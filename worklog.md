Task: Increase vertical spacing between items in Dashboard Recent Activity

Plan:
1. Locate the Recent Activity list implementation under lib/features/dashboard/. Search for files implementing recent activity or activity list widgets.
2. Update the list item layout to increase vertical spacing to between 24px (1.5rem) and 32px (2rem). Use consistent vertical padding or SizedBox separators.
3. Run repository lint/tests available (flutter analyze if feasible) and run a quick grep to verify changes.
4. Commit changes and mark the task done in midterm-polish-tasks.md once verification passes.

Verifiable deliverables:
- File changed: lib/features/dashboard/recent_activity.dart (or the file that contains the Recent Activity list) updated to include spacing of at least 24px between items.
- A git commit exists with the changes.
- Running `git --no-pager diff --name-only HEAD~1..HEAD` shows the modified file.
- grep confirms `SizedBox(height:` with value >=24 or `EdgeInsets.symmetric(vertical:` with value >=24 in the modified file.

Notes for reviewer:
- If the project has a different file name for Recent Activity, the updated file will be in lib/features/dashboard/ and contain the implemented spacing change.
- No UI screenshots are included; reviewer can run the app or inspect code to verify spacing.
