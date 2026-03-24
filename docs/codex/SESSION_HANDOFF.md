# Session Handoff Log

## 2026-03-19 23:20 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Solve context loss across new Codex windows for this repository.
- Done:
  - Added `AGENTS.md` with required session bootstrap steps.
  - Added `docs/codex/PROJECT_MEMORY.md` as the project context source.
  - Added `docs/codex/TASK_BOARD.md` as the active task source.
  - Added `docs/codex/SESSION_HANDOFF.md` as the handoff source.
  - Added `tools/codex/new_handoff.ps1` to append standardized handoff entries.
- Risks:
  - This is a process scaffold; it only works if every session maintains it.
  - If handoff is skipped, context quality will degrade quickly.
- Next:
  - Run one real development task end-to-end with this workflow.

## 2026-03-19 23:35 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fill task board with one concrete mainline and 3 deliverables.
- Done:
  - Replaced mojibake task board with ASCII version.
  - Set active mainline to battle balance v1.1 baseline lock.
- Risks:
  - Mainline is inferred from existing balance docs and may need reprioritization.
- Next:
  - Start deliverable #1 and run baseline verification with seed `620000`.

## 2026-03-20 10:07 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Implement naval transport rules similar to SAN14: all units (including siege) can board, `zouge` can use shoals, advanced ships ferry-only.
- Done:
  - Added naval runtime state to units in `scripts/unit_controller.gd`:
    - `naval_embarked`, ship type helpers, panel-state exposure.
    - Naval direct-path fallback (`is_unit_naval_direct_path_required`) for cross-water movement.
  - Extended battle walkability pipeline in `scripts/battlefield_controller.gd`:
    - `can_unit_walk_at_world(world_pos, unit)` now supports per-unit naval logic.
    - Auto embark/disembark transitions in unit motion resolution.
    - Ferry cache + shoal detection + ship-type restrictions.
    - Group command targeting now resolves walkability per selected unit.
  - Added naval rule configs in `data/config/battle_rules.json` (`demo_naval_*`).
  - Updated task board to current naval implementation scope.
  - Updated project memory with new battle/naval architecture notes.
  - Validation: `godot4 --headless --check-only --path .` passed.
- Risks:
  - Ferry points rely on strategic-site snapshots; if current battle map has no ferry data, advanced ships will be heavily constrained.
  - Ship type is currently auto-resolved by role/default rules (no player-side ship selector UI yet).
  - Shoal detection is proximity-based (coastline sampling), not an authored terrain tag.
- Next:
  - Add explicit ship-type command/UI (or per-unit preset editor hook), then run a battle demo pass with visible ferry markers and confirm restrictions in playtest.

## 2026-03-20 10:32 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Align naval UX with request: no in-battle manual switch, auto route via ferry for advanced ships.
- Done:
  - Added staged move pipeline in `scripts/unit_controller.gd`:
    - `issue_move_order` / `issue_attack_move_order` now use planner output and support multi-leg routing.
    - Added `staged_move_targets` queue and automatic stage activation when each leg arrives.
  - Added route planner in `scripts/battlefield_controller.gd`:
    - `plan_unit_move_targets(...)` + ferry selection helpers.
    - Advanced ships now auto plan `land -> ferry -> water -> ferry -> land` when needed.
  - Updated right-click move/attack-move command issue path to avoid premature block on water clicks and let per-unit planner decide.
  - Updated project memory with staged-route architecture note.
  - Validation: `godot4 --headless --check-only --path .` passed.
- Risks:
  - Ferry pairing is nearest-point heuristic; complex river networks may still need improved pairing cost logic.
  - `走舸` long-distance auto embark point search is not yet staged (current focus is advanced ship ferry automation).
- Next:
  - Run battle demo scenario test focused on three cases:
    1) advanced ship clicking water from inland auto-routes via ferry;
    2) advanced ship shallow embark is blocked;
    3) `走舸` shallow embark remains allowed.

## Handoff Template
- Owner:
- Goal:
  - 
- Done:
  - 
- Risks:
  - 
- Next:
  - 

## 2026-03-20 12:52 (China Standard Time)
- Owner: Codex
- Goal:
  - Run seed 620000 baseline reverify and confirm whether the current front6 lock_env benchmark still matches the relock baseline.
- Done:
  - Re-scoped the task board to seed 620000 baseline reverify, confirmed from existing reports that current CTRL 200-match reverify (`ab200_reverify_20260320_ctrl_tune1_matches_20260320_095157.csv`) is 200/200 timeout with avg_sim_sec=240.000 and avg_inf=11834.618, and confirmed from today's quick20 front6 smoke files that CTRL/XIONGLUE/HUOSHEN are all 20/20 timeout at avg_sim_sec=240.
- Risks:
  - Current battle benchmark is in a collapsed timeout state, so running more 200-match suites now would spend a lot of machine time while producing low-value all-timeout data; also Godot headless requires `--log-file` in this environment because default `user://logs` crashes.
- Next:
  - Diff battle logic and battle-rule changes after the 2026-03-17 front6 relock, identify the exact timeout trigger, then rerun a small seed 620000 smoke check before any new battle feature work.

## 2026-03-20 12:53 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Hook the pre-expedition ship selector into the expedition UI and reshape the panel toward a SAN11-like composition screen.
- Done:
  - Updated `scripts/engine/strategy_bootstrap.gd` so city `expedition_start` opens `expedition_prepare` instead of directly toggling active state.
  - Connected `StrategyUILayer.expedition_plan_confirmed` back into bootstrap and persisted `officer_ids`, `officer_names`, `ship_type`, `ship_label`, `combined_stats`, `land_profile`, and `water_profile` into `meta.city_orders`.
  - Completed expedition confirm handling in `scripts/presentation/strategy_ui_layer.gd` and added missing expedition-only visibility/layout helpers.
  - Added a SAN11-like expedition panel layout: left side is 3 vertical officer slots plus combined five stats and ship selector; right side shows land/water profile text plus shared radar chart.
  - Updated task board and project memory to reflect the new active naval-UX follow-up.
  - Validation: `godot4 --headless --check-only --path .` passed.
- Risks:
  - The expedition slots are currently selector cards with stat text, not portrait cards yet; visual fidelity is layout-correct but not fully picture-matched to SAN11.
  - Stored expedition selections are only persisted in strategy meta for now; downstream battle spawn/deployment still needs to consume `city_orders` data.
  - No live playtest was run in-window, so spacing still needs an in-editor visual pass at the target UI resolution.
- Next:
  - Open the strategy scene and visually tune expedition spacing/font sizes; if needed, add portrait rendering to the three officer slots.
  - When expedition-to-field deployment is implemented, read `meta.city_orders[city_id]` so chosen officers and ship type drive spawned unit defaults.

## 2026-03-20 13:08 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix the blank expedition panel specifically in `ChinaTerrain30km` without force-creating runtime nodes.
- Done:
  - Traced the blank panel to the runtime-specific path in `scripts/presentation/china_terrain_scene.gd`, not `scripts/engine/strategy_bootstrap.gd`.
  - Confirmed `ChinaTerrain30km` was still sending city `expedition_start` directly into `show_command_panel(action_id, _build_site_panel_data(...))`, which produced generic empty panel data and never entered `expedition_prepare`.
  - Added runtime-only expedition routing in `scripts/presentation/china_terrain_scene.gd`:
    - `expedition_start` now opens `expedition_prepare` with real city roster + ship options.
    - Connected `expedition_plan_confirmed` and stored runtime selection into `_runtime_city_orders`.
    - Added runtime expedition cancel handling and fed `_runtime_city_orders` back into the UI snapshot meta so city menu active/cancel state can reflect runtime selection.
  - Updated project memory to record that `china_terrain_scene.gd` is a separate UI command path from `strategy_bootstrap.gd`.
  - Validation: `godot4 --headless --check-only --path .` passed.
- Risks:
  - `ChinaTerrain30km` currently stores expedition setup only in runtime memory (`_runtime_city_orders`), not back into persistent world-state JSON.
  - This fix wires the front-end composition flow; downstream runtime deployment still needs to consume the stored officer/ship selection if the scene later spawns expedition field units from city orders.
- Next:
  - Run an in-scene visual test in `ChinaTerrain30km` and verify city `expedition_start` now opens the populated composition UI instead of a blank panel.
  - If runtime expedition deployment is added later, read `_runtime_city_orders[city_id]` when spawning field units so selected officers and ship type actually affect runtime units.

## 2026-03-20 12:57 (China Standard Time)
- Owner: Codex
- Goal:
  - Correct the seed 620000 baseline review scope after user clarified the recent timeouts were disconnect-caused invalid samples.
- Done:
  - Reclassified today's all-timeout runs as disconnect-invalid samples instead of battle logic regressions, and updated the task board so the active work is baseline review with invalid timeout samples excluded.
- Risks:
  - Current CSV output distinguishes timeout but not disconnect cause, so future review still needs a note on whether a run was interrupted externally.
- Next:
  - Continue seed 620000 baseline review using stable/usable samples only, and do not spend time chasing disconnect-caused timeout data.

## 2026-03-20 13:24 (China Standard Time)
- Owner: Codex
- Goal:
  - Continue the seed 620000 baseline review by separating usable historical anchors from disconnect-invalid reruns.
- Done:
  - Updated the task board back to seed 620000 baseline review, audited key reports, and wrote `tmp/reports/seed620000_review_20260320.md` to classify usable anchors versus disconnect-invalid 2026-03-20 reruns. Confirmed that the usable anchors are the 2026-03-16 legacy tune1 trio and the 2026-03-17 front6 relock suite, while today's all-timeout quick20/reverify/probe files should be excluded from baseline judgment.
- Risks:
  - The CSV format records timeout but not disconnect cause, so future interrupted runs can still be misread unless a note is added alongside the report prefix or handoff.
- Next:
  - Use the 2026-03-17 front6 relock set as the active baseline reference, and only schedule a new seed 620000 rerun after a stable uninterrupted smoke run is confirmed.

## 2026-03-20 13:30 (China Standard Time)
- Owner: Codex
- Goal:
  - Add a lightweight repo rule so disconnect/interrupted benchmark runs are not misread as valid baseline samples in future sessions.
- Done:
  - Added a benchmark sample validity rule to `docs/codex/PROJECT_MEMORY.md` and added section 20 in `docs/balance/personality_baseline.md` defining interrupted/disconnect-caused runs as invalid samples unless explicitly confirmed uninterrupted.
- Risks:
  - This is a documentation/process guard only; CSV files still do not encode disconnect cause, so people must keep writing the note in handoff or review files.
- Next:
  - When a future benchmark rerun is interrupted, mark it in the latest handoff and any temporary review note before using the CSV in balance conclusions.

## 2026-03-20 13:41 (China Standard Time)
- Owner: Codex
- Goal:
  - Add the interrupted-sample reminder to the new-window bootstrap prompt so future sessions do not misread disconnect-invalid benchmark CSVs.
- Done:
  - Rewrote `docs/codex/NEW_WINDOW_PROMPT.md` into clean UTF-8 text and added a startup reminder that all-timeout quickcheck/reverify samples must be checked for disconnect/interruption before being treated as gameplay regressions.
- Risks:
  - The prompt reduces operator error but still depends on the session actually following it; CSV files themselves still do not encode disconnect cause.
- Next:
  - Use the updated new-window prompt as the default bootstrap text for future Codex sessions in this repo.

## 2026-03-20 13:53 (China Standard Time)
- Owner: Codex
- Goal:
  - Formally close the seed 620000 baseline review and advance the task board back to the next mainline.
- Done:
  - Updated `tmp/reports/seed620000_review_20260320.md` with a task-closure section, recording that the active baseline reference remains the `2026-03-17` front6 relock set and that the 2026-03-20 all-timeout reruns must not be used for balance judgment. Updated `docs/codex/TASK_BOARD.md` to mark the seed 620000 review done and move `Naval transport follow-up` back into `In Progress`.
- Risks:
  - The next naval follow-up scope is intentionally kept broad until the user picks the exact change, so the next session should confirm the concrete subtask before editing runtime files.
- Next:
  - Resume the naval transport follow-up by identifying the exact requested UI/runtime change from the latest gameplay need, then implement it with focused validation.

## 2026-03-22 10:14 (China Standard Time)
- Owner: Codex
- Goal:
  - Clarify that the new-window prompt is a fallback for the user, while Codex should still auto-bootstrap by reading project memory/task board/handoff at session start.
- Done:
  - Updated `docs/codex/NEW_WINDOW_PROMPT.md` so it now explicitly says the text is optional fallback text, not something the user must paste every time, and that Codex should perform the bootstrap read automatically in a new session.
- Risks:
  - This improves the wording but still depends on future sessions following the repository bootstrap rule.
- Next:
  - Keep using automatic bootstrap on new sessions; only use the prompt text when a manual fallback is helpful.

## 2026-03-22 12:19 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Audit the newly provided GDScript iron rules against the current repository and persist the rule set into project memory for all future sessions.
- Done:
  - Performed a targeted compliance scan across core scripts (`scripts/engine`, `scripts/logic`, `scripts/presentation`, `scripts/unit_controller.gd`) and identified legacy deviations (global `class_name`/static usage, hardcoded constants, `_process` loops, naming-style mismatch).
  - Added `User GDScript Iron Rules (Effective 2026-03-22)` to `docs/codex/PROJECT_MEMORY.md`.
  - Added `Iron Rule Compliance Snapshot` to `docs/codex/PROJECT_MEMORY.md` so future sessions can see current gaps before editing.
- Risks:
  - Existing runtime still carries significant legacy style/architecture debt; strict full compliance cannot be reached instantly without broad refactor risk.
  - Rule #9 naming target (PascalCase/camelCase) conflicts with current repository-wide snake_case conventions, so migration needs staged planning.
- Next:
  - Enforce these iron rules for all new/modified code paths, and handle legacy debt incrementally per active task scope (do not do mass rename/refactor in one pass).

## 2026-03-22 12:42 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Make expedition preparation data actually affect battle-side unit deployment in the naval follow-up path.
- Done:
  - Updated `scripts/engine/strategy_bootstrap.gd` so `_spawn_battle_demo()` builds `team_a_deployment` from active city `meta.city_orders` (officer ids, ship type) and passes it into `BattlefieldController`.
  - Added expedition-to-battle mapping helpers in `strategy_bootstrap.gd`:
    - city order lookup (`_get_city_order_entry`)
    - ship normalization (`_normalize_battle_ship_type`)
    - officer aptitude parsing/role resolution (`_officer_aptitude_map`, `_resolve_officer_combat_role`)
    - deployment build (`_build_battle_team_a_deployment`)
  - Extended `scripts/battlefield_controller.gd` with `team_a_deployment` consumption:
    - normalize deployment entries, merge deployment roles over default team A role list
    - apply per-unit deployment fields (commander identity, aptitude override, personality trait seed, preferred ship type)
  - Updated `docs/codex/PROJECT_MEMORY.md` battle notes to record that expedition orders now feed battle team A deployment.
- Risks:
  - Current deployment application targets the strategy bootstrap battle path; `ChinaTerrain30km` runtime path still keeps separate runtime order memory and may need a mirrored hook if it later reuses `BattlefieldController` spawn logic.
  - Godot binary is unavailable in this shell (`godot4`/`godot` not found), so no headless check-only validation was possible in-session.
  - Role mapping from officer aptitude uses deterministic heuristic by slot priority; this is functional but may need design tuning.
- Next:
  - Run an in-engine playtest: select expedition officers/ship in city panel, enter battle, and verify team A shows chosen commanders plus expected ship behavior.
  - If design wants stricter role control, add explicit role selection into expedition UI payload (instead of aptitude-derived inference).

## 2026-03-22 14:00 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Enlarge the default project run window so the game starts in a larger desktop window.
- Done:
  - Verified window sizing is controlled by `project.godot` and found no runtime `DisplayServer` override path for startup size/mode.
  - Updated `project.godot` display window size from `1600x800` to `1920x1080`.
  - Updated `docs/codex/TASK_BOARD.md` to reflect this temporary in-progress runtime UX quick fix.
- Risks:
  - On displays smaller than 1920x1080, the OS/window manager may clamp or offset the startup window.
  - Godot binary is unavailable in this shell, so no in-session run validation was possible.
- Next:
  - Launch once and confirm the new startup window size is acceptable on the target display.
  - After UX confirmation, switch `TASK_BOARD` `In Progress` back to naval transport follow-up.

## 2026-03-22 14:29 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Upgrade `ChinaTerrain30km` mountain visuals with a more realistic rock texture set while keeping terrain shading on a low-overhead packed-texture path.
- Done:
  - Updated `docs/codex/TASK_BOARD.md` so the active scoped task is now the `ChinaTerrain30km` mountain material optimization.
  - Generated packed terrain textures in `素材/textures/`:
    - `aerial_rocks_02_packed_albedo_height.png` (`aerial_rocks_02_diff_2k.jpg` RGB + `aerial_rocks_02_disp_2k.png` alpha)
    - `aerial_rocks_02_packed_normal_roughness.png` (`素材/nature/textures/rock-norm.png` RGB + `aerial_rocks_02_rough_2k.jpg` alpha)
  - Updated `scenes/china_terrain_30km.tscn` rock `Terrain3DTextureAsset` to use the new packed textures and raised `normal_depth` from `0.55` to `0.72` for stronger mountain relief.
- Risks:
  - The packed normal/roughness texture currently reuses the existing `rock-norm.png` RGB because no EXR-capable conversion tool was available in-session for `aerial_rocks_02_nor_gl_2k.exr`; visual fit should still improve, but it is not a full-source-set replacement yet.
  - New packed PNGs do not have pre-generated Godot import artifacts in this shell; the editor/runtime should import them on next project open, but this was not exercised in-session.
  - Godot executable is still unavailable here, so no live camera/view validation was possible.
- Next:
  - Open `scenes/china_terrain_30km.tscn` in Godot once so the new packed textures import, then inspect a few mountain ranges at gameplay camera height.
  - If the relief still feels weak or the normal pattern mismatches the albedo, convert `素材/textures/aerial_rocks_02_nor_gl_2k.exr` into a Terrain3D packed normal/roughness texture and retune `normal_depth` from there.

## 2026-03-22 14:43 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Resolve the white Terrain3D surface caused by mixed texture-prep formats and switch the grass layer to the requested `aerial_grass_rock` set.
- Done:
  - Confirmed the white terrain came from mixed Terrain3D texture formats: the new rock layer used packed albedo/height + packed normal/roughness while the grass layer still used the old unpacked pair.
  - Generated `素材/textures/aerial_grass_rock_packed_albedo_height.png` from `aerial_grass_rock_diff_2k.jpg` + `aerial_grass_rock_disp_2k.png`.
  - Generated `素材/textures/aerial_grass_rock_packed_normal_roughness.png` from existing grass normal RGB + `aerial_grass_rock_rough_2k.jpg` alpha.
  - Updated both grass packed `.import` files to the same s3tc + mipmap + Terrain3D-compatible import settings used by the packed rock files.
  - Updated `scenes/china_terrain_30km.tscn` so both terrain layers now use packed textures consistently and retuned parameters for top-down readability:
    - Grass: `normal_depth 0.24`, `roughness 0.92`, `uv_scale 0.065`
    - Rock: `normal_depth 0.62`, `roughness 0.98`, `uv_scale 0.095`
- Risks:
  - Godot may still hold stale imported cache for the old packed textures until the editor reimports or restarts.
  - Both packed normal/roughness textures still reuse legacy normal-map RGB because no EXR-capable conversion tool was available in-session; roughness/height are from the new aerial sets, but normals are not yet fully source-matched.
- Next:
  - Restart Godot or manually reimport the four packed textures, then confirm the Terrain3D red errors disappear and the white surface is gone.
  - If the terrain still looks off after clean reimport, convert the two `*_nor_gl_2k.exr` files into matching packed normal/roughness textures to finish the full source-set swap.

## 2026-03-22 15:22 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Start the real-main-scene (`ChinaTerrain30km`) troop workflow by making regroup functional in the runtime scene and exposing all troop classes in the regroup UI.
- Done:
  - Updated `scripts/presentation/china_terrain_scene.gd` to load/cache `regroup_rules.json`, connect `StrategyUILayer.regroup_plan_confirmed`, and route city `regroup` actions to a real runtime regroup panel instead of the old empty placeholder payload.
  - Added runtime regroup dataset builders in `china_terrain_scene.gd`, including external troop-source normalization from `docs/troop_6class_3tier_standard.json`, inline siege-unit merge from `data/config/regroup_rules.json`, localized troop-category labels, and readable per-tier unit names so cavalry/spear/shield/bow/crossbow/siege/strategist all appear in the real main-scene regroup panel.
  - Added runtime regroup plan evaluation + apply flow in `china_terrain_scene.gd`: validates costs/batch sizes/reserves/siege durability, consumes command points, writes updated city `resources`, `stats.reserve_troops`, `stats.organized_troops`, `unit_composition`, and `siege_durability` back into the runtime world cache via `_upsert_world_city`.
  - Updated `docs/codex/TASK_BOARD.md` so the active task now matches the user-confirmed ChinaTerrain30km regroup/expendition workstream.
- Risks:
  - This first pass intentionally keeps regroup logic local to `ChinaTerrain30km`; `strategy_bootstrap.gd` still has a separate regroup implementation, so there is temporary duplication until a shared helper is extracted.
  - No Godot executable is available in this shell, so the regroup UI and new runtime data path were only statically verified.
  - `git` is not available in this shell either, so I could not use `git diff`/history tools for extra validation.
- Next:
  - Open a player-owned city in `scenes/china_terrain_30km.tscn`, verify the regroup panel now lists all troop classes and can successfully apply a plan.
  - After regroup is confirmed, extend expedition preparation to choose from existing regrouped troops plus ship type instead of officer-only selection.

## 2026-03-22 15:41 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Align the `ChinaTerrain30km` regroup UX with the clarified design: no manual three-tier troop selection, no explicit add-to-plan workflow, and direct per-class quantity adjustment.
- Done:
  - Updated `scripts/presentation/china_terrain_scene.gd` so runtime regroup no longer expands the external troop table into separate tier entries. It now collapses each class (`cavalry`, `spear`, `shield`, `bow`, `crossbow`, `siege`, `strategist`) into one regroup row, while applying `regroup_rules.json` `tech_traits` automatically based on city `stats.tech_points`.
  - Extended regroup panel payload with current `unit_composition`, so the UI can display each troop class's current quantity in the real main scene.
  - Updated `scripts/presentation/strategy_ui_layer.gd` regroup UX to show per-class `current / delta / after` values directly in the unit list and adjustment summary, relabeled buttons to `���� / ���� / ���õ���`, and switched detail text from plan-centric wording to direct quantity-adjustment wording.
  - Added remaining-reserve-aware regroup adjustment limits in `strategy_ui_layer.gd`, so multi-class adjustments respect available reserve troops before confirmation instead of only failing at final submit time.
- Risks:
  - The regroup summary still reuses the existing bottom list control as an adjustment summary; visually it is lighter-weight than a fully redesigned dedicated quantity table.
  - No Godot executable is available in this shell, so the single-class regroup presentation and direct-adjustment interaction were only statically verified.
- Next:
  - Open `scenes/china_terrain_30km.tscn` and verify regroup now shows one row per troop class with current quantities and direct increases.
  - If the flow feels right, continue with expedition preparation so it consumes existing regrouped troop classes rather than officer-only selection.

## 2026-03-22 14:50 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Swap the grass base layer albedo to `rocky_terrain_02_diff_2k.jpg` while preserving Terrain3D packed-format compatibility.
- Done:
  - Generated `�ز�/textures/rocky_terrain_02_packed_albedo_height.png` from `rocky_terrain_02_diff_2k.jpg` + `rocky_terrain_02_disp_2k.png`.
  - Updated `�ز�/textures/rocky_terrain_02_packed_albedo_height.png.import` to Terrain3D-compatible s3tc + mipmaps import settings.
  - Updated `scenes/china_terrain_30km.tscn` grass layer to use the new packed albedo/height texture while keeping the current packed normal/roughness texture.
  - Retuned grass readability for the rockier base color: `normal_depth 0.18`, `roughness 0.95`, `uv_scale 0.052`.
- Risks:
  - Grass layer is currently a hybrid setup: new `rocky_terrain_02` albedo/height with the existing packed grass normal/roughness, because no EXR-capable conversion tool was available in-session for the matching `rocky_terrain_02_nor_gl_2k.exr` and `rocky_terrain_02_rough_2k.exr`.
  - Godot may need manual reimport or restart before the new packed albedo/height texture replaces cached imports.
- Next:
  - Reimport `rocky_terrain_02_packed_albedo_height.png`, then inspect whether the grass base reads as natural ground at strategy zoom.
  - If the new base color works, finish the full same-source grass pack by converting the matching `rocky_terrain_02` normal/roughness maps.

## 2026-03-22 15:02 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Repair `china_terrain_30km.tscn` parse failure and move the grass layer fully onto the `rocky_terrain_02` packed set as far as local tooling allows.
- Done:
  - Repaired unmatched quotes in `scenes/china_terrain_30km.tscn` caused by previously broken mojibake string literals, restoring parseable scene text.
  - Corrected `res://�ز�/...` paths that had been accidentally rewritten into mojibake in the scene and related packed-texture `.import` files.
  - Generated `�ز�/textures/rocky_terrain_02_packed_normal_roughness.png` and wired the grass layer to it in `scenes/china_terrain_30km.tscn`.
  - The new grass packed normal/roughness uses current ground normal RGB plus roughness inferred from `rocky_terrain_02_spec_2k.png` alpha inversion, because the source `rocky_terrain_02_nor_gl_2k.exr` / `rocky_terrain_02_rough_2k.exr` cannot be decoded by the tools available in-session.
- Risks:
  - Grass normal is still a proxy, not the true `rocky_terrain_02` normal, so surface micro-shape is only partially same-source.
  - Godot should reimport the new packed normal/roughness texture on next scan/restart; cached import state may hide the change until then.
  - `rocky_terrain_02_*exr.import` remains dependent on engine/tool support for EXR import, which appears unavailable in this shell.
- Next:
  - Reopen or reimport `rocky_terrain_02_packed_albedo_height.png` and `rocky_terrain_02_packed_normal_roughness.png`, then verify the scene opens without parse errors and the grass layer no longer points to `aerial_grass_rock` assets.
  - If you want the true same-source normal and roughness, run a converter that can read EXR and rebuild `rocky_terrain_02_packed_normal_roughness.png` from the original `rocky_terrain_02_nor_gl_2k.exr` + `rocky_terrain_02_rough_2k.exr`.

## 2026-03-22 15:10 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix the persistent `china_terrain_30km.tscn` parse failure reported as `line 1: Expected '['`.
- Done:
  - Confirmed the scene file had a UTF-8 BOM prefix (`EF BB BF`) before `[gd_scene ...]`, which Godot was treating as unexpected data at line 1.
  - Rewrote `scenes/china_terrain_30km.tscn` as UTF-8 without BOM; file now begins directly with `[`.
- Risks:
  - Godot may keep the earlier failed parse result until the scene tab is reopened or the editor refreshes the resource.
- Next:
  - Close and reopen `res://scenes/china_terrain_30km.tscn`; if it still fails, capture the new console line because the old line-1 parse error should now be cleared.

## 2026-03-22 15:18 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Finish `rocky_terrain_02` grass normal/roughness packing with Godot-native EXR decoding and verify `china_terrain_30km.tscn` loads successfully.
- Done:
  - Located the running Godot editor executable at `E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe`.
  - Used a temporary Godot script in `tmp/pack_rocky_terrain_02_normal_roughness.gd` to load `rocky_terrain_02_nor_gl_2k.exr` and `rocky_terrain_02_rough_2k.exr`, then wrote a true `rocky_terrain_02_packed_normal_roughness.png` with normal RGB + roughness alpha.
  - Used a second temporary Godot script in `tmp/verify_china_terrain_scene_load.gd` to load `res://scenes/china_terrain_30km.tscn`; result was `LOAD_OK`.
  - Confirmed the line-1 parse error root cause had been the UTF-8 BOM and that the scene file now starts directly with `[gd_scene ...]`.
- Risks:
  - The editor window may still show the old failed parse until the scene tab is closed and reopened.
  - If the editor cached the previous import result for `rocky_terrain_02_packed_normal_roughness.png`, it may need a manual reimport once.
- Next:
  - Reopen `res://scenes/china_terrain_30km.tscn` in the editor and reimport `rocky_terrain_02_packed_normal_roughness.png` if the viewport still shows the previous grass response.

## 2026-03-22 16:56 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - 为 ChinaTerrain30km 主场景的出征流程补上特种兵前置数据，让主将专属特种兵先在运行时 roster、出征界面和出征 payload 中可见。
- Done:
  - 在 scripts/presentation/china_terrain_scene.gd 增加特种兵规则读取辅助、解锁状态读取和军官特种兵标注逻辑；城市 roster 现在会给符合条件的武将附带 special_troop_* 字段。
  - 在 scripts/presentation/strategy_ui_layer.gd 的出征界面中，为武将五维文本追加特种兵状态，并在主将提示里显示特种兵名称、基底兵种、解锁状态和解锁代价。
  - 扩展出征 payload，透传 main_special_troop_* 字段，供后续真正接入整编兵种出征时直接消费。
  - 修正 data/config/special_troop_rules.json 中文内容，当前已包含白马义从、陷阵营、藤甲兵三条规则。
- Risks:
  - 当前出征系统仍未真正选择“主将带哪类整编兵种”，所以特种兵仍只是前置展示与数据透传，尚未在出征确认时转化为实际部队。
  - 本轮没有接入“付费解锁”交互，special_troop_unlocks 仍仅读取 world_state.meta，未提供 UI 写入路径。
  - 本地缺少 Godot 运行环境，本次仅做了静态检查和 JSON 解析校验。
- Next:
  - 先把出征编成改成直接使用现有整编部队/兵种；确定主将所带基底兵种后，再把“已解锁特种兵自动替换对应兵种”接到出征确认和战场生成链路。

## 2026-03-22 15:27 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Approximate `small hills finer / big mountains coarser` using the existing two active Terrain3D layers without introducing new control maps.
- Done:
  - Retuned the base `Grass` layer (currently `rocky_terrain_02`) to behave as a finer rocky ground layer: `normal_depth 0.14`, `roughness 0.96`, `uv_scale 0.072`.
  - Retuned the `Rock` layer (currently `aerial_rocks_02`) to behave as a coarser cliff layer: `normal_depth 0.40`, `roughness 0.90`, `uv_scale 0.055`.
  - Softened global terrain transitions further with `blend_sharpness 0.52` and `projection_threshold 0.42`.
  - Re-ran headless load verification; scene file still loads, while the remaining reported parse errors are in unrelated `strategy_ui_layer.gd` script dependencies already present outside this texture task.
- Risks:
  - This is still an approximation based on layer role (fine base vs coarse cliff), not a true mountain-size-aware shader. Large painted hill areas may still need manual texture paint cleanup if the original control map assigned too much cliff layer.
  - Unrelated GDScript parse issues in `res://scripts/presentation/strategy_ui_layer.gd` continue to appear during headless script reload and were not changed in this task.
- Next:
  - Check an in-game mountain view; if cliffs still look too busy, lower the rock layer `uv_scale` once more toward `0.048` or reduce rock-painted coverage in the control map.

## 2026-03-22 17:20 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Optimize the generic city building mesh for `ChinaTerrain30km` so the large map uses a lighter default city asset.
- Done:
  - Measured `素材/建模/建筑单位/chengchi.glb` in Blender headless mode: 1 mesh object, about 39,656 vertices / 49,980 triangles.
  - Generated `素材/建模/建筑单位/chengchi_ct30_low.glb` via Blender cleanup + automatic topology simplification (`remove_doubles`, limited planar dissolve, decimate collapse). The optimized mesh now imports at about 12,751 vertices / 10,402 triangles.
  - Updated `scripts/presentation/china_city_overlay.gd` so `ChinaTerrain30km` now routes default city instances to `res://素材/建模/建筑单位/chengchi_ct30_low.glb` instead of the original `chengchi.glb`.
  - Updated `docs/codex/TASK_BOARD.md` so the active task reflects the current ChinaTerrain30km large-map city asset optimization work.
- Risks:
  - This is an automatic retopo/decimate pass intended for top-down large-map viewing, not a hand-authored close-up production mesh; fine silhouette or roof-edge details may be softer.
  - The exported lowpoly `.glb` is only slightly smaller on disk because texture payload still dominates file size; the main win is reduced scene geometry cost, not package size.
  - `luoyang.glb` is still the original asset; only the generic `chengchi` path was optimized in this turn.
  - No Godot editor/runtime visual verification was available in-session, so scene appearance was validated by mesh statistics only.
- Next:
  - Open `scenes/china_terrain_30km.tscn` and inspect several generic city instances at the common camera heights used in play; if the silhouette is acceptable, repeat the same dedicated lowpoly pass for `luoyang.glb`.

## 2026-03-22 17:29 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - 优化 ChinaTerrain30km 的出征编成界面：武将栏位不再显示五维，改为显示战斗个性/特技，并把选将改成二级列表窗口。
- Done:
  - 在 scripts/presentation/strategy_ui_layer.gd 把出征栏位从下拉框改成按钮式栏位，点击主将/副将栏位会弹出二级武将列表窗。
  - 新增出征挑将窗口，列表列出武将、战斗个性、特技、特种兵，并提供详情区、确定任用、设为空缺、关闭按钮。
  - 出征栏位文案改为 战斗个性 / 特技 / 特种兵，移除了武将五维展示；未选择武将时不再自动填充本城前三人，而是保持空缺等待手动选择。
  - 顺手修正了出征界面的船型、标题、提示文本和特种兵提示中的中文乱码，避免这块继续扩散旧字符串问题。
- Risks:
  - 本轮仍是静态修改，当前 shell 里没有直接跑 Godot 编辑器验证界面交互，所以二级窗口的尺寸、遮挡和 Tree 交互还需要你在场景里点一次确认。
  - 出征流程仍未接入“使用整编后的实际兵种/数量”，所以这轮只解决挑将 UI 与信息展示，不包含真正按整编部队出征。
- Next:
  - 进 scenes/china_terrain_30km.tscn 实测出征编成，确认二级挑将窗手感后，继续把出征队伍改成直接消费现有整编部队与兵种。

## 2026-03-22 17:48 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Reduce the generic `ChinaTerrain30km` city asset texture payload after the first lowpoly pass, so the large map uses a lighter city package in memory and on disk.
- Done:
  - Verified that the generic city asset still carried three embedded 4096x4096 textures after the geometry-only pass.
  - Generated `素材/建模/建筑单位/chengchi_ct30_low_2k.glb` by importing the lowpoly city asset, resizing all embedded textures to 2048x2048 in Blender, and exporting a dedicated large-map GLB.
  - Confirmed the new asset imports with the same lowpoly geometry (`10,402` triangles) and three 2048x2048 textures; file size dropped from about `37.02 MB` (`chengchi_ct30_low.glb`) to about `11.38 MB`.
  - Updated `scripts/presentation/china_city_overlay.gd` so `ChinaTerrain30km` now defaults to `res://素材/建模/建筑单位/chengchi_ct30_low_2k.glb` for generic city instances.
  - Updated `docs/codex/TASK_BOARD.md` to reflect that the active city-asset optimization pass now covers both geometry and texture payload reduction.
- Risks:
  - This 2K pass is tuned for top-down large-map viewing; if the camera ever gets much closer to city roofs/walls, some texture sharpness may need a per-scene override.
  - Only the generic `chengchi` path was reduced; `luoyang.glb` and any other special-case city assets still use their heavier textures.
  - No Godot runtime visual verification was available in-session, so acceptance still depends on in-scene review.
- Next:
  - Open `scenes/china_terrain_30km.tscn` and compare city readability versus the previous build; if acceptable, apply the same lowpoly + 2K workflow to `luoyang.glb`.

## 2026-03-22 17:58 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Extend the `ChinaTerrain30km` large-map asset optimization pass beyond the generic city, covering `luoyang`, passes, ferries, and outposts.
- Done:
  - Measured `luoyang.glb`, `guanai.glb`, and `jindu.glb` in Blender. `luoyang.glb` was especially heavy at about `499,856` triangles; `guanai.glb` and `jindu.glb` were about `50,000` triangles each.
  - Generated dedicated large-map assets `素材/建模/建筑单位/luoyang_ct30_low_2k.glb`, `素材/建模/建筑单位/guanai_ct30_low_2k.glb`, and `素材/建模/建筑单位/jindu_ct30_low_2k.glb` with reduced geometry plus 2048x2048 embedded textures.
  - Verified the optimized imports: `luoyang_ct30_low_2k.glb` about `50,664` triangles, `guanai_ct30_low_2k.glb` about `10,874`, `jindu_ct30_low_2k.glb` about `10,861`, all with three `2048x2048` textures. File sizes are about `13.18 MB`, `11.86 MB`, and `10.85 MB` respectively.
  - Updated `scripts/presentation/china_city_overlay.gd` so the `ChinaTerrain30km` Luoyang special-case model path now points to `res://素材/建模/建筑单位/luoyang_ct30_low_2k.glb`.
  - Updated `scenes/prefabs/fortress_pass_instance.tscn` and `scenes/prefabs/fortress_ferry_instance.tscn` to use the new `guanai_ct30_low_2k` and `jindu_ct30_low_2k` assets.
  - Updated `scripts/presentation/fortress_site_instance.gd` to support a per-prefab `model_scale_multiplier`, then changed `scenes/prefabs/fortress_outpost_instance.tscn` to reuse `chengchi_ct30_low_2k.glb` with `model_scale_multiplier = 0.82` so outposts render as a smaller city silhouette instead of `wubao.glb`.
  - Updated `docs/codex/TASK_BOARD.md` to reflect that the active optimization task now covers all requested landmark types.
- Risks:
  - No Godot runtime/editor visual verification was available in-session, so the chosen Luoyang decimation ratio and the outpost `0.82` scale still need in-scene acceptance.
  - The `.tscn` files in this repo display mojibake in this shell due encoding/codepage mismatch, so text inspection is noisier than normal even though the files were rewritten without BOM.
  - Only the requested landmark set was optimized; other heavy scene assets may still dominate if camera density increases elsewhere.
- Next:
  - Open `scenes/china_terrain_30km.tscn` and inspect Luoyang, several passes/ferries, and multiple outposts at gameplay camera heights; if the outpost looks too city-like, reduce `model_scale_multiplier` further or derive a second city-based variant.

## 2026-03-22 15:40 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Force slopes below 39 degrees to grass and reduce the base grass layer's overly regular tiled look.
- Done:
  - Added and ran `tmp/apply_slope_39_grass_rule.gd` through Godot headless to rewrite Terrain3D control maps so slopes below `39��` use texture id `0` (grass) and steeper slopes use texture id `1` (rock).
  - Retuned the base grass/macro-variation parameters in `scenes/china_terrain_30km.tscn` to reduce neat blockiness:
    - `blend_sharpness` softened to `0.4`
    - `macro_variation1` / `macro_variation_slope` / `noise1_scale` / `noise2_scale` adjusted for broader macro breakup
    - grass `normal_depth` lowered to `0.10`, `roughness` raised to `0.97`, `uv_scale` adjusted to `0.082`
- Risks:
  - Because the control maps were rewritten directly, any earlier hand-painted grass/rock mask decisions are now replaced by the pure slope rule.
  - Unrelated parse issues still exist in `scripts/presentation/china_terrain_scene.gd`; they did not block this texture/control-map write, but they still appear in headless script reload.
- Next:
  - Open the terrain scene and visually inspect whether the 39�� split is too aggressive; if so, raise or lower the threshold by 2-4 degrees and rerun the slope script.

## 2026-03-22 22:35 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Finish the ChinaTerrain30km regroup -> expedition follow-up in the real main-scene runtime, restore clean GDScript parse state, and wire expedition troop allocation to organized troops plus main-commander special troop activation.
- Done:
  - Repaired the remaining historical parse blockers in `scripts/presentation/strategy_ui_layer.gd` and `scripts/presentation/china_terrain_scene.gd`; headless Godot parse check now loads both scripts cleanly again via `tmp/_tmp_verify_expedition_parse.gd`.
  - Kept the user-approved expedition model: officer selection remains a secondary list window, officer slots emphasize battle style / skill / special troop instead of five stats, and expedition confirm now requires troop allocation from the already organized troop pool.
  - Finished the expedition troop-allocation payload path in `scripts/presentation/strategy_ui_layer.gd`: selected organized troop composition is summarized in the expedition panel, sent as `troop_allocation` / `troop_total`, and combined with main-commander special troop preview fields such as `main_special_troop_active` and `effective_main_troop_*`.
  - Finished the scene-side validation/storage path in `scripts/presentation/china_terrain_scene.gd`: runtime expedition confirmation now validates allocation against current regrouped composition, stores the chosen troop allocation on the city order entry, and keeps the effective main troop / special troop activation result in the runtime order.
  - Normalized the most relevant regroup/expedition/aide UI strings that were still corrupted into stable English placeholders so the main scene no longer breaks on those bad literals while you continue iteration.
  - Corrected the weather particle preload paths in `scripts/presentation/china_terrain_scene.gd` to the actual `res://素材/brackeys_vfx_bundle/...` assets.
- Risks:
  - These two core scripts still contain a lot of legacy mojibake in older, less-used UI text outside the main regroup -> expedition path; they are parse-safe now, but not all visible labels are fully cleaned back to proper Chinese yet.
  - I validated by headless parse and field-path inspection, not by clicking through the full `scenes/china_terrain_30km.tscn` UI in the editor, so final acceptance still needs an in-scene interaction pass.
  - Some expedition/aide text is temporarily English for stability; if you want a full Chinese polish pass, it should be done as a focused cleanup after the interaction flow is confirmed.
- Next:
  - Open `scenes/china_terrain_30km.tscn`, verify the real flow `整编 -> 出征`, confirm that troop allocation uses the organized composition correctly, and check that a main commander with an unlocked matching special troop activates it only when the allocated troop class matches.
  - If the flow feels right, do a dedicated UI text cleanup pass for the remaining main-scene regroup / expedition / aide labels and convert the temporary English placeholders into final Chinese wording.

## 2026-03-22 19:21 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Retexture the generic large-map city asset so city walls use the user-provided sandstone material and the green inner ground areas switch to `rocky_terrain_02_diff_2k.jpg`.
- Done:
  - Confirmed the provided `C:\Users\Admin\Downloads\large_sandstone_blocks_01_2k.blend` path was actually a directory wrapper from an extracted asset pack; used `C:\Users\Admin\Downloads\large_sandstone_blocks_01_2k.blend.zip` and its `textures/large_sandstone_blocks_01_diff_2k.jpg` source instead.
  - Inspected `素材/建模/建筑单位/chengchi_ct30_low_2k.glb` and confirmed the city still uses one 2048x2048 base-color atlas plus existing normal/roughness maps.
  - Generated `素材/建模/建筑单位/chengchi_ct30_low_2k_retex_base.png` by compositing the current base atlas with tiled sandstone blocks on wall/stone regions and `res://素材/textures/rocky_terrain_02_diff_2k.jpg` on the olive-green inner-ground regions.
  - Exported the new asset `素材/建模/建筑单位/chengchi_ct30_low_2k_retex.glb`; verified it keeps the lowpoly geometry (`10,402` triangles) and uses the new 2048x2048 base texture while preserving the existing normal/roughness textures.
  - Updated `scripts/presentation/china_city_overlay.gd` so generic `ChinaTerrain30km` cities now use `res://素材/建模/建筑单位/chengchi_ct30_low_2k_retex.glb`.
  - Updated `scenes/prefabs/fortress_outpost_instance.tscn` so outposts (which were already reusing the city mesh) now also use the retextured city asset.
- Risks:
  - The atlas replacement is an automatic mask-based retexture pass, not a hand-painted UV edit; some non-wall pale stone surfaces may also inherit the sandstone block look.
  - I preserved the old normal/roughness maps, so shading detail still reflects the original asset rather than a fully sandstone-matched PBR set.
  - No Godot runtime/editor visual verification was available in-session, so final acceptance still depends on in-scene review.
- Next:
  - Open `scenes/china_terrain_30km.tscn` and inspect several generic cities and outposts; if the sandstone area is too broad or the inner ground still feels too green, tune the atlas mask thresholds or hand-paint a cleaner UV texture.

## 2026-03-22 15:49 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Reduce the base grass layer's visible repetition without changing texture sources again.
- Done:
  - Retuned grass anti-tiling parameters in `scenes/china_terrain_30km.tscn`:
    - `blend_sharpness` -> `0.28`
    - `macro_variation1` -> darker, more earthy green
    - `macro_variation2` -> brighter yellow-green
    - `noise1_scale` -> `0.009`
    - `noise2_scale` -> `0.043`
    - grass `normal_depth` -> `0.06`
    - grass `uv_scale` -> `0.11`
  - Verified the terrain scene still reports `LOAD_OK`; remaining headless errors are from unrelated prefab resource paths with mojibake paths.
- Risks:
  - If the grass now looks too soft or too broad, the next adjustment should be small (especially `uv_scale` and `blend_sharpness`).
- Next:
  - Inspect in-editor and, if needed, fine-tune grass `uv_scale` within roughly `0.10` to `0.125` rather than doing another big jump.

## 2026-03-22 20:17 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Refine the first sandstone/rocky city retexture pass after visual feedback: roofs were being over-painted with the wall texture, and inner ground needed to stay more grass-like.
- Done:
  - Sampled representative atlas colors from the original city base texture and tightened the sandstone mask so it only targets lighter, more neutral stone regions instead of broad low-saturation areas.
  - Reworked the inner-ground treatment so `rocky_terrain_02_diff_2k.jpg` is now used as subtle detail over the original grass base instead of replacing it almost outright.
  - Re-exported `素材/建模/建筑单位/chengchi_ct30_low_2k_retex.glb` and regenerated `素材/建模/建筑单位/chengchi_ct30_low_2k_retex_base.png` with the refined masks.
  - Verified the retextured GLB still imports with the expected three 2048x2048 textures.
- Risks:
  - The roof/wall separation is still mask-based atlas compositing rather than manual UV paint, so a few ambiguous pale roof stones or stone trims may still pick up a little sandstone tint.
  - Normal and roughness maps are still the original set; only base color changed.
- Next:
  - Reopen `scenes/china_terrain_30km.tscn` and inspect a few cities/outposts. If any roof zones still read wrong, the next step should be a hand-painted cleanup mask rather than more global threshold tuning.

## 2026-03-22 23:20 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Clear the remaining mojibake in the real `ChinaTerrain30km` regroup / expedition / aide flow and verify the main-scene scripts still parse cleanly.
- Done:
  - Verified the previously suspected JSON sources (`data/config/officer_roster_san14_like_v1.json`, `docs/troop_6class_3tier_standard.json`, `data/config/regroup_rules.json`, `data/config/battle_personalities_blue_v1.json`) are actually correct when read as UTF-8; the remaining mojibake was in script literals, not the source data.
  - Repaired the user-facing regroup / expedition / aide text literals in `scripts/presentation/strategy_ui_layer.gd`, including expedition troop button labels, officer slot empty-state text, battle personality / skill labels, main-commander special troop hints, and aide auto-recommend feedback.
  - Repaired the main-scene runtime panel text in `scripts/presentation/china_terrain_scene.gd`, including regroup panel titles, passive/unlock labels, default troop category labels, and aide panel titles for city / ferry water-transport assignment.
  - Kept the existing main-scene logic intact; this was a scoped text cleanup only, no regroup -> expedition data flow changes.
  - Re-ran the headless Godot verifier `tmp/_tmp_verify_expedition_parse.gd`; both `res://scripts/presentation/strategy_ui_layer.gd` and `res://scripts/presentation/china_terrain_scene.gd` load successfully.
- Risks:
  - I only cleaned the confirmed user-visible mojibake on the real regroup / expedition / aide path; older non-core UI branches elsewhere in these large scripts may still contain mixed Chinese/English wording.
  - I validated by UTF-8 source inspection plus headless parse, not by clicking through `scenes/china_terrain_30km.tscn` in-editor, so final acceptance still needs an in-scene interaction pass.
  - The temporary helper `tmp/_tmp_fix_ui_mojibake.ps1` remains in `tmp/` for traceability; it is not part of runtime.
- Next:
  - Open `scenes/china_terrain_30km.tscn` and verify the real `���� -> ����` UI now shows readable Chinese in troop categories, troop passive text, officer slot summaries, and aide assignment windows.
  - If the wording reads correctly, do one last small polish pass to convert the remaining English placeholders in the same main-scene flow into final Chinese text.

## 2026-03-22 20:30 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Respond to visual feedback from the Godot import preview: wall texture detail was too sparse (only one or two block repeats visible), while the inner ground still needed to read more like grass.
- Done:
  - Increased sandstone tiling density specifically for wall-cap stone regions from the previous broad pass to a much denser repeat, so the visible stone trim should no longer read as only one or two giant bricks.
  - Added a separate, very subtle treatment bucket for bright wall-body plaster regions instead of painting them with the same large sandstone pattern.
  - Made the ground treatment grass-dominant again, leaving only light rocky variation rather than strong rocky replacement.
  - Re-exported `素材/建模/建筑单位/chengchi_ct30_low_2k_retex.glb` and regenerated `素材/建模/建筑单位/chengchi_ct30_low_2k_retex_base.png` with the denser wall-cap tiling.
- Risks:
  - Because the atlas edit is still mask-driven and not UV-hand-painted, wall-cap and plaster separation is approximate.
  - The wall-body enhancement currently touches only a very small set of bright plaster pixels; if the user wants visible wall-surface detail, a dedicated wall-body material pass or hand-painted mask will be better.
- Next:
  - Reimport `chengchi_ct30_low_2k_retex.glb` in Godot and compare the wall-top stone rhythm; if it is still too coarse, increase the wall-cap tile density again or isolate those UV strips into a dedicated atlas mask.

## 2026-03-22 23:42 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix the new editor/runtime failures reported after opening `scenes/china_terrain_30km.tscn`, specifically broken `%` format strings and the outpost retextured-city model reference.
- Done:
  - Fixed the runtime regroup-source format crash in `scripts/presentation/china_terrain_scene.gd` by replacing the corrupted passive description format string at line 8409 with a stable `"%s - %s"` pattern.
  - Fixed the main-scene regroup / expedition / aide format-string crashes in `scripts/presentation/strategy_ui_layer.gd`, including:
    - expedition officer picker title
    - regroup unit list rows
    - regroup plan list rows
    - aide picker stat / office labels
    - aide officer detail panel strings
  - Normalized the broken outpost model resource path in `scenes/prefabs/fortress_outpost_instance.tscn` to the real UTF-8 asset path `res://�ز�/��ģ/������λ/chengchi_ct30_low_2k_retex.glb`.
  - Re-ran the headless parse check via `tmp/_tmp_verify_expedition_parse.gd`; both `res://scripts/presentation/strategy_ui_layer.gd` and `res://scripts/presentation/china_terrain_scene.gd` still load cleanly.
- Risks:
  - I fixed the concrete format-string and missing-resource issues shown in the screenshots, but the editor console still contains unrelated legacy warnings/errors from addon/test/probe scripts such as `.codex_verify_*`, `brackeys_particle_controls`, and temporary `tmp/` probes.
  - The regroup / expedition flow still mixes Chinese and English labels; if the user wants a stable no-mojibake UI, the next pass should convert the remaining visible main-flow text in these two scripts to English consistently.
- Next:
  - Reopen `scenes/china_terrain_30km.tscn`, clear the editor error list, and confirm the previous crashes at `strategy_ui_layer.gd:2259`, `strategy_ui_layer.gd:4447`, and `china_terrain_scene.gd:8409` no longer reappear when opening regroup / expedition / aide panels.
  - If the flow is stable, do a focused English-only text pass for the visible main-scene regroup / expedition / aide labels to avoid future Chinese mojibake friction.

## 2026-03-22 21:16 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix the remaining city-wall issue reported from Godot preview: the outer wall body still lacked the sandstone texture because the previous pass relied too much on color thresholds.
- Done:
  - Switched the city retexture workflow from color-threshold masking to geometry-driven UV masking for the generic city asset.
  - Classified mesh polygons in Blender by world-space position and normal into three buckets: outer wall body, outer wall cap/crest, and inner ground.
  - Rasterized those polygon sets into UV-space masks (`tmp/chengchi_mask_wall_body.png`, `tmp/chengchi_mask_wall_cap.png`, `tmp/chengchi_mask_ground.png`) and used them to composite the atlas precisely.
  - Rebuilt `素材/建模/建筑单位/chengchi_ct30_low_2k_retex_base.png` so the outer wall body now receives dense sandstone tiling, wall-cap strips keep their own sandstone pass, and the inner ground remains grass-dominant.
  - Re-exported `素材/建模/建筑单位/chengchi_ct30_low_2k_retex.glb` with the new base atlas.
- Risks:
  - The outer wall mask is now geometry-driven and much more reliable, but if a few non-wall vertical trims share the same geometric band they may also pick up the sandstone treatment.
  - The wall still uses the original normal/roughness maps, so only base color changed.
- Next:
  - Reimport `chengchi_ct30_low_2k_retex.glb` in Godot and inspect the outer wall body specifically; if the sandstone is now present but still too faint or too coarse, tune only the wall-body blend/tile values rather than the global atlas thresholds.

## 2026-03-22 21:28 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Exclude the gatehouse top/roof area from the sandstone wall treatment after the user noticed the gate top should stay unpainted.
- Done:
  - Identified the gatehouse roof geometry in Blender by combining front-facing world position, near-center horizontal position, high elevation, and upward/sloped normals.
  - Rasterized that region into `tmp/chengchi_mask_gate_roof_exclude.png` and subtracted it from the wall-body / wall-cap masks before atlas compositing.
  - Rebuilt `素材/建模/建筑单位/chengchi_ct30_low_2k_retex_base.png` and re-exported `素材/建模/建筑单位/chengchi_ct30_low_2k_retex.glb` so the gatehouse top now falls back to the original roof/base-color treatment instead of sandstone.
- Risks:
  - The gate exclusion is geometry-driven and should be much safer than the old color-based pass, but if there are adjacent front-center trims sharing the same mesh band, they may also be restored with the original texture.
- Next:
  - Reimport `chengchi_ct30_low_2k_retex.glb` in Godot and check the gatehouse top specifically; if any remaining unwanted sandstone is still visible there, expand the gate exclusion mask slightly around that front-center cluster.

## 2026-03-22 23:58 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Convert the real `ChinaTerrain30km` regroup / expedition / aide main-flow UI into a stable English-first version to avoid repeated Chinese mojibake risk.
- Done:
  - Converted the visible regroup / expedition UI text in `scripts/presentation/strategy_ui_layer.gd` to English, including expedition panel titles, officer-slot labels, ship labels, troop assignment dialogs, regroup hints, regroup detail text, regroup button labels, and main-flow confirm/cancel button text.
  - Converted the main-scene runtime panel data in `scripts/presentation/china_terrain_scene.gd` to English for the same flow, including `Regroup`, `Expedition Setup`, `Officer Book`, `Ferry Logistics Assignment`, `Aide Assignment`, English ship labels, English expedition validation/status messages, and English aide role labels/descriptions.
  - Kept dynamic logic intact: expedition still uses organized troop allocation, special troop activation still depends on the main commander + matching troop class, and the officer picker remains a secondary window.
  - Re-ran headless checks:
    - `tmp/_tmp_verify_expedition_parse.gd` still loads `res://scripts/presentation/strategy_ui_layer.gd` and `res://scripts/presentation/china_terrain_scene.gd` successfully.
    - `tmp/_tmp_verify_scene_loads.gd` successfully loads `res://scenes/prefabs/fortress_outpost_instance.tscn` and `res://scenes/china_terrain_30km.tscn`.
- Risks:
  - This is an English-first stabilization pass for the real main flow only; unrelated legacy Chinese text still exists elsewhere in the repository, including non-core systems and older battle/facility flows.
  - Dynamic officer/troop names still come from data; if you later want a fully English game, those source datasets would need a separate translation pass.
- Next:
  - Open `scenes/china_terrain_30km.tscn`, clear the editor console once, and click through `Regroup -> Expedition -> Aide Assignment` to confirm the previously visible labels are now stable English in the actual runtime UI.
  - If anything still shows up in Chinese on that exact path, do one more tiny patch pass only for the remaining visible strings instead of broad repository-wide replacement.

## 2026-03-22 21:42 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Expand the gatehouse roof exclusion from one gate to all four gatehouse tops after the user pointed out that only one had been fixed.
- Done:
  - Detected all four gatehouse roof regions in Blender using four world-space side predicates (front/back/left/right) combined with elevated height and upward/sloped normals.
  - Rebuilt `tmp/chengchi_mask_gate_roof_exclude.png` to cover the gatehouse tops on all four sides instead of only the front gate.
  - Re-exported `素材/建模/建筑单位/chengchi_ct30_low_2k_retex.glb` and regenerated `素材/建模/建筑单位/chengchi_ct30_low_2k_retex_base.png` with the four-side gate exclusion applied.
- Risks:
  - The four-side gate exclusion is geometry-driven and broader than before; if some adjacent decorative trims share the same side-center roof geometry, they may also be restored to the original texture.
- Next:
  - Reimport `chengchi_ct30_low_2k_retex.glb` in Godot and verify all four gatehouse tops. If one side still shows sandstone, slightly enlarge only that side's gate predicate rather than touching the wall masks again.

## 2026-03-23 00:08 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix the real `Regroup` confirm button doing nothing in `ChinaTerrain30km`.
- Done:
  - Traced the confirm click path in `scripts/presentation/strategy_ui_layer.gd` and confirmed the regroup submit branch is `_on_command_decide_pressed() -> regroup_plan_confirmed.emit(...)`.
  - Found the real root cause: `_command_decide_button.disabled` was only being set by the expedition panel and never reset when switching panels, so the disabled state could persist into `Regroup` and make `Confirm Regroup` appear clickable while doing nothing.
  - Fixed the button state handling in `scripts/presentation/strategy_ui_layer.gd`:
    - reset `disabled = false` whenever a command panel is shown
    - initialize regroup panel confirm as disabled until regroup preview is built
    - bind regroup confirm enabled/disabled state to the current regroup preview validity (`plan_total > 0` and `can_apply`)
  - Re-ran the headless parse verifier `tmp/_tmp_verify_expedition_parse.gd`; both main scripts still load successfully.
- Risks:
  - This fix addresses the confirm-button state bug specifically; if the user still cannot submit after this, the next likely issue would be that another overlay is intercepting mouse input in their current scene state.
- Next:
  - Reopen the regroup panel in `scenes/china_terrain_30km.tscn`, add a troop change again, and check whether `Confirm Regroup` now submits immediately instead of silently doing nothing.

## 2026-03-22 16:08 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Add a lightweight, manually positionable mountain mist group to `ChinaTerrain30km` without implementing automatic mountain detection.
- Done:
  - Added `MountainMist` with three billboarded quad cards to `scenes/china_terrain_30km.tscn`.
  - Reused `res://�ز�/brackeys_vfx_bundle/particles/alpha/smoke_07_a.png` as the mist texture and tuned three separate materials/quad sizes for a layered thin-cloud look.
  - Verified the scene still text-loads with Godot headless (`LOAD_OK`).
- Risks:
  - The default placement is only a starting point; user should move `MountainMist` or individual `MistCard*` nodes to the exact mountain peaks desired.
  - This is a very light billboard mist effect, not volumetric clouds; the look depends on placement and camera angle.
- Next:
  - Reposition `MountainMist` in the editor, duplicate it for additional peaks if needed, and keep alpha low so the mountain remains readable.

## 2026-03-22 23:59 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Increase Luoyang city resources in the real main-scene data so regroup / expedition testing is less resource-constrained.
- Done:
  - Updated Luoyang resource values in data/config/world_state.json for the main world-state entry used by ChinaTerrain30km runtime.
  - New Luoyang resources: Money 45000, Food 65000, Iron 18000, Wood 18000, Horses 12000.
  - Verified data/config/world_state.json still parses successfully with ConvertFrom-Json.
- Risks:
  - This is a direct balance/data boost for Luoyang only; if the running editor session cached world state before the change, the scene may need a reload to reflect the new values.
  - If regroup cost tuning changes later, Luoyang may still need another balance pass rather than more raw resources.
- Next:
  - Reopen or reload scenes/china_terrain_30km.tscn, click Luoyang, and retest the regroup plan that previously ran out of Money / Horses.

## 2026-03-22 22:10 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Replace the fake bright-green inner ground look with a ground treatment much closer to `res://素材/textures/rocky_terrain_02_diff_2k.jpg`.
- Done:
  - Rebuilt the city retexture using the existing geometry-driven wall/body/gate masks, but changed the inner-ground compositing to be rocky-texture dominant instead of grass-base dominant.
  - Used two scales of `rocky_terrain_02_diff_2k.jpg` sampling for the ground area to reduce obvious simple tiling and exported the updated `素材/建模/建筑单位/chengchi_ct30_low_2k_retex.glb`.
- Risks:
  - The city model's ground UVs are heavily segmented, so even with a better source texture some polygon/island boundaries may still read visibly in the baked atlas.
  - If the user wants truly natural courtyard ground, the next step should likely be a dedicated hand-painted ground atlas or a separate ground mesh/material rather than further global blend tweaks.
- Next:
  - Reimport `chengchi_ct30_low_2k_retex.glb` in Godot and judge whether the new rocky-ground direction is acceptable; if not, either hand-paint the ground UV area or isolate the inner ground as a separate material path.

## 2026-03-23 00:08 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Make manually placed mountain mist visible only during fog-type weather so it does not hurt clarity in other weather states.
- Done:
  - Added `_mountain_mist_root` hookup in `scripts/presentation/china_terrain_scene.gd`.
  - Added `_apply_runtime_mountain_mist_visibility(weather_state)` and called it from runtime weather visual sync.
  - Mountain mist is now visible only when `weather_state` is `fog` or `mist`; `sunny/cloudy/windy/rain/storm` hide it at runtime.
  - Editor visibility remains on so the user can still reposition the `MountainMist` node manually.
- Risks:
  - This only affects runtime weather-driven visibility; if the user wants the node hidden in the editor too, that would need a separate rule.
- Next:
  - Play once through a few weather states and confirm `MountainMist` disappears outside fog weather while still being easy to position in the editor.

## 2026-03-23 09:02 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Reduce the obvious fake grass seam lines in the city courtyard ground after the user reported many visible line artifacts.
- Done:
  - Kept the geometry-driven wall/gate masks intact, but changed the ground compositing again to a much flatter, lower-contrast rocky-derived fill.
  - Replaced the previous high-contrast ground treatment with a rocky-color average plus only light multi-scale variation so UV island borders stop standing out as hard lines.
  - Re-exported `素材/建模/建筑单位/chengchi_ct30_low_2k_retex.glb` and regenerated `素材/建模/建筑单位/chengchi_ct30_low_2k_retex_base.png`.
- Risks:
  - Some UV island boundaries may still be faintly visible because the ground remains baked into a segmented atlas area; this pass reduces contrast rather than changing the underlying UV layout.
  - If the user wants perfectly clean courtyard ground, the stronger solution is a hand-painted ground atlas or a separate dedicated ground material/mesh.
- Next:
  - Reimport `chengchi_ct30_low_2k_retex.glb` in Godot and inspect whether the courtyard lines are acceptably reduced; if not, move to a hand-painted ground pass instead of further procedural blending.

## 2026-03-23 00:15 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Enforce the user's stricter rule that only fog-type weather may show any fog-like visuals.
- Done:
  - Updated `scripts/presentation/china_terrain_scene.gd` so environment fog now enables only for `fog/mist` weather, not `rain/cloudy/storm`.
  - Updated runtime map weather fog particles so `fog_on` is now true only for `fog/mist`.
  - Mountain mist manual cards remain runtime-visible only for `fog/mist`.
- Risks:
  - This intentionally removes storm fog ambience too; if storm should later have a separate non-fog atmosphere, it should be implemented with rain/light only.
- Next:
  - Run one scene cycle in rain/cloudy and confirm readability improves because all fog systems stay off outside fog weather.
## 2026-03-23 09:29 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Enforce the user's explicit rule that rain weather must not show any fog-like visuals in `ChinaTerrain30km`.
- Done:
  - Removed the leftover `rain_adds_mist` runtime path from `scripts/presentation/china_terrain_scene.gd` so rain no longer enables weather fog particles.
  - Confirmed the three fog-like systems now all use the same hard rule: only `fog/mist` may show environment fog, weather fog particles, or manual `MountainMist` cards at runtime.
  - Verified `scenes/china_terrain_30km.tscn` still headless-loads successfully with Godot (`LOAD_OK`).
- Risks:
  - This intentionally removes any rain haze ambience; if rain later needs atmosphere, it should use rain/light/color only, not mist/fog.
  - Editor-side visibility for `MountainMist` remains enabled by design so the user can still place nodes manually.
- Next:
  - Play `scenes/china_terrain_30km.tscn` in rain/cloudy/storm/fog once and visually confirm only `fog/mist` still show fog-like effects.

## 2026-03-23 09:26 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Eliminate the remaining courtyard line artifacts after confirming they were still obvious even with flatter ground texturing.
- Done:
  - Confirmed the problem was mainly geometric: the courtyard ground polygons spanned about `0.0567` world units in height and had many differing normals, which explained the persistent bright triangular lines.
  - Flattened the courtyard mesh itself by moving vertices predominantly belonging to ground polygons onto a shared average ground plane (`avg z ≈ 0.037126`), affecting `689` vertices.
  - Recomputed face normals after flattening, then rebuilt and re-exported `素材/建模/建筑单位/chengchi_ct30_low_2k_retex.glb` while preserving the current wall/gate texture masks.
- Risks:
  - The courtyard is now geometrically flatter; if any intentionally sculpted bumps existed there, this pass smooths them out.
  - Some atlas UV island color transitions still exist in the texture, but the stronger triangle-lighting artifact should now be reduced because the underlying ground mesh is flatter.
- Next:
  - Reimport `chengchi_ct30_low_2k_retex.glb` in Godot and inspect whether the bright triangular ground lines are gone or much weaker. If they persist, the next target is the normal map contribution on the ground region rather than the base color or geometry.
## 2026-03-23 10:03 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Correct the user-reported north/south inversion for ferry and wubao sites without disturbing city/pass placement.
- Done:
  - Updated `scripts/presentation/strategic_site_manager.gd` so site Z conversion is now category-aware: `ferry` and `fortress_outpost_instance` / `wubao` keep their source north-south direction, while the existing flip rule remains for the other site categories.
  - Updated strategic override saving to use the same category-aware inverse conversion, so future manual placement saves back consistently.
  - Set `StrategicSites` in `scenes/china_terrain_30km.tscn` to stop preserving stale editor/runtime instance transforms, forcing existing site instances to reapply from data on scene load.
  - Verified `scenes/china_terrain_30km.tscn` still headless-loads successfully with Godot (`LOAD_OK`).
- Risks:
  - This is a source-category fix based on the user-confirmed pattern (`city/pass` correct, `ferry/wubao` reversed); if a small subset inside those categories was hand-entered using the old wrong orientation, those individual records may still need manual touch-up.
  - Because stale scene transforms are no longer preserved, reopening the scene will snap existing strategic-site instances back onto data-driven positions.
- Next:
  - Reopen `scenes/china_terrain_30km.tscn`, inspect several ferry and wubao sites across north/south regions, then manually fine-adjust only the remaining off-by-a-bit locations and save overrides.

## 2026-03-23 00:18 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Redesign the real Regroup panel in ChinaTerrain30km toward a clearer block-based layout matching the user's sketch, with visible section separation.
- Done:
  - Reworked regroup layout in scripts/presentation/strategy_ui_layer.gd into distinct framed regions: city header, troop categories, selected troop detail, preview & cost, available troop list, current changes, adjust amount, and regroup summary.
  - Added dedicated regroup section frame/title helpers so the panel now has clear visual separation instead of one continuous text wall.
  - Updated regroup placeholders/titles to match the new structure, including Troop Categories, Selected Troop, Preview & Cost, Available Troops, Current Changes, Adjust Amount, and Regroup Summary.
  - Added a simple preview placeholder text (Troop Preview) and bound the preview title text to the currently selected troop name.
  - Re-ran headless parse verification with 	mp/_tmp_verify_expedition_parse.gd; both strategy_ui_layer.gd and china_terrain_scene.gd still load successfully.
- Risks:
  - This is a first-pass structural redesign using existing controls; the middle preview area still uses the existing placeholder frame, not a true troop illustration card grid yet.
  - Resource summary text is still the old long-form formatter, so if the user wants the bottom summary to look more like the spreadsheet mockup, it should be simplified in a second pass rather than widened further.
- Next:
  - Open scenes/china_terrain_30km.tscn, check the new regroup panel block layout in-editor, and then decide whether the second pass should focus on compact bottom-summary wording or replacing the right-side troop list with card-style columns.
## 2026-03-23 10:10 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Make the strategic-site manual save control easier to find in the Godot inspector so user position edits are less likely to be lost.
- Done:
  - Reorganized exported inspector properties in `scripts/presentation/strategic_site_manager.gd` into three categories: `Editor Actions`, `Data And Placement`, and `Visual And LOD`.
  - Moved `save_current_positions_now` to the top under `Editor Actions`, above `rebuild_now` and `clear_now`, so it is immediately visible when `StrategicSites` is selected.
  - Verified `scenes/china_terrain_30km.tscn` still headless-loads successfully with Godot (`LOAD_OK`).
- Risks:
  - This is an inspector UX change only; the save behavior itself is unchanged and still requires the user to click the toggle after manual repositioning.
- Next:
  - In the editor, select `StrategicSites`, confirm the `Editor Actions` section is visible at the top, then use `save_current_positions_now` after each batch of manual site moves.

## 2026-03-23 00:33 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Continue regroup UI redesign toward the user's spreadsheet mockup by making troop selection more card-like and shortening the bottom summary text.
- Done:
  - Added a new regroup troop-card area in scripts/presentation/strategy_ui_layer.gd, backed by RegroupUnitCardsScroll + RegroupUnitCardsGrid, so the right-side troop selection is no longer just a plain text list.
  - Each troop card now shows troop name, current amount, planned change, after amount, and per-batch cost, and clicking the card selects that troop just like the old list did.
  - Kept the hidden RegroupUnitList as the data-selection backbone for compatibility, while moving visible interaction to the new card section.
  - Simplified regroup summary text into three compact lines: total cost, reserves/organized after-change, and only the resources that actually change.
  - Re-ran headless parse verification with 	mp/_tmp_verify_expedition_parse.gd; both main scripts load successfully.
- Risks:
  - This is still a hybrid version: the visible troop area is now card-like, but the whole panel is not yet a full spreadsheet-style matrix with one fixed column per troop type.
  - Card text density depends on font and panel scale; if some categories have many troop classes, the scroll area may still need one more layout pass.
- Next:
  - Open scenes/china_terrain_30km.tscn, check whether the new troop cards feel closer to the mockup, and then decide whether the next pass should move to a true multi-column matrix or add per-card illustration/description blocks.

## 2026-03-23 00:46 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Further polish the real regroup panel so the troop cards and cost text read closer to the user's mockup instead of long sentence-style UI blocks.
- Done:
  - Updated regroup troop cards in scripts/presentation/strategy_ui_layer.gd to use a taller card format with clearer lines: troop name, current amount, after amount, planned change, and compact per-batch cost.
  - Switched troop-card cost text to a compact formatter (_format_regroup_compact_cost_values) so cards stay readable even when a troop consumes multiple resources.
  - Reworked the center preview cost text into a 4-line block (Per X, per-batch cost, planned change, total cost) via _build_regroup_cost_text.
  - Shortened the current-changes list rows to 
ame | before -> after (+delta) for faster scanning.
  - Re-ran headless parse verification with 	mp/_tmp_verify_expedition_parse.gd; both main scripts load successfully.
- Risks:
  - The troop cards are still text cards, not full art cards yet; if the user wants the spreadsheet mockup even closer, the next pass should replace card text with child labels/icons per row instead of plain button text.
  - Button text alignment on Godot Button is limited, so a later polish pass may need a custom card control if exact left-aligned composition is required.
- Next:
  - Open scenes/china_terrain_30km.tscn, verify the regroup cards and summary readability in the live UI, and if still too plain, do a final pass to convert each troop card into a custom left-aligned card layout with separate labels for current / planned / cost rows.

## 2026-03-23 00:58 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Simplify the real regroup UI after the user said the redesign had become too complex.
- Done:
  - Disabled the visible card-style troop selection area and restored the simpler RegroupUnitList as the main visible troop selector in scripts/presentation/strategy_ui_layer.gd.
  - Reduced regroup detail density by removing extra movement/range/morale lines and skipping the appended tech-effect block from the main detail panel.
  - Shortened troop description preview and collapsed center cost text back to a single-line format: Per X | Planned | Total.
  - Renamed the category header from Troop Categories back to the simpler Select Troop.
  - Re-ran headless parse verification with 	mp/_tmp_verify_expedition_parse.gd; both main scripts load successfully.
- Risks:
  - Some of the extra frame/title helpers still exist in code even though the visible interaction is simplified again; they are mostly cosmetic overhead now, not active logic risk.
  - If the user wants an even cleaner look after this, the next pass should remove or hide more decorative section titles rather than reintroducing new controls.
- Next:
  - Open scenes/china_terrain_30km.tscn, verify the regroup panel now feels simpler, and then decide whether the next cleanup should strip more visual frames or stop here.
## 2026-03-23 10:42 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Rebuild the `ChinaTerrain30km` ground layering so terrain uses four user-requested material bands: existing grass plus laterite soil, rocky trail rock, and snow by height/slope.
- Done:
  - Generated new packed texture sets for `red_laterite_soil_stones`, `rocky_trail`, and `snow_02` from the provided diffuse/disp/roughness textures; normal data is reconstructed from the displacement map to keep the terrain bumpy without needing the problematic source normal EXRs.
  - Saved those packed outputs both as PNGs and as directly loadable `.res` texture resources under `素材/textures`.
  - Updated `scenes/china_terrain_30km.tscn` Terrain3D assets to use four layers: `Grass` (existing `rocky_terrain_02`), `Soil` (`red_laterite_soil_stones`), `Rock` (`rocky_trail`), and `Snow` (`snow_02`).
  - Added `tmp/apply_height_slope_terrain_layers.gd` and applied it once to the terrain control maps, using height + slope + light noise breakup to distribute grass/soil/rock/snow and save the updated region resources.
  - Verified the updated scene still headless-loads successfully with Godot (`LOAD_OK`).
- Risks:
  - The current thresholds are a first-pass global rule; some ranges will likely need hand-tuning after the user judges snowline, rock coverage, and lowland soil amount in-editor.
  - Farm-field fine detail is not yet a separate dedicated overlay layer; current lowland breakup still relies on the grass base and Terrain3D macro variation.
  - Region-specific masks such as northwest desert, wetlands, and plank-road/catwalk routes are not added yet; this pass only establishes the dynamic base 4-layer terrain.
- Next:
  - Open `scenes/china_terrain_30km.tscn`, visually judge the new base 4-layer distribution, then tune the thresholds in `tmp/apply_height_slope_terrain_layers.gd` for grass/soil/rock/snow before adding regional overrides like desert or wetland.

## 2026-03-23 01:07 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Remove the duplicated Current Changes section from the real regroup UI after the user pointed out it repeated information already shown on the left.
- Done:
  - Removed the visible regroup Current Changes block from scripts/presentation/strategy_ui_layer.gd by collapsing its layout height to  , hiding the frame/title, and hiding the plan list.
  - Pulled the lower regroup controls upward automatically by reclaiming the old queue section space.
- Risks:
  - The regroup plan list still exists internally for logic compatibility, but it is now hidden from the visible UI.
- Next:
  - Reopen the regroup panel in scenes/china_terrain_30km.tscn and verify the lower area now feels cleaner without the duplicate block.
## 2026-03-23 10:53 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix the overbright washed-out terrain appearance introduced by the first 4-layer terrain pass.
- Done:
  - Identified the main cause: the new soil/rock/snow textures had been temporarily referenced through raw `.res` `ImageTexture` resources, which bypassed the normal imported color-space path and made the terrain look blown out.
  - Switched `scenes/china_terrain_30km.tscn` back to the proper imported `.png` packed textures for the new soil/rock/snow layers.
  - Re-ran the base terrain layer brush after raising the snow band (`SNOW_START` 590, `SNOW_END` 690) and pushing rock height thresholds upward, so central/northern inland terrain no longer gets excessive snow-white coverage.
  - Verified the updated scene still headless-loads successfully with Godot (`LOAD_OK`).
- Risks:
  - New packed textures still warn about missing mipmaps; this should affect distant sharpness/shimmer more than brightness, but they may still deserve a clean import refinement pass later.
  - The current terrain thresholds are still an early aesthetic pass and may need another visual tuning round after the user inspects the updated scene.
- Next:
  - Reopen `scenes/china_terrain_30km.tscn`, inspect whether the washed-out brightness is gone, then adjust lowland grass/soil balance before adding regional overrides like desert or wetland.
## 2026-03-23 11:02 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix the Terrain3D texture-format mismatch errors caused by the new soil/rock/snow packed textures.
- Done:
  - Confirmed the root cause from the editor errors: the new packed textures were imported with different compression, mipmap, and normal-map settings from the original terrain grass textures, which Terrain3D rejects.
  - Aligned the `.import` settings for `red_laterite_soil_stones_packed_*`, `rocky_trail_packed_*`, and `snow_02_packed_*` to match the original terrain texture import profile.
  - Triggered a Godot editor reimport pass and verified `scenes/china_terrain_30km.tscn` now headless-loads successfully without the previous Terrain3D texture mismatch failure.
- Risks:
  - The visual balance of grass/soil/rock/snow may still need another aesthetic tuning pass after the user reopens the editor and judges the terrain in-scene.
- Next:
  - Reopen `scenes/china_terrain_30km.tscn` or reload the project so the editor picks up the reimported textures, then judge the terrain brightness and distribution again.
## 2026-03-23 11:11 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Reapply the current `grass / soil / rock / snow` terrain layering rules after the user confirmed the intended texture mapping.
- Done:
  - Re-ran `tmp/apply_height_slope_terrain_layers.gd` so the Terrain3D control maps are freshly painted using the current mapping: existing grass, `red_laterite_soil_stones` as soil, `rocky_trail` as rock, and `snow_02` as snow.
  - Verified `scenes/china_terrain_30km.tscn` still headless-loads successfully with Godot (`LOAD_OK`).
- Risks:
  - This is still the same current threshold set; if the in-editor result looks wrong, the next step should be threshold tuning rather than another blind repaint.
- Next:
  - Reopen `scenes/china_terrain_30km.tscn` in the editor and judge the new terrain distribution before adjusting the grass/soil/rock/snow ranges.
## 2026-03-23 11:27 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Remove the last practical influence of the old aerial-rock look from `ChinaTerrain30km` by shrinking rock coverage and expanding the laterite soil band.
- Done:
  - Rechecked `scenes/china_terrain_30km.tscn`; the active terrain layers already point to `rocky_terrain_02` (grass), `red_laterite_soil_stones` (soil), `rocky_trail` (rock), and `snow_02` (snow). `aerial_rocks_02` is no longer referenced by the live terrain scene.
  - Updated `tmp/apply_height_slope_terrain_layers.gd` to widen the soil band and delay rock takeover significantly.
  - New thresholds: grass fades around `95–185m`; soil dominates roughly `75–560m` on gentler terrain; rock now mainly appears at `420m+` or steep `30–46°` slopes; snow starts around `635m+`.
  - Re-ran the terrain layer brush and verified `scenes/china_terrain_30km.tscn` still headless-loads successfully with Godot (`LOAD_OK`).
- Risks:
  - If the user still perceives a leftover old-rock look after editor reload, the likely cause is cached editor rendering or the visual character of `rocky_terrain_02` grass itself rather than an active `aerial_rocks_02` scene reference.
- Next:
  - Reopen or reload `scenes/china_terrain_30km.tscn` in the editor and judge whether the laterite soil coverage is now clearly more visible before further threshold tuning.
## 2026-03-23 11:38 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Repaint the terrain more like a clean reset after the user reported the old look still dominated the map.
- Done:
  - Reworked `tmp/apply_height_slope_terrain_layers.gd` into a much more soil-heavy distribution so the terrain reads as a fresh repaint instead of a rock-dominant carry-over.
  - New stronger reset-style thresholds: grass now stays mostly on lower flatter land (`60–135m`, `8–14°`), soil dominates broadly from low hills through most inland terrain (`35–650m`, `12–34°`), rock is delayed to higher/steeper mountains (`540m+` or `36–52°`), and snow starts later (`690m+`).
  - Reduced breakup noise to avoid the old overly busy speckled feel and re-ran the terrain control-map repaint across all active Terrain3D regions.
  - Verified `scenes/china_terrain_30km.tscn` still headless-loads successfully with Godot (`LOAD_OK`).
- Risks:
  - If the user still dislikes the remaining look after editor reload, the next likely culprit is the grass source texture itself (`rocky_terrain_02`) rather than leftover rock-layer paint.
- Next:
  - Reload `scenes/china_terrain_30km.tscn` and judge whether the terrain now reads as soil-dominant; if not, replace the grass source texture rather than only adjusting thresholds again.

## 2026-03-23 01:27 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Reshape the real expedition panel toward the user's mockup, using a simpler single-team layout before any true multi-team expedition logic.
- Done:
  - Changed the expedition officer slot root in scripts/presentation/strategy_ui_layer.gd from vertical to horizontal (HBoxContainer) so the three officer slots now lay out like left-to-right columns instead of stacked rows.
  - Rebuilt each expedition officer slot into a taller card-style block with centered role title, a large officer-select button area, and a lower battle-style / skill line.
  - Reworked expedition panel layout to a new single-team skeleton: left side for three officer columns plus a compact Team Summary, right side for Ship, Troop / Soldiers, and the radar/profile area below.
  - Simplified expedition summary text from the old full five-dimension overview to a shorter Team Summary and Troops presentation.
  - Updated expedition bottom hint text to match the new workflow wording (Pick the main commander first, Choose troop type and assign soldiers, Ready: ...).
  - Re-ran headless parse verification with 	mp/_tmp_verify_expedition_parse.gd; both main scripts load successfully.
- Risks:
  - This is still a single-team expedition implementation under the hood; the lower dd another team idea from the mockup is intentionally not wired yet.
  - Officer slots are now shaped more like large cells, but they still use button text instead of true portrait cards, so a later polish pass could replace them with custom card content if desired.
- Next:
  - Open scenes/china_terrain_30km.tscn, inspect the new expedition layout in the live UI, and then decide whether the next pass should add visual team placeholders or refine the officer-slot visuals with portraits.
## 2026-03-23 12:05 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Remove the remaining old-rock terrain look by replacing the actual live grass and rock texture sources instead of only repainting layer weights.
- Done:
  - Rechecked `scenes/china_terrain_30km.tscn` and confirmed the live scene still had `rocky_terrain_02` bound to the Grass layer and `aerial_rocks_02` bound to the Rock layer, which explained why the terrain still looked like the old texture set.
  - Swapped the live Grass layer to `aerial_grass_rock_packed_albedo_height.png` / `aerial_grass_rock_packed_normal_roughness.png`.
  - Swapped the live Rock layer to `rocky_trail_packed_albedo_height.png` / `rocky_trail_packed_normal_roughness.png`, fully removing `aerial_rocks_02` from the active terrain material bindings.
  - Slightly softened the grass and rock normal response in the scene material assets and added an explicit grass `uv_scale` so the new base layer is less harsh and easier to judge.
  - Re-ran `tmp/apply_height_slope_terrain_layers.gd` and verified `scenes/china_terrain_30km.tscn` still headless-loads successfully (`LOAD_OK`).
- Risks:
  - If the editor already had `china_terrain_30km.tscn` open, it may still be showing cached terrain/material state until the scene tab or project is reloaded.
  - The terrain control thresholds are still the current soil-heavy pass; visual taste tuning may still be needed after the new grass base is seen in-editor.
- Next:
  - Reopen or reload `scenes/china_terrain_30km.tscn` in the editor and judge the new grass/soil/rock separation before any further anti-tiling tuning.## 2026-03-23 12:18 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Stop using slope-based terrain distribution so soil becomes clearly visible and all terrain layers follow altitude only.
- Done:
  - Reworked `tmp/apply_height_slope_terrain_layers.gd` into a height-only repaint pass; removed all slope sampling, slope thresholds, and slope noise from the terrain layer decision logic.
  - Set the current altitude bands to a clearer sequence: grass fades around `85-170m`, soil becomes dominant around `110-430m` then fades by `560m`, rock rises from about `420m`, and snow starts around `720m`.
  - Re-ran the Terrain3D control-map repaint so the live terrain distribution now follows height only.
  - Verified `scenes/china_terrain_30km.tscn` still headless-loads successfully (`LOAD_OK`).
- Risks:
  - This is now intentionally less geologically realistic on steep cliffs because slope no longer forces rock exposure; the user explicitly preferred altitude-only layering for now.
  - Final visual balance may still need one more pass after the user checks whether the soil belt is now wide enough in-editor.
- Next:
  - Reopen `scenes/china_terrain_30km.tscn` and check whether the soil layer is now clearly visible; if still too weak, widen the soil band upward and delay rock takeover further.
## 2026-03-23 12:40 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Continue the real `ChinaTerrain30km` expedition UI cleanup so it better matches the user's simpler mockup.
- Done:
  - Shortened the expedition officer cards in `scripts/presentation/strategy_ui_layer.gd`, reduced button height, and kept the five-dimension summary directly inside each officer slot.
  - Added clearer visual placeholder rows for `+ Add New Team` under the current expedition team so the lower area reads like expandable future team space.
  - Tightened expedition layout sizing so the officer row consumes less vertical space and leaves more room for the lower expedition area.
  - Reworked `scripts/ui/expedition_radar_chart.gd` so each radar corner now draws `Axis land/water` values directly on the chart instead of relying on separate lower text boxes.
  - Re-ran headless parse verification with `tmp/_tmp_verify_expedition_parse.gd`; `strategy_ui_layer.gd` and `china_terrain_scene.gd` both load successfully.
- Risks:
  - This pass is parse-safe but still not visually verified inside the live editor, so actual clipping/overlap still needs one in-scene check.
  - `+ Add New Team` is still a UI placeholder only; there is no true multi-team expedition logic yet.
- Next:
  - Open `scenes/china_terrain_30km.tscn`, inspect the expedition panel in the real scene, and if any slot or radar label still clips, do one last spacing-only polish pass.
## 2026-03-23 12:42 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Reduce the grass layer's visible grid/repetition without changing the new altitude-only terrain distribution.
- Done:
  - During the first anti-tiling edit pass, `scenes/china_terrain_30km.tscn` text encoding was corrupted by a raw PowerShell rewrite; the scene stopped parsing.
  - Recovered the scene from the sibling project copy at `E:\山河志风起汉末 - 副本\scenes\china_terrain_30km.tscn`, and kept a backup of the broken file at `E:\山河志风起汉末\scenes\china_terrain_30km.tscn.codex_broken_backup_20260323_anti_tiling`.
  - Rebuilt the Terrain3D scene prefix so the live terrain again uses four layers: `aerial_grass_rock` grass, `red_laterite_soil_stones` soil, `rocky_trail` rock, and `snow_02` snow.
  - Tuned anti-tiling/anti-grid grass parameters in `scenes/china_terrain_30km.tscn`: lower `blend_sharpness` to `0.18`, enable projection + macro variation, use larger macro noise scales, reduce grass `normal_depth` to `0.05`, and set grass `uv_scale` to `0.078`.
  - Re-ran `tmp/apply_height_slope_terrain_layers.gd` and verified `scenes/china_terrain_30km.tscn` headless-loads successfully (`LOAD_OK`).
- Risks:
  - Scene recovery used the sibling copy as a base because the active file became text-corrupted; if there were scene-only edits made after `2026-03-19 22:24` only in the active copy, they may need to be re-synced manually.
  - The grass repetition should now be softer, but final visual taste may still need one more pass after the user judges it in-editor.
- Next:
  - Reopen `scenes/china_terrain_30km.tscn`, inspect lowland grass repetition, and if it still feels too blocky, push grass `uv_scale` lower again and slightly widen soil breakup into the grass band.## 2026-03-23 13:03 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Bring the grass back toward the original green look while keeping only sparse broad soil breakup and reducing the obvious dense grid repetition.
- Done:
  - Swapped the live grass layer in `scenes/china_terrain_30km.tscn` from `aerial_grass_rock` back to the original green `grass-02` texture set.
  - Retuned grass material parameters for a larger, less-dense surface read: `blend_sharpness` `0.12`, greener macro variation colors, larger macro-noise scale (`0.0028` / `0.01`), `projection_threshold` `0.52`, grass `normal_depth` `0.04`, and grass `uv_scale` `0.05`.
  - Updated `tmp/apply_height_slope_terrain_layers.gd` to keep altitude-only distribution but add a sparse lowland `soil breakup` mask driven by a separate low-frequency macro noise function, so the grass stays mostly green with only broad soil-color bands instead of dense speckled patches.
  - Re-ran the terrain repaint and verified `scenes/china_terrain_30km.tscn` still headless-loads successfully (`LOAD_OK`).
- Risks:
  - Because the grass is now much greener and the tiling is scaled up, some areas may read slightly simpler/flatter until the user hand-paints extra regional variation.
  - The new soil breakup is intentionally subtle; if the user wants more visible earth streaks, the breakup strength can be increased without changing the main altitude bands.
- Next:
  - Reopen `scenes/china_terrain_30km.tscn`, inspect lowland grass repetition and color, then either keep this cleaner base or slightly raise lowland soil-breakup strength for more earthy variation.## 2026-03-23 13:28 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix the Terrain3D white-ground failure from texture format mismatch, then replace the live soil and rock layers with the user-requested `coast_sand_rocks_02` and `rock_face` texture sets.
- Done:
  - Confirmed the user screenshot's root cause: the newly generated packed textures were auto-imported with non-Terrain3D settings (`compress/mode=0`, no mipmaps, wrong normal/roughness flags), which caused `Texture ID ... format ... doesn't match` and the washed-out white terrain.
  - Updated `tmp/pack_terrain_texture_set.gd` so texture-set packing now falls back to a constant roughness map when a source roughness EXR cannot be loaded, which was necessary for `rock_face` because its imported EXR assets were invalid.
  - Generated `coast_sand_rocks_02_packed_albedo_height.png` / `coast_sand_rocks_02_packed_normal_roughness.png` and `rock_face_packed_albedo_height.png` / `rock_face_packed_normal_roughness.png`.
  - Forced all four new packed textures to reimport with the same Terrain3D-compatible settings as the working grass and existing terrain textures: compressed S3TC/BPTC, mipmaps on, albedo as non-normal, normal+roughness as normal-map import with roughness mode enabled.
  - Rebound `scenes/china_terrain_30km.tscn` so the live soil layer now uses `coast_sand_rocks_02_packed_*` and the live rock layer now uses `rock_face_packed_*`.
  - Tuned the live material multipliers for the new sets: soil `normal_depth 0.1`, `roughness 0.94`, `uv_scale 0.082`; rock `normal_depth 0.12`, `roughness 0.92`, `uv_scale 0.046`.
  - Verified `scenes/china_terrain_30km.tscn` still headless-loads successfully (`LOAD_OK`) after the swap.
- Risks:
  - `rock_face` currently uses displacement-derived normals plus a fallback constant roughness because its source EXR imports are invalid; visually this should still be stable, but if the user later wants higher-fidelity rock microsurface detail, the source normal/roughness assets need a clean re-export or conversion.
  - The terrain control-map paint itself was not changed in this pass; only the soil/rock texture sources and compatible import path were fixed.
- Next:
  - Reopen `scenes/china_terrain_30km.tscn` and confirm the previous white-terrain error is gone; then judge whether the new soil/rock textures need further scale tuning or another lowland breakup pass.## 2026-03-23 13:46 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix the still-white Terrain3D by resolving the last remaining texture-format mismatch in the grass layer while keeping the new requested soil/rock textures.
- Done:
  - Verified the actual root cause with a direct Godot format probe: `grass-02-alb.png` loaded as format `17`, while the packed soil/rock/snow textures all loaded as format `19`, matching the editor error (`Texture ID 1/2/3 ... doesn't match format of first texture`).
  - Built a packed green grass set from the original green grass sources (`grass-02-alb.png`, `grass-02-disp.png`, `grass-02-nrm.png`) into `grass-02_packed_albedo_height.png` and `grass-02_packed_normal_roughness.png`.
  - Reimported the new packed green grass textures with Terrain3D-compatible settings via Godot `--import`, which generated the final imported resources and stable UIDs.
  - Rebound the live grass layer in `scenes/china_terrain_30km.tscn` to the packed green grass set, so all four Terrain3D albedo textures now share the same image format.
  - Rechecked all four active Terrain3D albedo textures; they now all load as format `19`.
- Risks:
  - If the editor already had `china_terrain_30km.tscn` open the whole time, it may still be showing the stale Terrain3D texture state until the scene tab or project is reloaded.
  - `verify_china_terrain_scene_load.gd` still reports an unrelated parse problem in `strategy_ui_layer.gd` through `china_terrain_scene.gd`, but the texture-format mismatch itself is resolved.
- Next:
  - Reopen `scenes/china_terrain_30km.tscn` (or restart the editor once) and confirm the previous Terrain3D white-ground mismatch is gone before continuing visual scale tuning.
## 2026-03-23 13:25 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Adjust the real `ChinaTerrain30km` expedition officer UI to match the user's latest feedback: shorter officer cards, five-dimension stats only in the officer picker, and no `Skill` label in expedition flow.
- Done:
  - Shortened the expedition officer slot cards again in `scripts/presentation/strategy_ui_layer.gd` and moved the slot layout to explicit manual positioning so the three officer boxes no longer stretch like full-height columns.
  - Removed five-dimension stats from the main expedition officer cards; each slot now shows only `Battle`, `Tactic`, and optional `Special` preview.
  - Updated the expedition officer picker table to `Officer / Battle / Tactic / Stats / Special` and added `Lead/Might/Int/Pol/Charm` to the lower detail panel instead of the main expedition cards.
  - Kept expedition `Tactic` text mapped from the existing officer tactic/skill data source, but removed the old `Skill` wording from the expedition UI.
  - During this pass, repaired several pre-existing/mixed-encoding parse breakpoints in `strategy_ui_layer.gd` by replacing malformed label strings with stable English fallbacks and restoring a few accidentally missing state/cache variable declarations.
  - Re-ran headless parse verification with `tmp/_tmp_verify_expedition_parse.gd`; `strategy_ui_layer.gd` and `china_terrain_scene.gd` both load successfully again.
- Risks:
  - The script is parse-safe again, but some unrelated legacy Chinese label strings in `strategy_ui_layer.gd` were normalized to English fallbacks where encoding corruption had already made them invalid.
  - This pass still needs one in-editor visual check to confirm the shorter officer cards now match the intended height and the picker table columns are readable at runtime.
- Next:
  - Open `scenes/china_terrain_30km.tscn`, inspect the expedition panel and officer picker, and if spacing still feels off, do a final layout-only polish pass from the new screenshot.
## 2026-03-23 14:02 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Remove the black-looking grass result and shift the height-only terrain rule so rock starts around 350m altitude.
- Done:
  - Stopped using the custom packed green grass set for the live scene because it produced an unstable black-looking result in-editor.
  - Rebound the live grass layer in `scenes/china_terrain_30km.tscn` back to the already stable `aerial_grass_rock_packed_*` set, while keeping the new requested soil (`coast_sand_rocks_02`) and rock (`rock_face`) layers.
  - Confirmed all four active Terrain3D albedo textures now load as the same image format (`19`), so the original Terrain3D format mismatch is no longer the active problem.
  - Updated the height-only terrain distribution in `tmp/apply_height_slope_terrain_layers.gd` so soil falls off earlier and rock starts around `350m` (`ROCK_HEIGHT_START 350`, `ROCK_HEIGHT_END 460`, soil fall `320-410m`).
  - Re-ran project import and terrain repaint.
- Risks:
  - The stable grass fallback is greener only through material tuning and not the user's custom packed green grass path; if the user later still wants the exact original green texture as a packed Terrain3D set, it should be rebuilt with a more reliable image pipeline.
  - There is still an unrelated script parse problem in `strategy_ui_layer.gd` reported when loading `china_terrain_scene.gd`, but that is outside this terrain-material issue.
- Next:
  - Reopen `scenes/china_terrain_30km.tscn` and judge whether the black lowland issue is gone and whether the new `350m+` rock band reads correctly before further visual tuning.
## 2026-03-23 13:48 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Tighten the real expedition left-side layout again after user feedback: shorter officer cards, one grouped outer frame, and a strictly simplified combined-stats panel.
- Done:
  - Added a left-side outer group panel in `scripts/presentation/strategy_ui_layer.gd` so the three officer cards and the combined summary read as one grouped block instead of four disconnected tall columns.
  - Shortened expedition officer cards again and reduced internal title/button/text heights so the cards occupy much less vertical space.
  - Simplified the right-side summary block to only show combined `Lead/Might/Int/Pol/Charm`, current soldiers, and troop-type summary.
  - Renamed the disabled lower placeholders from `Add New Team` to `Future Team Slot` so they no longer pretend to be an implemented action.
  - Re-ran headless parse verification with `tmp/_tmp_verify_expedition_parse.gd`; `strategy_ui_layer.gd` and `china_terrain_scene.gd` both load successfully.
- Risks:
  - `Future Team Slot` is still only a visual placeholder; no real multi-team expedition runtime exists yet.
  - This pass is parse-safe, but the exact card height and grouped frame spacing still need one live in-editor visual check.
- Next:
  - Open `scenes/china_terrain_30km.tscn`, inspect the expedition panel, and if any left-block spacing is still off, do one last layout-only screenshot-driven adjustment.
## 2026-03-23 14:18 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Make the grass read much greener and far less grid-like in a way that is obvious in-editor rather than subtle.
- Done:
  - Kept the stable live grass texture source and applied a much stronger green-biased material tuning in `scenes/china_terrain_30km.tscn`.
  - New stronger anti-tiling/green-grass settings: `blend_sharpness 0.04`, `macro_variation1 Color(0.58, 0.98, 0.52, 1)`, `macro_variation2 Color(0.9, 1.15, 0.85, 1)`, `macro_variation_slope 0.28`, `noise1_scale 0.0009`, `noise2_scale 0.0032`, `projection_threshold 0.7`, grass `normal_depth 0.012`, grass `roughness 0.985`, grass `uv_scale 0.018`.
  - Disabled lowland soil breakup entirely for the grass band in `tmp/apply_height_slope_terrain_layers.gd` (`GRASS_SOIL_BREAKUP_STRENGTH 0.0`) so the grass reads as cleaner green land instead of green mixed with noisy brown patches.
  - Re-ran import and terrain repaint after the stronger settings pass.
- Risks:
  - This is intentionally a stronger stylized/cleaner look, so some lowland areas may now look simpler than before until hand-painted regional variation is added.
  - The exact original-source green packed grass path is still not used live because that custom packed output remained visually unreliable; this pass instead pushes the stable grass path much closer to the requested greener look.
- Next:
  - Reopen `scenes/china_terrain_30km.tscn` and judge whether the greener cleaner grass is now finally obvious; if not, the next step should be swapping to a completely different stable grass texture source rather than more parameter nudges.## 2026-03-23 14:33 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix the `chengchi` city interior so the courtyard ground reads as full grass and the bright triangular ground lines no longer show through.
- Done:
  - Confirmed `chengchi_ct30_low_2k_retex.glb` is a single-mesh single-material asset, so the remaining bright triangles were not a separate helper node but part of the live city material path.
  - Added `scenes/materials/chengchi_city_ground_fix.gdshader` and `scenes/materials/chengchi_city_ground_fix.tres` to override only low, upward-facing local surfaces with a tiled grass texture while preserving the original building albedo/normal on the rest of the mesh.
  - Added the wrapper scene `scenes/prefabs/models/chengchi_ct30_low_2k_retex_ground_fixed.tscn` plus `scripts/presentation/chengchi_city_ground_fix.gd` so the fix is applied without modifying the original source `glb`.
  - Routed strategy-city instances in `scripts/presentation/china_city_overlay.gd` and outpost instances in `scenes/prefabs/fortress_outpost_instance.tscn` to the fixed wrapper scene.
  - Verified the wrapper scene applies `res://scenes/materials/chengchi_city_ground_fix.tres` at runtime and verified `scenes/china_terrain_30km.tscn` still headless-loads successfully (`LOAD_OK`).
- Risks:
  - This pass masks the bad inner-ground look through a shader-driven local-height/local-normal filter; if some roof eaves or low stone bases still catch a bit of grass tint in-editor, the next tuning pass should tighten `ground_max_y` / `ground_min_up_dot` rather than replacing the whole approach.
  - Visual acceptance is still pending a live in-editor check; headless verification confirms load safety, not final aesthetics.
- Next:
  - Reopen `scenes/china_terrain_30km.tscn`, inspect one normal city and one outpost up close, and if any remaining grass bleed or triangle highlight survives, do one threshold-only material tuning pass in `scenes/materials/chengchi_city_ground_fix.tres`.
## 2026-03-23 18:19 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Align ChinaTerrain30km terrain layers to the user's requested grass/soil/rock texture sets and remove the remaining global tint / overly dense lowland breakup look.
- Done:
  - Kept the live Terrain3D texture mapping aligned to the requested packed sets in scenes/china_terrain_30km.tscn: grass=ocky_terrain_02, soil=ocky_terrain_03, rock=ocks_ground_05, snow unchanged.
  - Reconfirmed by headless probe that all four active Terrain3D albedo textures load as the same format 19, so the previous white-ground format mismatch is not the active issue anymore.
  - Pulled the Terrain3D material back toward neutral in scenes/china_terrain_30km.tscn to remove the broad color cast: lend_sharpness 0.56, macro_variation1 (0.97,0.99,0.96), macro_variation2 (1.01,1.01,1.0), macro_variation_slope 0.05, 
oise1_scale 0.0011, 
oise2_scale 0.0036, projection_threshold 0.58.
  - Increased terrain texture world size so the visible repeating grid reads much less dense: grass uv_scale 0.016, soil  .034, rock  .028, with slightly calmer normal/roughness values.
  - Updated 	mp/apply_height_slope_terrain_layers.gd so low-altitude grass no longer gets automatic soil breakup (GRASS_SOIL_BREAKUP_STRENGTH 0.0) while keeping height-only distribution with rock still starting around 350m.
  - Re-ran the terrain layer repaint and re-ran the texture-format probe successfully.
- Risks:
  - If the editor has kept scenes/china_terrain_30km.tscn open across many edits, it may still be showing cached Terrain3D state until the scene tab is reopened or the editor is restarted once.
  - 	mp/verify_china_terrain_scene_load.gd still surfaces an unrelated parse failure chain through scripts/presentation/strategy_ui_layer.gd; this terrain pass did not touch that script.
- Next:
  - Reopen scenes/china_terrain_30km.tscn fresh and judge only two things first: whether the previous washed-out tint is gone and whether the grass repetition now reads larger/less grid-like before any further regional hand-painting.
## 2026-03-23 18:45 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Rework the real `ChinaTerrain30km` expedition left panel so the top big frame only wraps one team block, with the add-team action moved to a standalone `+` below it.
- Done:
  - Updated `scripts/presentation/strategy_ui_layer.gd` expedition layout so the top grouped frame only covers the first team block (`3 officer cards + combined stats`), while extra team blocks render below it instead of stretching that top frame.
  - Reset expedition extra-team expansion when opening the expedition panel, and kept the add-team interaction on a dedicated `+` button instead of the old placeholder-row metaphor.
  - Compressed expedition officer cards and simplified the combined summary to just `L/M/I/P/C`, `Soldiers`, and `Troops` so the top block fits the grouped frame more tightly.
  - Repaired multiple pre-existing mixed-encoding / broken-string parse failures in `scripts/presentation/strategy_ui_layer.gd` that were uncovered while restoring the expedition block, and added a few minimal fallback helper implementations so the main scene script chain parses again.
  - Re-ran headless parse verification with `tmp/_tmp_verify_expedition_parse.gd`; `strategy_ui_layer.gd` and `china_terrain_scene.gd` both load successfully again.
- Risks:
  - Some aide/regroup/move helper texts were normalized to English fallback text during the parse recovery; they are functional but may still need a later localization/cleanup pass.
  - A few recovered aide/move helper functions currently use minimal fallback implementations to keep the main scene parse-safe; if the user later wants to polish those panels, they should be revisited separately from expedition UI work.
- Next:
  - Open `scenes/china_terrain_30km.tscn`, verify the expedition top frame / `+` expansion visually, and if spacing is still off, do one more screenshot-driven layout-only pass.
## 2026-03-23 18:28 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Swap the live ChinaTerrain30km soil and rock layers to the user's newly requested texture sets without changing the existing height-layer distribution.
- Done:
  - Updated scenes/china_terrain_30km.tscn so the live terrain texture mapping is now grass=ocky_terrain_02, soil=coast_sand_rocks_02, rock=ocky_trail, snow unchanged.
  - Switched the scene ext-resources for soil to coast_sand_rocks_02_packed_albedo_height / coast_sand_rocks_02_packed_normal_roughness and rock to ocky_trail_packed_albedo_height / ocky_trail_packed_normal_roughness.
  - Rechecked by headless probe that the four currently active Terrain3D albedo textures all load as format 19, so the active texture set remains format-consistent for Terrain3D.
  - Left the current height-only layer rules and the anti-grid material tuning unchanged in this pass.
- Risks:
  - The scene file still carries historical garbled display for the 素材 path prefix in plain text output, so future replacements should continue targeting the filenames/UIDs rather than rewriting the whole prefix blindly.
  - If the editor has the terrain scene open from before this swap, it may still show stale cached textures until the scene tab or editor is reopened.
- Next:
  - Reopen scenes/china_terrain_30km.tscn fresh and confirm whether the soil band now clearly reads as coast_sand_rocks_02 and the mountain rock band reads as ocky_trail before any further color/tiling tuning.
## 2026-03-23 19:20 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix the immediate `china_terrain_30km.tscn` parse failure blocking scene open in Godot.
- Done:
  - Repaired malformed quoted city-name entries inside `scenes/china_terrain_30km.tscn`, including the `major_city_names` array and broken `CityOverlay/CityInstances` node-name / metadata quote pairs that were causing the text-scene parser to stop around line 330 and then line 359.
  - Re-ran headless scene-load verification with `tmp/_tmp_verify_china_scene_load.gd`; `res://scenes/china_terrain_30km.tscn` now loads successfully again (`LOAD_OK scene`).
- Risks:
  - Some city names still display as mojibake when inspected through the current shell/output path; the structural parse problem is fixed, but a later dedicated encoding cleanup pass may still be needed if the scene text itself should be normalized visually.
- Next:
  - Reopen `scenes/china_terrain_30km.tscn` in Godot and verify the editor no longer reports a parse error before continuing expedition UI visual checks.
## 2026-03-23 19:55 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Tighten the real `ChinaTerrain30km` expedition left-side team block after the latest screenshot: remove the visibly overlong blank officer area and reflow the combined team summary.
- Done:
  - Updated `E:\ɽ��־����ĩ\scripts\presentation\strategy_ui_layer.gd` expedition layout sizing so the left team block is tighter overall: wider summary column, slightly taller outer team block, but shorter-looking officer card area.
  - Split the left block layout so the officer-card row and the outer team frame are no longer effectively dragged by the same height target.
  - Changed the combined summary text to one stat per line (`Lead`, `Might`, `Int`, `Pol`, `Charm`) and put `Troop + Soldiers` on one line as requested.
  - Increased officer stat-label minimum height a bit so `Battle / Tactic / Special` reads more stably inside the compressed card area.
  - Re-ran headless parse verification with `res://tmp/_tmp_verify_expedition_parse.gd`; `strategy_ui_layer.gd` and `china_terrain_scene.gd` both load successfully.
- Risks:
  - This pass is still screenshot-driven; exact visual feel of the left block needs one live reopen in Godot to confirm the officer cards are no longer reading as an overlong empty column.
  - The expedition file remains historically fragile from earlier encoding recovery, so future edits should stay layout-local and avoid broad text rewrites.
- Next:
  - Reopen `E:\ɽ��־����ĩ\scenes\china_terrain_30km.tscn`, open Expedition once, and check whether the first team block now feels compact enough; if not, the next step should be one more pass on only `summary_w`, `team_inner_h`, and slot width/height values.
## 2026-03-23 18:35 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Swap the live rock layer to the user's ed_laterite_soil_stones set and retune the height-only terrain bands so rock starts around 320m and snow starts around 500m with a more natural transition.
- Done:
  - Updated scenes/china_terrain_30km.tscn so the live terrain mapping is now grass=ocky_terrain_02, soil=coast_sand_rocks_02, rock=ed_laterite_soil_stones, snow unchanged.
  - Tuned the rock layer material a bit calmer for a more natural read with the new texture: 
ormal_depth 0.085, oughness 0.955, uv_scale 0.034 in scenes/china_terrain_30km.tscn.
  - Updated 	mp/apply_height_slope_terrain_layers.gd to a softer height-only transition: soil fall 260-360m, rock rise 320-430m, snow rise 500-620m.
  - Re-ran the terrain repaint after the threshold change.
  - Reconfirmed by headless probe that the four active Terrain3D albedo textures still all load as format 19.
- Risks:
  - The scene may still show stale Terrain3D cache if it was already open before this pass; reopening the scene tab or restarting the editor may be required to see the new rock/snow bands.
  - Because snow now begins at 500m, broad highland areas may pick up snow sooner than before; if this feels too aggressive, the next adjustment should raise only SNOW_END, not revert the whole pass.
- Next:
  - Reopen scenes/china_terrain_30km.tscn and judge whether the 320m+ red-rock band and 500m+ snow band now read naturally before any further local hand-painting.
## 2026-03-23 20:08 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix the immediate expedition/UI startup error caused by a corrupted cinnabar-cloud icon resource path in `strategy_ui_layer.gd`.
- Done:
  - Repaired `UI_CLOUD_ICON_PATH` in `E:\ɽ��־����ĩ\scripts\presentation\strategy_ui_layer.gd` to point back to the real asset `res://�ز�/icon/xiangyun.png`.
  - Verified the failing call site `_apply_ui_cinnabar_cloud_corners(...)` now resolves against an existing file instead of the previous mojibake path blob.
  - Re-ran both `res://tmp/_tmp_verify_expedition_parse.gd` and `res://tmp/_tmp_verify_china_scene_load.gd`; no parse/load failure remains from this path issue.
- Risks:
  - PowerShell output in this environment still renders some Chinese paths as mojibake in plain text, so terminal display is not a reliable indicator of whether a `res://�ز�/...` path is actually valid at runtime.
  - `AIDE_PORTRAIT_DIR` still appears as a historically damaged path constant in the file, but the current `_resolve_aide_officer_portrait(...)` stub returns `null`, so it is not the active runtime blocker right now.
- Next:
  - Reopen the main scene and confirm the previous `xiangyun.png` load error no longer appears; if the next blocker is another damaged asset constant, fix only that constant locally instead of broad file cleanup.
## 2026-03-23 20:14 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Remove the active regroup-panel runtime blocker caused by a broken resource-change format string in `strategy_ui_layer.gd`.
- Done:
  - Added a safe early return in `E:\ɽ��־����ĩ\scripts\presentation\strategy_ui_layer.gd:4213` so `_build_regroup_resource_change_text(...)` now returns an English fallback `Resources ...` string before the historical mojibake formatter line can execute.
  - Kept the fix surgical and did not broad-rewrite the surrounding damaged text block.
  - Re-ran `res://tmp/_tmp_verify_expedition_parse.gd` and `res://tmp/_tmp_verify_china_scene_load.gd`; both completed successfully with exit code 0.
- Risks:
  - The old corrupted return line still exists below the new safe return as unreachable legacy debris; it is no longer an active runtime blocker, but the file still contains historical encoding damage and should only be cleaned in a dedicated pass.
  - Headless validation confirms parse/load safety, but the regroup panel should still be clicked once in the live `ChinaTerrain30km` scene to confirm the text reads acceptably in context.
- Next:
  - Reopen `E:\ɽ��־����ĩ\scenes\china_terrain_30km.tscn`, trigger the regroup panel once, and if the fallback text is acceptable, continue the screenshot-driven expedition/regroup UI spacing pass instead of broader text cleanup.
## 2026-03-23 18:47 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Swap the live rock layer to the user's gravelly_sand texture and raise the snowline to around 550m while keeping the other terrain bands intact.
- Done:
  - Generated new Terrain3D packed textures for gravelly_sand using the existing 	mp/pack_terrain_texture_set.gd pipeline, then rewrote the new .import files to the same s3tc Terrain3D format as the other active layers.
  - Updated scenes/china_terrain_30km.tscn so the live terrain mapping is now grass=ocky_terrain_02, soil=coast_sand_rocks_02, rock=gravelly_sand, snow unchanged.
  - Tuned the new rock layer a bit softer for a more natural read: 
ormal_depth 0.075, oughness 0.97, uv_scale 0.038.
  - Raised the snow band in 	mp/apply_height_slope_terrain_layers.gd to 550-670m and re-ran the terrain repaint.
  - Reconfirmed by headless probe that the four active Terrain3D albedo textures all load as format 19.
- Risks:
  - gravelly_sand is newly packed this session; if the editor had the terrain scene open throughout, it may still show stale rock textures until the scene tab or editor is reopened.
  - With snow now starting near 550m, some previously snowy ridges will pull back; if the new snow coverage feels too conservative, the next pass should lower only SNOW_END or SNOW_START slightly instead of reworking the full terrain stack.
- Next:
  - Reopen scenes/china_terrain_30km.tscn fresh and confirm whether the new gravelly_sand rock band reads naturally and whether the 550m+ snowline feels right before any more visual tuning.
## 2026-03-23 18:56 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix the all-white Terrain3D editor result after switching the rock layer to gravelly_sand.
- Done:
  - Confirmed the white terrain was caused by a Terrain3D normal texture format mismatch, not by the height-band rules: active normal formats were 21/21/19/21 for grass/soil/rock/snow.
  - Corrected gravelly_sand_packed_normal_roughness.png.import so it matches the working Terrain3D normal imports (compress/normal_map=1, oughness/mode=1, oughness/src_normal set).
  - Re-ran Godot import and re-probed the active normal textures; they now all load as format 21.
  - The active albedo textures remain consistent as format 19, so the Terrain3D texture stack is again format-aligned.
- Risks:
  - If scenes/china_terrain_30km.tscn stayed open during the failed white-ground state, the editor viewport may still need one manual reopen to flush the stale Terrain3D cache.
- Next:
  - Reopen scenes/china_terrain_30km.tscn and confirm the white fallback is gone; only after that should any further rock/snow visual tuning continue.
## 2026-03-23 20:58 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Move the expedition team five-stat summary into the right column and expose team aptitude next to ship/troop choices in the real `ChinaTerrain30km` expedition UI.
- Done:
  - Added expedition-only aptitude helpers in `E:\ɽ��־����ĩ\scripts\presentation\strategy_ui_layer.gd` to read officer `aptitude`, normalize unit role keys, and pick the best grade across the 3 selected officers.
  - Updated expedition troop text so selected troop types now render as `Unit(A) amount`, and troop detail now shows `Team aptitude` for the currently highlighted unit type.
  - Updated expedition ship summary so the right-side summary shows `Ship: ... (Naval X)` and the ship label now reads `Ship / Naval X` using the team-best naval aptitude.
  - Moved the main-team five-stat label from the left team block into the right column, and widened the main officer-slot row to use the full left block width.
  - Re-ran `res://tmp/_tmp_verify_expedition_parse.gd` and `res://tmp/_tmp_verify_china_scene_load.gd`; both completed successfully.
- Risks:
  - This is still a layout-only pass validated headlessly; the exact visual balance of the moved stat block versus the ship/troop controls should still be checked once in the live scene.
  - Troop aptitude is derived from the unit `class_id` where available and falls back to the unit id; if a later custom unit introduces a nonstandard class key, it may need one more local mapping case.
- Next:
  - Reopen `E:\ɽ��־����ĩ\scenes\china_terrain_30km.tscn`, open Expedition, and verify whether the right-column stat block and the new aptitude text spacing read naturally; if crowded, the next pass should only tune `right_stats_w`, `right_controls_w`, and `right_top_h`.
## 2026-03-23 19:10 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Stop manually adjusted city/site positions from snapping back to older JSON coordinates on later rebuilds or scene reopen.
- Done:
  - Updated scripts/presentation/china_city_overlay.gd so editor-time current city instance positions are treated as authoritative before overlay rebuilds and on editor scene ready when instances already exist.
  - Updated scripts/presentation/strategic_site_manager.gd so editor-time current strategic site instance positions are treated as authoritative before data reloads.
  - Added editor_current_positions_authoritative = true to both scripts as the default behavior.
  - Verified both scripts still parse successfully in headless Godot.
- Risks:
  - This only preserves positions that exist as current scene instances; if the editor has unsaved moves, the user still needs to save the scene or trigger a rebuild/reopen after the move so the current instance positions can be written into the override JSON.
- Next:
  - After manually adjusting ferry/outpost positions, save the scene once and trigger a rebuild/reopen; the updated scripts will write those current positions into the override files so later passes should not jump back to old coordinates.
## 2026-03-23 21:12 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Repair the expedition UI after the previous over-aggressive right-column layout pass caused visible overlap in the real `ChinaTerrain30km` scene.
- Done:
  - Reverted the expedition layout structure in `E:\ɽ��־����ĩ\scripts\presentation\strategy_ui_layer.gd` back to the stable left-team-block arrangement: officer slots and summary column are again inside the left block instead of splitting the right column.
  - Kept the requested aptitude additions: ship text still shows team-best naval aptitude, selected troop summary still shows per-unit aptitude, and troop detail still shows team aptitude for the selected troop type.
  - Cleaned the expedition header title back to a safe `Expedition %s` fallback instead of the broken mojibake string.
  - Re-ran `res://tmp/_tmp_verify_expedition_parse.gd` and `res://tmp/_tmp_verify_china_scene_load.gd`; both completed successfully.
- Risks:
  - The visual repair is headless-validated only; the live scene should still be reopened once to confirm the overlap is actually gone.
  - The file still contains older historical mixed-encoding damage in unrelated strings, so future text edits should remain narrow and local.
- Next:
  - Reopen `E:\ɽ��־����ĩ\scenes\china_terrain_30km.tscn`, verify the expedition panel is visually stable again, then do only a very small follow-up pass if you still want the five-stat text nudged a bit further right inside the same left block.
## 2026-03-23 21:22 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix the expedition UI confusion around top-left confirm/close controls and keep the expedition layout stable while preserving the requested aptitude labels.
- Done:
  - Confirmed the main command-panel confirm/cancel buttons are still bottom-anchored by the generic layout path; the visible top-left `Close` came from the expedition troop overlay, not the main panel buttons.
  - Added missing layout code for `ExpeditionTroopOverlay` / `ExpeditionTroopPanel` in `E:\ɽ��־����ĩ\scripts\presentation\strategy_ui_layer.gd`, including title, table, detail, amount spin, and bottom-row apply/clear/close buttons.
  - Fixed a local variable-name collision in that new troop-overlay layout block and revalidated parse/load safety.
  - Kept the earlier expedition layout rollback so the main expedition panel remains on the stable structure while still showing naval/troop aptitude hints.
- Risks:
  - This is still headless-validated only; the troop overlay should be opened once in the live scene to confirm the `Close` button and amount controls now stay inside the centered popup.
  - The left-block five-stat text has only been nudged mildly within the stable layout; if the user wants a stronger shift, it should be done as a tiny offset-only pass, not a structural move.
- Next:
  - Reopen `E:\ɽ��־����ĩ\scenes\china_terrain_30km.tscn`, open the troop popup once, and verify the popup buttons now sit inside the modal near the bottom rather than at the top-left corner.
## 2026-03-23 22:20 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix the real `ChinaTerrain30km` expedition panel so confirm/cancel return to the bottom, the stray top-left expedition residue is suppressed, and the five-stat summary shifts slightly right without another structural layout change.
- Done:
  - Updated `E:\ɽ��־����ĩ\scripts\presentation\strategy_ui_layer.gd` so `_show_expedition_content(...)` explicitly hides hover/tip/floating-title remnants before rebuilding the expedition panel.
  - Updated `_layout_expedition_panel_contents()` to explicitly place `CommandHint`, confirm, and cancel at the bottom center for expedition, and raised their `z_index` so they are not visually buried under expedition content.
  - Nudged the expedition five-stat summary a little further right inside the existing left team block instead of moving it into the right column.
  - Re-ran `res://tmp/_tmp_verify_expedition_parse.gd` and `res://tmp/_tmp_verify_china_scene_load.gd`; both completed without parse/load errors.
- Risks:
  - This remains a headless validation pass; the live expedition panel still needs one in-scene check to confirm the top-left stray control is truly gone visually and the bottom buttons read correctly over the textured panel.
  - `strategy_ui_layer.gd` still contains mixed historical line endings / mojibake in unrelated areas, so future text edits should stay very local.
- Next:
  - Reopen `E:\ɽ��־����ĩ\scenes\china_terrain_30km.tscn`, open the real Expedition panel once, and verify bottom confirm/cancel are visible and the left-top stray button/panel no longer appears; only if the user still wants more shift should the five-stat label move a few more pixels right.
## 2026-03-24 00:08 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Restore the previously added manually placeable mountain mist group that had disappeared from the live ChinaTerrain30km scene.
- Done:
  - Restored the mist texture ext-resource (smoke_07_a.png) into scenes/china_terrain_30km.tscn.
  - Restored the three mist materials and quad meshes (StandardMaterial3D_mist_a/b/c, QuadMesh_mist_a/b/c) into the live scene file.
  - Restored the MountainMist node and its three child cards (MistCardA/B/C) into the live scene tree, positioned the same as the earlier backup.
  - Confirmed the live scene file now contains MountainMist again.
- Risks:
  - This remains a lightweight billboard mist group, not true volumetric cloud rendering; visual quality still depends on where you place/duplicate the node in the editor.
- Next:
  - Open scenes/china_terrain_30km.tscn, search MountainMist in the scene tree, and move/duplicate it to the peaks you want.
## 2026-03-24 00:10 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Isolate high-confidence unused temporary `.glb` variants to reduce asset clutter without deleting recoverable files.
- Done:
  - Moved 21 high-confidence temporary/test `.glb` files from `assets_imports/rpg_troops` and `assets_imports/mixamo_troops/out` into `E:\ɽ��־����ĩ\tmp\glb_quarantine_20260324\...`, preserving their relative paths for easy restore.
  - Wrote a restore manifest at `E:\ɽ��־����ĩ\tmp\glb_quarantine_20260324\manifest_20260324.txt`.
  - Left uncertain non-temp files such as `�ز�/��ģ/����/toushiche.glb` and `�ز�/��ģ/������λ/tiekuangchang.glb` untouched.
- Risks:
  - This was a static-reference cleanup only; Godot may still show no issues until the user reopens the editor and exercises the relevant preview/test scenes.
  - Neighbor `.import` files were left in place intentionally; if these quarantined sources are later restored, Godot should be able to reuse or refresh imports normally.
- Next:
  - Reopen Godot, open the main scenes you actually use, and confirm no missing-model errors appear; if clean, the quarantined `.glb` files can be treated as unused candidates for permanent deletion later.
## 2026-03-24 00:24 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Recover the missing mountain mist, fix the broken china_terrain_30km.tscn parse state, and convert the mist group into a reusable prefab.
- Done:
  - Restored scene parseability by rebuilding the tail of scenes/china_terrain_30km.tscn into a clean CityOverlay + empty CityInstances root and a clean StrategicSites + empty SiteInstances root.
  - This intentionally dropped the corrupted inline city/site instance text that had become invalid scene syntax; the editor/runtime scripts are expected to rebuild instances from the override/data files.
  - Created the reusable prefab scenes/prefabs/mountain_mist.tscn for the mist group.
  - Replaced the live inline mist cards in scenes/china_terrain_30km.tscn with a prefab instance reference 22_mistprefab and kept the previous world transform for placement.
- Risks:
  - On first reopen, the city/site visual instances may need one scene reload/rebuild pass in the editor because the corrupted inline instances were removed on purpose.
  - The main scene still contains some now-unused inline mist-related resources; they are harmless, but could be cleaned later if desired.
- Next:
  - Reopen scenes/china_terrain_30km.tscn, confirm the scene opens again, and if city/site visuals do not immediately reappear, trigger the editor rebuild actions on CityOverlay / StrategicSites once.
## 2026-03-24 09:58 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Pull one Japanese tree asset through the local Tuanjie/Unity install and get a first performance-safe sample into `ChinaTerrain30km`.
- Done:
  - Located the purchased `Japanese Garden Pack` cache under `C:\Users\Admin\AppData\Roaming\Unity\Asset Store-5.x\Waldemarst` and restored the package into `D:\unity\My project\Assets\Waldemarst\JapaneseGardenPackage`.
  - Found installed editors at `D:\unity\2022.3.62t6\Editor\Tuanjie.exe` and `D:\unity\2022.3.62f3c1\Editor\Unity.exe`, then used a temporary batch exporter script in `D:\unity\My project\Assets\Editor\CodexTreeObjExporter.cs` to export `BlackPineTree_B.prefab` LOD0 to OBJ/MTL plus bark/atlas textures.
  - Added the exported source files under `res://�ز�/unity_imports/JapaneseGardenPack_clean/godot/BlackPineTree_B/`.
  - Converted the exported OBJ into a Godot-native packed scene at `res://scenes/prefabs/vegetation/black_pine_tree_b_lod0.tscn`, preserving bark and leaf atlas textures as separate materials and using alpha scissor on foliage for a cheaper first pass.
  - Added `scripts/presentation/japanese_tree_sample_spawner.gd` and attached a `JapaneseTreeSamples` node to `scenes/china_terrain_30km.tscn`; it spawns 3 sample black pine trees near Luoyang using terrain height sampling and modest visibility-range tuning.
- Risks:
  - The current conversion path is OBJ-based and only imported `BlackPineTree_B` LOD0; billboard/true Unity LODGroup behavior is not yet recreated in Godot.
  - The sample placement is hardcoded near Luoyang for quick visual verification and may need relocation or a proper vegetation system once the user approves the look.
  - The temporary Unity batch exporter lives outside the repo in `D:\unity\My project\Assets\Editor\CodexTreeObjExporter.cs`; if more trees are needed, keep using or clean it intentionally.
- Next:
  - Open `scenes/china_terrain_30km.tscn`, inspect the 3 Luoyang-side sample pines, and if the look is accepted, import one maple variant next and replace the hardcoded sample node with a reusable `MultiMeshInstance3D` vegetation sampler.
## 2026-03-24 10:16 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Recover the editor after the first Japanese black pine sample pass caused `china_terrain_30km.tscn` to become unsafe to open.
- Done:
  - Confirmed the exported `BlackPineTree_B` asset itself is not large (`1771` tris / `5313` verts, about `7m` tall) and is unlikely to be the direct cause of the editor stall.
  - Determined the higher-risk issue was the direct scripted writeback into `scenes/china_terrain_30km.tscn` during the sample-tree injection pass.
  - Removed the direct `JapaneseTreeSamples` injection attempt and restored `scenes/china_terrain_30km.tscn` from the sibling known-good copy at `E:\ɽ��־����ĩ - ����\scenes\china_terrain_30km.tscn`.
  - Preserved the converted tree resources (`res://�ز�/unity_imports/JapaneseGardenPack_clean/godot/BlackPineTree_B/*` and `res://scenes/prefabs/vegetation/black_pine_tree_b_lod0.tscn`) for later safer integration.
- Risks:
  - Restoring from the sibling copy may have rolled back scene-level edits made only in the active `china_terrain_30km.tscn` after `2026-03-19 22:24`; compare visually before doing new terrain/site work.
  - The Japanese tree integration still needs a safer path, preferably a separate test scene or an editor-placed child scene rather than scripted direct rewrite of the main scene text.
- Next:
  - Reopen `scenes/china_terrain_30km.tscn` and confirm the editor no longer stalls; then reintroduce the black pine only through a separate test scene or manual instancing workflow.
## 2026-03-24 14:05 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Land the first battlefield runtime pass for the 12-core famous commander unique skills, using a data table instead of placeholder-only button text.
- Done:
  - Added `E:\山河志风起汉末\data\config\unique_skills_v1.json` with 12 named unique skills for Wei/Shu/Wu core commanders, including names, descriptions, cooldowns, effect templates, and auto-cast rules.
  - Updated `E:\山河志风起汉末\scripts\battlefield_controller.gd` to load that table, map deployed/demo commanders to skills, expose names/descriptions through the RTS panel path, and enforce per-unit unique-skill cooldowns.
  - Replaced the old unique-skill placeholder activation path with template-driven runtime effects using existing morale/status/burn/cooldown systems, and upgraded auto-cast to consult per-skill rules instead of one generic trigger.
  - Updated `E:\山河志风起汉末\docs\codex\TASK_BOARD.md` so the active in-progress item reflects the unique-skill landing pass.
- Risks:
  - This environment did not provide a runnable Godot executable, so validation was limited to static/script-level inspection; the new runtime path still needs one real headless/editor load test.
  - `order_cost` is data-ready in the config, but the current battlefield runtime still does not have a true shared military-order resource pool/UI, so unique skills currently enforce cooldown only, not battlefield order-point deduction.
  - Effect templates intentionally reuse existing status/morale/burn systems for a safe first pass, so some buffs are approximations rather than fully bespoke per-skill mechanics.
- Next:
  - Open the project in Godot, load `E:\山河志风起汉末\scenes\battle_demo.tscn` or the real `ChinaTerrain30km` battle path, click several named commanders, and verify button availability / cooldown / auto-cast / effect readability before deciding whether to add a real battlefield military-order pool next.
## 2026-03-24 11:18 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Stop the city-management/aides panel regression where regroup controls leaked into aides and the aides page lost its own layout.
- Done:
  - Patched `E:\山河志风起汉末\scripts\presentation\strategy_ui_layer.gd` so `_set_regroup_controls_visible(false)` now also hides regroup dynamic frames, title labels, and `RegroupUnitCardsScroll`, preventing regroup remnants from leaking into `aides`.
  - Patched aide-mode visibility so aide-only controls are explicitly hidden/shown by mode, and fixed the previous broken state where picker details were forced hidden.
  - Implemented a minimal dedicated `_layout_aides_panel_contents()` so `做官` overview and picker now have their own stable positions again, with confirm/cancel remaining at the bottom.
  - Re-ran `res://tmp/_tmp_verify_expedition_parse.gd` and `res://tmp/_tmp_verify_china_scene_load.gd`; both completed without parse/load errors.
- Risks:
  - This is a surgical stop-the-bleed layout recovery, not a full redesign of the aides/office system; live visual spacing in the real `ChinaTerrain30km` scene still needs one manual in-scene check.
  - `strategy_ui_layer.gd` still has mixed historical mojibake/line-ending history, so future edits should stay equally local.
- Next:
  - Open the real city-management panel in `E:\山河志风起汉末\scenes\china_terrain_30km.tscn`, verify `做官` no longer shows regroup content and buttons stay at the bottom; then adjust only any remaining pixel-level spacing if needed.
## 2026-03-24 11:43 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Recover the Godot editor from the startup stall at "loading plugin window layout".
- Done:
  - Inspected the project editor cache and found `E:\山河志风起汉末\.godot\editor\editor_layout.cfg` had a corrupted first line, matching the startup stall during plugin/window layout load.
  - Backed up the affected project editor cache files into `E:\山河志风起汉末\.godot\editor\_codex_backup_20260324_layout_reset`.
  - Rewrote `E:\山河志风起汉末\.godot\editor\editor_layout.cfg` to a clean minimal default layout.
  - Rewrote `E:\山河志风起汉末\.godot\editor\project_metadata.cfg` to a clean minimal recent-file state.
  - Cleared `E:\山河志风起汉末\.godot\editor\script_editor_cache.cfg`.
  - Confirmed there were no remaining `godot.windows.opt.tools.64` processes after cleanup.
- Risks:
  - This resets only the project-local editor state; if the editor still stalls, the next suspect is a global Godot editor layout/config under `%APPDATA%\Godot\editor` rather than the project cache.
- Next:
  - Reopen the project once; if the stall persists, reset the global Godot editor layout cache next.
## 2026-03-24 11:52 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Stop the expedition UI root from leaking into every other city-management panel.
- Done:
  - Patched `E:\山河志风起汉末\scripts\presentation\strategy_ui_layer.gd` so `generic / aides / regroup / move / hide_command_panel` now explicitly call `_set_expedition_controls_visible(false)`.
  - Patched `_show_expedition_content(...)` to explicitly disable aides/regroup/move controls first, then enable expedition controls, making panel switching symmetrical.
  - Re-ran `res://tmp/_tmp_verify_expedition_parse.gd` and `res://tmp/_tmp_verify_china_scene_load.gd`; both completed without parse/load errors.
- Risks:
  - This fixes the obvious expedition-root leakage; there may still be pixel-level layout overlap inside the individual panels that needs one live visual pass.
- Next:
  - Reopen city management and verify `做官 / 整编 / 调动` no longer show expedition widgets at all; only if any specific leftover block remains should we patch that one node path next.
## 2026-03-24 11:59 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix the missing `xiangyun.png` cloud-corner icon used by the UI ornaments.
- Done:
  - Confirmed the real asset exists at `res://素材/icon/xiangyun.png`.
  - Patched `E:\山河志风起汉末\scripts\presentation\strategy_ui_layer.gd` constant `UI_CLOUD_ICON_PATH` to use the correct non-mojibake path.
  - Re-ran `res://tmp/_tmp_verify_china_scene_load.gd`; the scene loaded successfully.
- Risks:
  - Other historical mojibake resource constants may still exist elsewhere in the codebase, but this specific 祥云 icon error path is now corrected.
- Next:
  - Reopen the UI panels once and confirm the cloud-corner ornament renders again without the previous `xiangyun.png` missing-resource error.
## 2026-03-24 12:07 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Rework the aides overview to match the requested two-row office layout.
- Done:
  - Updated `E:\山河志风起汉末\scripts\presentation\strategy_ui_layer.gd` aide overview layout so the `taishou`/Governor slot is placed alone on the first row.
  - Placed all remaining visible aide offices in a single second row across the panel width.
  - Disabled the reused right-side portrait/description frame during aides overview, removing the unwanted large box.
  - Re-ran `res://tmp/_tmp_verify_expedition_parse.gd` and `res://tmp/_tmp_verify_china_scene_load.gd`; both completed without parse/load errors.
- Risks:
  - This is a structural layout change only; if the user wants the Governor card wider/narrower or aligned left instead of centered, that is now a small pixel-level follow-up.
- Next:
  - Open the aides overview in the live scene and verify the Governor sits alone on row one and every other office sits on row two with no right-side frame remaining.
## 2026-03-24 10:31 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Provide a safe standalone test scene for the imported Japanese black pine without touching `ChinaTerrain30km`.
- Done:
  - Created `scenes/tree_test.tscn` as a minimal isolated preview scene with environment, sun, camera, simple ground, and 3 instances of `black_pine_tree_b_lod0.tscn`.
  - Kept the test scene completely separate from `scenes/china_terrain_30km.tscn` to avoid repeating the previous main-scene writeback risk.
  - Verified `scenes/tree_test.tscn` headless-loads successfully and instantiates 3 tree children under `Trees` (`TREE_TEST_LOAD_OK trees=3`).
- Risks:
  - This is only a preview scene; no terrain height adaptation, vegetation batching, or large-map culling system is wired here yet.
  - The black pine asset still only represents exported `LOD0`; later performance work should add a simpler distant representation or a `MultiMeshInstance3D` sampler.
- Next:
  - Open `scenes/tree_test.tscn` in the editor, judge tree scale/material look, and if approved, import a second tree variant (recommended `JapaneseMapleTree_D`) into the same isolated test scene before any large-map integration.

## 2026-03-24 12:49 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Recover the lost ChinaTerrain30km terrain textures after the live scene regressed to the old 2-layer Terrain3D setup.
- Done:
  - Confirmed E:\山河志风起汉末\scenes\china_terrain_30km.tscn had fallen back to the old grass-02 + ock Terrain3D texture block.
  - Restored the live scene to a 4-layer packed terrain stack using valid es://素材/textures/... paths: grass=ocky_terrain_02, soil=coast_sand_rocks_02, rock=gravelly_sand, snow=snow_02.
  - Restored the newer anti-tiling Terrain3D material tuning on the live scene (lend_sharpness, macro variation, projection) instead of leaving the older sharp 2-layer settings.
  - Saved a safety copy at E:\山河志风起汉末\scenes\china_terrain_30km.tscn.codex_backup_20260324_restore_textures before editing.
  - Verified the restored live scene loads successfully with E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\山河志风起汉末 --quit --scene res://scenes/china_terrain_30km.tscn.
- Risks:
  - This restores the terrain texture asset/material block only; the painted splat distribution on the terrain is whatever the current live data already contains, so visual layer coverage may still need in-editor adjustment.
  - The scene still has historical encoding/mojibake history in some lines, so future edits should stay local and avoid broad rewrites.
- Next:
  - Open E:\山河志风起汉末\scenes\china_terrain_30km.tscn in the editor and confirm the four terrain layers are visible again; if any layer still looks wrong, tune the live paint distribution instead of swapping the asset block again.

## 2026-03-24 13:00 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix Guan Yu / Zhang Fei unique skills still reporting has no valid target even when the unit is already fighting a manually selected enemy.
- Done:
  - Patched E:\山河志风起汉末\scripts\battlefield_controller.gd unique-skill target selection so melee state now treats the current locked target as valid even when center-point distance/facing is transiently unfavorable.
  - Added a close-contact enemy fallback for unique skills, so frontal/cone skills can still resolve onto the nearest engaged enemy when the cone query temporarily returns empty.
  - Applied that fallback specifically to rontal_cleave_pressure and cone_roar_disrupt, covering Guan Yu and Zhang Fei.
  - Verified both es://scenes/battle_demo.tscn and es://scenes/china_terrain_30km.tscn headless-load successfully with the user-provided Godot executable.
- Risks:
  - This fixes target acquisition robustness, not balance; if the user later wants stricter directional gameplay again, we should add a softer manual-cast rule instead of removing the fallback entirely.
  - Headless scene load passed, but the final judgment still needs one in-battle manual cast check on Guan Yu / Zhang Fei against a locked melee target.
- Next:
  - In E:\山河志风起汉末\scenes\battle_demo.tscn, order Guan Yu or Zhang Fei to attack a nearby enemy, wait until they enter melee, then cast the unique skill and confirm it now fires on the engaged target instead of showing has no valid target.

## 2026-03-24 13:07 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Revert the extra Guan Yu / Zhang Fei melee fallback after the user identified the real cause as those commanders temporarily using siege equipment.
- Done:
  - Removed the extra close-contact unique-skill fallback helpers from E:\山河志风起汉末\scripts\battlefield_controller.gd.
  - Restored unique-skill target detection to the earlier cleaner version, while keeping the previously added face-direction improvement toward the intended target.
  - Verified es://scenes/battle_demo.tscn still headless-loads with the user-provided Godot executable.
- Risks:
  - With the fallback removed, Guan Yu / Zhang Fei again depend on their intended non-siege troop behavior and normal frontal-cone rules; if they are reassigned to unusual siege-like carriers later, the old target issue may reappear by design.
- Next:
  - Keep Guan Yu / Zhang Fei on normal combat troop types and do one manual in-battle cast check to confirm the simpler targeting now behaves as expected.
## 2026-03-24 12:18 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fine-tune aides overview sizing and make the appointment cost/status text clearer.
- Done:
  - Enlarged the Governor/`taishou` card in `E:\山河志风起汉末\scripts\presentation\strategy_ui_layer.gd` to a larger near-square first-row card.
  - Kept the non-governor offices on the second row but constrained that row to a centered narrower width so it no longer stretches edge-to-edge.
  - Updated the aides overview status line to explicitly show order cost, appointment count, and current available orders.
  - Updated the no-change helper text and per-card pending marker to clearer wording.
  - Re-ran `res://tmp/_tmp_verify_expedition_parse.gd` and `res://tmp/_tmp_verify_china_scene_load.gd`; both completed without parse/load errors.
- Risks:
  - Because `strategy_ui_layer.gd` still has historical encoding issues, the human-readable helper strings were kept ASCII-safe this pass to avoid introducing another mojibake regression.
- Next:
  - Reopen the aides overview and verify the Governor card feels large enough; if the user still wants it larger or wants the second row even tighter, only do one more pixel-level spacing pass.
## 2026-03-24 10:54 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix the obviously wrong dark leaf look in `tree_test.tscn` and add a first sakura preview without touching `ChinaTerrain30km`.
- Done:
  - Confirmed the black pine preview looked wrong because the raw Unity-to-Godot material translation was incomplete; the issue is not tree size but leaf shading/backface handling in the preview pass.
  - Added `scripts/presentation/tree_preview_tuner.gd` plus wrapper preview scenes `scenes/prefabs/vegetation/black_pine_tree_b_preview.tscn` and `scenes/prefabs/vegetation/sakura_tree_a_preview.tscn` so foliage gets alpha scissor, two-sided rendering, backlight, and reduced shadow harshness for preview.
  - Extended the local Unity/Tuanjie batch exporter to export `SakuraTree_A.prefab`, then converted it to `scenes/prefabs/vegetation/sakura_tree_a_lod0.tscn`.
  - Found that `SakuraTree_A` bark texture is actually JPEG data mislabeled as `.png`; added a `.jpg` alias and used that in the Godot conversion path.
  - Updated `scenes/tree_test.tscn` to use the black pine preview wrapper and added 2 sakura instances; verified the test scene loads and now contains 5 tree instances total.
- Risks:
  - `scenes/prefabs/vegetation/sakura_tree_a_lod0.tscn` is large because its textures are embedded for reliability; this is acceptable for preview but should be optimized before any large-map use.
  - The preview tuner improves the obviously wrong black look, but it is still only an approximation of the original Unity/Broccoli foliage shader.
- Next:
  - Open `scenes/tree_test.tscn`, judge the new black pine + sakura look, and if accepted, either optimize sakura into a lighter reusable resource path or import `JapaneseMapleTree_D` as the third test species.

## 2026-03-24 14:22 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Change Guan Yu and Zhang Fei back to normal infantry after confirming the earlier cast issue came from them spawning with siege-role assignments.
- Done:
  - Updated E:\山河志风起汉末\data\config\battle_rules.json so demo_team_a_unit_roles now starts with infantry, infantry instead of two siege entries, making the first two Team A demo commanders (Guan Yu and Zhang Fei) spawn as normal infantry.
  - Updated E:\山河志风起汉末\scripts\battlefield_controller.gd default 	eam_a_unit_roles fallback to PackedStringArray(["infantry", "infantry"]) so non-rule fallback behavior stays consistent.
  - Verified es://scenes/battle_demo.tscn still headless-loads with the user-provided Godot executable.
- Risks:
  - Only the first two Team A demo slots were normalized; if the user later binds Guan Yu / Zhang Fei through custom deployment data elsewhere, those external deployment roles can still override this demo default.
- Next:
  - Open E:\山河志风起汉末\scenes\battle_demo.tscn, select Guan Yu and Zhang Fei, and confirm their panel role now shows infantry and their unique skills cast normally in melee.
## 2026-03-24 11:02 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix the visible floating roots in `tree_test.tscn`.
- Done:
  - Measured the exported tree bounds and confirmed the issue was pivot/placement, not model size: black pine min Y about `-0.4208`, sakura min Y about `-0.2037`.
  - Updated all tree instance placements in `scenes/tree_test.tscn` from `y = 0.42` to `y = 0.0` so the roots sink into the ground plane instead of hovering above it.
  - Re-verified `scenes/tree_test.tscn` still headless-loads successfully with 5 tree instances.
- Risks:
  - Some species may still need per-tree bury offsets later because each exported prefab has a slightly different local origin.
- Next:
  - Reopen `scenes/tree_test.tscn`; if any species still floats or sinks too deep, tune per-instance Y offsets or add a species-level root bury offset wrapper.
## 2026-03-24 14:13 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Restore the missing ChinaTerrain30km move panel body after the recent city-command UI regression.
- Done:
  - Confirmed the regression root cause in `E:\山河志风起汉末\scripts\presentation\strategy_ui_layer.gd` was `func _layout_move_panel_contents() -> void:` returning immediately, leaving the whole move page without any positioned content.
  - Replaced that stub with a minimal dedicated move layout: header, target column, central officer/transport column, right summary/detail column, plus bottom hint and centered cancel/confirm buttons.
  - Kept the fix local to move-panel positioning only, so existing `_apply_move_mode_visibility()` logic still decides whether dispatch / recall / resource transport / troop transport widgets are shown.
  - Re-ran `res://tmp/_tmp_verify_expedition_parse.gd` and `res://tmp/_tmp_verify_china_scene_load.gd`; both passed headless after the patch.
- Risks:
  - This is a surgical recovery of the missing move UI, not a visual polish pass; if the user wants tighter spacing per move subtype, do one screenshot-driven spacing pass only on this function.
  - `strategy_ui_layer.gd` still has mixed-encoding history, so future edits should remain very local and avoid broad text rewrites.
- Next:
  - Open the real `ChinaTerrain30km` city command UI, enter each move subtype once (`Dispatch`, `Recall`, `Resources`, `Troops`), and confirm the restored layout is visible and that the bottom confirm/cancel area no longer overlaps content.
## 2026-03-24 14:32 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix Guan Yu still failing to cast after Guan Yu / Zhang Fei were moved back to infantry.
- Done:
  - Confirmed Guan Yu and Zhang Fei were already back on infantry defaults, so the remaining cast failure was no longer a siege-role issue.
  - Narrowed the likely cause to Guan Yu's unique skill using a tighter frontal-cone window than Zhang Fei while target acquisition is still based on unit-center distance during melee.
  - Updated E:\山河志风起汉末\data\config\unique_skills_v1.json for guanyu_weizhenhuaxia: ange 12.0 -> 14.0 and cone_angle_deg 70.0 -> 82.0.
  - Verified es://scenes/battle_demo.tscn still headless-loads with the user-provided Godot executable.
- Risks:
  - This is a tuning-side fix, not a structural targeting rewrite; if the user later enlarges formation spacing again, similar center-distance issues can reappear on other short frontal skills.
- Next:
  - Reopen E:\山河志风起汉末\scenes\battle_demo.tscn and test Guan Yu's unique skill in melee; if it still occasionally fails, the next step should be a targeted melee-center-distance exception only for manual frontal unique skills.

## 2026-03-24 14:55 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix the unit-defeat battle report so the HUD speaks from the defeating commander instead of the defeated side, and include the immediate reward summary in the same playback.
- Done:
  - Patched E:\山河志风起汉末\scripts\battlefield_controller.gd on_unit_defeated(...) so when a valid killer exists, the defeat HUD now uses the killer commander as speaker and no longer starts with the defeated unit's self-report line.
  - Patched E:\山河志风起汉末\scripts\battlefield_controller.gd _grant_team_battle_reward(...) to support reward accumulation without forcing a separate HUD report.
  - Unit-defeat reports now combine the kill announcement and the immediate reward delta (war_merit, gongji, 	ech_points, grain, wood, iron) into one HUD line.
  - Preserved the old fallback only for edge cases where no valid killer exists; in that case the defeated-side collapse report still appears.
  - Verified es://scenes/battle_demo.tscn headless-loads successfully with the user-provided Godot executable.
- Risks:
  - This pass fixes unit-defeat playback only; site/facility events still use their existing separate reward-report flow unless changed later for consistency.
  - Reward text is still presentation-only battle summary data; it is not yet wired into any larger campaign economy settlement layer beyond the existing team battle stats bucket.
- Next:
  - Open E:\山河志风起汉末\scenes\battle_demo.tscn, defeat one enemy unit, and confirm the HUD portrait/name now belongs to the killer commander and the same line includes the immediate reward summary.
## 2026-03-24 14:33 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Restore the real ChinaTerrain30km move panel so dispatch / recall / resource transport / troop transport no longer open as empty pages.
- Done:
  - Confirmed the second root cause in `E:\山河志风起汉末\scripts\presentation\china_terrain_scene.gd` was that `_build_site_panel_data(...)` never built move panel data and always returned empty `targets`, `source_officers`, `source_resources`, and `source_stats` for move actions.
  - Added runtime move-panel builders in `E:\山河志风起汉末\scripts\presentation\china_terrain_scene.gd` so move pages now receive same-faction target sites, source officers, source resources, source troop stats, and target rosters.
  - Connected `city_move_requested` in the ChinaTerrain runtime path and added a minimal runtime move executor so confirm now transfers officers/resources/troops between same-faction source/target sites instead of doing nothing.
  - Added focused helper functions for unique move IDs, troop-composition transfer, personnel cleanup after officer transfer, and city aide-score rebuild after move.
  - Re-ran `res://tmp/_tmp_verify_expedition_parse.gd`; it passed after the move patch.
- Risks:
  - The broader `res://scenes/china_terrain_30km.tscn` headless load is currently blocked by pre-existing terrain texture ext_resource mojibake paths (`res://缂佽京濮靛?...`), which is unrelated to this move patch but still prevents a clean scene-load validation.
  - The move executor is intentionally minimal and does not yet include extra polish/status text per subtype beyond basic success/failure feedback.
- Next:
  - Open the real city move UI and verify these concrete cases: `Dispatch` list populated, `Recall` target roster populated, `Resources` sliders show non-zero max/value labels when the source has stock, and confirming each subtype changes the source/target state as expected.
## 2026-03-24 15:35 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Safely place the imported Japanese tree cluster into the real `ChinaTerrain30km` main scene without re-running a risky whole-scene rewrite.
- Done:
  - Confirmed the working tree assets remain isolated in `scenes/prefabs/vegetation/japanese_tree_cluster_luoyang.tscn` with 2 black pines and 1 sakura, plus terrain snapping handled by `scripts/presentation/japanese_tree_cluster.gd`.
  - Found `scenes/china_terrain_30km.tscn` had widespread string corruption in the `CityOverlay` block, not just the previously identified texture-path mojibake, so local line-patching was no longer safe.
  - Backed up the broken current scene to `E:\山河志风起汉末\tmp\_tmp_corrupt_china_terrain_30km_before_restore_20260324.tscn`.
  - Restored `scenes/china_terrain_30km.tscn` from `E:\山河志风起汉末 - 副本\scenes\china_terrain_30km.tscn` and then re-added the `JapaneseTreeClusterLuoyang` ext_resource + root child instance.
  - Verified the restored main scene text now contains the tree cluster instance and intact `major_city_names` entries again.
- Risks:
  - Because the main scene was restored from the sibling backup copy, any scene-only edits made after that backup point may have been rolled back again; runtime/script-side fixes in other files remain intact.
  - Headless verification in Godot returned clean exit, but the temporary tree-cluster instantiate check still produced engine leak spam on exit, so final confidence should come from one visual editor/runtime check near Luoyang.
- Next:
  - Open `E:\山河志风起汉末\scenes\china_terrain_30km.tscn`, look near Luoyang, and visually confirm the 3-tree cluster sits on the terrain with acceptable size/shading/perf before expanding to more trees.
## 2026-03-24 14:42 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Clean up the move target list so it no longer shows invalid field units or duplicate city entries.
- Done:
  - Fixed `E:\山河志风起汉末\scripts\presentation\china_terrain_scene.gd` move target collection to stop listing runtime `field_unit` and `convoy` entries as valid move destinations.
  - Added target-id deduplication in the same move-target collector so duplicate city entries such as two `许昌 (city)` rows no longer appear.
  - Re-ran `res://tmp/_tmp_verify_expedition_parse.gd`; it still passes after the target-list cleanup.
- Risks:
  - This pass only narrows the target list; if the user wants more nuanced target rules later (for example exactly which site types are allowed), refine that whitelist directly in the same collector instead of touching the move UI again.
- Next:
  - Reopen the move panel and confirm the target list now keeps cities/sites only, with no `field_unit` rows and no duplicate `许昌` entry.
## 2026-03-24 15:37 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Simplify famous commander skill release toward a more San14-like auto-trigger feel so skills do not depend on fussy manual timing, especially for Zhang Liao.
- Done:
  - Patched E:\山河志风起汉末\scripts\battlefield_controller.gd so unique-skill auto mode now defaults to enabled (amous_auto_default_enabled = true).
  - Added a lightweight unique-skill auto proc roll with a short retry cooldown instead of only using the older strict all-or-nothing auto check.
  - Relaxed auto-cast conditions for frontal and dash-type unique skills to treat active melee/engagement as sufficient pressure, instead of requiring overly strict spatial checks every time.
  - Expanded unique-skill target acquisition for dash/charge templates so locked targets can still be chosen from a more forgiving pre-contact distance.
  - Updated E:\山河志风起汉末\data\config\unique_skills_v1.json so Zhang Liao's zhangliao_weizhenxiaoyaojin gets uto_proc_chance = 0.62.
  - Verified es://scenes/battle_demo.tscn still headless-loads with the user-provided Godot executable.
- Risks:
  - This is intentionally a feel/UX simplification; the result is less manually precise and a bit more gamey, which matches the user's request but is less deterministic than the earlier strict logic.
  - Manual cast still exists, but the new default auto mode may make it feel less necessary; if later the user wants exact manual control for some commanders, per-skill default-auto flags should be added.
- Next:
  - Open E:\山河志风起汉末\scenes\battle_demo.tscn, let Zhang Liao enter combat, and confirm his unique skill now tends to auto-fire naturally during engagement without needing awkward manual timing.

## 2026-03-24 15:44 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Make the imported tree cluster visible in the 30km main map by moving it next to the real Luoyang city coordinates and improving editor-side terrain snap timing.
- Done:
  - Verified Luoyang city instance in `scenes/china_terrain_30km.tscn` sits around `(6620, 2298)`.
  - Moved the 3-tree cluster in `scenes/prefabs/vegetation/japanese_tree_cluster_luoyang.tscn` from the earlier wrong test coordinates to positions beside Luoyang.
  - Updated `scripts/presentation/japanese_tree_cluster.gd` so terrain snapping is deferred in both `_enter_tree()` and `_ready()`, improving the chance that trees land correctly even when the scene is opened directly in the editor.
- Risks:
  - If the user has the scene already open in Godot, they may need to reload the scene tab once to see the moved cluster and refreshed editor-side snap.
- Next:
  - Reopen `scenes/china_terrain_30km.tscn`, navigate to Luoyang, and confirm the 2 pines + 1 sakura are now visible and grounded.

## 2026-03-24 16:02 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix the Japanese tree cluster disappearing when the user moved the cluster near Luoyang in the 30km main scene.
- Done:
  - Diagnosed the real issue: `JapaneseTreeClusterLuoyang` root in `scenes/china_terrain_30km.tscn` had been moved away from origin, while `scripts/presentation/japanese_tree_cluster.gd` was still snapping child trees using local coordinates, so moving the root sent the visible trees away from the expected terrain location.
  - Changed `scripts/presentation/japanese_tree_cluster.gd` to terrain-snap each child using `global_position` instead of local `position`.
  - Converted `scenes/prefabs/vegetation/japanese_tree_cluster_luoyang.tscn` child tree placements into small local offsets around the cluster root.
  - Set the main-scene cluster root transform to the Luoyang area at roughly `(6620, 2298)` so the whole cluster now behaves like a normal movable group.
  - Re-checked `scenes/china_terrain_30km.tscn` parse after removing an accidental literal newline escape sequence from the transform line.
- Risks:
  - If the scene tab stayed open across these edits, the editor may still be showing a stale instance cache until the tab or project reloads.
- Next:
  - Reload `scenes/china_terrain_30km.tscn`; if the trees still do not render, inspect the expanded `JapaneseTreeClusterLuoyang` children in the Scene tree and force `Editable Children` once to confirm the instanced preview scenes are present.

## 2026-03-24 16:19 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Revert famous skills to manual-by-default while simplifying both manual and auto trigger conditions so they stop relying on fussy cone/area geometry checks.
- Done:
  - Changed E:\山河志风起汉末\scripts\battlefield_controller.gd amous_auto_default_enabled back to alse, so unique skills are manual by default again.
  - Kept the simplified auto proc framework, but changed auto decision rules so AOE-style unique skills (rea_control_zone, rea_fire_burst, chain_fire_spread, rontal_cleave_pressure, cone_roar_disrupt) now trigger from simple local combat pressure (close_enemy_count >= 2 or melee state) instead of checking detailed cone/area coverage.
  - Simplified manual cast execution for frontal/cone famous skills so if the cone query returns empty, they now fall back to all nearby enemies in radius rather than failing on exact facing geometry.
  - Verified es://scenes/battle_demo.tscn still headless-loads with the user-provided Godot executable.
- Risks:
  - This intentionally trades precision for feel; frontal/cone skills are now less spatially strict and may occasionally hit nearby enemies that are not perfectly in front, which matches the user's request for simpler triggers.
- Next:
  - Open E:\山河志风起汉末\scenes\battle_demo.tscn, keep unique skills on manual by default, then test both manual casts and auto toggles to confirm they no longer fail due to cone/area micromanagement.
## 2026-03-24 16:47 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Verify whether the editor freeze was still caused by the old `xiangyun` missing-resource bug.
- Done:
  - Rechecked the live `E:\山河志风起汉末\scripts\presentation\strategy_ui_layer.gd` cloud-icon constant and rewrote the `UI_CLOUD_ICON_PATH` line in-place to the intended `res://素材/icon/xiangyun.png` entry.
  - Verified with a focused headless Godot script that both `res://scripts/presentation/strategy_ui_layer.gd` and `res://素材/icon/xiangyun.png` load successfully.
  - Verified `res://scenes/china_terrain_30km.tscn` also loads successfully in a focused headless check, so the screenshoted old `xiangyun` error is likely stale editor output / reload noise rather than the current blocking cause.
- Risks:
  - The editor can still appear as Windows `未响应` while reparsing the very large `china_terrain_30km.tscn` scene and replaying many warnings; this is now more of an editor responsiveness/perf issue than a confirmed missing-resource crash.
- Next:
  - If the editor keeps hanging after a full restart with the cleared/fixed `xiangyun` path, profile the editor-side stall itself (scene open time, warning flood sources, and heavy plugin/inspector redraw paths) instead of chasing the old cloud-icon error again.
## 2026-03-24 16:45 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Align battle reporting with the user's clarified intent: bottom commander dialogue should summarize player-side major wins/losses clearly, while the left report should continue covering broad player-related battle events.
- Done:
  - Reworked E:\山河志风起汉末\scripts\battlefield_controller.gd on_unit_defeated(...) so player-side victories now produce bottom HUD dialogue from the defeating player commander with the immediate reward delta in the same line.
  - Reworked E:\山河志风起汉末\scripts\battlefield_controller.gd on_unit_defeated(...) loss branch so when the enemy defeats a player-side unit, the bottom HUD now reports from the player/defender side instead of feeling like enemy celebration playback.
  - Reworked E:\山河志风起汉末\scripts\battlefield_controller.gd on_site_captured(...) so player-side captures now combine the capture announcement and reward delta into the same bottom HUD line, while enemy captures of player sites now produce a clean player-loss warning line.
  - Reworked E:\山河志风起汉末\scripts\battlefield_controller.gd _report_demo_facility_destroyed(...) so player destruction of enemy facilities now combines battle gains into the same bottom HUD line, while enemy destruction of player facilities reports a defensive loss warning from the player side.
  - Verified es://scenes/battle_demo.tscn still headless-loads with the user-provided Godot executable.
- Risks:
  - This pass focuses on current unit defeat / site capture / facility destruction battle events; explicit officer-capture (俘虏) playback still needs a dedicated event source if that mechanic is added or already exists elsewhere.
  - Left-side scrolling report still inherits the broader commander report system; this change makes major HUD events more player-facing, but does not yet create a fully separate player-only event channel.
- Next:
  - Open E:\山河志风起汉末\scenes\battle_demo.tscn, trigger one player victory and one player loss case, and confirm the bottom HUD now reads like player-side battlefield reporting with reward summaries on wins and clear loss warnings on defeats.

## 2026-03-24 16:18 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Create batch-planting oriented lightweight variants of the imported Japanese trees for future Terrain3D instancer/scatter use.
- Done:
  - Added `scripts/presentation/tree_batch_light_tuner.gd` to build a lighter tree presentation pass aimed at large-map planting: lower cull margin, finite visibility range, GI disabled, optional single-sided leaves, no backlight/transmittance, and no tree shadow casting by default.
  - Added lightweight wrapper scenes `scenes/prefabs/vegetation/black_pine_tree_b_batch_light.tscn` and `scenes/prefabs/vegetation/sakura_tree_a_batch_light.tscn` so the original imported base scenes remain untouched.
  - Added `scenes/tree_batch_light_test.tscn` as a tiny validation scene containing 2 pines + 1 sakura using the new lightweight wrappers.
  - Verified the new test scene headless-loads and instantiates 3 children successfully.
- Risks:
  - The lightweight wrappers still sit on top of the current imported base meshes; they reduce render cost, but they are not yet true reduced-geometry LOD assets.
  - Leaves are now single-sided by default for performance, so from some view angles they may look thinner; if the user dislikes that, flip `use_double_sided_leaves` back on for that species.
- Next:
  - Open `scenes/tree_batch_light_test.tscn` and judge whether the lighter look is acceptable; if yes, wire these light wrappers into Terrain3D Instancer for the first Luoyang-area batch planting pass.
## 2026-03-24 17:02 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Stop the expedition troop-assignment popup from covering the top commander slot frames.
- Done:
  - Adjusted the expedition troop popup layout in `E:\山河志风起汉末\scripts\presentation\strategy_ui_layer.gd` so the troop panel now opens below the commander/team block instead of starting near the top and overlapping the main/vice commander frames.
  - Kept the change local to expedition troop popup positioning only (`troop_panel_y` / derived height), without touching the rest of the expedition page layout.
  - Re-ran `res://tmp/_tmp_verify_expedition_parse.gd`; it still passes after the layout change.
- Risks:
  - This is a positional hotfix; if the user later adds many extra teams, the popup may still need one more constrained-height pass rather than a full expedition layout rewrite.
- Next:
  - Reopen expedition, click the troop-assignment button, and confirm the popup no longer blocks the top commander slot row.
## 2026-03-24 17:08 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Converge the imported tree strategy to only two large-map species (green pine + sakura), using the same lightweight model wrappers with larger baseline size and per-instance size variation.
- Done:
  - Updated `E:\山河志风起汉末\scenes\prefabs\vegetation\black_pine_tree_b_batch_light.tscn` so the lightweight green tree now uses a built-in `scale = Vector3(5, 5, 5)` baseline and a slightly longer visibility range for large-map use.
  - Updated `E:\山河志风起汉末\scenes\prefabs\vegetation\sakura_tree_a_batch_light.tscn` so the sakura lightweight tree also uses the same built-in `scale = Vector3(5, 5, 5)` baseline.
  - Added `E:\山河志风起汉末\scripts\presentation\japanese_tree_batch_sample_spawner.gd` as a simple two-species sample spawner that keeps species count low while varying only rotation and effective visual size.
  - Added `E:\山河志风起汉末\scenes\tree_batch_large_sample.tscn` to host that spawner, and refreshed `E:\山河志风起汉末\scenes\tree_batch_light_test.tscn` so its instances now represent the intended 4.2x–6.0x visual range around the new 5x baseline.
  - Verified `res://scenes/tree_batch_light_test.tscn` and `res://scenes/tree_batch_large_sample.tscn` both load successfully in headless Godot.
- Risks:
  - `tree_batch_large_sample.tscn` is a tool-spawned sample scene, so its children are created at runtime/editor-time rather than being serialized into the scene file; that is fine for preview but not yet the final Terrain3D instancer wiring.
  - The wrappers are still based on the current imported source meshes, so this is a rendering-cost reduction strategy, not a true geometry-decimation pass.
- Next:
  - Open `E:\山河志风起汉末\scenes\tree_batch_light_test.tscn` and/or `E:\山河志风起汉末\scenes\tree_batch_large_sample.tscn`, judge whether the 5x baseline plus 4.2x–6.0x variation feels right, then wire these two wrappers into the Terrain3D instancer for the Luoyang batch planting pass.

## 2026-03-24 18:53 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Recover the ChinaTerrain30km terrain textures again after the live scene was re-saved back to the old 2-layer Terrain3D asset block.
- Done:
  - Confirmed E:\山河志风起汉末\scenes\china_terrain_30km.tscn had once again reverted to the old grass-02 + ock two-layer Terrain3D resource setup.
  - Restored the live scene back to the 4-layer packed terrain setup using valid es://素材/textures/... paths for grass (ocky_terrain_02), soil (coast_sand_rocks_02), rock (gravelly_sand), and snow (snow_02).
  - Restored the anti-tiling Terrain3D material settings (lend_sharpness, macro variation, projection) on the live scene.
  - Saved a safety copy at E:\山河志风起汉末\scenes\china_terrain_30km.tscn.codex_backup_20260324_restore_textures_2 before rewriting the terrain block.
  - Verified es://scenes/china_terrain_30km.tscn headless-loads successfully with the user-provided Godot executable.
- Risks:
  - The most likely regression source is the Godot editor tab holding an older in-memory version of the scene; if the user saves that stale tab again, it can overwrite the restored file back to the old 2-layer terrain block.
- Next:
  - In Godot, close the currently open china_terrain_30km.tscn tab **without saving**, then reopen the scene fresh from disk before making any further edits to avoid re-overwriting the restored terrain resources.

## 2026-03-24 18:54 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Diagnose whether `E:\山河志风起汉末` is an empty Git repository or a broken one, and identify first-commit risks.
- Done:
  - Verified the repository is a normal non-bare work tree with `.git\HEAD` pointing at `refs/heads/master`, but with no commits, no refs, no index, and no remotes yet.
  - Ran `git fsck --full`, `git rev-list --all --count`, and `git count-objects -v`; results match a clean empty repository rather than repository corruption.
  - Confirmed the recent `git` failure was environmental, not repository damage: portable Git now runs correctly and this repo is registered as a global safe directory.
  - Reviewed first-commit risk areas: current `.gitignore` only ignores `.godot/` and misses large temp/backup/import directories such as `tmp/`, `_tmp_plugins/`, `assets_imports/`, many `*.bak*` scene/script backups, and multi-hundred-MB terrain backup folders under `data/terrain/china_30km`.
  - Confirmed `git-lfs` is available, which will be useful if large runtime terrain/resource binaries are intentionally versioned.
- Risks:
  - A naive first commit would capture a very noisy and very large working tree, including temporary probes, backup snapshots, logs, and possibly gigabytes of duplicate terrain backup data.
  - Some large files under `data/` appear runtime-critical while others are clearly backups; these need to be separated carefully before the first real commit so the repository history does not start bloated.
- Next:
  - Tighten `.gitignore` and define the first-commit allowlist/denylist before running `git add`, especially around `tmp/`, `_tmp_plugins/`, `assets_imports/`, scene/script backup files, and terrain backup directories.
## 2026-03-24 19:04 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix the ChinaTerrain30km expedition add-team regression where newly added team blocks overlapped the top commander row instead of stacking below it.
- Done:
  - Patched E:\ɽ��־����ĩ\scripts\presentation\strategy_ui_layer.gd inside _layout_expedition_panel_contents() so visible extra expedition team blocks now always receive their position and size before child-slot layout runs.
  - The root cause was dead code: extra_block.position and extra_block.size were indented after if not should_show: continue, so the extra blocks never got laid out and stayed piled on the upper layer.
  - Verified the focused headless parse still succeeds with E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\ɽ��־����ĩ -s res://tmp/_tmp_verify_expedition_parse.gd.
- Risks:
  - This is a surgical layout fix only; if the user still sees cover/overlap after a fresh reopen, the remaining suspect is z-order/child order rather than placement math.
  - strategy_ui_layer.gd has mixed-encoding history, so future edits in this area should stay line-local and avoid broad rewrites.
- Next:
  - Reopen the expedition UI from a fresh scene/runtime state, press the add-team + button again, and confirm the new block now stacks below the main team block instead of covering the top row.

## 2026-03-24 19:00 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Reduce first-commit noise by tightening root Git ignore rules and rechecking what still needs deliberate staging.
- Done:
  - Rewrote `E:\山河志风起汉末\.gitignore` to ignore Godot/editor cache, Codex probe files, root recovery logs, local backup copies, terrain backup directories, and obvious temporary script artifacts.
  - Confirmed the newly ignored set now covers `.godot/`, `tmp/`, `_tmp_plugins/`, root `.codex_*` / `.tmp_*` probes, `_codex_*.ps1`, root restore logs, `scenes/*backup*.tscn`, `scripts/**/*.bak*`, `data/config/*backup*.json`, and `data/terrain/china_30km/terrain_data_backup_*`.
  - Rechecked the remaining unignored tree and verified the major first-commit payload is now concentrated in actual project content such as `addons/`, `scripts/`, `scenes/`, `docs/`, `data/config/`, `data/terrain/china_30km/terrain_data`, `assets_imports/`, and `素材/`.
  - Confirmed `git-lfs` is available, but did not yet assign LFS tracking rules because some large asset folders still need an intentional keep-vs-ignore decision.
- Risks:
  - `素材/` (~4.7 GB) and `assets_imports/` (~123 MB) remain unignored and may be necessary for runtime, but a full first commit including them will be very large unless LFS policy is decided first.
  - Root terrain resources (`terrain3d*.res`, `china_dem.png`) and large terrain runtime data may be legitimate project assets, so they should be staged deliberately rather than via a blind `git add .`.
- Next:
  - Decide between a lightweight code/data first commit versus a full playable asset commit with Git LFS, then stage only the chosen allowlist.
## 2026-03-24 19:22 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Tighten the ChinaTerrain30km expedition team-row layout so the three officer slots and the right-side five-stat summary stop colliding and fill the team block cleanly.
- Done:
  - Adjusted E:\ɽ��־����ĩ\scripts\presentation\strategy_ui_layer.gd in _layout_expedition_panel_contents() to use a 4-column layout inside each expedition team block: 3 officer slot columns + 1 stats column.
  - Replaced the old uneven slots_w / summary_w split with 	eam_column_gap + 	eam_column_w, so the main row and extra team rows now share the same aligned widths.
  - Moved the main stats label and extra-team summary label to the new column start, which pushes the five-stat column slightly right and removes the overlap with the third officer slot.
  - Verified the focused headless parse still succeeds with E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\ɽ��־����ĩ -s res://tmp/_tmp_verify_expedition_parse.gd.
- Risks:
  - This is still a text-heavy English placeholder layout (Vice Commander II, etc.); if long localized strings remain crowded later, the next minimal fix should be font-size or label clipping inside the slot card, not another broad panel rewrite.
  - Godot sometimes looks "normal after reopen" because stale UI state/layout caches are cleared when the scene/script reloads; this patch fixes the underlying width math, but editor/runtime reopen may still mask unrelated transient layout states.
- Next:
  - Reopen the expedition UI and confirm each row now reads as four clean columns across the large frame, with the right-side five-stat column no longer touching the third officer slot.

## 2026-03-24 19:10 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Create a lightweight initial Git commit that captures the project skeleton, code, docs, and small core resources without pulling in the large raw asset trees.
- Done:
  - Staged the lightweight baseline set: root Git/config files, `project.godot`, `addons/`, `scripts/`, `scenes/`, `tools/`, `docs/`, `data/config/`, and small root terrain/icon resources.
  - Kept large or noisy trees out of the first commit, including `assets_imports/`, `素材/`, `data/terrain/` runtime/backup payloads, `.godot/`, `tmp/`, `_tmp_plugins/`, and known backup/log outputs.
  - Tightened `.gitignore` again so `tools/_tmp_*`, performance CSV/translation outputs, `*.TMP`, and tilde-prefixed temp files do not slip into the lightweight baseline.
- Risks:
  - The repository is now ready for history, but this first commit is intentionally not a full asset-complete playable checkout because raw import/source asset trees remain outside version control.
  - Some staged plugin binaries inside `addons/` are large but appear to be real runtime/plugin dependencies rather than disposable temp output.
- Next:
  - After this baseline commit, decide which runtime asset folders must be tracked next and whether to put them under Git LFS before any large asset commit.
