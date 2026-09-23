# 2026-09-23 / v002 · 发布GitHub公开仓库

- 日期与时区：2026-09-23，Asia/Shanghai。
- 当日版本：v002。
- 状态：已交付。
- 关联前版：[v001](../v001/CHANGELOG.md)。
- 用户目标：将当前项目上传到新的Public GitHub仓库 `rideshooter`。

## 本轮实际变更

1. 新增根目录 `.gitignore`，排除Godot缓存、构建产物、编辑器配置、本机环境文件和潜在密钥文件。
2. 将公开文档中的本机绝对路径改为仓库相对路径或通用命令示例。
3. 核对像素马素材的作者、来源和CC0许可，在素材目录补充来源说明。
4. 更新根目录记忆和开发记录索引，登记公开仓库地址。
5. 初始化首次Git提交并推送到 [xuyiwenak/rideshooter](https://github.com/xuyiwenak/rideshooter)，仓库可见性设为Public。
6. 原有私有仓库 `xuyiwenak/game` 未修改。

## 涉及文件

- [忽略规则](../../../.gitignore)。
- [根目录记忆](../../../README.md)、[任务清单](../../../TASK_BREAKDOWN.md)。
- [运行说明](../../../prototype/README.md)、[工程指引](../../../prototype/AGENTS.md)。
- [第三方像素马来源](../../../prototype/asset/sources/alizard_pixel_horse/README.md)。
- [开发记录索引](../../README.md)及本记录。

## 行为变化与兼容性

游戏行为、场景和资源没有变化。Godot生成目录 `prototype/.godot/` 不上传，克隆后首次打开项目时由Godot重建。仓库公开不等于自动授予第三方复用许可；本轮未添加开源许可证。

## 验证

- 敏感信息模式扫描：未发现API Key、访问令牌、私钥或明文密码。
- 公开路径检查：仓库文档不包含本机用户主目录的绝对路径。
- 第三方素材：OpenGameArt素材页核对为作者alizard发布的CC0资源，并补充本地来源记录。
- Godot完整测试：test_combat 18/18、test_elite 19/19、test_growth 19/19、test_integration 17/17、test_raider 15/15，共88/88。
- GitHub：核对仓库可见性为Public、默认分支和远端提交与本地HEAD一致。

## 未完成、风险与下一步

独立Boss、多路Boss技能、随机卡池/刷新/保底、Esc暂停菜单、正式美术音效与局外成长仍未完成。后续每次代码或文档交付按日期版本规则记录并提交；是否添加开源许可证由用户另行决定。
