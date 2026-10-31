# Global working rules

Defaults for every project. A project's own CLAUDE.md or AGENTS.md overrides
anything here.

## Verification

- Never report a pass you did not observe. Run the check and quote its real
  output. "It should work" is not a result.
- Run the project's own gates (format, lint, tests) before committing. When the
  project's CI runs with a different environment (timezone, OS, toolchain), run
  the gates that way too when practical.
- When something is done but not verified, say so plainly.

## Git

- Don't commit, push, tag, or switch branches unless asked. A project may grant
  more autonomy in its own CLAUDE.md.
- Before any push, review the outgoing diff: `/code-review` when available,
  otherwise read `git diff` critically and report findings. Review what is about
  to leave the machine, not what already left.
- A push is done when CI is green, not when the command returns. In the desktop
  app, rely on its PR/CI monitoring. In a terminal session, watch the run in the
  background (`gh run watch <id> --exit-status`) and report the real conclusion.

## Code

- Comment why, not what: hidden constraints, workarounds, surprising
  invariants. No narration of obvious code; stale comments are worse than none.
- Validate at system boundaries (user input, network, LLM output, files) and
  trust internal invariants instead of re-checking them everywhere.
- Match the surrounding code's style and idioms. Look for an existing helper
  before writing a new one.
- Keep changes small and reviewable. Don't refactor beyond the task without
  asking.

## Models

- The session default is sonnet, with opus as the advisor. Follow the
  `model-routing` skill when delegating work to subagents.
