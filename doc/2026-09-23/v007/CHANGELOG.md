# 2026-09-23 / v007 · 嘻哈马接入主游戏

- 日期与时区：2026-09-23，Asia/Shanghai
- 当日版本：v007
- 状态：已交付
- 关联前版：v005 动画试样；v006 弓箭配置继续保留
- 用户目标：检查已有素材，先把马加到游戏里。

## 本轮实际变更

Rider 复用现有 6 帧 SpriteFrames，替换方块马；8 FPS 跑步、冲刺 1.6 倍播放速度。虚拟画布72×72，脚底仍在局部y=9。保留原碰撞、箭矢起点、三车道和骑手占位绘制。未改源PNG。

烟尘由 Rider.step 手动推进、在世界位置留下痕迹；普通间隔0.12秒，冲刺0.06秒，尘团寿命0.45秒。离地停止发尘、保持当前跑姿，落地短喷3团。选卡、死亡和结束冻结动画和烟尘，重开清零。原 CPUParticles2D 场景保留为独立美术预览，主游戏不自主播放粒子。

## 涉及文件

- [rider.gd](../../../prototype/player/rider.gd)
- [test_horse.gd](../../../prototype/tests/test_horse.gd)
- [preview_horse.gd](../../../prototype/tests/preview_horse.gd)
- 根/工程/资源 README、ARCHITECTURE、player/tests AGENTS、资源命名与目录状态。

## 验证

Godot 可执行文件：`/Users/evan/Desktop/Godot.app/Contents/MacOS/Godot`，从仓库根执行。

- `Godot --headless --path prototype --script res://tests/test_combat.gd`：18/18。
- 相同命令分别运行 test_elite.gd 19/19、test_growth.gd 20/20、test_integration.gd 17/17、test_raider.gd 15/15；本轮重跑共89/89。
- `Godot --headless --path prototype --script res://tests/test_horse.gd`：10/10。通过真实 main.tscn 检查全部跑帧、真实等待期间暂停、恢复、跳跃停尘/定格、落地、冲刺、换道尘团留地、死亡/结束、重开。
- `Godot --headless --path prototype --script res://asset/tools/verify_horse_animation.gd`：PASS。
- `Godot --path prototype --script res://tests/preview_horse.gd`：Compatibility原生渲染跑步、跳跃、冲刺三图成功；查看了三个PNG，透明背景正常、脚底和阴影对齐、尘团留地。截图在user://horse_game_run.png、horse_game_jump.png、horse_game_sprint.png。
- `Godot --path prototype --script res://asset/tools/render_horse_preview.gd`：独立预览再次原生渲染成功，观察帧数6/6；已查看首帧。`git diff --check`通过。
- 没有真人手感验收；测试场景人为安排敌人并延后自动射击以观察角色。

## 未完成、风险与下一步

马是生成动画试样，帧间身体形态有变化，仍可精修；跳跃没有专用动画。骑手及环境仍是灰盒，美术统一和连续土路背景替换留待下一批。没有购买、提交或发布资源。
