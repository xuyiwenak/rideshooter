# 搞笑轻松风 · 第一批资源拆分

当前方向：A 草原构图，角色走大眼、夸张表情和玩具般比例。嘻哈马固定特征：大门牙、吐舌头、黄金鼻环、粗金链子、黄鬃毛、黑尾巴。背景降低细节，不继续采用严肃写实骑士作为风格标准。

## 画面与资源职责

三条跑道共享一块连续土路；只有两条低对比边界，不能用三条横线造成四路错觉。引擎内应从相邻 LANE_Y 的中点计算两条边界，不把整幅概念图硬切成三张道路。A v3 只验证构图；还不是精确的 480×270 游戏排布。

| 拆分对象 | 目标运行文件名（未完成的仅作规划） | 状态 / 获取方式 |
|---|---|---|
| 天空 | meadow_sky.png | 待制作，独立背景 |
| 远山、近丘 | meadow_hills_far.png / meadow_hills_near.png | 下方候选包；需要横向无缝 |
| 远处树林 | meadow_trees_far.png | 待选；简化轮廓避免抢角色 |
| 共享土路 | meadow_road_base.png | 待制作；不烘焙第三条内部横线 |
| 路外草边 | meadow_grass_border_top.png / meadow_grass_border_bottom.png | 待制作；不在三路中间放草带 |
| 嘻哈马奔跑 | horse_hiphop_run_sheet.png / horse_hiphop_sprite_frames.tres | 已完成 6 帧可播试样；仍需用户验收造型/节奏 |
| 马蹄烟尘 | hoof_dust.tscn | 原生 CPUParticles2D 试样，独立于马；不是烘焙动画 |
| 骑手 | rider_idle_sheet.png / rider_shoot_sheet.png | [设计方案已建立](rider_design.md)，A/B/C概念板已完成；[分层资源已接入Demo](runtime/characters/rider/README.md)，四动作由实际射击驱动 |
| 四类敌人 | enemies/*/*_sheet.png / *_sprite_frames.tres | [林地劫匪已接入](runtime/characters/enemies/README.md)，保留原AI与碰撞 |
| 路障 | obstacle_wood.png | 待选/绘制，保持低矮可跳 |
| 箭矢 | arrow_normal.png | 待制作；清晰小轮廓 |
| HUD | hud_panel.png / skill_shield.png 等 | 待选；技能图标按实际技能语义命名 |

## 这轮查到的候选（2026-09-23）

| 候选 | 页面确认内容 | 适配判断 / 限制 |
|---|---|---|
| [Pixel Horses / ivqnyshkq](https://ivqnyshkq.itch.io/pixel-horses) | 4 配色；idle/run；PNG 图集和 GIF；$1.99；允许使用及修改，禁止单独转售 | 可爱像素马备选，但未核实有吐舌、门牙、金链动作；未购买 |
| [Horse 2D Game Character Sprites / DionArtworks](https://www.codester.com/items/7856/horse-2d-game-character-sprites) | PNG、AI/EPS、Spriter；idle/run/walk/attack/hurt/dizzy/jump/die；700×700；页面 Regular $12 | 卡通路线候选，非像素统一风；需核对完整商业许可证与可修改条款；未购买，不直接引入 Spriter 插件 |
| [Grassy Mountains / vnitti](https://vnitti.itch.io/grassy-mountains-parallax-background) | 384×216，透明分层 PNG 和 PSD；作者称条款在包内，评论说明商用可购买或署名 | 草原远景候选；未下载、包内许可待核对；像素尺寸需适配 |
| [Free Smoke Fx Pixel 2 / BDragon1727](https://bdragon1727.itch.io/free-smoke-fx-pixel-2) | 70+ 烟雾效果；非商业免费；商用需任意金额捐赠；允许修改，禁止再分发 | 像素尘团备选；当前先用自有原生粒子，避免公开仓库纳入受限原件 |

没有把任何现成包宣称为“已包含大眼吐舌嘻哈马”。本轮以生成的新角色试样探索这组明确造型，其他候选只作可替代来源。
