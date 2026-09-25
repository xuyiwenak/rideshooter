# 嘻哈马与三跑道生成记录

2026-09-23；内置 image_gen，不是 CLI。马匹参考为 alizard 的 CC0 horse_run_cycle.png；最终 PNG 为 AI 生成动画试样，非原素材逐像素改绘。Godot 通过 AtlasTexture 区域和虚拟边距对齐，原 PNG 像素未作脚本编辑。

## A v3：两条分界与烟尘

```text
Use case: precise-object-edit. Input is an existing pixel-art mounted archery game mockup. Fix ONLY dirt-ground readability and add hoof dust. Preserve the exact image size, perspective, horizon, sky, meadow, outer grass borders, HUD and every character's position, scale and identity.
The broad dirt ground extends y345 to y820 in the 1672x941 reference. It currently has THREE faint horizontal ruts (around y440,545,660) which make FOUR perceived lanes. REMOVE ALL these ruts completely first, filling them with natural matching sandy ground. Then use EXACTLY TWO faint irregular shallow separators, one at y465 and one at y680, to suggest EXACTLY THREE wide lanes. The upper lane contains the soldier at x1200; middle lane contains the horse and enemy archer; lower lane contains the running soldier and wooden obstacle. Absolutely no center rut through the middle lane. No other long horizontal marks or additional divisions. One unified dirt surface, no grass medians, no painted road lines, no curbs. Low contrast, softly interrupted pixel-cluster separators, not strong geometric stripes. Preserve tiny random speckled ground texture without extended horizontal rows.
Add a modest readable trail of warm beige PIXEL ART DUST behind the running horse's rear hooves, at ground level near x355-470 y595-620, extending LEFT backwards, a few small rounded dusty puffs tapering and dissipating to the left. Thin earthy dust not smoke/fire, not a huge cloud; keep legs and hooves clearly visible and shadows intact. No dust near the horse's head or floating behind its rider. Stay crisp low-resolution pixel art; do not add smooth painted particles. Everything else stays the same.
```

## 第一版大眼吐舌马

```text
Use case: stylized-concept. Asset type: production sprite sheet for a funny relaxed 2D Godot pixel-art horse running animation.
Reference image: original CC0 chestnut horse run strip, only as species/color reference. Redesign as an ORIGINAL comical pony: an oversized expressive head, ONE very large white visible eye with big dark pupil, rounded broad goofy muzzle, big nostrils, long pink tongue flopping from the open smiling mouth, short stocky chestnut body, black spiky mane and black swishing tail, dark hooves. Silly and endearing, not heroic, not realistic. Face RIGHT in perfect side view. NO rider, saddle, weapons, dust or ground shadow. Make the tongue conspicuous in every frame.
Deliver exactly SIX sequential distinct gallop animation frames in a precise THREE COLUMNS by TWO ROWS uniform sprite sheet. Output dimensions ideally 1536x1024, with each frame in a 512x512 cell. Read order left-to-right then top-to-bottom. Every cell identical size. Exactly one pony per cell. Keep each body centered at identical x relative to cell, same pony scale, same head size, eye and tongue design, consistent palette and uniform chunky pixel size. Keep at least 50 px margin around each silhouette. Feet share same ground baseline within each cell. All movement inside frame; no camera movement.
Six genuinely DIFFERENT poses spanning a coherent looping gallop: (1) rear legs push backward, front knees tucked; (2) airborne extension with front legs reaching right and rear legs reaching left; (3) front hoof landing reaching forward, rear knees gather; (4) body lower in compression, front legs under chest and rear legs tucked; (5) rear hooves plant forward under belly, front legs lift; (6) hind legs extend into next push, front knees folded. Body bobs subtly no more than 10 px. Tongue bounces with delayed motion and tail swishes. Frame 6 leads naturally into 1. Do not simply duplicate the same running pose.
Style: clean coarse pixel art, 16-24 colors, strong dark brown stepped outlines, flat clustered highlights, toy-like proportions, no gradients, no antialiasing, no smooth illustration.
TRUE TRANSPARENT alpha background across the ENTIRE sheet, not a checkerboard painted into image. No backdrop, no labels, no numbers, no dividers, no border, no decorative panels, no text. Keep six clear isolated sprites on transparency.
```

## 最终嘻哈配饰版

```text
Use case: precise-object-edit. Edit this SIX-FRAME horse animation sprite sheet into a comical relaxed HIP-HOP pony. Preserve the 1536x1024 canvas, exact THREE COLUMN by TWO ROW uniform 512x512 cell layout, right-facing side view, six distinct galloping leg poses and same silhouette scale in every cell.
Consistent character changes in ALL SIX frames:
1. Two conspicuous oversized ivory FRONT BUCK TEETH visible at the upper front of the goofy open mouth. Not fangs. Keep the long pink flopping tongue and giant silly eye.
2. A shiny thick GOLD SEPTUM NOSE RING through the front/bottom of the muzzle, readable against chestnut fur, not through the eye or tongue.
3. A chunky oversized GOLD CHAIN NECKLACE draped around the base of the neck, visible as 4-6 simple interlocking golden links on the chest and front shoulder. Same chain design all frames; slight sway following run.
4. Dye the spiky MANE bright golden BLOND with a few dark roots. Keep the tail dark to separate silhouette. Playful hip-hop swagger and broad grin, cute mischievous troublemaker, not intimidating.
Keep chestnut coat, stout small body, large head, tiny dark hooves. Clearly different leg poses per frame, smoothly looping running cycle. Preserve body width and facial proportions through frames; do not add rider, clothing, sunglasses, hat, money, text, or more jewelry.
PRODUCTION CLEANUP: remove ALL colored glow, soft shadow, dark haze, decorative lighting, background pixels. True transparent alpha right up to clean pixel outline. No ambient glow. All visible horse pixels should be solid opaque, exterior fully transparent (hard alpha edges), including black mane/tail outlines. Crisp coarse pixel-art clusters, simplified flat colors, no dithering noise, no painted airbrush effects. Do not bake checkerboard into image.
No captions, no grid lines, no numbers. Exactly six pony frames on transparent background, each safely inside its equal cell.
```
