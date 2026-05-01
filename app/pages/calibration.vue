<template>
	<div class="min-h-screen bg-arcade-dark text-white p-6 font-terminal">
		<div class="max-w-7xl mx-auto">
			<header class="mb-6 flex items-baseline gap-4">
				<h1 class="text-3xl neon-text-cyan font-arcade">KINECT RANGE</h1>
				<span class="text-neon-gold/80 text-sm">
					{{ connected ? "● connected" : "○ disconnected" }}
				</span>
				<span class="text-white/50 text-sm">
					偵測到 {{ bodies.length }} 人,框內 {{ inRangeCount }} 人
				</span>
			</header>

			<div class="grid grid-cols-1 lg:grid-cols-[800px_1fr] gap-6">
				<!-- 雷達 -->
				<div class="neon-border-cyan rounded p-2 bg-black/40">
					<canvas
						ref="canvasRef"
						width="800"
						height="800"
						class="block w-full h-auto"
					/>
					<div class="text-xs text-white/60 mt-2 flex justify-between px-2">
						<span>俯視圖 X-Z 平面 (mm) · Kinect 在底部中央</span>
						<span>每格 500mm · 視野錐 ±37.5°</span>
					</div>
				</div>

				<!-- 控制面板 -->
				<div class="space-y-6">
					<div
						v-for="cfg in sliders"
						:key="cfg.key"
						class="neon-border-pink rounded p-4"
					>
						<div class="flex justify-between items-baseline mb-2">
							<label class="font-arcade text-sm neon-text-pink">{{ cfg.label }}</label>
							<span class="text-neon-gold text-lg">{{ Math.round(range[cfg.key]) }} mm</span>
						</div>
						<input
							type="range"
							:min="cfg.min"
							:max="cfg.max"
							:step="50"
							v-model.number="range[cfg.key]"
							@input="onRangeInput"
							class="w-full"
						/>
						<div class="flex justify-between text-[10px] text-white/40 mt-1">
							<span>{{ cfg.min }}</span>
							<span>{{ cfg.max }}</span>
						</div>
					</div>

					<button
						@click="copyAsPython"
						class="w-full neon-border-gold rounded p-3 font-arcade text-neon-gold hover:bg-neon-gold/10 transition"
					>
						{{ copyLabel }}
					</button>

					<pre class="text-xs text-white/70 bg-black/40 p-3 rounded overflow-x-auto">{{ pythonSnippet }}</pre>
				</div>
			</div>
		</div>
	</div>
</template>

<script setup>
import { onMounted, onUnmounted, ref, reactive, computed, nextTick } from "vue";
import { io } from "socket.io-client";

definePageMeta({ layout: false });

const SOCKET_URL = "http://127.0.0.1:5000";

const canvasRef = ref(null);
const socket = ref(null);
const connected = ref(false);
const bodies = ref([]);
const activeId = ref(null);

const range = reactive({
	x_min: -2000,
	x_max: 2000,
	z_min: 500,
	z_max: 5000,
});

const sliders = [
	{ key: "x_min", label: "X MIN (左界)", min: -3000, max: 0 },
	{ key: "x_max", label: "X MAX (右界)", min: 0, max: 3000 },
	{ key: "z_min", label: "Z MIN (近界)", min: 0, max: 3000 },
	{ key: "z_max", label: "Z MAX (遠界)", min: 500, max: 6000 },
];

const inRangeCount = computed(() => bodies.value.filter(b => b.in_range).length);

const pythonSnippet = computed(() => {
	return `calibration_range = {
    "x_min": ${Math.round(range.x_min)}.0, "x_max": ${Math.round(range.x_max)}.0,
    "z_min": ${Math.round(range.z_min)}.0, "z_max": ${Math.round(range.z_max)}.0,
}`;
});

const copyLabel = ref("COPY AS PYTHON");
const copyAsPython = async () => {
	try {
		await navigator.clipboard.writeText(pythonSnippet.value);
		copyLabel.value = "COPIED ✓";
		setTimeout(() => (copyLabel.value = "COPY AS PYTHON"), 1500);
	} catch (e) {
		copyLabel.value = "COPY FAILED";
	}
};

// --- Slider 變動 → debounce 後送後端 ---
let emitTimer = null;
const onRangeInput = () => {
	if (emitTimer) clearTimeout(emitTimer);
	emitTimer = setTimeout(() => {
		if (!socket.value) return;
		socket.value.emit("set_calibration_range", {
			x_min: range.x_min,
			x_max: range.x_max,
			z_min: range.z_min,
			z_max: range.z_max,
		});
	}, 100);
};

// --- 雷達繪製 ---
// X 軸: -3000 ~ 3000 mm,共 6000mm
// Z 軸: 0 ~ 6000 mm
// Canvas 800x800,Kinect 位於下緣中央
const X_RANGE = 6000;
const Z_RANGE = 6000;

const worldToCanvas = (x, z, canvasW, canvasH) => {
	const cx = (x / X_RANGE + 0.5) * canvasW;
	const cy = canvasH - (z / Z_RANGE) * canvasH;
	return [cx, cy];
};

const drawRadar = () => {
	const canvas = canvasRef.value;
	if (!canvas) return;
	const ctx = canvas.getContext("2d");
	const W = canvas.width;
	const H = canvas.height;

	// 背景
	ctx.fillStyle = "#0d0221";
	ctx.fillRect(0, 0, W, H);

	// 1m 網格
	ctx.strokeStyle = "rgba(255,255,255,0.08)";
	ctx.lineWidth = 1;
	for (let x = -3000; x <= 3000; x += 500) {
		const [cx] = worldToCanvas(x, 0, W, H);
		ctx.beginPath();
		ctx.moveTo(cx, 0);
		ctx.lineTo(cx, H);
		ctx.stroke();
	}
	for (let z = 0; z <= 6000; z += 500) {
		const [, cy] = worldToCanvas(0, z, W, H);
		ctx.beginPath();
		ctx.moveTo(0, cy);
		ctx.lineTo(W, cy);
		ctx.stroke();
	}

	// 中軸
	ctx.strokeStyle = "rgba(255,255,255,0.2)";
	const [cxAxis] = worldToCanvas(0, 0, W, H);
	ctx.beginPath();
	ctx.moveTo(cxAxis, 0);
	ctx.lineTo(cxAxis, H);
	ctx.stroke();

	// 軸標籤
	ctx.fillStyle = "rgba(255,255,255,0.5)";
	ctx.font = "12px VT323, monospace";
	for (let z = 1000; z <= 6000; z += 1000) {
		const [, cy] = worldToCanvas(0, z, W, H);
		ctx.fillText(`${z / 1000}m`, cxAxis + 4, cy - 2);
	}

	// FOV 視角錐 (NFOV 約 ±37.5°)
	ctx.strokeStyle = "rgba(0,255,255,0.25)";
	ctx.lineWidth = 1;
	const fovDeg = 37.5;
	const fovRad = (fovDeg * Math.PI) / 180;
	const farZ = 6000;
	const farX = farZ * Math.tan(fovRad);
	const [kx, ky] = worldToCanvas(0, 0, W, H);
	const [lx, ly] = worldToCanvas(-farX, farZ, W, H);
	const [rx, ry] = worldToCanvas(farX, farZ, W, H);
	ctx.beginPath();
	ctx.moveTo(kx, ky);
	ctx.lineTo(lx, ly);
	ctx.moveTo(kx, ky);
	ctx.lineTo(rx, ry);
	ctx.stroke();

	// Bounding box (當前範圍)
	const [bx1, by1] = worldToCanvas(range.x_min, range.z_max, W, H);
	const [bx2, by2] = worldToCanvas(range.x_max, range.z_min, W, H);
	ctx.fillStyle = "rgba(0,255,255,0.12)";
	ctx.fillRect(bx1, by1, bx2 - bx1, by2 - by1);
	ctx.strokeStyle = "#00ffff";
	ctx.lineWidth = 2;
	ctx.strokeRect(bx1, by1, bx2 - bx1, by2 - by1);

	// 偵測到的人
	for (const body of bodies.value) {
		const [px, py] = worldToCanvas(body.x, body.z, W, H);
		const isActive = body.id === activeId.value;
		ctx.fillStyle = body.in_range
			? (isActive ? "#39ff14" : "#00ffff")
			: "rgba(180,180,180,0.55)";
		ctx.beginPath();
		ctx.arc(px, py, isActive ? 14 : 10, 0, Math.PI * 2);
		ctx.fill();

		ctx.fillStyle = "white";
		ctx.font = "14px VT323, monospace";
		ctx.fillText(`#${body.id}`, px + 14, py + 4);
		ctx.fillStyle = "rgba(255,255,255,0.6)";
		ctx.font = "11px VT323, monospace";
		ctx.fillText(`(${Math.round(body.x)}, ${Math.round(body.z)})`, px + 14, py + 18);
	}

	// Kinect 標記
	ctx.fillStyle = "#ff0066";
	ctx.beginPath();
	ctx.arc(kx, ky - 4, 8, 0, Math.PI * 2);
	ctx.fill();
	ctx.fillStyle = "#ff0066";
	ctx.font = "14px 'Press Start 2P', monospace";
	ctx.fillText("KINECT", kx - 30, ky - 16);
};

let rafHandle = null;
const scheduleDraw = () => {
	if (rafHandle) return;
	rafHandle = requestAnimationFrame(() => {
		rafHandle = null;
		drawRadar();
	});
};

onMounted(async () => {
	await nextTick();
	drawRadar();

	socket.value = io(SOCKET_URL);
	socket.value.on("connect", () => {
		connected.value = true;
		// 同步當前後端範圍
		socket.value.emit("get_calibration_range");
	});
	socket.value.on("disconnect", () => {
		connected.value = false;
	});
	socket.value.on("calibration_range", (data) => {
		if (!data) return;
		for (const k of ["x_min", "x_max", "z_min", "z_max"]) {
			if (typeof data[k] === "number") range[k] = data[k];
		}
		scheduleDraw();
	});
	socket.value.on("skeleton_positions", (data) => {
		bodies.value = Array.isArray(data?.bodies) ? data.bodies : [];
		activeId.value = data?.active_id ?? null;
		scheduleDraw();
	});
});

onUnmounted(() => {
	if (emitTimer) clearTimeout(emitTimer);
	if (rafHandle) cancelAnimationFrame(rafHandle);
	if (socket.value) socket.value.disconnect();
});
</script>

<style scoped>
input[type="range"] {
	-webkit-appearance: none;
	appearance: none;
	height: 6px;
	background: linear-gradient(to right, #ff0066, #00ffff);
	border-radius: 3px;
	outline: none;
}
input[type="range"]::-webkit-slider-thumb {
	-webkit-appearance: none;
	appearance: none;
	width: 20px;
	height: 20px;
	background: #ffd700;
	border-radius: 50%;
	cursor: pointer;
	box-shadow: 0 0 8px #ffd700;
}
input[type="range"]::-moz-range-thumb {
	width: 20px;
	height: 20px;
	background: #ffd700;
	border-radius: 50%;
	cursor: pointer;
	border: none;
	box-shadow: 0 0 8px #ffd700;
}
</style>
