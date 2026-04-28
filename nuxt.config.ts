// https://nuxt.com/docs/api/configuration/nuxt-config
import tailwindcss from "@tailwindcss/vite";

export default defineNuxtConfig({
	app: {
		pageTransition: { name: "page", mode: "out-in" },
		head: {
			link: [
				{ rel: "preconnect", href: "https://fonts.googleapis.com" },
				{ rel: "preconnect", href: "https://fonts.gstatic.com", crossorigin: "" },
				{
					rel: "stylesheet",
					href: "https://fonts.googleapis.com/css2?family=Press+Start+2P&family=VT323:wght@400&display=swap",
				},
			],
		},
	},
	compatibilityDate: "2025-07-15",
	devtools: { enabled: false },

	css: ["~/assets/css/main.css"],

	vite: {
		plugins: [tailwindcss()],
	},

	modules: [
		"@nuxt/image",
		"@nuxt/eslint",
		"@nuxt/content",
		"@nuxt/scripts",
		"@nuxt/icon",
	],
});
