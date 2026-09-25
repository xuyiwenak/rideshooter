# 2026-09-23 / v006 · 弓箭配置Resource

- 日期与时区：2026-09-23，Asia/Shanghai
- 当日版本：v006
- 状态：已交付，待用户在Inspector体验调参
- 关联前版：[v005](../v005/CHANGELOG.md)
- 用户目标：把弓箭配置单独抽出，便于调整，并采用Godot习惯的配置管理方式。

## 本轮实际变更

1. 新增自定义 `BowConfig` Resource及默认 `.tres`，在Inspector按基础射击、多重、连射、燃烧分组。
2. 自动弓、构筑射速和敌人燃烧统一读取同一份默认配置；移除原共享参数文件中的射击间隔硬编码。
3. 保持当前数值与行为：基础间隔0.55秒、弹速420、同道/邻道伤害1/0.5、多重额外目标1/2、连射倍率0.82/0.66、燃烧原有两级数值。
4. 新增配置目录说明和Codex指引，更新根目录记忆、工程结构、运行说明及相关模块指引。
5. 成长测试新增共享配置资源断言。未实现穿透、暴击、蓄力或新的弓箭进化。

## 涉及文件

- [配置说明](../../../prototype/config/README.md)、[配置规则](../../../prototype/config/AGENTS.md)
- [字段定义](../../../prototype/config/weapons/bow_config.gd)、[默认数值](../../../prototype/config/weapons/bow_default.tres)
- [自动弓](../../../prototype/player/auto_bow.gd)、[构筑](../../../prototype/progression/run_build.gd)、[燃烧消费](../../../prototype/enemies/enemy.gd)
- [成长测试](../../../prototype/tests/test_growth.gd)
- 根README、prototype/README、ARCHITECTURE及相关模块AGENTS同步。

## 行为变化与兼容性

本轮是等值迁移，正常玩法数值与上一版一致。`.tres` 是当前默认弓箭的唯一数值入口；脚本仍负责索敌、弹道、升级和伤害行为。新建其他弓时应复用BowConfig结构并另存资源，而不是复制脚本。

## 验证

- Godot 4.7.2 headless editor导入成功，`BowConfig`全局类和`.tres`成功解析。
- test_combat 18/18、test_elite 19/19、test_growth 20/20、test_integration 17/17、test_raider 15/15，共89/89通过。
- 新断言确认RunBuild、AutoBow与Enemy共享默认BowConfig资源。
- 没有视觉变化，因此未重新运行图形预览。

## 未完成、风险与下一步

穿透、暴击、蓄力、破军巨箭和疾风连弩尚未实现。当前只有一把默认弓，因此没有加入武器选择器或多配置切换。工作区原有v003-v005美术资产改动保持不变，本轮未提交或推送Git。
