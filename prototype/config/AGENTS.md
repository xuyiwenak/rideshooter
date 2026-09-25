# 玩法配置资源

- 此目录存放可由Godot Inspector调整的自定义Resource，不保存本局运行状态。
- `weapons/bow_default.tres` 是当前默认弓箭配置；字段结构由 `bow_config.gd` 定义。
- `progression/growth_default.tres` 是战意奖励与升级费用；`encounters/encounter_default.tres` 是道路长度、精英关口与波次节奏；`encounters/waves/formation_*.tres` 是每波敌人/路障清单。消费者分别是 WarSpirit 和 EncounterDirector。
- 调整数值优先编辑 `.tres`，不要把同一数值重新写回玩家、敌人或成长脚本。
- 阵型敌人数量由 `WavePattern.enemies` 数组长度决定；`WaveEnemy` 定义种类、相对车道与出生 x，三个阵型依次循环。别把敌人位置再硬编码回 Director。
- 新增另一把弓时复制 `.tres` 并明确选择入口，不复制配置脚本。
- 改战意或出怪配置后运行 `test_run_config.gd`，并检查基础战斗、成长、精英和集成测试；纯数值调整也要人工试玩，理论全清预算不代表可实际全清。
