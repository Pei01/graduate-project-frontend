<template>
	<div
		class="fixed top-1/2 left-1/2 pointer-events-none z-9999"
		:style="cursorStyle"
	>
		<!-- cursor -->
		<div class="w-4 h-4 opacity-40 bg-white rounded-full"></div>

		<!-- dwell progress -->
		<svg
			class="absolute -top-6 -left-6"
			width="60"
			height="60"
		>
			<circle
				cx="30"
				cy="30"
				r="26"
				stroke="rgba(255,255,255,0.3)"
				stroke-width="4"
				fill="none"
			/>
			<circle
				cx="30"
				cy="30"
				r="26"
				stroke="white"
				stroke-width="4"
				fill="none"
				:stroke-dasharray="circumference"
				:stroke-dashoffset="progressOffset"
				stroke-linecap="round"
			/>
		</svg>
	</div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from "vue";
import { io } from "socket.io-client";

/* =====================
   基本狀態
===================== */
const x = ref(0);
const y = ref(0);

const hoverStartTime = ref<number | null>(null);
const hoveredElement = ref<HTMLElement | null>(null);

const DWELL_TIME = 3000; // ms

/* =====================
   Socket
===================== */
const socket = io("http://172.20.10.4:5000"); // 自行改

onMounted(() => {
	socket.on("cursor", ({ x: nx, y: ny }) => {
		x.value = nx;
		y.value = ny;
		handleHoverCheck();
	});
});

onUnmounted(() => {
	socket.disconnect();
});

/* =====================
   座標映射
   假設 x,y 為 0~1
===================== */
const screenX = computed(() => x.value * window.innerWidth);
const screenY = computed(() => y.value * window.innerHeight);

const cursorStyle = computed(() => ({
	transform: `translate(${screenX.value}px, ${screenY.value}px)`,
}));

/* =====================
   命中測試 + dwell
===================== */
function handleHoverCheck() {
	const el = document.elementFromPoint(screenX.value, screenY.value);
	const clickable = el?.closest("[data-kinect-clickable]") as HTMLElement | null;

	if (clickable !== hoveredElement.value) {
		hoveredElement.value = clickable;
		hoverStartTime.value = clickable ? performance.now() : null;
		return;
	}

	if (!clickable || hoverStartTime.value === null) return;

	const elapsed = performance.now() - hoverStartTime.value;
	if (elapsed >= DWELL_TIME) {
		triggerClick(clickable);
		hoverStartTime.value = null;
		hoveredElement.value = null;
	}
}

function triggerClick(el: HTMLElement) {
	el.dispatchEvent(new MouseEvent("click", { bubbles: true }));
}

/* =====================
   Progress circle
===================== */
const isHoveringClickable = computed(() => !!hoveredElement.value);

const progress = computed(() => {
	if (!hoverStartTime.value) return 0;
	return Math.min((performance.now() - hoverStartTime.value) / DWELL_TIME, 1);
});

const circumference = 2 * Math.PI * 26;
const progressOffset = computed(() => circumference * (1 - progress.value));
</script>
