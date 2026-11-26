# Archviz & 3D Render Mandatory Self-QA Gate

Before presenting any final 3D / interior / architectural render (including Cycles/Eevee renders and AI `i2i` / restyle outputs) to the user, you MUST run an automated layout & 1:1 native-pixel self-audit and fix blocking defects autonomously rather than waiting for the user to point them out.

## 0. Strict CAD / White-Model / Gray-Model Fidelity (Zero-Tolerance Veto)
- **Drawings & Models Are Law**: Every architectural/interior render MUST strictly follow the latest approved **CAD drawing**, **white/clay model (`白模`)**, or **gray model (`灰模`)**. Never pull an outdated early blockout when a newer complete layout exists.
- **Object-by-Object Inventory Audit**: Before any delivery, explicitly cross-check every major architectural element and furniture item in the render against the CAD / white / gray model:
  - Structural geometry: walls, ceiling coves, beams, door/window panel counts, and camera perspective.
  - Built-ins & millwork: TV feature walls, wood slats, cabinets, consoles, and trim.
  - Hero furniture & placement: sofas, lounge chairs, coffee tables, dining sets, planters, and rugs — exact **presence, count, position, orientation, and proportion**.
- **Automatic NO-SHIP Veto**: Dropping, hallucinating, relocating, or distorting any furniture or architectural element defined in the CAD/white/gray model is an **unforgivable NO-SHIP blocker**, regardless of how photorealistic the lighting or textures look. Re-run with the exact complete reference locked before handoff.

## 1. Mandatory 1:1 Native-Pixel Macro Crop Audit
- Never judge final render quality solely from a downsampled full-frame image.
- Before final delivery of any high-resolution render (>= 1920px wide), slice the image at **100% native pixel resolution** (using Python/Pillow) into **4 to 6 critical inspection crops** covering:
  1. Hero soft furnishings (sofa fabric micro-scale, cushion edges, throw pillow weave & seams)
  2. Tabletop / focal props (books, typography orientation, bowls, vases, specular sheen)
  3. Ground contact & floor/rug fidelity (chair legs, rug pile texture, furniture shadows)
  4. Large cabinetry / walls (wood veneer grain realism, plaster/stone transitions, trim joints)
  5. Ceiling & openings (cove shadow continuity, recessed light cup realism, window blinds/glare)
- Visually inspect every crop with `read_file` before deciding whether the render is ready to ship.

## 2. Adversarial Red-Team Scoring (No Premature Praise)
- During internal QA, prohibit rubber-stamping or leading with praise. Explicitly hunt for at least **5 concrete defects** across these 9 dimensions (score 1–10 each):
  1. **CAD / White-Model / Gray-Model Fidelity (Veto Gate)** — 100% faithful to latest CAD drawing or white/gray model; zero missing, added, or relocated furniture/openings/structure.
  2. **Texture Scale & Authenticity** — No procedural zebra stripes on flat wood cabinets, no oversized stucco-like fabric bumps, no stretched UVs.
  3. **Soft-Furnishing Tactility** — Natural yarn weave, stitched seams, organic cloth creases, and soft rug pile (no rubber/clay/cardboard look).
  4. **Geometry & Contact Fidelity** — No floating/clipping props, no faceted low-poly foreground edges, recessed fixtures modeled with hollow inner baffles (not flat black disks).
  5. **Typography & UV Chirality** — Book spines, covers, artwork, and wood grain must be right-side-up and unmirrored.
  6. **Material Roughness & Reflection Contrast** — Plausible physical separation between matte plaster, satin oiled wood, glossy stone, and brushed metal.
  7. **Lighting Continuity & Exposure** — No harsh unlit black bands inside ceiling coves, no clipped white blowouts, clean denoising without smeared detail.
  8. **Color Temperature & White Balance** — Strictly matches requested mood (e.g., neutral 4800K–6000K white light vs. 2700K/7800K blue hour).
  9. **1:1 Close-Up Believability** — Each native crop holds up as photographed reality rather than CG blockout.

## 3. Auto-Rework Before Handoff
- Any dimension scoring **< 8/10** (or any CAD/white-model/gray-model furniture/structure omission) is a **NO-SHIP blocker**: fix root causes in the scene/shaders/reference, re-render, and re-verify the affected 1:1 crops before delivering.
- When delivering the approved render, include a concise **Self-QA Log** confirming CAD/model inventory fidelity and noting any defects caught and fixed autonomously (or minor residual notes).
