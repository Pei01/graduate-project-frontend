<template>
	<div
		class="crt-overlay relative h-screen w-full overflow-hidden flex flex-col"
		style="background-color: #0d0221;"
	>
		<!-- Floating star pixels -->
		<div class="absolute inset-0 pointer-events-none z-0">
			<div
				v-for="i in 6"
				:key="i"
				class="absolute w-1 h-1 rounded-full"
				:style="{
					background: '#ffd700',
					animation: 'pixel-float 4s linear infinite',
					left: `${[10, 28, 45, 62, 78, 92][i - 1]}%`,
					top: `${[72, 85, 65, 88, 78, 70][i - 1]}%`,
					animationDelay: `${(i - 1) * 0.6}s`,
					animationDuration: `${3.5 + (i % 3) * 0.8}s`,
				}"
			/>
		</div>

		<!-- TOP HUD BAR -->
		<div
			class="relative z-10 flex items-center justify-between px-4 py-2"
			style="font-family: 'Press Start 2P', monospace; font-size: 8px; color: #ffd700; border-bottom: 1px solid #ff0066; box-shadow: 0 2px 8px #ff006680;"
		>
			<span>遊戲說明</span>
			<span class="neon-text-gold">{{ step }} / 2</span>
			<span style="color: #ffffff40; font-size: 7px;"></span>
		</div>

		<!-- MAIN CONTENT -->
		<div class="relative z-10 flex flex-col items-center justify-center flex-1 px-6 gap-5">

			<!-- Step indicator dots -->
			<div class="flex gap-3">
				<div
					v-for="s in 2"
					:key="s"
					class="rounded-full transition-all duration-500"
					:style="{
						width: s === step ? '20px' : '8px',
						height: '8px',
						background: s === step ? (step === 1 ? '#00ffff' : '#ffd700') : (s < step ? '#ffffff40' : '#ffffff15'),
						boxShadow: s === step ? `0 0 8px ${step === 1 ? '#00ffff' : '#ffd700'}` : 'none',
					}"
				/>
			</div>

			<!-- Step content with transition -->
			<Transition name="tutorial-step" mode="out-in">

				<!-- Step 1: KICK -->
				<div v-if="step === 1" key="kick" class="flex flex-col items-center gap-4 text-center">
					<p
						class="neon-text-pink"
						style="font-family: 'Press Start 2P', monospace; font-size: 13px; letter-spacing: 6px;"
					>
						動作 01
					</p>

					<!-- Kick animation SVG -->
					<svg width="120" height="160" viewBox="0 0 80 110" fill="none" xmlns="http://www.w3.org/2000/svg">
						<!-- Head -->
						<circle cx="40" cy="12" r="9" stroke="#00ffff" stroke-width="2.5" />
						<!-- Body -->
						<line x1="40" y1="21" x2="40" y2="64" stroke="#00ffff" stroke-width="2.5" />
						<!-- Left arm (静止) -->
						<line x1="40" y1="36" x2="16" y2="50" stroke="#00ffff" stroke-width="2.5" />
						<!-- Right arm (静止) -->
						<line x1="40" y1="36" x2="64" y2="50" stroke="#00ffff" stroke-width="2.5" />
						<!-- Left leg (standing) -->
						<line x1="40" y1="64" x2="24" y2="96" stroke="#00ffff" stroke-width="2.5" />
						<!-- Right leg (kicking - animated) -->
						<line
							class="gesture-leg-kick"
							x1="40" y1="64" x2="68" y2="80"
							stroke="#ff0066" stroke-width="3"
							style="transform-origin: 40px 64px;"
						/>
						<!-- Kick direction arrow -->
						<text x="65" y="68" fill="#ff0066" font-size="14" font-weight="bold" style="animation: blink 0.8s step-end infinite;">↑</text>
					</svg>

					<div class="flex flex-col items-center gap-2">
						<p
							class="neon-text-cyan"
							style="font-family: 'Press Start 2P', monospace; font-size: 22px; letter-spacing: 4px;"
						>
							踢腳
						</p>
						<p style="font-family: 'VT323', monospace; font-size: 30px; color: #ffffffcc; letter-spacing: 4px;">
							下一支影片
						</p>
					</div>
				</div>

				<!-- Step 2: RAISE HANDS -->
				<div v-else-if="step === 2" key="raise" class="flex flex-col items-center gap-4 text-center">
					<p
						class="neon-text-gold"
						style="font-family: 'Press Start 2P', monospace; font-size: 13px; letter-spacing: 6px;"
					>
						動作 02
					</p>

					<!-- Raise hands animation SVG -->
					<svg width="120" height="160" viewBox="0 0 80 110" fill="none" xmlns="http://www.w3.org/2000/svg">
						<!-- Head -->
						<circle cx="40" cy="12" r="9" stroke="#ffd700" stroke-width="2.5" />
						<!-- Body -->
						<line x1="40" y1="21" x2="40" y2="64" stroke="#ffd700" stroke-width="2.5" />
						<!-- Left arm raised (animated) -->
						<line
							class="gesture-arm-left"
							x1="40" y1="36" x2="8" y2="28"
							stroke="#ff0066" stroke-width="3"
							style="transform-origin: 40px 36px;"
						/>
						<!-- Right arm raised (animated) -->
						<line
							class="gesture-arm-right"
							x1="40" y1="36" x2="72" y2="28"
							stroke="#ff0066" stroke-width="3"
							style="transform-origin: 40px 36px;"
						/>
						<!-- Left leg -->
						<line x1="40" y1="64" x2="24" y2="96" stroke="#ffd700" stroke-width="2.5" />
						<!-- Right leg -->
						<line x1="40" y1="64" x2="56" y2="96" stroke="#ffd700" stroke-width="2.5" />
						<!-- Up arrows above hands -->
						<text x="2" y="22" fill="#ff0066" font-size="10" style="animation: blink 0.8s step-end infinite;">↑</text>
						<text x="68" y="22" fill="#ff0066" font-size="10" style="animation: blink 0.8s step-end infinite;">↑</text>
					</svg>

					<div class="flex flex-col items-center gap-2">
						<p
							class="neon-text-gold"
							style="font-family: 'Press Start 2P', monospace; font-size: 22px; letter-spacing: 4px;"
						>
							雙手舉起
						</p>
						<p style="font-family: 'VT323', monospace; font-size: 30px; color: #ffffffcc; letter-spacing: 4px;">
							結束遊戲
						</p>
					</div>
				</div>

			</Transition>

			<!-- Progress bar + countdown -->
			<div class="flex flex-col items-center gap-1" style="width: 260px;">
				<div
					class="w-full rounded-full overflow-hidden"
					style="height: 3px; background: rgba(255,255,255,0.1);"
				>
					<div
						class="h-full rounded-full"
						:style="{
							width: `${progress}%`,
							background: step === 1 ? '#00ffff' : '#ffd700',
							boxShadow: step === 1 ? '0 0 6px #00ffff' : '0 0 6px #ffd700',
							transition: 'width 0.1s linear',
						}"
					/>
				</div>
				<p
					style="font-family: 'VT323', monospace; font-size: 18px; color: #ffffff30; letter-spacing: 5px;"
				>
					{{ step < 2 ? `${countdown} 秒後繼續` : `${countdown} 秒後開始` }}
				</p>
			</div>

		</div>

		<!-- BOTTOM HUD -->
		<div
			class="relative z-10 flex items-center justify-center py-2"
			style="background: rgba(13,2,33,0.85); border-top: 1px solid rgba(0,255,255,0.15);"
		>
			<p style="font-family: 'VT323', monospace; font-size: 18px; color: #ffffff35; letter-spacing: 5px;">
				▶ 自動播放中，請觀看動作示範
			</p>
		</div>
	</div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from "vue";
import { useRouter } from "vue-router";

const router = useRouter();

const STEP_DURATION = 4500; // ms per step
const TICK = 100;

const step = ref(1);
const progress = ref(0);
let timer = null;

const countdown = computed(() =>
	Math.max(1, Math.ceil(((100 - progress.value) / 100) * STEP_DURATION / 1000))
);

const goToShorts = () => {
	if (timer) clearInterval(timer);
	router.push("/shorts");
};

const advance = () => {
	if (step.value < 2) {
		if (timer) clearInterval(timer);
		step.value++;
		progress.value = 0;
		startTimer();
	} else {
		goToShorts();
	}
};

const startTimer = () => {
	if (timer) clearInterval(timer);
	const increment = (TICK / STEP_DURATION) * 100;
	timer = setInterval(() => {
		progress.value = Math.min(100, progress.value + increment);
		if (progress.value >= 100) {
			clearInterval(timer);
			timer = null;
			advance();
		}
	}, TICK);
};

onMounted(() => {
	startTimer();
});

onUnmounted(() => {
	if (timer) clearInterval(timer);
});
</script>

<style scoped>
.tutorial-step-enter-active,
.tutorial-step-leave-active {
	transition: all 0.35s ease;
}
.tutorial-step-enter-from {
	opacity: 0;
	transform: translateX(24px);
}
.tutorial-step-leave-to {
	opacity: 0;
	transform: translateX(-24px);
}

/* 調弱霓虹文字效果 */
:deep(.neon-text-cyan) {
	text-shadow: 0 0 4px #00ffff60, 0 0 8px #00ffff30;
}
:deep(.neon-text-pink) {
	text-shadow: 0 0 4px #ff006660, 0 0 8px #ff006630;
}
:deep(.neon-text-gold) {
	text-shadow: 0 0 4px #ffd70060, 0 0 8px #ffd70030;
}
</style>
