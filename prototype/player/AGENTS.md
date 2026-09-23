# 玩家与自动攻击

- rider.gd / rider.tscn：上下换道、跳跃、冲刺、生命、护盾、免伤、占位马匹绘制。
- auto_bow.gd：攻击节奏、索敌、射击与进化后的射击方式。箭实体由 combat 模块管理。
- 头顶玩家血量显示在 ../ui/hud.gd，不在 rider 的绘制函数里。
- 保留玩家固定横坐标与道路相对滚动；不擅自加入左右自由移动。
- 所有受伤经 rider.hurt()，不要绕过冲刺无敌、护盾和受伤保护；新伤害来源也遵守此约定。
- 改动后检查 test_combat、test_growth、test_raider；时钟/重开或依赖变化追加 test_integration。
