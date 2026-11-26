---
name: archviz-blender-craft
description: >-
  Archviz material, lighting, UV, color management, low-VRAM optimization, and
  Cycles craft guardrails for Blender 5.x + the bundled Znzmo 18 PBR architectural
  material and 4 lighting preset library (MyBlenderLibrary). Use alongside Blender
  MCP for photorealistic interiors.
---

# Archviz Blender Craft & Znzmo Material Library Guide

This skill pairs with the **`MyBlenderLibrary`** (`知末风自建素材库`) bundled in `assets/MyBlenderLibrary/` of this plugin.

## 1. Bundled Znzmo Asset Browser Library (`知末风自建素材库`)
- **`znzmo_materials_library.blend`**: 18 procedural PBR architectural materials (`MAT_Stone_Travertine_奶油多孔洞石`, `MAT_Marble_CalacattaViola_宝格丽紫奢石`, `MAT_Stone_BacklitOnyx_冰晶透光奢石`, `MAT_Stone_Terrazzo_暖灰水磨石`, `MAT_Tile_Zellige_手工釉面砖`, `MAT_Plaster_Microcement_侘寂微水泥`, `MAT_Plaster_FlutedArtPaint_浮雕艺术漆`, `MAT_Wood_BurlWood_中古树瘤木皮`, `MAT_Wood_SmokedWalnut_宋式烟熏黑胡桃`, `MAT_Fabric_Boucle_羊羔绒泰迪绒`, `MAT_Fabric_Velvet_中古丝绒天鹅绒`, `MAT_Leather_SaddleLeather_中古油蜡马鞍皮`, `MAT_Fabric_RattanCane_宋式编织藤编`, `MAT_Glass_ReededGlass_长虹压花玻璃`, `MAT_Glass_CrackedIce_意式冰裂破碎玻璃`, `MAT_Metal_BrushedChampagne_拉丝香槟金`, `MAT_Metal_AgedBronze_做旧古铜`, `MAT_Metal_RippledSteel_钛金水波纹金属`).
- **`znzmo_lighting_library.blend`**: 3 World Atmosphere Assets (`LGT_World_01_午后树影斜阳`, `LGT_World_02_高级蓝调时刻`, `LGT_World_03_侘寂阴天柔光`) + 4 Lighting Rig Collections (`LGT_Rig_小山丘防眩深杯射灯_24deg`, `LGT_Rig_2700K暗藏悬浮灯带`, `LGT_Rig_无主灯磁吸轨道组合`, `LGT_Rig_窗口树影光影板_Gobo`).
- **`ies/`**: 5 ANSI LM-63 `.ies` photometric files (`IES_01_Scallop_24deg.ies` to `IES_05_LinearFlood_110deg.ies`).
- **`gobos/`**: `Gobo_TreeFoliage_Dappled_2K.png`.
- **`book_covers/`**: Editorial book cover & spine textures.

## 2. Draft-First Side-by-Side Iteration & Parametric `--look` Switching
- **Read Into Numbers Before Building**: When converting a floor plan or sketch to 3D geometry, trust explicit dimension labels over raw pixel ratios and verify every room corner, wall thickness, door/window span, and furniture footprint in metres first.
- **Fast Draft Diff Loop**: Never wait for high-sample 4K renders to discover geometry or sightline bugs. Render fast draft passes at **`960 × 540`, `32 samples`**, place the draft side-by-side next to the reference, and list concrete discrepancies (beams poking through roof, posts blocking window sightlines, clipping terrain/furniture, exposure drift). Fix until the diff list is empty before final rendering.
- **Parametric `--look` Collections**: Organize lighting rigs into clean toggleable collections (`LOOK_Daylight`, `LOOK_BlueHour`, `LOOK_Overcast`, `LOOK_WarmNight`) so switching the entire scene mood from the same camera is a single script flag (`--look day` / `--look dusk`) rather than rebuilding lights.

## 3. Blender 5.x Compatibility, Color Management & Port Separation
- **Dedicated Ports**: SketchUp MCP on `127.0.0.1:9876`, Blender MCP on `127.0.0.1:9877`.
- **Color Management (`AgX` vs. `Khronos PBR Neutral`)**:
  - Blender's default `AgX` has strong highlight desaturation that can wash warm sunsets, 2700K amber coves, and rich cognac leather/walnut toward muted beige.
  - When preserving warm sunset hues, saturated accent tones, or exact brand/material color fidelity is critical, switch to `scene.view_settings.view_transform = 'Khronos PBR Neutral'`.
- **Sky Texture**: `sky_type = "MULTIPLE_SCATTERING"` (replaces removed `"NISHITA"`).
- **OBJ Import**: `bpy.ops.wm.obj_import(filepath=..., global_scale=0.0254, forward_axis='Y', up_axis='Z')` followed by `transform_apply(location=False, rotation=True, scale=True)`.
- **Cycles Sky Portal**: `area_light_data.cycles.is_portal = True`.
- **Principled BSDF Sheen**: Connect fabric Base Color to `Sheen Tint`, keep `Sheen Weight` around `0.18–0.25`.

## 4. Low-VRAM (8 GB GPU) Memory & Motion-Blur Guardrails
If Cycles hits GPU Out-of-Memory (`CUDA/OptiX OOM`) on 8 GB cards:
1. **Audit Top Offenders First**: Run a quick Python inspection in Blender listing the top 10 meshes by polygon count and top 10 `bpy.data.images` by pixel resolution/memory.
2. **Foliage & Asset LOD**: Scanned trees/conifers (e.g. Poly Haven plants) can easily reach 10M–30M polygons. Decimate or swap to lighter proxy meshes for animation/walkthrough passes while keeping full-res trees for hero stills.
3. **Apply Generative Modifiers Before Motion Blur**: Live `Bevel`, `Subsurf`, or `Solidify` modifiers on animated/moving objects cause Cycles to classify them as *deforming meshes* and duplicate vertex buffers across every motion-blur time step. **Apply modifiers (`bpy.ops.object.modifier_apply`) before keyframing motion** to slash VRAM usage dramatically.

## 5. Material, UV & Fixture Craft Guardrails
- **Real Scanned PBR vs. Procedural**: Prefer real 2K scanned PBR wood veneers (local CC0 library or Poly Haven) on large flat panels (TV consoles, cabinets) to prevent zebra stripes; keep bouclé wool loops at 3–5 mm metric scale; layer sharp `Voronoi Distance to Edge` hairline veins on Calacatta Viola marble.
- **Book & Artwork UV Chirality**: Verify UV axis orientation in 1:1 macro crops so text is never mirrored or upside-down.
- **Coves & Fixtures**: Model recessed spotlights with hollow inner baffles; illuminate ceiling coves smoothly without harsh dark shadow strips.
