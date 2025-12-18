<template>
	<div class="relative h-full">
		<!-- 背景圖：加上 object-cover 確保填滿且不變形 -->
		<img src="~/assets/images/end_cover.png" class="h-full" />

		<!-- 底部容器：關鍵是加上 w-full left-0，這樣 items-center 才會在正中間 -->
		<!-- pb-20 用來留出底部安全距離 -->
		<div
			class="absolute bottom-0 left-0 w-full flex flex-col justify-center items-center pb-40"
		>
			<!-- === 長條式進度條容器 === -->
			<div
				class="w-3/4 max-w-2xl h-2 bg-gray-800/20 rounded-full overflow-hidden relative"
			>
				<!-- 進度條本體 -->
				<div
					class="h-full bg-black shadow-[0_0_15px_rgba(6,182,212,0.8)] transition-all duration-75 ease-linear"
					:style="{ width: `${progress}%` }"
				></div>
			</div>

			<!-- 顯示秒數 -->
			<div class="mt-4 font-mono text-white text-xl font-bold">
				{{ Math.ceil((DURATION * (1 - progress / 100)) / 1000) }}s
			</div>
		</div>
	</div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from "vue";
import { useRouter } from "vue-router";

const router = useRouter();

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
