import {defineConfig} from "vitest/config";

export default defineConfig({
  test: {
    include: ["src/**/*.test.ts", "scripts/**/*.test.ts"],
    exclude: ["src/security.rules.test.ts", "src/**/*.emulator.test.ts"],
    environment: "node",
  },
});
