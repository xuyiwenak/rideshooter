# 精英：决策与执行分离

- elite_brain.gd：仅按距离、车道、动作冷却、重复历史评分，选 charge / spear / reposition / wait。
- elite.gd：执行状态、计时、移动、攻击预警、锁定目标、收招和绘制；elite.tscn 是生成场景。
- 仅在决策点选招，已进入的攻击不因玩家最新位置重选；预警后锁定的车道不得偷偷改变。
- 冲撞后保留破绽，成功对冲延长窗口；改动需同步 HUD 危险提示和测试。
- 目前没有独立 Boss。Boss 两路/三路技能只是策划建议，不可写成现有精英能力；未来实现时独立确定范围。
- 验证：test_elite、test_integration；新伤害机制还需 test_raider 免伤边界与原生预警截图。

- 野猪骑长SpriteFrames沿用Enemy的visual_clock；visual_animation仅映射已有状态，不产生伤害或推进决策。LOCKED/CHARGE=charge，AIM=aim，THROW=release，OPEN/RECOIL=recover，其余run。
