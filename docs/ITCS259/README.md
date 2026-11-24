# ITCS259 Final Project Materials

These materials document the current BahtBuddy Flutter application for
**ITCS259 Mobile Application Development**.

## Submission files

The course asks for three items. Two are in this folder. The presentation video is recorded separately.

- [BahtBuddy_Project_Report.pdf](./BahtBuddy_Project_Report.pdf) — final report.
  Sections follow the submission instructions: Introduction and Background,
  Related Works, Methodology, Results, Conclusion, Responsibilities of Each
  Team Member, and References. Section 1.4 maps the app to the course
  proposal: a Flutter expense tracker with a local SQLite database.
  Screenshots of every screen are in Appendix A.
- [BahtBuddy_Presentation_Slides.pdf](./BahtBuddy_Presentation_Slides.pdf) —
  12-slide 16:9 deck in the app’s Ocean theme for the 26 November 2026
  presentation. The order is introduction, the problem, related work,
  features, a demonstration, architecture and the technology stack,
  results, and the conclusion.
- Presentation video, 2–5 minutes. It is not in this folder. Record from the
  deck, then put the unlisted YouTube, Drive, or GitHub link in the
  MyCourse submission.

The source project is the repository root. Installation is in the root
README. The schema lives in `lib/data/db/app_database.dart` (Drift). There
is no separate SQL script and no slip-image dataset.

## Demonstration order

1. Home: balance, safe-to-spend value, and the balance in each currency.
2. Add: camera, photo library, or a manual expense or income.
3. History, then Reports: the month, the tips, and spending over time.
4. Settings: theme, language, time zone, lock, and budgets.

The report states the limit directly: the on-device recognizer reads Latin
text, the user confirms every draft, and a measured slip study was not run.
The screenshots use the ledger already on the emulator (฿600 income and ฿20
expense on 24 November 2026). They show the interface. They are not a
usability score.

## Verification

- Final report: 15 pages. Figures A1–A11 are in Appendix A, two screens per page.
- Presentation deck: 12 slides, Ocean theme, every screen included
- Automated Flutter tests: 23 passed, 0 failed, on 24 November 2026
- Visual check: report gallery pages and every slide were rendered and inspected
