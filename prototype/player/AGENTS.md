# 玩家与自动攻击

- rider.gd / rider.tscn：上下换道、跳跃、冲刺、生命、护盾、免伤、嘻哈马 SpriteFrames 与共享时钟烟尘绘制。
- rider_visual.gd / rider_skin.gd：分层贴图、皮肤Resource和马帧鞍点偏移；无独立时钟。皮肤只管外观。
- auto_bow.gd：四动作射击周期、索敌、撒放时生成箭及进化后的射击方式。箭实体由 combat 模块管理。
- 弓箭伤害、弹速、多重数量与射速读取 `../config/weapons/bow_default.tres`；行为判断留在脚本。
- 马匹跑帧、尘团寿命只由 step 推进；跳跃停尘/定格跑姿，落地短喷，reset 清空。贴图不决定碰撞或攻击点。
- 头顶玩家血量显示在 ../ui/hud.gd，不在 rider 的绘制函数里。
- 保留玩家固定横坐标与道路相对滚动；不擅自加入左右自由移动。
- 所有受伤经 rider.hurt()，不要绕过冲刺无敌、护盾和受伤保护；新伤害来源也遵守此约定。
- 飞行箭起点由rider.arrow_origin读取visual.muzzle，不能回退为脱离贴图的硬编码坐标；新增动作覆盖test_rider_animation。
- 改动后检查 test_combat、test_growth、test_raider；时钟/重开或依赖变化追加 test_integration。

- AutoBow.released在shoot_volley完成后只发一次，提供当前弓口与方向；不要在每支箭的shoot内重复播放弦声。
