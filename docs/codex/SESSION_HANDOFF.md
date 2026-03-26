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
  - `璧拌埜` long-distance auto embark point search is not yet staged (current focus is advanced ship ferry automation).
- Next:
  - Run battle demo scenario test focused on three cases:
    1) advanced ship clicking water from inland auto-routes via ferry;
    2) advanced ship shallow embark is blocked;
    3) `璧拌埜` shallow embark remains allowed.

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
  - Generated packed terrain textures in `绱犳潗/textures/`:
    - `aerial_rocks_02_packed_albedo_height.png` (`aerial_rocks_02_diff_2k.jpg` RGB + `aerial_rocks_02_disp_2k.png` alpha)
    - `aerial_rocks_02_packed_normal_roughness.png` (`绱犳潗/nature/textures/rock-norm.png` RGB + `aerial_rocks_02_rough_2k.jpg` alpha)
  - Updated `scenes/china_terrain_30km.tscn` rock `Terrain3DTextureAsset` to use the new packed textures and raised `normal_depth` from `0.55` to `0.72` for stronger mountain relief.
- Risks:
  - The packed normal/roughness texture currently reuses the existing `rock-norm.png` RGB because no EXR-capable conversion tool was available in-session for `aerial_rocks_02_nor_gl_2k.exr`; visual fit should still improve, but it is not a full-source-set replacement yet.
  - New packed PNGs do not have pre-generated Godot import artifacts in this shell; the editor/runtime should import them on next project open, but this was not exercised in-session.
  - Godot executable is still unavailable here, so no live camera/view validation was possible.
- Next:
  - Open `scenes/china_terrain_30km.tscn` in Godot once so the new packed textures import, then inspect a few mountain ranges at gameplay camera height.
  - If the relief still feels weak or the normal pattern mismatches the albedo, convert `绱犳潗/textures/aerial_rocks_02_nor_gl_2k.exr` into a Terrain3D packed normal/roughness texture and retune `normal_depth` from there.

## 2026-03-22 14:43 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Resolve the white Terrain3D surface caused by mixed texture-prep formats and switch the grass layer to the requested `aerial_grass_rock` set.
- Done:
  - Confirmed the white terrain came from mixed Terrain3D texture formats: the new rock layer used packed albedo/height + packed normal/roughness while the grass layer still used the old unpacked pair.
  - Generated `绱犳潗/textures/aerial_grass_rock_packed_albedo_height.png` from `aerial_grass_rock_diff_2k.jpg` + `aerial_grass_rock_disp_2k.png`.
  - Generated `绱犳潗/textures/aerial_grass_rock_packed_normal_roughness.png` from existing grass normal RGB + `aerial_grass_rock_rough_2k.jpg` alpha.
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
  - Updated `scripts/presentation/strategy_ui_layer.gd` regroup UX to show per-class `current / delta / after` values directly in the unit list and adjustment summary, relabeled buttons to `锟斤拷锟斤拷 / 锟斤拷锟斤拷 / 锟斤拷锟矫碉拷锟斤拷`, and switched detail text from plan-centric wording to direct quantity-adjustment wording.
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
  - Generated `锟截诧拷/textures/rocky_terrain_02_packed_albedo_height.png` from `rocky_terrain_02_diff_2k.jpg` + `rocky_terrain_02_disp_2k.png`.
  - Updated `锟截诧拷/textures/rocky_terrain_02_packed_albedo_height.png.import` to Terrain3D-compatible s3tc + mipmaps import settings.
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
  - Corrected `res://锟截诧拷/...` paths that had been accidentally rewritten into mojibake in the scene and related packed-texture `.import` files.
  - Generated `锟截诧拷/textures/rocky_terrain_02_packed_normal_roughness.png` and wired the grass layer to it in `scenes/china_terrain_30km.tscn`.
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
  - 涓?ChinaTerrain30km 涓诲満鏅殑鍑哄緛娴佺▼琛ヤ笂鐗圭鍏靛墠缃暟鎹紝璁╀富灏嗕笓灞炵壒绉嶅叺鍏堝湪杩愯鏃?roster銆佸嚭寰佺晫闈㈠拰鍑哄緛 payload 涓彲瑙併€?- Done:
  - 鍦?scripts/presentation/china_terrain_scene.gd 澧炲姞鐗圭鍏佃鍒欒鍙栬緟鍔┿€佽В閿佺姸鎬佽鍙栧拰鍐涘畼鐗圭鍏垫爣娉ㄩ€昏緫锛涘煄甯?roster 鐜板湪浼氱粰绗﹀悎鏉′欢鐨勬灏嗛檮甯?special_troop_* 瀛楁銆?  - 鍦?scripts/presentation/strategy_ui_layer.gd 鐨勫嚭寰佺晫闈腑锛屼负姝﹀皢浜旂淮鏂囨湰杩藉姞鐗圭鍏电姸鎬侊紝骞跺湪涓诲皢鎻愮ず閲屾樉绀虹壒绉嶅叺鍚嶇О銆佸熀搴曞叺绉嶃€佽В閿佺姸鎬佸拰瑙ｉ攣浠ｄ环銆?  - 鎵╁睍鍑哄緛 payload锛岄€忎紶 main_special_troop_* 瀛楁锛屼緵鍚庣画鐪熸鎺ュ叆鏁寸紪鍏电鍑哄緛鏃剁洿鎺ユ秷璐广€?  - 淇 data/config/special_troop_rules.json 涓枃鍐呭锛屽綋鍓嶅凡鍖呭惈鐧介┈涔変粠銆侀櫡闃佃惀銆佽棨鐢插叺涓夋潯瑙勫垯銆?- Risks:
  - 褰撳墠鍑哄緛绯荤粺浠嶆湭鐪熸閫夋嫨鈥滀富灏嗗甫鍝被鏁寸紪鍏电鈥濓紝鎵€浠ョ壒绉嶅叺浠嶅彧鏄墠缃睍绀轰笌鏁版嵁閫忎紶锛屽皻鏈湪鍑哄緛纭鏃惰浆鍖栦负瀹為檯閮ㄩ槦銆?  - 鏈疆娌℃湁鎺ュ叆鈥滀粯璐硅В閿佲€濅氦浜掞紝special_troop_unlocks 浠嶄粎璇诲彇 world_state.meta锛屾湭鎻愪緵 UI 鍐欏叆璺緞銆?  - 鏈湴缂哄皯 Godot 杩愯鐜锛屾湰娆′粎鍋氫簡闈欐€佹鏌ュ拰 JSON 瑙ｆ瀽鏍￠獙銆?- Next:
  - 鍏堟妸鍑哄緛缂栨垚鏀规垚鐩存帴浣跨敤鐜版湁鏁寸紪閮ㄩ槦/鍏电锛涚‘瀹氫富灏嗘墍甯﹀熀搴曞叺绉嶅悗锛屽啀鎶娾€滃凡瑙ｉ攣鐗圭鍏佃嚜鍔ㄦ浛鎹㈠搴斿叺绉嶁€濇帴鍒板嚭寰佺‘璁ゅ拰鎴樺満鐢熸垚閾捐矾銆?

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
  - Measured `绱犳潗/寤烘ā/寤虹瓚鍗曚綅/chengchi.glb` in Blender headless mode: 1 mesh object, about 39,656 vertices / 49,980 triangles.
  - Generated `绱犳潗/寤烘ā/寤虹瓚鍗曚綅/chengchi_ct30_low.glb` via Blender cleanup + automatic topology simplification (`remove_doubles`, limited planar dissolve, decimate collapse). The optimized mesh now imports at about 12,751 vertices / 10,402 triangles.
  - Updated `scripts/presentation/china_city_overlay.gd` so `ChinaTerrain30km` now routes default city instances to `res://绱犳潗/寤烘ā/寤虹瓚鍗曚綅/chengchi_ct30_low.glb` instead of the original `chengchi.glb`.
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
  - 浼樺寲 ChinaTerrain30km 鐨勫嚭寰佺紪鎴愮晫闈細姝﹀皢鏍忎綅涓嶅啀鏄剧ず浜旂淮锛屾敼涓烘樉绀烘垬鏂椾釜鎬?鐗规妧锛屽苟鎶婇€夊皢鏀规垚浜岀骇鍒楄〃绐楀彛銆?- Done:
  - 鍦?scripts/presentation/strategy_ui_layer.gd 鎶婂嚭寰佹爮浣嶄粠涓嬫媺妗嗘敼鎴愭寜閽紡鏍忎綅锛岀偣鍑讳富灏?鍓皢鏍忎綅浼氬脊鍑轰簩绾ф灏嗗垪琛ㄧ獥銆?  - 鏂板鍑哄緛鎸戝皢绐楀彛锛屽垪琛ㄥ垪鍑烘灏嗐€佹垬鏂椾釜鎬с€佺壒鎶€銆佺壒绉嶅叺锛屽苟鎻愪緵璇︽儏鍖恒€佺‘瀹氫换鐢ㄣ€佽涓虹┖缂恒€佸叧闂寜閽€?  - 鍑哄緛鏍忎綅鏂囨鏀逛负 鎴樻枟涓€?/ 鐗规妧 / 鐗圭鍏碉紝绉婚櫎浜嗘灏嗕簲缁村睍绀猴紱鏈€夋嫨姝﹀皢鏃朵笉鍐嶈嚜鍔ㄥ～鍏呮湰鍩庡墠涓変汉锛岃€屾槸淇濇寔绌虹己绛夊緟鎵嬪姩閫夋嫨銆?  - 椤烘墜淇浜嗗嚭寰佺晫闈㈢殑鑸瑰瀷銆佹爣棰樸€佹彁绀烘枃鏈拰鐗圭鍏垫彁绀轰腑鐨勪腑鏂囦贡鐮侊紝閬垮厤杩欏潡缁х画鎵╂暎鏃у瓧绗︿覆闂銆?- Risks:
  - 鏈疆浠嶆槸闈欐€佷慨鏀癸紝褰撳墠 shell 閲屾病鏈夌洿鎺ヨ窇 Godot 缂栬緫鍣ㄩ獙璇佺晫闈氦浜掞紝鎵€浠ヤ簩绾х獥鍙ｇ殑灏哄銆侀伄鎸″拰 Tree 浜や簰杩橀渶瑕佷綘鍦ㄥ満鏅噷鐐逛竴娆＄‘璁ゃ€?  - 鍑哄緛娴佺▼浠嶆湭鎺ュ叆鈥滀娇鐢ㄦ暣缂栧悗鐨勫疄闄呭叺绉?鏁伴噺鈥濓紝鎵€浠ヨ繖杞彧瑙ｅ喅鎸戝皢 UI 涓庝俊鎭睍绀猴紝涓嶅寘鍚湡姝ｆ寜鏁寸紪閮ㄩ槦鍑哄緛銆?- Next:
  - 杩?scenes/china_terrain_30km.tscn 瀹炴祴鍑哄緛缂栨垚锛岀‘璁や簩绾ф寫灏嗙獥鎵嬫劅鍚庯紝缁х画鎶婂嚭寰侀槦浼嶆敼鎴愮洿鎺ユ秷璐圭幇鏈夋暣缂栭儴闃熶笌鍏电銆?

## 2026-03-22 17:48 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Reduce the generic `ChinaTerrain30km` city asset texture payload after the first lowpoly pass, so the large map uses a lighter city package in memory and on disk.
- Done:
  - Verified that the generic city asset still carried three embedded 4096x4096 textures after the geometry-only pass.
  - Generated `绱犳潗/寤烘ā/寤虹瓚鍗曚綅/chengchi_ct30_low_2k.glb` by importing the lowpoly city asset, resizing all embedded textures to 2048x2048 in Blender, and exporting a dedicated large-map GLB.
  - Confirmed the new asset imports with the same lowpoly geometry (`10,402` triangles) and three 2048x2048 textures; file size dropped from about `37.02 MB` (`chengchi_ct30_low.glb`) to about `11.38 MB`.
  - Updated `scripts/presentation/china_city_overlay.gd` so `ChinaTerrain30km` now defaults to `res://绱犳潗/寤烘ā/寤虹瓚鍗曚綅/chengchi_ct30_low_2k.glb` for generic city instances.
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
  - Generated dedicated large-map assets `绱犳潗/寤烘ā/寤虹瓚鍗曚綅/luoyang_ct30_low_2k.glb`, `绱犳潗/寤烘ā/寤虹瓚鍗曚綅/guanai_ct30_low_2k.glb`, and `绱犳潗/寤烘ā/寤虹瓚鍗曚綅/jindu_ct30_low_2k.glb` with reduced geometry plus 2048x2048 embedded textures.
  - Verified the optimized imports: `luoyang_ct30_low_2k.glb` about `50,664` triangles, `guanai_ct30_low_2k.glb` about `10,874`, `jindu_ct30_low_2k.glb` about `10,861`, all with three `2048x2048` textures. File sizes are about `13.18 MB`, `11.86 MB`, and `10.85 MB` respectively.
  - Updated `scripts/presentation/china_city_overlay.gd` so the `ChinaTerrain30km` Luoyang special-case model path now points to `res://绱犳潗/寤烘ā/寤虹瓚鍗曚綅/luoyang_ct30_low_2k.glb`.
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
  - Added and ran `tmp/apply_slope_39_grass_rule.gd` through Godot headless to rewrite Terrain3D control maps so slopes below `39锟斤拷` use texture id `0` (grass) and steeper slopes use texture id `1` (rock).
  - Retuned the base grass/macro-variation parameters in `scenes/china_terrain_30km.tscn` to reduce neat blockiness:
    - `blend_sharpness` softened to `0.4`
    - `macro_variation1` / `macro_variation_slope` / `noise1_scale` / `noise2_scale` adjusted for broader macro breakup
    - grass `normal_depth` lowered to `0.10`, `roughness` raised to `0.97`, `uv_scale` adjusted to `0.082`
- Risks:
  - Because the control maps were rewritten directly, any earlier hand-painted grass/rock mask decisions are now replaced by the pure slope rule.
  - Unrelated parse issues still exist in `scripts/presentation/china_terrain_scene.gd`; they did not block this texture/control-map write, but they still appear in headless script reload.
- Next:
  - Open the terrain scene and visually inspect whether the 39锟斤拷 split is too aggressive; if so, raise or lower the threshold by 2-4 degrees and rerun the slope script.

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
  - Corrected the weather particle preload paths in `scripts/presentation/china_terrain_scene.gd` to the actual `res://绱犳潗/brackeys_vfx_bundle/...` assets.
- Risks:
  - These two core scripts still contain a lot of legacy mojibake in older, less-used UI text outside the main regroup -> expedition path; they are parse-safe now, but not all visible labels are fully cleaned back to proper Chinese yet.
  - I validated by headless parse and field-path inspection, not by clicking through the full `scenes/china_terrain_30km.tscn` UI in the editor, so final acceptance still needs an in-scene interaction pass.
  - Some expedition/aide text is temporarily English for stability; if you want a full Chinese polish pass, it should be done as a focused cleanup after the interaction flow is confirmed.
- Next:
  - Open `scenes/china_terrain_30km.tscn`, verify the real flow `鏁寸紪 -> 鍑哄緛`, confirm that troop allocation uses the organized composition correctly, and check that a main commander with an unlocked matching special troop activates it only when the allocated troop class matches.
  - If the flow feels right, do a dedicated UI text cleanup pass for the remaining main-scene regroup / expedition / aide labels and convert the temporary English placeholders into final Chinese wording.

## 2026-03-22 19:21 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Retexture the generic large-map city asset so city walls use the user-provided sandstone material and the green inner ground areas switch to `rocky_terrain_02_diff_2k.jpg`.
- Done:
  - Confirmed the provided `C:\Users\Admin\Downloads\large_sandstone_blocks_01_2k.blend` path was actually a directory wrapper from an extracted asset pack; used `C:\Users\Admin\Downloads\large_sandstone_blocks_01_2k.blend.zip` and its `textures/large_sandstone_blocks_01_diff_2k.jpg` source instead.
  - Inspected `绱犳潗/寤烘ā/寤虹瓚鍗曚綅/chengchi_ct30_low_2k.glb` and confirmed the city still uses one 2048x2048 base-color atlas plus existing normal/roughness maps.
  - Generated `绱犳潗/寤烘ā/寤虹瓚鍗曚綅/chengchi_ct30_low_2k_retex_base.png` by compositing the current base atlas with tiled sandstone blocks on wall/stone regions and `res://绱犳潗/textures/rocky_terrain_02_diff_2k.jpg` on the olive-green inner-ground regions.
  - Exported the new asset `绱犳潗/寤烘ā/寤虹瓚鍗曚綅/chengchi_ct30_low_2k_retex.glb`; verified it keeps the lowpoly geometry (`10,402` triangles) and uses the new 2048x2048 base texture while preserving the existing normal/roughness textures.
  - Updated `scripts/presentation/china_city_overlay.gd` so generic `ChinaTerrain30km` cities now use `res://绱犳潗/寤烘ā/寤虹瓚鍗曚綅/chengchi_ct30_low_2k_retex.glb`.
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
  - Re-exported `绱犳潗/寤烘ā/寤虹瓚鍗曚綅/chengchi_ct30_low_2k_retex.glb` and regenerated `绱犳潗/寤烘ā/寤虹瓚鍗曚綅/chengchi_ct30_low_2k_retex_base.png` with the refined masks.
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
  - Open `scenes/china_terrain_30km.tscn` and verify the real `锟斤拷锟斤拷 -> 锟斤拷锟斤拷` UI now shows readable Chinese in troop categories, troop passive text, officer slot summaries, and aide assignment windows.
  - If the wording reads correctly, do one last small polish pass to convert the remaining English placeholders in the same main-scene flow into final Chinese text.

## 2026-03-22 20:30 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Respond to visual feedback from the Godot import preview: wall texture detail was too sparse (only one or two block repeats visible), while the inner ground still needed to read more like grass.
- Done:
  - Increased sandstone tiling density specifically for wall-cap stone regions from the previous broad pass to a much denser repeat, so the visible stone trim should no longer read as only one or two giant bricks.
  - Added a separate, very subtle treatment bucket for bright wall-body plaster regions instead of painting them with the same large sandstone pattern.
  - Made the ground treatment grass-dominant again, leaving only light rocky variation rather than strong rocky replacement.
  - Re-exported `绱犳潗/寤烘ā/寤虹瓚鍗曚綅/chengchi_ct30_low_2k_retex.glb` and regenerated `绱犳潗/寤烘ā/寤虹瓚鍗曚綅/chengchi_ct30_low_2k_retex_base.png` with the denser wall-cap tiling.
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
  - Normalized the broken outpost model resource path in `scenes/prefabs/fortress_outpost_instance.tscn` to the real UTF-8 asset path `res://锟截诧拷/锟斤拷模/锟斤拷锟斤拷锟斤拷位/chengchi_ct30_low_2k_retex.glb`.
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
  - Rebuilt `绱犳潗/寤烘ā/寤虹瓚鍗曚綅/chengchi_ct30_low_2k_retex_base.png` so the outer wall body now receives dense sandstone tiling, wall-cap strips keep their own sandstone pass, and the inner ground remains grass-dominant.
  - Re-exported `绱犳潗/寤烘ā/寤虹瓚鍗曚綅/chengchi_ct30_low_2k_retex.glb` with the new base atlas.
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
  - Rebuilt `绱犳潗/寤烘ā/寤虹瓚鍗曚綅/chengchi_ct30_low_2k_retex_base.png` and re-exported `绱犳潗/寤烘ā/寤虹瓚鍗曚綅/chengchi_ct30_low_2k_retex.glb` so the gatehouse top now falls back to the original roof/base-color treatment instead of sandstone.
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
  - Re-exported `绱犳潗/寤烘ā/寤虹瓚鍗曚綅/chengchi_ct30_low_2k_retex.glb` and regenerated `绱犳潗/寤烘ā/寤虹瓚鍗曚綅/chengchi_ct30_low_2k_retex_base.png` with the four-side gate exclusion applied.
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
  - Reused `res://锟截诧拷/brackeys_vfx_bundle/particles/alpha/smoke_07_a.png` as the mist texture and tuned three separate materials/quad sizes for a layered thin-cloud look.
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
  - Replace the fake bright-green inner ground look with a ground treatment much closer to `res://绱犳潗/textures/rocky_terrain_02_diff_2k.jpg`.
- Done:
  - Rebuilt the city retexture using the existing geometry-driven wall/body/gate masks, but changed the inner-ground compositing to be rocky-texture dominant instead of grass-base dominant.
  - Used two scales of `rocky_terrain_02_diff_2k.jpg` sampling for the ground area to reduce obvious simple tiling and exported the updated `绱犳潗/寤烘ā/寤虹瓚鍗曚綅/chengchi_ct30_low_2k_retex.glb`.
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
  - Re-exported `绱犳潗/寤烘ā/寤虹瓚鍗曚綅/chengchi_ct30_low_2k_retex.glb` and regenerated `绱犳潗/寤烘ā/寤虹瓚鍗曚綅/chengchi_ct30_low_2k_retex_base.png`.
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
  - Flattened the courtyard mesh itself by moving vertices predominantly belonging to ground polygons onto a shared average ground plane (`avg z 鈮?0.037126`), affecting `689` vertices.
  - Recomputed face normals after flattening, then rebuilt and re-exported `绱犳潗/寤烘ā/寤虹瓚鍗曚綅/chengchi_ct30_low_2k_retex.glb` while preserving the current wall/gate texture masks.
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
  - Saved those packed outputs both as PNGs and as directly loadable `.res` texture resources under `绱犳潗/textures`.
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
  - New thresholds: grass fades around `95鈥?85m`; soil dominates roughly `75鈥?60m` on gentler terrain; rock now mainly appears at `420m+` or steep `30鈥?6掳` slopes; snow starts around `635m+`.
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
  - New stronger reset-style thresholds: grass now stays mostly on lower flatter land (`60鈥?35m`, `8鈥?4掳`), soil dominates broadly from low hills through most inland terrain (`35鈥?50m`, `12鈥?4掳`), rock is delayed to higher/steeper mountains (`540m+` or `36鈥?2掳`), and snow starts later (`690m+`).
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
  - Recovered the scene from the sibling project copy at `E:\灞辨渤蹇楅璧锋眽鏈?- 鍓湰\scenes\china_terrain_30km.tscn`, and kept a backup of the broken file at `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\china_terrain_30km.tscn.codex_broken_backup_20260323_anti_tiling`.
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
  - The scene file still carries historical garbled display for the 绱犳潗 path prefix in plain text output, so future replacements should continue targeting the filenames/UIDs rather than rewriting the whole prefix blindly.
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
  - Updated `E:\山锟斤拷志锟斤拷锟斤拷末\scripts\presentation\strategy_ui_layer.gd` expedition layout sizing so the left team block is tighter overall: wider summary column, slightly taller outer team block, but shorter-looking officer card area.
  - Split the left block layout so the officer-card row and the outer team frame are no longer effectively dragged by the same height target.
  - Changed the combined summary text to one stat per line (`Lead`, `Might`, `Int`, `Pol`, `Charm`) and put `Troop + Soldiers` on one line as requested.
  - Increased officer stat-label minimum height a bit so `Battle / Tactic / Special` reads more stably inside the compressed card area.
  - Re-ran headless parse verification with `res://tmp/_tmp_verify_expedition_parse.gd`; `strategy_ui_layer.gd` and `china_terrain_scene.gd` both load successfully.
- Risks:
  - This pass is still screenshot-driven; exact visual feel of the left block needs one live reopen in Godot to confirm the officer cards are no longer reading as an overlong empty column.
  - The expedition file remains historically fragile from earlier encoding recovery, so future edits should stay layout-local and avoid broad text rewrites.
- Next:
  - Reopen `E:\山锟斤拷志锟斤拷锟斤拷末\scenes\china_terrain_30km.tscn`, open Expedition once, and check whether the first team block now feels compact enough; if not, the next step should be one more pass on only `summary_w`, `team_inner_h`, and slot width/height values.
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
  - Repaired `UI_CLOUD_ICON_PATH` in `E:\山锟斤拷志锟斤拷锟斤拷末\scripts\presentation\strategy_ui_layer.gd` to point back to the real asset `res://锟截诧拷/icon/xiangyun.png`.
  - Verified the failing call site `_apply_ui_cinnabar_cloud_corners(...)` now resolves against an existing file instead of the previous mojibake path blob.
  - Re-ran both `res://tmp/_tmp_verify_expedition_parse.gd` and `res://tmp/_tmp_verify_china_scene_load.gd`; no parse/load failure remains from this path issue.
- Risks:
  - PowerShell output in this environment still renders some Chinese paths as mojibake in plain text, so terminal display is not a reliable indicator of whether a `res://锟截诧拷/...` path is actually valid at runtime.
  - `AIDE_PORTRAIT_DIR` still appears as a historically damaged path constant in the file, but the current `_resolve_aide_officer_portrait(...)` stub returns `null`, so it is not the active runtime blocker right now.
- Next:
  - Reopen the main scene and confirm the previous `xiangyun.png` load error no longer appears; if the next blocker is another damaged asset constant, fix only that constant locally instead of broad file cleanup.
## 2026-03-23 20:14 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Remove the active regroup-panel runtime blocker caused by a broken resource-change format string in `strategy_ui_layer.gd`.
- Done:
  - Added a safe early return in `E:\山锟斤拷志锟斤拷锟斤拷末\scripts\presentation\strategy_ui_layer.gd:4213` so `_build_regroup_resource_change_text(...)` now returns an English fallback `Resources ...` string before the historical mojibake formatter line can execute.
  - Kept the fix surgical and did not broad-rewrite the surrounding damaged text block.
  - Re-ran `res://tmp/_tmp_verify_expedition_parse.gd` and `res://tmp/_tmp_verify_china_scene_load.gd`; both completed successfully with exit code 0.
- Risks:
  - The old corrupted return line still exists below the new safe return as unreachable legacy debris; it is no longer an active runtime blocker, but the file still contains historical encoding damage and should only be cleaned in a dedicated pass.
  - Headless validation confirms parse/load safety, but the regroup panel should still be clicked once in the live `ChinaTerrain30km` scene to confirm the text reads acceptably in context.
- Next:
  - Reopen `E:\山锟斤拷志锟斤拷锟斤拷末\scenes\china_terrain_30km.tscn`, trigger the regroup panel once, and if the fallback text is acceptable, continue the screenshot-driven expedition/regroup UI spacing pass instead of broader text cleanup.
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
  - Added expedition-only aptitude helpers in `E:\山锟斤拷志锟斤拷锟斤拷末\scripts\presentation\strategy_ui_layer.gd` to read officer `aptitude`, normalize unit role keys, and pick the best grade across the 3 selected officers.
  - Updated expedition troop text so selected troop types now render as `Unit(A) amount`, and troop detail now shows `Team aptitude` for the currently highlighted unit type.
  - Updated expedition ship summary so the right-side summary shows `Ship: ... (Naval X)` and the ship label now reads `Ship / Naval X` using the team-best naval aptitude.
  - Moved the main-team five-stat label from the left team block into the right column, and widened the main officer-slot row to use the full left block width.
  - Re-ran `res://tmp/_tmp_verify_expedition_parse.gd` and `res://tmp/_tmp_verify_china_scene_load.gd`; both completed successfully.
- Risks:
  - This is still a layout-only pass validated headlessly; the exact visual balance of the moved stat block versus the ship/troop controls should still be checked once in the live scene.
  - Troop aptitude is derived from the unit `class_id` where available and falls back to the unit id; if a later custom unit introduces a nonstandard class key, it may need one more local mapping case.
- Next:
  - Reopen `E:\山锟斤拷志锟斤拷锟斤拷末\scenes\china_terrain_30km.tscn`, open Expedition, and verify whether the right-column stat block and the new aptitude text spacing read naturally; if crowded, the next pass should only tune `right_stats_w`, `right_controls_w`, and `right_top_h`.
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
  - Reverted the expedition layout structure in `E:\山锟斤拷志锟斤拷锟斤拷末\scripts\presentation\strategy_ui_layer.gd` back to the stable left-team-block arrangement: officer slots and summary column are again inside the left block instead of splitting the right column.
  - Kept the requested aptitude additions: ship text still shows team-best naval aptitude, selected troop summary still shows per-unit aptitude, and troop detail still shows team aptitude for the selected troop type.
  - Cleaned the expedition header title back to a safe `Expedition %s` fallback instead of the broken mojibake string.
  - Re-ran `res://tmp/_tmp_verify_expedition_parse.gd` and `res://tmp/_tmp_verify_china_scene_load.gd`; both completed successfully.
- Risks:
  - The visual repair is headless-validated only; the live scene should still be reopened once to confirm the overlap is actually gone.
  - The file still contains older historical mixed-encoding damage in unrelated strings, so future text edits should remain narrow and local.
- Next:
  - Reopen `E:\山锟斤拷志锟斤拷锟斤拷末\scenes\china_terrain_30km.tscn`, verify the expedition panel is visually stable again, then do only a very small follow-up pass if you still want the five-stat text nudged a bit further right inside the same left block.
## 2026-03-23 21:22 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix the expedition UI confusion around top-left confirm/close controls and keep the expedition layout stable while preserving the requested aptitude labels.
- Done:
  - Confirmed the main command-panel confirm/cancel buttons are still bottom-anchored by the generic layout path; the visible top-left `Close` came from the expedition troop overlay, not the main panel buttons.
  - Added missing layout code for `ExpeditionTroopOverlay` / `ExpeditionTroopPanel` in `E:\山锟斤拷志锟斤拷锟斤拷末\scripts\presentation\strategy_ui_layer.gd`, including title, table, detail, amount spin, and bottom-row apply/clear/close buttons.
  - Fixed a local variable-name collision in that new troop-overlay layout block and revalidated parse/load safety.
  - Kept the earlier expedition layout rollback so the main expedition panel remains on the stable structure while still showing naval/troop aptitude hints.
- Risks:
  - This is still headless-validated only; the troop overlay should be opened once in the live scene to confirm the `Close` button and amount controls now stay inside the centered popup.
  - The left-block five-stat text has only been nudged mildly within the stable layout; if the user wants a stronger shift, it should be done as a tiny offset-only pass, not a structural move.
- Next:
  - Reopen `E:\山锟斤拷志锟斤拷锟斤拷末\scenes\china_terrain_30km.tscn`, open the troop popup once, and verify the popup buttons now sit inside the modal near the bottom rather than at the top-left corner.
## 2026-03-23 22:20 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix the real `ChinaTerrain30km` expedition panel so confirm/cancel return to the bottom, the stray top-left expedition residue is suppressed, and the five-stat summary shifts slightly right without another structural layout change.
- Done:
  - Updated `E:\山锟斤拷志锟斤拷锟斤拷末\scripts\presentation\strategy_ui_layer.gd` so `_show_expedition_content(...)` explicitly hides hover/tip/floating-title remnants before rebuilding the expedition panel.
  - Updated `_layout_expedition_panel_contents()` to explicitly place `CommandHint`, confirm, and cancel at the bottom center for expedition, and raised their `z_index` so they are not visually buried under expedition content.
  - Nudged the expedition five-stat summary a little further right inside the existing left team block instead of moving it into the right column.
  - Re-ran `res://tmp/_tmp_verify_expedition_parse.gd` and `res://tmp/_tmp_verify_china_scene_load.gd`; both completed without parse/load errors.
- Risks:
  - This remains a headless validation pass; the live expedition panel still needs one in-scene check to confirm the top-left stray control is truly gone visually and the bottom buttons read correctly over the textured panel.
  - `strategy_ui_layer.gd` still contains mixed historical line endings / mojibake in unrelated areas, so future text edits should stay very local.
- Next:
  - Reopen `E:\山锟斤拷志锟斤拷锟斤拷末\scenes\china_terrain_30km.tscn`, open the real Expedition panel once, and verify bottom confirm/cancel are visible and the left-top stray button/panel no longer appears; only if the user still wants more shift should the five-stat label move a few more pixels right.
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
  - Moved 21 high-confidence temporary/test `.glb` files from `assets_imports/rpg_troops` and `assets_imports/mixamo_troops/out` into `E:\山锟斤拷志锟斤拷锟斤拷末\tmp\glb_quarantine_20260324\...`, preserving their relative paths for easy restore.
  - Wrote a restore manifest at `E:\山锟斤拷志锟斤拷锟斤拷末\tmp\glb_quarantine_20260324\manifest_20260324.txt`.
  - Left uncertain non-temp files such as `锟截诧拷/锟斤拷模/锟斤拷锟斤拷/toushiche.glb` and `锟截诧拷/锟斤拷模/锟斤拷锟斤拷锟斤拷位/tiekuangchang.glb` untouched.
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
  - Added the exported source files under `res://锟截诧拷/unity_imports/JapaneseGardenPack_clean/godot/BlackPineTree_B/`.
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
  - Removed the direct `JapaneseTreeSamples` injection attempt and restored `scenes/china_terrain_30km.tscn` from the sibling known-good copy at `E:\山锟斤拷志锟斤拷锟斤拷末 - 锟斤拷锟斤拷\scenes\china_terrain_30km.tscn`.
  - Preserved the converted tree resources (`res://锟截诧拷/unity_imports/JapaneseGardenPack_clean/godot/BlackPineTree_B/*` and `res://scenes/prefabs/vegetation/black_pine_tree_b_lod0.tscn`) for later safer integration.
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
  - Added `E:\灞辨渤蹇楅璧锋眽鏈玕data\config\unique_skills_v1.json` with 12 named unique skills for Wei/Shu/Wu core commanders, including names, descriptions, cooldowns, effect templates, and auto-cast rules.
  - Updated `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\battlefield_controller.gd` to load that table, map deployed/demo commanders to skills, expose names/descriptions through the RTS panel path, and enforce per-unit unique-skill cooldowns.
  - Replaced the old unique-skill placeholder activation path with template-driven runtime effects using existing morale/status/burn/cooldown systems, and upgraded auto-cast to consult per-skill rules instead of one generic trigger.
  - Updated `E:\灞辨渤蹇楅璧锋眽鏈玕docs\codex\TASK_BOARD.md` so the active in-progress item reflects the unique-skill landing pass.
- Risks:
  - This environment did not provide a runnable Godot executable, so validation was limited to static/script-level inspection; the new runtime path still needs one real headless/editor load test.
  - `order_cost` is data-ready in the config, but the current battlefield runtime still does not have a true shared military-order resource pool/UI, so unique skills currently enforce cooldown only, not battlefield order-point deduction.
  - Effect templates intentionally reuse existing status/morale/burn systems for a safe first pass, so some buffs are approximations rather than fully bespoke per-skill mechanics.
- Next:
  - Open the project in Godot, load `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\battle_demo.tscn` or the real `ChinaTerrain30km` battle path, click several named commanders, and verify button availability / cooldown / auto-cast / effect readability before deciding whether to add a real battlefield military-order pool next.
## 2026-03-24 11:18 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Stop the city-management/aides panel regression where regroup controls leaked into aides and the aides page lost its own layout.
- Done:
  - Patched `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\strategy_ui_layer.gd` so `_set_regroup_controls_visible(false)` now also hides regroup dynamic frames, title labels, and `RegroupUnitCardsScroll`, preventing regroup remnants from leaking into `aides`.
  - Patched aide-mode visibility so aide-only controls are explicitly hidden/shown by mode, and fixed the previous broken state where picker details were forced hidden.
  - Implemented a minimal dedicated `_layout_aides_panel_contents()` so `鍋氬畼` overview and picker now have their own stable positions again, with confirm/cancel remaining at the bottom.
  - Re-ran `res://tmp/_tmp_verify_expedition_parse.gd` and `res://tmp/_tmp_verify_china_scene_load.gd`; both completed without parse/load errors.
- Risks:
  - This is a surgical stop-the-bleed layout recovery, not a full redesign of the aides/office system; live visual spacing in the real `ChinaTerrain30km` scene still needs one manual in-scene check.
  - `strategy_ui_layer.gd` still has mixed historical mojibake/line-ending history, so future edits should stay equally local.
- Next:
  - Open the real city-management panel in `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\china_terrain_30km.tscn`, verify `鍋氬畼` no longer shows regroup content and buttons stay at the bottom; then adjust only any remaining pixel-level spacing if needed.
## 2026-03-24 11:43 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Recover the Godot editor from the startup stall at "loading plugin window layout".
- Done:
  - Inspected the project editor cache and found `E:\灞辨渤蹇楅璧锋眽鏈玕.godot\editor\editor_layout.cfg` had a corrupted first line, matching the startup stall during plugin/window layout load.
  - Backed up the affected project editor cache files into `E:\灞辨渤蹇楅璧锋眽鏈玕.godot\editor\_codex_backup_20260324_layout_reset`.
  - Rewrote `E:\灞辨渤蹇楅璧锋眽鏈玕.godot\editor\editor_layout.cfg` to a clean minimal default layout.
  - Rewrote `E:\灞辨渤蹇楅璧锋眽鏈玕.godot\editor\project_metadata.cfg` to a clean minimal recent-file state.
  - Cleared `E:\灞辨渤蹇楅璧锋眽鏈玕.godot\editor\script_editor_cache.cfg`.
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
  - Patched `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\strategy_ui_layer.gd` so `generic / aides / regroup / move / hide_command_panel` now explicitly call `_set_expedition_controls_visible(false)`.
  - Patched `_show_expedition_content(...)` to explicitly disable aides/regroup/move controls first, then enable expedition controls, making panel switching symmetrical.
  - Re-ran `res://tmp/_tmp_verify_expedition_parse.gd` and `res://tmp/_tmp_verify_china_scene_load.gd`; both completed without parse/load errors.
- Risks:
  - This fixes the obvious expedition-root leakage; there may still be pixel-level layout overlap inside the individual panels that needs one live visual pass.
- Next:
  - Reopen city management and verify `鍋氬畼 / 鏁寸紪 / 璋冨姩` no longer show expedition widgets at all; only if any specific leftover block remains should we patch that one node path next.
## 2026-03-24 11:59 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix the missing `xiangyun.png` cloud-corner icon used by the UI ornaments.
- Done:
  - Confirmed the real asset exists at `res://绱犳潗/icon/xiangyun.png`.
  - Patched `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\strategy_ui_layer.gd` constant `UI_CLOUD_ICON_PATH` to use the correct non-mojibake path.
  - Re-ran `res://tmp/_tmp_verify_china_scene_load.gd`; the scene loaded successfully.
- Risks:
  - Other historical mojibake resource constants may still exist elsewhere in the codebase, but this specific 绁ヤ簯 icon error path is now corrected.
- Next:
  - Reopen the UI panels once and confirm the cloud-corner ornament renders again without the previous `xiangyun.png` missing-resource error.
## 2026-03-24 12:07 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Rework the aides overview to match the requested two-row office layout.
- Done:
  - Updated `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\strategy_ui_layer.gd` aide overview layout so the `taishou`/Governor slot is placed alone on the first row.
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
  - Confirmed E:\灞辨渤蹇楅璧锋眽鏈玕scenes\china_terrain_30km.tscn had fallen back to the old grass-02 + ock Terrain3D texture block.
  - Restored the live scene to a 4-layer packed terrain stack using valid es://绱犳潗/textures/... paths: grass=ocky_terrain_02, soil=coast_sand_rocks_02, rock=gravelly_sand, snow=snow_02.
  - Restored the newer anti-tiling Terrain3D material tuning on the live scene (lend_sharpness, macro variation, projection) instead of leaving the older sharp 2-layer settings.
  - Saved a safety copy at E:\灞辨渤蹇楅璧锋眽鏈玕scenes\china_terrain_30km.tscn.codex_backup_20260324_restore_textures before editing.
  - Verified the restored live scene loads successfully with E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\灞辨渤蹇楅璧锋眽鏈?--quit --scene res://scenes/china_terrain_30km.tscn.
- Risks:
  - This restores the terrain texture asset/material block only; the painted splat distribution on the terrain is whatever the current live data already contains, so visual layer coverage may still need in-editor adjustment.
  - The scene still has historical encoding/mojibake history in some lines, so future edits should stay local and avoid broad rewrites.
- Next:
  - Open E:\灞辨渤蹇楅璧锋眽鏈玕scenes\china_terrain_30km.tscn in the editor and confirm the four terrain layers are visible again; if any layer still looks wrong, tune the live paint distribution instead of swapping the asset block again.

## 2026-03-24 13:00 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix Guan Yu / Zhang Fei unique skills still reporting has no valid target even when the unit is already fighting a manually selected enemy.
- Done:
  - Patched E:\灞辨渤蹇楅璧锋眽鏈玕scripts\battlefield_controller.gd unique-skill target selection so melee state now treats the current locked target as valid even when center-point distance/facing is transiently unfavorable.
  - Added a close-contact enemy fallback for unique skills, so frontal/cone skills can still resolve onto the nearest engaged enemy when the cone query temporarily returns empty.
  - Applied that fallback specifically to rontal_cleave_pressure and cone_roar_disrupt, covering Guan Yu and Zhang Fei.
  - Verified both es://scenes/battle_demo.tscn and es://scenes/china_terrain_30km.tscn headless-load successfully with the user-provided Godot executable.
- Risks:
  - This fixes target acquisition robustness, not balance; if the user later wants stricter directional gameplay again, we should add a softer manual-cast rule instead of removing the fallback entirely.
  - Headless scene load passed, but the final judgment still needs one in-battle manual cast check on Guan Yu / Zhang Fei against a locked melee target.
- Next:
  - In E:\灞辨渤蹇楅璧锋眽鏈玕scenes\battle_demo.tscn, order Guan Yu or Zhang Fei to attack a nearby enemy, wait until they enter melee, then cast the unique skill and confirm it now fires on the engaged target instead of showing has no valid target.

## 2026-03-24 13:07 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Revert the extra Guan Yu / Zhang Fei melee fallback after the user identified the real cause as those commanders temporarily using siege equipment.
- Done:
  - Removed the extra close-contact unique-skill fallback helpers from E:\灞辨渤蹇楅璧锋眽鏈玕scripts\battlefield_controller.gd.
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
  - Enlarged the Governor/`taishou` card in `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\strategy_ui_layer.gd` to a larger near-square first-row card.
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
  - Updated E:\灞辨渤蹇楅璧锋眽鏈玕data\config\battle_rules.json so demo_team_a_unit_roles now starts with infantry, infantry instead of two siege entries, making the first two Team A demo commanders (Guan Yu and Zhang Fei) spawn as normal infantry.
  - Updated E:\灞辨渤蹇楅璧锋眽鏈玕scripts\battlefield_controller.gd default 	eam_a_unit_roles fallback to PackedStringArray(["infantry", "infantry"]) so non-rule fallback behavior stays consistent.
  - Verified es://scenes/battle_demo.tscn still headless-loads with the user-provided Godot executable.
- Risks:
  - Only the first two Team A demo slots were normalized; if the user later binds Guan Yu / Zhang Fei through custom deployment data elsewhere, those external deployment roles can still override this demo default.
- Next:
  - Open E:\灞辨渤蹇楅璧锋眽鏈玕scenes\battle_demo.tscn, select Guan Yu and Zhang Fei, and confirm their panel role now shows infantry and their unique skills cast normally in melee.
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
  - Confirmed the regression root cause in `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\strategy_ui_layer.gd` was `func _layout_move_panel_contents() -> void:` returning immediately, leaving the whole move page without any positioned content.
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
  - Updated E:\灞辨渤蹇楅璧锋眽鏈玕data\config\unique_skills_v1.json for guanyu_weizhenhuaxia: ange 12.0 -> 14.0 and cone_angle_deg 70.0 -> 82.0.
  - Verified es://scenes/battle_demo.tscn still headless-loads with the user-provided Godot executable.
- Risks:
  - This is a tuning-side fix, not a structural targeting rewrite; if the user later enlarges formation spacing again, similar center-distance issues can reappear on other short frontal skills.
- Next:
  - Reopen E:\灞辨渤蹇楅璧锋眽鏈玕scenes\battle_demo.tscn and test Guan Yu's unique skill in melee; if it still occasionally fails, the next step should be a targeted melee-center-distance exception only for manual frontal unique skills.

## 2026-03-24 14:55 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix the unit-defeat battle report so the HUD speaks from the defeating commander instead of the defeated side, and include the immediate reward summary in the same playback.
- Done:
  - Patched E:\灞辨渤蹇楅璧锋眽鏈玕scripts\battlefield_controller.gd on_unit_defeated(...) so when a valid killer exists, the defeat HUD now uses the killer commander as speaker and no longer starts with the defeated unit's self-report line.
  - Patched E:\灞辨渤蹇楅璧锋眽鏈玕scripts\battlefield_controller.gd _grant_team_battle_reward(...) to support reward accumulation without forcing a separate HUD report.
  - Unit-defeat reports now combine the kill announcement and the immediate reward delta (war_merit, gongji, 	ech_points, grain, wood, iron) into one HUD line.
  - Preserved the old fallback only for edge cases where no valid killer exists; in that case the defeated-side collapse report still appears.
  - Verified es://scenes/battle_demo.tscn headless-loads successfully with the user-provided Godot executable.
- Risks:
  - This pass fixes unit-defeat playback only; site/facility events still use their existing separate reward-report flow unless changed later for consistency.
  - Reward text is still presentation-only battle summary data; it is not yet wired into any larger campaign economy settlement layer beyond the existing team battle stats bucket.
- Next:
  - Open E:\灞辨渤蹇楅璧锋眽鏈玕scenes\battle_demo.tscn, defeat one enemy unit, and confirm the HUD portrait/name now belongs to the killer commander and the same line includes the immediate reward summary.
## 2026-03-24 14:33 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Restore the real ChinaTerrain30km move panel so dispatch / recall / resource transport / troop transport no longer open as empty pages.
- Done:
  - Confirmed the second root cause in `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\china_terrain_scene.gd` was that `_build_site_panel_data(...)` never built move panel data and always returned empty `targets`, `source_officers`, `source_resources`, and `source_stats` for move actions.
  - Added runtime move-panel builders in `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\china_terrain_scene.gd` so move pages now receive same-faction target sites, source officers, source resources, source troop stats, and target rosters.
  - Connected `city_move_requested` in the ChinaTerrain runtime path and added a minimal runtime move executor so confirm now transfers officers/resources/troops between same-faction source/target sites instead of doing nothing.
  - Added focused helper functions for unique move IDs, troop-composition transfer, personnel cleanup after officer transfer, and city aide-score rebuild after move.
  - Re-ran `res://tmp/_tmp_verify_expedition_parse.gd`; it passed after the move patch.
- Risks:
  - The broader `res://scenes/china_terrain_30km.tscn` headless load is currently blocked by pre-existing terrain texture ext_resource mojibake paths (`res://缂備浇浜慨闈涱焽?...`), which is unrelated to this move patch but still prevents a clean scene-load validation.
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
  - Backed up the broken current scene to `E:\灞辨渤蹇楅璧锋眽鏈玕tmp\_tmp_corrupt_china_terrain_30km_before_restore_20260324.tscn`.
  - Restored `scenes/china_terrain_30km.tscn` from `E:\灞辨渤蹇楅璧锋眽鏈?- 鍓湰\scenes\china_terrain_30km.tscn` and then re-added the `JapaneseTreeClusterLuoyang` ext_resource + root child instance.
  - Verified the restored main scene text now contains the tree cluster instance and intact `major_city_names` entries again.
- Risks:
  - Because the main scene was restored from the sibling backup copy, any scene-only edits made after that backup point may have been rolled back again; runtime/script-side fixes in other files remain intact.
  - Headless verification in Godot returned clean exit, but the temporary tree-cluster instantiate check still produced engine leak spam on exit, so final confidence should come from one visual editor/runtime check near Luoyang.
- Next:
  - Open `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\china_terrain_30km.tscn`, look near Luoyang, and visually confirm the 3-tree cluster sits on the terrain with acceptable size/shading/perf before expanding to more trees.
## 2026-03-24 14:42 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Clean up the move target list so it no longer shows invalid field units or duplicate city entries.
- Done:
  - Fixed `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\china_terrain_scene.gd` move target collection to stop listing runtime `field_unit` and `convoy` entries as valid move destinations.
  - Added target-id deduplication in the same move-target collector so duplicate city entries such as two `璁告槍 (city)` rows no longer appear.
  - Re-ran `res://tmp/_tmp_verify_expedition_parse.gd`; it still passes after the target-list cleanup.
- Risks:
  - This pass only narrows the target list; if the user wants more nuanced target rules later (for example exactly which site types are allowed), refine that whitelist directly in the same collector instead of touching the move UI again.
- Next:
  - Reopen the move panel and confirm the target list now keeps cities/sites only, with no `field_unit` rows and no duplicate `璁告槍` entry.
## 2026-03-24 15:37 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Simplify famous commander skill release toward a more San14-like auto-trigger feel so skills do not depend on fussy manual timing, especially for Zhang Liao.
- Done:
  - Patched E:\灞辨渤蹇楅璧锋眽鏈玕scripts\battlefield_controller.gd so unique-skill auto mode now defaults to enabled (amous_auto_default_enabled = true).
  - Added a lightweight unique-skill auto proc roll with a short retry cooldown instead of only using the older strict all-or-nothing auto check.
  - Relaxed auto-cast conditions for frontal and dash-type unique skills to treat active melee/engagement as sufficient pressure, instead of requiring overly strict spatial checks every time.
  - Expanded unique-skill target acquisition for dash/charge templates so locked targets can still be chosen from a more forgiving pre-contact distance.
  - Updated E:\灞辨渤蹇楅璧锋眽鏈玕data\config\unique_skills_v1.json so Zhang Liao's zhangliao_weizhenxiaoyaojin gets uto_proc_chance = 0.62.
  - Verified es://scenes/battle_demo.tscn still headless-loads with the user-provided Godot executable.
- Risks:
  - This is intentionally a feel/UX simplification; the result is less manually precise and a bit more gamey, which matches the user's request but is less deterministic than the earlier strict logic.
  - Manual cast still exists, but the new default auto mode may make it feel less necessary; if later the user wants exact manual control for some commanders, per-skill default-auto flags should be added.
- Next:
  - Open E:\灞辨渤蹇楅璧锋眽鏈玕scenes\battle_demo.tscn, let Zhang Liao enter combat, and confirm his unique skill now tends to auto-fire naturally during engagement without needing awkward manual timing.

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
  - Changed E:\灞辨渤蹇楅璧锋眽鏈玕scripts\battlefield_controller.gd amous_auto_default_enabled back to alse, so unique skills are manual by default again.
  - Kept the simplified auto proc framework, but changed auto decision rules so AOE-style unique skills (rea_control_zone, rea_fire_burst, chain_fire_spread, rontal_cleave_pressure, cone_roar_disrupt) now trigger from simple local combat pressure (close_enemy_count >= 2 or melee state) instead of checking detailed cone/area coverage.
  - Simplified manual cast execution for frontal/cone famous skills so if the cone query returns empty, they now fall back to all nearby enemies in radius rather than failing on exact facing geometry.
  - Verified es://scenes/battle_demo.tscn still headless-loads with the user-provided Godot executable.
- Risks:
  - This intentionally trades precision for feel; frontal/cone skills are now less spatially strict and may occasionally hit nearby enemies that are not perfectly in front, which matches the user's request for simpler triggers.
- Next:
  - Open E:\灞辨渤蹇楅璧锋眽鏈玕scenes\battle_demo.tscn, keep unique skills on manual by default, then test both manual casts and auto toggles to confirm they no longer fail due to cone/area micromanagement.
## 2026-03-24 16:47 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Verify whether the editor freeze was still caused by the old `xiangyun` missing-resource bug.
- Done:
  - Rechecked the live `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\strategy_ui_layer.gd` cloud-icon constant and rewrote the `UI_CLOUD_ICON_PATH` line in-place to the intended `res://绱犳潗/icon/xiangyun.png` entry.
  - Verified with a focused headless Godot script that both `res://scripts/presentation/strategy_ui_layer.gd` and `res://绱犳潗/icon/xiangyun.png` load successfully.
  - Verified `res://scenes/china_terrain_30km.tscn` also loads successfully in a focused headless check, so the screenshoted old `xiangyun` error is likely stale editor output / reload noise rather than the current blocking cause.
- Risks:
  - The editor can still appear as Windows `鏈搷搴擿 while reparsing the very large `china_terrain_30km.tscn` scene and replaying many warnings; this is now more of an editor responsiveness/perf issue than a confirmed missing-resource crash.
- Next:
  - If the editor keeps hanging after a full restart with the cleared/fixed `xiangyun` path, profile the editor-side stall itself (scene open time, warning flood sources, and heavy plugin/inspector redraw paths) instead of chasing the old cloud-icon error again.
## 2026-03-24 16:45 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Align battle reporting with the user's clarified intent: bottom commander dialogue should summarize player-side major wins/losses clearly, while the left report should continue covering broad player-related battle events.
- Done:
  - Reworked E:\灞辨渤蹇楅璧锋眽鏈玕scripts\battlefield_controller.gd on_unit_defeated(...) so player-side victories now produce bottom HUD dialogue from the defeating player commander with the immediate reward delta in the same line.
  - Reworked E:\灞辨渤蹇楅璧锋眽鏈玕scripts\battlefield_controller.gd on_unit_defeated(...) loss branch so when the enemy defeats a player-side unit, the bottom HUD now reports from the player/defender side instead of feeling like enemy celebration playback.
  - Reworked E:\灞辨渤蹇楅璧锋眽鏈玕scripts\battlefield_controller.gd on_site_captured(...) so player-side captures now combine the capture announcement and reward delta into the same bottom HUD line, while enemy captures of player sites now produce a clean player-loss warning line.
  - Reworked E:\灞辨渤蹇楅璧锋眽鏈玕scripts\battlefield_controller.gd _report_demo_facility_destroyed(...) so player destruction of enemy facilities now combines battle gains into the same bottom HUD line, while enemy destruction of player facilities reports a defensive loss warning from the player side.
  - Verified es://scenes/battle_demo.tscn still headless-loads with the user-provided Godot executable.
- Risks:
  - This pass focuses on current unit defeat / site capture / facility destruction battle events; explicit officer-capture (淇樿檹) playback still needs a dedicated event source if that mechanic is added or already exists elsewhere.
  - Left-side scrolling report still inherits the broader commander report system; this change makes major HUD events more player-facing, but does not yet create a fully separate player-only event channel.
- Next:
  - Open E:\灞辨渤蹇楅璧锋眽鏈玕scenes\battle_demo.tscn, trigger one player victory and one player loss case, and confirm the bottom HUD now reads like player-side battlefield reporting with reward summaries on wins and clear loss warnings on defeats.

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
  - Adjusted the expedition troop popup layout in `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\strategy_ui_layer.gd` so the troop panel now opens below the commander/team block instead of starting near the top and overlapping the main/vice commander frames.
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
  - Updated `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\prefabs\vegetation\black_pine_tree_b_batch_light.tscn` so the lightweight green tree now uses a built-in `scale = Vector3(5, 5, 5)` baseline and a slightly longer visibility range for large-map use.
  - Updated `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\prefabs\vegetation\sakura_tree_a_batch_light.tscn` so the sakura lightweight tree also uses the same built-in `scale = Vector3(5, 5, 5)` baseline.
  - Added `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\japanese_tree_batch_sample_spawner.gd` as a simple two-species sample spawner that keeps species count low while varying only rotation and effective visual size.
  - Added `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\tree_batch_large_sample.tscn` to host that spawner, and refreshed `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\tree_batch_light_test.tscn` so its instances now represent the intended 4.2x鈥?.0x visual range around the new 5x baseline.
  - Verified `res://scenes/tree_batch_light_test.tscn` and `res://scenes/tree_batch_large_sample.tscn` both load successfully in headless Godot.
- Risks:
  - `tree_batch_large_sample.tscn` is a tool-spawned sample scene, so its children are created at runtime/editor-time rather than being serialized into the scene file; that is fine for preview but not yet the final Terrain3D instancer wiring.
  - The wrappers are still based on the current imported source meshes, so this is a rendering-cost reduction strategy, not a true geometry-decimation pass.
- Next:
  - Open `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\tree_batch_light_test.tscn` and/or `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\tree_batch_large_sample.tscn`, judge whether the 5x baseline plus 4.2x鈥?.0x variation feels right, then wire these two wrappers into the Terrain3D instancer for the Luoyang batch planting pass.

## 2026-03-24 18:53 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Recover the ChinaTerrain30km terrain textures again after the live scene was re-saved back to the old 2-layer Terrain3D asset block.
- Done:
  - Confirmed E:\灞辨渤蹇楅璧锋眽鏈玕scenes\china_terrain_30km.tscn had once again reverted to the old grass-02 + ock two-layer Terrain3D resource setup.
  - Restored the live scene back to the 4-layer packed terrain setup using valid es://绱犳潗/textures/... paths for grass (ocky_terrain_02), soil (coast_sand_rocks_02), rock (gravelly_sand), and snow (snow_02).
  - Restored the anti-tiling Terrain3D material settings (lend_sharpness, macro variation, projection) on the live scene.
  - Saved a safety copy at E:\灞辨渤蹇楅璧锋眽鏈玕scenes\china_terrain_30km.tscn.codex_backup_20260324_restore_textures_2 before rewriting the terrain block.
  - Verified es://scenes/china_terrain_30km.tscn headless-loads successfully with the user-provided Godot executable.
- Risks:
  - The most likely regression source is the Godot editor tab holding an older in-memory version of the scene; if the user saves that stale tab again, it can overwrite the restored file back to the old 2-layer terrain block.
- Next:
  - In Godot, close the currently open china_terrain_30km.tscn tab **without saving**, then reopen the scene fresh from disk before making any further edits to avoid re-overwriting the restored terrain resources.

## 2026-03-24 18:54 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Diagnose whether `E:\灞辨渤蹇楅璧锋眽鏈玚 is an empty Git repository or a broken one, and identify first-commit risks.
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
  - Patched E:\山河志风起汉末\scripts\presentation\strategy_ui_layer.gd inside _layout_expedition_panel_contents() so visible extra expedition team blocks now always receive their position and size before child-slot layout runs.
  - The root cause was dead code: extra_block.position and extra_block.size were indented after if not should_show: continue, so the extra blocks never got laid out and stayed piled on the upper layer.
  - Verified the focused headless parse still succeeds with E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\山河志风起汉末 -s res://tmp/_tmp_verify_expedition_parse.gd.
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
  - Rewrote `E:\灞辨渤蹇楅璧锋眽鏈玕.gitignore` to ignore Godot/editor cache, Codex probe files, root recovery logs, local backup copies, terrain backup directories, and obvious temporary script artifacts.
  - Confirmed the newly ignored set now covers `.godot/`, `tmp/`, `_tmp_plugins/`, root `.codex_*` / `.tmp_*` probes, `_codex_*.ps1`, root restore logs, `scenes/*backup*.tscn`, `scripts/**/*.bak*`, `data/config/*backup*.json`, and `data/terrain/china_30km/terrain_data_backup_*`.
  - Rechecked the remaining unignored tree and verified the major first-commit payload is now concentrated in actual project content such as `addons/`, `scripts/`, `scenes/`, `docs/`, `data/config/`, `data/terrain/china_30km/terrain_data`, `assets_imports/`, and `绱犳潗/`.
  - Confirmed `git-lfs` is available, but did not yet assign LFS tracking rules because some large asset folders still need an intentional keep-vs-ignore decision.
- Risks:
  - `绱犳潗/` (~4.7 GB) and `assets_imports/` (~123 MB) remain unignored and may be necessary for runtime, but a full first commit including them will be very large unless LFS policy is decided first.
  - Root terrain resources (`terrain3d*.res`, `china_dem.png`) and large terrain runtime data may be legitimate project assets, so they should be staged deliberately rather than via a blind `git add .`.
- Next:
  - Decide between a lightweight code/data first commit versus a full playable asset commit with Git LFS, then stage only the chosen allowlist.
## 2026-03-24 19:22 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Tighten the ChinaTerrain30km expedition team-row layout so the three officer slots and the right-side five-stat summary stop colliding and fill the team block cleanly.
- Done:
  - Adjusted E:\山河志风起汉末\scripts\presentation\strategy_ui_layer.gd in _layout_expedition_panel_contents() to use a 4-column layout inside each expedition team block: 3 officer slot columns + 1 stats column.
  - Replaced the old uneven slots_w / summary_w split with 	eam_column_gap + 	eam_column_w, so the main row and extra team rows now share the same aligned widths.
  - Moved the main stats label and extra-team summary label to the new column start, which pushes the five-stat column slightly right and removes the overlap with the third officer slot.
  - Verified the focused headless parse still succeeds with E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\山河志风起汉末 -s res://tmp/_tmp_verify_expedition_parse.gd.
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
  - Kept large or noisy trees out of the first commit, including `assets_imports/`, `绱犳潗/`, `data/terrain/` runtime/backup payloads, `.godot/`, `tmp/`, `_tmp_plugins/`, and known backup/log outputs.
  - Tightened `.gitignore` again so `tools/_tmp_*`, performance CSV/translation outputs, `*.TMP`, and tilde-prefixed temp files do not slip into the lightweight baseline.
- Risks:
  - The repository is now ready for history, but this first commit is intentionally not a full asset-complete playable checkout because raw import/source asset trees remain outside version control.
  - Some staged plugin binaries inside `addons/` are large but appear to be real runtime/plugin dependencies rather than disposable temp output.
- Next:
  - After this baseline commit, decide which runtime asset folders must be tracked next and whether to put them under Git LFS before any large asset commit.

## 2026-03-24 17:22 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Expand the already-mounted Luoyang tree cluster into a small grove using only the two new large-map lightweight tree species, while keeping the main scene reference stable.
- Done:
  - Replaced `scenes/prefabs/vegetation/japanese_tree_cluster_luoyang.tscn` to use only `black_pine_tree_b_batch_light.tscn` and `sakura_tree_a_batch_light.tscn` instead of the older preview wrappers.
  - Expanded the Luoyang cluster from 3 trees to 18 trees total: 12 green pines + 6 sakuras.
  - Kept the species count low and varied only local position, Y rotation, and relative scale so the visible size range stays around the intended old-scale 4.2x鈥?.0x band on top of the new 5x baseline wrappers.
  - Left `scenes/china_terrain_30km.tscn` untouched this pass because it already instances the Luoyang cluster scene; the change is therefore localized and safe to reload.
  - Re-ran a focused load check for the Luoyang cluster and main terrain scene; no blocking parse/load failure appeared.
- Risks:
  - Godot may still show a stale cached instance if `china_terrain_30km.tscn` stayed open throughout edits; a scene tab reload is likely required before the new grove becomes visible.
  - This is still scene-instance based planting, not Terrain3D region-file instancing yet; it is a safe first grove, not the final highest-scale foliage solution.
- Next:
  - Reload `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\china_terrain_30km.tscn`, inspect Luoyang again, and if the grove density/size feels right, convert this two-species setup into Terrain3D instancer data for wider regional planting.

## 2026-03-24 20:06 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Repair the live `china_terrain_30km.tscn` terrain texture bindings after the map appeared white again in the editor.
- Done:
  - Rechecked `E:\山河志风起汉末\scenes\china_terrain_30km.tscn` and confirmed the grass/rock ext_resources had drifted back to the old `nature/textures` set instead of the intended packed terrain textures.
  - Rebound the scene's 4 Terrain3D texture slots to the packed texture set under `E:\山河志风起汉末\素材\textures\`: grass=`rocky_terrain_02_packed_*`, soil=`coast_sand_rocks_02_packed_*`, rock=`gravelly_sand_packed_*`, snow=`snow_02_packed_*`.
  - Re-verified the scene file now points all four texture asset slots at the expected packed resources.
  - Ran a headless load check and confirmed the terrain scene still opens; current blocking load noise is from unrelated `strategy_ui_layer.gd` parse errors, not missing terrain texture files.
- Risks:
  - Godot can still overwrite the repaired scene if an old in-memory `china_terrain_30km.tscn` tab is saved after the fix; the scene should be closed without saving and reopened fresh from disk.
  - There is still an unrelated script parse failure in `E:\山河志风起汉末\scripts\presentation\strategy_ui_layer.gd` referenced by `china_terrain_scene.gd`; this is not the white-texture root cause but may confuse editor refresh behavior.
- Next:
  - Reopen `E:\山河志风起汉末\scenes\china_terrain_30km.tscn` fresh in Godot 3D view, verify the terrain is no longer white, and only then continue tuning tiling/color parameters.

## 2026-03-24 17:37 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Make the Luoyang two-species grove visually readable against the green terrain by improving canopy contrast/fullness and increasing local density.
- Done:
  - Updated `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\tree_batch_light_tuner.gd` to support explicit `leaf_tint` and `bark_tint`, so large-map tree wrappers can push species-specific color contrast without touching the source imported materials.
  - Tuned `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\prefabs\vegetation\black_pine_tree_b_batch_light.tscn` toward darker cooler foliage, lower alpha scissor, and double-sided leaves so the green trees read fuller and stand apart from the grass.
  - Tuned `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\prefabs\vegetation\sakura_tree_a_batch_light.tscn` toward brighter pink foliage, lower alpha scissor, and double-sided leaves so sakura stands out more clearly.
  - Rebuilt `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\prefabs\vegetation\japanese_tree_cluster_luoyang.tscn` into a denser grove with 30 trees total (18 green + 12 sakura) arranged in tighter local clumps around Luoyang.
  - Verified the grove scene text is intact; the follow-up main scene headless load was blocked by an unrelated existing parse error in `res://scripts/presentation/strategy_ui_layer.gd`, not by the tree cluster files touched this pass.
- Risks:
  - Double-sided leaves and lower alpha scissor improve readability but cost more than the prior ultra-light setting; this is still acceptable for the current small Luoyang grove, but wide-map blanket planting should move to Terrain3D instancing next.
  - If `china_terrain_30km.tscn` remains open in the editor, instance caching may still hide the refreshed grove until the scene tab is reloaded.
- Next:
  - Reload `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\china_terrain_30km.tscn` and judge whether the darker pine + brighter sakura + denser clumps are now visible enough; if still not, the next step should be reducing local grass around the grove area or adding a small contrasting ground patch under tree groups.
## 2026-03-24 20:26 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Align the expedition officer picker with the user's San11-style UI expectation: remove the Tactic field, split five officer stats into separate columns/lines, enlarge the secondary menu, and start reusing a shared officer basic-overview presentation.
- Done:
  - Updated E:\山河志风起汉末\scripts\presentation\strategy_ui_layer.gd expedition picker table from Officer/Battle/Tactic/Stats/Special to Officer/Battle/Lead/Might/Int/Pol/Charm/Special and widened the picker panel so the secondary menu is closer to the primary panel footprint.
  - Updated expedition slot cards to show Battle + Special only; removed the unwanted Tactic label from those slot summaries.
  - Added reusable officer overview helpers (_officer_stat_value, _officer_stat_lines, _append_officer_basic_overview_lines) and switched the expedition picker detail plus aide-tooltip/detail builders to use that shared basic-overview formatting.
  - Recorded the new UI rule in E:\山河志风起汉末\docs\codex\PROJECT_MEMORY.md: officer overview should be reusable, five stats should split into separate fields when space allows, and Battle should be preferred over Tactic in default officer-overview UIs.
  - Verified the focused headless parse still succeeds with E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\山河志风起汉末 -s res://tmp/_tmp_verify_expedition_parse.gd.
- Risks:
  - The expedition picker now has more columns, so on narrower resolutions the table may still need one more width pass or a slightly smaller font size; that would be a layout-only follow-up.
  - The repository still contains other officer-related UIs that do not yet consume the new shared overview helper; this turn only converted the expedition picker/detail path and aide detail/tooltip path.
- Next:
  - Reopen the expedition officer picker in runtime and confirm the table reads cleanly as Officer/Battle/Lead/Might/Int/Pol/Charm/Special; if any column still feels cramped, do one more tiny width/font pass without changing the structure again.

## 2026-03-24 20:14 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Make the ChinaTerrain30km grass look less grid-like and less obviously repeated without adding runtime-heavy detail.
- Done:
  - Updated `E:\山河志风起汉末\scenes\china_terrain_30km.tscn` Terrain3D anti-tiling noise from a cellular-style pattern to a smoother continuous pattern by changing the `FastNoiseLite` setup.
  - Softened Terrain3D layer blending and widened the macro variation scales so the grass no longer breaks into obvious small square-like patches.
  - Increased the apparent grass texture size by lowering the grass `uv_scale`, and reduced grass `normal_depth` slightly so the surface reads broader and less busy from strategy-camera height.
- Risks:
  - This tuning affects the shared Terrain3D material, so soil/rock transitions may also look a bit softer and broader than before.
  - If a stale in-memory scene tab is saved again, Godot can still overwrite the tuned scene file; inspect from a freshly reopened `china_terrain_30km.tscn` tab.
- Next:
  - Reopen the terrain scene in 3D view and judge two things only: whether the grass patching now reads as broader/natural, and whether transitions became too soft; if needed, do one more small pass instead of another big retune.

## 2026-03-24 17:46 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Make the green tree species read much larger than before by doubling the current large-map wrapper scale again.
- Done:
  - Updated `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\prefabs\vegetation\black_pine_tree_b_batch_light.tscn` so the built-in green tree base scale is now `Vector3(10, 10, 10)` instead of `Vector3(5, 5, 5)`.
  - Increased the green tree wrapper visibility range and cull margin slightly to better fit the larger canopy footprint.
  - Verified the Luoyang tree cluster still instantiates successfully after the green-tree size increase.
- Risks:
  - This doubles the green trees only; if they now feel too dominant relative to sakura, the next pass should rebalance the cluster layout or slightly enlarge sakura too.
- Next:
  - Reload `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\china_terrain_30km.tscn` and judge whether the enlarged green canopy is now readable enough against the grass.

## 2026-03-24 20:21 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Soften the visible terrain layer cut lines after the grass anti-tiling pass reduced repetition but transitions still looked too hard.
- Done:
  - Updated `E:\山河志风起汉末\scenes\china_terrain_30km.tscn` Terrain3D material to reduce layer transition sharpness further by lowering `blend_sharpness` to `0.12`.
  - Added explicit Terrain3D auto-blend parameters in the same scene: `auto_slope = 0.62`, `auto_height_reduction = 0.02`, to make slope/height-driven layer changes read less like a hard cut.
- Risks:
  - If transitions become too wide in flatter mid-altitude areas, the next correction should be a very small `blend_sharpness` increase rather than another broad texture retune.
  - A stale open scene tab in Godot can still overwrite the tuned scene if saved without reloading from disk first.
- Next:
  - Reopen the terrain scene and inspect the same hilltop edge; if the line is still too crisp, the next step should be brushing/softening the control map in those specific regions rather than globally changing texture scales again.

## 2026-03-24 17:55 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Soften the current grove color grading slightly while adding only a modest number of new trees.
- Done:
  - Relaxed the green tree tint in `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\prefabs\vegetation\black_pine_tree_b_batch_light.tscn` so the canopy is still visible but less aggressively dark/saturated.
  - Relaxed the sakura tint in `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\prefabs\vegetation\sakura_tree_a_batch_light.tscn` so the pink reads softer and less punchy.
  - Added a modest outer ring to `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\prefabs\vegetation\japanese_tree_cluster_luoyang.tscn`: 6 extra green trees and 4 extra sakura.
  - Verified the Luoyang grove scene still instantiates successfully after the softening + density pass.
- Risks:
  - This pass keeps the current scene-instance approach; if the user later wants a much larger forest footprint, the next scaling step should move to Terrain3D instancing rather than continuing to hand-grow this one cluster scene.
- Next:
  - Reload `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\china_terrain_30km.tscn` and judge whether the colors now feel softer while the grove is slightly fuller.

## 2026-03-24 20:34 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Stabilize `strategy_ui_layer.gd` after editor-side script resolution noise and remove corrupted resource path constants.
- Done:
  - Rechecked `E:\山河志风起汉末\scripts\presentation\strategy_ui_layer.gd` and confirmed the top-level cloud icon / aide portrait constants had mojibake-corrupted paths.
  - Replaced them with valid project paths: `res://素材/icon/xiangyun.png` and `res://素材/立绘`.
  - Re-ran a headless load for `E:\山河志风起汉末\scenes\china_terrain_30km.tscn`; the scene now loads cleanly without the earlier `StrategyUILayer` resolution noise.
- Risks:
  - Godot editor can still show stale parse/highlight state in already-open script tabs until they are reopened.
  - `strategy_ui_layer.gd` still carries many in-flight expedition UI edits from earlier work; future merges there should stay surgical.
- Next:
  - Reopen the script tab / scene tab fresh in Godot, confirm the red script error markers are gone, then continue with the next gameplay/UI task instead of more terrain churn.

## 2026-03-24 21:24 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Bind the new Gitee remote, push the lightweight baseline if possible, and prepare a first-pass Git LFS plan for the large asset trees.
- Done:
  - Bound `origin` to `https://gitee.com/sunny-ling/shanhezhi-fengqihanmo.git`.
  - Verified the current push blocker is HTTPS authentication, not local Git setup: with terminal prompts disabled, `git push -u origin master` fails with `could not read Username for 'https://gitee.com': terminal prompts disabled`.
  - Added an initial LFS tracking plan in `E:\灞辨渤蹇楅璧锋眽鏈玕.gitattributes` and committed it as `3ca3427 chore: add initial lfs tracking rules`.
  - Scoped the first-pass LFS rules to the currently untracked large asset trees most clearly tied to runtime use: `assets_imports/` heavy binary media, `data/terrain/china_30km` height/terrain region payloads, and selected runtime-facing subtrees under `绱犳潗/`.
- Risks:
  - Push is still blocked until Gitee credentials are available in this environment (HTTPS username + password/token, or a working SSH key setup).
  - The LFS rules are intentionally conservative-first; before tracking the entire raw asset universe, verify which `绱犳潗/` subtrees are truly required for distributable runtime history.
- Next:
  - Authenticate this machine to Gitee, then run `git push -u origin master` and only after that start staging selected large asset folders under the new LFS rules.

## 2026-03-24 21:32 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Finish the expedition officer picker so the player can click up to three officers continuously and let the system auto-assign main/vice commanders by office rank first, then lead.
- Done:
  - Updated `E:\山河志风起汉末\scripts\presentation\strategy_ui_layer.gd` expedition setup flow to ingest `panel_data["assignments"]`, rebuild the officer->office map, restore saved `selected_officer_ids`, and auto-sort them into commander order before padding the three visible slots.
  - Added focused expedition-selection helpers in the same file for clean selected-id extraction, office-priority sorting, role-prefix display, and shared team-apply logic.
  - Implemented the missing expedition picker table/detail/button handlers so the picker now supports continuous add/remove selection up to three officers, shows `[Main] / [Vice I] / [Vice II]` prefixes in the table, updates button states to `Add Officer` / `Remove` / `Team Full`, and clears the whole team via `Clear Team`.
  - Kept the existing user-facing hint aligned with the agreed rule: main and vice commanders are assigned automatically.
  - Verified the focused headless parse succeeds with `E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\山河志风起汉末 -s res://tmp/_tmp_verify_expedition_parse.gd`.
- Risks:
  - The team is now auto-ranked globally, so after the team is full, replacing one officer requires removing one first and then adding the new one; this is intentional for now, but if the user wants slot-click replacement behavior later it should be added explicitly rather than mixed back into the current picker.
  - `strategy_ui_layer.gd` still carries many earlier local changes outside this turn, so any further edits in this file should stay surgical and revalidated immediately.
- Next:
  - Open the expedition picker in runtime and check one thing only: continuous three-officer selection should auto-place the highest-office/highest-lead officer into the main slot and label the table rows with the resulting `[Main] / [Vice I] / [Vice II]` order.

## 2026-03-24 21:40 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Remove redundant expedition picker UI noise so the officer list carries the screen instead of repeating main/vice labels and officer stats below the table.
- Done:
  - Updated `E:\山河志风起汉末\scripts\presentation\strategy_ui_layer.gd` so the expedition picker table no longer prepends `[Main] / [Vice I] / [Vice II]` to officer names; commander ordering remains automatic but is now implicit through the top slot cards only.
  - Simplified the picker title back to `Select Officers` instead of repeating the selected-count reminder.
  - Hid the lower picker detail text block and reclaimed that space for the table, so more officers are visible at once and the UI stops re-reading the selected officer's Battle/stat lines under the list.
  - Re-verified the focused parse path with `E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\山河志风起汉末 -s res://tmp/_tmp_verify_expedition_parse.gd`.
- Risks:
  - The picker now relies entirely on the slot cards above for visible main/vice feedback; if the user later wants a subtler in-list cue, add only a very light row tint or icon rather than text prefixes.
- Next:
  - Reopen the expedition picker and judge whether the expanded officer list now feels clean enough; if not, the next tiny pass should be row-height/font-density only, not new info blocks.

## 2026-03-24 22:02 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Land the first large-asset batch to the active Gitee remote, using a Gitee-compatible strategy after discovering free-tier LFS upload limits.
- Done:
  - Identified that Gitee rejected LFS uploads for this repository tier (`LFS only supported repository in paid or trial enterprise`), so the earlier LFS-first terrain attempt was intentionally converted to a normal Git fallback.
  - Reverted `.gitattributes` back to text normalization only, removing active LFS tracking rules from the live branch so future pushes to this Gitee repo are not blocked.
  - Added the first runtime terrain batch as ordinary Git content and pushed it successfully in commit `9b75ea0 feat: add china_30km terrain runtime data`.
  - Scoped that batch to the live `data/terrain/china_30km/terrain_data` region files, the primary `china_height_30km.r16`, and the main political mask assets/metadata used by the live terrain scene and related runtime/tooling scripts.
- Risks:
  - This Gitee remote cannot currently be used as an LFS-backed asset remote without upgrading the repo tier or moving large-asset history to a different host that supports standard Git LFS.
  - Other large trees such as `assets_imports/` and `绱犳潗/` remain outside version control; adding them to plain Git should be done carefully in smaller runtime-focused batches.
- Next:
  - If continuing on Gitee, stage the next runtime-critical asset batch in plain Git (recommended: only the exact `assets_imports/rpg_troops` subset referenced by `battle_rules.json`), or switch future large-asset storage to a Git LFS-capable remote before adding `绱犳潗/`.

## 2026-03-24 22:00 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Match the user's preferred expedition picker flow: single-click rows should directly add/remove officers, selected rows should be visibly marked, and the bottom confirm button should only return to the first expedition screen.
- Done:
  - Updated `E:\山河志风起汉末\scripts\presentation\strategy_ui_layer.gd` to connect expedition picker table `gui_input` and added `_toggle_expedition_picker_officer(...)`, so left-clicking a row now directly toggles that officer in/out of the current three-officer team without using the bottom button to add/remove.
  - Updated the picker table rebuild to tint currently selected officers with a different row background, keeping the chosen team visible directly in the list.
  - Simplified picker bottom actions so `Confirm` now just closes the picker and returns to the first expedition screen; the old clear/remove action remains hidden.
  - Kept the lower repeated detail block hidden so the table remains the main focus.
  - Re-ran the focused headless check; `strategy_ui_layer.gd` itself still loads cleanly, while the verifier script also reports an unrelated pre-existing parse problem in `res://scripts/battlefield_controller.gd` preload from `china_terrain_scene.gd`.
- Risks:
  - The new row-toggle flow now depends on `Tree.gui_input`; if Godot changes row-click ordering in-editor, the first thing to recheck is whether row selection and row toggle are both still firing once per click.
  - The broader verifier currently hits an unrelated `battlefield_controller.gd` preload parse issue outside this turn, so use the expedition picker runtime itself as the practical check for this UI pass.
- Next:
  - Open expedition picker in runtime and verify the exact intended loop: click up to three rows to select them, click a selected row again to remove it, then press `Confirm` to return to the first expedition screen with the chosen team preserved.

## 2026-03-24 21:02 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Adjust player-facing battle loss reports so friendly unit destruction / line collapse / site loss are reported by relay rather than by the defeated side speaking in third person, while still allowing a short first-person line from the defeated friendly unit.
- Done:
  - Updated `E:\山河志风起汉末\scripts\battlefield_controller.gd` loss-report routing for player-side unit defeat branches.
  - Added helpers to separate relay HUD lines from unit self-lines: player loss events now push the left report entry, then show bottom HUD speaker `传令`, then queue one short first-person line from the defeated friendly unit.
  - Converted player-side bad-news wording from commander-style `主公，我军...` voice to relay-style `急报，...` for unit defeat, site loss, and facility destruction loss branches.
  - Kept player-side victory branches on commander voice, so only bad-news routing changed.
  - Re-validated `battlefield_controller.gd` parses and `E:\山河志风起汉末\scenes\china_terrain_30km.tscn` headless-loads again.
- Risks:
  - I did not find a currently wired standalone officer-capture event entry point in the live battlefield runtime, so this pass covers friendly unit defeat / site loss / facility loss first; officer capture should reuse the same relay + first-person pattern once that event hook is exposed.
  - The first-person line currently uses fallback text through `pick_commander_dialogue_line("defeat_unit", ...)`; if you later want named generals to have bespoke defeat/capture quotes, add that event key in `E:\山河志风起汉末\scripts\unit_controller.gd` dialogue tables.
- Next:
  - Play one battle where a friendly unit is destroyed and confirm the sequence reads as: left report `急报...`, bottom HUD speaker `传令`, then a short first-person defeated-unit line; after that, wire the same pattern into officer-capture once the event source is identified.

## 2026-03-25 00:13 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Land the next smallest runtime-critical asset batch by tracking only the `assets_imports/rpg_troops` files directly referenced by battle runtime config/scenes.
- Done:
  - Confirmed the live runtime references only five troop assets under `assets_imports/rpg_troops`: `troop_spear`, `troop_archer`, `troop_infantry`, `troop_cavalry`, and `troop_infantry_shield`.
  - Added only those five GLBs plus their adjacent texture and `.import` files; intentionally left the many `_tmp_*` experiment files in the same folder untracked.
  - Tightened `E:\灞辨渤蹇楅璧锋眽鏈玕.gitignore` with `assets_imports/**/_tmp_*` so imported scratch outputs stop polluting future Git status scans.
  - Committed and pushed the batch successfully as `bd8700f feat: add rpg troop runtime assets`.
- Risks:
  - `assets_imports/horse_rider_demo` and `assets_imports/mixamo_troops` remain outside version control; if gameplay/runtime starts depending on them directly, they should be added in similarly explicit subsets rather than by staging the whole tree.
  - `battle_rules.json` and `horse_rider_demo.tscn` now have their immediate `rpg_troops` dependencies covered, but other preview/demo scenes may still reference files elsewhere in `assets_imports/`.
- Next:
  - If continuing resource onboarding, do the next batch either from `assets_imports/mixamo_troops/out` (runtime-ready character assets) or from a tightly scoped `绱犳潗/` runtime subset such as `绱犳潗/icon`, `绱犳潗/ui`, and directly referenced VFX textures.

## 2026-03-25 00:07 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Make the expedition officer picker behave like a true secondary menu inside the same primary command panel: same footprint as the一级菜单, and reuse the primary confirm/cancel buttons instead of adding a separate bottom button row.
- Done:
  - Updated `E:\山河志风起汉末\scripts\presentation\strategy_ui_layer.gd` so the expedition picker overlay now expands to the full command-panel footprint and the picker content area is laid out against the same panel bounds instead of using the previous smaller floating subpanel.
  - Added picker pending-selection state so row clicks now only change the temporary secondary-menu selection; `Confirm` on the primary bottom button applies that pending three-officer selection and returns to the first expedition screen, while `Back` discards it and returns without applying.
  - Reused the primary bottom command buttons while the expedition picker is open by switching the main decide text to `Confirm`, keeping `Back` on cancel, and hiding the picker's own confirm/clear/close button row.
  - Kept the direct row-toggle and selected-row background highlighting from the previous pass.
  - Re-verified with `E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\山河志风起汉末 -s res://tmp/_tmp_verify_expedition_parse.gd`.
- Risks:
  - This turn only converted the expedition officer picker to primary-panel sizing/button reuse; if the user wants the troop subpanel and other secondary panels to follow the exact same pattern, they should be migrated one by one with the same temporary-state approach rather than by broad UI rewrites.
- Next:
  - Open the expedition officer picker and verify the exact loop: row clicks only mark temporary selection, `Back` returns without changing the first screen, and the primary `Confirm` button applies the three-officer selection then returns to the expedition main screen.

## 2026-03-25 00:24 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Remove redundant relay HUD lines when the defeated friendly unit already speaks in first person.
- Done:
  - Updated `E:\山河志风起汉末\scripts\battlefield_controller.gd` so the player-side unit-defeat branches no longer enqueue `传令` when a first-person defeated-unit line is already queued.
  - Kept the left battle report entry intact; only the bottom HUD sequence changed.
  - Revalidated `battlefield_controller.gd` parse and `E:\山河志风起汉末\scenes\china_terrain_30km.tscn` headless load.
- Risks:
  - This pass only changes friendly unit defeat; standalone officer-capture still needs its own event hook, but should follow the same rule: self line first, no extra relay if self line exists.
- Next:
  - Trigger one friendly unit defeat in battle and confirm the bottom HUD now shows only the unit's first-person line instead of `传令 + 自述`.

## 2026-03-25 00:24 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Add the next smallest direct-runtime `绱犳潗/` subset: only icon/UI/VFX assets that are explicitly referenced by live scripts/scenes/config.
- Done:
  - Confirmed direct runtime references currently require `绱犳潗/icon/xiangyun.png`, `绱犳潗/ui/bg.tres`, `绱犳潗/ui/闈㈡澘鑳屾櫙.jpg`, `绱犳潗/ui/dreamina_7609992228173352201_1771839419291-removebg-preview (1).png`, and the specific `绱犳潗/brackeys_vfx_bundle` particle/predrawn/flipbook textures preloaded by `battlefield_controller.gd`, `unit_controller.gd`, `china_terrain_scene.gd`, and `mountain_mist_layer.gd`.
  - Staged only that minimal direct-reference subset plus the matching `.import` companions; left the rest of `绱犳潗/ui` and `绱犳潗/brackeys_vfx_bundle` untracked.
  - Tightened `.gitignore` with `assets_imports/**/_tmp_*`, which cleans up imported asset scratch outputs discovered during the previous `rpg_troops` pass.
- Risks:
  - `绱犳潗/` still contains a large amount of untracked source/runtime content outside this minimal subset; future additions should continue following exact-reference batches rather than folder-wide adds.
  - `bg.tres` currently references the UI background image using the repository's existing mixed-encoding path convention; the asset is now versioned, but the broader encoding/history issue remains a repository-wide risk.
- Next:
  - Commit and push this minimal `绱犳潗/` runtime subset, then consider whether the next batch should be `assets_imports/mixamo_troops/out` or the remaining directly referenced `绱犳潗/寤烘ā` runtime models.

## 2026-03-25 09:26 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Add a Poly Haven sky to the large terrain scene by choosing and wiring an appropriate downloadable sky resource.
- Done:
  - Chose `Meadow` from Poly Haven as a softer daytime sky suitable for the current terrain and vegetation style.
  - Downloaded the official Poly Haven `2K HDR` source to `E:\灞辨渤蹇楅璧锋眽鏈玕绱犳潗\hdri\polyhaven_meadow_2k.hdr`.
  - Built an embedded Godot sky resource `E:\灞辨渤蹇楅璧锋眽鏈玕绱犳潗\hdri\polyhaven_meadow_sky.tres` from that HDR so the project can load it reliably without depending on importer support for raw `.hdr` files.
  - Updated `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\china_terrain_30km.tscn` to reference the new `Sky` resource and switch `WorldEnvironment` from flat background color mode to sky mode.
- Risks:
  - The generated `polyhaven_meadow_sky.tres` embeds the HDR image data, so it is relatively large on disk; this is reliable, but if the user later wants a leaner asset pipeline, we should replace it with a normal imported texture-based sky once the project鈥檚 importer path is stabilized.
  - A tonemapped JPG variant was intentionally not used because the direct image download path was different than the guessed URL; the installed sky uses the real HDR data instead of a fake/404 JPG.
- Next:
  - Reload `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\china_terrain_30km.tscn` and judge the new sky; if it feels too bright/dim, the next step is a quick `ambient_light_energy` / exposure tweak only.

## 2026-03-25 00:15 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix the expedition secondary-menu primary buttons not responding after the full-panel resize pass.
- Done:
  - Reduced the expedition picker overlay/panel hit area to the command-panel content region above the bottom hint/button row in `E:\山河志风起汉末\scripts\presentation\strategy_ui_layer.gd`, so the reused primary `Back` / `Confirm` buttons are no longer covered by the secondary overlay.
  - Re-ran `E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\山河志风起汉末 -s res://tmp/_tmp_verify_expedition_parse.gd` successfully.
- Risks:
  - This fix is currently applied to the expedition officer picker path only; other secondary overlays still need the same treatment if they are migrated to reuse the primary buttons.
- Next:
  - Reopen the expedition officer picker and verify the primary bottom buttons now respond: `Back` should discard pending picker edits, and `Confirm` should apply them then return to the expedition main screen.

## 2026-03-25 09:32 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Continue the player-facing battle report pass by making player loss HUD output more reliable without expanding scope beyond the active battlefield report task.
- Done:
  - Updated E:\灞辨渤蹇楅璧锋眽鏈玕scripts\battlefield_controller.gd so _enqueue_first_person_loss_hud(...) now returns whether a self-line was actually queued.
  - For player-side unit-loss branches in on_unit_defeated(...), kept the preferred rule of self line first, no redundant relay, but added a fallback so the bottom HUD now automatically uses 浼犱护 with the same loss summary if the defeated unit has no usable self-line.
  - Re-checked the current codebase for a standalone officer-capture / prisoner runtime hook and did not find an active event entry beyond the existing unit defeat / site capture / facility destroyed flows.
  - Revalidated with focused headless checks: es://tmp/_tmp_parse_battlefield.gd loads attlefield_controller.gd, and es://tmp/_verify_battle_and_china_load.gd exits cleanly.
- Risks:
  - Officer capture still has no clearly wired live event source, so this pass does not add fabricated capture reporting; once that hook exists it should follow the same player-facing rule: prefer self/subject line, fallback to relay only when needed.
  - This turn intentionally stayed inside battle-report logic; other unrelated modified files in the working tree remain untouched and still need separate review before any broad commit.
- Next:
  - In runtime, trigger one friendly unit defeat that has a normal self-line and one case that lacks one, then confirm the bottom HUD behavior is now self line when available / relay fallback when not; after that, continue tracing whether officer capture should be surfaced from another battle or officer-state path.
## 2026-03-25 09:36 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Replace the previously installed Poly Haven forest panorama with a clean sky-only setup after the user confirmed they only want sky and the HDRI felt too heavy.
- Done:
  - Confirmed the earlier `Meadow` HDRI was a full 360 forest panorama, which is why trees/buildings appeared in the sky and why it felt visually/performance-heavy for this map.
  - Generated `E:\灞辨渤蹇楅璧锋眽鏈玕绱犳潗\hdri\clean_procedural_sky.tres` using Godot's built-in `PhysicalSkyMaterial`, giving a clean sky without any photographed ground objects.
  - Updated `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\china_terrain_30km.tscn` to replace the previous `polyhaven_meadow_sky.tres` reference with `clean_procedural_sky.tres` and reduced ambient sky energy slightly.
  - Verified the clean procedural sky resource loads successfully in headless Godot.
- Risks:
  - The old downloaded `polyhaven_meadow_2k.hdr` and generated `polyhaven_meadow_sky.tres` are still on disk for now, but they are no longer referenced by the main scene.
- Next:
  - Reload `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\china_terrain_30km.tscn`; if the clean sky feels too plain, do only a light color/brightness tweak on `clean_procedural_sky.tres` rather than returning to a heavy HDRI panorama.

## 2026-03-25 00:25 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Bring the expedition troop-allocation secondary menu in line with the new secondary-menu rule: same primary-panel footprint, reuse primary confirm/back buttons, and keep edits temporary until primary confirm.
- Done:
  - Added temporary troop-allocation state in `E:\山河志风起汉末\scripts\presentation\strategy_ui_layer.gd` so the expedition troop secondary menu now edits a pending allocation instead of mutating the live expedition payload immediately.
  - Updated the expedition troop secondary menu to reuse the primary bottom `Back` / `Confirm` buttons: `Back` discards pending troop edits, `Confirm` applies them and returns to the expedition main screen.
  - Converted the troop secondary overlay/panel to the same full primary-panel footprint above the shared button row, and hid the old internal `Set Amount / Clear Type / Close` button row.
  - Wired the troop amount spin box to update the pending troop allocation directly while the secondary menu is open, with a sync guard to avoid refresh recursion.
  - Re-verified with `E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\山河志风起汉末 -s res://tmp/_tmp_verify_expedition_parse.gd`.
- Risks:
  - This pass only covered the expedition troop secondary menu because it is the only remaining real overlay in this file; if other future secondary menus are added, they should follow the same temporary-state + shared-bottom-buttons pattern instead of creating another local button row.
- Next:
  - Open expedition troop allocation in runtime and verify the exact loop: adjust troop amounts with the spin box, `Back` should discard those pending edits, and primary `Confirm` should apply them then return to the expedition main screen.

## 2026-03-25 09:43 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Change the default main-scene editor camera to a more level/horizon-facing angle so the user can see the sky without manually tilting down/up as much.
- Done:
  - Updated the `EditorCamera` transform in `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\china_terrain_30km.tscn` from a steep downward pitch to a much shallower near-level angle while keeping the same camera position.
  - Verified the main terrain scene still resolves as a loadable resource after the camera transform change.
- Risks:
  - This only changes the default saved editor camera orientation in the scene file; if the editor preserves a previously cached per-tab viewport pose, the user may still need to reopen the scene tab once to see the new default angle.
- Next:
  - Reopen `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\china_terrain_30km.tscn` and confirm the default view now shows more horizon/sky.

## 2026-03-25 09:49 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Make the LOD2 view genuinely near-horizontal without changing its zoom distance.
- Done:
  - Confirmed the effective ChinaTerrain30km camera rules come from `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\china_terrain_scene.gd`, not the generic presentation JSON.
  - Updated the hardcoded `camera_rules` block so `lod_tilt_deg[1]` (LOD2) is now `14.0` degrees, while its height and distance ratio remain unchanged.
  - Left other LOD levels untouched.
- Risks:
  - If the editor/game is currently on another LOD level, the user may need to wheel/zoom to LOD2 again before this flatter tilt becomes apparent.
- Next:
  - Reopen `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\china_terrain_30km.tscn`, switch to LOD2 if needed, and confirm the horizon is now much flatter without the camera being pulled closer.
## 2026-03-25 16:05 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Continue the player-facing battle report pass by wiring an officer-capture hook and a minimal captive runtime tied to battle personality ufu.
- Done:
  - Added a minimal officer-capture runtime to E:\山河志风起汉末\scripts\battlefield_controller.gd: ufu capture chance/duration loading from es://data/config/battle_personalities_blue_v1.json, runtime capture marks, captured-officer event storage, and getters for later UI/state integration.
  - Added on_unit_control_applied(...) and hooked capture-mark registration to successful control application, then resolved actual capture in on_unit_defeated(...) so ufu can produce live capture outcomes without per-frame scans.
  - Added player-facing capture reporting: when the player captures an enemy officer, the commander report now announces the capture and grants a dedicated reward package; when a player officer is captured, the left report says 急报... and the bottom HUD prefers the captured unit's own first-person line with no redundant relay.
  - Wired E:\山河志风起汉末\scripts\unit_controller.gd so both personality-applied control and COUNTERED status notify the battlefield controller via on_unit_control_applied(...).
  - Revalidated with headless Godot: es://tmp/_tmp_verify_capture_parse.gd loads both attlefield_controller.gd and unit_controller.gd, and es://scenes/china_terrain_30km.tscn loads successfully.
- Risks:
  - This is still a battle-runtime captive system only; there is no persistence into world_state.json, no post-battle prisoner management UI, and no release/ransom/execution flow yet.
  - Direct control applications that bypass the hooked paths still fall back to the defeat-time controlled status + bufu capture check, which is practical but not yet a fully unified status-source pipeline.
- Next:
  - In runtime, verify one player capture and one player officer being captured; if the feel is right, the next step is to persist captured officers into a strategy-layer prisoner list and surface simple post-battle handling.

## 2026-03-25 10:00 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Continue the player-facing battle report pass by tracing whether officer capture already exists in the live battle runtime and, if so, complete the missing player-facing dialogue layer instead of inventing a separate system.
- Done:
  - Confirmed the current working tree already contains an officer-capture pipeline in E:\灞辨渤蹇楅璧锋眽鏈玕scripts\battlefield_controller.gd: on_unit_control_applied(...) records temporary capture marks, _try_resolve_officer_capture(...) rolls capture on enemy defeat, and _report_officer_captured(...) pushes player-facing reports including a defeat_capture self-line for the captured side.
  - Updated E:\灞辨渤蹇楅璧锋眽鏈玕scripts\unit_controller.gd dialogue tables to actually support that live defeat_capture event key, so captured units can now use generic / role / personality / famous-commander lines instead of always falling back to a single hardcoded sentence.
  - Also expanded defeat_unit coverage in the same dialogue tables so player loss self-lines now vary more naturally across roles and famous commanders.
  - Revalidated with focused headless checks: es://tmp/_tmp_parse_unit_controller.gd loads unit_controller.gd, and es://tmp/_verify_battle_and_china_load.gd exits cleanly.
- Risks:
  - I still have not runtime-played the officer-capture path end to end, so while parsing and scene loading are clean, the next real check should confirm the actual in-battle sequence and capture frequency feel correct.
  - The officer-capture logic appears to be present only in the current working tree; if you later compare against remote/base history, treat it as uncommitted local gameplay work until explicitly committed.
- Next:
  - In battle, trigger one ufu/control-assisted capture case and verify the sequence is now: left report announces the capture, bottom HUD uses the captive unit's defeat_capture line when available, and only falls back to 浼犱护 when no self-line exists; after that, decide whether to surface captured-officer results back into the strategy layer roster/state.## 2026-03-25 14:24 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Tighten the expedition prepare screen without broad UI churn: keep only one officer-pick entry button on the main panel, and make troop amount adjustment feel more direct with a slider plus numeric input.
- Done:
  - Updated `E:\山河志风起汉末\scripts\presentation\strategy_ui_layer.gd` so the expedition main screen now exposes a single shared `Select Officers` button while the three commander slots remain as read-only result cards showing role + officer + battle/special summary.
  - Kept the existing secondary officer picker flow intact: the shared button opens the same pending-selection picker, primary `Back` still discards, and primary `Confirm` still applies the final three-officer selection.
  - Added `ExpeditionTroopAmountSlider` to the troop secondary panel and synced it with the existing amount `SpinBox`, so troop quantity can now be dragged or typed while both controls clamp to the currently available amount for the selected troop type.
  - Adjusted the troop secondary layout to place the slider and numeric amount control on the same bottom row while preserving the same primary-panel footprint and shared bottom confirm/cancel buttons.
  - Revalidated with `E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\山河志风起汉末 -s res://tmp/_tmp_verify_expedition_parse.gd`.
- Risks:
  - This pass does not introduce a separate commander troop-cap rule because no existing runtime/config field for that cap was found in the current repository search; the slider max currently follows the selected troop type's available amount only.
  - `scripts/presentation/strategy_ui_layer.gd` already has a large pre-existing working-tree diff outside this focused UI pass, so any later cleanup should review changes surgically before broader commits.
- Next:
  - In runtime, open `出征 -> 选将` and confirm only one main-screen pick button remains; then open `兵种/数量` and verify the slider + numeric field both update the same pending amount cleanly and still commit only on the primary `Confirm` button.

## 2026-03-25 10:14 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Turn the Luoyang decorative tree cluster in `ChinaTerrain30km` into a readable `I鉂わ笍U` confession layout using only the existing optimized green pine and sakura wrappers.
- Done:
  - Rebuilt `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\prefabs\vegetation\japanese_tree_cluster_luoyang.tscn` as a clean `I鉂わ笍U` composition while keeping the same root node name, same snap script, and the same child-scene hookup from the main terrain scene.
  - Used green pines as the outer contour and sakura trees as the inner body, with per-instance scale trims so the letters remain readable even though the shared green wrapper itself is intentionally large.
  - Added mild rotation/scale variation only within those two existing tree models, so the layout still stays performance-friendly and does not introduce new vegetation assets.
  - Revalidated with `E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\灞辨渤蹇楅璧锋眽鏈?-s res://tmp/_tmp_verify_tree_i_love_u.gd`, which reported `cluster_child_count=58`; only the usual headless dummy-renderer leak spam appeared on exit.
- Risks:
  - The `I鉂わ笍U` readability still depends on the current map camera height and the root instance position near Luoyang; if the user wants it even bolder from farther zoom levels, the next pass should enlarge spacing first rather than adding many more trees.
  - Terrain snapping keeps trunks grounded, but on steeper local slopes some letters may look slightly vertically uneven because each tree samples terrain height independently.
- Next:
  - Open `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\china_terrain_30km.tscn`, view the Luoyang area from the accepted flat LOD2 angle, and adjust spacing or enlarge the heart if the silhouette still feels too subtle.

## 2026-03-25 10:26 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Rework `TreeTest` into a much denser `I鉂わ笍U` confession preview and provide a straight top-down camera so the shape is readable immediately on open.
- Done:
  - Rebuilt `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\tree_test.tscn` to use the existing optimized batch-light pine and sakura wrappers instead of the old sparse preview setup.
  - Generated a dense symbol layout with green pines as outline and sakura trees as fill/body, resulting in 162 total trees for a much fuller silhouette.
  - Added `TopDownCamera` as the current camera, placed directly above the layout with orthographic projection so the full `I鉂わ笍U` composition is visible at a glance.
  - Kept the scene lightweight: one flat ground plane, one sun, one environment, and no extra runtime logic beyond scene content.
  - Revalidated with `E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\灞辨渤蹇楅璧锋眽鏈?-s res://tmp/_tmp_verify_tree_test_scene.gd`, which reported `tree_test_children=162`, `camera_current=true`, and `camera_projection=1`.
- Risks:
  - Because the test scene is now intentionally dense, if you later want even more volume the safer next step is to reduce grid spacing slightly rather than scaling every tree up again.
  - The headless verify still prints the usual dummy-renderer/Jolt leak noise on exit; that did not block scene parsing or camera verification.
- Next:
  - Open `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\tree_test.tscn` in Godot and judge whether the heart should be wider or whether the whole wordmark should be compressed a bit more for an even stronger aerial read.
## 2026-03-25 14:39 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Refine the expedition row layout so officer-pick entry sits on the far left in the same row as the officer cards, and ensure newly added extra team rows also show the same pick-entry button style.
- Done:
  - Updated `E:\山河志风起汉末\scripts\presentation\strategy_ui_layer.gd` so the main expedition `Select Officers` button is now a narrow vertical button column on the far left of the team row instead of sitting above the three commander cards.
  - Recomputed the team-row width split so the left-side select button, three officer cards, and right-side summary can stay on one row with narrower card widths.
  - Added matching left-side `Select\nOfficers` buttons to each extra team block created by the `+` button, and hid the old per-slot extra-row pick buttons so the added rows now visually match the main row.
  - Kept the extra-row button wiring minimal and consistent with the current single expedition officer-selection flow, avoiding broader multi-team payload changes in this pass.
  - Revalidated with `E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\山河志风起汉末 -s res://tmp/_tmp_verify_expedition_parse.gd`.
- Risks:
  - Extra added team rows still do not have an independent expedition team data model in the current runtime; this pass only fixes the row-entry button layout/visibility and does not introduce separate officer payload storage for each extra row.
- Next:
  - In runtime, add one extra team row and confirm both the main row and the new row show the left-side select button, with the row staying on one line and no overlap between the officer cards and the summary panel.

## 2026-03-25 10:36 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix the visible `I/U` order in `TreeTest`, raise the preview viewpoint so the whole wordmark fits, and add lightweight environment polish without hurting performance.
- Done:
  - Rebuilt `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\tree_test.tscn` so the visible order now reads `I鉂わ笍U` from the editor-facing preview angle the user is using.
  - Kept the same dense 162-tree composition, still using only the optimized pine/sakura batch-light wrappers.
  - Raised and widened `TopDownCamera` to `y=560` with orthographic `size=360`, so the full wordmark fits much more comfortably in one shot.
  - Upgraded the test scene environment from a flat color to the existing clean procedural sky resource and slightly softened the sun / ground presentation for a cleaner romantic preview at almost no runtime cost.
  - Revalidated with `E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\灞辨渤蹇楅璧锋眽鏈?-s res://tmp/_tmp_verify_tree_test_scene.gd`, which reported `tree_test_children=162`, `camera_current=true`, `camera_projection=1`, `camera_size=360.0`, `camera_y=560.0`, and `bg_mode=2`.
- Risks:
  - The visible reading order was corrected for the current editor-facing view; if you rotate around to the opposite side, any wordmark in world space will naturally read reversed from that opposite direction.
  - The scene still relies on a single ground color, so if you want a more authored romantic presentation the next cheap win is adding a subtle petal-colored floor accent rather than increasing tree count again.
- Next:
  - Open `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\tree_test.tscn` and confirm the current editor-facing view now reads correctly; if accepted, the next pass can add a low-cost petal ring or a soft pink ground accent around the heart.
## 2026-03-25 14:47 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Make the expedition row labels visually tighter after the left-side pick-button pass, without changing structure again.
- Done:
  - Shortened the main expedition row officer-pick button text in `E:\山河志风起汉末\scripts\presentation\strategy_ui_layer.gd` from `Select Officers` to `Pick Officers` and reduced that button font size to keep the narrow left column cleaner.
  - Shortened row role labels from `Main Commander / Vice Commander I / Vice Commander II` to `Main Cmdr / Vice I / Vice II` and reduced those label font sizes slightly.
  - Applied the same compact `Pick\nOfficers` text and smaller font sizing to the extra-team left-side pick buttons so added rows match the first row.
  - Re-ran `E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\山河志风起汉末 -s res://tmp/_tmp_verify_expedition_parse.gd`; one transient file-read failure occurred immediately after save, and the next run completed cleanly.
- Risks:
  - This pass only tightens English labels/font sizing; if the user still wants the row denser, the next safe step is shrinking the summary column width or nudging officer-card widths again rather than adding more text compression.
- Next:
  - Reopen the expedition panel and confirm the shortened English labels no longer crowd the left row; if they still feel large, do one more narrow spacing pass on the same row only.

## 2026-03-25 10:48 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Make `TreeTest` freely viewable, improve the confession presentation with a soft heart halo and water-backed staging, and rebalance the pine/sakura colors so the composition reads more gently.
- Done:
  - Added `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\tree_test_free_camera.gd` and switched `TreeTest` to a scripted perspective `PreviewCamera`, so the scene is no longer locked to a single orthographic top-down view.
  - Rebuilt `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\tree_test.tscn` with the corrected visible order `I鉂わ笍U`, an added sakura halo around the heart, a broad water backdrop, and a lighter central stage plane for better contrast.
  - Tuned the lightweight vegetation wrappers: brightened the green pine foliage slightly and toned down the sakura brightness/harshness by lowering tint intensity and increasing roughness/scissor tuning.
  - Revalidated with `E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\灞辨渤蹇楅璧锋眽鏈?-s res://tmp/_tmp_verify_tree_test_scene.gd`, which reported `tree_test_children=181`, `camera_current=true`, `camera_script=true`, `camera_fov=42.0`, and `water_mesh_ok=true`.
- Risks:
  - The water is intentionally a very cheap stylized plane, not a full animated shader water system; that keeps performance stable but means the look stays calm rather than flashy.
  - The free camera is built for this presentation scene only; if later reused elsewhere, its default distance/speeds may need retuning for different map sizes.
- Next:
  - Open `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\tree_test.tscn`, try the free camera controls, and decide whether you want the next pass to push farther toward 鈥渞omantic photo spot鈥?(petal scatter / lanterns) or 鈥渃lean minimalist confession stage鈥?(less ground, more water).
## 2026-03-25 15:07 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Reorganize the expedition panel right-side information so the five core stats sit with the ship/troop area instead of being squeezed into the officer row, while keeping changes limited to the expedition screen.
- Done:
  - Updated `E:\山河志风起汉末\scripts\presentation\strategy_ui_layer.gd` so the expedition five-core-stat summary now becomes a dedicated right-side `Core` block instead of sharing the left officer-row summary column.
  - Simplified the right-side ship/troop grouping: the ship header now only labels ship selection, troop summary now lists `Soldiers`, `Types`, `Ship`, `Naval Apt`, and `Special` in one compact block, and the troop button label was shortened to `Troops`.
  - Rebalanced the expedition layout split so the left side gives space only to the select button plus three officer cards, while the right side reserves a two-column top area for `Core` stats and ship/troop info.
  - Hid the old extra-team row rich-text summary placeholder blocks so added rows no longer keep the obsolete right-hand stat column inside each row.
  - Revalidated with `E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\山河志风起汉末 -s res://tmp/_tmp_verify_expedition_parse.gd`.
- Risks:
  - This pass is layout/text reorganization only; final visual balance still depends on in-editor/runtime inspection because `strategy_ui_layer.gd` computes many sizes dynamically from the current command-panel dimensions.
- Next:
  - Open the expedition panel in runtime and verify the right side now reads as `Core + Ship/Troops` as one grouped area; if any line still feels crowded, do one more spacing pass on the right top block only.

## 2026-03-25 11:03 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Replace the flat confession-test presentation with a more cinematic beach-and-water setup, remove the extra outer blossom ring, and make the sakura/pine rendering look nicer than the earlier performance-first version.
- Done:
  - Added `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\tree_cinematic_tuner.gd` plus two dedicated cinematic wrappers: `black_pine_tree_b_cinematic.tscn` and `sakura_tree_a_cinematic.tscn`, so `TreeTest` now uses a quality-oriented material pass instead of the earlier batch-light look.
  - Rebuilt `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\tree_test.tscn` to remove the extra outer blossom ring, keep the `I鉂わ笍U` layout, and stage it on a natural sand-island plane surrounded by moving water.
  - Added custom shader-driven materials for `TreeTest`: `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\shaders\tree_test_water.gdshader` for animated wave motion / fresnel highlights and `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\shaders\tree_test_sand_island.gdshader` for an irregular beach island with shoreline darkening.
  - Kept the free-view camera path in place and tuned the default camera farther back so the full confession layout is easier to frame before manual adjustments.
  - Revalidated with `E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\灞辨渤蹇楅璧锋眽鏈?-s res://tmp/_tmp_verify_tree_test_scene.gd`, which reported `tree_test_children=162`, `camera_current=true`, `camera_script=true`, `water_material_ok=true`, and `island_material_ok=true`.
- Risks:
  - This is now intentionally a presentation-first local test scene; if you later want to reuse it inside a much larger runtime map, the new cinematic tree materials and animated water shader should stay scoped to `TreeTest` rather than being copied blindly into the big terrain scene.
  - The look should already be much softer than before, but 鈥滅數褰辨劅鈥?is inherently subjective; the next polish pass would likely be about color grading / sun angle / camera framing rather than tree count.
- Next:
  - Open `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\tree_test.tscn`, judge the beach/water/sakura mood in-editor, and if you want it even more romantic the next step should be a golden-hour lighting pass plus a subtle shoreline reflection boost.

## 2026-03-25 11:19 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Push `TreeTest` farther toward a screenshot-first confession scene: correct the upside-down heart/U read, make the water look more like still photographed sea rather than gameplay water, and pack the tree letters densely enough that they read as solid forms.
- Done:
  - Rebuilt `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\tree_test.tscn` with denser letter patterns, smaller grid spacing, and larger per-tree scales, raising the total to 278 trees so the `I鉂わ笍U` reads much more like filled shapes instead of sparse dots.
  - Corrected the symbol design so the heart and `U` are no longer vertically inverted relative to the intended screenshot read.
  - Replaced the animated water look with a static cinematic water shader in `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\shaders\tree_test_water.gdshader`, keeping ripples / sky-blue tone / reflective glints but removing time-based motion since the user only needs screenshots.
  - Retuned the cinematic pine/sakura wrappers to render denser foliage and softer sakura highlights, reducing visible gaps while keeping a more romantic photo-like look.
  - Tightened the screenshot camera further in `TreeTest` with a narrower `fov=34` and a farther default orbit distance for cleaner framing.
  - Revalidated with `E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\灞辨渤蹇楅璧锋眽鏈?-s res://tmp/_tmp_verify_tree_test_scene.gd`, which reported `tree_test_children=278`, `camera_current=true`, `camera_script=true`, `camera_fov=34.0`, and `water_material_ok=true`.
- Risks:
  - The exact final 鈥渕ovie鈥?feel now depends heavily on your chosen screenshot angle and sun position; the content is much denser and softer, but the last 10% of impact is likely a camera-framing choice rather than more asset changes.
  - Because the water is now static-on-purpose for screenshots, it will look best in stills rather than as a live moving showcase.
- Next:
  - Open `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\tree_test.tscn`, frame the shot with the free camera, and if you want one more polish pass the best next step is a dedicated golden-hour color grade / sun-angle tuning just for the final screenshot.

## 2026-03-25 11:31 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix the still-upside-down heart/U read, replace the sea with a screenshot-friendly transparent Maldives-style lagoon look, and push `TreeTest` into a golden-hour confession presentation.
- Done:
  - Created `E:\灞辨渤蹇楅璧锋眽鏈玕绱犳潗\hdri\sunset_procedural_sky.tres` and switched `TreeTest` to that warmer sunset sky, while lowering the sun angle and warming direct light for a golden-hour mood.
  - Reworked `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\tree_test.tscn` so the heart and `U` use flipped vertical placement relative to the current camera-facing screenshot direction, while keeping the same dense 278-tree composition.
  - Replaced the old opaque water staging with a two-layer lagoon setup: `LagoonFloorMesh` under the surface for clear tropical seabed color and a transparent static water surface above it using a new screenshot-oriented shader.
  - Updated `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\shaders\tree_test_water.gdshader` to a static, non-animated but still reflective / rippled transparent water look, and added `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\shaders\tree_test_lagoon_floor.gdshader` for the bright shallow-to-deep lagoon floor color underneath.
  - Kept the free camera path active and tuned the default framing for a more cinematic golden-hour screenshot setup.
  - Revalidated with `E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\灞辨渤蹇楅璧锋眽鏈?-s res://tmp/_tmp_verify_tree_test_scene.gd`, which reported `tree_test_children=278`, `camera_current=true`, `camera_script=true`, `water_material_ok=true`, and `floor_material_ok=true`.
- Risks:
  - The symbolic orientation is now corrected for the current default screenshot-facing direction; if the camera is rotated around behind the composition, any world-space letters will naturally read differently from that opposite side.
  - The lagoon look is tuned for still screenshots rather than real-time animated showcase water, so the biggest remaining quality gain would come from final camera framing and light placement, not more motion.
- Next:
  - Open `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\tree_test.tscn`, hit `F` to reset, and frame the golden-hour angle you like best; if needed, the next pass should be a final 鈥渉ero shot鈥?camera preset saved directly into the scene.

## 2026-03-25 11:42 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Add a testing-only stable officer-capture toggle on the live battlefield capture pipeline so capture flow can be verified reliably without creating a second system.
- Done:
  - Restored the live officer-capture runtime path in E:\灞辨渤蹇楅璧锋眽鏈玕scripts\battlefield_controller.gd, including control-hit capture marking, defeat-time capture resolution, runtime capture event recording, and capture report/HUD output.
  - Added debug_force_officer_capture_for_testing in E:\灞辨渤蹇楅璧锋眽鏈玕scripts\battlefield_controller.gd; when enabled, capture keeps the normal prerequisite flow but skips the random failure roll once capture conditions are met.
  - Wired battle-rules override support with key demo_force_officer_capture_for_testing.
  - Reconnected E:\灞辨渤蹇楅璧锋眽鏈玕scripts\unit_controller.gd control-status callbacks so control application and countered state notify the battlefield capture pipeline again.
  - Revalidated with focused headless checks: es://tmp/_tmp_parse_capture_pair.gd loads both scripts and es://tmp/_verify_battle_and_china_load.gd exits cleanly.
- Risks:
  - This toggle guarantees capture only after the existing prerequisites are satisfied; it does not bypass the need for a valid control-assisted capture chain, so tests should still use a ufu unit or an existing control-mark path.
  - Strategy-layer post-battle persistence for captured officers is still not wired; this pass is runtime testing support only.
- Next:
  - Enable debug_force_officer_capture_for_testing in the scene inspector or via battle rules, then run one control-assisted defeat case to verify capture now triggers every time the preconditions are met; after that, decide whether to also add a more aggressive full-force test mode that bypasses the ufu/control prerequisite entirely.
## 2026-03-25 16:05 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Tidy the expedition page right-side info area only: remove duplicate lower six-stat text, unify `Ship/Troops` formatting, move the radar lower, and make naval/water data blue.
- Done:
  - Updated `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\strategy_ui_layer.gd` so the right-side top block now reads as `Ship` + team naval aptitude, then ship selection, then `Troops` + current troop aptitude, with the troop summary simplified to `Type / Apt / Count` plus special troop when active.
  - Hid the duplicate lower `Land/Naval` rich-text blocks instead of reusing them, so the radar remains the only six-axis comparison display in that area.
  - Increased the right-top spacing and moved the radar chart further down to reduce top label clipping.
  - Updated `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\ui\expedition_radar_chart.gd` so naval/water values now use the blue palette and land values use the amber palette for contrast.
  - Revalidated with `E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\灞辨渤蹇楅璧锋眽鏈?-s res://tmp/_tmp_verify_expedition_parse.gd`.
- Risks:
  - The `Ship` label and `Troops` button now carry two lines of compact English text; if the current font/theme renders them too tight at runtime, the next safe pass should be spacing/font tuning only, not another structure change.
  - The hidden lower land/water rich-text controls still exist in code for now; they are intentionally suppressed in this pass to avoid disturbing other expedition logic.
- Next:
  - Open the expedition page in runtime and visually confirm the radar top labels are readable, the blue layer is clearly understood as naval data, and the `Ship/Troops` block feels aligned enough before doing any further detail polish.

## 2026-03-25 11:48 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Add the requested Poly Haven `Qwantani Dusk 2 (Pure Sky)` sky into `TreeTest` without breaking the current golden-hour confession setup.
- Done:
  - Downloaded the requested Poly Haven sky asset source from `https://polyhaven.com/a/qwantani_dusk_2_puresky` and stored a Godot-friendly tonemapped panorama copy under `E:\灞辨渤蹇楅璧锋眽鏈玕sky_assets\qwantani_dusk_2_puresky.jpg`.
  - Added `E:\灞辨渤蹇楅璧锋眽鏈玕sky_assets\qwantani_dusk_2_puresky_sky.tres` as a `PanoramaSkyMaterial` wrapper so `TreeTest` can reference the Poly Haven sky as a normal Godot `Sky` resource.
  - Switched `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\tree_test.tscn` from the procedural sunset sky resource to the new Poly Haven panorama sky.
  - Also kept the recently thickened green outline intact; current `TreeTest` stays at `460` trees total.
  - Revalidated with `E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\灞辨渤蹇楅璧锋眽鏈?-s res://tmp/_tmp_verify_tree_test_scene.gd`, which reported `tree_test_children=460`, `camera_current=true`, `camera_script=true`, `water_material_ok=true`, and `floor_material_ok=true`.
- Risks:
  - This uses the tonemapped JPG panorama variant rather than the raw EXR because the current headless/Godot import path in this repository recognized the JPG import cleanly and reliably for the scene resource flow.
  - The sky now matches the requested Poly Haven look, but the final screenshot mood still depends on your chosen camera yaw/pitch relative to the sunset glow in that panorama.
- Next:
  - Open `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\tree_test.tscn`, reset the camera with `F`, then orbit until the warm horizon sits behind the island for the strongest confession-shot silhouette.

## 2026-03-25 12:02 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Swap `TreeTest` to the requested Poly Haven `The Sky Is On Fire` panorama while restoring strong golden-hour mood and improving the sea/sky blend.
- Done:
  - Downloaded the requested sky panorama from `https://polyhaven.com/a/the_sky_is_on_fire` and added Godot sky wrappers under `E:\灞辨渤蹇楅璧锋眽鏈玕sky_assets\the_sky_is_on_fire.jpg` and `E:\灞辨渤蹇楅璧锋眽鏈玕sky_assets\the_sky_is_on_fire_sky.tres`.
  - Switched `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\tree_test.tscn` to the new `The Sky Is On Fire` sky resource.
  - Reworked `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\shaders\tree_test_water.gdshader` so the sea reflects warmer sunset tones and blends toward the sky better instead of staying a detached flat blue.
  - Added horizon fog directly in the `TreeTest` environment block so sea and sky merge more naturally in the distance while keeping the island readable in the foreground.
  - Revalidated with `E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\灞辨渤蹇楅璧锋眽鏈?-s res://tmp/_tmp_verify_tree_test_scene.gd`, which reported `tree_test_children=460`, `camera_current=true`, `camera_script=true`, `water_material_ok=true`, and `floor_material_ok=true`.
- Risks:
  - This uses the Poly Haven tonemapped JPG panorama variant because it imports reliably in the current Godot project path; the EXR route remained less reliable in this repository鈥檚 headless verification flow.
  - The final 鈥済olden鈥?feeling now depends a lot on camera yaw relative to the brightest part of the panorama, so the best screenshot will still come from choosing the right view angle.
- Next:
  - Open `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\tree_test.tscn`, press `F`, rotate until the hottest cloud glow sits behind or beside the island, and capture the shot with the water highlight aligned under the sky glow.
## 2026-03-25 16:55 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Continue the core-12 unique-skill pass: verify config, polish low-risk auto-cast logic, and keep this window off the prisoner-system branch.
- Done:
  - Confirmed `E:\山河志风起汉末\data\config\unique_skills_v1.json` still contains all 12 core officers and explicit `auto_proc_chance` values for each skill.
  - Updated `E:\山河志风起汉末\scripts\battlefield_controller.gd` unique-skill auto logic so target selection now scores candidates instead of always taking the nearest target, with support for role preference, enemy-commander preference, advancing-target preference, cluster preference, and burning-target preference.
  - Wired extra auto-rule checks that were present in data but not fully honored at runtime: fire skills now skip auto-cast when rain-blocked if `prefer_not_rain` is set, interrupt skills can react to an actively casting target when `trigger_on_enemy_cast` is set, and fire-chain style skills now require a burning target when `require_existing_burning_target` is set.
  - Updated `E:\山河志风起汉末\docs\codex\TASK_BOARD.md` to record the current unique-skill polish pass as an in-progress item and add live-combat verification as the next follow-up.
  - Revalidated with `E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\山河志风起汉末 -s res://tmp/_tmp_verify_unique_skills.gd` and `E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\山河志风起汉末 --quit --scene res://scenes/china_terrain_30km.tscn`, both of which exited cleanly.
- Risks:
  - `scripts/battlefield_controller.gd` still has a large amount of unrelated in-flight work in the working tree from earlier passes, so future merges should review hunks carefully and avoid bundling unrelated battle-report/prisoner-side changes by accident.
  - `data\config\unique_skills_v1.json` still has historical mixed-encoding display issues in some Chinese fields; Godot parses it, but external strict JSON tooling may still complain.
- Next:
  - Open a live battle with the 12 core officers, verify that auto-cast now prefers more sensible targets in practice, then trim only obvious outlier cooldown/proc values rather than changing templates again.

## 2026-03-25 12:45 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Persist battle officer-capture results back into the strategy layer without introducing a second prisoner pipeline.
- Done:
  - Updated `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\engine\strategy_bootstrap.gd` so battle-end settlement now calls `_settle_battle_captured_officers()` before returning to internal phase.
  - Added strategy-meta default support for `meta.captured_officers`, and wrote capture settlement records there with officer snapshot, source city, captor info, battle origin city, capture day, and testing-force flag.
  - Settlement now scans the live world snapshot for the captured officer, removes that officer from the source city `officer_roster`, rebuilds `personnel` and `officers` values for the affected city, and syncs `meta.city_orders` so expedition selections do not keep dangling captured officers.
  - Updated `E:\灞辨渤蹇楅璧锋眽鏈玕docs\codex\PROJECT_MEMORY.md` to record the new strategy-layer capture persistence structure.
  - Revalidated battle-side parse with `E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\灞辨渤蹇楅璧锋眽鏈?-s res://tmp/_tmp_parse_capture_pair.gd`, which loaded `battlefield_controller.gd` and `unit_controller.gd` cleanly.
- Risks:
  - Full bootstrap parse is currently blocked by an existing unrelated compile error in `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\strategy_ui_layer.gd:4952` (`_unique_string_array()` missing there), so this pass could not get a clean end-to-end `strategy_bootstrap.gd` headless compile signal.
  - The new persistence path currently settles only officers that can be resolved by `captured_officer_id`; generic enemy demo units without a real officer id still only produce battle-time reports, not strategy prisoners.
- Next:
  - Fix or isolate the existing `strategy_ui_layer.gd` compile blocker, then run a headless bootstrap parse and one live expedition battle to verify captured officers disappear from the source city and land in `meta.captured_officers` as expected.

## 2026-03-25 16:28 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Make the expedition flow actually complete end-to-end instead of only looking correct: confirm button must emit, main-scene panel must carry troop data, and confirmed orders must validate/store troop payload.
- Done:
  - Updated `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\strategy_ui_layer.gd` so the main command `Confirm` button now emits `expedition_plan_confirmed` when the active panel is `expedition_prepare`, using the built expedition payload and refusing empty officer / zero troop submissions.
  - Updated `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\engine\strategy_bootstrap.gd` so `_open_expedition_panel()` now passes `units`, `unit_composition`, `selected_unit_allocation`, `organized_troops`, and `assignments`, bringing the main-scene expedition panel in line with the runtime scene data contract.
  - Added `_validate_expedition_troop_payload()` in `strategy_bootstrap.gd` and used it in `_on_expedition_plan_confirmed()` so troop allocation is checked against organized troops and unit composition before the order is accepted.
  - Extended `_set_expedition_active()` to persist troop allocation / totals / lead troop / effective troop / special troop flags in `meta.city_orders` instead of dropping them.
  - Added `E:\灞辨渤蹇楅璧锋眽鏈玕tmp\_tmp_verify_expedition_flow_contract.gd` as a focused contract check for the expedition confirm chain.
  - Revalidated with both `res://tmp/_tmp_verify_expedition_parse.gd` and `res://tmp/_tmp_verify_expedition_flow_contract.gd` under headless Godot.
- Risks:
  - `StrategyBootstrap` still does not convert selected troop composition into different battle-side unit role spawning yet; the confirmed expedition order now carries the data correctly, but battle deployment still mainly uses officer/aptitude/ship identity.
  - The contract test is text-contract based, so if the implementation is later refactored heavily it should be updated rather than treated as a behavior test.
- Next:
  - In runtime, open a city expedition panel and verify this exact path: pick officers -> pick troops/amount -> confirm expedition -> reopen panel and confirm the previous troop allocation persists; after that, the next logical pass is making the chosen lead troop influence actual spawned battle role composition.
## 2026-03-25 17:08 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Rebalance the 12 core unique skills so they have clearer strength tiers, with Zhuge Liang, Cao Cao, and Zhou Yu treated as first-tier strategic-impact skills.
- Done:
  - Updated `E:\山河志风起汉末\data\config\unique_skills_v1.json` cooldown and `auto_proc_chance` values to create clearer tiers without changing templates or order cost.
  - First-tier strategic skills were set to stronger overall tempo/value windows: `caocao` `50.0 / 0.36`, `zhugeliang` `52.0 / 0.35`, `zhouyu` `54.0 / 0.33`.
  - Second-tier high-impact skills were tuned to sit just below the top group: `simayi` `53.0 / 0.40`, `guanyu` `53.0 / 0.46`, `sunquan` `53.0 / 0.34`, `luxun` `56.0 / 0.34`.
  - Third-tier narrower but reliable burst/raid skills were kept with relatively higher auto trigger but lower strategic ceiling: `zhangliao` `51.0 / 0.54`, `ganning` `51.0 / 0.52`, `liubei` `56.0 / 0.39`.
  - Fourth-tier situational frontline pressure skills were lowered slightly: `xiahoudun` `57.0 / 0.43`, `zhangfei` `57.0 / 0.44`.
  - Revalidated with `E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\山河志风起汉末 -s res://tmp/_tmp_verify_unique_skills.gd` and `E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\山河志风起汉末 --quit --scene res://scenes/china_terrain_30km.tscn`, both clean.
- Risks:
  - This pass only changes cooldown/proc tempo; real battlefield ranking may still shift after live tests because some skills scale differently with formation density, weather, and player manual timing.
  - `zhangliao` and `ganning` still have high auto-trigger values by design because they are narrow assassination/raid skills, so they may feel more active than some higher-tier strategic skills even though their ceiling is lower.
- Next:
  - Run one live combat pass with the 12 core officers and check whether first-tier strategic skills actually feel more battle-defining than the narrower burst skills; if not, do one more micro-pass on cooldown only.

## 2026-03-25 12:58 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Re-run strategy bootstrap validation after the strategy-layer capture persistence patch and identify the next real blocker.
- Done:
  - Re-checked `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\strategy_ui_layer.gd` around the previous `_unique_string_array()` report and confirmed the current file path now uses `_expedition_selected_clean_officer_ids()` in that expedition confirm path.
  - Re-ran `E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\灞辨渤蹇楅璧锋眽鏈?-s res://tmp/_codex_parse_check.gd`, which exited cleanly, so `strategy_bootstrap.gd` is no longer blocked by the earlier compile error.
  - Re-ran `E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\灞辨渤蹇楅璧锋眽鏈?-s res://tmp/_verify_battle_and_china_load.gd`, which also exited cleanly.
  - Re-ran a headless main-scene boot with `--quit --scene res://scenes/main.tscn`; runtime now reaches UI build but logs missing resource errors for `res://缁辩姵娼?icon/xiangyun.png` from `strategy_ui_layer.gd` instead of script compile failures.
- Risks:
  - The current next blocker is no longer script compilation; it is a runtime asset path/import issue for `xiangyun.png`, likely tied to the repository's long-standing mixed-encoding asset-path history.
  - Until that icon path is fixed or safely guarded, headless main-scene startup still logs resource load errors even though the strategy capture settlement code compiles.
- Next:
  - Fix or guard the `xiangyun.png` resource load path in `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\strategy_ui_layer.gd`, then rerun headless `main.tscn` startup and, after that, do one live battle to verify captured officers are removed from source-city rosters and written into `meta.captured_officers`.

## 2026-03-25 12:12 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Revert `TreeTest` from the less convincing fire-sky attempt back to the warmer golden-hour sunset version, while reducing the visible sea/sky and shallow-water boundary feeling.
- Done:
  - Switched `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\tree_test.tscn` back to `E:\灞辨渤蹇楅璧锋眽鏈玕sky_assets\sunset_procedural_sky.tres` instead of the temporary `The Sky Is On Fire` panorama wrapper.
  - Retuned `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\shaders\tree_test_water.gdshader` to blend more gently toward the horizon tint and reduced the over-strong shallow-water contrast so the sea no longer feels as detached from the sunset sky.
  - Retuned `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\shaders\tree_test_lagoon_floor.gdshader` so the underwater color transition is softer and the bright ring around the island is less obvious.
  - Reduced horizon fog density and warmed its color, then enlarged both the water plane and lagoon floor plane to `9000 x 9000` so the horizon sits much farther away and blends more naturally.
  - Revalidated with `E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\灞辨渤蹇楅璧锋眽鏈?-s res://tmp/_tmp_verify_tree_test_scene.gd`, which still reports `tree_test_children=460`, `camera_current=true`, `camera_script=true`, `water_material_ok=true`, and `floor_material_ok=true`.
- Risks:
  - This restores the more controlled and flattering golden-hour look, but the very last bit of 鈥渞eal ocean to sky鈥?illusion still depends on the screenshot angle; a flatter horizon shot will always sell it better than a higher angle.
  - The `The Sky Is On Fire` files remain on disk but are no longer used by `TreeTest`.
- Next:
  - Open `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\tree_test.tscn`, keep the lower grazing camera angle, and capture from a direction where the warm sky glow sits along the waterline for the best sea/sky merge.
## 2026-03-25 18:08 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Keep the TreeTest golden-hour confession scene, but push the ocean toward a cleaner blue transparent lagoon look.
- Done:
  - Retuned `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\shaders\tree_test_water.gdshader` so the sea base shifts from warm gray-blue to a clearer cyan-to-deep-blue gradient, while preserving warm sunset glints and horizon sheen.
  - Increased the water transparency behavior, especially near the island, so the shallow area reads more like transparent blue water instead of a flatter opaque surface.
  - Retuned `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\shaders\tree_test_lagoon_floor.gdshader` to use more turquoise shallow tint and deeper blue offshore tint, reducing the washed-out pale look under the water.
  - Revalidated with `E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\灞辨渤蹇楅璧锋眽鏈?-s res://tmp/_tmp_verify_tree_test_scene.gd`, which still reported `tree_test_children=460`, `camera_current=true`, `camera_script=true`, `water_material_ok=true`, and `floor_material_ok=true`.
- Risks:
  - This was tuned to stay compatible with the current golden procedural sunset; depending on the exact camera angle, the water may still look warmer at the far horizon because sunset reflection is intentionally preserved.
  - The existing headless verification still prints the known dummy-renderer leak noise on exit, but the scene and materials load correctly.
- Next:
  - Open `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\tree_test.tscn` and check one hero angle; if you want it even more鍍忛┈灏斾唬澶? the next small pass should only reduce warm horizon tint and brighten shallow cyan another notch.

## 2026-03-25 13:08 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix the broken `xiangyun.png` UI resource path and validate the user-designated `ChinaTerrain30km` gameplay entry again.
- Done:
  - Updated `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\strategy_ui_layer.gd` to use the real cloud-icon path `res://绱犳潗/icon/xiangyun.png` instead of the garbled `res://缁辩姵娼?icon/xiangyun.png` constant.
  - Revalidated `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\china_terrain_30km.tscn` with `E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\灞辨渤蹇楅璧锋眽鏈?--quit --scene res://scenes/china_terrain_30km.tscn`, which exited cleanly.
  - Revalidated `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\main.tscn` with the same headless `--quit --scene` flow, which also exited cleanly after the icon-path fix.
  - Updated `E:\灞辨渤蹇楅璧锋眽鏈玕docs\codex\PROJECT_MEMORY.md` to record that `ChinaTerrain30km` is the user-designated primary gameplay validation scene.
- Risks:
  - This fix addresses the confirmed `xiangyun.png` path only; other historical mixed-encoding asset paths may still exist elsewhere and should be treated case-by-case rather than mass-rewritten.
  - Headless startup is now clean, but the battle-to-strategy prisoner persistence still needs a live gameplay verification pass to confirm captured officers disappear from source-city rosters and land in `meta.captured_officers` during real play.
- Next:
  - Run one live `ChinaTerrain30km` battle that produces an officer capture, then inspect the originating city roster and `meta.captured_officers` to confirm the full persistence loop works in runtime.
## 2026-03-25 18:58 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Make `ChinaTerrain30km` use a pure flat LOD1 sightseeing camera, hide all settlement names in LOD1, and keep LOD2 as the prior pitched view with unchanged height.
- Done:
  - Updated `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\china_terrain_scene.gd` camera rules so `lod_tilt_deg` is now `[0.0, 45.0, 45.0, 45.0, 88.0, 88.0]`, while `lod_level_heights` stays unchanged at `[160.0, 420.0, 1400.0, 4200.0, 12000.0, 26000.0]`.
  - Updated `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\map_camera_controller.gd` to allow a true flat `0.0` degree per-LOD tilt instead of clamping all LOD tilts to `10+` degrees.
  - Updated `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\china_city_instance.gd` so city names are hidden in `LOD1` while keeping the scene objects themselves visible.
  - Updated `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\strategic_site_manager.gd` so non-city / strategic site labels are also hidden in `LOD1`, matching the sightseeing requirement and reducing on-screen clutter.
  - While trying to validate scene load, also repaired several pre-existing malformed string-literal lines in `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\china_terrain_scene.gd` near the facility action tables and one runtime winner-name fallback, but did not finish a full cleanup of that file.
- Risks:
  - Full headless load validation for `res://scenes/china_terrain_30km.tscn` is still blocked by additional old malformed/garbled string literals elsewhere in `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\china_terrain_scene.gd`; the first remaining parser stop encountered at the end of this session was around line `1306`, and the quick odd-quote scan showed more unrelated corrupted text lines further down.
  - Because of that pre-existing script corruption, runtime verification is not yet a clean proof of the new LOD behavior even though the targeted camera/label logic files themselves were updated.
- Next:
  - Do one dedicated cleanup pass on malformed string literals in `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\china_terrain_scene.gd` until `china_terrain_30km.tscn` loads cleanly again, then verify `LOD1` flat sightseeing view and `LOD1` hidden labels in-engine.
## 2026-03-25 17:26 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Collapse the unique-skill balance into three tiers and move Xiahou Dun, Zhang Fei, and Sun Quan into the third tier per user direction.
- Done:
  - Updated `E:\山河志风起汉末\data\config\unique_skills_v1.json` so the third-tier group is now `xiahoudun`, `zhangfei`, and `sunquan`.
  - Tuned `xiahoudun` to `56.0 / 0.45`, `zhangfei` to `56.0 / 0.45`, and `sunquan` to `56.0 / 0.32` (`cooldown_sec / auto_proc_chance`).
  - Repaired the temporary malformed Sun Quan block introduced during the tier reshuffle and revalidated the unique-skill JSON parse.
- Risks:
  - This is still a paper balance pass; the temporary auto-battle probe is not yet clean enough to trust for final ranking decisions, so live or scripted combat sampling is still the next real balance step.
- Next:
  - When returning to balance, finish the unique-skill probe cleanup and use it only for relative smoke testing, then do one more micro-pass if any third-tier skill feels too flat.
## 2026-03-25 19:32 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Build an isolated confession-scene presentation variant with better sea/sky blending and a path toward standalone sharing without affecting the main project flow.
- Done:
  - Added `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\tree_test_touch_camera.gd` as a touch-friendly orbit camera for phone/tablet/desktop style presentation, including drag rotate, pinch zoom, mouse wheel zoom, reset, and optional auto-rotate.
  - Added `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\shaders\tree_test_ocean_shell.gdshader` for a large spherical ocean shell that fills the far horizon with blue ocean color so sea and sky blend more naturally.
  - Created a fully isolated scene variant at `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\tree_test_love_app.tscn` that keeps the original `tree_test.tscn` untouched while switching to the new touch camera and adding the `OceanShell` backdrop.
  - Headless-loaded `res://scenes/tree_test_love_app.tscn` successfully; only the existing tree-material remap warnings appeared during load.
  - Added export/share notes at `E:\灞辨渤蹇楅璧锋眽鏈玕deliverables\tree_test_love_app\README.md` and confirmed the current machine does not have Godot export templates under `C:\Users\Admin\AppData\Roaming\Godot\export_templates`.
- Risks:
  - The isolated love-app scene is ready, but final standalone `.exe` / `.html` / `.apk` export is still blocked on missing Godot export templates on this machine.
  - A true one-link phone+computer delivery is best done as a Web export, but that still requires the missing export templates and then a simple hosting step.
- Next:
  - Install/export Godot templates, then export `tree_test_love_app.tscn` as Web first and Windows desktop second; if needed after that, create a tiny dedicated subproject so the export has a completely separate project entry without touching the main game entry scene.
## 2026-03-25 14:24 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Finish the unique-skill auto-balance probe so it can run headless reliably and produce reusable per-officer reports plus a batch summary.
- Done:
  - Rebuilt `E:\山河志风起汉末\tmp\_tmp_unique_skill_tier_probe.gd` into a clean single-officer headless probe script. It now accepts `--officer`, `--matches`, `--max_sim_sec`, `--time_scale`, `--seed_start`, and `--report`, runs isolated auto-battles, and writes a JSON payload with `summary` + `matches`.
  - Added `E:\山河志风起汉末\tools\balance\run_unique_skill_tier_probe.ps1` as the batch launcher. It runs one Godot headless process per officer, captures stdout/stderr logs, aggregates all JSON summaries into `summary.csv`, `summary.json`, and `summary.txt`, and supports optional `-OfficerIds` filtering for focused smoke runs.
  - Verified the single-officer path with a Cao Cao smoke run that generated `E:\山河志风起汉末\tmp\reports\unique_skill_probe_smoke_caocao.json`.
  - Verified the batch launcher end-to-end with a 1-match smoke run. Example output directory: `E:\山河志风起汉末\tmp\reports\unique_skill_probe_20260325_142309`, containing per-officer JSON/logs plus `summary.csv` and `summary.txt`.
- Risks:
  - The current probe is good for relative smoke testing, but 1-match runs are intentionally noisy; real balance decisions should use higher `-Matches` and probably a longer `-MaxSimSec`.
  - Probe results currently reflect “entire team led by one officer vs baseline mirror team,” so they measure broad battle swing rather than pure skill-only value in a mixed historical roster.
- Next:
  - Use `tools\balance\run_unique_skill_tier_probe.ps1 -Matches 3` or higher for a less noisy ranking pass, then only adjust `cooldown_sec` / `auto_proc_chance` if the multi-run ordering still disagrees with the intended three-tier design.

## 2026-03-25 16:44 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Make the confirmed expedition troop choice influence real battle deployment instead of being stored only as UI/order data.
- Done:
  - Added troop-to-battle-role mapping helpers in `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\engine\strategy_bootstrap.gd` so confirmed expedition troop composition can be translated into battle roles (`cavalry / spear / shield / archer / crossbow / strategist / siege`) using the selected lead troop first and the remaining chosen troop types after it.
  - Updated `_build_battle_team_a_deployment()` in `strategy_bootstrap.gd` so team A role selection now prefers the expedition troop-derived role sequence before falling back to the old officer-aptitude-based role resolver.
  - Kept the change intentionally narrow: ship type, aptitude, and officer identity logic remain intact; only the role source now respects confirmed expedition troop choice when possible.
  - Expanded `E:\灞辨渤蹇楅璧锋眽鏈玕tmp\_tmp_verify_expedition_flow_contract.gd` to assert the new deployment-role hook is wired into the expedition flow contract.
  - Revalidated with `res://tmp/_tmp_verify_expedition_parse.gd` and `res://tmp/_tmp_verify_expedition_flow_contract.gd` under headless Godot.
- Risks:
  - The troop-to-role mapping is still heuristic and English-token based (`caval`, `bow`, `cross`, `siege`, etc.); if future regroup unit ids/class ids drift far from those tokens, the fallback will be the old officer-based role resolver.
  - This pass changes battle role composition, but it still does not yet split one expedition into multiple distinct troop-count-based battlefield stacks; it only makes the spawned role identity follow the selected main troop mix.
- Next:
  - In runtime, confirm one or two obvious cases: selecting cavalry-heavy expedition should spawn cavalry-led team A, and selecting bow/crossbow-heavy expedition should spawn ranged-led team A; if that reads correctly, the next step is deciding whether vice units should also inherit exact troop names/labels or even proportional soldier counts.
## 2026-03-25 21:05 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Recover the corrupted `china_terrain_scene.gd` / `strategy_ui_layer.gd` mojibake pass safely and restore clean `ChinaTerrain30km` headless startup.
- Done:
  - Repaired `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\china_terrain_scene.gd` damaged logic around `_runtime_siege_resolve_city_record` and `_accumulate_gold_personality_level`, restoring the missing helper function `_apply_blue_effect_bonus` and the broken city-defense setup block.
  - Restored verified resource paths in `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\china_terrain_scene.gd` for weather textures and `poly_nature_pack_assets.blend`.
  - Cleaned remaining mojibake defaults in `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\strategy_ui_layer.gd` for player-brief background, command title icon, cancel button, decide button, and regroup empty-resource text.
  - Revalidated `res://scenes/china_terrain_30km.tscn` with `E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\灞辨渤蹇楅璧锋眽鏈?--quit --scene res://scenes/china_terrain_30km.tscn`, which now exits with code `0` again.
- Risks:
  - This pass removed the confirmed mojibake / corruption in the two touched presentation scripts, but the wider repo may still contain historical non-English UI strings that were not part of this recovery scope.
  - `strategy_ui_layer.gd` still has large unrelated local modifications already in progress in this worktree; future cleanup should stay surgical to avoid stomping those changes.
- Next:
  - If the user still wants broader English localization, do a controlled pass on player-facing UI strings only, starting from `strategy_ui_layer.gd` command/regroup text and validating after each small batch.
## 2026-03-25 19:44 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Push the isolated `tree_test_love_app` scene toward a more cinematic sea/sky blend and add screenshot-friendly hero camera presets.
- Done:
  - Retuned `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\shaders\tree_test_ocean_shell.gdshader` with a softer blue horizon gradient plus a warm sunset glow band so the ocean shell blends into the sky more cinematically.
  - Retuned the isolated scene environment in `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\tree_test_love_app.tscn` only: slightly higher ambient, softer cooler fog tint, lower fog density, farther fog depth, slightly improved sunset light angle, and a deeper ocean-shell placement.
  - Upgraded `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\tree_test_touch_camera.gd` to include three hero presets: `Wide Reveal`, `Heart Hero`, and `Low Horizon`, with keyboard shortcuts `1`, `2`, `3`, and `Space` to cycle.
  - Revalidated `res://scenes/tree_test_love_app.tscn` headlessly after fixing a temporary UTF-8 BOM issue introduced during editing; the scene loads again with only the existing tree-material remap warnings.
- Risks:
  - The hero preset framing is based on the current island/tree composition and should be visually checked in-editor for final screenshot approval; the logic loads cleanly, but exact emotional framing is still best judged by eye.
  - The persistent tree-material remap warnings come from the older cinematic tuner workflow and were not changed in this pass.
- Next:
  - Open `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\tree_test_love_app.tscn`, try `1` / `2` / `3`, and if one angle is close but not perfect, do one final art pass on preset focus/yaw/pitch only.

## 2026-03-25 17:02 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Correct the expedition troop model back to a single-troop San11-style unit after the user clarified that one expedition unit should only ever carry one troop type.
- Done:
  - Updated `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\strategy_ui_layer.gd` so expedition troop selection now normalizes to a single troop type only, both when loading old saved orders and when changing troop amount in the picker; choosing a troop now clears any previous troop selection automatically.
  - Tightened the right-side troop summary in `strategy_ui_layer.gd` to display only one selected troop type instead of a multi-type preview.
  - Updated `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\engine\strategy_bootstrap.gd` so expedition battle deployment now uses one troop-derived role repeated across the generated deployment entries instead of cycling across multiple troop roles.
  - Repaired the broken `AIDE_PORTRAIT_DIR` constant in `strategy_ui_layer.gd` by pointing it to `res://绱犳潗/绔嬬粯`, which restored script parseability after the file鈥檚 prior encoding damage.
  - Revalidated with both `res://tmp/_tmp_verify_expedition_parse.gd` and `res://tmp/_tmp_verify_expedition_flow_contract.gd` under headless Godot.
- Risks:
  - `AIDE_PORTRAIT_DIR` was repaired to a sane existing directory to restore parsing, but the portrait-name matching logic may still need a later dedicated cleanup because the surrounding file has heavy encoding history.
  - Battle deployment still uses multiple generated entries internally; this pass only ensures they all follow the single selected troop role instead of pretending one expedition unit can carry multiple troop types.
- Next:
  - In runtime, verify this exact behavior: selecting cavalry/bow/spear now leaves only one troop type active in the expedition picker and reopening the panel preserves only that one choice; if accepted, the next pass should decide whether the battle-side display label should show the effective special troop name directly when auto-conversion is active.
## 2026-03-25 21:16 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Resolve the editor parser error shown from `china_terrain_scene.gd` failing to preload `strategy_ui_layer.gd`.
- Done:
  - Fixed the actual broken constants at `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\strategy_ui_layer.gd:27` and `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\strategy_ui_layer.gd:28`.
  - Restored `UI_CLOUD_ICON_PATH` to `res://绱犳潗/icon/xiangyun.png` and `AIDE_PORTRAIT_DIR` to `res://绱犳潗/绔嬬粯`.
  - Revalidated direct script load with `res://tmp/_tmp_parse_strategy_ui_layer.gd` and headless scene startup for `res://scenes/china_terrain_30km.tscn`; both now succeed.
- Risks:
  - The editor may still show stale errors until the script tab or project is reloaded.
- Next:
  - If the editor still reports the old preload error, reopen `strategy_ui_layer.gd` or restart the Godot editor once to clear cached diagnostics.
## 2026-03-25 14:45 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Run a full 12-officer unique-skill probe with 3 matches per officer and capture a less noisy ranking snapshot.
- Done:
  - Executed `tools\balance\run_unique_skill_tier_probe.ps1` with `-Matches 3 -MaxSimSec 120 -TimeScale 8`.
  - Generated a full report bundle under `E:\山河志风起汉末\tmp\reports\unique_skill_probe_20260325_143618` including per-officer JSON/logs plus `summary.csv`, `summary.json`, and `summary.txt`.
  - Current 3-match ranking snapshot from `summary.txt`: `caocao` first, `liubei` second, then `sunquan`, `zhangliao`, `simayi`, `xiahoudun`, `luxun`, `zhouyu`, `zhugeliang`, `ganning`, `zhangfei`, `guanyu`.
- Risks:
  - This probe still measures “whole team led by one officer vs baseline mirror team,” so it is useful for relative smoke testing but not for final lore-accurate ranking by itself.
  - Several runs still resolve on timeout comparison, so `-Matches 5` or `-Matches 7` would give a more stable next snapshot before making further balance edits.
- Next:
  - If using the probe to tune balance, run one more pass at higher sample count and only adjust `cooldown_sec` / `auto_proc_chance` where the multi-run trend repeatedly contradicts the intended three-tier design.
## 2026-03-25 20:02 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Convert the isolated love-app scene from flat planes plus backdrop shell into a true curved beach/ocean presentation with a sunset sky dome and a low horizon sun.
- Done:
  - Reworked `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\tree_test_love_app.tscn` so `WaterMesh` now uses a giant world sphere (`SphereMesh_water_world`) centered below the scene, making the sea genuinely curved instead of a flat plane.
  - Reworked `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\tree_test_love_app.tscn` so `IslandMesh` now uses a slightly larger giant sphere (`SphereMesh_island_world`) centered below the scene, letting the beach/sand mask sit on a curved surface.
  - Hid the old flat lagoon floor plane in the isolated scene to stop it from visually breaking the spherical world illusion.
  - Replaced the old backdrop shell shader reference with a new sky-dome shader at `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\shaders\tree_test_sunset_sky_dome.gdshader`, which adds sunset gradient, glow band, cloud wisps, and a near-horizon sun disk.
  - Retuned the isolated scene environment and light to support the sunset direction, and increased camera far clip so the large curved world and dome are actually visible.
  - Retuned `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\tree_test_touch_camera.gd` so the default preset now opens with a low sunset-reveal angle instead of a flatter top-down art-preview feeling.
  - Headless-loaded `res://scenes/tree_test_love_app.tscn` successfully after the curved-world conversion; existing tree-material remap warnings remain but the scene loads.
- Risks:
  - The scene now matches the requested spherical-beach / spherical-ocean / sunset-dome structure, but the exact art quality of the final sunset shot still needs an in-editor eyeball check because curved-world presentation is very angle-sensitive.
  - The isolated scene still keeps old helper resources like the procedural sky ext-resource in the file even though the visible result should now be dominated by the custom sky dome.
- Next:
  - Open `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\tree_test_love_app.tscn`, check preset `1`, then do one final visual pass only on sun height / camera pitch / beach radius if you want the sunset to sit even more precisely on the sea horizon.
## 2026-03-25 14:59 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Recover the corrupted unique_skills_v1.json and finish the unique-skill balance probe handoff cleanly.
- Done:
  - Rebuilt E:\灞辨渤蹇楅璧锋眽鏈玕data\config\unique_skills_v1.json from git show HEAD:data/config/unique_skills_v1.json instead of trying any further regex patching.
  - Reapplied the intended current cooldown / auto-proc values for the 12 core officers, preserving the three-tier target direction from this session.
  - Revalidated the config with E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\灞辨渤蹇楅璧锋眽鏈?-s res://tmp/_tmp_verify_unique_skills.gd.
  - Re-ran a smoke probe through E:\灞辨渤蹇楅璧锋眽鏈玕tools\balance\run_unique_skill_tier_probe.ps1 for caocao; report bundle generated under E:\灞辨渤蹇楅璧锋眽鏈玕tmp\reports\unique_skill_probe_20260325_145803.
- Risks:
  - data/config/unique_skills_v1.json was regenerated through PowerShell JSON serialization, so formatting/order may differ from the hand-authored original even though the runtime data now validates.
  - The latest balance values are only smoke-checked after recovery; a broader -Matches 3 or -Matches 5 rerun is still needed before locking the three-tier ranking.
- Next:
  - Re-run the full 12-officer probe at higher sample count, then only trim the remaining outliers against the intended tiers without touching the prisoner-system branch.
## 2026-03-25 21:41 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Continue the safe English pass on player-visible map/runtime labels without reopening broad encoding risk.
- Done:
  - Kept `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\strategy_ui_layer.gd` parse-clean and restored its safe default resource paths.
  - Updated `E:\灞辨渤蹇楅璧锋眽鏈玕data\config\world_state.json` first batch of visible names: factions `wei/shu`, cities `luoyang/xinye/xuchang`, related building-unit city labels, and the officer/governor names plus domestic-personality blurbs for those three city rosters.
  - Updated the next visible map-label batch in `E:\灞辨渤蹇楅璧锋眽鏈玕data\config\world_state.json`: `Baidi Ferry`, `Hangu Pass`, `Jiange Fort`, and the first displayed Luoyang/Xinye/Hulao field-unit names plus commander labels.
  - Revalidated `res://scenes/china_terrain_30km.tscn` headless after each batch; exit code remains `0`.
- Risks:
  - `world_state.json` still contains many additional historical mojibake names outside this first safe batch, especially later sites and unit labels.
  - Because the file has old malformed-encoding history, future translation should continue in small visible clusters rather than mass replacement.
- Next:
  - Continue with the next visible world-state batch: remaining site names, remaining field-unit names/commander labels, then any surviving officer names that still appear in city/move/aide panels.
## 2026-03-25 20:12 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix the broken curved-world look in `tree_test_love_app` after the first sphere conversion made the beach look sliced and destroyed the Maldives-like ocean color.
- Done:
  - Added `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\shaders\tree_test_spherical_beach.gdshader` so the beach mask is now computed from sphere direction near the top pole instead of using the old flat-plane island shader.
  - Added `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\shaders\tree_test_spherical_ocean.gdshader` so the ocean on the world sphere now keeps turquoise lagoon color near the island while only warming near the sunset horizon.
  - Rewired `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\tree_test_love_app.tscn` to use the new spherical beach/ocean shaders and kept the sunset sky dome setup.
  - Kept the curved world structure: spherical ocean, spherical beach patch, hidden old flat lagoon floor, sunset dome, and low sunset sun direction.
  - Revalidated `res://scenes/tree_test_love_app.tscn` headlessly after correcting one temporary path separator issue; scene now loads again with only the pre-existing tree-material remap warnings.
- Risks:
  - Final visual quality still needs an in-editor eyeball check because spherical beach radius and lagoon falloff are art-tuned values.
  - The tree-material remap warnings remain from the older cinematic tree tuner and were not changed in this pass.
- Next:
  - Reopen `E:\灞辨渤蹇楅璧锋眽鏈玕scenes\tree_test_love_app.tscn` and judge the new spherical beach/ocean look; if needed, do one last art pass only on beach radius and lagoon width.
## 2026-03-25 21:49 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Align the English cleanup pass with the user's preference that map place names / site names stay in Chinese for easier position editing.
- Done:
  - Reverted the first translated geography labels in `E:\灞辨渤蹇楅璧锋眽鏈玕data\config\world_state.json` back to Chinese while keeping officer/UI English work intact.
  - Restored city names `娲涢槼 / 鏂伴噹 / 璁告槍`, matching building-unit city labels, and restored site labels `鐧藉笣娲ユ浮 / 铏庣墷鍏?/ 鍓戦榿鍫.
  - Revalidated `res://scenes/china_terrain_30km.tscn` headless; exit code remains `0`.
- Risks:
  - The broader file still contains many non-geographic mojibake names further down; future cleanup should preserve the user's new rule: geography stays Chinese unless explicitly requested otherwise.
- Next:
  - Continue English cleanup only for non-geographic player-facing content: officer names if desired, unit display names, personalities, hints, and battle/UI text.
## 2026-03-25 21:57 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Record a durable project rule for handling mojibake / Chinese / English going forward.
- Done:
  - Updated `E:\灞辨渤蹇楅璧锋眽鏈玕docs\codex\PROJECT_MEMORY.md` with a new language and encoding policy.
  - Locked in the current direction: English-first player-facing build, Chinese geography retained during active map editing, and no more broad blind mojibake replacement.
- Risks:
  - The repo still contains historical mixed-encoding content, so future cleanup must keep following the small-batch rule.
- Next:
  - Continue localization cleanup under the new rule: translate UI / officer / unit text first, keep map place names in Chinese unless the user asks otherwise.
## 2026-03-25 22:04 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Update the language policy to preserve clean Chinese source text for a later Chinese version.
- Done:
  - Revised `E:\灞辨渤蹇楅璧锋眽鏈玕docs\codex\PROJECT_MEMORY.md` so clean Chinese names/UI/report text are preserved by default.
  - Locked in the new rule: only fix mojibake or explicitly requested translations; do not overwrite good Chinese source text just to chase the English-facing build.
- Risks:
  - Future English build work should move toward localization tables or mapping layers; direct in-place translation is now the exception, not the default.
- Next:
  - Continue cleanup by fixing only mojibake / broken text while preserving valid Chinese source strings for later CN localization.
## 2026-03-25 22:06 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Update the language policy to preserve clean Chinese source text for a later Chinese version.
- Done:
  - Revised `E:\灞辨渤蹇楅璧锋眽鏈玕docs\codex\PROJECT_MEMORY.md` so clean Chinese names/UI/report text are preserved by default.
  - Locked in the new rule: only fix mojibake or explicitly requested translations; do not overwrite good Chinese source text just to chase the English-facing build.
- Risks:
  - Future English build work should move toward localization tables or mapping layers; direct in-place translation is now the exception, not the default.
- Next:
  - Continue cleanup by fixing only mojibake / broken text while preserving valid Chinese source strings for later CN localization.
## 2026-03-25 22:20 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Land the first-batch special troop rule expansion for expedition flow, keep code/config keys English-only, and add tech-point cost display without reopening broader UI work.
- Done:
  - Expanded `E:\灞辨渤蹇楅璧锋眽鏈玕data\config\special_troop_rules.json` from 3 entries to 6 entries: `white_horse`, `trap_guard`, `rattan_guard`, `tiger_leopard_cavalry`, `white_feather_guard`, `jiefan_corps`.
  - Kept runtime rule keys English-only and bound the new officers `caochun`, `chendao`, and `dingfeng` to their special troops.
  - Normalized special-troop unlock costs to the current requested structure `money + tech_points + command_points` for the whole first batch.
  - Updated `E:\灞辨渤蹇楅璧锋眽鏈玕scripts\presentation\strategy_ui_layer.gd` unlock-cost text mapping so expedition hints now render `Tech` when a special troop requires `tech_points`.
  - Revalidated with `res://tmp/_tmp_verify_expedition_parse.gd` and `res://tmp/_tmp_verify_expedition_flow_contract.gd`; both passed.
- Risks:
  - This pass only lands rule/config + display support; there is still no dedicated player-facing special-troop unlock action that actually spends the listed costs and writes `meta.special_troop_unlocks`.
  - `data/config/special_troop_rules.json` has prior encoding sensitivity; future edits should stay narrow and avoid mass rewrite outside this table.
- Next:
  - Add a minimal unlock action/path that consumes `money`, `tech_points`, and `command_points`, writes `meta.special_troop_unlocks`, and lets the expedition panel immediately reflect newly unlocked special troops.
## 2026-03-25 16:48 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Run the second unique-skill balance pass and verify whether the three-tier target moved closer after the latest cooldown / auto-proc tweaks.
- Done:
  - Rebuilt E:\灞辨渤蹇楅璧锋眽鏈玕data\config\unique_skills_v1.json again from HEAD baseline to recover from the broken mojibake-string variant, then applied the second balance pass values.
  - Revalidated the config with E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\灞辨渤蹇楅璧锋眽鏈?-s res://tmp/_tmp_verify_unique_skills.gd.
  - Ran a full 12-officer probe with 	ools\balance\run_unique_skill_tier_probe.ps1 -Matches 3 -MaxSimSec 120 -TimeScale 8.
  - Latest snapshot bundle is E:\灞辨渤蹇楅璧锋眽鏈玕tmp\reports\unique_skill_probe_20260325_164627; top group is now caocao, liubei, then zhangliao / sunquan / zhugeliang / guanyu / zhouyu clustered in the middle, with zhangfei improved from  /3 to 1/3 but still weak.
- Risks:
  - The probe moved zhugeliang upward, but liubei is still too high relative to the intended first tier and zhouyu fell back into the middle pack.
  - zhangfei, xiahoudun, simayi, luxun, and ganning still need another pass if the goal is a cleaner three-tier separation.
- Next:
  - Do a third tuning pass focused on lowering liubei, stabilizing zhouyu and zhugeliang into tier 1, and deciding whether zhangliao should stay as a strong tier-2 outlier or be trimmed slightly.
## 2026-03-25 16:56 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix the isolated love-app scene beach/ocean artifact by replacing the sphere-pole approach with a curved plane-cap approach while keeping the sunset sky.
- Done:
  - Switched E:\山河志风起汉末\scenes\tree_test_love_app.tscn water shader reference from 	ree_test_spherical_ocean.gdshader to the new E:\山河志风起汉末\scripts\shaders\tree_test_curved_ocean.gdshader.
  - Switched E:\山河志风起汉末\scenes\tree_test_love_app.tscn beach shader reference from 	ree_test_spherical_beach.gdshader to E:\山河志风起汉末\scripts\shaders\tree_test_curved_beach.gdshader.
  - Replaced the active water/island meshes in E:\山河志风起汉末\scenes\tree_test_love_app.tscn from giant sphere meshes to high-subdivision PlaneMesh resources, and moved the active nodes back to near-world-origin so the curved effect now comes from the vertex shader instead of sphere pole topology.
  - Tuned the active water plane to 60000 x 60000 with subdivisions and the island plane to 5200 x 4200 with subdivisions so the scene keeps a curved horizon without the radial fan artifact.
  - Headless-loaded es://scenes/tree_test_love_app.tscn successfully after the conversion; no new shader parse/runtime errors were reported.
  - Confirmed again that the noisy 	ree_cinematic_tuner.gd SpatialMaterial remap warnings are not the root cause of the beach artifact.
- Risks:
  - Visual quality still needs one in-editor eyeball pass because the exact Maldives feel depends on camera angle, water transparency, and sunset alignment.
  - The old sphere mesh sub-resources still remain in the .tscn file as unused data; they do not drive the active result anymore, but can be cleaned later if desired.
- Next:
  - Open E:\山河志风起汉末\scenes\tree_test_love_app.tscn in the editor, inspect preset 1, and do a final art-only pass on water transparency / lagoon color / beach radius if the horizon or shoreline still needs more romance-film polish.
## 2026-03-25 17:01 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Run a third unique-skill balance pass and check whether the three-tier target can be reached with another light cooldown / auto-proc adjustment.
- Done:
  - Applied a third pass to E:\灞辨渤蹇楅璧锋眽鏈玕data\config\unique_skills_v1.json, mainly lowering liubei / sunquan / zhangliao while raising zhugeliang / zhouyu / simayi / zhangfei / xiahoudun / luxun / ganning.
  - Revalidated the JSON with the headless verifier; the config still parses correctly after the latest edits.
  - Ran another full 12-officer probe with 	ools\balance\run_unique_skill_tier_probe.ps1 -Matches 3 -MaxSimSec 120 -TimeScale 8.
  - Latest report bundle is E:\灞辨渤蹇楅璧锋眽鏈玕tmp\reports\unique_skill_probe_20260325_165827; the outcome swung hard again: liubei returned to 3/3, zhouyu dropped to  /3, and several officers clustered around 1/3.
- Risks:
  - The probe is currently too volatile to treat a single -Matches 3 snapshot as reliable for final tier locking; small value changes are causing outsized ranking swings.
  - liubei still overperforms despite repeated nerfs, while zhouyu and zhugeliang remain unstable relative to the intended first tier.
- Next:
  - Stop blind whole-roster tweaking and instead run focused higher-sample probes (-Matches 5 or -Matches 7) on the officers with unstable swings, especially liubei, zhouyu, zhugeliang, and caocao, before making another balance pass.
## 2026-03-25 17:07 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix the love-app visual regression where the island read as a dark mud plate and the ocean was visually disappearing against the sunset sky.
- Done:
  - Retuned E:\山河志风起汉末\scripts\shaders\tree_test_curved_beach.gdshader to much brighter white-sand colors, slightly larger island mask, and a soft emission lift so the beach no longer reads as dark soil.
  - Retuned E:\山河志风起汉末\scripts\shaders\tree_test_curved_ocean.gdshader to stronger Maldives-style cyan/blue water and much higher opacity so the sea remains visible instead of blending away into the orange sky.
  - Updated E:\山河志风起汉末\scenes\tree_test_love_app.tscn water/sand material parameters to match the new beach/ocean look and lowered WaterMesh to create clearer sea-vs-island separation.
  - Updated E:\山河志风起汉末\scripts\presentation\tree_test_touch_camera.gd preset 1 so scene startup now uses a closer, lower sunset framing that should expose more sea around the island.
  - Revalidated headless scene load without parse errors after the shader/material/camera retune.
- Risks:
  - This pass fixes the obvious mud-plate / invisible-sea problem structurally, but the exact final beauty still depends on an in-editor eyeball check because the scene is shot-oriented.
- Next:
  - Reopen E:\山河志风起汉末\scenes\tree_test_love_app.tscn, press 1 or F to reset the new preset, and if the island still feels too large, shrink only the island mask while keeping the now-visible blue sea.
## 2026-03-25 23:35 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Revalidate the latest Chinese-text recovery on runtime data files and restore main-scene stability without widening scope.
- Done:
  - Re-read `docs/codex/PROJECT_MEMORY.md`, `docs/codex/TASK_BOARD.md`, and the latest `docs/codex/SESSION_HANDOFF.md` entry per repo bootstrap rules.
  - Revalidated `data/config/officer_roster_san14_like_v1.json` and `data/config/world_state.json` as UTF-8 JSON after the previous repair batch.
  - Recovered `data/config/officer_roster_san14_like_v1.json` from the broken working-copy state and kept only the confirmed semantic fix `zhongyao -> 閽熺箛`.
  - Reduced `data/config/world_state.json` to 8 semantic changes only: `鏇归瓘 -> 榄廯, `铚€姹?-> 铚€`, `绮句簬绛瑰垝 -> 绮句簬绛栧垝`, `鍐涚邯娓呮暣 -> 鍐涚邯鏁磋們`, `璐圭 -> 娉曟`, `鏉冭皨绋虫斂 -> 鏉冭皨鍠勬斂`, `绛瑰垝缁熺 -> 绛栧垝缁熺`, `鍓戦榿鍧炲牎 -> 鍓戦榿鍫.
  - Repaired `scripts/presentation/china_terrain_scene.gd` enough to restore `res://scenes/china_terrain_30km.tscn` headless loading again by fixing the corrupted `special_troop_unlock` block indentation and restoring broken asset paths at the weather/nature constants.
  - Revalidated `res://scenes/china_terrain_30km.tscn` headlessly; current run exits cleanly again.
- Risks:
  - `scripts/presentation/china_terrain_scene.gd` still contains a larger pre-existing mixed diff (including English text replacements and other runtime tweaks) that was not normalized in this pass; only the parse/path blockers were fixed.
  - `scripts/engine/strategy_bootstrap.gd` still has an independent parse issue when loaded by the generic parse probe (`Expected closing "]" after array elements.` at line 41); this did not block the user-designated `ChinaTerrain30km` validation scene and was left out of scope for this recovery pass.
- Next:
  - Isolate the intended `special_troop_unlock` gameplay change in `scripts/presentation/china_terrain_scene.gd`, revert unrelated language/translation noise in that file to match the Chinese-preservation policy, then separately inspect `scripts/engine/strategy_bootstrap.gd:41`.
## 2026-03-25 23:47 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Close the first-batch special troop unlock loop for the expedition panel without reopening broader UI layout work.
- Done:
  - Kept the new expedition special-troop unlock path parse-clean in `scripts/presentation/strategy_ui_layer.gd`, `scripts/engine/strategy_bootstrap.gd`, and `scripts/presentation/china_terrain_scene.gd`.
  - Tightened `strategy_ui_layer.gd` expedition visibility handling so the special-troop unlock button is force-hidden only when the expedition panel closes, and normal refresh logic owns re-showing it.
  - Extended `tmp/_tmp_verify_expedition_flow_contract.gd` so the expedition contract now also checks the special-troop unlock signal, UI handler, UI apply hook, bootstrap unlock handler, and unlock persistence write.
  - Added `tmp/_tmp_verify_special_troop_unlock_ui.gd` to verify the expedition UI-side unlock loop: button visible before unlock, signal payload emitted, officer unlock state flips immediately, selected base troop auto-activates the special troop, and the unlock button hides afterward.
  - Revalidated with `res://tmp/_tmp_verify_expedition_parse.gd`, `res://tmp/_tmp_verify_expedition_flow_contract.gd`, and `res://tmp/_tmp_verify_special_troop_unlock_ui.gd`; all passed.
- Risks:
  - This pass validates the UI/helper contract and parse state, but not a full editor-clicked end-to-end run inside the actual scene; one manual in-editor expedition unlock click is still worth doing.
  - `docs/codex/TASK_BOARD.md` now includes the unlock loop in Done, but the board still contains older duplicated battle-report placeholders that were already present before this pass.
- Next:
  - Manually click one expedition special-troop unlock in `res://scenes/china_terrain_30km.tscn` and confirm the deducted money / tech_points / command_points match the config cost in the live runtime HUD.
## 2026-03-25 17:42 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Make the love-app scene obviously readable as white sand plus blue sea, and switch runtime camera to free-camera controls.
- Done:
  - Rewrote E:\ɽ��־����ĩ\scripts\shaders\tree_test_curved_beach.gdshader to an unshaded bright white-sand island so it stays visibly pale instead of reading as muddy under sunset lighting.
  - Rewrote E:\ɽ��־����ĩ\scripts\shaders\tree_test_curved_ocean.gdshader to an unshaded high-visibility blue/cyan sea so the water stays clearly visible against the sunset background.
  - Tightened both water/sand island masks in E:\ɽ��־����ĩ\scenes\tree_test_love_app.tscn to Vector2(560, 180) so the sand footprint better matches the actual I-heart-U tree layout.
  - Switched PreviewCamera in E:\ɽ��־����ĩ\scenes\tree_test_love_app.tscn from the touch preset camera to es://scripts/presentation/tree_test_free_camera.gd and tuned defaults for a freer runtime view.
  - Lowered WaterMesh further to improve visible sea-vs-island separation.
  - Headless validation still reports no parse errors for es://scenes/tree_test_love_app.tscn after the rewrite.
- Risks:
  - The user screenshot was from the editor viewport, not necessarily the runtime camera, so runtime free-camera behavior needs an in-editor play check.
- Next:
  - Reopen and run E:\ɽ��־����ĩ\scenes\tree_test_love_app.tscn; if the sand is still too large in editor view, shrink only the island mask further rather than changing the ocean again.
## 2026-03-25 17:49 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Replace noisy whole-roster tuning with a higher-sample focused probe on the four officers that matter most for the intended top-tier shape.
- Done:
  - Ran 	ools\balance\run_unique_skill_tier_probe.ps1 for caocao, liubei, zhugeliang, and zhouyu only, using -Matches 7 -MaxSimSec 120 -TimeScale 8.
  - Generated the focused report bundle under E:\山河志风起汉末\tmp\reports\unique_skill_probe_20260325_174220.
  - High-sample snapshot now shows liubei as clearly overtuned (7/7, score 1.000), caocao still firmly top tier (7/7, score  .951), zhugeliang around upper-middle / low-top (4/7, score  .438), and zhouyu clearly undertuned in the current configuration (1/7, score -0.200).
- Risks:
  - This confirms the previous full-roster -Matches 3 runs were too noisy to trust for final top-tier ordering.
  - Any next balance pass should change only the top-tier candidates first; touching the whole roster again would just reintroduce noise.
- Next:
  - Do a focused fourth pass: heavily nerf liubei, strongly buff zhouyu, lightly buff zhugeliang, keep caocao nearly unchanged, then re-run the same 4-officer -Matches 7 check before touching the rest of the roster.
## 2026-03-25 23:56 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Clear the independent parse blockers in `scripts/engine/strategy_bootstrap.gd` without widening gameplay scope.
- Done:
  - Repaired the malformed supply-fog keyword arrays at `strategy_bootstrap.gd:41-43`.
  - Repaired the malformed expedition/regroup/siege text lines and ship-label option rows enough for the bootstrap script to parse again.
  - Revalidated the generic parse probe `res://tmp/_codex_parse_check.gd`; it now reports `bootstrap_script_ok=true` and `ui_script_ok=true`.
  - Revalidated `res://scenes/china_terrain_30km.tscn` headlessly again after the bootstrap fixes; current run still exits cleanly.
- Risks:
  - `scripts/engine/strategy_bootstrap.gd` still contains historical mixed-encoding text in several non-blocking strings; this pass only cleared syntax blockers and the most obvious malformed rows.
  - `scripts/presentation/china_terrain_scene.gd` still has a broader mixed diff outside the parser/path fixes from the previous pass; that cleanup remains a separate narrowing task.
- Next:
  - Do a dedicated text-normalization pass for `strategy_bootstrap.gd` and `china_terrain_scene.gd`, keeping valid Chinese source text and only fixing mojibake / broken strings in small verified batches.
## 2026-03-25 17:59 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Make the love-app scene read as endless blue sea + warm yellow sand + lower yolk-like sunset with stronger dusk clouds.
- Done:
  - Rewrote E:\ɽ��־����ĩ\scripts\shaders\tree_test_curved_ocean.gdshader to a stronger blue/cyan endless-sea look with horizon brightening driven by view angle.
  - Rewrote E:\ɽ��־����ĩ\scripts\shaders\tree_test_curved_beach.gdshader to a warmer yellow-sand palette instead of the previous over-white beach.
  - Rewrote E:\ɽ��־����ĩ\scripts\shaders\tree_test_sunset_sky_dome.gdshader to a purple-pink dusk gradient, stronger cloud streaks, and a lower less-blinding yolk-like sun.
  - Reduced the active island mesh in E:\ɽ��־����ĩ\scenes\tree_test_love_app.tscn from a huge plane to 1400 x 520, so the beach is now a compact island rather than a giant white plate.
  - Disabled scene fog, lowered sun light energy, raised the island slightly above the water, and moved the water closer to the island surface so the ocean should read more clearly.
  - Kept PreviewCamera on the free-camera script and changed the default view to a lower, more horizon-facing angle.
- Risks:
  - The editor viewport grid can still visually compete with the ocean in edit mode; runtime look is the real target to judge.
- Next:
  - Reopen and run E:\ɽ��־����ĩ\scenes\tree_test_love_app.tscn; if the island is now correct but the sun still sits too high, lower only sun_direction in the sky-dome shader a little more.
## 2026-03-26 00:10 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Do one safe small batch on `scripts/engine/strategy_bootstrap.gd`, limited to visible mojibake UI/status text only.
- Done:
  - Rewrote the current regroup / expedition / siege summary text rows in `strategy_bootstrap.gd` as clean Chinese equivalents, without changing the surrounding control flow.
  - Kept scope away from gameplay logic and resource-path restoration in this pass.
- Risks:
  - The repository currently also has independent parse blockers outside this file, especially `scripts/battlefield_controller.gd:207` and `scripts/presentation/strategy_ui_layer.gd:28-29`, so the generic parse probe is not globally clean right now.
  - Because Windows PowerShell is misreading UTF-8-no-BOM Chinese lines in some views, terminal display may still show mojibake even when the rewritten source bytes are correct; future cleanup should continue using explicit UTF-8 reads or in-editor verification.
- Next:
  - Safest next batch is either fixing `strategy_ui_layer.gd:28-29` resource-path corruption or resolving the duplicate variable parse error in `battlefield_controller.gd:207`, then rerunning the generic parse probe.
## 2026-03-25 18:19 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Recover the love-app scene from the flat-color fallback and move it back toward a realistic transparent Maldives-water presentation with warmer dusk and redder sakura blossoms.
- Done:
  - Rewrote E:\ɽ��־����ĩ\scripts\shaders\tree_test_curved_ocean.gdshader back to a lit transparent water shader with fresnel/glints and turquoise shallow-water layering instead of the flat unshaded blue fallback.
  - Re-enabled LagoonFloorMesh in E:\ɽ��־����ĩ\scenes\tree_test_love_app.tscn and dropped it below the water surface so transparent water now has a visible shallow-sea floor to read against.
  - Switched the scene environment background to a dark clear color (ackground_mode = 1) so the custom SkyDome shader is no longer visually overridden by the default sky background.
  - Rewrote E:\ɽ��־����ĩ\scripts\shaders\tree_test_sunset_sky_dome.gdshader to a warmer dusk gradient with stronger glow/streak clouds and a more visible low sun.
  - Retinted E:\ɽ��־����ĩ\scenes\prefabs\vegetation\sakura_tree_a_cinematic.tscn so sakura blossoms push back toward red-pink instead of the previous desaturated tone.
  - Kept the smaller island footprint and free camera controls while preserving headless scene load with no parse errors reported.
- Risks:
  - The exact ocean beauty still depends on how the transparent water, lagoon floor, and sky read together in-editor/runtime; this pass fixes the structural layering but may still need one more art tuning pass.
- Next:
  - Reopen and run E:\ɽ��־����ĩ\scenes\tree_test_love_app.tscn; if the water is now readable but still not tropical enough, tune only water alpha/deep-vs-lagoon color and sun height rather than reverting back to flat-color fallbacks.
## 2026-03-25 18:26 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Retune Liu Bei so his unique skill reads as a healer/support skill instead of a broad all-purpose cleanse aura.
- Done:
  - Confirmed the intended runtime hook is morale_recover_cleanse in E:\山河志风起汉末\scripts\battlefield_controller.gd, and designed the Liu Bei pass around light HP recovery + weaker morale/spirit support + narrower cleanse.
  - Rebuilt E:\山河志风起汉末\data\config\unique_skills_v1.json from HEAD baseline and set Liu Bei to a healer-support profile: longer cooldown, lower proc chance, lighter morale/spirit, cleanse_confusion, plus lly_hp_recover_ratio / lly_hp_recover_flat.
- Risks:
  - E:\山河志风起汉末\scripts\battlefield_controller.gd in this worktree has broader historical encoding corruption in early constant sections; headless validation still fails before the runtime can confirm the new Liu Bei HP-recovery hook.
  - I stopped short of doing a blind full-file rewrite because that file also carries other nontrivial local changes from this branch and would be risky to overwrite casually.
- Next:
  - Fix attlefield_controller.gd by restoring the broken early constant/string blocks from a known-good source first, then reapply the minimal Liu Bei healer-support runtime hook and rerun the unique-skill verifier.
## 2026-03-25 18:30 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Move special troop unlock entry out of expedition UI and into the city technology panel without widening gameplay scope.
- Done:
  - Re-read `docs/codex/PROJECT_MEMORY.md`, `docs/codex/TASK_BOARD.md`, and the latest `docs/codex/SESSION_HANDOFF.md` block before edits.
  - Repaired `scripts/presentation/strategy_ui_layer.gd` parse blockers caused by broken resource-path constants and restored the missing aide pending-change helper alias.
  - Kept expedition-side unlock UI hidden in `strategy_ui_layer.gd`; unlock state now remains a shared UI update path through `apply_special_troop_unlock(...)`.
  - Added runtime `technology` panel routing in `scripts/presentation/china_terrain_scene.gd` via `_build_site_panel_data(...) -> _build_runtime_technology_panel_data(...)`.
  - Changed runtime special-troop unlock handling in `scripts/presentation/china_terrain_scene.gd` to resolve city data from the technology panel and refresh UI through `apply_special_troop_unlock(...)` when available.
  - Updated `scripts/engine/strategy_bootstrap.gd` unlock callback to prefer `apply_special_troop_unlock(...)` over the expedition-only compatibility method.
  - Partially cleaned independent mojibake parse blockers in `scripts/battlefield_controller.gd` (resource paths / malformed constants), but did not finish that legacy cleanup.
- Risks:
  - Full headless scene validation is still blocked by remaining historical parse errors in `scripts/battlefield_controller.gd`; current blocker had advanced to around the commander-portrait helper / constant area during this pass.
  - `scripts/presentation/china_terrain_scene.gd` technology-panel path is implemented, but could not be end-to-end headless-validated because of the unrelated `battlefield_controller.gd` preload failure.
  - `scripts/engine/strategy_bootstrap.gd` still does not have a dedicated technology-panel opener; the real user runtime path is `china_terrain_scene.gd`, which was the scoped priority for this task.
- Next:
  - Finish isolating / cleaning the remaining parse blockers in `scripts/battlefield_controller.gd`, then rerun headless checks for `strategy_ui_layer.gd`, `china_terrain_scene.gd`, and the real main scene to confirm the technology-panel unlock flow works end to end.
## 2026-03-25 19:23 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Follow the user's simpler direction: treat the ocean as a cyan-transparent sea mask first, instead of overcomplicating the scene with failed realism attempts.
- Done:
  - Simplified E:\ɽ��־����ĩ\scripts\shaders\tree_test_curved_ocean.gdshader to a clearer blue-cyan transparent ocean mask with only light ripple/fresnel shaping.
  - Restored E:\ɽ��־����ĩ\sky_assets\sunset_procedural_sky.tres as the active world sky and switched E:\ɽ��־����ĩ\scenes\tree_test_love_app.tscn back to ackground_mode = 2 so the scene no longer falls back to the dark manual background.
  - Kept LagoonFloorMesh visible to preserve shallow-water readability under the transparent ocean.
  - Lowered the water/floor stack and hid SkyDome to stop it from fighting the background sky.
- Risks:
  - This pass intentionally favors obvious readability over complex realism; it is a staging point, not the final romance-grade ocean.
- Next:
  - Reopen and run E:\ɽ��־����ĩ\scenes\tree_test_love_app.tscn; if this makes the ocean readable again, do one follow-up polish pass only on tropical tint / transparency / sunset warmth.
## 2026-03-25 19:45 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix the missing sky/sun regression in the isolated love-app scene and verify whether the user's run path was being blocked by an unrelated project parse error.
- Done:
  - Fixed the malformed SkyDome node lines in E:\ɽ��־����ĩ\scenes\tree_test_love_app.tscn so isible and position are now separate valid properties again.
  - Confirmed the scene still carries both a WorldEnvironment sky and a visible SkyDome, but the user's screenshot also shows an unrelated parse failure from es://scripts/battlefield_controller.gd, which can interrupt full-project play.
- Risks:
  - If the user presses full project Run instead of current scene Run, the unrelated attlefield_controller.gd parse error can still prevent a clean preview of the isolated love-app scene.
- Next:
  - Advise the user to run 	ree_test_love_app.tscn as the current scene (F6 / Run Current Scene) and only fix the unrelated attlefield_controller.gd parse error if they want full-project play restored too.
## 2026-03-25 20:35 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Unblock `china_terrain_scene.gd` / `strategy_bootstrap.gd` by clearing the remaining parse/load blockers in `scripts/battlefield_controller.gd`, while keeping the earlier technology-panel special-troop move intact.
- Done:
  - Reconstructed the missing unique-skill dispatcher in `E:\山河志风起汉末\scripts\battlefield_controller.gd` via `_execute_unique_skill(...)`, replacing a corrupted orphan `match` fragment near the unique-skill helpers.
  - Surgically cleared a long chain of mojibake-caused syntax blockers in `E:\山河志风起汉末\scripts\battlefield_controller.gd`, mainly broken quoted strings in commander HUD text, siege objective overlays, reward reports, unit-tag dialogue bubbles, facility labels, and battle report templates.
  - Restored the broken Brackeys VFX preload base path at the top of `E:\山河志风起汉末\scripts\battlefield_controller.gd` from the corrupted prefix to the real on-disk asset path `res://素材/brackeys_vfx_bundle/...`.
  - Headless validation now passes for the bootstrap parse chain: `res://tmp/_codex_parse_check.gd` reports `bootstrap_script_ok=true` and `ui_script_ok=true`, and `res://tmp/_tmp_verify_expedition_parse.gd` reports `LOAD_OK` for both `strategy_ui_layer.gd` and `china_terrain_scene.gd`.
- Risks:
  - Many user-facing battle strings in `scripts/battlefield_controller.gd` were replaced with short English placeholders during parse recovery; text quality/localization is not final.
  - This pass focused on parse/load recovery, not full runtime combat behavior verification; unique-skill execution and battle report wording still need an in-scene sanity pass.
- Next:
  - Open the real scene and verify the runtime chain end-to-end: city technology panel opens, special-troop unlock still works from technology (not expedition), and battle scene / RTS HUD no longer fail on `battlefield_controller.gd` preload.
## 2026-03-25 20:03 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Finish the Liu Bei healer-support pass after the user repaired the battlefield controller parse issues.
- Done:
  - Verified E:\山河志风起汉末\scripts\battlefield_controller.gd parses again under headless Godot.
  - Kept Liu Bei's config in E:\山河志风起汉末\data\config\unique_skills_v1.json as a healer-support skill: longer cooldown, lower proc chance, lighter morale/spirit support, cleanse_confusion, plus light HP recovery.
  - Updated morale_recover_cleanse runtime in E:\山河志风起汉末\scripts\battlefield_controller.gd to actually apply lly_hp_recover_ratio / lly_hp_recover_flat.
  - Changed the auto-cast rule for morale_recover_cleanse to prefer low-HP ally rescue instead of broad old morale/slow cleanse conditions.
  - Normalized the broken VFX preload path constants at the top of attlefield_controller.gd so headless script loading works again.
  - Revalidated with E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\山河志风起汉末 -s res://tmp/_tmp_verify_unique_skills.gd and ran a Liu Bei smoke probe; latest report bundle is E:\山河志风起汉末\tmp\reports\unique_skill_probe_20260325_200229.
- Risks:
  - The smoke probe is only 1 match, so this confirms runtime integrity and general behavior, not final balance.
  - Some top-of-file resource/path constants in attlefield_controller.gd were normalized to stable parseable values during recovery; if you want those exact display/resource strings restored artistically, do it in a separate cleanup pass.
- Next:
  - Run a focused -Matches 5 or -Matches 7 comparison on liubei, caocao, zhugeliang, and zhouyu again to see whether the healer-support conversion lowers Liu Bei's stable ranking enough.
## 2026-03-25 20:29 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Remove the black upper sky by replacing the unreliable physical sky setup with an explicit dusk procedural sky.
- Done:
  - Replaced E:\ɽ��־����ĩ\sky_assets\sunset_procedural_sky.tres with a ProceduralSkyMaterial resource that sets explicit sky/ground colors and sun color/size, so the upper half of the sky no longer depends on dark defaults.
  - Revalidated headless loading of es://scenes/tree_test_love_app.tscn with no sky parse errors reported.
- Risks:
  - The user is viewing through the editor while the error panel is open, so visual judgment can still be noisy until they rerun the current scene after reloading the updated sky resource.
- Next:
  - Reopen E:\ɽ��־����ĩ\scenes\tree_test_love_app.tscn and run current scene again; if the sky is visible but not rosy enough, tune only the procedural sky colors next.
## 2026-03-25 20:42 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Continue the focused top-tier balance pass by pushing Liu Bei down further and bringing Zhou Yu up toward the intended first-tier band.
- Done:
  - Rebuilt E:\山河志风起汉末\data\config\unique_skills_v1.json from HEAD baseline again and safely applied the current full value set.
  - Further nerfed Liu Bei's healer-support profile: longer cooldown, lower proc chance, lower morale/spirit support, lower HP recovery amount, and a stricter low-HP trigger threshold.
  - Clearly buffed Zhou Yu's fire skill: shorter cooldown, higher proc chance, larger area, stronger initial burst, stronger burn, longer burning duration, slightly stronger confusion, and a lower minimum enemy-count trigger.
  - Revalidated with headless Godot and reran the focused caocao / liubei / zhugeliang / zhouyu -Matches 7 probe.
  - Latest focused bundle is E:\山河志风起汉末\tmp\reports\unique_skill_probe_20260325_203622; result is now caocao first (7/7), zhugeliang and zhouyu both 4/7, and liubei down to 3/7.
- Risks:
  - caocao still stands noticeably above the rest, so if the final target is a tighter three-way top tier, he may eventually need a very small trim or the other two need a final small bump.
  - This pass intentionally over-corrected Liu Bei downward to confirm that the healer conversion can stop him from dominating; if you want him a little stronger than 3/7, the next adjustment should be very small.
- Next:
  - Either lock this snapshot as the new top-tier baseline, or do one last micro pass: tiny buff to Liu Bei or tiny buff to Zhou Yu / Zhuge Liang depending on the exact flavor you want.
## 2026-03-25 20:49 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Keep a single `Attack` axis in expedition radar and make the water-side number after `/` visually blue.
- Done:
  - Updated `E:\山河志风起汉末\scripts\ui\expedition_radar_chart.gd` so radar axis labels are drawn in split segments instead of one flat string.
  - Kept the label name and land value in the default gold tone, while drawing the water-side value after `/` with `WATER_LABEL_COLOR` to match the blue naval overlay.
  - Left the expedition radar axis set unchanged (`Attack / Defense / Tactics / Mobility / Siege / Command`), so the UI still uses one attack axis as requested.
  - Re-ran lightweight headless checks for the expedition UI parse chain after the change with no new parse failures.
- Risks:
  - This pass only changes label rendering color, not the underlying land/water stat formulas.
- Next:
  - If the user accepts the color split, adjust the expedition stat model next: decide whether to keep single defense or split physical/magic defense while still keeping a single attack axis.
## 2026-03-25 21:05 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Close the focused player-facing battle-report pass by rechecking the new commander-report hooks and validating the real main scene.
- Done:
  - Re-read `E:\ɽ��־����ĩ\docs\codex\PROJECT_MEMORY.md`, `E:\ɽ��־����ĩ\docs\codex\TASK_BOARD.md`, and the latest `E:\ɽ��־����ĩ\docs\codex\SESSION_HANDOFF.md` block before touching scope.
  - Rechecked the battle-report functions in `E:\ɽ��־����ĩ\scripts\battlefield_controller.gd`: `_format_battle_reward_delta(...)`, `on_unit_defeated(...)`, `on_site_captured(...)`, `report_commander_runtime_event(...)`, `report_commander_site_victory(...)`, and `_report_demo_facility_destroyed(...)`.
  - Confirmed the new player-facing report path stays scoped to player-related combat events and uses clearer win/loss wording plus bottom commander dialogue triggers.
  - Revalidated lightweight parse loading with `godot.windows.opt.tools.64.exe --headless --path E:\ɽ��־����ĩ -s res://tmp/_codex_parse_check.gd`.
  - Revalidated the user-designated main gameplay scene with `godot.windows.opt.tools.64.exe --headless --path E:\ɽ��־����ĩ --quit --scene res://scenes/china_terrain_30km.tscn`.
- Risks:
  - `E:\ɽ��־����ĩ\scripts\battlefield_controller.gd` still has many unrelated historical diffs in this worktree; this pass only confirms the battle-report slice is stable, not that the whole file is ready for a broad cleanup.
  - `report_commander_runtime_event(...)` currently filters to player team only (`team_id == 0`), which matches the active task goal but could be expanded later if you want enemy-side narration too.
- Next:
  - Do a live in-editor combat smoke test on `E:\ɽ��־����ĩ\scenes\china_terrain_30km.tscn` and check four cases: player kills a unit, player loses a unit, player captures a site, player loses a site; if any line feels noisy, only tune wording/priority rather than reopening combat logic.
## 2026-03-25 20:52 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Make the isolated love-app scene easier to frame by opening up the camera, removing the distracting center blue patch, and reshaping the island into a more natural rounded form.
- Done:
  - Rewrote E:\ɽ��־����ĩ\scripts\presentation\tree_test_free_camera.gd for a freer orbit camera: farther max zoom, shallower default pitch for seeing the distance, and vertical camera movement on R / C while keeping WASD, right-drag, wheel zoom, Q/E, and F reset.
  - Retuned E:\ɽ��־����ĩ\scripts\shaders\tree_test_curved_ocean.gdshader to a more opaque cyan-turquoise sea so the view reads as ocean instead of black through transparency.
  - Retuned E:\ɽ��־����ĩ\scripts\shaders\tree_test_curved_beach.gdshader so the island mask is more rounded and irregular rather than a flat elongated oval.
  - Updated E:\ɽ��־����ĩ\scenes\tree_test_love_app.tscn to use the new camera defaults, enlarge the island plane to support the rounder mask, and hide LagoonFloorMesh so the distracting center blue patch is gone.
- Risks:
  - The scene still uses a highly stylized quick-look ocean/sky stack; if the user wants a final romance-grade shot, one more art-only pass on colors and sunset warmth will still help.
- Next:
  - Reopen and run E:\ɽ��־����ĩ\scenes\tree_test_love_app.tscn, verify the blue patch is gone and the camera can see farther, then do a final beauty-only pass if the composition is accepted.
## 2026-03-25 20:59 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Do a focused second-tier / lower-tier balance pass after stabilizing the top tier.
- Done:
  - Ran a 9-officer middle/lower-band probe (simayi, zhangliao, liubei, guanyu, luxun, ganning, xiahoudun, zhangfei, sunquan) with -Matches 5, producing E:\山河志风起汉末\tmp\reports\unique_skill_probe_20260325_204910.
  - Applied a focused pass: nerfed liubei and sunquan, buffed simayi, zhangliao, guanyu, and ganning, then rebuilt data/config/unique_skills_v1.json from HEAD baseline safely.
  - Revalidated with headless Godot and reran the same 9-officer group at -Matches 3; latest bundle is E:\山河志风起汉末\tmp\reports\unique_skill_probe_20260325_205819.
- Risks:
  - The second-band probe became highly pool-sensitive: after the latest pass, zhangfei and xiahoudun spiked upward while guanyu, zhangliao, and ganning collapsed, which suggests this grouped probe is now measuring intra-pool matchup interactions more than stable global tier strength.
  - At this point, continuing broad whole-band tuning is likely to overfit to one probe composition.
- Next:
  - Treat the current top-tier snapshot as provisionally stable, then switch the rest of the roster to smaller role-based buckets or officer-vs-baseline micro probes instead of another large mixed middle-band probe.
## 2026-03-25 21:12 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Add a safe live-test checklist so the player-facing battle-report pass can be verified in-editor without widening runtime scope.
- Done:
  - Added `E:\ɽ��־����ĩ\docs\codex\BATTLE_REPORT_SMOKETEST_CHECKLIST.md`.
  - Scoped the checklist to `res://scenes/china_terrain_30km.tscn` and the active battle-report task only.
  - Covered six focused cases: player unit kill, player unit loss, player site capture, player site loss, player supply runtime event, and player facility destroy/loss.
  - Added pass/fail rules plus a short notes template so the next live test can be recorded consistently.
- Risks:
  - This is a manual smoke checklist only; it does not replace a real live combat pass in the editor.
  - If the scenario setup cannot reliably trigger supply or facility cases, those two items may need a more controlled repro scene later.
- Next:
  - Run the checklist in `E:\ɽ��־����ĩ\scenes\china_terrain_30km.tscn`, then tune only battle-report wording/priority for any failed case.
## 2026-03-25 21:32 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Change regroup-layer siege equipment from batch-100 to single-item semantics without touching other troop classes.
- Done:
  - Updated `E:\ɽ��־����ĩ\data\config\regroup_rules.json` so `ram`, `ladder`, and `catapult` now use `batch_size = 1` while the global `default_batch_size = 100` remains unchanged for normal troops.
  - Updated `E:\ɽ��־����ĩ\scripts\presentation\strategy_ui_layer.gd` regroup UI to read siege durability panel data, show siege entries as `Unit 1` instead of `Batch 100`, and keep preview amount text aligned with total selected amount.
  - Updated regroup amount slider logic for siege units so the step is 1 and the max value follows remaining siege durability capacity instead of reserve troop count.
  - Fixed regroup preview bookkeeping so siege selections no longer consume reserve troop preview totals; only normal troops affect reserve/organized troop preview.
  - Revalidated parse integrity with `godot.windows.opt.tools.64.exe --headless --path E:\ɽ��־����ĩ -s res://tmp/_codex_parse_check.gd` and got `bootstrap_script_ok=true`, `ui_script_ok=true`.
- Risks:
  - This pass only changes regroup-layer batching and UI preview semantics; it does not refactor the broader battle/runtime siege model.
  - Siege cost is still using the existing per-item resource values from config; if you want each single siege engine to cost more like an old batch-equivalent, that should be tuned separately.
- Next:
  - Open the real regroup panel in `res://scenes/china_terrain_30km.tscn` and verify three cases: siege slider steps by 1, normal troop slider still steps by 100, and siege preview no longer reduces reserve troop count.
## 2026-03-25 21:07 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Stop further fine-grained probe chasing and consolidate the current core-12 unique-skill package into one readable overall snapshot.
- Done:
  - Added E:\山河志风起汉末\docs\balance\core12_unique_skills_snapshot_20260325.md, summarizing the 12 officer unique skills by tier, role, current cooldown/proc values, and current lock-in recommendation.
  - Kept the overall recommendation as: top tier caocao / zhugeliang / zhouyu, second tier simayi / guanyu / liubei / luxun / zhangliao / ganning, third tier xiahoudun / zhangfei / sunquan.
  - Revalidated the current unique-skill config/runtime package with the headless verifier after writing the summary doc.
- Risks:
  - The mixed middle-band probe remains interaction-sensitive, so the second/third-tier edge is still a practical snapshot, not a mathematically final truth.
- Next:
  - Use the summary doc as the current design baseline and shift effort into skill presentation, tooltip text, and live battle feel instead of more probe-only tuning.
## 2026-03-25 21:28 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Start the next safe gameplay-logic point by polishing low-risk unique-skill auto-cast targeting/trigger behavior instead of reopening broad balance tuning.
- Done:
  - Updated `E:\ɽ��־����ĩ\scripts\battlefield_controller.gd` target selection for unique skills so auto-cast now scores in-range enemies instead of always defaulting to the nearest unit.
  - Added lightweight target preferences that finally honor existing config intent for safe cases: tactician focus, ranged/backline focus, fire-skill cluster focus, burning-target preference, and dash-skill preference for ranged/strategist targets.
  - Tightened `_should_auto_cast_unique_skill(...)` for `area_control_zone`, `area_fire_burst`, and `chain_fire_spread` so these skills check cluster size / weather / burning-target rules more explicitly instead of using one broad generic condition.
  - Fixed the `chain_fire_spread` hit loop boundary so `spread_count` no longer over-hits by one target.
  - Revalidated with `godot.windows.opt.tools.64.exe --headless --path E:\ɽ��־����ĩ -s res://tmp/_codex_parse_check.gd`, `res://tmp/_tmp_verify_unique_skills.gd`, and `--quit --scene res://scenes/china_terrain_30km.tscn`.
- Risks:
  - This pass improves target choice and trigger discipline, but it does not rebalance the actual skill numbers; officer strength rankings may still need later probe-based tuning.
  - Main-scene headless load still prints existing material-remap warnings from `tree_batch_light_tuner.gd`; they did not block this validation pass.
- Next:
  - Run a focused live or probe check on Zhou Yu / Lu Xun / Zhang Liao / Gan Ning to confirm the smarter target choice makes fire/assault skills trigger on better targets before doing any new value tuning.
## 2026-03-26 00:06 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Unify the wording style for the core-12 unique skill descriptions and refresh the current summary snapshot to match.
- Done:
  - Rebuilt E:\山河志风起汉末\data\config\unique_skills_v1.json from HEAD baseline again and rewrote all 12 desc fields into one consistent style: one-sentence battlefield-facing descriptions with clear role intent.
  - Preserved the current accepted balance snapshot while rewriting the copy, including Liu Bei healer-support, Zhou Yu fire-burst, and the current tier layout.
  - Rewrote E:\山河志风起汉末\docs\balance\core12_unique_skills_snapshot_20260325.md so the summary doc now uses the same unified wording style as the config.
  - Revalidated the unique-skill package with the headless verifier after the wording pass.
- Risks:
  - The PowerShell console still displays Chinese as mojibake in this environment, but the files are rewritten in UTF-8 and the runtime validator passes.
- Next:
  - If desired, continue with the next presentation-layer pass: battle tooltip text, skill cast banner wording, or skill-specific VFX/readability polish.
## 2026-03-26 09:56 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Follow up the unique-skill auto-cast polish with a focused verification pass on Zhou Yu / Lu Xun / Zhang Liao / Gan Ning, and only fix something if a clear low-risk runtime issue showed up.
- Done:
  - Re-read `E:\ɽ��־����ĩ\docs\codex\PROJECT_MEMORY.md`, `E:\ɽ��־����ĩ\docs\codex\TASK_BOARD.md`, and the latest `E:\ɽ��־����ĩ\docs\codex\SESSION_HANDOFF.md` block before continuing.
  - Reused `E:\ɽ��־����ĩ\tools\balance\run_unique_skill_tier_probe.ps1` and ran a focused 4-officer probe for `zhouyu`, `luxun`, `zhangliao`, and `ganning`; output bundle is `E:\ɽ��־����ĩ\tmp\reports\unique_skill_probe_20260326_094719`.
  - Observed that this focused probe was still extremely harsh / pool-sensitive (all four ended 0/5 in that run), so I did not do a blind balance-value retune from one noisy sample.
  - Found and removed an unreachable duplicate branch block in `E:\ɽ��־����ĩ\scripts\battlefield_controller.gd` inside `_execute_unique_skill(...)`, leaving a single clean dispatcher path.
  - Revalidated with `godot.windows.opt.tools.64.exe --headless --path E:\ɽ��־����ĩ -s res://tmp/_codex_parse_check.gd`, `res://tmp/_tmp_verify_unique_skills.gd`, and `--quit --scene res://scenes/china_terrain_30km.tscn`.
- Risks:
  - The 4-officer probe result is useful as a warning sign, but not yet reliable enough to justify direct cooldown/proc rebalance by itself.
  - The current probe only reports match outcomes, not actual unique-skill cast counts or target-quality telemetry, so it still cannot prove whether weak results come from poor casts, bad matchups, or broader role/pool issues.
- Next:
  - If continuing this branch, add lightweight probe telemetry for unique-skill cast success / cast count / target role hit in `tmp/` or run a short live combat smoke on these four officers before any new number tuning.
## 2026-03-26 10:18 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Set up an isolated web-delivery path for `E:\山河志风起汉末\scenes\tree_test_love_app.tscn` so the user can publish it as a shareable webpage without changing the main game runtime.
- Done:
  - Added `E:\山河志风起汉末\.github\workflows\love_web_pages.yml` to download Godot 4.6.1 editor + export templates in CI, patch the entry scene for CI only, export the `Web` preset, and deploy the result to GitHub Pages.
  - Added `E:\山河志风起汉末\export_presets.cfg` with a focused Web preset for the isolated love scene delivery path.
  - Added `E:\山河志风起汉末\tools\export\prepare_love_web.py` so CI rewrites `run/main_scene` to `res://scenes/tree_test_love_app.tscn` without permanently changing the local project entry.
  - Updated `E:\山河志风起汉末\deliverables\tree_test_love_app\README.md` with the GitHub Pages publishing steps and file references.
  - Validated that the new `Web` preset is recognized by local Godot 4.6.1; the current local export blocker remains missing templates under `C:\Users\Admin\AppData\Roaming\Godot\export_templates\4.6.1.stable\web_nothreads_*.zip`.
- Risks:
  - The repository currently imports/scans a very large asset set, so the first GitHub Actions web build may be slow and could need one follow-up pass if import time or artifact size is too high.
  - This repo currently has only a Gitee remote; GitHub Pages will not exist until the repository is mirrored or pushed to GitHub and Pages/Actions are enabled there.
  - Local Windows export is still blocked by missing local Web export templates even though CI will download its own templates.
- Next:
  - Mirror this repository to GitHub, enable Pages from GitHub Actions, then push `main`/`master` or run the `Love Web Pages` workflow once to get the shareable URL.
## 2026-03-26 10:05 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Add lightweight unique-skill telemetry to the temporary probe path so the next validation round can distinguish ��did not cast�� from ��casted but underperformed��.
- Done:
  - Extended `E:\ɽ��־����ĩ\tmp\_tmp_unique_skill_tier_probe.gd` to record per-match unique-skill telemetry based on famous-skill cooldown transitions for team 0 units.
  - Added telemetry fields to each probe report: `casts_total`, `avg_casts_per_match`, `casts_without_target`, `burning_target_casts`, `casts_by_skill`, `casts_by_target_role`, and per-cast records.
  - Updated `E:\ɽ��־����ĩ\tools\balance\run_unique_skill_tier_probe.ps1` so the runner summary text now surfaces the new cast telemetry fields.
  - Revalidated the probe chain with `res://tmp/_tmp_verify_unique_skills.gd` and reran quick telemetry checks, including `E:\ɽ��־����ĩ\tmp\reports\unique_skill_probe_20260326_100105`, `E:\ɽ��־����ĩ\tmp\reports\unique_skill_probe_20260326_100232`, and the 4-officer sample `E:\ɽ��־����ĩ\tmp\reports\unique_skill_probe_20260326_100259`.
  - The new telemetry immediately exposed a meaningful split: in the 4-officer one-match sample, `zhangliao` cast 4 times and `ganning` cast 3 times, while `zhouyu` and `luxun` both cast 0 times.
- Risks:
  - The telemetry infers casts from cooldown rises, so it is good for cast-count debugging but still not a perfect semantic event trace.
  - The current quick sample sizes are intentionally tiny; use them to diagnose trigger behavior, not to lock final balance.
- Next:
  - Use the telemetry evidence to inspect why `area_fire_burst` / `chain_fire_spread` are not firing in these probe setups, then loosen only the trigger condition that is actually suppressing casts instead of buffing raw damage/cooldowns first.
## 2026-03-26 10:18 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Answer the user's rain-weather suspicion directly and relax the fire-weather rule so strategist `skyfire` and fire unique skills can still cast in rain instead of being hard-blocked.
- Done:
  - Confirmed the earlier zero-cast behavior was indeed strongly tied to rain gating: the project weather config already had `skyfire_castable_in_rain = true`, but runtime still hard-blocked fire tactics/unique skills and even blocked `apply_burn(...)` globally under rain.
  - Updated `E:\ɽ��־����ĩ\scripts\battlefield_controller.gd` weather helpers so `strat_skyfire` can cast in rain according to config, while rain applies the configured weaker damage / burn multipliers instead of a full ban.
  - Updated fire unique-skill runtime in `E:\ɽ��־����ĩ\scripts\battlefield_controller.gd` so `area_fire_burst` / `chain_fire_spread` can also cast in rain, again with rain fire-power / burn-duration / burn-dps multipliers rather than a hard block.
  - Updated fire auto-cast gating so strategist auto-cast no longer treats rain as a blanket fire prohibition when `skyfire` is rain-castable.
  - Updated `E:\ɽ��־����ĩ\scripts\unit_controller.gd` `apply_burn(...)` signature with an optional weather override flag, and routed rain-allowed skyfire / fire-unique applications through that path so rain no longer suppresses the burning state after a successful cast.
  - Updated the `strat_skyfire` tooltip text to say rain casting is allowed but weakened.
  - Re-ran focused telemetry probe for `zhouyu` and `luxun`; result bundle is `E:\ɽ��־����ĩ\tmp\reports\unique_skill_probe_20260326_101622`.
  - The rain-weather telemetry now clearly proves the fix is active: `Zhou Yu` cast 4 times with 4 burning-target casts and won his sample, while `Lu Xun` cast 2 times with 2 burning-target casts.
- Risks:
  - This pass intentionally relaxes rain restrictions only for strategist `skyfire` and fire unique-skill paths; normal `strat_fire_attack` remains rain-blocked unless you explicitly want that widened too.
  - Repository-wide parse validation is currently blocked by unrelated pre-existing script issues in `strategy_bootstrap.gd` and `china_terrain_scene.gd`; those blockers are outside this fire-weather change scope.
- Next:
  - If you want the same philosophy applied more broadly, decide whether standard strategist `strat_fire_attack` should also become rain-castable with reduced power, then do one more small weather-rule pass instead of touching raw balance values.
## 2026-03-26 00:18 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Continue the unique-skill presentation pass by unifying battle-facing runtime wording, not just the config descriptions.
- Done:
  - Rewrote unique-skill related battle UI/status text in E:\山河志风起汉末\scripts\battlefield_controller.gd into a unified Chinese wording style.
  - Covered the famous-skill mode toggle status, famous-skill unavailable / no-target / activated feedback, and the RTS panel tooltip/button wording for the unique-skill and skill-auto controls.
  - Kept the scope narrow to battle-facing unique-skill copy so ordinary movement/tactic messaging was not broadly disturbed.
  - Revalidated with the headless unique-skill verifier after the copy pass.
- Risks:
  - The surrounding runtime still contains many older English or mixed-language combat/status messages outside the unique-skill scope; those were intentionally left alone in this pass.
- Next:
  - If desired, continue with a second presentation pass focused on tactic-cast status text and battle-status phrasing so the full battle HUD reads in one consistent style.
## 2026-03-26 10:31 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Give the user a low-friction GitHub Pages enable/push path for the isolated love-scene web build without relying on the GitHub Settings page.
- Done:
  - Added `E:\山河志风起汉末\tools\export\enable_github_pages.ps1`, which enables or updates GitHub Pages for `jay-sunshine/iloveu` through the GitHub REST API using `build_type=workflow`.
  - Added `E:\山河志风起汉末\deliverables\tree_test_love_app\GITHUB_PAGES_QUICKSTART.md` with the exact remote-add, push, PAT, and trigger-build commands for this repository.
  - Parsed the PowerShell helper script locally to confirm the script syntax is valid.
- Risks:
  - The user still needs a GitHub PAT with repository admin/pages-related permission to enable Pages via API.
  - If GitHub access is unstable from the user network, the push/API steps may need retry or a VPN/proxy even though they avoid the web Settings UI.
- Next:
  - Run the commands from `E:\山河志风起汉末\deliverables\tree_test_love_app\GITHUB_PAGES_QUICKSTART.md`, then wait for the `Love Web Pages` workflow to publish `https://jay-sunshine.github.io/iloveu/`.
## 2026-03-26 10:36 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Finish the force-level grand-strategy (中枢) wiring so technology/special-troop unlocks are handled from a faction-wide menu instead of only city scope.
- Done:
  - Finished scripts/engine/strategy_bootstrap.gd force-menu flow: added 中枢 action list handlers, opened the faction technology panel from the new right-side shortcut, and added pooled faction-wide special-troop unlock validation/spending across player cities.
  - Updated scripts/presentation/strategy_ui_layer.gd technology payload emission so faction-scope unlocks now send scope_kind and source-city context instead of behaving like plain city unlocks.
  - Simplified the technology detail empty-state hint to avoid brittle scope inference in UI code.
  - Fixed the pending runtime scene break in scripts/presentation/china_terrain_scene.gd by aligning the player-faction technology panel call sites with the actual helper name.
  - Revalidated with headless parse check and china_terrain_30km.tscn scene load.
- Risks:
  - PowerShell still displays Chinese strings as mojibake in this shell, so visible text should be verified in-editor/in-game if any label looks off.
  - Non-technology 中枢 branches are still placeholders; only 军略 is functionally wired in this pass.
- Next:
  - Do an in-game click-through on 中枢 -> 军略 in both bootstrap and ChinaTerrain30km paths, then wire the next grand-strategy branch the player wants (铨叙 / 求贤 / 纵横 etc.).
## 2026-03-26 10:43 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - 统一普通战法提示文案、战斗状态栏 _set_battle_status 常用提示，以及战报/奖励播报文案，保持战斗 HUD 口径一致。
- Done:
  - 在 E:\山河志风起汉末\scripts\battlefield_controller.gd 统一了常用状态栏提示，包括攻击前进、移动/攻击/撤退命令、建造放置、侦察提示、战技/战法冷却与目标无效等常见反馈。
  - 把普通战技、普通战法、武将技的“发动 / 冷却 / 无目标 / 条件不符”提示收口为统一中文表达，并补齐了技能失败原因与建造默认提示的中文文案。
  - 重写了战报奖励格式、部队击破、据点占领、补给变化、设施摧毁等播报文案，使奖励展示改为“获得：战功/功绩/粮草...”的统一格式。
  - 用 E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\山河志风起汉末 -s res://tmp/_tmp_verify_unique_skills.gd 完成了 headless 校验。
- Risks:
  - scripts/battlefield_controller.gd 历史改动很多，当前工作区还混有这轮之外的旧变更；后续提交时应按 hunk 挑选，避免把无关内容一并带入。
  - 战略层、结算层和部分调试统计面板里仍有旧的英文/混合文案，这一轮没有继续外扩。
- Next:
  - 如需继续统一体验，下一步建议清理战略层/战斗结算面板里的剩余英文文案，并顺手把战报左下角滚动日志的措辞与底部大对话框再对齐一轮。
## 2026-03-26 11:08 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Switch the just-finished battle-copy pass from Chinese wording back to English because the current localization target is the English version.
- Done:
  - Reconverted the recent battle HUD/status wording in E:\山河志风起汉末\scripts\battlefield_controller.gd to English, including order feedback, build placement prompts, skill/tactic/unique-skill status, and command button tooltips.
  - Reconverted battle reward formatting and commander report templates to English for unit defeat, site capture, supply events, and facility destruction.
  - Kept the scope narrow to the recent battle-facing wording pass instead of attempting a repo-wide localization rewrite.
  - Revalidated with E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\山河志风起汉末 -s res://tmp/_tmp_verify_unique_skills.gd.
- Risks:
  - scripts/battlefield_controller.gd still contains older mixed-language and mojibake strings outside this narrowed battle-copy scope.
  - A true full-English build still needs follow-up passes in other runtime/UI files beyond this controller.
- Next:
  - Continue with a broader English localization sweep for the remaining mixed-language UI panels, battle summaries, and strategy-layer screens if the English build remains the active target.
## 2026-03-26 11:23 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Continue the English-version cleanup by removing the remaining mixed-language and mojibake battle text inside scripts/battlefield_controller.gd.
- Done:
  - Replaced the leftover mojibake hover-panel bonus text with clean English lines for personality bonuses and unique-skill readiness in E:\山河志风起汉末\scripts\battlefield_controller.gd.
  - Restored the build menu title to a proper English label (Field Build [B]) and fixed the surrounding line formatting so the block parses cleanly.
  - Replaced the siege debug overlay variant summary strings with readable English summaries for ram / ladder / catapult facility damage and proc counts.
  - Confirmed scripts/battlefield_controller.gd no longer contains Chinese or mojibake battle-facing strings, then revalidated with E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\山河志风起汉末 -s res://tmp/_tmp_verify_unique_skills.gd.
- Risks:
  - This pass only finished the remaining battle-controller text; other files may still contain older mixed-language strings.
  - Some terminology choices (for example Merit vs Gongji) may still need a later glossary pass for consistency across the whole English build.
- Next:
  - Move on to the next English-localization batch outside attlefield_controller.gd, starting with nearby battle/strategy UI panels that still contain mixed-language labels.
## 2026-03-26 10:46 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Retarget the GitHub Pages delivery path from `jay-sunshine/iloveu` to the new repository `jay-sunshine/iloveubaby`.
- Done:
  - Updated `E:\山河志风起汉末\tools\export\enable_github_pages.ps1` default repo name from `iloveu` to `iloveubaby`.
  - Updated `E:\山河志风起汉末\deliverables\tree_test_love_app\GITHUB_PAGES_QUICKSTART.md` so the repo URL, remote URL, and expected Pages URL all point to `jay-sunshine/iloveubaby`.
  - Updated the local `github` remote to `https://github.com/jay-sunshine/iloveubaby.git` while keeping `origin` on Gitee.
- Risks:
  - The new GitHub repository still needs the current local code pushed before the `Love Web Pages` workflow can appear and run.
- Next:
  - Push `master` to the updated `github` remote, then open the Actions tab for `jay-sunshine/iloveubaby` and run the web deployment workflow.
## 2026-03-26 10:32 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Continue the parse-blocker cleanup after the rain-fire pass, focusing only on the newly exposed script-load errors in `strategy_bootstrap.gd` and `china_terrain_scene.gd`.
- Done:
  - Replaced the two faction-strategy signal connections in `E:\ɽ��־����ĩ\scripts\engine\strategy_bootstrap.gd` with explicit `Callable(self, ...)` wiring to avoid the earlier handler-resolution parse blocker.
  - Added a compatibility alias in `E:\ɽ��־����ĩ\scripts\presentation\china_terrain_scene.gd` so the player-faction technology panel builder is reachable under both naming variants.
  - Fixed corrupted VFX texture preload paths at the top of `E:\ɽ��־����ĩ\scripts\presentation\china_terrain_scene.gd` to the real on-disk `res://�ز�/brackeys_vfx_bundle/...` assets.
  - Surgically replaced several mojibake-broken strings in `E:\ɽ��־����ĩ\scripts\engine\strategy_bootstrap.gd` that were breaking parse in regroup / siege / officer-book / faction-technology / expedition panel data blocks.
  - Confirmed `godot.windows.opt.tools.64.exe --headless --path E:\ɽ��־����ĩ -s res://tmp/_codex_parse_check.gd` now reports `bootstrap_script_ok=true` and `ui_script_ok=true` with no remaining parse error.
  - Re-ran `godot.windows.opt.tools.64.exe --headless --path E:\ɽ��־����ĩ --quit --scene res://scenes/china_terrain_30km.tscn`; the scene now loads past the earlier script parse blockers and only emits existing non-fatal material/deprecation warnings.
- Risks:
  - This pass fixed the exposed parse blockers but did not do a broad text-quality review; some nearby strings may still be placeholder English or legacy mixed-encoding content.
  - The main-scene headless run still prints existing warnings from `tree_batch_light_tuner.gd`, but they are not blocking script load.
- Next:
  - If continuing this cleanup branch, switch from parse recovery to a narrow runtime smoke test inside `ChinaTerrain30km`, or do one more tiny pass only if another concrete parse blocker appears.
## 2026-03-26 11:06 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Fix the failed GitHub Pages CI run for `jay-sunshine/iloveubaby` after the first workflow reported missing Godot web export templates.
- Done:
  - Diagnosed the failure from the GitHub Actions log: Godot looked for `web_nothreads_debug.zip` and `web_nothreads_release.zip` directly under `~/.local/share/godot/export_templates/4.6.1.stable`, while the workflow had unzipped the `.tpz` one level too deep.
  - Updated `E:\山河志风起汉末\.github\workflows\love_web_pages.yml` to unzip the export templates into a temp directory and copy `templates/.` into the exact Godot version folder expected by the exporter.
  - Committed the CI fix as `a05a345` with message `Fix Godot web template install path` and pushed it to `github/master` for `jay-sunshine/iloveubaby`.
- Risks:
  - The next workflow run may still fail on a different export/runtime issue because this repository is large and the web export path is being exercised for the first time.
- Next:
  - Watch the new run triggered by commit `a05a345`; if it fails, inspect the next error block rather than retrying the old run.
## 2026-03-26 12:05 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Continue the faction-level `Strategy` menu pass, stabilize the new `Personnel` branch, and make the new grand-strategy titles consistent.
- Done:
  - Confirmed `scripts/engine/strategy_bootstrap.gd`, `scripts/presentation/strategy_ui_layer.gd`, and `scripts/presentation/china_terrain_scene.gd` now parse with the new `Strategy` / `Personnel` / `Technology` wiring in place.
  - Kept the new grand-strategy labels English-first (`Personnel`, `Talent`, `Technology`, `Intelligence`, `Diplomacy`, `Council`) to avoid adding more mojibake-prone UI text.
  - Finalized the new faction-level personnel overview path by reusing the existing `aides` panel in read-only mode instead of inventing a separate menu.
  - Unified the bootstrap-side technology panel title to `Grand Strategy - Technology` so it matches the runtime path and the rest of the new strategy naming.
  - Revalidated with `res://tmp/_codex_parse_check.gd`; `bootstrap_script_ok=true` and `ui_script_ok=true`.
- Risks:
  - Only `Personnel` and `Technology` are meaningfully wired under `Strategy`; the other faction branches still return the placeholder not-wired message.
  - The repository still contains older mixed-encoding text and path history outside this narrow grand-strategy scope, so future edits in nearby blocks should remain surgical.
- Next:
  - Wire the next faction-level branch the player wants (recommended: `Talent` or `Council`) using the same full-size secondary-menu pattern and English-first labels.
## 2026-03-26 20:15 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Continue the English battle-facing unique-skill pass by polishing in-battle skill/tactic prompts, cast broadcast wording, and tactic VFX separation.
- Done:
  - Fixed the malformed function signatures that were blocking clean script parsing in `E:\ɽ��־����ĩ\scripts\unit_controller.gd` and `E:\ɽ��־����ĩ\scripts\battlefield_controller.gd`.
  - Kept the English cast-report pipeline on one path only: unique skill, normal skill, and tactic success now all funnel through `_report_player_ability_cast(...)` in `E:\ɽ��־����ĩ\scripts\battlefield_controller.gd`.
  - Finished a second VFX differentiation pass in `E:\ɽ��־����ĩ\scripts\battlefield_controller.gd`: `support`, `control`, and `wind` field effects now use distinct ring/disc geometry, orbit spacing, pulse speed, mark silhouettes, and ornament intensity so battlefield reads are easier at a glance.
  - Re-ran Godot headless verification with `E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\ɽ��־����ĩ -s res://tmp/_tmp_verify_unique_skills.gd` and it exited cleanly.
- Risks:
  - `scripts/battlefield_controller.gd` and `scripts/unit_controller.gd` already carried a large pre-existing working-tree diff before this pass, so later commit staging should still be hunk-based.
  - The current English fallback strategy only guarantees skill-related commander lines; broader battle chatter outside skill keys may still contain mixed language in some paths.
- Next:
  - If continuing this branch, do one focused runtime polish pass on battle cast feedback: tighten the remaining English wording in bottom commander lines / left report, or add one more readability layer such as style-colored icons for support/control/offense skill casts.
## 2026-03-26 12:28 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Change the faction `Strategy` interaction so the first-level menu stays small and the second-level branch menu also reuses the same small-menu size instead of opening the large command panel directly.
- Done:
  - Reworked `scripts/presentation/strategy_ui_layer.gd` so the existing small submenu panel is now reusable as a generic second-level strategy submenu, not only for `Move`.
  - Added small second-level submenu definitions for `Personnel`, `Technology`, `Talent`, `Intelligence`, `Diplomacy`, and `Council`; only `Personnel -> Overview` and `Technology -> Tree` currently open real content pages.
  - Changed faction-menu click flow so `Strategy` first-level buttons now open a same-size second-level submenu before entering the large content panel.
  - Updated bootstrap and ChinaTerrain30km runtime handlers to accept the new submenu action ids `faction_personnel_overview` and `faction_technology_tree`.
  - Revalidated with `res://tmp/_codex_parse_check.gd`; `bootstrap_script_ok=true` and `ui_script_ok=true`.
- Risks:
  - `Talent`, `Intelligence`, `Diplomacy`, and `Council` second-level entries are menu placeholders only; they still land on the existing not-wired message until their actual pages are built.
  - This pass only changes the strategy branch navigation pattern; it does not restyle the large detail panels themselves.
- Next:
  - If the user accepts this small second-level pattern, build the next real branch page behind one of those submenu entries, preferably `Talent` or `Council`.
## 2026-03-26 11:24 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Replace the heavy whole-project web export with a dedicated lightweight confession-only web subproject and change the web app title to `iloveu`.
- Done:
  - Added a new isolated web subproject at `E:\山河志风起汉末\web\iloveu_web` containing only the love scene, the two tree prefabs, required shaders/scripts/sky, and the pine textures/import cache needed by that scene.
  - Created a minimal `project.godot` inside that subproject with `config/name="iloveu"` and its own `export_presets.cfg`, so the browser title/runtime identity no longer uses the main game name.
  - Rewrote `E:\山河志风起汉末\.github\workflows\love_web_pages.yml` so GitHub Actions now imports and exports `web/iloveu_web` instead of the full repository project.
  - Revalidated the lightweight subproject locally: the scene now loads from the isolated path with only the existing tree-material remap warnings; no missing-resource errors remain after copying the required `.import` / `.ctex` files.
- Risks:
  - The lightweight web build should be much faster, but the first redeploy still depends on GitHub Pages propagation time and GitHub Pages network speed from the user's region.
  - The tree cinematic tuner still prints legacy material-remap warnings; they do not block export, but a later beauty pass could clean them up.
- Next:
  - Wait for the new `Love Web Pages` run triggered by `Add lightweight iloveu web subproject`; once it goes green, hard-refresh `https://jay-sunshine.github.io/iloveubaby/` and confirm the lighter build plus `iloveu` title.
## 2026-03-26 21:05 (Asia/Shanghai)
- Owner: Codex
- Goal:
  - Preserve Chinese source text while keeping the current English battle-facing skill/tactic pass usable.
- Done:
  - Added lightweight bilingual selectors in `E:\ɽ��־����ĩ\scripts\battlefield_controller.gd` and `E:\ɽ��־����ĩ\scripts\unit_controller.gd` via `battle_text_language` + `_battle_text(...)`, so skill names, skill/tactic tooltips, cast broadcasts, and key commander fallback lines now keep both Chinese source text and English output text together.
  - Replaced the skill-related hard-overwrite English strings with paired Chinese/English text in the two runtime scripts.
  - Repaired several legacy mojibake parse blockers exposed while preserving Chinese fallback text in `E:\ɽ��־����ĩ\scripts\unit_controller.gd`, including commander dialogue constant tables, famous-commander aliases, personality archetype fallback parsing, status-display names, and several state/status fallback lines.
  - Restored four broken VFX preload paths in `E:\ɽ��־����ĩ\scripts\unit_controller.gd` back to the real `res://�ز�/brackeys_vfx_bundle/...` assets.
  - Revalidated with `E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe --headless --path E:\ɽ��־����ĩ -s res://tmp/_tmp_verify_unique_skills.gd` and the check passed.
- Risks:
  - `battle_text_language` is currently per-script/per-instance, not a full project-wide localization pipeline yet.
  - There are still many older English-first changes elsewhere in the repo outside this narrow battle-skill pass; this handoff only covers the touched skill/tactic/broadcast/runtime text paths.
- Next:
  - If continuing, centralize the battle text language switch into a shared config / world meta / localization layer so one toggle can swap the whole battle UI between Chinese and English.
