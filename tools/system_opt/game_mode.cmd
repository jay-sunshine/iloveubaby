@echo off
if /I "%1"=="closecodex" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0switch_game_mode.ps1" -CloseCodex
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0switch_game_mode.ps1"
)
pause
