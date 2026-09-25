# 战斗与生命周期

- combat.gd：场景注册、敌人/箭矢容器、碰撞路由、击杀信号及清理。
- arrow.gd / arrow.tscn：飞行、扫掠碰撞、过期与绘制。
- damage.gd：单次命中的伤害和燃烧数据，不持有场景引用。
- 敌人自行执行 AI，成长模块处理奖励。Combat 不承担选卡或动作决策。
- 重开必须清理活动节点及等待删除的节点；死亡奖励一次，离场不奖励。
- hostile 箭通过来源有效性清理；所有对玩家伤害统一调用 rider.hurt()。
- 新敌人注册同时检查 ../world/encounter_director.gd 的出场安排。
- 此目录改动可能影响所有玩法，运行五组自动测试。

- hit_confirmed只在玩家箭真实扫掠命中、伤害结算后发出位置与方向；enemy_defeated在死亡信号中发一次位置。视觉/声音由asset/runtime/effects/archery消费，Combat不持有音效节点。
- 修改反馈事件需跑test_archery_feedback，检查齐射只响一次、未命中/离场不响、击杀单次及暂停重开。
