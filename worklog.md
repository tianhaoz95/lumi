# Worklog: Convert Chat Input Bar to Floating Glass Pill

Task: Home / Chat — Input Bar

Goal
- Convert the bottom chat input bar into a floating pill styled with glassmorphism. It should not span full width (leave horizontal margins), have a high border radius (pill), and include a subtle backdrop blur and translucent surface.

Planned steps
1. Locate the chat input widget in lib/features/home/ (search for "chat", "input", "message", "composer").
2. Edit the widget to wrap the input in a Container with:
   - borderRadius: 9999 (pill)
   - background color using theme token `surface` at ~70% opacity
   - BackdropFilter with Gaussian blur (20px)
   - Horizontal margin ("snow" on sides) and vertical padding to float above keyboard
3. Ensure the widget is not full-width by applying constrained width or horizontal margin.
4. Run analysis/tests: `flutter analyze` and `make test` (existing checks). Fix any compile issues.
5. Commit changes.

Verifiable deliverables
- worklog.md exists at project root and lists the task, steps, and deliverables (this file).
- The repository contains an edited chat input widget file (e.g., lib/features/home/... ) where the input Container includes `BackdropFilter` and a BoxDecoration with borderRadius 9999 and translucent background.
- The chat input Container applies horizontal margin (not full width) — reviewer can inspect code for EdgeInsets symmetric horizontal > 12.
- `flutter analyze` exits with code 0 (static analysis passes) OR `make test` exits 0 if test suite exists and is runnable in this environment.

Notes
- If any missing assets or packages are required, document them in this worklog and provide instructions to the reviewer.

