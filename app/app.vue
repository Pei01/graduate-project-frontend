<template>
	<div class="relative h-screen w-full bg-black">
		<!-- 
			★ 全域背景音樂 ★
			放在這裡可以確保換頁時音樂不中斷。
			ref="bgmAudio" 用來讓 JS 控制播放/暫停。
		-->
		<audio ref="bgmAudio" loop hidden>
			<!-- 請確認檔案路徑 -->
			<source src="/audio/bgm.mp3" type="audio/mpeg" />
		</audio>

		<div class="absolute h-full left-96 w-[390px]">
			<KinectCursor />
			<NuxtPage />
		</div>
	</div>
</template>

<script setup>
import { ref, watch, onMounted } from "vue";
import { useRoute } from "vue-router";

const route = useRoute();
const bgmAudio = ref(null);

// === 音樂淡入淡出設定 ===
const TARGET_VOLUME = 0.5; // 目標音量 (最大聲)
let fadeInterval = null;   // 儲存計時器 ID

// 淡出函式 (Fade Out)
const fadeOut = () => {
	const audio = bgmAudio.value;
	if (!audio) return;

	// 清除之前的淡入淡出排程，避免衝突
	if (fadeInterval) clearInterval(fadeInterval);

	// 每 100ms 降低 0.05 音量 (約 1 秒淡出完畢)
	fadeInterval = setInterval(() => {
		if (audio.volume > 0.05) {
			audio.volume = Math.max(0, audio.volume - 0.05);
		} else {
			// 音量歸零後，真正暫停音樂
			audio.volume = 0;
			audio.pause();
			clearInterval(fadeInterval);
			fadeInterval = null;
		}
	}, 100);
};

// 淡入函式 (Fade In)
const fadeIn = () => {
	const audio = bgmAudio.value;
	if (!audio) return;

	if (fadeInterval) clearInterval(fadeInterval);

	// 如果是暫停狀態，先將音量歸零並開始播放
	if (audio.paused) {
		audio.volume = 0;
		audio.play().catch((e) => {
			console.log("Autoplay prevented:", e);
		});
	}

	// 每 100ms 增加 0.05 音量
	fadeInterval = setInterval(() => {
		if (audio.volume < TARGET_VOLUME - 0.05) {
			audio.volume = Math.min(TARGET_VOLUME, audio.volume + 0.05);
		} else {
			audio.volume = TARGET_VOLUME;
			clearInterval(fadeInterval);
			fadeInterval = null;
		}
	}, 100);
};

// === 音樂控制核心邏輯 ===
const manageBGM = () => {
	if (!bgmAudio.value) return;

	// 判斷當前路徑
	const isSilentPage = route.path === "/shorts";

	if (isSilentPage) {
		// 如果在影片頁，且音樂正在播放，執行淡出
		if (!bgmAudio.value.paused) {
			fadeOut();
		}
	} else {
		// ★ 新增邏輯：如果是回到首頁 (Root)，將音樂重頭開始 ★
		if (route.path === "/") {
			bgmAudio.value.currentTime = 0;
		}

		// 如果在其他頁面 (包含首頁)
		// 1. 如果音樂是暫停的 (剛從影片頁回來) -> 淡入
		// 2. 如果音樂正在播但音量很小 (淡出到一半切回來) -> 淡入
		if (bgmAudio.value.paused || bgmAudio.value.volume < TARGET_VOLUME) {
			fadeIn();
		}
	}
};

// 1. 監聽路由變化：當使用者切換頁面時觸發
watch(
	() => route.path,
	() => {
		manageBGM();
	}
);

// 2. 初始化：當 App 剛載入時觸發
onMounted(() => {
	// 初始設定：直接設定音量並嘗試播放 (剛進站不需要淡入，直接播比較直覺)
	if (bgmAudio.value) {
		// 如果一進來就是在影片頁，就不播
		if (route.path === "/shorts") {
			return;
		}
		
		bgmAudio.value.volume = TARGET_VOLUME;
		bgmAudio.value.play().catch(() => {
			// 如果自動播放失敗，等待使用者點擊
			const startAudioOnInteraction = () => {
				manageBGM(); // 這裡會觸發 fadeIn，效果也不錯
				window.removeEventListener('click', startAudioOnInteraction);
			};
			window.addEventListener('click', startAudioOnInteraction);
		});
	}
});
</script>