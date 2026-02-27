<template>
	<div
		class="crt-overlay relative h-screen w-full overflow-hidden flex flex-col"
		style="background-color: #0d0221;"
	>
		<!-- TOP HUD BAR -->
		<div
			class="relative z-10 flex items-center justify-between px-4 py-2"
			style="font-family: 'Press Start 2P', monospace; font-size: 8px; color: #ffd700; border-bottom: 1px solid #ff0066; box-shadow: 0 2px 8px #ff006680;"
		>
			<span>分數</span>
			<span class="neon-text-gold">001337</span>
			<span class="neon-text-pink">遊戲結束</span>
		</div>

		<!-- MAIN CONTENT -->
		<div class="relative z-10 flex flex-col items-center justify-center flex-1 px-6 gap-8">

			<!-- GAME OVER title -->
			<div class="text-center">
				<h1
					class="game-over-drop neon-text-pink"
					style="font-family: 'Press Start 2P', monospace; font-size: 42px; line-height: 1.1; letter-spacing: 2px;"
				>
					遊戲<br>結束
				</h1>
				<!-- Pixel dot separator -->
				<div class="flex items-center justify-center gap-1 mt-4">
					<span
						v-for="n in 20"
						:key="n"
						class="inline-block"
						style="width: 6px; height: 6px; background: #ff0066; box-shadow: 0 0 4px #ff0066;"
					/>
				</div>
			</div>

			<!-- Stats panel -->
			<div
				class="neon-border-cyan w-full max-w-xs px-6 py-4"
				style="background: rgba(0, 255, 255, 0.04);"
			>
				<div
					class="flex justify-between items-center mb-3"
					style="font-family: 'VT323', monospace; font-size: 22px;"
				>
					<span style="color: #ffffff90;">已觀看影片</span>
					<span class="neon-text-gold">{{ watchedStars }}</span>
				</div>
				<div
					class="flex justify-between items-center"
					style="font-family: 'VT323', monospace; font-size: 22px;"
				>
					<span style="color: #ffffff90;">關卡完成</span>
					<span class="neon-text-cyan">{{ watchStats.watchedPercent }}%</span>
				</div>
			</div>

			<!-- CONTINUE countdown -->
			<div class="flex flex-col items-center gap-3 w-full max-w-xs">
				<p
					class="blink"
					style="font-family: 'Press Start 2P', monospace; font-size: 11px; color: #ffd700; letter-spacing: 2px;"
				>
					繼續？
				</p>

				<!-- Big countdown number -->
				<div
					class="neon-text-pink"
					style="font-family: 'Press Start 2P', monospace; font-size: 56px; line-height: 1;"
				>
					{{ Math.ceil((DURATION * (1 - progress / 100)) / 1000) }}
				</div>

				<!-- Pixel segmented progress bar -->
				<div
					class="neon-border-pink w-full overflow-hidden relative"
					style="height: 20px; background: rgba(255,0,102,0.08);"
				>
					<!-- Pixel grid overlay -->
					<div
						class="absolute inset-0 pointer-events-none"
						style="background: repeating-linear-gradient(90deg, rgba(13,2,33,0.5) 0px, rgba(13,2,33,0.5) 2px, transparent 2px, transparent 18px); z-index: 2;"
					/>
					<!-- Progress fill -->
					<div
						class="h-full arcade-pulse transition-all ease-linear"
						style="background: #ff0066; duration: 75ms;"
						:style="{ width: `${progress}%`, transitionDuration: '75ms' }"
					/>
				</div>

				<p
					style="font-family: 'VT323', monospace; font-size: 16px; color: #ffffff50; letter-spacing: 2px;"
				>
					返回主畫面中...
				</p>
			</div>
		</div>

		<!-- BOTTOM BAR -->
		<div
			class="relative z-10 text-center py-2"
			style="font-family: 'VT323', monospace; font-size: 14px; color: #ffffff30; border-top: 1px solid #ffffff15;"
		>
			© 1984 NTHU ARCADE CO. ALL RIGHTS RESERVED
		</div>
	</div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from "vue";
import { useRouter } from "vue-router";

const router = useRouter();

// 從 shorts.vue 共享的觀看統計
const watchStats = useState("watchStats", () => ({ watchSeconds: 0, watchedPercent: 0, watchedCount: 0 }));

const watchedStars = computed(() => {
	const p = watchStats.value.watchedPercent;
	if (p >= 67) return "★★★";
	if (p >= 34) return "★★☆";
	if (p > 0)   return "★☆☆";
	return "☆☆☆";
});

// === 設定參數 ===
const DURATION = 5000; // 倒數時間 (毫秒)
const progress = ref(0); // 進度 (0 ~ 100)
let animationFrameId = null;

// === 核心邏輯：計時器 ===
const startCountdown = () => {
	const startTime = performance.now();

	const update = (currentTime) => {
		// 計算經過時間
		const elapsed = currentTime - startTime;

		// 計算百分比 (0 ~ 100)
		const percent = Math.min((elapsed / DURATION) * 100, 100);
		progress.value = percent;

		if (percent < 100) {
			// 繼續下一幀動畫
			animationFrameId = requestAnimationFrame(update);
		} else {
			// 時間到！執行跳轉
			goHome();
		}
	};

	// 啟動動畫迴圈
	animationFrameId = requestAnimationFrame(update);
};

// === 跳轉邏輯 ===
const goHome = () => {
	// 防止重複觸發
	if (animationFrameId) cancelAnimationFrame(animationFrameId);
	router.push("/");
};

onMounted(() => {
	startCountdown();
});

onUnmounted(() => {
	// 離開頁面時一定要清除動畫，避免記憶體洩漏或錯誤跳轉
	if (animationFrameId) cancelAnimationFrame(animationFrameId);
});
</script>
