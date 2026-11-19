import { createRequire } from "node:module";
import path from "node:path";
import { fileURLToPath } from "node:url";

const require = createRequire(import.meta.url);
const esbuild = require("esbuild");

const demoDir = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

await esbuild.build({
  entryPoints: [path.join(demoDir, "scripts/sdk-bundle-entry.ts")],
  outfile: path.join(demoDir, "libs/bcl-ring-sdk.js"),
  bundle: true,
  format: "esm",
  platform: "browser",
  target: "es2018",
});
