# 普通怪与敌人共用规则

- enemy.gd：共用生命/燃烧/死亡信号，以及普通怪移动、弓手预警、接触和离场；共用visual_clock与SpriteFrames绘制。
- 燃烧持续时间、跳伤与间隔读取 `../config/weapons/bow_default.tres`，不要在敌人脚本另设一套数值。
- infantry.tscn / archer.tscn：固定车道普通怪。
- raider.gd / raider.tscn：较快接近、预告后相邻换道的追击兵；不临时改目标，不贴脸开始换道。
- elite/：精英专属决策和执行，进入修改前读该目录 AGENTS.md。
- 出现在哪一路、同时出现多少只由 ../world/encounter_director.gd 管，不在敌人脚本自行刷怪。
- 保持可见位置与碰撞一致；目的车道不等于已经到达的位置。
- 扩展敌人时检查 Combat 场景注册、战意奖励、离场/死亡单次信号、选卡暂停和重开。
- 普通怪改动跑 test_combat、test_raider、test_integration；共用生命周期改动再跑精英与成长。

- 场景导出visual_frames/visual_size选择外观；素材在asset/runtime/characters/enemies。visual_clock只由step_status推进，不能自主播放。
- 普通怪头顶血条和目标点统一由HUD绘制，enemy.gd只画本体/预警/受击燃烧；不重复血条。
- 美术修改另跑test_enemy_art、preview_enemy_art检查帧、暂停、真实出箭与原生可见性。

- hit_flash同时驱动角色贴图短暂提亮和10%压缩回弹；只改绘制尺寸，脚底与hit_center保持不变。
