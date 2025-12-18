<!-- 問題一 -->
<template>
	<div class="flex relative justify-center items-center h-full">
		<img src="~/assets/images/bg.png" class="absolute h-full" />

		<div class="flex flex-col justify-center items-center z-10">
			<img src="~/assets/images/title.png" class="-mb-20" />

			<div class="px-4 grid grid-cols-2 gap-4">
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
</template>

<script setup lang="ts">
import { useRouter } from "vue-router";
import animal1 from "~/assets/images/animals/option1.png";
import animal2 from "~/assets/images/animals/option2.png";
import animal3 from "~/assets/images/animals/option3.png";
import animal4 from "~/assets/images/animals/option4.png";
import animal5 from "~/assets/images/animals/option5.png";
import animal6 from "~/assets/images/animals/option6.png";

const router = useRouter();

const animals = [
	{ src: animal1, value: "cat" },
	{ src: animal2, value: "dog" },
	{ src: animal3, value: "lion" },
	{ src: animal4, value: "owl" },
	{ src: animal5, value: "penguin" },
	{ src: animal6, value: "whale" },
];

const handleAnimalSelect = (animal: string) => {
	console.log("Selected animal:", animal);
	// 在這裡處理動物選擇的邏輯，例如導航到遊戲頁面並傳遞所選動物

	router.push("/question2")
};
</script>
