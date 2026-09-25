# 2026-09-25 / v003 · 四类林地劫匪接入Demo

- 日期与时区：2026-09-25，Asia/Shanghai。
- 当日版本：v003。
- 状态：已交付，可运行美术试样。
- 关联前版：[v002概念设计](../v002/CHANGELOG.md)。
- 用户目标：匹配现有游戏框架，把怪物资源加入Demo。

## 本轮实际变更

1. 内置image_gen生成四张透明运行图集：锅盔打手4帧、紫兜帽弓手4帧、橙围巾追击兵4帧、野猪骑长6帧。精英图额外做透明底修订。PNG原始像素保留，由Godot AtlasTexture切区域及留白；四包带SpriteFrames和含SHA256的manifest。
2. 四个现有敌人场景分别引用对应SpriteFrames与显示画布。Enemy共用visual_clock由step_status推进；弓手按warning/fired切瞄准与空弓撒放；Elite按已有状态映射投矛、空手撒放、冲撞和吐舌喘气破绽姿势。
3. 角色统一朝左、nearest采样、方形画布、脚底基准y=55/64，显示脚底局部y=4；普通显示画布48/52，精英72。耳朵和武器外轮廓不扩大碰撞。
4. 普通怪血条/目标点从Enemy迁入HUD统一显示，与精英血条共用UI层，避免角色图集重叠遮挡。燃烧/受击与攻击预警保留在原角色中。
5. 新增27项敌人美术检查与真实main原生预览脚本，归档四状态截图及72帧GIF；同步模块职责、用户运行说明、资源目录与索引。

## 涉及文件

- [四类运行资源](../../../prototype/asset/runtime/characters/enemies/README.md)、[完整生成提示词](../../../prototype/asset/concepts/enemy_runtime_prompts.md)。
- [Enemy](../../../prototype/enemies/enemy.gd)、[Elite](../../../prototype/enemies/elite/elite.gd)、四类`.tscn`、[HUD](../../../prototype/ui/hud.gd)。
- [专项测试](../../../prototype/tests/test_enemy_art.gd)、[原生预览](../../../prototype/tests/preview_enemy_art.gd)。
- [实际场景合影](../../../prototype/asset/concepts/enemy_art_overview.png)、[瞄准](../../../prototype/asset/concepts/enemy_art_aim.png)、[锁道](../../../prototype/asset/concepts/enemy_art_locked.png)、[破绽](../../../prototype/asset/concepts/enemy_art_open.png)、[运行GIF](../../../prototype/asset/concepts/enemy_demo_preview.gif)。

## 行为变化与兼容性

玩法仍是三车道自动骑射；未修改AI评分/承诺车道、碰撞中心、箭矢创建、伤害、数值配置、刷新表和击杀奖励。选卡、死亡、完成统一停止动画，重开删除旧敌人节点。无插件或外部代码依赖；不是第三方CC0包，没有购买素材，也没有创建Git提交。

## 验证

本轮使用`/Users/evan/Desktop/Godot.app/Contents/MacOS/Godot`，4.7.2 Compatibility，从仓库根执行：

```sh
GODOT_BIN=/Users/evan/Desktop/Godot.app/Contents/MacOS/Godot
"$GODOT_BIN" --headless --path prototype --editor --import
for name in combat elite growth integration raider horse rider_animation run_config enemy_art; do
  "$GODOT_BIN" --headless --path prototype --script "res://tests/test_${name}.gd"
done
"$GODOT_BIN" --headless --path prototype --script res://asset/tools/verify_horse_animation.gd
"$GODOT_BIN" --path prototype --script res://tests/preview_enemy_art.gd
"$GODOT_BIN" --path prototype --script res://asset/tools/render_horse_preview.gd
git diff --check
```

- 导入成功，无解析/运行错误。所有测试本轮实际重跑：18+19+20+17+15+10+18+14+27=158/158。
- 马匹资产检查通过；原生马预览观察到6/6帧并检查截图。
- 原生敌人预览退出0；检查四类朝向、大小、透明边缘及红色锁道/绿色破绽等截图；脚本同时断言三种普通怪的血条像素可见。
- 原生main脚本输出72帧960×540序列；ffmpeg按30FPS，split/palettegen/paletteuse导出2.4秒GIF。脚本人工安排四类同屏，并提高敌人生命、关闭成长暂停用于观察；不是正常关卡刷怪布局或通关录像。
- `git diff --check`通过。另检查资源manifest的SHA256、源尺寸、帧边界、命名以及本轮文档链接。
- 没有进行真人完整通关或难度验收；本次只验证资源接入与原有自动玩法回归。

## 未完成、风险与下一步

生成循环存在帧间形变，精英冲撞/破绽等目前是状态关键姿势，并非完整精修动作；没有独立死亡/受击序列。背景和箭矢仍使用现有灰盒绘制；没有新增Boss、多副本、换肤菜单。后续可据实际试玩反馈统一像素密度并精修跑步与攻击衔接。
