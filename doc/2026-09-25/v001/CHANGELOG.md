# 2026-09-25 / v001 · 战意与出怪压测配置

- 日期与时区：2026-09-25，Asia/Shanghai
- 当日版本：v001（文档批次，不是游戏发行版本）
- 状态：已交付
- 关联前版：[2026-09-24 / v001](../../2026-09-24/v001/CHANGELOG.md)
- 用户目标：提高战意和普通怪数量供试玩测试，并将相关可调参数单独配置，便于后续改档。

## 本轮实际变更

- 新增成长 Resource：普通击杀2战意、精英击杀8战意、首级费用3、后续每级费用+1；WarSpirit 在重开时读取配置，并按配置结算击杀与溢出。
- 新增关卡 Resource：道路长度60、精英在剩余30触发、精英前剩余36停刷、首波延迟1.4、后续间隔5（单位均为基础路程秒）；精英出场车道与横坐标、轮换基准车道也可调。
- 三组阵型分别保存为 Resource，每组3只普通怪；每只可设类型、相对车道、起始横坐标，第三组保留路障。EncounterDirector 只负责按配置执行，不再持有固定阵型。
- 主场景初始化时明确重置各模块；适配原有测试预期，新增配置专项测试覆盖自定义 Resource、战意计算、刷新与理论整局预算。
- 更新配置使用说明、模块职责、试玩说明及策划案的最新已实现参数。

## 涉及文件

- [成长配置](../../../prototype/config/progression/growth_default.tres)、[字段定义](../../../prototype/config/progression/growth_config.gd)、[战意消费者](../../../prototype/progression/war_spirit.gd)
- [关卡配置](../../../prototype/config/encounters/encounter_default.tres)、[字段定义](../../../prototype/config/encounters/encounter_config.gd)、[阵型目录](../../../prototype/config/encounters/waves/)、[关卡消费者](../../../prototype/world/encounter_director.gd)
- [主场景组装](../../../prototype/main.gd)、[配置专项测试](../../../prototype/tests/test_run_config.gd)、[调参说明](../../../prototype/config/README.md)、[工程结构](../../../prototype/ARCHITECTURE.md)
- [策划案](../../../GAME_DESIGN.md)、[试玩说明](../../../prototype/README.md)、[项目目录记忆](../../../README.md)

## 行为变化与兼容性

默认正常流程理论上有精英前5波、精英后6波，合计33只普通怪与1只精英。全清总战意为 `33×2+8=74`，可触发9次升级；第10次累计需要75，差1。漏怪不奖励，故实际成长低于此上限。精英练习模式不刷普通怪、不开成长。三车道上下换道、自动骑射、冲刺、敌人AI、弓箭数值和现有固定供卡路线未改；未引入插件或第三方素材。改变阵型数量后，理论预算会相应改变。

## 验证

- 本轮执行：`/Users/evan/Desktop/Godot.app/Contents/MacOS/Godot --headless --path prototype --editor --quit`；退出码0，资源与脚本导入通过。
- 本轮逐项执行：同一 Godot 二进制、`--headless --path prototype --script res://tests/<文件名>`，文件依次为 `test_combat.gd`、`test_elite.gd`、`test_growth.gd`、`test_integration.gd`、`test_raider.gd`、`test_horse.gd`、`test_rider_animation.gd`、`test_run_config.gd`。实际结果依次为18/18、19/19、20/20、17/17、15/15、10/10、18/18、14/14；合计131/131，退出码均为0。
- 人工检查：未做真人试玩；配置专项用脚本推进道路并清怪，只证明数值与调度逻辑，不证明玩家能全清。
- 未运行：原生图形截图/视觉比较；本轮未修改表现资源，最终手感和密度仍需玩家试玩确认。

## 未完成、风险与下一步

- 33只普通怪、74战意是理想全清预算。随着密度增加，实际漏怪率、卡牌暂停频率、碰撞压力和帧率可能与脚本推演不同。
- 建议在正常流程分别试玩弓箭/战马路线，记录每局击杀数、最终等级、通关或死亡时 Road 值，再决定是否需要进一步调小间隔、提高奖励或放宽升级费用。
- 未完成项仍包括独立 Boss、随机卡池/保底、正式美术音效、局外成长；本轮没有把它们写成已交付。
