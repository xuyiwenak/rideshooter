# Godot 工程指引

先读仓库根 README.md 和 AGENTS.md；具体模块继续读其 AGENTS.md。技术地图见 ARCHITECTURE.md，运行说明见 README.md。

## 入口与约束

- project.godot 是项目入口，main.tscn 是主场景；main.gd 负责依赖注入、信号连接、统一子步和重开。
- 保留统一暂停机制：玩法模块由 main 推进 step，不私自新增独立 _process 使选卡期间仍运行。
- 使用独立场景承载玩家、敌人和箭矢；Combat 管生命周期，其他模块不要偷偷创建第二套实体容器。
- Godot 4.7.2、GDScript、Compatibility 渲染。480×270 灰盒，文案与形状绘制是占位实现。
- 不为文档整理迁移源码路径；需要重命名时检查 preload、场景资源引用与测试入口。

## 验证

从仓库根执行。先把 `GODOT_BIN` 设置为本机Godot可执行文件路径：

```sh
GODOT_BIN="/path/to/Godot"
"$GODOT_BIN" --headless --path prototype --script res://tests/test_combat.gd
"$GODOT_BIN" --headless --path prototype --script res://tests/test_elite.gd
"$GODOT_BIN" --headless --path prototype --script res://tests/test_growth.gd
"$GODOT_BIN" --headless --path prototype --script res://tests/test_integration.gd
"$GODOT_BIN" --headless --path prototype --script res://tests/test_raider.gd
```

根据改动运行相关检查；涉及共同伤害、时钟、场景组合或生命周期时运行全套。既看退出码，也检查 Godot 输出的解析/运行错误。视觉变化另外使用 tests/preview_*.gd 图形运行并查看截图，不能用 headless 结果替代。

代码交付后更新对应文档，并遵守根目录的日期版本记录规则。
