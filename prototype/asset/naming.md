# Godot 美术资源组织与命名

核验日期：2026-09-23。此规则针对本项目资源，目录根固定为 `res://asset/`。

## 官方与项目实例

- [Godot 4.7 项目组织](https://docs.godotengine.org/en/4.7/tutorials/best_practices/project_organization.html)：推荐目录/文件使用小写 snake_case，避免跨系统大小写差异；参考资料目录可用 `.gdignore` 排除。
- [官方 Platformer 2D](https://github.com/godotengine/godot-demo-projects/tree/master/2d/platformer)：通过 GitHub contents API 核对，player/ 中放 player.tscn、player.gd、robot.webp、jump.wav；enemy/ 中放 enemy.tscn、enemy.webp、hit.wav。相关文件按对象聚合。
- [官方 Dodge the Creeps](https://github.com/godotengine/godot-demo-projects/tree/master/2d/dodge_the_creeps)：顶层有 art/、fonts/，场景脚本另放。表明 Godot 没有唯一强制资源目录树。
- 本项目保留既有 gameplay 模块，将美术统一放 asset，再按对象/环境主题分组。没有复制示例工程代码或素材。

## 强制采用的项目规则

1. 运行资源的目录和文件用 ASCII 小写 snake_case：`[a-z0-9_]+`，标准扩展名小写；不用空格、中文、括号、连字符，也不用仅大小写不同的两个名字。现有 README.md、AGENTS.md 等文档约定不强行迁移。
2. 命名表达对象和用途，例如 `horse_hiphop_run_sheet.png`、`horse_hiphop_sprite_frames.tres`、`hoof_dust.tscn`。不用 `final_final`；只有设计历史图保留 `_v2`、`_v3`。
3. 单张透明图 PNG；图集 `_sheet.png`；SpriteFrames 配置 `_sprite_frames.tres`；可实例化的视觉节点 `.tscn`。图层名用 `far`、`near`、`border_top` 等职责，不用难理解的 `layer_1_final`。
4. 文件名不会让 Godot 自动识别帧率、动画或碰撞。帧区域、顺序、帧率和循环写入 SpriteFrames；每组源尺寸/锚点另记 manifest。动画键统一 `idle`、`run`、`jump`、`hurt`；尚未画好的动作不能建空资源冒充已完成。
5. 源图和概念图留在带 `.gdignore` 的 sources/、concepts/；runtime/ 不放 `.gdignore`。预览场景放 previews/；资产检查工具放 tools/。
6. `.godot/` 由引擎生成，不手工编辑或提交缓存；`.import` 是导入配置，`.uid` 由 Godot 管理。已被场景引用的文件在 Godot 内移动，并复查引用；不靠全局改名修复。
7. 像素图使用 nearest 采样，透明 PNG 保留 alpha。实际帧画布与可见身体尺寸分开记录，脚底锚点固定；不按透明边界推导碰撞盒。

## 当前可用试样

```text
asset/runtime/
├── characters/horse_hiphop/
│   ├── horse_hiphop_run_sheet.png
│   ├── horse_hiphop_sprite_frames.tres
│   ├── horse_hiphop_run_manifest.json
│   └── horse_hiphop.tscn
└── effects/hoof_dust/
    └── hoof_dust.tscn
```

本组 6 帧、8 FPS、循环，朝右。源图 1536×1024、3×2；各 AtlasTexture 输出统一 512×512 虚拟画布，脚底基准 440。源 PNG 未修改，裁切区域依 alpha>200 的实体范围配置，底部边距对齐。视觉场景默认约 80×80 画布，实际主体较小，主游戏绘制为 72×72 虚拟画布，脚底位于 Rider 局部 y=9。

预览会自主播放；视觉节点本身不自动播放。接入主游戏时必须由现有统一时钟/暂停控制动画及烟尘；主游戏已在 Rider 中实现选卡暂停、离地停尘、落地短喷、冲刺加量和重开清理；该处使用手动推进的尘团，不直接播放独立 CPUParticles2D 预览。

原生类型参考：[SpriteFrames](https://docs.godotengine.org/en/stable/classes/class_spriteframes.html)、[图片导入](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_images.html)。
