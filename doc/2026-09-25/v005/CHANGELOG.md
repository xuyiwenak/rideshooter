# 2026-09-25 / v005 · 本机授权音效接入 Demo

- 日期与时区：2026-09-25，Asia/Shanghai。
- 当日版本：v005；状态：已交付本机可运行集成。
- 关联前版：[v004骑射反馈](../v004/CHANGELOG.md)。
- 用户目标：把 Sound FX Starter Pack Vol. 1 中适合本 Demo 的声音加入游戏。

## 本轮实际变更

- 复制7段本机授权WAV至Git忽略的 `prototype/asset/runtime/audio/sfx/ovani_starter/`，命名统一小写 snake_case；提供可复现的本地导入脚本、源文件映射和许可说明。原始WAV、Godot导入设置和新混音未放进公开仓库。
- 弓弦和箭命中优先使用授权声，文件缺失时自动回退既有合成WAV；敌人击杀沿用合成滑稽音。护盾真挡伤时播放格挡声并显示蓝环，升到新级时播放奖励声，有效选卡时播放UI点击声。
- 马蹄和草地氛围声随主时钟启动；选卡、死亡、关卡结束暂停，重开停止。跳跃停马蹄，落地恢复，冲锋提高马蹄音调。选卡中的UI声独立于玩法暂停。
- 战斗短声仍使用固定6通道与短冷却；增加2个UI声和2个循环声通道。没有改变三车道、伤害、成长奖励或关卡配置。
- 新增13项本机授权音效专项检查。两个快速退出的旧测试增加AudioServer回收等待，避免引擎退出时产生资源警告。

## 涉及文件

- [音频导入器](../../../prototype/asset/tools/import_ovani_starter.py)、[音效映射与授权说明](../../../prototype/asset/runtime/audio/sfx/README.md)、[反馈实现](../../../prototype/asset/runtime/effects/archery/archery_feedback.gd)及[反馈说明](../../../prototype/asset/runtime/effects/archery/README.md)、[Git忽略规则](../../../.gitignore)。
- [主场景连接](../../../prototype/main.gd)、[骑手护盾事件](../../../prototype/player/rider.gd)、[成长事件](../../../prototype/progression/war_spirit.gd)。
- [授权音效专项](../../../prototype/tests/test_licensed_audio.gd)、test_horse.gd、test_enemy_art.gd；根目录记忆、工程和资源说明及测试指引同步更新。

## 行为变化与兼容性

公开仓库克隆后没有Ovani原始WAV，工程仍可运行；弓弦与命中回退合成声，其余新增声音静音。拥有授权包的本机执行导入脚本并让Godot导入后，即能播放7段声音。新混音在本机Godot `user://archery_feedback_mix.wav`，旧仓库 `asset/concepts/archery_feedback_mix.wav` 仍是上一版合成声预览。

## 本轮验证

从仓库根实际运行：

```sh
python3 prototype/asset/tools/import_ovani_starter.py '/Users/evan/Desktop/Sound FX Starter Pack Vol. 1'
'/Users/evan/Desktop/Godot.app/Contents/MacOS/Godot' --headless --path prototype --import
for name in combat elite growth integration raider horse rider_animation run_config enemy_art archery_feedback licensed_audio; do
  '/Users/evan/Desktop/Godot.app/Contents/MacOS/Godot' --headless --path prototype --script "res://tests/test_${name}.gd"
done
'/Users/evan/Desktop/Godot.app/Contents/MacOS/Godot' --path prototype --script res://tests/preview_archery_feedback.gd
```

- 全套191/191通过（18+19+20+17+15+10+18+14+27+20+13），最终重跑无解析/运行错误及资源泄漏。授权音效专项验证7段载入、马蹄与草地启动、跳跃/冲锋、暂停、护盾、升级/选卡、合成回退和重开。
- Godot原生120帧预览退出码0，观察到release/hit/defeat。实际引擎混音录音4.789秒、48kHz双声道、峰值约0.202FS、RMS约0.0251FS，非静音无削波；这是自动振幅检查，不等于人工音色验收。
- Git忽略检查确认授权目录下WAV及 `.import` 均为ignored。未提交或发布Git。

## 未完成与下一步

当前没有敌人投矛声和玩家失血声；环境与马蹄的主观响度、长时间循环衔接还需在实际设备试玩验收。授权音效专项仅在本机包存在时运行；公开仓库环境应跳过该项，其他测试依赖合成回退。
