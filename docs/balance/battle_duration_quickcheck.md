# 战斗时长快检（5000 无克制）

更新时间：2026-03-18

## 用途
- 快速验证“`5000 vs 5000`（无兵种克制）是否接近目标时长（例如 100 秒）”。
- 批量跑多局，输出 `CSV + summary.json`，减少手动盯盘偏差。

## 一键命令（PowerShell）
```powershell
tools/balance/run_battle_duration_quickcheck.ps1
```

默认参数：
- `matches=10`
- `units_per_team=1`
- `soldiers_per_unit=5000`
- `role=infantry`
- `symmetric=true`
- `disable_personality=true`
- `force_spawn_template=true`
- `reissue_order_interval_sim_sec=10`
- `team_front_offset_z=6.0`
- `time_scale=8.0`
- 可选：`UnitAttackDamageOverride`、`UnitMaxHpOverride`（仅压测覆盖，不改正式配置）

输出目录：
- `tmp/reports/*_matches_*.csv`
- `tmp/reports/*_summary_*.json`

## 直接运行器（可自定义）
```powershell
godot4 --headless --path . -s res://scripts/tools/battle_duration_batch_runner.gd -- `
  --matches=10 `
  --units_per_team=1 `
  --soldiers_per_unit=5000 `
  --role=infantry `
  --symmetric=true `
  --team_front_offset_z=6 `
  --time_scale=8 `
  --max_sim_sec=240 `
  --disable_personality=true `
  --force_spawn_template=true `
  --reissue_order_interval_sim_sec=10 `
  --prefix=battle_duration_100s
```

## summary 关键字段
- `duration_avg_sec`：均值
- `duration_median_sec`：中位数
- `duration_p90_sec`：90 分位
- `timeout_count`：超时局数

建议判定线（当前目标）：
- 通过：`duration_median_sec` 在 `90~110` 秒区间
- 复调：超出区间或 `timeout_count > 0`
