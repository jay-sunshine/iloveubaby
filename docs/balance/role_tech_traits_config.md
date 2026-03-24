# 战斗科技特性配置（3特性）

更新时间：2026-03-18

## 目标
- 兵种不再走升级兵种分支。
- 通过科技特性为同一兵种叠加效果。
- 配置化控制：解锁等级、持续时间、叠加规则、效果数值。

## 配置入口
- 文件：`data/config/battle_rules.json`
- 关键字段：
  - `demo_role_tech_enabled`
  - `demo_role_tech_default_level`
  - `demo_role_tech_levels`
  - `demo_role_tech_traits`

## 字段说明
1. `demo_role_tech_levels`
- 作用：给每个兵种设定科技等级（当前用于解锁特性）。
- 示例：`"spear": 2` 表示枪兵解锁到2级特性。

2. `demo_role_tech_traits`
- 作用：定义每个兵种的特性列表（可用 `default` 作为通用模板）。
- 每条特性支持：
  - `id`: 唯一标识
  - `name`: 显示名称
  - `description`: 描述
  - `unlock_level`: 解锁等级
  - `duration_sec`: 持续时间（`0` 表示常驻）
  - `stack_rule`: 叠加规则（`additive` / `max` / `override`）
  - `max_stacks`: 最大叠层
  - `effects`: 实际生效字段

3. `effects` 可用键
- `tech_attack_bonus_pct`
- `tech_defense_bonus_pct`
- `tech_speed_bonus_pct`
- `tech_magic_attack_bonus_pct`
- `tech_magic_defense_bonus_pct`
- `tech_range_bonus_flat`
- `tech_spirit_cost_reduction_pct`
- `tech_morale_cap_bonus`
- `tech_spirit_cap_bonus`

## 当前默认行为
- 默认提供3条通用特性 + 3条策士特性模板。
- 默认等级为 `0`，即不生效，不会改变现有战斗平衡。
- 想启用时只需把 `demo_role_tech_levels` 对应兵种调高到 `1~3`。
