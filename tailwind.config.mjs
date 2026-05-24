/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{astro,html,js,jsx,md,mdx,ts,tsx}'],
  darkMode: 'class',
  theme: {
    extend: {
      screens: {
        // Height-based breakpoint — targets short/landscape viewports (≤700px tall)
        short: { raw: '(max-height: 700px)' },
      },
      colors: {
        purple: {
          700: '#6f42c1',
          800: '#5a389a',
          900: '#4a2d7e',
        },
      },
      fontFamily: {
        sans: [
          'Inter',
          'system-ui',
          '-apple-system',
          'BlinkMacSystemFont',
          '"Segoe UI"',
          'sans-serif',
        ],
        mono: ['"JetBrains Mono"', '"Fira Code"', 'monospace'],
      },
    },
  },
  plugins: [],
};
