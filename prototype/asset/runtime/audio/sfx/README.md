# 骑射音效

本机若拥有 Ovani Sound FX Starter Pack Vol. 1，可用下述命令把 7 段 WAV 放进 Godot 的 `res://asset/runtime/audio/sfx/ovani_starter/`。文件名均为小写 snake_case。弓弦和箭命中优先播放导入素材；缺少素材时沿用原有合成声音。新增护盾、升级、选卡、马蹄和环境声在缺少素材时保持静音，不影响玩法。

```sh
python3 prototype/asset/tools/import_ovani_starter.py "/path/to/Sound FX Starter Pack Vol. 1"
```

| 原包相对路径 | Demo 文件名 | 触发 |
|---|---|---|
| `Medieval/Bow Shoot.wav` | `bow_shoot.wav` | 每次齐射撒放一次 |
| `Medieval/Arrow Hit.wav` | `arrow_hit.wav` | 玩家箭实际命中 |
| `Medieval/Horse Gallop Loop.wav` | `horse_gallop_loop.wav` | 地面骑行；跳跃停，冲锋加快 |
| `Medieval/Shield Block.wav` | `shield_block.wav` | 护盾真实抵挡伤害 |
| `Medieval/Loot Gold.wav` | `loot_gold.wav` | 打开升级三选一 |
| `UI & Menus/Click Bounce.wav` | `click_bounce.wav` | 有效选择卡牌 |
| `Environment/Grassy Field Loop.wav` | `grassy_field_loop.wav` | 草原环境氛围 |

使用该包须由使用者持有自己的授权；包中 PDF 指向 [Ovani 许可条款](https://ovanisound.com/policies/terms-of-service)。原始 WAV 及其 Godot `.import` 文件在 `.gitignore` 中，本公开仓库只保留导入脚本和映射；不要把原始包文件提交或作为独立素材重新发布。Godot 打开工程后会自动导入本机文件。若刚复制后仍听到合成声，重启编辑器或用 `Godot --headless --path prototype --import` 完成导入。

## 原有合成备用声音

本项目程序合成试样，无第三方录音、购买包或克隆人声。生成器：[generate_archery_sfx.py](../../../tools/generate_archery_sfx.py)，仅使用Python标准库，可用`python3 prototype/asset/tools/generate_archery_sfx.py`复现。

| 文件 | 变体 | 时长 | 声音设计 |
|---|---|---|---|
| bow_release_01.wav ～ bow_release_03.wav | 3 | 0.16s | 衰减弦振、短噪声起音 |
| arrow_hit_01.wav ～ arrow_hit_03.wav | 3 | 0.13s | 低频短敲击与滤波噪声 |
| enemy_defeat_01.wav ～ enemy_defeat_03.wav | 3 | 0.29s | 下降滑音与烟团噗声 |

44.1kHz、单声道、16-bit PCM、无循环。固定随机种子；2ms淡入、12ms淡出边界；每文件峰值约0.55FS。游戏内短声按类别约-15～-16dB，音调轮换1.0/0.97/1.03。并发限制见[特效说明](../../effects/archery/README.md)。引擎录制混音已核对非静音、无削波；主观音色和高射速耐听程度仍需实际试听。
