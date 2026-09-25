# 分层骑手 · Demo接入

当前皮肤：`skins/adventurer/rider_skin.tres`。使用Godot原生AtlasTexture拆分透明图集，无需运行时抠图、插件或额外下载。原PNG保持不变，来源/完整提示词见[生成记录](../../../concepts/rider_parts_prompts.md)。

## 已拆分资源

- `rider_head.tres`：头、头发、头巾整体。
- `rider_body.tres`：躯干、骑姿双腿、靴子。
- `rider_quiver.tres`：背部箭袋；皮肤quiver字段可留空。
- `rider_saddle.tres` / `rider_stirrup.tres`：鞍具和近侧镫带/马镫。
- `rider_arms_grab/nock/draw/release.tres`：抓箭、搭弓、拉弓、撒放，每组手臂与弓配套；撒放图无箭。
- `rider_parts_manifest.json`：源图区域与马帧偏移，搭弓使用第二张修订源图，其余部件使用首版。

这些.tres是可单独引用的纹理资源，不是九张导出的PNG。弓弦与双臂按姿势配套，当前换弓需配套替换四组手臂，不支持任意武器实时拼接。

## 使用与换皮

`player/rider.tscn`的Visual节点引用`player/rider_visual.gd`。Inspector中的skin为RiderSkin资源，可替换整套，或复制为新皮肤再改head等字段。新头部保持相同虚拟尺寸/颈部位置，不能直接塞入任意尺寸肖像。当前仅交付A皮肤，没有游戏内皮肤菜单。

视觉脚本负责各部件绘制位置、6个马帧的小幅鞍点修正、冲刺/跳跃时上半身前移、受伤透明闪烁。没有自主_process或自动播放，动画由共享时钟推进。近侧靴镫已做对齐；远侧镫和躯干大幅俯仰仍是可精修项，不宣称完整骨骼骑姿系统。

AutoBow控制四动作及撒放事件，比例25%/20%/35%/20%。基础首发准备约0.44秒，连续撒放间隔仍为0.55秒（连射I/II为0.451/0.363秒）。目标消失时停在拉弓；重新出现合法目标再撒放。飞行箭由Combat创建，视觉贴图里的箭不参与碰撞；多重/箭雨每次撒放统一结算。

实际箭起点使用Rider.arrow_origin，跟随鞍点、跳跃和上半身偏移。头部换装只改外观，不改HP/伤害/命中范围。

## 预览与限制

- [真实运行GIF](../../../concepts/rider_demo_preview.gif)：Godot原生渲染；为展示连续射击，脚本将一个敌人的生命设为999。
- `res://tests/preview_rider.gd`：四姿势、上路跳跃与66帧真实游戏推进截图到user://。
- `res://tests/test_rider_animation.gd`：18项；原有六组测试99项，本轮共117项。

当前是4个关键姿势切换，没有声称细腻补间或逐像素人工精修完成。两张生成图集内仍包含未使用区域，后续可在美术工具中打包精简。
