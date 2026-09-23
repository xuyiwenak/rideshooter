# 普通怪与敌人共用规则

- enemy.gd：共用生命/燃烧/死亡信号，以及普通怪移动、弓手预警、接触和离场。
- infantry.tscn / archer.tscn：固定车道普通怪。
- raider.gd / raider.tscn：较快接近、预告后相邻换道的追击兵；不临时改目标，不贴脸开始换道。
- elite/：精英专属决策和执行，进入修改前读该目录 AGENTS.md。
- 出现在哪一路、同时出现多少只由 ../world/encounter_director.gd 管，不在敌人脚本自行刷怪。
- 保持可见位置与碰撞一致；目的车道不等于已经到达的位置。
- 扩展敌人时检查 Combat 场景注册、战意奖励、离场/死亡单次信号、选卡暂停和重开。
- 普通怪改动跑 test_combat、test_raider、test_integration；共用生命周期改动再跑精英与成长。
