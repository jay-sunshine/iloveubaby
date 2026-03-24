# 兵种克制矩阵微调记录（2026-03-18 / v3）

## 本轮目标
- 按第 3 步执行“兵种对阵矩阵平衡”。
- 保持 `5000 vs 5000` 基线战斗时长在约 `100s` 附近。
- 优先修正两类问题：
  - `盾 vs 弩` 结果不符合“弩克盾”的设计预期。
  - `策士` 对多兵种偏弱且缺少反制窗口。

## 本轮配置改动
文件：`data/config/battle_rules.json`  
键：`demo_role_counter_damage_matrix`

- `spear.cavalry`: `1.16 -> 1.12`
- `spear.scout`: `1.11 -> 1.07`
- `cavalry.archer`: `1.08 -> 1.05`
- `cavalry.crossbow`: `1.08 -> 1.04`
- `cavalry.siege`: `1.12 -> 1.09`
- `archer.spear`: `1.06 -> 1.03`
- `crossbow.shield`: `1.10 -> 1.20`
- `crossbow.spear`: `1.06 -> 1.05`
- `shield.crossbow`: 删除（不再额外克制弩兵）
- `siege.shield`: `1.12 -> 1.10`
- `scout.archer`: `1.05 -> 1.03`
- 新增 `strategist` 反制：
  - `strategist.spear = 1.08`
  - `strategist.shield = 1.12`
  - `strategist.cavalry = 1.06`

## 压测与回归
### 重点分组复核（改后）
- A组：`role_matrix_focus_a_v2_20260318_175659_summary.json`（弓/弩/骑/斥候/器械）
- B组：`role_matrix_focus_b_v2_20260318_181738_summary.json`（枪/骑/斥候/策士）
- C组：`role_matrix_focus_c_v2_20260318_183200_summary.json`（盾/弩/弓）

关键变化：
- `shield vs crossbow`：由“盾优势”翻转为“弩优势”（符合预期）。
- `spear vs strategist`：由“枪优势”翻转为“策士优势”（说明策士补偿生效）。
- `cavalry vs strategist`：由强压收敛到轻微优势（不再一边倒）。

### 全矩阵粗扫（改后）
- 汇总：`tmp/reports/role_matrix_scan_v3_20260318_184016_summary.json`
- 关键指标：
  - `match_count_per_cell = 2`
  - `duration_median_avg_sec = 96.884`
  - `timeout_cells = 1`（主要为 `strategist vs strategist`）

### 时长基线回归（改后）
- 汇总：`tmp/reports/final_duration_regression_summary_20260318_191714.json`
- 结果：
  - `matches = 10`
  - `duration_median_sec = 100.4`
  - `duration_avg_sec = 106.83`
  - 无超时

## 当前仍存在的强克制对阵（待下一轮）
- `archer` 仍被 `cavalry / scout / crossbow / siege` 明显压制。
- `spear` 对 `cavalry / scout / siege` 仍偏强。
- `scout` 对 `strategist` 仍是强克制。
- `strategist vs strategist` 仍易拖到超时判定。

## 结论
- 本轮已完成“矩阵微调 + 回归验证 + 时长守住”的闭环。
- 战斗节奏未被破坏（中位时长保持在约 100 秒）。
- `盾弩关系` 与 `策士定位` 已明显改善；剩余问题集中在“弓系脆弱过强”和“枪系克制幅度偏高”。
