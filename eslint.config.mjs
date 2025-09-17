import js from "@eslint/js";
import tseslintPlugin from "@typescript-eslint/eslint-plugin";
import tsParser from "@typescript-eslint/parser";
import vuePlugin from "eslint-plugin-vue";
import globals from "globals";

const ignores = [
  "node_modules/**",
  "vendor/**",
  "storage/**",
  "public/**",
  "bootstrap/cache/**",
];

export default [
  {
    ignores,
  },
  {
    languageOptions: {
      ecmaVersion: "latest",
      sourceType: "module",
      globals: {
        ...globals.browser,
      },
    },
  },
  js.configs.recommended,
  ...vuePlugin.configs["flat/recommended"],
  {
    files: ["**/*.ts", "**/*.tsx"],
    languageOptions: {
      parser: tsParser,
      parserOptions: {
        ecmaVersion: "latest",
        sourceType: "module",
      },
    },
    plugins: {
      "@typescript-eslint": tseslintPlugin,
    },
    rules: {
      ...tseslintPlugin.configs.recommended.rules,
    },
  },
];
