# 骑手拆分图集生成记录

日期：2026-09-24。工具：内置 image_gen（imagegen技能）。输入：本项目生成的 rider_shoot_four_poses.png。图集为参考造型重新生成的透明部件，不是从不透明概念板中无损抠出。

- rider_parts_sheet.png：第一版，保留源像素，用AtlasTexture引用头部、身体、箭袋、鞍具与动作区域。
- rider_nock_sheet.png：修订搭弓手势，运行时仅引用其中搭弓区域；其余部件仍使用首版。
- 原图均保留RGBA，不通过脚本改像素。区域与挂点在Godot资源/视觉脚本中配置。手臂与弓按姿势配套，头部独立，当前只有A皮肤。没有购买或使用第三方拆包素材。

## 部件生成提示词

```text
Create a TRANSPARENT PNG modular sprite parts atlas based on the reference mounted rider. NO horse. NO background, labels, grids, shadows or text. Exactly 4 columns x 2 rows of equal 384x512 cells, total1536x1024. Each asset stays completely within its own cell with clear empty margin. Pixel art, crisp outlines, simple shading, right-facing. Same teal tunic, brown trousers boots wristguards, cheerful dark hair and terracotta headband.
TOP ROW:
cell1 isolated complete head with hair face and headband, side facing right, neck stub, NO body.
cell2 isolated HEADLESS and ARMLESS seated rider body: teal torso, belt, brown bent thigh knee lower leg and boot in conventional seated horseback pose. Hips seated, knee bent forward, shin down. No arms, no hands, no head, no horse. Complete torso behind removable arm overlays.
cell3 isolated back quiver/shoulder bag with three arrows, brown leather, tilted slightly back. No person.
cell4 isolated brown saddle and hanging leather stirrup strap with clear iron stirrup loop at bottom. No horse/person.
BOTTOM ROW: four isolated PAIRS OF ARMS plus BOW, right-facing, with teal short sleeves, brown bracers and skin-colored hands; NOTHING ELSE, no head or torso. Use the SAME shoulder locations and same bow grip location across these four equal cells. Bow grip on RIGHT side of cell. The rider head and torso are invisible, to be composited from top row. Keep all arms properly connected to shoulder stubs. Exactly two arms per cell.
cell1 GRAB: left bow arm stretches forward to bow; right drawing arm bends up and back with hand at the invisible back quiver, elbow back. NO arrow nocked.
cell2 NOCK: left hand keeps bow grip; right hand near chest placing one horizontal right-pointing arrow onto bowstring. String nearly relaxed.
cell3 DRAW: left arm extended right, right elbow backward, right hand at invisible cheek draws string behind. Clear V string joining bow ends to arrow nock at cheek. ONE right-pointing arrow nocked.
cell4 RELEASE: left arm still forward holding bow same grip, right drawing hand open just behind cheek. String straight after release. NO arrow, NO flying arrow, NO motion streaks.
Important actual alpha transparency across all empty areas. These are disassembled reusable components, not a character sheet with complete people. NO HORSES in any cell. No complete heads or bodies in bottom row. Preserve reference identity.
```

## 搭弓修订提示词

```text
Edit the reference atlas ONLY bottom row SECOND cell (x384..767,y512..1023), the NOCK pose. Keep exact image1536x1024 and ALL other seven components unchanged. Preserve genuine transparent background. That second pose currently looks fully drawn. Change the drawing arm so its elbow stays at left shoulder but forearm reaches FORWARD and the drawing hand is very near the bow grip, placing the arrow nock on a nearly straight relaxed string, NOT pulling it back near the cheek. The arrow shaft extends farther RIGHT past the bow, but stays fully within x384..767. Keep two arms, same teal sleeves and brown gloves, same shoulder at around x470,y770, and same bow grip at around x704,y784. Bow tips at approximately x654,y600 and x654,y936. String nearly straight x654, hand carrying arrow nock around x646,y764. Drawing hand clearly close to bow, with the drawing forearm extending diagonally from left shoulder to right hand. No head/body. Same pixel-art quality as original. Every other cell unchanged, including the third cell full-draw pose for comparison. No labels, no background.
```
