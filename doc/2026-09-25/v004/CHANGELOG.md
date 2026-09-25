# 2026-09-25 / v004 · 骑射撒放、命中与击杀声画反馈

- 日期与时区：2026-09-25，Asia/Shanghai。
- 当日版本：v004；状态：已交付可运行试样。
- 关联前版：[v003敌人美术](../v003/CHANGELOG.md)。
- 用户目标：给Demo加入撒放、命中、击杀声音与卡通视觉反馈。

## 本轮实际变更

- 独立ArcheryFeedback场景接收真实撒放、扫掠命中和敌人死亡事件；弓口回弹白线130ms、命中星芒碎屑220ms、击杀烟团及装饰碎片380ms。玩家箭增加短拖尾，敌人受击短暂提亮并压缩回弹，脚底不变。
- Python标准库程序合成9个原始WAV，弦声/打击声/击杀滑音各3个变体，保存可复现生成器。没有引入第三方录音、插件或人声模型。
- 一次齐射发一次撒放事件；未命中不响，离场不出击杀反馈。燃烧/冲撞死亡复用死亡反馈，燃烧跳伤不冒充箭命中。
- 6个固定音频通道、48个视觉事件上限，按类别限制最短播放间隔。main统一step推进特效，显式暂停音频；选卡、死亡、完成冻结，重开清空。退出停止播放并释放stream引用。
- 新增20项专项检查；快速音频测试在主场景释放后等待0.1秒，允许AudioServer回收后退出，不删改原有玩法断言。

## 涉及文件

- [原生特效及说明](../../../prototype/asset/runtime/effects/archery/README.md)、[9个WAV及来源](../../../prototype/asset/runtime/audio/sfx/README.md)、[合成器](../../../prototype/asset/tools/generate_archery_sfx.py)。
- [AutoBow](../../../prototype/player/auto_bow.gd)、[Combat](../../../prototype/combat/combat.gd)、[Arrow](../../../prototype/combat/arrow.gd)、[Enemy](../../../prototype/enemies/enemy.gd)、[main](../../../prototype/main.gd)与main.tscn。
- [专项测试](../../../prototype/tests/test_archery_feedback.gd)、[原生预览与混音录制](../../../prototype/tests/preview_archery_feedback.gd)、test_rider_animation.gd退出回收等待。
- [运行GIF](../../../prototype/asset/concepts/archery_feedback_preview.gif)、[实际引擎混音WAV](../../../prototype/asset/concepts/archery_feedback_mix.wav)、[撒放截图](../../../prototype/asset/concepts/archery_release.png)、[命中截图](../../../prototype/asset/concepts/archery_hit.png)、[击杀截图](../../../prototype/asset/concepts/archery_defeat.png)。

## 行为与兼容性

保留三车道、攻击周期、碰撞、伤害、奖励与AI逻辑。特效模块仅消费表现事件，不能发射箭或修改血量。声音不是逐箭重复播放；通道占满时忽略新增声音，不阻塞战斗。重开会停止旧声音，音效使用Godot原生AudioStreamPlayer。

## 本轮验证

使用本机Godot 4.7.2 Compatibility。以下命令从仓库根实际执行，测试由Python逐个调用等价命令并检查退出码及ERROR/leaked输出：

```sh
GODOT_BIN=/Users/evan/Desktop/Godot.app/Contents/MacOS/Godot
python3 prototype/asset/tools/generate_archery_sfx.py
"$GODOT_BIN" --headless --path prototype --editor --import
for name in combat elite growth integration raider horse rider_animation run_config enemy_art archery_feedback; do
  "$GODOT_BIN" --headless --path prototype --script "res://tests/test_${name}.gd"
done
"$GODOT_BIN" --path prototype --script res://tests/preview_archery_feedback.gd
"$GODOT_BIN" --headless --path prototype --script res://asset/tools/verify_horse_animation.gd
"$GODOT_BIN" --path prototype --script res://asset/tools/render_horse_preview.gd
git diff --check
```

- 全套178/178通过：18+19+20+17+15+10+18+14+27+20，最终输出无ERROR及泄漏警告。
- 初次极速测试退出有AudioStreamPlaybackWAV回收警告；加入退出清理及测试0.1秒回收等待后，全套重跑通过。
- 原生120帧预览退出0，实际观察到release/hit/defeat三事件，检查撒放、存活受击、击杀截图。前半目标标准生命，后半人为启用箭雨及1HP目标，关闭成长暂停，仅作表现验收，不是正常关卡录像。
- AudioEffectRecord取得4.597秒双声道实际混音，PCM分析峰值0.208FS、RMS约0.0149，非静音无削波。9个源文件44.1kHz/16bit/单声道，峰值约0.55FS，均非静音；未完成主观听感验收。
- ffmpeg以30FPS对原生120帧执行split/palettegen/paletteuse导出4秒无声GIF；录音按真实墙钟，GIF按模拟时钟，二者未合并为同步视频。
- 马资产检查通过；原生预览观察6/6帧。文档链接、命名和git diff --check通过。

## 未完成与下一步

当前是程序合成音与原生绘制试样，音色/响度需要用户实际试听。尚无敌方投矛、玩家受伤、护盾或UI声音，没有真人怪叫、震屏或受击停顿；未进行真人完整通关和难度验收。未提交Git。
