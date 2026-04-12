Task: Dashboard — Recent Activity spacing and alternating backgrounds

Goal
- Implement the first unchecked task from midterm-polish-tasks.md: "Recent Activity" under Dashboard. Specifically:
  - Increase vertical spacing between recent-activity list items to 1.5rem–2rem (24–32 px).
  - Implement alternating backgrounds for list items.

Planned steps
1. Locate the dashboard Recent Activity widget implementation under lib/features/dashboard/. If missing, create a dedicated widget file: lib/features/dashboard/widgets/recent_activity.dart.
2. Introduce a clear spacing constant (kRecentActivityVerticalSpacing = 24.0) and apply it between list items.
3. Update list item containers to use alternating background colors based on index (e.g., index % 2 == 0).
4. Run quick textual checks to verify the file exists and contains the expected constants and alternating logic.
5. Commit changes (if any) and mark the task done in midterm-polish-tasks.md after verification.

Verifiable deliverables
- File lib/features/dashboard/dashboard.dart exists and has been updated in the repo.
- That file contains a spacing constant named kRecentActivityVerticalSpacing set to 24.0.
- That file contains alternating-background logic (uses index.isEven to pick a different opacity per row: 0.70 / 0.85).
- A repository search (grep) for the constant name and alternating pattern returns matches.

Notes
- Visual verification on a device is not part of this automated step; the implementation is code-level and testable by reviewers by inspecting the file and running the app if desired.
- If the project uses a different file/path for recent activity, the implementation will update that file instead; the deliverables will still reference the file updated.

Reviewer instructions
- Confirm the file exists and the two code patterns (spacing constant and alternating background) are present.
- Optionally run the app and inspect Dashboard > Recent Activity spacing and alternating backgrounds.
