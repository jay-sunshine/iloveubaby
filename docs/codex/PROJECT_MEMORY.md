# Project Memory (Codex)

## Project Snapshot
- Project: 灞辨渤蹇楅璧锋眽鏈?- Engine: Godot 4.6 (`Forward Plus`)
- Physics: Jolt Physics
- Main scene: `res://scenes/main.tscn`
- Main bootstrap script: `res://scripts/engine/strategy_bootstrap.gd`

## Runtime Entry Structure
1. `StrategyMain` uses `strategy_bootstrap.gd` as game bootstrap.
2. `MapView` handles world/map presentation (`strategy_map_view.gd`).
3. `UILayer` handles strategy UI (`strategy_ui_layer.gd`).
4. `StrategicSites` and `CitySites` use `strategic_site_manager.gd`.
5. `PreloadManager` runs preload flow (`preload_manager.gd`).
6. `scenes/china_terrain_30km.tscn` also has its own runtime interaction path in `scripts/presentation/china_terrain_scene.gd`; city command UI there is not driven by `strategy_bootstrap.gd`.

## Core Data and Rules
- World state: `res://data/config/world_state.json`
- Rules loaded by bootstrap:
  - `internal_affairs_rules.json`
  - `battle_rules.json`
  - `general_rules.json`
  - `diplomacy_rules.json`
  - `ai_rules.json`
  - `engine_rules.json`
  - `presentation_rules.json`
  - `regroup_rules.json`
  - `fire_rules.json`
  - `weather_settings.json`
- Officer roster: `res://data/config/officer_roster_san14_like_v1.json`

## Current Architecture Intent
1. Data source layer: `scripts/data/*` (JSON loading and repository bootstrap).
2. Logic layer: `scripts/logic/*` (facade + modules + API).
3. Presentation layer: `scripts/presentation/*` (map/city/site/UI rendering and interaction).
4. Bootstrap orchestration: `scripts/engine/strategy_bootstrap.gd`.

## Battle Runtime Notes
1. Movement walkability chain: `UnitController -> BattlefieldController.can_unit_walk_at_world(...) -> StrategyMapView.can_unit_walk_at_world(...)`.
2. Naval transport rules (boarding/disembark/ferry/shoal) are centralized in `scripts/battlefield_controller.gd` and tuned by `data/config/battle_rules.json` keys prefixed with `demo_naval_`.
3. Unit naval runtime state is stored in `scripts/unit_controller.gd` (`naval_embarked`, preferred/effective ship type).
4. Move orders now support staged targets in `UnitController` (auto multi-leg route), with route planning provided by `BattlefieldController.plan_unit_move_targets(...)`.
5. Strategy-layer expedition flow now opens `expedition_prepare` in `scripts/presentation/strategy_ui_layer.gd`; confirmed selections persist in `meta.city_orders` (`officer_ids`, `ship_type`, land/water profiles) through `scripts/engine/strategy_bootstrap.gd`.
6. `StrategyBootstrap` now converts active city expedition orders into `battle.team_a_deployment` at battle spawn time, and `BattlefieldController` consumes that deployment to seed team A commander identity, role composition, and preferred ship type.

## Working Conventions
1. Treat `scripts/engine`, `scripts/logic`, `scripts/presentation`, `data/config` as core runtime.
2. Treat `tmp/` and `tools/_tmp_*` as experiment/probe area.
3. New sessions must recover context from this file + task board + handoff log, not chat memory.
4. For benchmark/balance CSV review, treat externally interrupted or disconnect-caused all-timeout runs as invalid samples unless a handoff/note explicitly says they were uninterrupted gameplay results.

## User GDScript Iron Rules (Effective 2026-03-22)
1. Avoid abusive use of global variables, global static logic, and global cross-file class references.
2. Split scripts by node responsibility; do not centralize everything into one script.
3. Core entities (`city`, `officer`, `unit`, `tile`) should be independent scenes with independent scripts.
4. Keep gameplay numbers in Resource/config tables; do not hardcode balance values in runtime scripts.
5. Prefer signal-based communication between nodes; do not rely on brittle relative paths like `get_node("../...")`.
6. Keep AI logic isolated in a dedicated `AIController`-style node/module, decoupled from movement/render code.
7. Avoid unnecessary per-frame `_process`; use `Timer`/event-driven updates when possible.
8. For large-map performance, AI should scan local ranges, not full-map traversal.
9. Naming target for new work: script/class PascalCase, function camelCase, variables explicit and meaningful.
10. Deliver runnable code with a minimal usage path; avoid dead or placeholder logic.

## Iron Rule Compliance Snapshot
1. Current repository still has legacy deviations, including broad `class_name` usage, static caches, and many hardcoded runtime constants in core scripts.
2. Naming style in existing runtime is mostly snake_case (file and function level), which conflicts with the new naming target and should be migrated incrementally.
3. Multiple runtime paths still use `_process` and broad collection scans; future changes should prioritize event/timer and local-scope updates.

## Known Risks
1. Repository is very large with many temporary/probe files; easy to lose focus.
2. Some files contain mixed encoding history; avoid broad blind replacements.
3. Runtime tuning and balance work overlap; keep decisions logged in handoff entries.

## New Window Recovery Checklist
1. Read this file first.
2. Read `docs/codex/TASK_BOARD.md` and pick only one active target.
3. Read latest block in `docs/codex/SESSION_HANDOFF.md`.
4. Confirm "what is done / what is next / what is risky" before code edits.


