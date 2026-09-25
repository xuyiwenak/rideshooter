# 战意、构筑与文案

- war_spirit.gd：战意收益、升级门槛、溢出、待选次数、选项供给与选择结算。
- 战意击杀奖励、首次升级费用、逐级费用增量来自 `../config/progression/growth_default.tres`；不要在脚本里另设重复常量。重开时 `WarSpirit.reset()` 从资源读取首级费用。
- run_build.gd：技能等级、进化、技能效果公式、击杀回血和构筑预设。
- 弓箭的可调数值统一来自 `../config/weapons/bow_default.tres`；不要在构筑脚本重复硬编码射速倍率。
- skill_data/catalog.gd：名称和描述，不运行技能逻辑。
- 技能效果由玩家/自动弓等模块消费；不要通过选卡 UI 直接改伤害。
- 当前为固定路线供卡，不是随机卡池；不要误报刷新、保底已经实现。
- 新技能同时检查上限、文案、升级效果、暂停、重开与进化前后行为。
- 验证 test_growth、test_integration、test_run_config；射击/护盾变化再查 test_combat 和 test_raider。
