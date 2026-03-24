# 兵种定位修正（2026-03-18）

## 目标
- 骑兵应克制策士。
- 弓兵/弩兵应体现射程与输出优势，但身板偏脆。
- 斥候应是侦察位：更快、更远视野、攻击极低、略有生存提升。

## 实际改动

### 1) 克制矩阵
文件：`data/config/battle_rules.json`

- 新增：`cavalry -> strategist = 1.12`
- 删除：`strategist -> cavalry`
- 删除：`scout -> archer`（不再通过克制倍率强化斥候输出）

### 2) 角色模板（运行时属性）
文件：`scripts/battlefield_controller.gd`（`_apply_role_visual`）

- `scout`
  - `move_speed: 6.2 -> 6.8`
  - `vision_radius >= 72`
  - `hold_attack_scan_radius >= 58`
  - `max_hp *= 1.12`
  - `attack_damage *= 0.34`
  - 技能消耗设为极高（压制斥候爆发）
- `archer`
  - `archer_damage_mul = 1.08`
  - `max_hp *= 0.82`
- `crossbow`
  - `archer_damage_mul: 1.2 -> 1.28`
  - `max_hp *= 0.86`

## 回归结果（定向）

### 枪/骑/斥候/策士
报告：`tmp/reports/role_matrix_focus_b_v3_20260318_194103_summary.json`

- `cavalry vs strategist`：骑兵优势（符合目标）
- `scout vs strategist`：策士优势（斥候不再靠输出压制策士）
- `spear vs strategist`：策士优势（保留策士对枪反制）

### 盾/弩/弓
报告：`tmp/reports/role_matrix_focus_c_v3_20260318_195042_summary.json`

- `shield vs crossbow`：弩兵优势（“弩克盾”保持）
- `crossbow vs archer`：弩兵优势
- `shield vs archer`：盾兵优势（弓兵脆身板特征更明显）

## 注意
- 斥候镜像与“斥候 vs 策士”出现超时（240s），说明斥候伤害已经显著降低，侦察定位生效，但节奏偏慢。
- 基线时长（步兵镜像）本轮样本中位数约 `116.8s`，比目标 `100s` 略长，后续可单独微调全局 DPS/生存参数。
