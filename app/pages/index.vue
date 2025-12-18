<template>
	<div class="relative inset-0 h-full">
		<img src="~/assets/images/cover.png" class="h-full" />

		<div
			class="button-bounce flex justify-center items-center top-[66%] left-[28%] absolute group rotate-4 z-10"
		>
			<button
				class="kinect-interactive flex justify-center items-center group bg-[#186DC4] w-60 h-20 rounded-full outline-black outline-4 z-20"
				@click="handleStateChange"
			>
				<img src="~/assets/images/start.png" class="-rotate-4" />
			</button>

			<!-- <img
				src="~/assets/images/button_hover.png"
				class="absolute max-w-none group-hover:opacity-100 opacity-0"
			/> -->
		</div>
	</div>
</template>

<script setup lang="ts">
import { useRouter } from "vue-router";

const router = useRouter();

const handleStateChange = () => {
	router.push("/question1");
};
</script>
