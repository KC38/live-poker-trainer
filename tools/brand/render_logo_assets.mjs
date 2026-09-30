#!/usr/bin/env node
/**
 * Rasterize assets/brand/logo_mark.svg into UI, launcher, and notification PNGs.
 *
 * Usage (from repo root, with @resvg/resvg-js available):
 *   node tools/brand/render_logo_assets.mjs
 *
 * Optional: RESVG_MODULE=/path/to/@resvg/resvg-js
 */
import fs from 'node:fs';
import path from 'node:path';
import {createRequire} from 'node:module';
import {fileURLToPath} from 'node:url';

const require = createRequire(import.meta.url);
const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '../..');
const SVG_PATH = path.join(ROOT, 'assets/brand/logo_mark.svg');
const GOLD = '#D4A84B';
const BG_DARK = '#0A0E16';

function loadResvg() {
  const candidates = [
    process.env.RESVG_MODULE,
    path.join(ROOT, '.cursor/tmp/resvg-install/node_modules/@resvg/resvg-js'),
    '@resvg/resvg-js',
  ].filter(Boolean);
  for (const candidate of candidates) {
    try {
      return require(candidate);
    } catch {
      // try next
    }
  }
  throw new Error(
    'Install @resvg/resvg-js (npm i @resvg/resvg-js) or set RESVG_MODULE',
  );
}

function ensureDir(dir) {
  fs.mkdirSync(dir, {recursive: true});
}

function writePng(filePath, bytes) {
  ensureDir(path.dirname(filePath));
  fs.writeFileSync(filePath, bytes);
}

function render(Resvg, svg, {size, background}) {
  const resvg = new Resvg(svg, {
    fitTo: {mode: 'width', value: size},
    background,
  });
  return resvg.render().asPng();
}

function monoSvg(svg, color) {
  return svg.replaceAll('#D4A84B', color).replaceAll('#d4a84b', color);
}

function main() {
  const {Resvg} = loadResvg();
  const svg = fs.readFileSync(SVG_PATH, 'utf8');
  if (!svg.includes(GOLD)) {
    throw new Error(`Expected brand gold ${GOLD} in ${SVG_PATH}`);
  }

  writePng(
    path.join(ROOT, 'assets/brand/logo_mark.png'),
    render(Resvg, svg, {size: 1024, background: 'rgba(0,0,0,0)'}),
  );

  writePng(
    path.join(ROOT, 'assets/brand/app_icon.png'),
    render(Resvg, svg, {size: 1024, background: BG_DARK}),
  );

  const iosDir = path.join(
    ROOT,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset',
  );
  const iosSizes = [
    ['Icon-App-20x20@1x.png', 20],
    ['Icon-App-20x20@2x.png', 40],
    ['Icon-App-20x20@3x.png', 60],
    ['Icon-App-29x29@1x.png', 29],
    ['Icon-App-29x29@2x.png', 58],
    ['Icon-App-29x29@3x.png', 87],
    ['Icon-App-40x40@1x.png', 40],
    ['Icon-App-40x40@2x.png', 80],
    ['Icon-App-40x40@3x.png', 120],
    ['Icon-App-60x60@2x.png', 120],
    ['Icon-App-60x60@3x.png', 180],
    ['Icon-App-76x76@1x.png', 76],
    ['Icon-App-76x76@2x.png', 152],
    ['Icon-App-83.5x83.5@2x.png', 167],
    ['Icon-App-1024x1024@1x.png', 1024],
  ];
  for (const [name, size] of iosSizes) {
    writePng(
      path.join(iosDir, name),
      render(Resvg, svg, {size, background: BG_DARK}),
    );
  }

  const androidMip = [
    ['mipmap-mdpi', 48],
    ['mipmap-hdpi', 72],
    ['mipmap-xhdpi', 96],
    ['mipmap-xxhdpi', 144],
    ['mipmap-xxxhdpi', 192],
  ];
  for (const [folder, size] of androidMip) {
    writePng(
      path.join(ROOT, `android/app/src/main/res/${folder}/ic_launcher.png`),
      render(Resvg, svg, {size, background: BG_DARK}),
    );
  }

  const whiteSvg = monoSvg(svg, '#FFFFFF');
  const notifSizes = [
    ['drawable-mdpi', 24],
    ['drawable-hdpi', 36],
    ['drawable-xhdpi', 48],
    ['drawable-xxhdpi', 72],
    ['drawable-xxxhdpi', 96],
  ];
  for (const [folder, size] of notifSizes) {
    writePng(
      path.join(
        ROOT,
        `android/app/src/main/res/${folder}/ic_notification.png`,
      ),
      render(Resvg, whiteSvg, {size, background: 'rgba(0,0,0,0)'}),
    );
  }

  console.log('Rendered brand logo assets from', path.relative(ROOT, SVG_PATH));
}

main();
