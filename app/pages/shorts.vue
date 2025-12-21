<template>
	<div
		class="h-screen bg-black flex relative justify-center items-center overflow-hidden"
	>
		<!-- ... (Template 內容保持不變) ... -->

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
				class="h-screen relative flex justify-center items-center bg-black"
			>
				<video
					:ref="(el) => (videoRefs[index] = el)"
					class="w-full h-full transition-opacity duration-300"
					:class="getVideoStyle(index)"
					:src="video.src"
					loop
					playsinline
					@click="changeVideo(1)"
					@loadedmetadata="onMetadataLoaded($event, index)"
				/>

				<!-- 影片資訊 -->
				<div
					class="absolute bottom-24 left-5 text-white z-10 pointer-events-none [text-shadow:0_2px_4px_rgba(0,0,0,0.8)]"
				>
					<h2 class="text-2xl font-bold mb-2">{{ video.title }}</h2>
					<p class="text-lg opacity-90">{{ video.desc }}</p>
				</div>
			</div>
		</div>

		<!-- 控制按鈕層 -->
		<div class="absolute right-4 bottom-20 flex flex-col gap-5 z-20">
			<!-- <button
				class="kinect-btn w-20 h-20 rounded-full bg-white/20 backdrop-blur-md border-2 border-white text-white flex justify-center items-center transition-all duration-300 hover:bg-white/30"
				@click="changeVideo(-1)"
			>
				▲
			</button>

			<div
				class="text-center text-2xl font-bold text-white [text-shadow:0_0_10px_black]"
			>
				{{ displayIndex }} / {{ rawVideos.length }}
			</div>

			<button
				class="kinect-btn w-20 h-20 rounded-full bg-white/20 backdrop-blur-md border-2 border-white text-white flex justify-center items-center transition-all duration-300 hover:bg-white/30"
				@click="changeVideo(1)"
			>
				▼
			</button> -->

			<button
				class="kinect-interactive kinect-btn mt-10 px-5 py-2.5 bg-red-600/60 text-white no-underline rounded-full text-center border border-red-500 backdrop-blur-sm transition-all hover:bg-red-600/80"
				@click="handleEnded"
			>
				結束測驗
			</button>
		</div>
	</div>
</template>

<script setup>
import { ref, computed, watch, onMounted, onUnmounted, nextTick } from "vue";
import { useRouter } from "vue-router";

// 假設路徑正確

// === 1. 原始資料 ===
const rawVideos = [
	{
		id: 1,
		src: "/videos/short1.mp4",
		title: "寶寶老闆的真心話",
		desc: "街訪路邊的小朋友，沒想到他們的回答竟然充滿了人生哲理？",
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
		desc:
			"穿著復古點點裙的貓咪們再次登場！這次帶來了默契十足的雙人手勢舞，魔性又可愛。",
	},
	{
		id: 8,
		src: "/videos/short8.mp4",
		title: "極致舒壓擠牙膏",
		desc:
			"五顏六色、充滿亮粉的牙膏擠在牙刷上的特寫，絕對是強迫症患者的最愛，視覺上的極致享受。",
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
];

const router = useRouter();

// === 2. 建構無限輪播資料 ===
const extendedVideos = computed(() => {
	const firstClone = { ...rawVideos[0], id: "clone-first", isClone: true };
	const lastClone = {
		...rawVideos[rawVideos.length - 1],
		id: "clone-last",
		isClone: true,
	};
	return [lastClone, ...rawVideos, firstClone];
});

// === 3. 狀態管理 ===
const currentIndex = ref(1);
const videoRefs = ref([]);
const transitionDuration = ref(500);
let isAnimating = false;
let loopResetTimer = null;

// ★ 新增：儲存每部影片的比例狀態 ('portrait' | 'landscape')
const videoOrientations = ref({});

// === ★ 新增：判斷影片方向 ===
const onMetadataLoaded = (event, index) => {
	const { videoWidth, videoHeight } = event.target;
	// 如果 寬 > 高，判定為橫式 (Landscape)
	if (videoWidth > videoHeight) {
		videoOrientations.value[index] = "landscape";
	} else {
		videoOrientations.value[index] = "portrait";
	}
};

// === ★ 新增：根據方向回傳對應 class ===
const getVideoStyle = (index) => {
	const orientation = videoOrientations.value[index];

	if (orientation === "landscape") {
		// 橫式影片：完整顯示 (object-contain)，背景保持黑色
		return "object-contain";
	} else {
		// 直式影片：填滿螢幕 (object-cover)，增加沉浸感
		return "object-cover";
	}
};

// === 4. 核心邏輯 (保持不變) ===
const changeVideo = async (direction) => {
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

// === 5. 播放控制 (保持不變) ===
watch(currentIndex, async (newIdx, oldIdx) => {
	await nextTick();
	if (oldIdx !== undefined && videoRefs.value[oldIdx]) {
		videoRefs.value[oldIdx].pause();
		videoRefs.value[oldIdx].currentTime = 0;
	}
	if (videoRefs.value[newIdx]) {
		try {
			await videoRefs.value[newIdx].play();
		} catch (err) {}
	}
});

const displayIndex = computed(() => {
	const realLength = rawVideos.length;
	if (currentIndex.value === 0) return realLength;
	if (currentIndex.value === extendedVideos.value.length - 1) return 1;
	return currentIndex.value;
});

const handleEnded = async () => {
	// const URL = "http://192.168.0.141:4000/api/print";
	const URL = "http://172.20.10.5:4000/api/print";

	router.push("/end");

	// FIXME:
	// await $fetch(URL, {
	// 	method: "POST",
	// 	body: {
	// 		message: "print request from vue app",
	// 	},
	// });
};

// ★ 新增：處理舉手事件
const handleHandUp = () => {
	changeVideo(1); // 切換到下一部
};

onMounted(() => {
	nextTick(() => {
		if (videoRefs.value[1]) {
			videoRefs.value[1].play().catch(() => {});
		}
	});

	// ★ 新增：監聽來自 KinectCursor 的全域事件
	window.addEventListener("hand-up", handleHandUp);
});

onUnmounted(() => {
	if (loopResetTimer) clearTimeout(loopResetTimer);
	videoRefs.value.forEach((video) => {
		if (video) video.pause();
	});

	// ★ 新增：移除監聽器
	window.removeEventListener("hand-up", handleHandUp);
});
</script>
