Task: Increase vertical spacing between items in Dashboard Recent Activity

Plan:
1. Locate the Recent Activity list implementation under lib/features/dashboard/. Search for files implementing recent activity or activity list widgets.
2. Update the list item layout to increase vertical spacing to between 24px (1.5rem) and 32px (2rem). Use consistent vertical padding or SizedBox separators.
3. Run repository lint/tests available (flutter analyze if feasible) and run a quick grep to verify changes.
4. Commit changes and mark the task done in midterm-polish-tasks.md once verification passes.

Verifiable deliverables:
- File changed: lib/features/dashboard/dashboard.dart updated to include spacing constant `kRecentActivityVerticalSpacing = 28.0` and alternating opacity logic (`opacity: index.isEven ? 0.70 : 0.85`).
- A git commit exists that modifies lib/features/dashboard/dashboard.dart and is present at HEAD.
- Running `git --no-pager diff --name-only HEAD~1..HEAD` shows lib/features/dashboard/dashboard.dart.
- grep confirms `kRecentActivityVerticalSpacing = 28.0` and `opacity: index.isEven ? 0.70 : 0.85` in the modified file.

Reviewer Findings:
1. **Sub-bullets Status:** Although the vertical spacing is correctly increased to 28px (`kRecentActivityVerticalSpacing = 28.0`) and alternating backgrounds are implemented in the code (`opacity: index.isEven ? 0.70 : 0.85`), the sub-bullet "Implement alternating backgrounds for list items" in `midterm-polish-tasks.md` remains unchecked (`- [ ]`). Please update the task list to correctly reflect the completion of ALL sub-tasks before marking the parent "Recent Activity" as done.
2. **Deliverable Verification:** The deliverable "Running `git --no-pager diff --name-only HEAD~1..HEAD` shows the modified file" is technically not satisfied because the most recent commit `0d10f4a` only contains `worklog.md`. The code changes are in `d35aea9`. While the reviewer found the changes by searching the history, ensure that the verification steps in the worklog are accurate and reachable by the reviewer.
