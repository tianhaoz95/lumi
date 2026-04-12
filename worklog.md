Task: Implement intentional asymmetry and generous negative space on the Login & Sign Up screen

Plan:
1. Inspect existing login UI code at lib/features/auth/login_screen.dart.
2. Increase layout asymmetry and negative space for wide and narrow layouts: widen max container, increase left hero padding, increase overall page horizontal padding, and add subtle spacing tweaks when form fields are focused.
3. Run a quick format/check (git diff) and commit changes.

Verifiable deliverables:
- File lib/features/auth/login_screen.dart contains asymmetry (left hero flex 3 / right form flex 2) and updated spacing (maxWidth 1000, horizontal padding 32, increased right gap on hero to 64).
- worklog.md exists at repository root and lists the plan and deliverables (this file).
- Git commit present with message containing "Implement login asymmetry and spacing".

Notes for reviewer:
- Visual verification: open the login screen on wide layout and confirm the left hero area is significantly larger and the form is narrower with generous space.
- Code checks: search for "maxWidth: 1000" and "padding: const EdgeInsets.symmetric(horizontal: 32.0" in lib/features/auth/login_screen.dart.
