# 逐风骑手 · 项目目录记忆

更新日期：2026-09-23（Asia/Shanghai）<br>
最新归档：[2026-09-23 / v002](doc/2026-09-23/v002/CHANGELOG.md)<br>
工程阶段：三车道骑射 Roguelite 灰盒 Demo，基础成长、精英及普通追击兵已实现。

GitHub：[xuyiwenak/rideshooter](https://github.com/xuyiwenak/rideshooter)（Public）。

## 目录组织

```text
game/
├── AGENTS.md                    Codex 全仓规则与阅读顺序
├── README.md                    当前目录记忆（本文件）
├── GAME_DESIGN.md               玩法策划；区分已实现与待设计
├── DEVELOPMENT_WORKFLOW.md      开发阶段与人机分工
├── TASK_BREAKDOWN.md            细化任务与资源准备清单
├── doc/
│   ├── AGENTS.md                日期版本归档规则
│   ├── README.md                历史版本索引
│   ├── _templates/CHANGELOG.md   每次交付记录模板
│   └── 2026-09-23/
│       ├── v001/CHANGELOG.md     首次基线与目录组织记录
│       └── v002/CHANGELOG.md     GitHub公开仓库发布记录
└── prototype/                   Godot 工程
    ├── AGENTS.md                工程约束与验证入口
    ├── README.md                用户运行、操作与试玩说明
    ├── ARCHITECTURE.md          模块职责、信号与生命周期
    ├── project.godot            引擎项目入口
    ├── main.tscn / main.gd      场景组装、统一时钟和输入
    ├── core/                   基础参数
    ├── player/                 玩家操作、生命与自动弓
    ├── combat/                 实体管理、箭矢、碰撞与伤害数据
    ├── enemies/                固定怪、弓手、换道追击兵
    │   └── elite/              精英决策与动作执行
    ├── progression/            战意、选卡、技能和进化
    │   └── skill_data/         技能名称与说明
    ├── world/                  道路、远景、刷怪与关卡进度
    ├── ui/                     头顶血量、HUD、选卡显示
    └── tests/                  自动检查与原生渲染截图脚本
```

各主要代码模块均有自己的 AGENTS.md；elite/ 额外说明决策与执行边界。目录树省略 .uid、缓存及部分场景文件，以实际工程为准。

## 按问题找代码

| 想改什么 | 首先打开 |
|---|---|
| 换道/跳跃/冲刺时间、基础道路速度 | prototype/core/tuning.gd |
| 玩家动作、冲刺免伤、护盾 | prototype/player/rider.gd |
| 自动攻击、目标选择、箭雨 | prototype/player/auto_bow.gd |
| 箭矢碰撞、伤害数据、实体清理 | prototype/combat/ |
| 普通怪受伤、燃烧、离场 | prototype/enemies/enemy.gd |
| 普通怪上下换道追击 | prototype/enemies/raider.gd |
| 精英选哪招 | prototype/enemies/elite/elite_brain.gd |
| 精英预警、投矛、冲撞和硬直 | prototype/enemies/elite/elite.gd |
| 出怪车道、阵型、精英出场 | prototype/world/encounter_director.gd |
| 地面速度、路障、花草 | prototype/world/road.gd |
| 山体、灌木、固定太阳 | prototype/world/scenery.gd |
| 战意升级与选卡供给 | prototype/progression/war_spirit.gd |
| 技能等级、进化与效果公式 | prototype/progression/run_build.gd |
| 技能文案 | prototype/progression/skill_data/catalog.gd |
| 玩家/精英头顶血量与状态 | prototype/ui/hud.gd |
| 普通怪头顶血条 | prototype/enemies/enemy.gd |
| 选卡显示与点击 | prototype/ui/upgrade_panel.gd |

## 当前已确认的项目记忆

- 操作：W/S 或上下换道，Space 跳跃，Shift/E 冲刺，R 重开；F1 正常流程、F2 精英练习、F3/F4 构筑预设。
- 冲刺持续 0.48 秒、冷却 3 秒，期间免伤并保留护盾；道路目标速度提高到基础的 1.8 倍，玩家横坐标不变。
- 固定步兵/弓手与橙色换道追击兵混合、多路错峰出现；精英会选冲撞、投矛或换位。
- 已有 6 项技能、2 条进化；卡牌按固定路线供给。道路中点触发精英，战斗中冻结路程推进但背景继续滚动。
- 最近一次代码交付的 5 组检查为 88/88 通过；本次目录文档交付未重跑玩法测试。
- 未完成：独立 Boss、两路/三路 Boss 技能、随机卡池/刷新/保底、Esc 暂停菜单、正式美术音效、局外成长。

## 文档职责与维护

根 README.md 只保留最新地图与状态；玩法细节放 GAME_DESIGN.md；执行安排放工作流/任务清单；模块机制放 ARCHITECTURE.md；每天每次交付的历史记录放 doc/日期/vNNN/CHANGELOG.md。避免把所有细节复制到每份文档。

已有三个策划/执行文档保留原位置，避免破坏已有引用。doc/ 是新增的版本记录区，不代表已经搬迁或备份全部文档。

新日期从 v001 起，同一天下一次交付为 v002、v003……。例如下次仍在今天修改，使用 doc/2026-09-23/v002/；不同日期新建对应日期目录。只在实际修改交付时归档，不是每日自动运行的定时任务。

运行方法见 [prototype/README.md](prototype/README.md)，验证方法见 [prototype/AGENTS.md](prototype/AGENTS.md)。
