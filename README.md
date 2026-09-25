# 逐风骑手 · 项目目录记忆

更新日期：2026-09-25（Asia/Shanghai）<br>
最新归档：[2026-09-25 / v006](doc/2026-09-25/v006/CHANGELOG.md)<br>
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
│   ├── 2026-09-23/
│   │   ├── v001/CHANGELOG.md     首次基线与目录组织记录
│   │   ├── v002/CHANGELOG.md     GitHub公开仓库发布记录
│   │   ├── v003/CHANGELOG.md     素材库与三版美术概念图
│   │   ├── v004/CHANGELOG.md     A方向连续土路概念修订
│   │   ├── v005/CHANGELOG.md     嘻哈马动画试样、烟尘与资源规范
│   │   ├── v006/CHANGELOG.md     弓箭配置Resource与调参入口
│   │   ├── v007/CHANGELOG.md     嘻哈马与马蹄烟尘接入主游戏
│   │   ├── v008/CHANGELOG.md     骑手头身比例、分层换皮肤与概念板
│   │   ├── v009/CHANGELOG.md     骑姿连接点、马镫与完整射箭分解
│   │   ├── v010/CHANGELOG.md     射箭简化为四动作循环
│   │   └── v011/CHANGELOG.md     骑手四动作设计板
│   ├── 2026-09-24/v001/CHANGELOG.md 分层骑手与四动作接入Demo
│   ├── 2026-09-25/v001/CHANGELOG.md 战意与出怪配置及压测档
│   ├── 2026-09-25/v002/CHANGELOG.md 林地劫匪敌人美术提案
│   ├── 2026-09-25/v003/CHANGELOG.md 四类敌人图集与状态姿势接入
│   ├── 2026-09-25/v004/CHANGELOG.md 骑射撒放/命中/击杀声画反馈
│   ├── 2026-09-25/v005/CHANGELOG.md 本机授权音效接入与回退
│   └── 2026-09-25/v006/CHANGELOG.md GitHub同步与缓存忽略
└── prototype/                   Godot 工程
    ├── AGENTS.md                工程约束与验证入口
    ├── README.md                用户运行、操作与试玩说明
    ├── ARCHITECTURE.md          模块职责、信号与生命周期
    ├── project.godot            引擎项目入口
    ├── main.tscn / main.gd      场景组装、统一时钟和输入
    ├── asset/                  原件/概念图、动画试样、资源规范与预览工具
    ├── config/                 Inspector可编辑的玩法数值Resource
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
| 弓箭伤害、射速、多重和燃烧数值 | prototype/config/weapons/bow_default.tres |
| 普通/精英击杀战意、升级需求 | prototype/config/progression/growth_default.tres |
| 道路长度、刷怪节奏、精英关口 | prototype/config/encounters/encounter_default.tres |
| 每波怪物数量、类型、车道和路障 | prototype/config/encounters/waves/formation_*.tres |
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
| 普通怪头顶血条 | prototype/ui/hud.gd |
| 选卡显示与点击 | prototype/ui/upgrade_panel.gd |

## 当前已确认的项目记忆

- 美术资源入口：[prototype/asset/README.md](prototype/asset/README.md)。A v3 以两条淡分界表达三路；角色方向改为搞笑嘻哈马（大眼吐舌、门牙、鼻环、金链、黄鬃毛），6 帧/8 FPS 马匹已替换主游戏方块马，并加入共享时钟烟尘、冲刺加速、离地停尘与落地短喷。A骑手已分层接入，四类林地劫匪已接入，背景仍为灰盒，没有实现多个副本；跳跃暂定格跑姿。
- 骑手已有[分层与换皮肤设计](prototype/asset/rider_design.md)和A/B/C概念板；推荐A头巾冒险者，已确认头肩臀脚蹬、背部装备分层与抓箭/搭弓/拉弓/撒放四动作循环规格，并完成[四动作设计板](prototype/asset/concepts/rider_shoot_four_poses.png)；A骑手已通过独立纹理与RiderSkin接入四动作射击；可以替换头部/皮肤资源，尚无游戏内换肤菜单。资源入口见[骑手资源说明](prototype/asset/runtime/characters/rider/README.md)。
- 敌人已有[林地劫匪团设计提案](prototype/asset/enemy_design.md)和四类概念板，对应现有步兵/弓手/追击/精英，已通过透明图集与SpriteFrames替换四类灰盒外观，保留AI、预警和碰撞；见[运行资源](prototype/asset/runtime/characters/enemies/README.md)。
- 骑射已接入撒放白线/弦声、箭尾短拖线、命中星芒/打击声及击杀烟团/滑音；9个程序合成WAV、6通道限流、暂停与重开清理。见[反馈资源说明](prototype/asset/runtime/effects/archery/README.md)。主观音色仍待试听。
- 已把本机 Ovani 7段授权音效接入弓弦、命中、马蹄、护盾、升级、选卡和草地氛围。原始WAV在Git忽略目录，通过[导入脚本与映射](prototype/asset/runtime/audio/sfx/README.md)安装；弓弦和命中缺失时回退原合成声。选卡暂停、跳跃、冲锋和重开均同步声音状态。
- 操作：W/S 或上下换道，Space 跳跃，Shift/E 冲刺，R 重开；F1 正常流程、F2 精英练习、F3/F4 构筑预设。
- 冲刺持续 0.48 秒、冷却 3 秒，期间免伤并保留护盾；道路目标速度提高到基础的 1.8 倍，玩家横坐标不变。
- 固定步兵/弓手与橙色换道追击兵混合、多路错峰出现；精英会选冲撞、投矛或换位。
- 已有 6 项技能、2 条进化；卡牌按固定路线供给。道路中点触发精英，战斗中冻结路程推进但背景继续滚动。
- 弓箭、战意成长、关卡刷新各有独立 `.tres` 配置。当前压测档普通怪2战意、精英8战意、每5基础路程秒一波、每波3怪；完整道路理论11波共33普通怪，全部击杀可获74战意、触发9次选卡。具体调参见[配置说明](prototype/config/README.md)。
- 本轮五组玩法检查89/89、马匹专项10/10、骑手专项18/18、配置专项14/14，敌人美术专项27/27，声画反馈20/20，本机授权音效13/13，共191/191通过；真人可击杀率和难度尚待试玩。
- 未完成：独立 Boss、两路/三路 Boss 技能、随机卡池/刷新/保底、Esc 暂停菜单、完整正式美术音效、局外成长。

## 文档职责与维护

根 README.md 只保留最新地图与状态；玩法细节放 GAME_DESIGN.md；执行安排放工作流/任务清单；模块机制放 ARCHITECTURE.md；每天每次交付的历史记录放 doc/日期/vNNN/CHANGELOG.md。避免把所有细节复制到每份文档。

已有三个策划/执行文档保留原位置，避免破坏已有引用。doc/ 是新增的版本记录区，不代表已经搬迁或备份全部文档。

新日期从 v001 起，同一天按已有最大编号递增；不同日期新建对应日期目录。只在实际修改交付时归档，不是每日自动运行的定时任务。

运行方法见 [prototype/README.md](prototype/README.md)，验证方法见 [prototype/AGENTS.md](prototype/AGENTS.md)。
