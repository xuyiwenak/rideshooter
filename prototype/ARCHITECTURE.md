# 工程结构与扩展指南

本轮把原先集中在 main.gd 的玩法拆成独立场景与职责模块。保留三车道、自动骑射、跳跃和冲锋，不加入左右自由移动。使用原生 GDScript；没有安装行为树插件，也没有复制开源项目代码或素材。

## 文件归属

| 位置 | 负责什么 | 不应承担什么 |
|---|---|---|
| main.tscn / main.gd | 组装模块、连接信号、统一推进与暂停、重开与输入分发 | 敌人决策、技能公式、绘制角色 |
| core/tuning.gd | 基础移动与道路参数 | 每局运行状态、武器专属数值 |
| config/weapons/bow_config.gd + bow_default.tres | 弓箭配置字段与Inspector可编辑的当前数值 | 技能运行状态、索敌规则 |
| config/progression/growth_config.gd + growth_default.tres | 普通/精英战意收益与升级费用 | 本局战意余额、选卡状态 |
| config/encounters/encounter_config.gd + encounter_default.tres + waves/ | 道路/精英关口、刷新节奏、阵型轮换及具体刷怪清单 | 刷怪计时、敌人实体生命周期 |
| player/rider.tscn / rider.gd | 换道、跳跃、冲锋、生命、护盾、马匹跑帧与烟尘 | 敌人生成、经验与选卡 |
| player/rider_visual.gd / rider_skin.gd | 分层外观、皮肤引用、马帧鞍点修正 | 伤害、独立动画时钟 |
| player/auto_bow.gd | 四动作周期、自动索敌、撒放事件与构筑射击效果 | 伤害结算、敌人决策 |
| combat/combat.gd | 管理敌人与箭矢、碰撞路由、清理与击杀信号 | 选卡、道路调度 |
| combat/arrow.tscn / arrow.gd / damage.gd | 飞行、扫掠碰撞、伤害及燃烧数据 | 全局成长状态 |
| enemies/enemy.gd + infantry/archer.tscn | 普通怪移动、生命、燃烧、攻击与离场，共用美术时钟与绘制 | 精英动作选择 |
| enemies/raider.gd / raider.tscn | 追击兵的换道预告、锁定移动、冷却 | 改写统一伤害和奖励规则 |
| enemies/elite/elite_brain.gd | 根据距离、车道、冷却与历史给动作评分 | 绘制、直接移动或扣血 |
| enemies/elite/elite.gd / elite.tscn | 执行已选动作：预警、换位、投矛、冲锋、硬直、回位 | 每帧重新决定攻击目标 |
| progression/run_build.gd | 技能等级、进化、技能数值与击杀回血 | 经验需求、卡牌绘制 |
| progression/war_spirit.gd | 战意、升级、选项与选择结算 | 直接控制角色或箭矢 |
| progression/skill_data/catalog.gd | 技能名称与说明 | 技能运行逻辑 |
| world/encounter_director.gd | 道路进度、刷怪组、精英关口与结束条件 | 敌人攻击细节 |
| world/road.gd | 道路速度、滚动距离、路障与路边参照物 | 精英决策 |
| world/scenery.gd | 读取道路距离，绘制分层远景与固定太阳 | 单独累积另一套世界速度 |
| ui/hud.gd / upgrade_panel.gd | 展示状态、所有头顶血条与普通怪目标点、发出选卡意图 | 修改伤害或技能等级 |
| asset/runtime/effects/archery/ | 消费撒放/命中/击杀/护盾/选卡信号，短命特效、授权音频本地回退、循环音、暂停与重开清理 | 创建箭矢、计算伤害或修改AI |
| asset/runtime/ + asset/previews/ + asset/tools/ | 美术图集、SpriteFrames、视觉/烟尘试样和资产级预览验证 | 修改玩法碰撞、绕过统一暂停 |

## 数据与时钟

- main 显式注入模块引用。敌人死亡 → Combat 的 enemy_killed 信号 → 构筑回血、战意收益、关卡推进。界面选卡 → WarSpirit → RunBuild → 必要时通知 Rider。
- 所有玩法由 main 统一推进；选卡、死亡与结束阻止后续子步。单帧拆成最多 1/60 秒子步，严重卡顿最多补算 0.25 秒，避免一次跨越碰撞区；这不是联网确定性模拟。
- 冲锋把道路目标速度提升到基础的 1.8 倍，平滑加减速。地面、路障、普通怪的相对移动和远景共享道路来源。Rider 从 asset/runtime 的 SpriteFrames 手动选帧，烟尘也由 step 推进，无自主动画时钟；选卡/死亡/结束一起冻结，重开清空。角色屏幕横坐标不变；攻击预警、冷却、精英动作仍按实际游戏时间推进。
- Road 显示的是按基础速度折算的剩余路程，不再是墙钟倒计时。到中点触发一次精英；精英战冻结关卡进度与普通怪刷新，但道路画面继续滚动。
- WarSpirit 和 EncounterDirector 各持有导出的 Resource 配置；main 的 `reset_run()` 从资源重置运行态。改数值/阵型在 `.tres`，改机制在脚本；`WavePattern.enemies` 长度就是每波普通怪数，Director 依车道轮换生成。
- Combat 持有敌人/箭矢节点，死亡只结算一次；离场普通怪不奖励、不继续攻击，其残留敌箭清理。重开清理所有运行节点，包括等待删除的节点，重置构筑、经验、道路和精英脑状态。

骑手部件由Visual子节点绘制；AutoBow的抓箭/搭弓/拉弓/撒放状态跟随combat.step，撒放阶段只创建一次齐射。首次攻击需完成准备（基础约0.44秒），持续射击周期沿用配置。箭起点由Rider.arrow_origin读取视觉锚点；图集边界不用于碰撞。

## 精英 AI：选动作与执行动作分开

只在动作结束后的决策点评分，而不是持续读取玩家输入改招。同道更倾向冲撞；距离较远时投矛更有吸引力；错道提高换位评分。动作具有冷却、重复惩罚及连续重复上限，没有可用动作则短暂等待。

选择冲撞后：换道 → 红色锁道预警 0.9 秒 → 冲撞 → 退开 → 绿色破绽 1.8 秒 → 回位。成功对冲延长破绽到 2.4 秒。选择投矛后：锁定当时车道 → 紫色瞄准 0.95 秒 → 发射一次 → 收招回位。预警后不追踪玩家的新车道。

这是小型评分决策加显式状态执行，不是完整行为树系统。普通弓手仍使用原有固定预警逻辑。借鉴参考：[LimboAI](https://github.com/limbonaut/limboai) 的冲锋、游击与远程示例拆分，以及 [Godot Utility AI](https://github.com/Pennycook/godot-utility-ai) 的评分选动作思路。将来敌人种类与动作组合显著增加，再评估插件，不为当前 Demo 增加依赖。

## 下次怎么扩展

1. 新敌人：新增独立场景；复用 Enemy 的生命、燃烧和信号约定；在 Combat 注册生成入口，再将种类加入 `WaveEnemy` 可选值及阵型资源。不要把动作写回 main 或 Director。
2. 新精英动作：Brain 增加评分与冷却；Elite 增加执行状态、预警和收招；测试锁定后不追踪、单次结算、暂停和重开。Boss 以后独立做场景，不向 Elite 堆 Boss 专用分支。
3. 新技能：补 Catalog 文案、RunBuild 等级与公式，再由对应战斗模块消费；弓箭数值放进 BowConfig，行为仍留在脚本。若改变选卡供给，单独修改 WarSpirit。目前不是完全数据驱动技能系统。
4. 替换美术：优先替换各场景的局部绘制，保留脚底与攻击点约定；不要用贴图尺寸反推玩法碰撞。路障目前仍由 Road 的轻量字典管理，没有为每个装饰物创建节点。

## 验证入口

在 prototype 目录使用 Godot 可执行文件运行 `--headless --path . --script res://tests/<文件名>`。

| 文件 | 检查范围 | 项数 |
|---|---|---|
| test_combat.gd | 索敌、伤害、普通怪预警/离场、冲锋、刷新 | 18 |
| test_elite.gd | 精英预警、冲撞、反击、练习与道路流程 | 19 |
| test_growth.gd | 战意、暂停、选卡、技能、进化、共享弓箭配置与重开 | 20 |
| test_integration.gd | 模块连接、节点清理、AI 决策与锁定、速度、完整构筑流程 | 17 |
| test_raider.gd | 固定/移动怪、换道锁定和暂停、混合阵型、冲刺免伤边界 | 15 |
| test_run_config.gd | Resource 可覆盖、战意与费用、波次/精英配置、完整道路理论预算 | 14 |
| test_archery_feedback.gd | 撒放/命中/击杀反馈、暂停、重开及并发 | 20 |
| test_licensed_audio.gd | 本机授权WAV映射、马蹄/环境/护盾/UI与回退；需要先导入素材包 | 13 |

五组玩法检查共89项；test_horse.gd 另有10项主场景动画/烟尘、跳跃、换道、暂停、重开检查，test_rider_animation.gd 有18项，配置专项14项，加敌人美术27项，共158项。preview_rider.gd导出四动作、上路跳跃和运行序列。preview_horse.gd 输出跑步/跳跃/冲刺原生截图。preview_elite.gd、preview_growth.gd 与 preview_raider.gd 必须带图形运行，用于截图检查。自动测试不替代真人手感验收；完整流程测试会自动选卡并补生命，配置专项也只计算理论全清，不代表难度已通过。

仍未完成：Boss、随机卡池/刷新/进化保底、Esc 暂停菜单、完整正式美术音效、局外成长与商业化。

## 敌人美术适配

四个敌人场景导出SpriteFrames/visual_size，从asset/runtime/characters/enemies引用透明PNG的AtlasTexture。Enemy.step_status推进visual_clock，_draw按现有弓手预警/已发射状态选择姿势；Elite仅覆盖visual_animation映射状态。资源只替换局部绘制，保留hit_center、车道移动、AI承诺、攻击事件、数值与刷怪表。普通怪血条/目标点迁到HUD统一UI层，避免被角色图集遮挡；状态特效/预警仍由敌人绘制。test_enemy_art验证27项，preview_enemy_art检查实际渲染并断言血条像素。

## 撒放、命中与击杀反馈

main连接AutoBow.released、Combat.hit_confirmed/enemy_defeated、Rider.shield_blocked和WarSpirit.upgrade_opened/choice_confirmed到独立ArcheryFeedback，统一step推进寿命，并在每帧及refresh_views同步选卡/死亡/结束暂停至玩法音频通道。马蹄和草地循环声也仅随main step运行，跳跃停蹄声、冲锋提高音调；UI提示音在选卡暂停中可以播放。reset_run清空视觉与声音。Combat死亡位置在节点清理前发出；命中点取实际扫掠段最近点，未命中不出反馈。声音仅是表现，不影响伤害与奖励；6个短声通道/48视觉事件上限，组内短冷却抑制箭雨叠音。本地Ovani 7段WAV通过导入脚本复制到Git忽略目录；弓弦/命中缺失时回退合成音。专项test_archery_feedback20项、test_licensed_audio13项，当前共191项。
