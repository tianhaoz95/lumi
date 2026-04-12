Task: Set typography fonts — Headlines to 'Manrope' and Body to 'Inter'

Planned steps:
1. Inspect current theme file at lib/core/theme.dart to find where text styles are defined.
2. Create this worklog.md documenting plan and verifiable deliverables.
3. Modify ThemeData to explicitly set ThemeData.fontFamily to 'Inter' for body/labels and ensure headline/display/title styles use GoogleFonts.manrope.
4. Run quick repository checks (grep) to confirm the changes are present.
5. Update midterm-polish-tasks.md to mark the typography checkbox done once deliverables are verified.

Verifiable deliverables:
- File lib/core/theme.dart contains GoogleFonts.manrope calls for headline/display/title styles.
- ThemeData in lib/core/theme.dart explicitly sets fontFamily: 'Inter'.
- A grep search for "GoogleFonts.manrope" and "fontFamily: 'Inter'" in lib/core/theme.dart returns matches.
- midterm-polish-tasks.md updated: the specific task line for "Explicitly set `fontFamily` for Headlines to 'Manrope' and Body to 'Inter'." is changed from "- [ ]" to "- [x]" after verification.

Notes for reviewer:
- The project uses the google_fonts package; headlines are set via GoogleFonts.manrope which ensures Manrope is used for display and title styles. Setting ThemeData.fontFamily to 'Inter' makes body and label text default to Inter while preserving explicit Manrope headlines.
