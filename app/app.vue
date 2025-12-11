<template>
	<div
		class="flex items-center justify-center relative overflow-hidden h-screen w-full"
	>
		<!-- FIXME: Kinect Cursor -->
		<div
			id="kinect-cursor"
			:style="cursorStyle"
			class="fixed top-0 left-[525px] z-50 w-8 h-8 rounded-full pointer-events-none transition-all ease-linear shadow-lg bg-red-600"
		/>

		<!-- FIXME: 測試用按鈕，之後刪除 -->
		<button
			class="absolute top-4 left-4 z-50 p-2 bg-black rounded-full"
			@click="next"
		>
			<p class="text-white">影片上滑</p>
		</button>

		<!-- 封面 -->
		<div v-if="isCover" class="relative inset-0 h-full">
			<img src="~/assets/images/cover.png" class="h-full" />

			<div
				class="button-bounce flex justify-center items-center top-[66%] left-[28%] absolute group rotate-4 z-10"
			>
				<button
					class="flex justify-center items-center group bg-[#186DC4] w-44 h-12 rounded-full outline-black outline-4 z-20"
					@click="handleStateChange"
				>
					<img src="~/assets/images/start.png" class="-rotate-4" />
				</button>

				<img
					src="~/assets/images/button_hover.png"
					class="absolute max-w-none group-hover:opacity-100 opacity-0"
				/>
			</div>
		</div>

		<!-- 問題頁面 -->
		<div v-if="isQuestion" class="relative inset-0 h-full">
			<!-- 問題首頁 -->
			<div class="absolute top-0 fade-out h-full">
				<img src="~/assets/images/bg_cover.png" class="h-full" />

				<div class="absolute top-0 size-full">
					<img
						src="~/assets/images/bubble1.png"
						class="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 rotate-fade-in origin-bottom-left max-w-none"
					/>

					<img
						src="~/assets/images/bubble2.png"
						class="absolute right-0 bottom-16 rotate-fade-in origin-bottom-right opacity-0 [--deg:-90deg] [animation-delay:0.5s]! max-w-none"
					/>
				</div>
			</div>

			<!-- 問題一 -->
			<div
				class="h-full transition-all ease-in-out duration-300"
				:class="questionState === QuestionState.Q1 ? 'opacity-100' : 'opacity-0'"
			>
				<img src="~/assets/images/bg.png" class="h-full" />

				<div class="opacity-0 fade-in">
					<img
						src="~/assets/images/title.png"
						class="absolute top-0 max-w-none -translate-x-1/2 left-1/2"
					/>

					<div class="absolute bottom-24 px-4 grid grid-cols-2 gap-4 w-full">
						<img
							v-for="(animal, index) in animals"
							:key="index"
							class="kinect-interactive w-full cursor-pointer group group-[.is-hovered]:scale-110 hover:scale-110 transition-transform duration-300"
							:src="animal.src"
							@click="handleAnimalSelect(animal.value)"
						/>
					</div>
				</div>
			</div>

			<!-- 問題二 -->
			<div
				class="absolute top-0 h-full transition-all ease-in-out duration-300"
				:class="
					questionState === QuestionState.Q2
						? 'opacity-100'
						: 'opacity-0 pointer-events-none'
				"
			>
				<img src="~/assets/images/bg/2.png" class="h-full" />

				<div
					class="absolute top-0 size-full flex flex-col items-center justify-center gap-10"
				>
					<div
						class="flex flex-col justify-center items-center font-bold text-black text-4xl gap-2"
					>
						<h1 class="">以下哪種情境</h1>
						<h1 class="">最讓您感到壓力？</h1>
					</div>

					<div class="flex flex-col items-center justify-center w-80 gap-4">
						<div v-for="option in questionOptions.Q2" :key="option" class="w-full">
							<button
								class="bg-[#E6FFE9] border-4 border-[#29983C] rounded-full w-full h-20 hover:scale-110 transition-transform duration-300 p-4"
								@click="handleOptionSelect(option)"
							>
								{{ option }}
							</button>
						</div>
					</div>
				</div>
			</div>

			<!-- 問題三 -->
			<div
				class="absolute top-0 h-full transition-all ease-in-out duration-300"
				:class="
					questionState === QuestionState.Q3
						? 'opacity-100'
						: 'opacity-0 pointer-events-none'
				"
			>
				<img src="~/assets/images/bg/3.png" class="h-full" />

				<div
					class="absolute top-0 size-full flex flex-col items-center justify-center gap-10"
				>
					<div
						class="flex flex-col justify-center items-center font-bold text-black text-4xl gap-2"
					>
						<h1 class="">遇到中肯的批評</h1>
						<h1 class="">您的第一反應是？</h1>
					</div>

					<div class="flex flex-col items-center justify-center w-80 gap-4">
						<div v-for="option in questionOptions.Q3" :key="option" class="w-full">
							<button
								class="bg-[#FFFBF4] border-4 border-[#FFAD08] rounded-full w-full h-20 hover:scale-110 transition-transform duration-300 p-4"
								@click="handleOptionSelect(option)"
							>
								{{ option }}
							</button>
						</div>
					</div>
				</div>
			</div>

			<!-- 問題四 -->
			<div
				class="absolute top-0 h-full transition-all ease-in-out duration-300"
				:class="
					questionState === QuestionState.Q4
						? 'opacity-100'
						: 'opacity-0 pointer-events-none'
				"
			>
				<img src="~/assets/images/bg/4.png" class="h-full" />

				<div
					class="absolute top-0 size-full flex flex-col items-center justify-center gap-10"
				>
					<div
						class="flex flex-col justify-center items-center font-bold text-black text-4xl gap-2"
					>
						<h1 class="">您在什麼時候</h1>
						<h1 class="">可以不看手機？</h1>
					</div>

					<div class="flex flex-col items-center justify-center w-80 gap-4">
						<div v-for="option in questionOptions.Q4" :key="option" class="w-full">
							<button
								class="bg-[#E7F3FF] border-4 border-[#167EE7] rounded-full w-full h-20 hover:scale-110 transition-transform duration-300 p-4"
								@click="handleOptionSelect(option)"
							>
								{{ option }}
							</button>
						</div>
					</div>
				</div>
			</div>

			<!-- animation -->
			<div
				class="absolute top-0 h-full"
				:class="
					questionState === QuestionState.transition
						? 'slide-up'
						: 'opacity-0 pointer-events-none'
				"
			>
				<img src="~/assets/images/bg/5.png" class="h-full" />

				<div v-for="(value, index) in animationParams" :key="index">
					<img
						src="~/assets/images/arrow_up.png"
						class="float-up absolute"
						:style="`left: ${value.left}; animation-delay: ${value.delay};`"
					/>
				</div>
			</div>
		</div>

		<!-- 影片容器 -->
		<div v-if="isVideo" class="absolute w-xl h-screen">
			<!-- <h1 class="relative top-6 left-6 text-white font-extrabold text-4xl">
				Focus
			</h1> -->

			<div class="absolute right-6 bottom-20">
				<div class="relative flex items-center justify-center" @click="toggleHeart">
					<img :src="icon" class="absolute size-10" />
					<div class="size-16 bg-white opacity-20 rounded-full" />
				</div>
			</div>
		</div>

		<div
			v-for="(item, index) in items"
			:key="index"
			class="absolute inset-0 flex items-center justify-center overflow-hidden text-white text-4xl font-bold transition-all duration-1500 ease-in-out"
			:class="isVideo ? 'opacity-100' : 'opacity-0 translate-y-full'"
			:style="{
				transform: `translateY(${(index - currentIndex) * 100}%)`,
			}"
		>
			<video
				ref="shortRef"
				:src="item.src"
				class="w-xl"
				:autoplay="currentIndex === index"
				loop
			/>
		</div>
	</div>
</template>

<script lang="ts" setup>
import { onMounted, onUnmounted, ref } from "vue";
import { io } from "socket.io-client";

import animal1 from "~/assets/images/animals/option1.png";
import animal2 from "~/assets/images/animals/option2.png";
import animal3 from "~/assets/images/animals/option3.png";
import animal4 from "~/assets/images/animals/option4.png";
import animal5 from "~/assets/images/animals/option5.png";
import animal6 from "~/assets/images/animals/option6.png";

import short1 from "~/assets/videos/short1.mp4";
import short2 from "~/assets/videos/short2.mp4";
import short3 from "~/assets/videos/short3.mp4";
import short4 from "~/assets/videos/short4.mp4";
import short5 from "~/assets/videos/short5.mp4";
import short6 from "~/assets/videos/short6.mp4";
import short7 from "~/assets/videos/short7.mp4";
import short8 from "~/assets/videos/short8.mp4";
import short9 from "~/assets/videos/short9.mp4";
import short10 from "~/assets/videos/short10.mp4";
import short11 from "~/assets/videos/short11.mp4";
import short12 from "~/assets/videos/short12.mp4";

import heart from "~/assets/images/heart.svg";
import clicked_heart from "~/assets/images/clicked_heart.svg";

let socket = null;

onMounted(() => {
	console.log("Mounting component and connecting to server...");
	socket = io("http://172.20.10.4:5000");
	console.log(socket);

	socket.on("connect", () => {
		console.log("Connected to server");
	});

	socket.on("hand_event", () => {
		console.log("Received hand_event");
		next();
	});

	socket.on("cursor_move", (data) => {
		cursorX.value = data.x;
		cursorY.value = data.y;

		
		const element = document.elementFromPoint(525 + cursorX.value, cursorY.value);
		handleHoverVisuals(element);
	});

	socket.on("mouse_click", () => {
		console.log("Received mouse_click event");

		// FIXME:
		const element = document.elementFromPoint(525 + cursorX.value, cursorY.value);
		if (element instanceof HTMLElement) {
			element.click();
		}
	});
});

const animals = [
	{ src: animal1, value: "cat" },
	{ src: animal2, value: "dog" },
	{ src: animal3, value: "lion" },
	{ src: animal4, value: "owl" },
	{ src: animal5, value: "penguin" },
	{ src: animal6, value: "whale" },
];

const selectedAnimal = ref("");
const handleAnimalSelect = (animal: string) => {
	selectedAnimal.value = animal;
	questionState.value++;
};

const items = [
	{ label: "影片 1", src: short1 },
	{ label: "影片 2", src: short2 },
	{ label: "影片 3", src: short3 },
	{ label: "影片 4", src: short4 },
	{ label: "影片 5", src: short5 },
	{ label: "影片 6", src: short6 },
	{ label: "影片 7", src: short7 },
	{ label: "影片 8", src: short8 },
	{ label: "影片 9", src: short9 },
	{ label: "影片 10", src: short10 },
	{ label: "影片 11", src: short11 },
	{ label: "影片 12", src: short12 },
];

const currentIndex = ref(0);

const enum State {
	COVER,
	QUESTION,
	VIDEO,
	END,
}

const isCover = computed(() => state.value === State.COVER);
const isQuestion = computed(() => state.value === State.QUESTION);
const isVideo = computed(() => state.value === State.VIDEO);
const isEnd = computed(() => state.value === State.END);

const state = ref(State.COVER);

const enum QuestionState {
	Q1,
	Q2,
	Q3,
	Q4,
	transition,
}

const animationParams = [
	{ left: "5%", delay: "0s" },
	{ left: "25%", delay: "1.2s" },
	{ left: "45%", delay: "0.8s" },
	{ left: "45%", delay: "3.2s" },
	{ left: "65%", delay: "2s" },
	{ left: "80%", delay: "1.5s" },
];

const questionState = ref(QuestionState.Q1);

const selectedOptions = ref<string[]>([]);

const questionOptions = {
	Q1: ["cat", "dog", "lion", "owl", "penguin", "whale"],
	Q2: ["決定午餐要吃什麼", "跟店員多要一份餐具", "拒絕朋友不想去的聚會"],
	Q3: [
		"雖受傷但認同，急著想知道如何改進！",
		"表面點頭道謝，心裡覺得對方根本不懂⋯⋯⋯",
		"堅信自己最棒，無視批評並吃甜點犒賞自己",
	],
	Q4: ["吃飯的時候", "看電影的時候", "讀書的時候"],
};

const handleOptionSelect = (option: string) => {
	selectedOptions.value.push(option);
	questionState.value++;
};

const handleStateChange = () => {
	state.value++;
};

watch(
	() => questionState.value,
	(newVal) => {
		if (newVal === QuestionState.transition) {
			setTimeout(() => {
				handleStateChange();
			}, 4800); // 4.8秒後切換到影片狀態
		}
	}
);

const shortRef = ref<HTMLVideoElement[]>([]);

const next = () => {
	currentIndex.value++;
	currentIndex.value = currentIndex.value % items.length;
	console.log("Current Index:", currentIndex.value);

	if (icon.value === clicked_heart) {
		toggleHeart();
	}

	if (shortRef.value) {
		const videoEl = shortRef.value[currentIndex.value];
		const prevVideoEl =
			shortRef.value[(currentIndex.value - 1 + items.length) % items.length];

		if (videoEl) {
			videoEl.currentTime = 0;
			videoEl.play();
		}

		if (prevVideoEl) {
			prevVideoEl.pause();
		}
	}
};

const icon = ref(heart);
const toggleHeart = () => {
	if (icon.value === heart) {
		icon.value = clicked_heart;
	} else {
		icon.value = heart;
	}
};

const cursorX = ref(0);
const cursorY = ref(0);

const cursorStyle = computed(() => ({
	// 圓點是 w-8 h-8 (32px)，因此需要向左上平移 16px 進行居中
	transform: `translate(${cursorX.value - 16}px, ${cursorY.value - 16}px)`,
}));

let lastHoveredEl: Element | null = null;

const handleHoverVisuals = (elementUnderCursor: Element | null) => {
  if (!elementUnderCursor) {
    if (lastHoveredEl) {
      lastHoveredEl.classList.remove('is-hovered'); // 移除狀態
      lastHoveredEl = null;
    }
    return;
  }

  const target = elementUnderCursor.closest('.kinect-interactive');

  if (lastHoveredEl !== target) {
    if (lastHoveredEl) {
      lastHoveredEl.classList.remove('is-hovered');
    }

    if (target) {
      target.classList.add('is-hovered'); // 加上通用狀態 class
    }

    lastHoveredEl = target;
  }
};

onUnmounted(() => {
	if (socket) {
		socket.disconnect();
	}
});
</script>
