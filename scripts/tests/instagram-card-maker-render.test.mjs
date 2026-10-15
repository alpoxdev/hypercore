#!/usr/bin/env bun
/// <reference types="bun" />
// @ts-check
/**
 * instagram-card-maker composer render gate.
 *
 * The composer must cover the whole card with a cover-cropped photo, blur only
 * the photo layer, and keep white text legible over a translucent scrim on top
 * of it. Those are pixel-level properties of the shipped asset, so every case
 * drives the real `assets/card-studio.html` over `file://` in `Bun.WebView`,
 * renders a document, and reads the drawn canvas back through `getImageData`.
 *
 * The composer is copied into a fresh temp dir first, so no repository file is
 * written to and the page runs from a clean origin. Assertions are on measured
 * pixels, drawn geometry, and the public API shape - never on prose.
 */
import { expect, test } from "bun:test";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "../..");
const composerPath = join(root, "skills/instagram-card-maker/assets/card-studio.html");
const composerSource = readFileSync(composerPath, "utf8");
const WebView = Reflect.get(Bun, "WebView");
const hasWebView = typeof WebView === "function";

/** In-page helpers available to every probe body. */
const PAGE_HELPERS = `
const mk = (w, h) => { const c = document.createElement("canvas"); c.width = w; c.height = h; return c; };
const url = (c) => c.toDataURL("image/png");
const solid = (w, h, color) => { const c = mk(w, h); const x = c.getContext("2d"); x.fillStyle = color; x.fillRect(0, 0, w, h); return url(c); };
const quad = () => {
  const c = mk(400, 400); const x = c.getContext("2d");
  x.fillStyle = "#ff0000"; x.fillRect(0, 0, 200, 200);
  x.fillStyle = "#00ff00"; x.fillRect(200, 0, 200, 200);
  x.fillStyle = "#0000ff"; x.fillRect(0, 200, 200, 200);
  x.fillStyle = "#ffff00"; x.fillRect(200, 200, 200, 200);
  return url(c);
};
const split = () => {
  const c = mk(1080, 1350); const x = c.getContext("2d");
  x.fillStyle = "#000000"; x.fillRect(0, 0, 1080, 1350);
  x.fillStyle = "#ffffff"; x.fillRect(540, 0, 540, 1350);
  return url(c);
};
const NL = String.fromCharCode(10);
const slide = (photo, extra) => Object.assign({
  title: "HOOK TITLE", body: "Body line one." + NL + "Body line two.",
  photo: photo, photoSource: "test", generated: false, alt: "test card",
  layout: "bottom-left", layoutReason: "Keep the test subject clear",
  scene: "Synthetic pixel fixture", visualType: "photo",
  reuseReason: "Repeat the controlled fixture for regression measurement"
}, extra || {});
const docOf = (photo, extra) => ({
  brand: "BRAND", width: 1080, height: 1350, caption: "test caption",
  sources: ["https://example.com/source | 2026-10-15"],
  slides: [slide(photo, extra), slide(photo, extra)]
});
const cardCtx = (i) => document.querySelectorAll("#gallery canvas")[i].getContext("2d");
const px = (ctx, a, b) => { const d = ctx.getImageData(a, b, 1, 1).data; return [d[0], d[1], d[2], d[3]]; };
const buffer = (ctx, x, y, w, h) => ctx.getImageData(x, y, w, h).data;
const at = (buf, w, x, y) => { const i = (y * w + x) * 4; return [buf[i], buf[i + 1], buf[i + 2], buf[i + 3]]; };
const lum = (r, g, b) => { const f = (v) => { const c = v / 255; return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4); }; return 0.2126 * f(r) + 0.7152 * f(g) + 0.0722 * f(b); };
const contrast = (r, g, b) => 1.05 / (lum(r, g, b) + 0.05);
const renderOne = async (photo, extra) => { await window.cardStudio.render(docOf(photo, extra)); return cardCtx(0); };
`;

/**
 * Copy the composer into a fresh temp dir and run one probe against it.
 * @param {string} body async in-page body; its resolved value is returned
 * @returns {Promise<any>}
 */
async function observe(body) {
  const dir = mkdtempSync(join(tmpdir(), "icm-render-"));
  try {
    writeFileSync(join(dir, "card-studio.html"), composerSource);
    const view = new WebView({ width: 1000, height: 800 });
    try {
      await view.navigate(`file://${join(dir, "card-studio.html")}`);
      // `view.evaluate` resolves a returned promise, so the async body is awaited directly.
      const value = await view.evaluate(`(() => { ${PAGE_HELPERS} return (async () => { ${body} })(); })()`);
      if (value && typeof value === "object" && "error" in value) throw new Error(value.error);
      return value;
    } finally {
      view.close();
    }
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
}

// ------------------------------------------------------------- composition

test.skipIf(!hasWebView)("body layouts move text and keep contrast while the cover stays bottom-left", async () => {
  const result = await observe(`
    const drawn = [];
    const original = CanvasRenderingContext2D.prototype.fillText;
    CanvasRenderingContext2D.prototype.fillText = function(value,x,y,...args) {
      if(value==="HOOK TITLE") drawn.push({align:this.textAlign,x,y});
      return original.call(this,value,x,y,...args);
    };
    try {
      const photo=solid(1080,1350,"#ffffff");
      const layouts=["bottom-left","top-left","top-right","center","bottom-right"];
      const doc=docOf(photo);
      doc.slides=layouts.map(layout=>slide(photo,{layout}));
      await window.cardStudio.render(doc);
      return {drawn, backgrounds:drawn.map((v,i)=>px(cardCtx(i),540,v.y-10)),
        manifest:JSON.parse(window.cardStudio.exportSidecars()["manifest.json"])};
    } finally { CanvasRenderingContext2D.prototype.fillText=original; }
  `);
  expect(result.drawn.map((/** @type {{align:string}} */ p)=>p.align)).toEqual(["left","left","right","center","right"]);
  expect(result.drawn.map((/** @type {{x:number}} */ p)=>p.x)).toEqual([72,72,1008,540,1008]);
  expect(result.drawn[0].y).toBe(1046);
  expect(result.drawn[1].y).toBe(200);
  expect(result.drawn[2].y).toBe(200);
  expect(result.drawn[3].y).toBeGreaterThan(200);
  expect(result.drawn[3].y).toBeLessThan(1046);
  expect(result.backgrounds.every((/** @type {number[]} */ p)=>p[0]>=90 && p[0]<=100 && p[3]===255)).toBe(true);
});

test.skipIf(!hasWebView)("invalid layout, cover alignment and unexplained photo reuse block exports", async () => {
  const result = await observe(`
    const cases=[];
    for(const kind of ["invalid","cover","reuse"]){
      const doc=docOf(solid(1080,1350,"#3366cc"));
      if(kind==="invalid") doc.slides[1].layout="diagonal";
      if(kind==="cover") doc.slides[0].layout="top-left";
      if(kind==="reuse") delete doc.slides[1].reuseReason;
      let rejected=false,blocked=false;
      try{await window.cardStudio.render(doc);}catch{rejected=true;}
      try{window.cardStudio.exportCards();}catch{blocked=true;}
      cases.push({kind,rejected,blocked,count:document.querySelectorAll("#gallery canvas").length});
    }
    return cases;
  `);
  expect(result).toEqual(["invalid","cover","reuse"].map(kind=>({kind,rejected:true,blocked:true,count:0})));
});

test.skipIf(!hasWebView)("the photo fills every card edge to edge (requires Bun.WebView)", async () => {
  const result = await observe(`
    const ctx = await renderOne(quad());
    const grid = [];
    for (let y = 2; y < 1350; y += 96) for (let x = 2; x < 1080; x += 96) grid.push(px(ctx, x, y)[3]);
    return {
      alphaValues: Array.from(new Set(grid)),
      topLeft: px(ctx, 2, 2), topRight: px(ctx, 1077, 2),
      bottomLeft: px(ctx, 2, 1347), bottomRight: px(ctx, 1077, 1347),
      leftEdge: px(ctx, 2, 400), rightEdge: px(ctx, 1077, 400),
      bottomCenter: px(ctx, 540, 1347)
    };
  `);
  // Alpha 255 at every sampled point: the photo covers 100% of the card, no gap.
  expect(result.alphaValues).toEqual([255]);
  // The four quadrants of the cover-cropped photo land at the four corners.
  const [tlr, tlg, tlb] = result.topLeft;
  const [trr, trg, trb] = result.topRight;
  expect(tlr).toBeGreaterThan(200); expect(tlg).toBeLessThan(60); expect(tlb).toBeLessThan(60);
  expect(trg).toBeGreaterThan(200); expect(trr).toBeLessThan(60); expect(trb).toBeLessThan(60);
  // Left and right edges come from the photo, so the crop reaches both sides.
  expect(result.leftEdge[0]).toBeGreaterThan(200); expect(result.leftEdge[1]).toBeLessThan(60);
  expect(result.rightEdge[1]).toBeGreaterThan(200); expect(result.rightEdge[0]).toBeLessThan(60);
  // The bottom row is still the photo (scrim-darkened), not a background bar.
  expect(result.bottomLeft[2]).toBeGreaterThan(result.bottomLeft[0]);
  expect(result.bottomLeft[2]).toBeGreaterThan(60);
  expect(result.bottomRight[0]).toBeGreaterThan(60);
  expect(result.bottomRight[2]).toBeLessThan(30);
  expect(result.bottomCenter[3]).toBe(255);
});

test.skipIf(!hasWebView)("the scrim is translucent so the photo stays visible under the text (requires Bun.WebView)", async () => {
  const result = await observe(`
    const white = await renderOne(solid(1080, 1350, "#ffffff"));
    const overWhite = { top: px(white, 540, 1046), mid: px(white, 540, 1200), low: px(white, 540, 1340) };
    const black = await renderOne(solid(1080, 1350, "#000000"));
    const overBlack = { top: px(black, 540, 1046), mid: px(black, 540, 1200), low: px(black, 540, 1340) };
    return { overWhite, overBlack };
  `);
  // Over a pure white photo the scrimmed band is a mid grey: not white (scrim present)
  // and not black (the scrim is translucent, not an opaque panel).
  for (const point of ["top", "mid", "low"]) {
    const value = result.overWhite[point][0];
    expect(value).toBeGreaterThan(40);
    expect(value).toBeLessThan(140);
  }
  // Over a black photo the same points go to black, so the photo shows through.
  expect(result.overBlack.mid[0]).toBe(0);
  expect(result.overBlack.low[0]).toBe(0);
  expect(result.overWhite.low[0] - result.overBlack.low[0]).toBeGreaterThanOrEqual(50);
});

// ----------------------------------------------------------------- contrast

test.skipIf(!hasWebView)("white text keeps provable contrast over a pure white photo (requires Bun.WebView)", async () => {
  const result = await observe(`
    const ctx = await renderOne(solid(1080, 1350, "#ffffff"));
    // The text block sits between textTop and textTop + contentHeight; sample the whole band.
    const x0 = 80, x1 = 1000, y0 = 1046, y1 = 1278;
    const buf = buffer(ctx, x0, y0, x1 - x0 + 1, y1 - y0 + 1);
    const bw = x1 - x0 + 1;
    let min = 99, minY = -1, whiteInk = 0;
    for (let y = y0; y <= y1; y += 2) {
      const [r, g, b] = at(buf, bw, 540 - x0, y - y0);
      const c = contrast(r, g, b);
      if (c < min) { min = c; minY = y; }
    }
    for (let y = y0; y <= y1; y += 1) for (let x = x0; x <= x1; x += 1) {
      const [r, g, b] = at(buf, bw, x - x0, y - y0);
      if (r === 255 && g === 255 && b === 255) whiteInk += 1;
    }
    return { minContrast: min, minY, whiteInk };
  `);
  // W3C SC 1.4.3 minimum for normal text, met structurally over the worst-case photo.
  expect(result.minContrast).toBeGreaterThanOrEqual(4.5);
  // The title/body ink is drawn at full white, on top of the scrim.
  expect(result.whiteInk).toBeGreaterThan(0);
});

// ------------------------------------------------------ text over photo

test.skipIf(!hasWebView)("the text layer stays sharp over the photo (requires Bun.WebView)", async () => {
  const result = await observe(`
    // Over a uniform photo the photo contributes no edges, so every sharp edge
    // in the text band belongs to the text layer drawn on top of the scrim.
    const ctx = await renderOne(solid(1080, 1350, "#808080"));
    const x0 = 80, x1 = 1000, y0 = 1000, y1 = 1350;
    const buf = buffer(ctx, x0, y0, x1 - x0 + 1, y1 - y0 + 1);
    const bw = x1 - x0 + 1;
    let maxStep = 0, white = 0, textTop = y1;
    for (let y = y0; y < y1; y += 1) for (let x = x0; x < x1; x += 1) {
      const a = at(buf, bw, x - x0, y - y0);
      const b = at(buf, bw, x + 1 - x0, y - y0);
      const s = Math.abs(b[0] - a[0]); if (s > maxStep) maxStep = s;
      if (a[0] === 255 && a[1] === 255 && a[2] === 255) { white += 1; if (y < textTop) textTop = y; }
    }
    return { maxStep: maxStep, white: white, textTop: textTop, topLeft: px(ctx, 540, 300) };
  `);
  // Glyph cores are drawn at full white, far above the scrimmed photo value.
  expect(result.white).toBeGreaterThan(0);
  // A single-pixel jump from scrim grey to full white: the text is not blurred.
  expect(result.maxStep).toBeGreaterThanOrEqual(120);
  // Above the text band the photo shows unscrimmed, so the scrim is localized.
  expect(result.topLeft[0]).toBeGreaterThan(100);
  expect(result.topLeft[0]).toBeLessThan(150);
});

// ------------------------------------------- preserved behaviour and API

test.skipIf(!hasWebView)("the public API renders, exports, and reports the same shape (requires Bun.WebView)", async () => {
  const result = await observe(`
    const api = window.cardStudio;
    const surface = ["validate", "render", "exportCards", "exportSidecars", "exportHTML"].map((k) => typeof api[k]);
    const summary = await api.render(docOf(solid(1080, 1350, "#3366cc")));
    const cards = api.exportCards();
    const sidecars = api.exportSidecars();
    return {
      surface: surface, frozen: Object.isFrozen(api), summary: summary,
      cards: cards.map((c) => ({ name: c.name, width: c.width, height: c.height, prefix: c.dataUrl.slice(0, 22) })),
      sidecarKeys: Object.keys(sidecars).sort()
    };
  `);
  expect(result.frozen).toBe(true);
  expect(result.surface).toEqual(["function", "function", "function", "function", "function"]);
  expect(result.summary).toEqual({ count: 2, width: 1080, height: 1350 });
  expect(result.cards.map((/** @type {{ name: string }} */ c) => c.name)).toEqual(["01.png", "02.png"]);
  expect(result.cards.every((/** @type {{ width: number, height: number }} */ c) => c.width === 1080 && c.height === 1350)).toBe(true);
  expect(result.cards.every((/** @type {{ prefix: string }} */ c) => c.prefix === "data:image/png;base64,")).toBe(true);
  expect(result.sidecarKeys).toEqual(["alt-text.json", "caption.txt", "manifest.json", "sources.md"]);
});

test.skipIf(!hasWebView)("supported dimensions render and unsupported dimensions are rejected (requires Bun.WebView)", async () => {
  const result = await observe(`
    const renderAt = async (height) => {
      await window.cardStudio.render({ brand: "B", width: 1080, height: height, caption: "c", sources: ["s | 2026-10-15"], slides: [slide(solid(1080, 1350, "#3366cc")), slide(solid(1080, 1350, "#3366cc"))] });
      const c = document.querySelectorAll("#gallery canvas")[0];
      return [c.width, c.height];
    };
    const ok = {};
    for (const h of [1080, 1350, 1440]) ok[h] = await renderAt(h);
    let bad = null, status = null;
    try { await renderAt(1200); } catch (e) { bad = String(e); }
    status = document.getElementById("status").dataset.error;
    return { ok: ok, bad: bad, status: status, gallery: document.querySelectorAll("#gallery canvas").length };
  `);
  expect(result.ok["1080"]).toEqual([1080, 1080]);
  expect(result.ok["1350"]).toEqual([1080, 1350]);
  expect(result.ok["1440"]).toEqual([1080, 1440]);
  expect(result.bad).toEqual(expect.any(String));
  expect(result.status).toBe("true");
  expect(result.gallery).toBe(0);
});

test.skipIf(!hasWebView)("overflowing text fails instead of shrinking (requires Bun.WebView)", async () => {
  const result = await observe(`
    const longTitle = ["A", "B", "C", "D", "E", "F"].join(NL);
    const longBody = ["1", "2", "3", "4", "5", "6"].join(NL);
    let titleError = null, bodyError = null;
    try { await window.cardStudio.render(docOf(solid(1080, 1350, "#3366cc"), { title: longTitle })); } catch (e) { titleError = String(e); }
    const titleGallery = document.querySelectorAll("#gallery canvas").length;
    try { await window.cardStudio.render(docOf(solid(1080, 1350, "#3366cc"), { body: longBody })); } catch (e) { bodyError = String(e); }
    return { titleError: titleError, bodyError: bodyError, titleGallery: titleGallery };
  `);
  expect(result.titleError).toEqual(expect.any(String));
  expect(result.bodyError).toEqual(expect.any(String));
  // A rejected render clears the gallery instead of exporting a shrunk card.
  expect(result.titleGallery).toBe(0);
});

test.skipIf(!hasWebView)("a supplied logo is drawn unfiltered at the top-right (requires Bun.WebView)", async () => {
  const result = await observe(`
    const ctx = await renderOne(solid(1080, 1350, "#000000"), {});
    const logoCanvas = mk(100, 40); const lx = logoCanvas.getContext("2d");
    lx.fillStyle = "#00ffff"; lx.fillRect(0, 0, 100, 40);
    const logo = logoCanvas.toDataURL("image/png");
    await window.cardStudio.render({ brand: "B", width: 1080, height: 1350, caption: "c", sources: ["s | 2026-10-15"], logo: logo, slides: [slide(solid(1080, 1350, "#000000")), slide(solid(1080, 1350, "#000000"))] });
    const drawn = cardCtx(0);
    return { logoPixel: px(drawn, 920, 100), outsidePixel: px(drawn, 700, 100) };
  `);
  // The logo keeps its original color at the top-right, unfiltered and un-recolored.
  expect(result.logoPixel[0]).toBeLessThan(40);
  expect(result.logoPixel[1]).toBeGreaterThan(200);
  expect(result.logoPixel[2]).toBeGreaterThan(200);
  // Outside the logo box the card is the (scrimmed) photo, so the logo is localized.
  expect(result.outsidePixel[1]).toBeLessThan(40);
});
