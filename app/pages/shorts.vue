<template>
	<div
		class="h-full w-full bg-black flex relative justify-center items-center overflow-hidden"
	>
		<!-- 影片滑動容器 -->
		<div
			class="w-full h-full transition-transform ease-[cubic-bezier(0.25,0.1,0.25,1.0)]"
			:style="{
				transform: `translateY(-${currentIndex * 100}%)`,
				transitionDuration: `${transitionDuration}ms`,
			}"
		>
			<div
				v-for="(video, index) in extendedVideos"
				:key="`${video.id}-${index}`"
				class="h-full relative flex justify-center items-center bg-black"
			>
				<video
					:ref="(el) => { if (el) videoRefs[index] = el }"
					class="w-full h-full transition-opacity duration-300"
					:class="getVideoStyle(index)"
					:src="video.src"
					loop
					playsinline
					@click="changeVideo(1)"
					@loadedmetadata="onMetadataLoaded($event, index)"
				/>

				<!-- 正在播放 label (左上角) -->
				<div class="absolute top-4 left-4 z-10 pointer-events-none px-2 py-1">
					<p
						class="neon-text-gold"
						style="font-family: 'VT323', monospace; font-size: 24px; letter-spacing: 2px;"
					>
						&gt; 正在播放_
					</p>
				</div>

				<!-- 影片標題與描述 (左下角) -->
				<!-- <div class="absolute bottom-[100px] left-4 z-10 pointer-events-none w-3/4">
					<h2
						class="mb-1"
						style="font-family: 'Press Start 2P', monospace; font-size: 18px; line-height: 1.5; color: #00ffff; text-shadow: 0 0 4px #00ffff50, 0 0 8px #00ffff25;"
					>
						{{ video.title }}
					</h2>
					<p
						style="font-family: 'VT323', monospace; font-size: 14px; color: #ffffffcc; text-shadow: 0 1px 4px rgba(0,0,0,0.9);"
					>
						{{ video.desc }}
					</p>
				</div> -->
			</div>
		</div>

		<!-- 右上角影片計數器 -->
		<div
			class="absolute top-3 right-3 z-20 neon-border-gold text-center px-3 py-2"
			style="background: rgba(13,2,33,0.85);"
		>
			<p style="font-family: 'Press Start 2P', monospace; font-size: 11px; color: #ffd700; letter-spacing: 1px;">影片</p>
			<p class="neon-text-gold" style="font-family: 'Press Start 2P', monospace; font-size: 21px; margin-top: 2px;">
				{{ String(displayIndex).padStart(2, "0") }}
			</p>
		</div>

		<!-- 底部 HUD 控制面板 -->
		<div
			class="absolute bottom-0 left-0 right-0 z-20 flex items-center justify-between px-4 py-3"
			style="background: rgba(13,2,33,0.80); border-top: 1px solid rgba(0,255,255,0.25);"
		>
			<!-- 左側：踢腳動作提示 -->
			<div class="flex flex-col items-center gap-1">
				<svg width="32" height="48" viewBox="0 0 32 48" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
					<circle cx="16" cy="6" r="5" stroke="#00ffff" stroke-width="1.5" />
					<line x1="16" y1="11" x2="16" y2="30" stroke="#00ffff" stroke-width="1.5" />
					<line x1="16" y1="18" x2="6" y2="24" stroke="#00ffff" stroke-width="1.5" />
					<line x1="16" y1="18" x2="26" y2="24" stroke="#00ffff" stroke-width="1.5" />
					<line x1="16" y1="30" x2="8" y2="44" stroke="#00ffff" stroke-width="1.5" />
					<line
						class="gesture-leg-kick"
						x1="16" y1="30" x2="28" y2="38"
						stroke="#ff0066" stroke-width="1.5"
						style="transform-origin: 16px 30px;"
					/>
				</svg>
				<span
					style="font-family: 'VT323', monospace; font-size: 20px; color: #00ffff; letter-spacing: 1px; text-shadow: 0 0 6px #00ffff;"
				>
					踢腳=下一部
				</span>
			</div>

			<!-- 右側：舉手動作提示 -->
			<div class="flex flex-col items-center gap-1">
				<svg width="32" height="48" viewBox="0 0 32 48" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
					<circle cx="16" cy="6" r="5" stroke="#ffd700" stroke-width="1.5" />
					<line x1="16" y1="11" x2="16" y2="30" stroke="#ffd700" stroke-width="1.5" />
					<line
						class="gesture-arm-left"
						x1="16" y1="18" x2="6" y2="12"
						stroke="#ff0066" stroke-width="1.5"
						style="transform-origin: 16px 18px;"
					/>
					<line
						class="gesture-arm-right"
						x1="16" y1="18" x2="26" y2="12"
						stroke="#ff0066" stroke-width="1.5"
						style="transform-origin: 16px 18px;"
					/>
					<line x1="16" y1="30" x2="8" y2="44" stroke="#ffd700" stroke-width="1.5" />
					<line x1="16" y1="30" x2="24" y2="44" stroke="#ffd700" stroke-width="1.5" />
				</svg>
				<span
					style="font-family: 'VT323', monospace; font-size: 20px; color: #ffd700; letter-spacing: 1px; text-shadow: 0 0 6px #ffd700;"
				>
					舉手=離開
				</span>
			</div>
		</div>
	</div>
</template>

<script setup>
import { ref, computed, watch, onMounted, onUnmounted, nextTick } from "vue";
import { useRouter } from "vue-router";

// === 1. 原始資料 ===
const rawVideos = [
	{
		id: 1,
		src: "/videos/short1.mp4",
		title: "貓咪大廚的煩惱",
		desc: "貓咪大廚煮麵又煮糊了，被老闆罵了一頓，真是太難了！",
	},
	{
		id: 2,
		src: "/videos/short2.mp4",
		title: "貓咪的秘密身分",
		desc: "你看這隻貓咪多可愛...等等！牠怎麼突然變成了百獸之王？",
	},
	{
		id: 3,
		src: "/videos/short3.mp4",
		title: "保險箱裡的寶藏",
		desc: "費盡千辛萬苦解開了最安全的保險箱，結果裡面的東西讓人哭笑不得。",
	},
	{
		id: 4,
		src: "/videos/short4.mp4",
		title: "恐龍鄰居來敲門",
		desc: "當侏羅紀恐龍出現在家門口試圖惡作劇，卻遇上了淡定的阿嬤...",
	},
	{
		id: 5,
		src: "/videos/short5.mp4",
		title: "Emina 的市集大冒險",
		desc: "今天帶大家來到傳統市場，這裡充滿了熱情的攤販與意想不到的好物！",
	},
	{
		id: 6,
		src: "/videos/short6.mp4",
		title: "復古貓咪時裝秀",
		desc: "穿越時空的貓咪們穿上了復古洋裝，優雅又可愛的模樣讓人融化。",
	},
	{
		id: 7,
		src: "/videos/short7.mp4",
		title: "貓咪復古迪斯可",
		desc: "穿著復古點點裙的貓咪們再次登場！這次帶來了默契十足的雙人手勢舞，魔性又可愛。",
	},
	{
		id: 8,
		src: "/videos/short8.mp4",
		title: "極致舒壓擠牙膏",
		desc: "五顏六色、充滿亮粉的牙膏擠在牙刷上的特寫，絕對是強迫症患者的最愛，視覺上的極致享受。",
	},
	{
		id: 9,
		src: "/videos/short9.mp4",
		title: "禪與自我覺醒",
		desc: "一場關於冥想、突破自我與蛻變的視覺旅程，尋找內心的平靜。",
	},
	{
		id: 10,
		src: "/videos/short10.mp4",
		title: "極致舒壓切水果",
		desc: "晶瑩剔透的水果切開瞬間，帶給你視覺與聽覺的雙重 ASMR 享受。",
	},
	{
		id: 11,
		src: "/videos/short11.mp4",
		title: "追逐財富的奔跑",
		desc: "我們每天忙碌奔波究竟是為了什麼？一支關於金錢與人生選擇的短片。",
	},
	{
		id: 12,
		src: "/videos/short12.mp4",
		title: "第一人稱雲霄飛車",
		desc: "抓緊扶手！帶你體驗在山林間穿梭、收集金幣的極速快感。",
	},
	{
		id: 13,
		src: "/videos/short13.mp4",
		title: "校園狼人熱舞",
		desc: "大家注意啦！清大校園驚見兩隻...愛跳舞的狼？跟著音樂一起嗨！",
	},
	{
		id: 14,
		src: "/videos/short14.mp4",
		title: "課堂上的震撼教育",
		desc: "學生突然站起來給了老師一巴掌？這到底是怎麼一回事？",
	},
	{
		id: 15,
		src: "/videos/short15.mp4",
		title: "暖呼呼的小豬",
		desc: "冬天就是要像這隻小豬一樣，裹在暖暖的毛毯裡，露出幸福的表情！",
	},
	{
		id: 16,
		src: "/videos/short16.mp4",
		title: "半夜的搖滾貓",
		desc: "凌晨兩點不睡覺在門口打鼓？這隻貓咪的搖滾魂燃燒得太不是時候啦！",
	},
	{
		id: 17,
		src: "/videos/short17.mp4",
		title: "寶寶老闆的真心話",
		desc: "街訪路邊的小朋友，沒想到他們的回答竟然充滿了人生哲理？",
	},
];

const router = useRouter();

// === 2. 狀態管理 ===
// 結構：[CloneLast, Real1..Real17, CloneFirst]，從 index 1 (Real1) 開始
const currentIndex = ref(1);

// 用 plain array，不用 ref，避免 reactivity 觸發額外 re-render
const videoRefs = [];
const transitionDuration = ref(500);
let isAnimating = false;
let loopResetTimer = null;

const videoOrientations = ref({});

// === 觀看時長與覆蓋率追蹤 ===
const watchStartTime = ref(null);
const totalWatchSeconds = ref(0);
const watchedVideoIds = ref(new Set());

// === 判斷影片方向 ===
const onMetadataLoaded = (event, index) => {
	const { videoWidth, videoHeight } = event.target;
	if (videoWidth > videoHeight) {
		videoOrientations.value[index] = "landscape";
	} else {
		videoOrientations.value[index] = "portrait";
	}
};

// === 取得當前索引對應的真實影片 ID ===
const getCurrentRealVideoId = (index) => {
	const video = extendedVideos.value[index];
	if (!video || video.isClone) return null;
	return typeof video.id === "number" ? video.id : null;
};

// === 根據方向回傳對應 class ===
const getVideoStyle = (index) => {
	const orientation = videoOrientations.value[index];
	if (orientation === "landscape") {
		return "object-contain";
	} else {
		return "object-cover";
	}
};

// === 建構無限輪播資料 ===
const extendedVideos = computed(() => {
	const firstClone = { ...rawVideos[0], id: "clone-first", isClone: true };
	const lastClone = { ...rawVideos[rawVideos.length - 1], id: "clone-last", isClone: true };
	return [lastClone, ...rawVideos, firstClone];
});

// === 切換影片邏輯 ===
const changeVideo = (direction) => {
	if (isAnimating) return;
	isAnimating = true;
	transitionDuration.value = 500;
	currentIndex.value += direction;
	loopResetTimer = setTimeout(() => {
		handleLoopReset();
		isAnimating = false;
	}, 500);
};

const handleLoopReset = () => {
	const total = extendedVideos.value.length;
	if (currentIndex.value === total - 1) {
		transitionDuration.value = 0;
		currentIndex.value = 1;
	} else if (currentIndex.value === 0) {
		transitionDuration.value = 0;
		currentIndex.value = total - 2;
	}
};

// === 播放控制 ===
watch(currentIndex, async (newIdx, oldIdx) => {
	if (watchStartTime.value !== null) {
		totalWatchSeconds.value += (Date.now() - watchStartTime.value) / 1000;
	}
	watchStartTime.value = Date.now();

	const newVideoId = getCurrentRealVideoId(newIdx);
	if (newVideoId !== null) {
		watchedVideoIds.value.add(newVideoId);
	}

	await nextTick();
	if (oldIdx !== undefined && videoRefs[oldIdx]) {
		videoRefs[oldIdx].pause();
		videoRefs[oldIdx].currentTime = 0;
	}
	if (videoRefs[newIdx]) {
		try {
			await videoRefs[newIdx].play();
		} catch (err) {}
	}
});

const displayIndex = computed(() => {
	const realLength = rawVideos.length;
	if (currentIndex.value === 0) return realLength;
	if (currentIndex.value === extendedVideos.value.length - 1) return 1;
	return currentIndex.value;
});

// 狀態管理：選擇的動物
const selectedAnimal = useState("selectedAnimal");

// 狀態管理：觀看統計（供 end.vue 使用）
const watchStats = useState("watchStats", () => ({ watchSeconds: 0, watchedPercent: 0, watchedCount: 0 }));

const handleEnded = async () => {
	if (watchStartTime.value !== null) {
		totalWatchSeconds.value += (Date.now() - watchStartTime.value) / 1000;
		watchStartTime.value = null;
	}

	const watchSeconds = Math.round(totalWatchSeconds.value);
	const watchedPercent = Math.round(
		(watchedVideoIds.value.size / rawVideos.length) * 100
	);

	watchStats.value = { watchSeconds, watchedPercent, watchedCount: watchedVideoIds.value.size };

	const URL = "http://172.20.10.5:4000/api/print";

	try {
		await $fetch(URL, {
			method: "POST",
			body: {
				message: selectedAnimal.value || null,
				watchSeconds,
				watchedPercent,
			},
		});
	} catch (e) {
		console.error("Print failed:", e);
	}

	router.push("/end");
};

const handleHandUp = () => {
	handleEnded();
};

const handleKick = () => {
	changeVideo(1);
};

onMounted(() => {
	nextTick(() => {
		// 從 index 1 (Real1) 開始播放
		if (videoRefs[1]) {
			videoRefs[1].play().catch(() => {});
			watchStartTime.value = Date.now();
			watchedVideoIds.value.add(rawVideos[0].id);
		}
	});

	window.addEventListener("hand-up", handleHandUp);
	window.addEventListener("kick", handleKick);
});

onUnmounted(() => {
	if (loopResetTimer) clearTimeout(loopResetTimer);
	videoRefs.forEach((video) => {
		if (video) video.pause();
	});
	window.removeEventListener("hand-up", handleHandUp);
	window.removeEventListener("kick", handleKick);
});
</script>
