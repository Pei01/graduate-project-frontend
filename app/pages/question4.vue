<!-- 問題四 -->
<template>
	<div class="flex relative justify-center items-center h-full">
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
						class="kinect-interactive bg-[#E7F3FF] border-4 border-[#167EE7] rounded-full w-full h-20 hover:scale-110 transition-transform duration-300 p-4"
						@click="handleOptionSelect(option)"
					>
						{{ option }}
					</button>
				</div>
			</div>
		</div>
	</div>
</template>

<script setup lang="ts">
import { useRouter } from "vue-router";

const router = useRouter();

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
	console.log("Selected option:", option);

	router.push("/shorts");
};
</script>
