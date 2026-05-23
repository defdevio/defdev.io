import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';

export default defineConfig({
  integrations: [
    tailwind({
      // Our global.css already contains the @tailwind directives
      applyBaseStyles: false,
    }),
  ],
});
