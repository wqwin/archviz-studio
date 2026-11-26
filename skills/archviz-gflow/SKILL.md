---
name: archviz-gflow
description: >-
  Generate photorealistic interior and architectural renderings from CAD drawings,
  white/clay models (白模), gray models (灰模), or 3D renders using gflow-cli
  (Google Flow Nano Banana 2.1 i2i + 2K/4K upscaling) with Pre-Render Spatial
  Inventory, standardized --look lighting presets, strict layout lock, and
  mandatory side-by-side + 1:1 native-pixel Self-QA.
---

# Archviz Rendering Workflow via `gflow-cli`

## 1. Pre-Render Spatial & Furniture Inventory ("Read It Into Numbers First")
Before calling `gflow image i2i` (or building geometry), **NEVER jump straight into rendering**. First inspect the latest approved reference (`read_file`) and write down a concise **Pre-Render Inventory**:
- **Latest Reference Check**: Confirm it is the latest approved CAD drawing, white model (`白模`), gray model (`灰模`), or complete 3D layout — never an outdated early blockout missing furniture.
- **Dimension Priority (CAD / Floor Plans / Sketches)**: When reading dimensioned drawings or sketches, **trust written dimension labels over raw pixel ratios**, and explicitly flag any contradictions (e.g. mismatched room widths or misaligned openings) before proceeding.
- **Enumerated Lock List**:
  1. **Architectural Envelope**: Wall layout, ceiling coves/recessed channels, beam spans, exact door/window panel count, and camera eye-height / perspective.
  2. **Built-ins & Millwork**: TV feature wall, wood slats, floating consoles, cabinetry, shelving, and trim.
  3. **Hero Furniture & Props**: Exact **presence, count, position, orientation, and proportion** of every sofa, accent lounge chair, coffee table, dining set, planter, rug, and floor lamp.
- Copy non-ASCII reference paths to a clean ASCII temp path before passing `--ref` on Windows.

## 2. Standardized Lighting & Mood Presets (`--look`)
Use these 5 standardized architectural mood presets whenever the user specifies a look (e.g., `--look bluehour`, "用日景预设", "切阴天柔光") so lighting, color temperature, and exposure remain consistent across iterations from the same camera:

| Preset (`--look`) | Exterior / Sky | Interior Lighting | Ideal Use Case |
| :--- | :--- | :--- | :--- |
| **`daylight`** | Crisp neutral 5000K–5600K daylight, soft clean sunbeams | Subtle balanced architectural fill; no blown-out highlights | Clean daytime presentation, neutral material fidelity |
| **`bluehour`** | Deep 7800K twilight sky with dusk foliage silhouette | Warm 2700K–2800K indirect ceiling coves, 24° scallop wall washers, natural warm-cool glass reflections | Hero living rooms, luxury residential twilight showcase |
| **`golden_afternoon`** | Low 3500K–4200K late-afternoon raking sun with dappled foliage/mullion shadows | Soft warm accent lamps at 30–50% intensity | Warm timber, travertine, editorial sunlit interiors |
| **`overcast_soft`** | Diffused 5800K–6500K cloudy/post-rain sky, ultra-soft shadow gradients | Subtle 3000K architectural wash; crisp matte/satin contrast | Wabi-sabi, microcement, minimalist serene spaces |
| **`warm_night`** | Dark night exterior with subtle window reflections | Layered 2700K indirect coves, recessed baffles, table/floor lamps; zero harsh overhead glare | Cozy evening residential & hospitality mood |

## 3. Layout-Locked `i2i` Generation
Run `gflow image i2i` with `--model nano2 --aspect 16:9 -n 1`:
- Paste the **Pre-Render Inventory** verbatim into a **STRICT LAYOUT LOCK** section of the prompt so every architectural opening and furniture item is explicitly anchored and nothing is dropped, added, or relocated.
- Pair it with the chosen **`--look`** lighting recipe and physically grounded material descriptions.
- When upgrading an existing 3D CG render that has procedural shader artifacts (striped wood veneer, corrugated pillow bumps, blurry marble), explicitly instruct Flow to replace those CG textures with real physical materials while keeping geometry 100% locked.
- Reuse the returned `media_id` when iterating styles or `--look` presets on the same reference.

## 4. High-Resolution Upscaling (`2K` / `4K`)
```powershell
gflow image upscale <MEDIA_ID> --scale 4k --out "<output_dir>"
```
- If `UpscaleUnavailableError` occurs (4K is Flow Ultra-only), automatically fall back to `--scale 2k` (`2752 × 1536`) and inform the user clearly.

## 5. Mandatory Self-QA Gate (Enforced by `rules/AGENTS.md`)
Before delivering any render (`>= 1920px` wide):
1. **Side-by-Side Diff Audit & Object-by-Object Inventory Check**: Compose a quick side-by-side comparison (`reference | render`) via `uv run --with pillow python ...` and inspect it via `read_file` against the Pre-Render Inventory. Any missing, added, or relocated furniture/opening = automatic **NO-SHIP**.
2. **1:1 Native-Pixel Macro Crop Audit**: Slice 4–6 native 100% resolution crops (sofa/pillows, tabletop/props, lounge chair/floor/rug, TV wall/cabinetry, ceiling cove/blinds) and inspect EVERY crop via `read_file`.
3. **Adversarial Scoring**: Score all 9 dimensions (1–10). Any score `< 8/10` triggers autonomous rework & re-verification before final handoff.
4. Deliver with clickable `file:///` links and a concise **Self-QA Log**.
