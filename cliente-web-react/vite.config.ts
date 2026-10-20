import { configDefaults, defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react";

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173
  },
  test: {
    environment: "jsdom",
    exclude: [...configDefaults.exclude, "e2e/**"], // las E2E las corre Playwright (npm run e2e)
    setupFiles: ["./src/setupTests.ts"],
    restoreMocks: true,
    unstubGlobals: true
  }
});
