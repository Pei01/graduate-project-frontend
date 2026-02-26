<template>
	<div class="relative inset-0 h-full w-[547.25px]">
		<img src="~/assets/images/cover.png" class="h-full w-full" />

		<div
			class="justify-center items-center top-[66%] left-[28%] absolute group rotate-4 z-10"
		>
		 	<div class="absolute text-bold text-xl -top-[62px] -left-8 -rotate-1">
				*動動你的右手*
			</div>

			<button
				class="button-bounce kinect-interactive flex justify-center items-center group bg-[#186DC4] w-60 h-20 rounded-full outline-black outline-4 z-20"
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
	router.push("/shorts");
};

onMounted(() => {
	window.addEventListener("hand-up", handleStateChange);
});
</script>
