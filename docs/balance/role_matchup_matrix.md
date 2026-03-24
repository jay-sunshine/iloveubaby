# 兵种对阵矩阵压测

更新时间：2026-03-18

## 目的
- 批量评估兵种互打胜率与时长。
- 识别“胜率异常”或“左右位偏置”对局。
- 为后续克制系数微调提供依据。

## 一键命令
```powershell
tools/balance/run_role_matchup_matrix.ps1
```

默认：
- 角色：`infantry, shield, spear, archer, crossbow, cavalry, scout, siege, strategist`
- 每格场次：`1`
- 场景：`5000 vs 5000`（`units_per_team=1, soldiers_per_unit=5000`）
- 自动技能：开启
- 对称重排：开启

## 常用参数
```powershell
# 每格 3 局，稳定性更高
tools/balance/run_role_matchup_matrix.ps1 -MatchCountPerCell 3

# 关闭自动技能，观察纯白刃/普攻倾向
tools/balance/run_role_matchup_matrix.ps1 -DisableAutoRelease

# 调整异常阈值（默认 0.30，即综合优势 >= 30%）
tools/balance/run_role_matchup_matrix.ps1 -AnomalyThreshold 0.25
```

## 输出文件
脚本会在 `tmp/reports/` 生成：
- `*_cells.csv`：每个 A vs B 单元格明细
- `*_pairs.csv`：合并 A↔B 后的对阵指标
- `*_anomalies.csv`：异常对局清单
- `*_matrix_winrate_pct.csv`：胜率矩阵（百分比）
- `*_summary.json`：汇总与 Top 异常

## 指标解释
- `combined_advantage`：合并正反手后的综合优势（正值偏向 `role_a`，负值偏向 `role_b`）
- `bias_gap`：`A vs B` 与 `B vs A` 的镜像差异，越高说明左右位偏置越明显
- `timeout_total`：正反手超时总数
