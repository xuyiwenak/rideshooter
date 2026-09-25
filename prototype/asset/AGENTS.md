# 美术资源模块

- 先读 README.md、naming.md 与 asset_breakdown.md。所有实际运行资源使用 ASCII 小写 snake_case。
- sources/ 和 concepts/ 不导入游戏；runtime/ 存原生可用资源，previews/ 只演示，tools/ 做资产级验证。
- 图集配套 SpriteFrames 明确区域、帧率、循环、统一画布和脚底；命名不代替资源配置。保留原始图集像素和来源。
- 独立预览可以自主播放；接入 gameplay 必须遵守 main 的统一暂停、时钟与重开。不可宣称预览等于游戏已接入。
- generated 图片记录工具/提示词/参考许可，不冒充第三方购买素材或已人工精修动画。
- 本地授权音频通过 tools/import_ovani_starter.py 复制到 runtime/audio/sfx/ovani_starter/；原始 WAV 和 .import 已被 Git 忽略。公开仓库只存导入器与映射，不上传原包。
- 修改后跑 tools/verify_horse_animation.gd；视觉变化跑 tools/render_horse_preview.gd 并看原生截图。涉及 gameplay 再跑对应玩法测试。
- 不手改 .godot/ 或 .uid，不自动购买、提交或发布。
