# New Window Prompt

Optional fallback text for a new Codex window:

```text
If you have not already done the repository bootstrap yourself, do not change code yet. First read these files, then reply in 10 lines or fewer with:
Current understanding / Plan / Risks

1) docs/codex/PROJECT_MEMORY.md
2) docs/codex/TASK_BOARD.md
3) docs/codex/SESSION_HANDOFF.md (latest entry only)

Extra rule:
- If benchmark / quickcheck / reverify CSV files show all-timeout results, first confirm whether the run was interrupted, disconnected, or manually stopped.
- If the sample is confirmed interrupted, mark it as an invalid sample before treating it as a gameplay regression.

Then begin execution.
```

Note:
- This is a fallback prompt for the user, not a requirement that the user must paste it every time.
- In this repository, Codex should perform the bootstrap read automatically at the start of a new session.
