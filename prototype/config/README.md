# Godot 配置管理

当前采用 Godot 常用的“自定义 Resource 定义结构，`.tres` 保存数据”方式。停止游戏后，在编辑器左下角“文件系统”点开资源，右侧 Inspector 调参并保存，再重新运行游戏；游戏中只按 R 不保证重新加载资源。

- `weapons/bow_config.gd`：字段定义和Inspector分组，通常只有新增/删除配置项时才改。
- `weapons/bow_default.tres`：弓箭基础射击、多重、连射与燃烧数值。
- `progression/growth_default.tres`：普通/精英击杀战意、首次升级所需战意、之后每级增加量。字段由 `growth_config.gd` 定义，`WarSpirit` 读取。
- `encounters/encounter_default.tres`：道路长度、精英关口与出场位置、首波延迟、每波间隔、轮换基准车道、轮换阵型。字段由 `encounter_config.gd` 定义，`EncounterDirector` 读取。
- `encounters/waves/formation_a.tres`、`formation_b.tres`、`formation_c.tres`：每组具体敌人的类型、相对车道、起始横坐标和可选路障。`wave_pattern.gd` 与 `wave_enemy.gd` 定义字段。

## 这轮压测的默认档

| 参数 | 当前值 | 调整入口 |
|---|---|---|
| 普通怪 / 精英击杀战意 | 2 / 8 | `progression/growth_default.tres` |
| 升级需求 | 3、4、5…… | 同上：首次需求 3、每级 +1 |
| 道路长度 / 精英触发 | 60 / 剩余 30 基础路程秒 | `encounters/encounter_default.tres` |
| 精英前停刷普通怪 | 剩余 36 基础路程秒 | 同上；给精英出场留缓冲 |
| 首波 / 后续间隔 | 1.4 / 每 5 基础路程秒 | 同上；精英击败后首波再次等 1.4 |
| 每波普通怪 | 3 只 | `encounters/waves/formation_*.tres` 的 Enemies 数组 |

正常流程理想情况下精英前 5 波、精英后 6 波，共 11 波、33 只普通怪与 1 个精英。若全部击杀，理论总战意 `33×2+8=74`，足够触发 9 次选卡（累计需要 63），离第 10 次所需累计 75 差 1 点；剩余战意 11。漏怪不奖励，玩家实际拿到的战意与选卡数通常更少。精英练习模式不刷普通怪且不积累战意。该预算由 `test_run_config.gd` 锁定，但不等于真人可全清或难度已合格。

## 怎么调怪物数量

先改 `wave_interval`：数值越小，刷新越密；再在三个 `formation_*.tres` 的 `Enemies` 数组增减条目，决定每波具体数量。在 Inspector 展开 Enemies，增加数组大小，为新槽选择 `WaveEnemy` Resource，再展开该元素设置 `kind`、`lane_offset`、`start_x`；删怪则减小数组大小。`kind` 为 infantry / archer / raider；`lane_offset` 为相对基准车道偏移 0/1/2，超过第三道后循环；`start_x` 越大，敌人越晚到玩家附近。车道编号 0/1/2 对应上/中/下路。`lane_cycle` 是每组的基准车道轮换，当前为 `[1, 0, 2]`。三个阵型依次循环，阵型资源不是只用一次。第三组还带一个路障；勾选 `has_obstacle` 并设车道和横坐标可调整它。

若同时加怪和加战意，先估算一局 `波数 × 每波怪数 × 普通奖励 + 精英奖励`，再和累计升级需求比较。波数不仅受间隔影响，也受道路长度、首波延迟、精英前停刷线和精英战后的重启延迟影响；建议每次只改一两个变量，再跑测试与真人试玩。不要为了增加普通怪数量去修改 Combat 或 main 的生成逻辑。

改道路节点时保持 `0 < elite_trigger_remaining < pre_elite_spawn_stop_remaining < run_length`，保证精英前有停刷缓冲、精英后还有路程。把奖励设为 0、阵型数组清空或把间隔调得极短都可能让压力测试失去意义；改变默认档后，`test_run_config.gd` 的预算断言也应按新设计更新。

不要在运行游戏时通过远程 Inspector 调整后期待自动写回资源。弓箭技能目前只有两级，为了避免下标含义不清，仍使用明确的 Level 1 / Level 2 字段。

场景结构、节点引用和信号不放在配置表中；技能名称与说明仍在 `progression/skill_data/catalog.gd`。怪物生命/AI、马匹速度、弓箭伤害不属于此次“战意—刷怪量”联调，继续由各自模块或已有弓箭资源管理。
