# 2026-09-23 / v003 · 素材库与美术方向

- 日期与时区：2026-09-23，Asia/Shanghai
- 当日版本：v003
- 状态：已交付，方向待用户选择
- 关联前版：[v002](../v002/CHANGELOG.md)
- 用户目标：资源统一放入 asset，并提供多个效果图。

## 本轮实际变更

建立 prototype/asset；下载 alizard CC0 马匹三组原始 PNG，记录来源、实际尺寸与 SHA-256。使用内置 image_gen 生成 A 晴日草原、B 暖秋山林、C 青雾古道三张概念图，归档完整提示词。登记其他候选素材，未购买其他包。sources 与 concepts 增加 .gdignore，避免误导入。

## 涉及文件

- [素材库说明](../../../prototype/asset/README.md)、[候选清单](../../../prototype/asset/CATALOG.md)
- [马匹来源](../../../prototype/asset/sources/alizard_pixel_horse/SOURCE.md)、[校验清单](../../../prototype/asset/sources/alizard_pixel_horse/files.json)
- [完整提示词](../../../prototype/asset/concepts/PROMPTS.md)
- [A](../../../prototype/asset/concepts/a_meadow.png)、[B](../../../prototype/asset/concepts/b_autumn.png)、[C](../../../prototype/asset/concepts/c_mist.png)
- [根索引](../../../README.md)、[版本索引](../../README.md)

## 行为变化与兼容性

未改玩法脚本与场景，游戏仍是原灰盒；未新增插件。本任务没有执行提交或发布。

## 验证

- python3 标准库下载检查：三张原件 PNG 尺寸为 410×66、574×66、328×66。
- python3 -（stdin 标准库脚本）：读取六张 PNG 签名与 IHDR，核对三项 SHA-256，检查本轮 Markdown 相对链接和两处 .gdignore，全部通过。
- 目视检查工具返回三图：均有三条水平道路、一个玩家和同构图敌人分布。
- 未跑 Godot 玩法测试或原生截图：本轮未改运行逻辑；生成概念图不能代替游戏渲染验证。

## 未完成、风险与下一步

待选择方向后进行一屏真实素材验证。概念图并非原素材无损合成，未逐像素匹配 480×270，敌方弓手朝向需落地修正。骑手/跳跃/精英动作、三车道路面、技能图标仍需制作。公开仓库不得随意加入禁止独立再分发的候选原件，采用时须核对完整条款。
