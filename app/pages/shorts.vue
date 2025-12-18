<template>
  <div class="h-full bg-black flex relative justify-center items-center overflow-hidden">
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
          :ref="(el) => (videoRefs[index] = el)"
          class="w-full h-full object-cover"
          :src="video.src"
          loop
          playsinline
          @click="changeVideo(1)"
        ></video>

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
    <div class="absolute right-5 top-1/2 -translate-y-1/2 flex flex-col gap-5 z-20">
      
      <button
        class="kinect-btn w-20 h-20 rounded-full bg-white/20 backdrop-blur-md border-2 border-white text-white flex justify-center items-center transition-all duration-300 hover:bg-white/30"
        @click="changeVideo(-1)"
      >
        ▲
      </button>

      <div class="text-center text-2xl font-bold text-white [text-shadow:0_0_10px_black]">
        {{ displayIndex }} / {{ rawVideos.length }}
      </div>

      <button
        class="kinect-btn w-20 h-20 rounded-full bg-white/20 backdrop-blur-md border-2 border-white text-white flex justify-center items-center transition-all duration-300 hover:bg-white/30"
        @click="changeVideo(1)"
      >
        ▼
      </button>

      <!-- 退出按鈕：使用 router.push 是正確的，不要用 <a> 標籤 -->
      <!-- <a> 標籤會導致整頁刷新，Kinect Socket 會斷線 -->
      <button
        class="kinect-btn mt-10 px-5 py-2.5 bg-red-600/60 text-white no-underline rounded-full text-center border border-red-500 backdrop-blur-sm transition-all hover:bg-red-600/80"
        @click="handleEnded"
      >
        退出
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted, onUnmounted, nextTick } from "vue";
import { useRouter } from "vue-router";

import short1 from "~/assets/videos/short1.mp4";
import short2 from "~/assets/videos/short2.mp4";
import short3 from "~/assets/videos/short3.mp4";


// 暫時使用範例影片連結以確保可運行，你可以換回你的 import
const rawVideos = [
  {
    id: 1,
    src: short1,
    title: "大白兔的故事",
    desc: "這是一部經典的開源動畫電影。",
  },
  {
    id: 2,
    src: short2,
    title: "大象之夢",
    desc: "3D 動畫短片，展示了超現實的機械世界。",
  },
  {
    id: 3,
    src: short3,
    title: "火焰特效",
    desc: "展示高畫質的火焰粒子效果。",
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
let loopResetTimer = null; // 儲存計時器 ID 以便清除

// === 4. 核心邏輯 ===
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

// === 5. 播放控制 ===
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

const handleEnded = () => {
  // 使用 router.push 是正確的
  router.push("/end"); // 注意：你的檔案叫 result.vue，所以路徑要是 /result
};

onMounted(() => {
  nextTick(() => {
    if (videoRefs.value[1]) {
      videoRefs.value[1].play().catch(() => {});
    }
  });
});

// ★ 新增：組件卸載時的清理工作
onUnmounted(() => {
  // 1. 清除計時器
  if (loopResetTimer) clearTimeout(loopResetTimer);
  
  // 2. 暫停所有影片 (避免轉場時還有聲音)
  videoRefs.value.forEach(video => {
    if (video) video.pause();
  });
});
</script>