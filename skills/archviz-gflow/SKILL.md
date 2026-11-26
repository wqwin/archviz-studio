---
name: archviz-gflow
description: >-
  Generate photorealistic interior and architectural renderings from CAD drawings,
  white/clay models (白模), gray models (灰模), or 3D renders using gflow-cli
  (Google Flow Nano Banana 2.1 i2i + 2K/4K upscaling) with strict layout lock
  and mandatory 1:1 native-pixel Self-QA.
---

# Archviz Rendering Workflow via `gflow-cli`

## 1. Strict Reference Selection (Zero-Tolerance Gate)
- Always use the **latest approved CAD drawing, white model (`白模`), gray model (`灰模`), or complete 3D layout** as `--ref`. Never use an outdated early blockout missing furniture.
- Copy non-ASCII reference paths to a clean ASCII temp path before passing `--ref` on Windows.

## 2. Layout-Locked `i2i` Generation
Run `gflow image i2i` with `--model nano2 --aspect 16:9 -n 1`:
- Include an explicit **STRICT LAYOUT LOCK** section enumerating EVERY hero architectural element (ceiling coves, door/window panel count, wall slats, camera angle) and EVERY furniture item (sofa, accent lounge chairs, coffee table, planter, TV console, rug) so nothing is dropped, added, or moved.
- When upgrading an existing 3D CG render that has procedural shader artifacts (striped wood veneer, corrugated pillow bumps, blurry marble), explicitly instruct Flow to replace those CG textures with real physical materials while keeping geometry 100% locked.
- Reuse the returned `media_id` if iterating styles on the same reference.

## 3. High-Resolution Upscaling (`2K` / `4K`)
```powershell
gflow image upscale <MEDIA_ID> --scale 4k --out "<output_dir>"
```
- If `UpscaleUnavailableError` occurs (4K is Flow Ultra-only), automatically fall back to `--scale 2k` (`2752 × 1536`) and inform the user clearly.

## 4. Mandatory Self-QA Gate (Enforced by `rules/AGENTS.md`)
Before delivering any render (`>= 1920px` wide):
1. **Object-by-Object Inventory Audit**: Cross-check every architectural element and furniture piece against the CAD/white/gray model. Any omission or relocation = automatic **NO-SHIP**.
2. **1:1 Native-Pixel Macro Crop Audit**: Use `uv run --with pillow python ...` to slice 4–6 native 100% resolution crops (sofa/pillows, tabletop/props, lounge chair/floor/rug, TV wall/cabinetry, ceiling cove/blinds) and inspect EVERY crop via `read_file`.
3. **Adversarial Scoring**: Score all 9 dimensions (1–10). Any score `< 8/10` triggers autonomous rework & re-verification before final handoff.
4. Deliver with clickable `file:///` links and a concise **Self-QA Log**.
