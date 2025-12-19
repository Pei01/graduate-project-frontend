<template>
	<!-- ★ 修改：使用 v-show 或 v-if 根據路由隱藏游標 -->
	<div
		ref="cursorRef"
		class="fixed top-0 left-0 w-0 h-0 z-99999 pointer-events-none"
	>
		<!-- ... 原本的游標 HTML 保持不變 ... -->
		<div
			class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-5 h-5 rounded-full border-2 shadow-[0_0_10px_rgba(0,0,0,0.3)] transition-all duration-100"
			:class="
				isPulsing
					? 'bg-cyan-400/80 scale-150 border-cyan-200'
					: 'bg-white/60 border-white/90'
			"
		/>
		<svg
			v-if="isLoading"
			:key="loadingKey"
			class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 -rotate-90 overflow-visible"
			width="60"
			height="60"
			viewBox="0 0 60 60"
		>
			<circle class="fill-none stroke-white/20 stroke-4" cx="30" cy="30" r="26" />
			<circle
				class="fill-none stroke-[#00ffff] stroke-4 animate-fill"
				stroke-linecap="round"
				stroke-dasharray="164"
				stroke-dashoffset="164"
				cx="30"
				cy="30"
				r="26"
				:style="{ animationDuration: `${DWELL_TIME}ms` }"
			/>
		</svg>
	</div>
</template>

<script setup>
import { onMounted, onUnmounted, ref } from "vue";
import { io } from "socket.io-client";

// === 設定參數 ===
const DWELL_TIME = 3000;
const SOCKET_URL = "http://172.20.10.4:5000";
const SCREEN_OFFSET_X = 526;
const SCREEN_OFFSET_Y = 0;
const DEBOUNCE_MS = 200;

// === 狀態管理 ===
const cursorRef = ref(null);
const socket = ref(null);
const isLoading = ref(false);
const loadingKey = ref(0);
const isPulsing = ref(false);

let hoverTimer = null;
let debounceTimer = null;
let lastHoveredEl = null;

const handleMouseData = (data) => {
	// ★ 新增：如果當前頁面不應該顯示游標，就直接中止，節省效能
	if (!cursorRef.value) return;

	// ... (原本的座標計算與移動邏輯保持不變) ...
	const globalX = data.x + SCREEN_OFFSET_X;
	const globalY = data.y + SCREEN_OFFSET_Y;

	cursorRef.value.style.transform = `translate(${globalX}px, ${globalY}px)`;

	// 穿透偵測
	const elements = document.elementsFromPoint(globalX, globalY);

	let target = null;
	for (const el of elements) {
		const interactive = el.closest(".kinect-interactive");
		if (interactive) {
			target = interactive;
			break;
		}
	}
	handleDwellLogic(target);
};

// ... (原本的 handleDwellLogic, startLoading, stopLoading, triggerClick 等函式保持不變) ...
const handleDwellLogic = (target) => {
	if (target && lastHoveredEl === target) {
		if (debounceTimer) {
			clearTimeout(debounceTimer);
			debounceTimer = null;
		}
		return;
	}
	if (!target && lastHoveredEl) {
		if (!debounceTimer) {
			debounceTimer = setTimeout(() => {
				fullReset();
			}, DEBOUNCE_MS);
		}
		return;
	}
	if (debounceTimer) {
		clearTimeout(debounceTimer);
		debounceTimer = null;
	}
	fullReset();
	if (target) {
		lastHoveredEl = target;
		target.classList.add("is-hovered");
		startLoading(target);
	}
};

const fullReset = () => {
	if (lastHoveredEl) {
		lastHoveredEl.classList.remove("is-hovered");
	}
	stopLoading();
	lastHoveredEl = null;
};

const startLoading = (target) => {
	loadingKey.value++;
	isLoading.value = true;
	hoverTimer = setTimeout(() => {
		triggerClick(target);
		isLoading.value = false;
	}, DWELL_TIME);
};

const stopLoading = () => {
	isLoading.value = false;
	if (hoverTimer) {
		clearTimeout(hoverTimer);
		hoverTimer = null;
	}
};

const triggerClick = (el) => {
	isPulsing.value = true;
	setTimeout(() => {
		isPulsing.value = false;
	}, 300);
	el.click();
	el.focus();
};

onMounted(() => {
	socket.value = io(SOCKET_URL);

	// 1. 監聽游標移動
	socket.value.on("cursor_move", (data) => {
		requestAnimationFrame(() => handleMouseData(data));
	});

	// 2. ★ 新增：監聽舉手事件 (或其他手勢)
	socket.value.on("hand_event", (data) => {
		// 將事件轉發給全域 window，讓其他頁面可以監聽
		// data 可以包含 { type: 'hand_up' } 之類的資訊
		window.dispatchEvent(new CustomEvent("hand-up", { detail: data }));
	});
});

onUnmounted(() => {
	stopLoading();
	if (debounceTimer) clearTimeout(debounceTimer);
	if (socket.value) socket.value.disconnect();
});
</script>
