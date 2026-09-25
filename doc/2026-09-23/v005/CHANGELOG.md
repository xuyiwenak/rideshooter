# 2026-09-23 / v005 · 嘻哈马动画试样与资源规范

- 日期与时区：2026-09-23，Asia/Shanghai
- 当日版本：v005
- 状态：已交付试样，未接入主游戏
- 关联前版：[v004](../v004/CHANGELOG.md)
- 用户目标：三条跑道清晰、马蹄烟尘；按引擎规范管理素材；改为搞笑轻松画风，并绘制大眼吐舌、门牙、金鼻环、大金链和黄鬃毛的动画。

## 本轮实际变更

1. 内置 image_gen 编辑 A v3，去除多余中间车辙，只保留两条淡分界，加入烟尘概念。
2. 搜索可爱/卡通马、山景与烟尘素材，明确未找到已核实同时满足全部指定特征的现成包；未购买任何素材。
3. 内置 image_gen 生成并按用户追加要求修改 6 帧嘻哈马图集；原 PNG 保持不变，通过 AtlasTexture 区域/边距配置统一画布及脚底。
4. 新增 SpriteFrames、无自主播放的马视觉场景、独立 CPUParticles2D 烟尘和可播放预览场景，生成原生渲染 GIF。
5. 参考 Godot 官方规范和两个官方 Demo 的实际目录，形成小写 snake_case 命名、资源分组、拆分候选文档；新增 asset/AGENTS.md。

## 涉及文件

- [素材入口](../../../prototype/asset/README.md)、[命名规范](../../../prototype/asset/naming.md)、[拆分及候选](../../../prototype/asset/asset_breakdown.md)
- [A v3](../../../prototype/asset/concepts/a_meadow_v3.png)、[生成提示词](../../../prototype/asset/concepts/horse_hiphop_prompts.md)
- [图集](../../../prototype/asset/runtime/characters/horse_hiphop/horse_hiphop_run_sheet.png)、[SpriteFrames](../../../prototype/asset/runtime/characters/horse_hiphop/horse_hiphop_sprite_frames.tres)、[帧参数](../../../prototype/asset/runtime/characters/horse_hiphop/horse_hiphop_run_manifest.json)
- [马视觉场景](../../../prototype/asset/runtime/characters/horse_hiphop/horse_hiphop.tscn)、[烟尘](../../../prototype/asset/runtime/effects/hoof_dust/hoof_dust.tscn)
- [预览场景](../../../prototype/asset/previews/horse_hiphop_preview.tscn)、[动态GIF](../../../prototype/asset/concepts/horse_hiphop_run_preview.gif)
- [资产验证](../../../prototype/asset/tools/verify_horse_animation.gd)、[原生渲染](../../../prototype/asset/tools/render_horse_preview.gd)
- 根 README、doc/README、prototype/ARCHITECTURE 与素材目录说明同步；Godot 自动生成相关 .uid 和 .import，未手动修改缓存。

## 行为变化与兼容性

独立试样可播，主游戏脚本和 main.tscn 未修改。6 帧、8 FPS、循环朝右；原始生成 PNG 1536×1024，3×2 帧；AtlasTexture 输出 512×512，脚底基准 440。无额外插件。预览不等于玩法接入。

## 验证

以下 GODOT_BIN 为本机实际安装的 Godot 4.7.2 可执行文件；均在仓库根执行。

```sh
"$GODOT_BIN" --headless --editor --path prototype --quit
"$GODOT_BIN" --headless --path prototype --script res://asset/tools/verify_horse_animation.gd
"$GODOT_BIN" --path prototype --script res://asset/tools/render_horse_preview.gd
```

- 导入成功；资产检查通过：6 个 AtlasTexture、统一画布/脚底、循环动画、预览与烟尘场景可加载。
- 带图形模式在 Compatibility/OpenGL 后端导出 48 帧，观测到全部 6 个动画帧，退出码0。
- 首次目视发现烟尘缺少 Gradient 产生异常色点，已显式补白色 Gradient 并重新渲染检查；最终烟尘为浅土色。
- ffmpeg 以 `-framerate 8`、palettegen/paletteuse、`-loop 0` 将原生截图编码为 GIF，成功。
- python3 标准库/Pillow只读检查：PNG尺寸和透明通道、运行资源 snake_case、文档本地链接；没有用 Python 修改图像。
- 未重跑88项主玩法检查：未修改或连接任何主玩法逻辑。动画连贯性仅为试样级，仍有生成帧间体形变化。

## 未完成、风险与下一步

主场景替换、骑手、跳跃/受击、统一暂停和跑速/落地烟尘联动仍未接入。未来需按主时钟控制，不能让选卡期间独立播放。多副本仍为规划。源 PNG 的透明边缘有半透明像素，现按实体阈值取区域；最终小尺寸像素精修及循环手感待进一步验收。未执行 Git 提交或发布。
