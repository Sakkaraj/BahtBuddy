# ITCS259 Final Project Materials

These materials document the current BahtBuddy Flutter application for
**ITCS259 Mobile Application Development**.

## Submission files

- [BahtBuddy_Project_Report.pdf](./BahtBuddy_Project_Report.pdf) - academic
  report covering the problem, related works, methodology, architecture, data
  model, implementation, results, limitations, responsibilities, and
  references.
- [BahtBuddy_Presentation_Slides.pdf](./BahtBuddy_Presentation_Slides.pdf) -
  11-slide 16:9 presentation for a 2-5 minute demonstration.
- [build_final_deliverables.py](./build_final_deliverables.py) - redesigned
  academic report and slide-deck generator.
- `screen_*.png` - authentic Android emulator screenshots included in the
  report and slides.

## Regenerating the PDFs

From the repository root:

```powershell
python docs\ITCS259\build_final_deliverables.py
```

The generator writes the report and slide PDFs into this folder. It requires
Python and ReportLab. The implementation facts are based on the current
Flutter/Riverpod, Drift SQLite, ML Kit Latin OCR, parser, notifications, charts,
backup/restore, and cached Frankfurter exchange-rate code.

## Demonstration order

1. Home: balance, safe-to-spend value, and cached exchange rates.
2. Add: manual expense or income, then explain the slip camera/gallery path.
3. Reports: period summary, previous-period comparison, charts, and rule-based
   tips.
4. Architecture: explain that financial records remain local and that the
   exchange-rate service is the only optional network dependency.

The report states the important limitation accurately: the configured ML Kit
recognizer uses the Latin model, so the review form remains mandatory and Thai
script recognition is a future improvement. The Android screenshots are
demonstration evidence, not a usability or OCR-accuracy study.

The screenshots show the seeded emulator demonstration data (฿600 income and
฿20 expense). They are included as implementation evidence; they are not
performance claims or a substitute for the automated tests listed in the
report.

## Verification

- Final report: 9 pages
- Presentation deck: 11 slides
- Automated Flutter tests: 23 passed, 0 failed
- Visual verification: report and slide representative pages rendered and
  inspected
