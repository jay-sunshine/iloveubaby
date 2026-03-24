# 个性事件平衡基线（锁定）

更新时间：2026-03-16

## 1. 基线用途
- 作为个性机制后续调参的固定对照组。
- 规则：后续所有平衡回归必须先跑同协议，再和本页数值对比。

## 2. 固定测试协议
- 场景：`res://scenes/battle_demo.tscn`
- 运行器：`res://scripts/tools/personality_batch_sim_runner.gd`
- 样本：`matches=200`（含镜像腿，实际 100 对种子）
- 对称：`mirror=true`、`symmetric=true`、`mirror_swap_team=true`
- 仿真：`time_scale=8`、`max_sim_sec=240`
- 统计口径：
  - `avg_inf` = `(team0_inflicted 平均 + team1_inflicted 平均) / 2`
  - `avg_trigger` = `(team0_trigger 平均 + team1_trigger 平均) / 2`

## 3. 锁定结果（swap+200）

| 方案 | 战绩(W-L-D) | avg_sim_sec | avg_inf | avg_trigger |
|---|---:|---:|---:|---:|
| CTRL | 116-84-0 | 9.352 | 22674.43 | 0.000 |
| XIONGLUE | 99-101-0 | 9.156 | 23984.07 | 19.925 |
| HUOSHEN | 100-98-2 | 9.021 | 22677.66 | 19.740 |

对应原始 CSV：
- `tmp/reports/ab200_ctrl_swap_r1_matches_20260316_144323.csv`
- `tmp/reports/ab200_xionglue_swap_r1_matches_20260316_145033.csv`
- `tmp/reports/ab200_huoshen_swap_r1_matches_20260316_150028.csv`

## 4. 回归判定规则（后续统一执行）
- 必须使用“第 2 节同协议”。
- 相比本页基线，任一方案触发以下条件即判定为“需复调”：
  - 胜率偏移绝对值 `> 5` 个百分点。
  - `avg_sim_sec` 偏移绝对值 `> 8%`。
  - `avg_inf` 偏移绝对值 `> 6%`。

## 5. 本次 1+2 改动后烟雾验证（对抗链）
- XIONGLUE（20 局）
  - `tmp/reports/smoke_counter_xionglue_traits_20260316_155426.csv`
  - `blocked_count=54`，`forced_count=12`
- HUOSHEN（20 局）
  - `tmp/reports/smoke_counter_huoshen_traits_20260316_155520.csv`
  - `blocked_count=61`，`forced_count=19`

结论：`blocked/forced` 已由“长期接近 0”变为可观测非零，可进入下一轮 200 局正式回归。

## 6. 对抗链正式回归（swap+200，2026-03-16）

新增原始 CSV：
- `tmp/reports/ab200_ctrl_postchain_matches_20260316_160943.csv`
- `tmp/reports/ab200_xionglue_postchain_matches_20260316_161644.csv`
- `tmp/reports/ab200_huoshen_postchain_matches_20260316_162310.csv`
- `tmp/reports/ab200_xionglue_postchain_traits_20260316_161644.csv`
- `tmp/reports/ab200_huoshen_postchain_traits_20260316_162310.csv`

结果总览：

| 方案 | 战绩(W-L-D) | avg_sim_sec | avg_inf | avg_trigger | avg_blocked | avg_forced |
|---|---:|---:|---:|---:|---:|---:|
| CTRL_POST | 102-98-0 | 9.438 | 22817.40 | 0.000 | 0.000 | 0.000 |
| XIONGLUE_POST | 90-109-1 | 10.390 | 23688.44 | 20.270 | 1.670 | 0.465 |
| HUOSHEN_POST | 112-85-3 | 10.051 | 22973.48 | 20.688 | 1.695 | 0.438 |

对抗链关键触发汇总：
- XIONGLUE：`xionglue_confuse` 触发 8108，blocked 668，forced 186
- HUOSHEN：`huoshen_burn` 触发 8275，blocked 678，forced 175

相对锁定基线（第 3 节）偏移：
- CTRL：胜率 -7.00pp，avg_sim +0.92%，avg_inf +0.63%
- XIONGLUE：胜率 -4.50pp，avg_sim +13.48%，avg_inf -1.23%
- HUOSHEN：胜率 +6.00pp，avg_sim +11.42%，avg_inf +1.30%

按第 4 节阈值判定：
- 触发“需复调”：CTRL（胜率偏移）、XIONGLUE（avg_sim 偏移）、HUOSHEN（胜率与 avg_sim 偏移）。

## 7. 参数回调快测（100局，2026-03-16）

本轮回调参数（`scripts/unit_controller.gd`）：
- `immunity_base_chance = 0.07`
- `immunity_control_resist_weight = 0.32`
- `immunity_int_weight = 0.002`
- `suppression_base_chance = 0.05`
- `suppression_lv1_bonus = 0.06`
- `suppression_lv2_bonus = 0.12`
- `forced_duration_mul = 0.62`
- `dispel_on_block = true`，`dispel_chance_on_block = 0.35`

快测原始 CSV：
- `tmp/reports/q100_ctrl_tune1_matches_20260316_164111.csv`
- `tmp/reports/q100_xionglue_tune1_matches_20260316_164444.csv`
- `tmp/reports/q100_huoshen_tune1_matches_20260316_164808.csv`
- `tmp/reports/q100_xionglue_tune1_traits_20260316_164444.csv`
- `tmp/reports/q100_huoshen_tune1_traits_20260316_164808.csv`

结果摘要（100局）：

| 方案 | 战绩(W-L-D) | avg_sim_sec | avg_inf | avg_trigger | avg_blocked | avg_forced |
|---|---:|---:|---:|---:|---:|---:|
| CTRL_TUNE100 | 51-49-0 | 9.500 | 22821.24 | 0.000 | 0.000 | 0.000 |
| XIONGLUE_TUNE100 | 47-53-0 | 9.436 | 23867.74 | 19.980 | 1.220 | 0.285 |
| HUOSHEN_TUNE100 | 54-45-1 | 9.176 | 22635.44 | 20.420 | 1.120 | 0.195 |

对抗链可观测性（trait 汇总）：
- XIONGLUE：trigger 3996 / blocked 244 / forced 57
- HUOSHEN：trigger 4084 / blocked 224 / forced 39

快测结论：
- 相比第 6 节 200局结果，`avg_sim_sec` 已明显回落，胜率偏移也收敛。
- 建议下一步按同参数直接跑正式 `swap+200` 复核，再决定是否锁定为 v1.1 基线。

## 8. tune1 正式复核（swap+200，2026-03-16）

正式复核原始 CSV：
- `tmp/reports/ab200_ctrl_tune1_matches_20260316_172214.csv`
- `tmp/reports/ab200_xionglue_tune1_matches_20260316_172833.csv`
- `tmp/reports/ab200_huoshen_tune1_matches_20260316_173506.csv`
- `tmp/reports/ab200_xionglue_tune1_traits_20260316_172833.csv`
- `tmp/reports/ab200_huoshen_tune1_traits_20260316_173506.csv`

结果摘要（seed_start=620000）：

| 方案 | 战绩(W-L-D) | avg_sim_sec | avg_inf | avg_trigger | avg_blocked | avg_forced |
|---|---:|---:|---:|---:|---:|---:|
| CTRL_TUNE1 | 99-101-0 | 9.223 | 22638.61 | 0.000 | 0.000 | 0.000 |
| XIONGLUE_TUNE1 | 104-95-1 | 9.321 | 23924.71 | 20.030 | 1.198 | 0.215 |
| HUOSHEN_TUNE1 | 105-95-0 | 9.419 | 22905.83 | 19.840 | 1.065 | 0.277 |

对抗链可观测性（trait 汇总）：
- XIONGLUE：trigger 8012，blocked 479（5.98%），forced 86（1.07%）
- HUOSHEN：trigger 7936，blocked 426（5.37%），forced 111（1.40%）

附加稳定性复测（CTRL，仅换种子）：
- `tmp/reports/ab200_ctrl_tune1_r2_matches_20260316_174529.csv`
- 结果：106-94-0，`avg_sim_sec=9.325`，`avg_inf=22757.11`

判定建议：
- 从“对抗链是否工作且不过载”看：可用（blocked/forced 非零且占比温和，avg_sim 已回落到 9.2~9.4）。
- 从“单次胜率阈值”看：CTRL 对比旧基线波动偏大，建议将 v1.1 锁定规则升级为“多种子均值”后再最终锁定。
- 实操建议：对 CTRL / XIONGLUE / HUOSHEN 各跑 `2x200`（不同 seed_start），以均值作为 v1.1 锁定值。

## 9. tune1 最终锁定（2x200，多种子均值，2026-03-16）

本轮新增原始 CSV（run2 已补齐）：
- `tmp/reports/ab200_ctrl_tune1_matches_20260316_172214.csv`
- `tmp/reports/ab200_ctrl_tune1_r2_matches_20260316_174529.csv`
- `tmp/reports/ab200_xionglue_tune1_matches_20260316_172833.csv`
- `tmp/reports/ab200_xionglue_tune1_r2_matches_20260316_180721.csv`
- `tmp/reports/ab200_huoshen_tune1_matches_20260316_173506.csv`
- `tmp/reports/ab200_huoshen_tune1_r2_matches_20260316_181359.csv`
- `tmp/reports/ab200_xionglue_tune1_traits_20260316_172833.csv`
- `tmp/reports/ab200_xionglue_tune1_r2_traits_20260316_180721.csv`
- `tmp/reports/ab200_huoshen_tune1_traits_20260316_173506.csv`
- `tmp/reports/ab200_huoshen_tune1_r2_traits_20260316_181359.csv`

2x200 合并结果（400 局）：

| 方案 | 战绩(W-L-D) | avg_sim_sec | avg_inf | avg_trigger | avg_blocked | avg_forced |
|---|---:|---:|---:|---:|---:|---:|
| CTRL_V11_LOCK | 205-195-0 | 9.274 | 22697.86 | 0.000 | 0.000 | 0.000 |
| XIONGLUE_V11_LOCK | 204-192-4 | 9.310 | 23893.37 | 20.068 | 1.201 | 0.219 |
| HUOSHEN_V11_LOCK | 206-194-0 | 9.410 | 22901.56 | 19.814 | 1.126 | 0.288 |

对抗链触发汇总（trait 文件合并）：
- XIONGLUE：trigger 16054，blocked 961（5.99%），forced 175（1.09%）
- HUOSHEN：trigger 15851，blocked 901（5.68%），forced 230（1.45%）

相对旧基线（第 3 节）偏移：
- CTRL：胜率 -6.75pp，avg_sim -0.83%，avg_inf +0.10%
- XIONGLUE：胜率 +1.50pp，avg_sim +1.68%，avg_inf -0.38%
- HUOSHEN：胜率 +1.50pp，avg_sim +4.32%，avg_inf +0.99%

最终锁定结论（v1.1）：
- 以本节 `2x200` 合并均值作为新锁定值。
- 后续回归继续使用第 2 节固定协议，判定阈值沿用第 4 节，但对照目标改为本节锁定值。
- 当前调参参数冻结为：`immunity_base_chance=0.07`、`immunity_control_resist_weight=0.32`、`immunity_int_weight=0.002`、`suppression_base_chance=0.05`、`suppression_lv1_bonus=0.06`、`suppression_lv2_bonus=0.12`、`forced_duration_mul=0.62`、`dispel_chance_on_block=0.35`。

## 10. 一键回归脚本（v1.1）

执行全套 `2x200`（CTRL/XIONGLUE/HUOSHEN 各两组）：

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\balance\run_personality_v11_suite.ps1 -LockEnv v11 -PrefixBase ab200
```

按 v1.1 锁定值汇总并阈值判定：

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\balance\summarize_personality_v11_suite.ps1 -PrefixBase ab200 -BaselineProfile front6 -FailOnThreshold
```

输出文件：
- `tmp/reports/personality_v11_lockcheck_*.json`
- `tmp/reports/personality_v11_lockcheck_*.md`

## 11. 运行时轻量优化（2026-03-16）

为降低实机卡顿，已做两项运行时优化（不改机制逻辑）：
- `scripts/unit_controller.gd`
  - `personality_event_debug_stats_enabled` 默认改为 `false`（实机不再做事件调试计数字典写入）。
  - 新增 `personality_event_light_tick_interval_sec`（默认 `0.05`），个性效果计时采用轻量分段 tick。
  - 个性运行时加成改为“脏标记重建”，避免每帧无变化重算。
- `scripts/tools/personality_batch_sim_runner.gd`
  - 基准回归时强制 `personality_event_debug_stats_enabled=true`
  - 基准回归时强制 `personality_event_light_tick_interval_sec=0.0`
  - 目的：保证基线统计口径与历史锁定值一致。

轻量优化后快测（q60）：
- `tmp/reports/q60_lightopt_ctrl_matches_20260316_200659.csv`
- `tmp/reports/q60_lightopt_xionglue_matches_20260316_200659.csv`
- `tmp/reports/q60_lightopt_huoshen_matches_20260316_200659.csv`

快测摘要：
- CTRL：`31-29-0`，`avg_sim_sec=9.438`
- XIONGLUE：`30-28-2`，`avg_sim_sec=9.436`，`avg_trigger=20.108`，`avg_blocked=1.217`，`avg_forced=0.275`
- HUOSHEN：`35-25-0`，`avg_sim_sec=9.207`，`avg_trigger=19.883`，`avg_blocked=1.208`，`avg_forced=0.158`

## 12. 轻量默认完整复核（2x200，2026-03-16）

锁定复核原始 CSV（轻量默认）：
- `tmp/reports/ab200_ctrl_tune1_lockcheck_matches_20260316_202450.csv`
- `tmp/reports/ab200_ctrl_tune1_r2_lockcheck_matches_20260316_204107.csv`
- `tmp/reports/ab200_xionglue_tune1_lockcheck_matches_20260316_203017.csv`
- `tmp/reports/ab200_xionglue_tune1_r2_lockcheck_matches_20260316_204937.csv`
- `tmp/reports/ab200_huoshen_tune1_lockcheck_matches_20260316_203546.csv`
- `tmp/reports/ab200_huoshen_tune1_r2_lockcheck_matches_20260316_205645.csv`
- `tmp/reports/ab200_xionglue_tune1_lockcheck_traits_20260316_203017.csv`
- `tmp/reports/ab200_xionglue_tune1_r2_lockcheck_traits_20260316_204937.csv`
- `tmp/reports/ab200_huoshen_tune1_lockcheck_traits_20260316_203546.csv`
- `tmp/reports/ab200_huoshen_tune1_r2_lockcheck_traits_20260316_205645.csv`

合并结果（400 局，对照第 9 节 v1.1 锁定值）：

| 方案 | 战绩(W-L-D) | avg_sim_sec | avg_inf | avg_trigger | avg_blocked | avg_forced | 漂移(win/sim/inf) | 结论 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| CTRL | 209-190-1 | 13.024 | 22359.36 | 0.000 | 0.000 | 0.000 | +1.00pp / +40.43% / -1.49% | FAIL |
| XIONGLUE | 205-191-4 | 11.173 | 21807.71 | 18.770 | 1.076 | 0.194 | +0.25pp / +20.02% / -8.73% | FAIL |
| HUOSHEN | 218-181-1 | 5.177 | 21150.96 | 10.046 | 0.573 | 0.124 | +3.00pp / -44.98% / -7.64% | FAIL |

判定：
- 按第 4 节阈值（胜率 5pp / sim 8% / inf 6%），三组全部未通过。
- 结论：**“轻量默认”当前实现不满足 v1.1 锁定稳定性，不能作为默认基线发布。**

## 13. 回滚后完整复核（2x200，2026-03-16）

为恢复锁定稳定性，已回滚 `scripts/unit_controller.gd` 的高风险轻量路径：
- `_physics_process` 改回直接调用 `_tick_personality_event_effects(delta)`。
- 移除 `_tick_personality_event_effects_light` 分段 tick 路径。
- 移除个性运行时加成“脏标记重建”路径，改回每帧重建。
- `personality_event_debug_stats_enabled` 默认恢复为 `true`。
- `personality_event_light_tick_interval_sec` 默认恢复为 `0.0`（保留字段，兼容批处理脚本）。

本次 2x200 原始 CSV（prefix: `ab200_rollback_lockcheck`）：
- `tmp/reports/ab200_rollback_lockcheck_ctrl_tune1_matches_20260316_212252.csv`
- `tmp/reports/ab200_rollback_lockcheck_ctrl_tune1_r2_matches_20260316_212752.csv`
- `tmp/reports/ab200_rollback_lockcheck_xionglue_tune1_matches_20260316_212419.csv`
- `tmp/reports/ab200_rollback_lockcheck_xionglue_tune1_r2_matches_20260316_213012.csv`
- `tmp/reports/ab200_rollback_lockcheck_huoshen_tune1_matches_20260316_212603.csv`
- `tmp/reports/ab200_rollback_lockcheck_huoshen_tune1_r2_matches_20260316_213219.csv`
- `tmp/reports/ab200_rollback_lockcheck_xionglue_tune1_traits_20260316_212419.csv`
- `tmp/reports/ab200_rollback_lockcheck_xionglue_tune1_r2_traits_20260316_213012.csv`
- `tmp/reports/ab200_rollback_lockcheck_huoshen_tune1_traits_20260316_212603.csv`
- `tmp/reports/ab200_rollback_lockcheck_huoshen_tune1_r2_traits_20260316_213219.csv`

首次汇总（`personality_v11_lockcheck_20260316_213417`）说明：
- 该次汇总时脚本尚不支持 `PrefixBase`，实际读取的是默认 `ab200_*` 最新文件。
- 因此该次 PASS 结果与本节 `ab200_rollback_lockcheck_*` 原始 CSV 不一致，判定为**无效结果**，仅保留作排查记录。

| 方案 | 战绩(W-L-D) | avg_sim_sec | avg_inf | avg_trigger | avg_blocked | avg_forced | 漂移(win/sim/inf) | 结论 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| CTRL | 203-195-2 | 9.496 | 22839.294 | 0.000 | 0.000 | 0.000 | -0.50pp / +2.394% / +0.623% | INVALID |
| XIONGLUE | 194-205-1 | 9.275 | 23881.702 | 19.876 | 1.129 | 0.250 | -2.50pp / -0.372% / -0.049% | INVALID |
| HUOSHEN | 195-204-1 | 9.442 | 22979.690 | 19.726 | 1.092 | 0.240 | -2.75pp / +0.340% / +0.341% | INVALID |

对抗链汇总：
- XIONGLUE：trigger 15901，blocked 903（5.679%），forced 200（1.258%）
- HUOSHEN：trigger 15781，blocked 874（5.538%），forced 192（1.217%）

结论：
- 本节首次 PASS 不可用于锁定判定。

本次汇总输出：
- `tmp/reports/personality_v11_lockcheck_20260316_213417.json`
- `tmp/reports/personality_v11_lockcheck_20260316_213417.md`

## 14. Prefix 纠偏复核（2x200，2026-03-17）

修复项：
- `tools/balance/summarize_personality_v11_suite.ps1` 新增 `-PrefixBase` 参数，按指定前缀读取 CSV。
- 使用该参数对 `ab200_rollback_lockcheck` 复算：`personality_v11_lockcheck_20260317_101409`。
- 之后重跑完整 2x200（`ab200_rollback_lockcheck_v2`）并再次汇总：`personality_v11_lockcheck_20260317_103231`。

`ab200_rollback_lockcheck_v2` 原始 CSV：
- `tmp/reports/ab200_rollback_lockcheck_v2_ctrl_tune1_matches_20260317_102039.csv`
- `tmp/reports/ab200_rollback_lockcheck_v2_ctrl_tune1_r2_matches_20260317_102633.csv`
- `tmp/reports/ab200_rollback_lockcheck_v2_xionglue_tune1_matches_20260317_102259.csv`
- `tmp/reports/ab200_rollback_lockcheck_v2_xionglue_tune1_r2_matches_20260317_102815.csv`
- `tmp/reports/ab200_rollback_lockcheck_v2_huoshen_tune1_matches_20260317_102503.csv`
- `tmp/reports/ab200_rollback_lockcheck_v2_huoshen_tune1_r2_matches_20260317_102944.csv`
- `tmp/reports/ab200_rollback_lockcheck_v2_xionglue_tune1_traits_20260317_102259.csv`
- `tmp/reports/ab200_rollback_lockcheck_v2_xionglue_tune1_r2_traits_20260317_102815.csv`
- `tmp/reports/ab200_rollback_lockcheck_v2_huoshen_tune1_traits_20260317_102503.csv`
- `tmp/reports/ab200_rollback_lockcheck_v2_huoshen_tune1_r2_traits_20260317_102944.csv`

按 v1.1 锁定值汇总（`-PrefixBase ab200_rollback_lockcheck_v2 -FailOnThreshold`）：

| 方案 | 战绩(W-L-D) | avg_sim_sec | avg_inf | avg_trigger | avg_blocked | avg_forced | 漂移(win/sim/inf) | 结论 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| CTRL | 200-200-0 | 1.077 | 19509.045 | 0.000 | 0.000 | 0.000 | -1.25pp / -88.391% / -14.049% | FAIL |
| XIONGLUE | 200-200-0 | 1.037 | 19411.311 | 0.022 | 0.002 | 0.000 | -1.00pp / -88.865% / -18.759% | FAIL |
| HUOSHEN | 200-200-0 | 1.055 | 19459.524 | 0.031 | 0.002 | 0.000 | -1.50pp / -88.792% / -15.030% | FAIL |

对抗链汇总：
- XIONGLUE：trigger 18，blocked 2（11.111%），forced 0（0%）
- HUOSHEN：trigger 25，blocked 2（8.000%），forced 0（0%）

判定：
- 三组均远超阈值（尤其 sim 与 inf 漂移），`-FailOnThreshold` 失败。
- 结论：当前战场基线（非个性参数）已与 v1.1 锁定环境发生显著偏离，不能用 v1.1 锁定值做通过判定。

本次汇总输出：
- `tmp/reports/personality_v11_lockcheck_20260317_101409.json`
- `tmp/reports/personality_v11_lockcheck_20260317_101409.md`
- `tmp/reports/personality_v11_lockcheck_20260317_103231.json`
- `tmp/reports/personality_v11_lockcheck_20260317_103231.md`

## 15. 锁定环境模式（v11）落地（2026-03-17）

已落地能力：
- `scripts/tools/personality_batch_sim_runner.gd` 新增 `--lock_env=v11` 参数。
- `tools/balance/run_personality_v11_suite.ps1` 新增 `-LockEnv` 参数（默认 `v11`）。
- `tools/balance/summarize_personality_v11_suite.ps1` 新增 `-PrefixBase` 参数，避免串读历史 CSV。

当前 `lock_env=v11` 锁定内容（runner 侧）：
- 关闭 demo 设施干预：`demo_facility_test_setup_enabled=false`
- 固定单位规模：`units_per_team=6`、`soldiers_per_unit=4200`
- 固定部署：`team_spacing_x=20.0`、`team_front_offset_z=82.0`
- 固定角色集合：`team_a_unit_roles/_team_b_unit_roles` 使用基准数组
- 关闭战场脚本启动随机化：`randomize_on_ready=false`（由 runner 注入）

快速烟测（`MatchCount=2`）：
- prefix `lockenv_param_smoke`，三组 `avg_sim_sec` 落在 `8.87~12.13`（接近历史量级）。

补充烟测（`MatchCount=20`）：
- prefix `lockenv_seeded_smoke`，CTRL `avg_sim_sec=1.98`，仍显著低于 v1.1 区间。

完整复核（`2x200`，prefix `ab200_lockenv_v11`）：
- 仍出现大量超短局（平均约 `1s` 量级），未恢复到 v1.1 稳定区间。
- 说明：仅靠当前 `lock_env=v11` 参数锁定仍不足以覆盖全部战场漂移源，需继续补齐锁定项后再重建锁值。

按 v1.1 锁定值汇总（`-PrefixBase ab200_lockenv_v11 -FailOnThreshold`）：

| 方案 | 战绩(W-L-D) | avg_sim_sec | avg_inf | avg_trigger | avg_blocked | avg_forced | 漂移(win/sim/inf) | 结论 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| CTRL | 200-200-0 | 1.125 | 20743.889 | 0.000 | 0.000 | 0.000 | -1.25pp / -87.866% / -8.609% | FAIL |
| XIONGLUE | 200-200-0 | 1.051 | 20606.798 | 0.009 | 0.002 | 0.000 | -1.00pp / -88.714% / -13.755% | FAIL |
| HUOSHEN | 200-200-0 | 1.038 | 20542.431 | 0.051 | 0.004 | 0.000 | -1.50pp / -88.966% / -10.301% | FAIL |

汇总输出：
- `tmp/reports/personality_v11_lockcheck_20260317_110400.json`
- `tmp/reports/personality_v11_lockcheck_20260317_110400.md`

## 16. lock_env 坍塌根因与修复（2026-03-17）

根因定位：
- `personality_batch_sim_runner.gd` 的 `--lock_env=v11` 参数在实例化前写入，但战场 `_ready()` 会执行 `_load_battle_rules()`，把 `team_front_offset_z` 等参数再次覆盖。
- 当前 `battle_rules.json` 中 `demo_front_offset_z=82.0`，在 `battle_demo_simple_terrain` 上会触发出生点修正，把单位挤到同一坐标（常见为 `(0,0,0)`），导致“1 秒局”异常。

修复落地：
- `scripts/tools/personality_batch_sim_runner.gd`
  - 新增 v11 常量并统一使用。
  - 将 v11 的 `team_front_offset_z` 调整为 `6.0`（保证在 demo 场景可行走范围内，且可缩短平均战斗时长）。
  - 在 `_apply_runtime_sim_overrides()` 再次写入锁定参数，确保 `_ready()` 后仍生效。

修复后小样本（`ab20_lockenv_fix_smoke`, 2x20）：
- 已消除“全员同点 + 超短局（~1s）”坍塌。
- 但整体对局时长显著偏长（`avg_sim_sec` 约 `191~211`，超时率偏高），与 v1.1 旧锁值（约 `9.x`）不一致。

追加重定标小样本（`ab20_lockenv_front6`, 2x20）：
- `tmp/reports/ab20_lockenv_front6_ctrl_tune1_matches_20260317_130443.csv`
- `tmp/reports/ab20_lockenv_front6_ctrl_tune1_r2_matches_20260317_132342.csv`
- `tmp/reports/ab20_lockenv_front6_xionglue_tune1_matches_20260317_131123.csv`
- `tmp/reports/ab20_lockenv_front6_xionglue_tune1_r2_matches_20260317_133021.csv`
- `tmp/reports/ab20_lockenv_front6_huoshen_tune1_matches_20260317_131736.csv`
- `tmp/reports/ab20_lockenv_front6_huoshen_tune1_r2_matches_20260317_133646.csv`

汇总（`personality_v11_lockcheck_20260317_134320`）：

| 方案 | 战绩(W-L-D) | avg_sim_sec | avg_inf | avg_trigger | avg_blocked | avg_forced |
|---|---:|---:|---:|---:|---:|---:|
| CTRL | 14-14-12 | 153.733 | 20825.700 | 0.000 | 0.000 | 0.000 |
| XIONGLUE | 11-19-10 | 145.913 | 20871.600 | 17.075 | 1.150 | 0.175 |
| HUOSHEN | 17-14-9 | 144.477 | 21738.412 | 23.162 | 1.500 | 0.225 |

输出：
- `tmp/reports/personality_v11_lockcheck_20260317_134320.json`
- `tmp/reports/personality_v11_lockcheck_20260317_134320.md`

结论：
- 当前状态从“坍塌失真”变为“可运行但口径漂移很大”。
- 前线距离从 `26` 收敛到 `6` 后，运行成本已下降，但仍远高于旧 `9.x` 口径。
- 下一步应基于当前 `lock_env(v11, front=6)` 做正式重建锁值（建议直接跑 `2x200` 生成新基线），而非继续用旧 `9.x` 锁值判通过。

## 17. front=6 正式重锁（2x200，2026-03-17）

本轮原始 CSV（prefix: `ab200_lockenv_front6_relock`）：
- `tmp/reports/ab200_lockenv_front6_relock_ctrl_tune1_matches_20260317_141647.csv`
- `tmp/reports/ab200_lockenv_front6_relock_ctrl_tune1_r2_matches_20260317_172119.csv`
- `tmp/reports/ab200_lockenv_front6_relock_xionglue_tune1_matches_20260317_152001.csv`
- `tmp/reports/ab200_lockenv_front6_relock_xionglue_tune1_r2_matches_20260317_182514.csv`
- `tmp/reports/ab200_lockenv_front6_relock_huoshen_tune1_matches_20260317_162201.csv`
- `tmp/reports/ab200_lockenv_front6_relock_huoshen_tune1_r2_matches_20260317_192357.csv`
- `tmp/reports/ab200_lockenv_front6_relock_xionglue_tune1_traits_20260317_152001.csv`
- `tmp/reports/ab200_lockenv_front6_relock_xionglue_tune1_r2_traits_20260317_182514.csv`
- `tmp/reports/ab200_lockenv_front6_relock_huoshen_tune1_traits_20260317_162201.csv`
- `tmp/reports/ab200_lockenv_front6_relock_huoshen_tune1_r2_traits_20260317_192357.csv`

汇总（400 局）：

| 方案 | 战绩(W-L-D) | avg_sim_sec | avg_inf | avg_trigger | avg_blocked | avg_forced |
|---|---:|---:|---:|---:|---:|---:|
| CTRL | 135-153-112 | 148.735 | 20946.992 | 0.000 | 0.000 | 0.000 |
| XIONGLUE | 149-158-93 | 140.514 | 20796.850 | 17.739 | 1.022 | 0.220 |
| HUOSHEN | 154-151-95 | 143.035 | 21450.205 | 22.670 | 1.386 | 0.258 |

对抗链总量：
- XIONGLUE：trigger `14191`，blocked `818`（5.764%），forced `176`（1.240%）
- HUOSHEN：trigger `18136`，blocked `1109`（6.115%），forced `206`（1.136%）

本次汇总输出：
- `tmp/reports/personality_v11_lockcheck_20260317_202804.json`
- `tmp/reports/personality_v11_lockcheck_20260317_202804.md`

锁定说明：
- 旧 v1.1（第 9 节）是 `avg_sim≈9.x` 口径，已不适配当前战场环境。
- 若采用 `lock_env=v11(front=6)`，应以上表 2x200 结果作为新的锁定对照值。
- `summarize_personality_v11_suite.ps1` 已支持基线档切换：
  - `-BaselineProfile front6`（默认，当前推荐）
  - `-BaselineProfile legacy`（仅用于回看旧 v1.1 口径）

## 18. 快速验收通道（2x20）

用于日常改动后的快速回归（默认按 `front6` 新锁值判定）：

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\balance\run_personality_v11_quickcheck.ps1 -PrefixBase quick20_front6
```

说明：
- 内部会先跑 `run_personality_v11_suite.ps1`（`MatchCount=20`），再自动执行 `summarize_personality_v11_suite.ps1 -FailOnThreshold`。
- 若阈值不通过，脚本会直接返回非 0 退出码，适合接 CI 或本地门禁。

## 19. 发布门禁（front6）

固定流程（战斗逻辑改动后必跑）：

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\balance\run_personality_v11_quickcheck.ps1 -PrefixBase gate_front6
```

发布前门禁校验（快速，检查“最新战斗逻辑修改时间”是否晚于最近一次通过的 quickcheck 标记）：

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\balance\assert_battle_logic_gate.ps1 -BaselineProfile front6
```

判定：
- `run_personality_v11_quickcheck.ps1` 退出码 `0`：写入 `tmp/reports/battle_gate_front6.json` 标记。
- `assert_battle_logic_gate.ps1` 退出码 `0`：门禁通过，可继续开发/发布。
- 任一命令非 `0`：门禁失败，必须先重新跑 quickcheck。

## 20. 中断样本标记规则

- 若一次 quickcheck / reverify / suite 运行过程中发生掉线、远程中断、手动终止或其他外部中断，即使生成了 `CSV`，也不得直接作为平衡判定样本。
- 这类样本若表现为 `100% timeout`、`avg_sim_sec=max_sim_sec` 或明显异常，应先按“中断无效样本”处理，而不是直接判定为战斗逻辑回归。
- 记录要求：至少在最近一条 `docs/codex/SESSION_HANDOFF.md` 中写明该 prefix/文件为中断无效样本；如有临时复核说明，可同步写入 `tmp/reports/*review*.md`。
- 只有在明确确认“运行未中断”的前提下，`timeout` 才能进入正式基线结论。
