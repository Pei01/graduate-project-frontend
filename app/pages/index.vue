<template>
	<div
		class="crt-overlay relative h-screen w-full overflow-hidden flex flex-col"
		style="background-color: #0d0221;"
	>
		<!-- Floating star pixels -->
		<div class="absolute inset-0 pointer-events-none z-0">
			<div
				v-for="i in 8"
				:key="i"
				class="absolute w-1 h-1 rounded-full"
				style="background: #ffd700; animation: pixel-float 4s linear infinite;"
				:style="{
					left: `${[8, 18, 33, 48, 62, 72, 85, 92][i - 1]}%`,
					top: `${[70, 85, 60, 90, 75, 80, 65, 88][i - 1]}%`,
					animationDelay: `${(i - 1) * 0.55}s`,
					animationDuration: `${3.5 + (i % 3) * 0.8}s`,
				}"
			/>
		</div>

		<!-- TOP HUD BAR -->
		<div
			class="relative z-10 flex items-center justify-between px-4 py-2"
			style="font-family: 'Press Start 2P', monospace; font-size: 12px; color: #ffd700; border-bottom: 1px solid #ff0066; box-shadow: 0 2px 8px #ff006680;"
		>
			<span>HI-SCORE</span>
			<span class="neon-text-gold">999999</span>
			<span>PLAYER 1</span>
		</div>

		<!-- MAIN CONTENT -->
		<div class="relative z-10 flex flex-col items-center justify-center flex-1 px-6 gap-6">

			<!-- Title block -->
			<div class="text-center">
				<h1
					class="glitch neon-text-pink"
					style="font-family: 'Press Start 2P', monospace; font-size: 54px; line-height: 1.2; letter-spacing: 2px;"
				>
					SHORTS
				</h1>
				<h2
					class="neon-text-cyan mt-1"
					style="font-family: 'Press Start 2P', monospace; font-size: 17px; letter-spacing: 4px;"
				>
					ARCADE
				</h2>
				<div
					class="mt-3 mx-auto"
					style="height: 2px; width: 260px; background: linear-gradient(90deg, transparent, #00ffff, #ff0066, transparent);"
				/>
				<p
					class="mt-2"
					style="font-family: 'VT323', monospace; font-size: 27px; color: #ffffff80; letter-spacing: 2px;"
				>
					{{ episodeText }}<span v-if="showCursor" class="blink">_</span>
				</p>
			</div>

			<!-- Stick figure: arms raised -->
			<svg width="80" height="110" viewBox="0 0 80 110" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
				<!-- Head -->
				<circle cx="40" cy="14" r="10" stroke="#00ffff" stroke-width="2.5" />
				<!-- Body -->
				<line x1="40" y1="24" x2="40" y2="68" stroke="#00ffff" stroke-width="2.5" />
				<!-- Left arm (偏水平，旋轉時手往上下揮) -->
				<line class="gesture-arm-left" x1="40" y1="36" x2="8" y2="32" stroke="#ff0066" stroke-width="2.5" style="transform-origin: 40px 36px;" />
				<!-- Right arm (偏水平，旋轉時手往上下揮) -->
				<line class="gesture-arm-right" x1="40" y1="36" x2="72" y2="32" stroke="#ff0066" stroke-width="2.5" style="transform-origin: 40px 36px;" />
				<!-- Left leg -->
				<line x1="40" y1="68" x2="22" y2="96" stroke="#00ffff" stroke-width="2.5" />
				<!-- Right leg -->
				<line x1="40" y1="68" x2="58" y2="96" stroke="#00ffff" stroke-width="2.5" />
			</svg>

			<!-- Gesture instruction -->
			<div class="text-center" style="font-family: 'VT323', monospace;">
				<p style="font-size: 30px; color: #00ffff; letter-spacing: 2px;">雙手舉起</p>
				<p class="blink mt-1" style="font-size: 33px; color: #ffffff; letter-spacing: 1px;">▶ 開始遊戲 ◀</p>
			</div>

			<!-- INSERT COIN + button -->
			<div class="flex flex-col items-center gap-6">
				<p
					class="blink"
					style="font-family: 'Press Start 2P', monospace; font-size: 15px; color: #ffd700; letter-spacing: 2px;"
				>
					{{ insertCoinDisplay }}
				</p>

				<button
					class="button-bounce kinect-interactive neon-border-pink flex items-center justify-center gap-2 px-8 py-3"
					style="font-family: 'Press Start 2P', monospace; font-size: 18px; color: #ff0066; background: rgba(255,0,102,0.08); cursor: pointer; letter-spacing: 1px;"
					@click="handleStateChange"
				>
					PLAY ▶
				</button>

			</div>
		</div>

		<!-- BOTTOM BAR -->
		<div
			class="relative z-10 text-center py-2"
			style="font-family: 'VT323', monospace; font-size: 21px; color: #ffffff30; border-top: 1px solid #ffffff15;"
		>
			© 2026 ATTENTION CO., LTD. ALL RIGHTS RESERVED
		</div>
	</div>
</template>

<script setup lang="ts">
import { useRouter } from "vue-router";

const router = useRouter();

const handleStateChange = () => {
	router.push("/tutorial");
};

// --- Typewriter (one-time) ---
const EPISODE_FULL = "SEASON 1 · EPISODE INFINITE";
const episodeText = ref("");
const showCursor = ref(true);

// --- PAY WITH TIME / INSERT ATTENTION alternating ---
const COIN_BASE = "◉ PAY WITH TIME ◉";
const ATTENTION_TARGET = "◉ INSERT ATTENTION ◉";
const insertCoinDisplay = ref(COIN_BASE);

let typeTimerId: ReturnType<typeof setInterval> | null = null;
let alternateId: ReturnType<typeof setInterval> | null = null;

onMounted(() => {
	window.addEventListener("hand-up", handleStateChange);

	// One-time typewriter
	let i = 0;
	typeTimerId = setInterval(() => {
		i++;
		episodeText.value = EPISODE_FULL.substring(0, i);
		if (i >= EPISODE_FULL.length) {
			clearInterval(typeTimerId!);
			setTimeout(() => { showCursor.value = false; }, 800);
		}
	}, 70);

	// Alternate between PAY WITH TIME and INSERT ATTENTION every 3s
	alternateId = setInterval(() => {
		insertCoinDisplay.value =
			insertCoinDisplay.value === COIN_BASE ? ATTENTION_TARGET : COIN_BASE;
	}, 3000);
});

onUnmounted(() => {
	window.removeEventListener("hand-up", handleStateChange);
	if (typeTimerId) clearInterval(typeTimerId);
	if (alternateId) clearInterval(alternateId);
});
</script>
