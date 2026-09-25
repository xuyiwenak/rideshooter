# 美术资源库

统一入口：`res://asset/`。A 草原方向，角色改为搞笑轻松的嘻哈小马；6 帧嘻哈马已接入主游戏，A骑手已分层接入，四类敌人已接入林地劫匪图集，背景仍使用灰盒绘制。

## 林地劫匪（已接入Demo）

[林地劫匪四类设计](enemy_design.md)与[概念板](concepts/enemy_woodland_bandits.png)：歪锅盔打手、眯眼弓手、飞毛腿劫匪、野猪骑长，对应现有四类逻辑；透明运行图集已接入四类场景，含跑步循环与弓手/精英状态关键姿势。详见[运行说明](runtime/characters/enemies/README.md)、[实际场景截图](concepts/enemy_art_overview.png)、[运行GIF](concepts/enemy_demo_preview.gif)及[完整生成提示词](concepts/enemy_runtime_prompts.md)。生成帧仍属试样，尚未精修完整攻击/受击/死亡动画。

## 骑手（已接入Demo）

[分层与换皮肤方案](rider_design.md)及[三款头部/骑姿设计图](concepts/rider_skin_concepts.png)已建立。推荐A头巾冒险者；B歪王冠与C反戴帽用于比较。已确认头/肩/臀/脚蹬连接点、头发头巾与头部整体、背部肩囊归属弓箭装备，并细化抓箭/搭弓/拉弓/撒放四动作循环。[分层运行资源](runtime/characters/rider/README.md)已接入，包括头、身体、箭袋、鞍具、马镫和四组手臂/弓。只交付A皮肤，可通过Resource替换外观，没有游戏内换肤菜单。

[骑手四动作设计板](concepts/rider_shoot_four_poses.png)：抓箭 → 搭弓 → 拉弓 → 撒放，保留概念设计；主游戏使用另外生成的透明部件，见[真实运行GIF](concepts/rider_demo_preview.gif)。

## 最新可播放试样

- [嘻哈马动态预览 GIF](concepts/horse_hiphop_run_preview.gif)：Godot 原生渲染，6 帧、8 FPS，加独立马蹄烟尘。
- [Godot 预览场景](previews/horse_hiphop_preview.tscn)：可在编辑器打开并运行当前场景。
- [马匹视觉场景](runtime/characters/horse_hiphop/horse_hiphop.tscn)、[SpriteFrames](runtime/characters/horse_hiphop/horse_hiphop_sprite_frames.tres)、[透明图集](runtime/characters/horse_hiphop/horse_hiphop_run_sheet.png)、[烟尘场景](runtime/effects/hoof_dust/hoof_dust.tscn)。
- 造型：大眼、吐舌、大门牙、黄金鼻环、粗金链、黄鬃毛。6 帧身体形状仍存在生成动画的变化，属于试样，未声称人工精修完成。
- 资源规则见 [naming.md](naming.md)，拆分和候选素材见 [asset_breakdown.md](asset_breakdown.md)，生成记录见 [horse_hiphop_prompts.md](concepts/horse_hiphop_prompts.md)。

主游戏由 `player/rider.gd` 按统一 step 手动选帧，使用 72×72 虚拟画布、脚底 y=9。烟尘采用共享时钟的轻量尘团绘制，避免独立粒子在选卡时继续播放；原 CPUParticles2D 场景只供预览。跳跃定格跑姿，落地短喷，冲刺加快并加密烟尘，重开清空。

## 当前美术方向（2026-09-23）

- 优先 A，最新道路参考为 [A v3 三路与烟尘](concepts/a_meadow_v3.png)。原视角/纵深保留；该图角色仍是旧造型，角色方向以嘻哈马试样为准。
- 三路共享一整片土路，只保留两条浅分界，避免三条车辙形成四路错觉；外围保留草地。玩法仍为三路上下换道。
- A/B/C 可分别作为草原、秋林、雾林的副本环境主题；这是后续规划，当前没有交付多个副本。
- A v2 是内置 image_gen 编辑的概念图，未接入游戏。完整提示词见 [PROMPT_A_V2.md](concepts/PROMPT_A_V2.md)。

## 目录与状态

| 目录 / 文件 | 内容 | 当前状态 |
|---|---|---|
| [sources/alizard_pixel_horse/](sources/alizard_pixel_horse/) | 马匹三组原始 PNG、来源和校验记录 | 已下载，未接入 |
| [concepts/](concepts/) | A/B/C、道路修订、原生动画 GIF 与提示词 | 优先 A；B/C 后续副本主题 |
| [runtime/](runtime/) | 嘻哈马图集、动画资源、视觉场景和原生烟尘 | 马图集/SpriteFrames 已接入主游戏；粒子场景保留独立预览 |
| [previews/](previews/) / [tools/](tools/) | 可播场景、资产检查、原生截图导出 | 资产级验证入口 |
| [CATALOG.md](CATALOG.md) | 已有素材与候选包清单 | 候选不等于已下载或已授权归档 |

`sources/` 保存第三方原件；`concepts/` 保存参考与预览；两者通过 `.gdignore` 排除导入。`runtime/characters/` 与 `runtime/effects/` 已建立，environment/ 与 ui/ 有实际资源时再建。

## 使用约定

- 保留原件；裁切、改色、翻转等衍生文件独立保存，并登记所用来源与变化。
- 每包记录作者、源页面、下载地址、授权、获取日期、使用状态；禁止把候选包标成已接入。
- 当前仓库公开。禁止单独再分发的素材包不要直接提交原件；需要按具体条款安排私有存储或本地下载，并在提交前检查。
- 不以图片边缘自动推算碰撞范围；继续保留脚底、攻击点和三车道约定。
- 概念图不是精灵图集，不直接切图当成动画，也不代表第三方素材组合后的真实渲染。

## 三版效果图

| 方案 | 侧重点 | 落地需注意 |
|---|---|---|
| [A 晴日草原](concepts/a_meadow.png) | 简洁明亮，战斗容易辨识 | 草边细节减量；敌方弓手朝向需修正 |
| [B 暖秋山林](concepts/b_autumn.png) | 后续秋林副本主题候选 | 秋叶不可盖住道路和预警；敌方弓手朝向需修正 |
| [C 青雾古道](concepts/c_mist.png) | 冷色山林，氛围更沉静 | 雾仅放远景，角色保持对比；敌方弓手朝向需修正 |

三图均有三条水平道路和相同角色布局，但像素密度、人物尺寸、HUD 与实际 480×270 画面并未逐像素对齐。生成的马也不是原 PNG 的无损拼贴。选型后需制作一屏真实素材验证，再接动画和完整关卡。

生成方式与完整提示词见 [PROMPTS.md](concepts/PROMPTS.md)。

## 骑射反馈（已接入）

[原生特效场景](runtime/effects/archery/README.md)与[音效说明/本地导入映射](runtime/audio/sfx/README.md)已接入真实撒放、命中、击杀、护盾和升级选卡事件；马蹄与草地声音随统一暂停。9个合成音效仍作为公开仓库中的备用声，本机7段Ovani授权WAV经导入脚本复制到被忽略的runtime目录。[旧运行GIF](concepts/archery_feedback_preview.gif)无声；[旧合成声引擎混音](concepts/archery_feedback_mix.wav)可试听。新授权声混音只保存在本机 Godot `user://`。
