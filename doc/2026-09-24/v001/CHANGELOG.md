# 2026-09-24 / v001 · 分层骑手与四动作接入Demo

- 日期与时区：2026-09-24，Asia/Shanghai
- 当日版本：v001
- 状态：已交付Demo试样
- 关联前版：2026-09-23/v011四姿势设计
- 用户目标：拆分素材并加入Demo。

## 实际变更

1. 使用内置image_gen将概念造型转为透明部件图集，另修订搭弓手势。保留原始RGBA像素，AtlasTexture区域引用拆分头部、身体、箭袋、鞍具、马镫和四套手臂/弓。
2. 新增RiderSkin资源与RiderVisual子节点，取代方块骑手。头发/头巾随头部整体，背部箭袋可空。马6帧各有小幅位置修正，冲刺/腾空上半身前移，受伤闪烁随共享时钟。
3. AutoBow按抓箭→搭弓→拉弓→撒放循环，只在撒放创建一次齐射。目标消失时保持拉弓，再次出现合法目标才发射。
4. 箭出生点改为视觉弓口锚点，包含跳跃与马帧偏移。右上方HUD留出玩家列，解决上车道跳跃时头部被顶栏盖住。

## 文件

- [资源说明与换肤入口](../../../prototype/asset/runtime/characters/rider/README.md)
- [生成来源与完整提示词](../../../prototype/asset/concepts/rider_parts_prompts.md)
- [rider_visual.gd](../../../prototype/player/rider_visual.gd)、[rider_skin.gd](../../../prototype/player/rider_skin.gd)
- rider.gd/rider.tscn、auto_bow.gd、ui/hud.gd
- [test_rider_animation.gd](../../../prototype/tests/test_rider_animation.gd)、[preview_rider.gd](../../../prototype/tests/preview_rider.gd)
- 根/工程/资源README、设计状态、ARCHITECTURE、player/ui/tests指引及索引。

## 行为与兼容性

基础第一次射击增加约0.44秒准备，连续撒放间隔仍为0.55秒；连射I/II为0.451/0.363秒。四段比例25%/20%/35%/20%。没有新增独立_process、插件、左/右自由移动或改动命中范围。视觉皮肤不含HP/伤害数值。

拆分产物是Godot可直接引用的.tres纹理，不是九张导出PNG。手臂和弓按姿势一起制作，未来更换弓需匹配四姿势；只有A皮肤，没有游戏内换肤界面。近侧马镫已接入，远侧镫与细腻补间尚待精修。

## 本轮验证

可执行文件：`/Users/evan/Desktop/Godot.app/Contents/MacOS/Godot`；工作目录为仓库根。

- `Godot --headless --path prototype --editor --import --quit`：通过，无解析错误。
- `Godot --headless --path prototype --script res://tests/<name>.gd`：test_combat 18/18、test_elite 19/19、test_growth 20/20、test_integration 17/17、test_raider 15/15、test_horse 10/10、test_rider_animation 18/18；本轮合计117/117。
- 新测试覆盖抓箭/搭弓/拉弓不提前出箭、撒放一次、跳跃弓口、选卡暂停（含真实等待）/恢复、重开、三种射速、目标消失/恢复、进化齐射、换Resource和空背部槽不改玩法、死亡冻结。
- 首次旧测试发现初始化阶段onready引用未赋值，改为访问现有Visual节点的getter后通过，未删改原断言。
- `Godot --path prototype --script res://tests/preview_rider.gd`：原生Compatibility渲染四动作、上路跳跃，另推进66帧主游戏并导出。查看截图；修订搭弓与拉弓区别、脚镫对齐及顶栏遮挡。实际运行图已显示撒放飞行箭。
- `Godot --headless --path prototype --script res://asset/tools/verify_horse_animation.gd`：PASS。
- `Godot --path prototype --script res://asset/tools/render_horse_preview.gd`：6/6动画帧被观察到。
- ffmpeg以60FPS输入实际66帧，20FPS输出[运行GIF](../../../prototype/asset/concepts/rider_demo_preview.gif)。预览将一个敌人的生命设置999以展示连续射击，其余通过实际main._process推进。
- PNG/GIF格式、资源路径与Markdown本地链接检查；git diff --check。
- 没有真人手感验收，未将自动测试等同于难度平衡通过。

## 限制与后续

当前是4关键姿势切换，远侧遮挡、马背形变匹配、头部及手部小像素轮廓仍可精修；不宣称已完成人工逐像素正式动画。源图未作紧凑打包。环境和敌人依旧灰盒。没有购买、提交或发布。
