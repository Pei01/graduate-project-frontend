<!-- 問題一 -->
<template>
	<div class="flex relative justify-center items-center h-full w-[547.25px]">
		<img src="~/assets/images/bg.png" class="absolute h-full w-full" />

		<div class="flex flex-col justify-center items-center z-10">
			<img src="~/assets/images/title.png" class="max-w-none w-[130%] -mb-30" />

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
	{ src: animal1, value: "喵咪" },
	{ src: animal2, value: "狗勾" },
	{ src: animal3, value: "辛巴寶寶" },
	{ src: animal4, value: "喵頭鷹" },
	{ src: animal5, value: "企鵝寶寶" },
	{ src: animal6, value: "小鯨魚" },
];

const selectedAnimal = useState("selectedAnimal");

const handleAnimalSelect = (animal: string) => {
	selectedAnimal.value = animal; 

	router.push("/question2");
};
</script>
