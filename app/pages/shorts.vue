<template>
	<div
		class="h-screen bg-black flex relative justify-center items-center overflow-hidden"
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
				class="h-screen relative flex justify-center items-center bg-black"
			>
				<!-- 
					★ 修改重點：
					1. :loop -> Intro 影片不循環，其他影片循環
					2. @ended -> 監聽播放結束，用於 Intro 自動切換
				-->
				<video
					:ref="(el) => (videoRefs[index] = el)"
					class="w-full h-full transition-opacity duration-300"
					:class="getVideoStyle(index)"
					:src="video.src"
					:loop="video.id !== 'intro'"
					playsinline
					@click="changeVideo(1)"
					@loadedmetadata="onMetadataLoaded($event, index)"
					@ended="handleVideoEnded(index)"
				/>

				<!-- 影片資訊 -->
				<div
					class="absolute top-[900px] left-5 text-white z-10 pointer-events-none [text-shadow:0_2px_4px_rgba(0,0,0,0.8)] w-2/3"
				>
					<h2 class="text-2xl font-bold mb-2">{{ video.title }}</h2>
					<p class="text-lg opacity-90">{{ video.desc }}</p>
				</div>
			</div>
		</div>

		<!-- 控制按鈕層 -->
		<div class="absolute right-4 bottom-14 flex flex-col gap-5 z-20">
			<button
				v-show="currentIndex !== 0"
				class="kinect-interactive kinect-btn mt-10 py-2 px-3 bg-orange-600/60 text-white text-xl no-underline rounded-full text-center border border-orange-500 backdrop-blur-sm transition-all hover:bg-orange-600/80"
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

// === 開場影片設定 ===
// 請確認 public/videos/ 下有這個 intro.mp4 檔案
const introVideo = {
	id: "intro",
	src: "/videos/intro.mp4",
};

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
const isIntroPhase = ref(true);
const currentIndex = ref(0);

const videoRefs = ref([]);
const transitionDuration = ref(500);
let isAnimating = false;
let loopResetTimer = null;

// ★ 新增：儲存每部影片的比例狀態 ('portrait' | 'landscape')
const videoOrientations = ref({});

// === 觀看時長與覆蓋率追蹤 ===
const watchStartTime = ref(null);        // 當前影片開始播放的時間戳
const totalWatchSeconds = ref(0);        // 累計觀看秒數
const watchedVideoIds = ref(new Set());  // 已觀看的真實影片 ID（1–17）

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

// === 取得當前索引對應的真實影片 ID ===
const getCurrentRealVideoId = (index) => {
	const video = extendedVideos.value[index];
	if (!video || video.isClone || video.id === "intro") return null;
	return typeof video.id === "number" ? video.id : null;
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

// === 2. 建構無限輪播資料 ===
const extendedVideos = computed(() => {
	const firstClone = { ...rawVideos[0], id: "clone-first", isClone: true };
	const lastClone = {
		...rawVideos[rawVideos.length - 1],
		id: "clone-last",
		isClone: true,
	};

	if (isIntroPhase.value) {
		// ★ 開場模式清單： [Intro, Real1, Real2, ..., CloneFirst]
		return [introVideo, ...rawVideos, firstClone];
	} else {
		// ★ 正常循環模式： [CloneLast, Real1, Real2, ..., CloneFirst]
		return [lastClone, ...rawVideos, firstClone];
	}
});

// === 4. 切換影片邏輯 ===
const changeVideo = async (direction) => {
	if (isAnimating) return;
	isAnimating = true;

	transitionDuration.value = 500;
	currentIndex.value += direction;

	loopResetTimer = setTimeout(() => {
		// ★ 狀態切換邏輯：如果從 Intro (idx 0) 滑到 Real1 (idx 1)
		if (isIntroPhase.value && currentIndex.value === 1) {
			isIntroPhase.value = false;
		}

		handleLoopReset();
		isAnimating = false;
	}, 500);
};

const handleLoopReset = () => {
	const total = extendedVideos.value.length;

	// 處理無限輪播的瞬移
	if (currentIndex.value === total - 1) {
		transitionDuration.value = 0;
		currentIndex.value = 1;
	} else if (currentIndex.value === 0 && !isIntroPhase.value) {
		transitionDuration.value = 0;
		currentIndex.value = total - 2;
	}
};

// === 5. 播放控制 ===
watch(currentIndex, async (newIdx, oldIdx) => {
	// 累積離開影片的觀看時長
	if (watchStartTime.value !== null) {
		totalWatchSeconds.value += (Date.now() - watchStartTime.value) / 1000;
	}
	watchStartTime.value = Date.now();

	// 記錄新影片的唯一 ID（排除 clone 和 intro）
	const newVideoId = getCurrentRealVideoId(newIdx);
	if (newVideoId !== null) {
		watchedVideoIds.value.add(newVideoId);
	}

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

// === ★ 新增：處理 Intro 播放結束 ===
const handleVideoEnded = (index) => {
	// 如果現在是開場階段 (Intro Phase) 且正在播放第一個影片 (Intro)
	if (isIntroPhase.value && index === 0) {
		console.log("Intro 結束，自動切換...");
		changeVideo(1);
	}
};

const displayIndex = computed(() => {
	if (isIntroPhase.value && currentIndex.value === 0) return "-";

	const realLength = rawVideos.length;
	if (currentIndex.value === 0) return realLength;
	if (currentIndex.value === extendedVideos.value.length - 1) return 1;
	return currentIndex.value;
});

// 狀態管理：選擇的動物
const selectedAnimal = useState("selectedAnimal");

const handleEnded = async () => {
	// 結算當前影片的觀看時長
	if (watchStartTime.value !== null) {
		totalWatchSeconds.value += (Date.now() - watchStartTime.value) / 1000;
		watchStartTime.value = null;
	}

	const watchSeconds = Math.round(totalWatchSeconds.value);
	const watchedPercent = Math.round(
		(watchedVideoIds.value.size / rawVideos.length) * 100
	);

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

// ★ 新增：處理舉手事件
const handleHandUp = () => {
	handleEnded()
};

const handleKick = () => {
	if (currentIndex.value !== 0) {
		changeVideo(1);
	}
}

onMounted(() => {
	nextTick(() => {
		// 播放第一個影片 (Intro)
		if (videoRefs.value[0]) {
			videoRefs.value[0].play().catch(() => {});
			watchStartTime.value = Date.now();
		}
	});

	window.addEventListener("hand-up", handleHandUp);
	window.addEventListener("kick", handleKick);
});

onUnmounted(() => {
	if (loopResetTimer) clearTimeout(loopResetTimer);

	videoRefs.value.forEach((video) => {
		if (video) video.pause();
	});

	window.removeEventListener("hand-up", handleHandUp);
	window.removeEventListener("kick", handleKick);
});
</script>
