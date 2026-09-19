import {defineConfig} from "vitest/config";

export default defineConfig({
  test: {
    include: [
      "src/security.rules.test.ts",
      "src/**/*.emulator.test.ts",
    ],
    environment: "node",
    fileParallelism: false,
  },
});
