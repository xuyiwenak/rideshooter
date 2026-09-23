# 2026-09-23 / v001 · 项目指引与版本记录基线

- 日期与时区：2026-09-23，Asia/Shanghai。
- 当日版本：v001（首次建立记录，不代表第一版游戏）。
- 状态：已交付。
- 关联前版：无；不为之前的对话追溯编造版本。
- 用户目标：在目录层级给 Codex 定位指引，按日期和版本管理修改记录，并在最外层保留项目目录记忆。

## 本轮实际变更

1. 新建根 README.md，维护当前目录树、按功能找代码的索引、已实现与未实现状态。
2. 新建根 AGENTS.md、Godot 工程级和各主要模块 AGENTS.md，规定阅读顺序、职责边界、验证入口和交付归档规则。
3. 新建 doc/ 的规则、历史索引、记录模板和本版本目录。
4. 保留原有策划案、工作流、任务清单和源码位置。没有修改游戏代码、资源、Godot 配置或依赖。

## 涉及文件

- [根目录记忆](../../../README.md)、[根 Codex 规则](../../../AGENTS.md)。
- [工程规则](../../../prototype/AGENTS.md)。
- 模块规则：[core](../../../prototype/core/AGENTS.md)、[player](../../../prototype/player/AGENTS.md)、[combat](../../../prototype/combat/AGENTS.md)、[enemies](../../../prototype/enemies/AGENTS.md)、[elite](../../../prototype/enemies/elite/AGENTS.md)、[progression](../../../prototype/progression/AGENTS.md)、[world](../../../prototype/world/AGENTS.md)、[ui](../../../prototype/ui/AGENTS.md)、[tests](../../../prototype/tests/AGENTS.md)。
- [归档规则](../../AGENTS.md)、[历史索引](../../README.md)、[记录模板](../../_templates/CHANGELOG.md)、本记录。

## 当前玩法基线（此前已存在，不是本轮新增）

- 三车道上下移动、跳跃、自动骑射、冲刺加速与0.48秒免伤；无左右自由移动。
- 普通怪包含固定步兵/弓手与换道追击兵，多路错峰出现；玩家和敌人头顶显示生命。
- 精英使用评分决策与动作状态执行；6项技能、2条进化、固定路线选卡。
- 模块拆分与信号协作已落地，详见 [工程结构](../../../prototype/ARCHITECTURE.md)。

## 行为变化与兼容性

游戏行为无变化。新增的是后续协作入口和人工维护规范。日期版本号仅标识文档交付批次，不代替 Git 提交或可恢复源码备份；本轮未创建提交，也未配置每日自动化。

## 验证

- 本轮：使用 Node.js 静态检查脚本检查16份新增文档、28个Markdown本地链接及版本目录，全部通过。本轮文件改动仅为新增文档。
- 本轮未运行 Godot 玩法测试：没有修改代码、场景或配置。
- 历史结果：此前一次代码交付的 test_combat 18/18、test_elite 19/19、test_growth 19/19、test_integration 17/17、test_raider 15/15，共88/88通过；这是沿用结果，不是本轮重跑。
- 历史画面检查：此前已查看追击兵预警与头顶生命截图；本轮未新增画面检查。

## 未完成与下一步

独立Boss、多路Boss技能、随机卡池/刷新/保底、Esc暂停菜单、正式美术音效和局外成长仍未完成。下一轮实际修改后，按当日目录已有版本顺延；若仍在2026-09-23，则创建v002，不覆盖本记录。
