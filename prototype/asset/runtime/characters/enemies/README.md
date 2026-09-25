# 林地劫匪运行资源

四种原生场景已引用各自的 SpriteFrames；引擎无需插件。来源：内置 image_gen 参考本项目概念板生成，完整提示词见 [生成记录](../../../concepts/enemy_runtime_prompts.md)。没有引入第三方素材包，生成资源不标为第三方 CC0。

| 游戏类型 | 美术目录 | 当前动作 | 实际显示画布 |
|---|---|---|---|
| infantry | goblin_grunt | 4帧跑步，8FPS | 48×48 |
| archer | goblin_archer | 2帧走路6FPS、瞄准、空弓撒放 | 48×48 |
| raider | goblin_runner | 4帧跑步，10FPS | 52×52 |
| elite | boar_captain | 2帧奔跑8FPS、投矛预备、撒放、冲撞、喘气破绽 | 72×72 |

每个目录保存原始透明 `*_sheet.png`、`*_sprite_frames.tres` 与 `*_manifest.json`。PNG未经像素裁改；AtlasTexture描述区域和透明留白，保持方形虚拟画布与脚底 y=55/64 画布高度；绘制脚底在角色局部 y=4。区域、画布、校验值、帧顺序和帧率均可在manifest核对。所有角色朝左，nearest采样。

Enemy.visual_clock只由step_status推进；选卡、死亡和结束使用现有main暂停，重开由Combat删除旧节点。Enemy.visual_animation读取弓手预警/已射击状态；Elite覆盖该方法读取自己的现有状态。美术不创建箭矢，不改出怪、战意、伤害、索敌、碰撞和AI承诺车道。

弓手只在实际发射后切空弓。精英LOCKED/CHARGE用俯身冲撞，AIM用举矛，THROW用空手撒放，OPEN/RECOIL用吐舌喘气；其他状态用奔跑。精英脚下彩色状态环、冲撞红道、瞄准线，普通怪血条/目标点/燃烧与受击提示全部保留。

这是可运行的生成美术试样。跑步循环仍有帧间形变；精英冲撞和破绽目前是状态关键姿势，尚无精修完整攻击/死亡/受击动画。不能把2帧或静态关键姿势称为完整高帧动画。

`tests/preview_enemy_art.gd`在真实main场景中安排四类同时出现进行可见性检查；该布局是验收排布，不代表修改了实际刷怪表。GIF提高敌人生命用于观察动画，不是正常通关录像。
