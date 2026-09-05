import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';
import mermaid from 'astro-mermaid';

const API_GATEWAY_URL = 'https://vh4tf5xws5.execute-api.us-west-2.amazonaws.com/prod';

export default defineConfig({
  site: 'https://www.defdev.io',
  integrations: [
    mermaid({
      theme: 'base',
      autoTheme: false,
      enableLog: false,
      mermaidConfig: {
        themeVariables: {
          background: 'transparent',
          primaryColor: '#27272a',
          primaryTextColor: '#f4f4f5',
          primaryBorderColor: '#a78bfa',
          lineColor: '#a78bfa',
          secondaryColor: '#18181b',
          tertiaryColor: '#3f3f46',
          edgeLabelBackground: '#18181b',
          fontFamily: 'Inter, sans-serif',
        },
      },
    }),
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
