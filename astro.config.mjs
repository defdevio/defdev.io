import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';

const API_GATEWAY_URL = 'https://vh4tf5xws5.execute-api.us-west-2.amazonaws.com/prod';

export default defineConfig({
  site: 'https://www.defdev.io',
  integrations: [
    tailwind({
      // Our global.css already contains the @tailwind directives
      applyBaseStyles: false,
    }),
  ],
  vite: {
    server: {
      proxy: {
        '/api': {
          target: API_GATEWAY_URL,
          changeOrigin: true,
          rewrite: (path) => path.replace(/^\/api/, ''),
        },
      },
    },
  },
});
