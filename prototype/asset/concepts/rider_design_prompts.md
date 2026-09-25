# 骑手设计对照图生成记录

- 日期：2026-09-23
- 工具：内置 image_gen（imagegen 技能），非 CLI。
- 输入：项目自有生成马图集 `../runtime/characters/horse_hiphop/horse_hiphop_run_sheet.png`，仅角色/风格参考；没有输入 Kingdom 的游戏图片或拆包素材。
- 输出：`rider_skin_concepts.png`，1536×1024 概念板。不是可直接切分的透明动画图集，马匹姿态是重新生成的示意，不是原图无损合成。
- 观察：三种头部与骑姿可供比较；射箭、冲刺可作为动作方向。纹理细节多于480×270实际画面，正式素材需要简化到目标像素尺寸并校准鞍点，不能直接缩小整板使用。

## 完整提示词

```text
Use case: stylized-concept.
Create an original pixel-art rider character DESIGN COMPARISON BOARD for a humorous relaxed side-scrolling mounted archery game, landscape 1536x1024. This is a concept board, not a production sprite atlas.
Image 1 is the project's existing funny hiphop horse design reference ONLY: brown horse, enormous eye, tongue, buck teeth, gold nose ring and gold chain, blond mane. Preserve its recognizable design in mounted examples, but do NOT copy the input's six-panel layout or dark backdrop.
Warm off-white flat background. Clean readable pixel-art sprites enlarged with nearest-neighbor-like crisp square pixels, very limited shading and consistent outlines. No painterly rendering, no realistic anatomy.
Top half: three equally sized SIDE-VIEW RIGHT-FACING mounted rider variants on the SAME reference horse, same scale, same conventional seated horseback pose. Hips clearly seated on saddle, thighs diagonally forward, bent knees and boots pointing slightly forward hanging along horse flank, never standing on back. Torso slim and slightly forward, compact. Enlarged human head ~18 pixels tall in a full horse+rider silhouette about 65 logical pixels tall; head width about 1.3x shoulders, NOT a giant bobblehead. Strongly readable heads with expressive eyebrows and face, horse face unobstructed. Human sits BEHIND horse mane. Same simple teal tunic, brown trousers and boots, brown short bow carried above horse neck in all three. Distinguish primarily HEAD:
A: original mischievous adventurer, untidy dark hair, terracotta headband tied behind, raised eyebrow, small confident grin. Recommended default.
B: goofy would-be king, SMALL crooked brass crown, short dark hair, same clear face.
C: laid-back street rider, backwards plum baseball cap, one small gold earring, same clear face; no sunglasses hiding eyes.
Label each only "A", "B", "C" in plain dark letters above.
Bottom half: three small original A action studies, SAME head scale and seated rider proportions, right-facing, on lightly muted horse silhouettes: relaxed ride, draw bow correctly with front arm holding bow toward right and rear hand drawing string to cheek, sprint with modest forward lean. Labels only "RIDE", "SHOOT", "SPRINT". Bow never passes through horse face. No extra hands, no legs stretching to ground, no huge armor, no cape obscuring mount.
Keep horse body larger than rider. This should convey reusable body pose and interchangeable head identity, friendly expressive comedy. Do not imitate any copyrighted character or include existing game logos. This is not a mock game screenshot.
```
