"""Final academic report and presentation PDFs for the BahtBuddy ITCS259 project."""

from pathlib import Path
from reportlab.lib import colors
from reportlab.lib.colors import HexColor
from reportlab.lib.enums import TA_CENTER, TA_JUSTIFY, TA_LEFT
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfgen import canvas
from reportlab.platypus import (
    PageBreak, Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle,
    Image as RLImage, KeepTogether, HRFlowable, Preformatted,
)


OUT = Path(__file__).resolve().parent
ROOT = OUT.parent.parent

pdfmetrics.registerFont(TTFont("Segoe", r"C:\Windows\Fonts\segoeui.ttf"))
pdfmetrics.registerFont(TTFont("SegoeBold", r"C:\Windows\Fonts\segoeuib.ttf"))
pdfmetrics.registerFont(TTFont("SegoeSemi", r"C:\Windows\Fonts\seguisb.ttf"))

NAVY = HexColor("#12324F")
TEAL = HexColor("#0E9F8A")
BLUE = HexColor("#2E74B5")
INK = HexColor("#1A2A3A")
MUTED = HexColor("#617284")
LINE = HexColor("#DCE5EA")
PAPER = HexColor("#F4F7F8")
WHITE = colors.white
GREEN = HexColor("#12B981")
RED = HexColor("#F05A67")


def para(text, style):
    return Paragraph(text, style)


def report_styles():
    return {
        "title": ParagraphStyle("title", fontName="SegoeBold", fontSize=27,
                                leading=32, textColor=NAVY, alignment=TA_LEFT),
        "subtitle": ParagraphStyle("subtitle", fontName="Segoe", fontSize=13,
                                   leading=18, textColor=MUTED),
        "cover_label": ParagraphStyle("cover_label", fontName="SegoeSemi",
                                      fontSize=10, leading=12, textColor=TEAL),
        "h1": ParagraphStyle("h1", fontName="SegoeBold", fontSize=17,
                             leading=21, textColor=NAVY, spaceBefore=8, spaceAfter=7,
                             keepWithNext=True),
        "h2": ParagraphStyle("h2", fontName="SegoeBold", fontSize=12,
                             leading=15, textColor=BLUE, spaceBefore=7, spaceAfter=4,
                             keepWithNext=True),
        "body": ParagraphStyle("body", fontName="Segoe", fontSize=9.5,
                               leading=14, textColor=INK, alignment=TA_JUSTIFY,
                               spaceAfter=6),
        "small": ParagraphStyle("small", fontName="Segoe", fontSize=8,
                                leading=11, textColor=INK, spaceAfter=3),
        "caption": ParagraphStyle("caption", fontName="Segoe", fontSize=7.8,
                                  leading=10.5, textColor=MUTED,
                                  alignment=TA_CENTER, spaceBefore=3),
        "code": ParagraphStyle("code", fontName="Courier", fontSize=7,
                               leading=9, textColor=INK, leftIndent=4,
                               rightIndent=4, backColor=PAPER),
        "th": ParagraphStyle("th", fontName="SegoeBold", fontSize=8,
                             leading=10, textColor=WHITE),
        "td": ParagraphStyle("td", fontName="Segoe", fontSize=8,
                             leading=10.5, textColor=INK),
    }


S = report_styles()


def academic_table(headers, rows, widths):
    data = [[para(h, S["th"]) for h in headers]]
    data += [[para(str(cell), S["td"]) for cell in row] for row in rows]
    table = Table(data, colWidths=widths, repeatRows=1)
    table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), NAVY),
        ("TEXTCOLOR", (0, 0), (-1, 0), WHITE),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1), [WHITE, PAPER]),
        ("GRID", (0, 0), (-1, -1), 0.35, LINE),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("LEFTPADDING", (0, 0), (-1, -1), 5),
        ("RIGHTPADDING", (0, 0), (-1, -1), 5),
        ("TOPPADDING", (0, 0), (-1, -1), 4),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
    ]))
    return table


def report_footer(c, doc):
    c.saveState()
    c.setFillColor(TEAL)
    c.rect(0, A4[1] - 7, A4[0], 7, fill=1, stroke=0)
    c.setFillColor(NAVY)
    c.rect(0, 0, A4[0], 24, fill=1, stroke=0)
    c.setFillColor(WHITE)
    c.setFont("Segoe", 8)
    c.drawString(18 * mm, 9, "ITCS259 · Mobile Application Development")
    c.drawRightString(A4[0] - 18 * mm, 9, f"{doc.page}")
    c.restoreState()


def cover_footer(c, doc):
    c.saveState()
    c.setFillColor(NAVY)
    c.rect(0, 0, A4[0], 30, fill=1, stroke=0)
    c.setFillColor(WHITE)
    c.setFont("Segoe", 8)
    c.drawString(18 * mm, 11, "Bachelor-level final project · ITCS259")
    c.drawRightString(A4[0] - 18 * mm, 11, "Submitted 30 November 2026")
    c.restoreState()


def screen(name, height=82 * mm):
    path = OUT / name
    return RLImage(str(path), height=height, width=38 * mm)


def section_heading(number, title):
    return para(f"{number}. {title}", S["h1"])


def build_report():
    path = OUT / "BahtBuddy_Project_Report.pdf"
    doc = SimpleDocTemplate(
        str(path), pagesize=A4,
        leftMargin=18 * mm, rightMargin=18 * mm,
        topMargin=16 * mm, bottomMargin=16 * mm,
        title="BahtBuddy — Final Project Report",
        author="Jirathiwat Suntipreedatham and Sakkaraj Tuvajit",
        subject="ITCS259 Mobile Application Development",
    )
    story = []

    story += [
        Spacer(1, 24 * mm),
        para("ITCS259 · MOBILE APPLICATION DEVELOPMENT", S["cover_label"]),
        Spacer(1, 7 * mm),
        para("BahtBuddy", S["title"]),
        Spacer(1, 2 * mm),
        para("Offline-first personal expense tracker with on-device bank-slip recognition",
             S["subtitle"]),
        Spacer(1, 7 * mm),
        HRFlowable(width="100%", thickness=2, color=TEAL, spaceAfter=8),
        para("Final Project Report", S["subtitle"]),
        Spacer(1, 7 * mm),
        academic_table(
            ["Student name", "Student ID", "Primary responsibility"],
            [
                ["Jirathiwat Suntipreedatham", "6788122",
                 "Flutter UI, state management, reports, testing, documentation"],
                ["Sakkaraj Tuvajit", "6788140",
                 "Drift database, repositories, OCR flow, services, platform integration"],
            ],
            [66 * mm, 28 * mm, 78 * mm],
        ),
        Spacer(1, 7 * mm),
        para("<b>Institution:</b> ITCS259 · <b>Submission date:</b> 30 November 2026",
             S["small"]),
        para("<b>Source repository:</b> https://github.com/Sakkaraj/BahtBuddy",
             S["small"]),
        PageBreak(),
    ]

    story += [
        para("Abstract", S["h1"]),
        para(
            "BahtBuddy is an offline-first mobile personal-finance application developed for university students in Thailand. It integrates manual income and expense entry, on-device bank-slip text recognition, local SQLite storage, category budgets, financial reports, notifications, backup and restore, and device authentication. The application was implemented with Flutter and Dart and uses Riverpod for state management and Drift for typed SQLite persistence. A rule-based parsing pipeline converts recognized text into an editable transaction draft, ensuring that OCR never writes financial data without explicit user confirmation. The system’s major design contribution is the combination of privacy-preserving local storage, practical slip-assisted entry, and explainable rule-based reporting. Evaluation consists of unit, database-repository, parser, and widget tests, as well as Android emulator workflow verification. This report documents the problem definition, related applications, methodology, architecture, implementation, outcomes, limitations, and future improvements.",
            S["body"],
        ),
        para("<b>Keywords:</b> mobile development, Flutter, personal finance, local database, OCR, offline-first architecture, Riverpod, Drift",
             S["small"]),
        para("Table of Contents", S["h1"]),
        academic_table(
            ["Section", "Topic"],
            [
                ["1", "Introduction and Background"],
                ["2", "Related Works"],
                ["3", "Methodology and System Architecture"],
                ["4", "Technology Stack"],
                ["5", "Implementation"],
                ["6", "Results and User Interface"],
                ["7", "Testing and Evaluation"],
                ["8", "Limitations and Future Work"],
                ["9", "Conclusion"],
                ["10", "Team Responsibilities"],
                ["11", "References"],
            ],
            [18 * mm, 154 * mm],
        ),
        PageBreak(),
    ]

    story += [
        section_heading("1", "Introduction and Background"),
        para(
            "University students commonly perform small purchases and bank transfers throughout the week. A bank application records the transfer, but it is not primarily designed for personal budgeting, category analysis, cash spending, or explanation of unusual spending patterns. Users may delay or abandon manual logging because repeated entry is inconvenient. A slip is also an already available source of amount, date, recipient, and transaction reference data.",
            S["body"],
        ),
        para(
            "BahtBuddy addresses this problem by providing a local ledger that supports both manual and slip-assisted entry. The application does not require an account. Financial records, categories, budgets, recipient rules, and preferences are stored on the device. The slip image is processed on the phone with Google ML Kit. OCR output is parsed into an editable draft, and no record is stored until the user confirms it. Optional exchange-rate information is the only network-dependent feature and is cached for offline use.",
            S["body"],
        ),
        para("1.1 Problem Statement", S["h2"]),
        para(
            "How can a mobile personal-finance application reduce repetitive data entry while preserving privacy, accuracy controls, and the user’s ability to manage cash and digital transactions?",
            S["body"],
        ),
        para("1.2 Objectives", S["h2"]),
        academic_table(
            ["Objective", "Implemented capability"],
            [
                ["Reduce entry effort", "Camera/gallery OCR and editable parser draft"],
                ["Preserve privacy", "SQLite-first storage and no account server"],
                ["Support complete cash flow", "Expense, income, categories, and history"],
                ["Provide actionable analysis", "Budgets, period reports, charts, and ranked tips"],
                ["Improve accessibility", "English/Thai localization and configurable themes"],
                ["Protect local data", "PIN, biometric authentication, and backup/restore"],
            ],
            [48 * mm, 124 * mm],
        ),
        para("1.3 Scope and Use Cases", S["h2"]),
        para(
            "The intended users are Thai university students who record food, transportation, shopping, bills, education, entertainment, health, and income. Representative use cases include adding a PromptPay expense from a slip, reviewing an OCR-derived amount, recording cash spending, searching historical transactions, setting monthly category budgets, exporting a ledger, and reviewing spending advice.",
            S["body"],
        ),
    ]

    story += [
        section_heading("2", "Related Works"),
        para(
            "Notebook and spreadsheet methods are private and require no service account, but they do not provide automated OCR, reminders, charts, or reliable duplicate detection. Cloud expense applications offer dashboards and synchronization, although they may require account registration and transmission of receipt images. Banking applications provide accurate transfer history, yet they are not explicitly optimized for personal categories, cash transactions, learned merchant rules, or custom budget alerts.",
            S["body"],
        ),
        academic_table(
            ["Approach", "Strength", "Weakness", "BahtBuddy response"],
            [
                ["Notebook/spreadsheet", "Private and offline", "Manual entry; no OCR or alerts",
                 "Local ledger with parser-assisted entry"],
                ["Cloud finance app", "Sync and rich dashboards", "Account and network dependency",
                 "No account; local-first operation"],
                ["Banking app", "Authoritative transfer information", "Limited personal budgeting",
                 "Personal categories, budgets, tips, cash/income"],
                ["Receipt OCR app", "Automatic extraction", "Privacy or API-cost concerns",
                 "On-device ML Kit and review-before-save"],
            ],
            [38 * mm, 39 * mm, 45 * mm, 50 * mm],
        ),
        para(
            "BahtBuddy distinguishes itself by retaining OCR and financial data on the device, combining slip entry with learned recipient-category rules, and presenting financial summaries using deterministic arithmetic rather than opaque recommendations.",
            S["body"],
        ),
    ]

    story += [
        section_heading("3", "Methodology and System Architecture"),
        para("3.1 Development Approach", S["h2"]),
        para(
            "The project follows a layered, feature-oriented implementation. Screens present UI and user actions; Riverpod providers expose state; repositories coordinate database operations and validation; Drift provides typed SQLite access; and dedicated services handle OCR, notifications, exchange rates, and home layout persistence.",
            S["body"],
        ),
        para("3.2 System Architecture", S["h2"]),
        academic_table(
            ["Layer", "Responsibilities", "Representative implementation"],
            [
                ["Presentation", "Navigation, widgets, themes, localization", "Material 3 screens and go_router"],
                ["State", "Reactive application state", "Riverpod providers and AsyncNotifier"],
                ["Domain/repositories", "Save rules, duplicate checks, learned categories", "TransactionRepository"],
                ["Data", "Schema, queries, migrations, backup payload", "Drift AppDatabase"],
                ["Platform services", "OCR, authentication, notifications, files", "ML Kit, local_auth, local notifications"],
                ["External network", "Optional exchange-rate retrieval", "Frankfurter API with JSON cache"],
            ],
            [36 * mm, 78 * mm, 58 * mm],
        ),
        para("3.3 Slip Processing Workflow", S["h2"]),
        para(
            "<b>Camera/gallery image → temporary image copy → ML Kit Latin text recognition → rule-based parser → category suggestion → editable EntryScreen → duplicate/reference validation → Drift transaction insert/update.</b>",
            S["body"],
        ),
        para("3.4 Navigation and State Flow", S["h2"]),
        para(
            "go_router provides a StatefulShellRoute with Home, History, Reports, and Settings branches. The Entry and Budgets pages are separate routes. Screens subscribe to StreamProviders or AsyncNotifiers rather than owning independent copies of database state.",
            S["body"],
        ),
    ]

    story += [
        section_heading("4", "Technology Stack"),
        academic_table(
            ["Area", "Selected technology", "Rationale"],
            [
                ["Framework", "Flutter 3 / Dart", "Cross-platform UI from one codebase"],
                ["Navigation", "go_router", "Typed route structure and persistent shell branches"],
                ["State", "flutter_riverpod", "Dependency isolation and reactive database state"],
                ["Database", "Drift / SQLite", "Type-safe queries and migration support"],
                ["OCR", "google_mlkit_text_recognition", "On-device Latin text recognition"],
                ["Image access", "image_picker", "Camera and photo-library integration"],
                ["Charts", "fl_chart", "Category and trend visualization"],
                ["Security", "local_auth / PIN hash", "Device biometrics and app-level PIN"],
                ["Notifications", "flutter_local_notifications", "Budget alerts and reminders"],
                ["Localization", "flutter_localizations / intl", "English and Thai interface"],
                ["Backup", "csv, file_picker, share_plus", "Export and restore user data"],
                ["Exchange rates", "Frankfurter ECB API", "No-key public rates with local cache"],
            ],
            [32 * mm, 62 * mm, 78 * mm],
        ),
    ]

    story += [
        section_heading("5", "Implementation"),
        para("5.1 Data Model", S["h2"]),
        academic_table(
            ["Drift table", "Core fields", "Purpose"],
            [
                ["Categories", "key, nameEn, nameTh, isIncome", "Seeded spending and income categories"],
                ["MoneyTransactions", "amount, type, category, occurredAt, note, recipient, slipReference, imagePath",
                 "Primary financial ledger"],
                ["Budgets", "categoryId, monthlyLimit", "One monthly limit per expense category"],
                ["RecipientRules", "recipientKey, categoryId", "Learned recipient-to-category mapping"],
                ["Preferences", "theme, locale, PIN hash, biometrics, reminder, timezone",
                 "Persistent application settings"],
            ],
            [34 * mm, 78 * mm, 60 * mm],
        ),
        para("5.2 Transaction Persistence and Duplicate Protection", S["h2"]),
        Preformatted(
            "Future<SaveStatus> save(TransactionDraft draft) async {\n"
            "  final existing = await db.transactionByReference(reference);\n"
            "  if (existing != null && existing.id != draft.id) {\n"
            "    return SaveStatus.duplicate;\n"
            "  }\n"
            "  // Build the Drift companion and insert or update the row.\n"
            "  // Learn the normalized recipient/category relationship.\n"
            "  return SaveStatus.saved;\n"
            "}",
            S["code"],
        ),
        para(
            "A duplicate is prevented when a slip reference already exists, unless the user is editing the same transaction. Blank references are not enforced as unique values.",
            S["body"],
        ),
        para("5.3 Rule-Based Slip Parsing", S["h2"]),
        Preformatted(
            "Amount priority:\n"
            "1. Labeled amount: Amount:, จำนวนเงิน, or ยอดเงิน\n"
            "2. Currency before amount: THB or ฿\n"
            "3. Currency after amount: บาท, THB, or ฿\n"
            "4. Standalone decimal amount on a complete text line",
            S["code"],
        ),
        para(
            "The parser extracts numeric and named dates, Buddhist year dates, recipient labels, and transaction references. It does not claim to understand every layout. The user may edit every proposed field on EntryScreen.",
            S["body"],
        ),
        para("5.4 Reporting Logic", S["h2"]),
        para(
            "The reports page calculates period balances, average daily spending, comparison with the previous period, category proportions, and ranked textual tips. A tip engine warns for spending above income, high category concentration, a 15 percent or larger period change, thin or strong remaining balances, forecast daily pace, and unusually large individual records.",
            S["body"],
        ),
    ]

    story += [
        section_heading("6", "Results and User Interface"),
        para(
            "The application implements the main proposed workflows. The following figures were captured from the current Android debug build running on an emulator. They demonstrate the actual interface rather than a wireframe.",
            S["body"],
        ),
        Table([
            [screen("screen_home.png", 103 * mm), screen("screen_reports.png", 103 * mm)],
            [para("<b>Figure 1.</b> Home page: balance, entry actions, exchange rates.", S["caption"]),
             para("<b>Figure 2.</b> Reports: period controls, balance, tips, category share.", S["caption"])],
        ], colWidths=[86 * mm, 86 * mm]),
        Spacer(1, 5 * mm),
        Table([
            [screen("screen_settings.png", 103 * mm), Spacer(1, 1)],
            [para("<b>Figure 3.</b> Settings: appearance, security, reminders, budgets.", S["caption"]),
             para("", S["caption"])],
        ], colWidths=[86 * mm, 86 * mm]),
        PageBreak(),
        para("Implemented Feature Matrix", S["h2"]),
        academic_table(
            ["Feature", "Status", "Implementation evidence"],
            [
                ["Manual expense and income", "Completed", "Unified entry form with category and date controls"],
                ["Slip camera/gallery entry", "Completed", "ML Kit, parser, persisted draft image and reference"],
                ["Duplicate protection", "Completed", "Unique database semantics plus repository validation"],
                ["Recipient category learning", "Completed", "RecipientRules table and category suggester"],
                ["History and filtering", "Completed", "Text search, type, and date-range filters"],
                ["Budgets and alerts", "Completed", "Per-category monthly limits and 80/100% crossings"],
                ["Reports and charts", "Completed", "Period summaries and category/financial charts"],
                ["PIN and biometrics", "Completed", "Hashed PIN and local_auth integration"],
                ["Backup/restore", "Completed", "Versioned JSON restore and CSV export"],
                ["Localization/themes", "Completed", "English/Thai and six visual themes"],
            ],
            [46 * mm, 25 * mm, 101 * mm],
        ),
    ]

    story += [
        section_heading("7", "Testing and Evaluation"),
        para(
            "Testing is divided by responsibility. Pure tests validate parser output and ranking mathematics; repository tests validate SQLite behavior and duplicate prevention; widget tests validate the entry workflow.",
            S["body"],
        ),
        academic_table(
            ["Test file", "Coverage", "Validation type"],
            [
                ["slip_parser_test.dart", "Thai/English slips, dates, references, category and budget rules",
                 "Unit tests"],
                ["duplicate_test.dart", "Stored reference rejection and learned category mapping",
                 "In-memory Drift repository test"],
                ["widget_test.dart", "Manual save and slip-confirmation fields",
                 "Flutter widget test"],
                ["exchange_rates_test.dart", "Frankfurter conversion and time-zone date parsing",
                 "Unit tests"],
                ["history_filter_test.dart", "Expense/income/date/text filtering",
                 "Unit tests"],
                ["report_tips_test.dart", "Glance facts and ranked tip rules",
                 "Unit tests"],
                ["pin_pad_test.dart", "PIN input behavior",
                 "Widget logic test"],
            ],
            [42 * mm, 92 * mm, 38 * mm],
        ),
        para("7.1 Android Emulator Verification", S["h2"]),
        para(
            "The emulator build was verified by opening the Home, History, Reports, Add/Slip, and Settings workflows and by capturing the corresponding interface states. The demonstration data used in the screenshots is test data and is not a claim of real-user performance.",
            S["body"],
        ),
        para("7.2 Evaluation Status", S["h2"]),
        para(
            "<b>Verified status:</b> the complete Flutter test suite passed on 24 November 2026 with 23 tests successful and no failures. Coverage includes Bangkok time-zone behavior, duplicate references, history filtering, PIN-pad behavior, manual entry, slip confirmation, exchange-rate parsing, report tips, and repository learning. OCR accuracy was not measured on a recorded 50-slip data set, so that item remains future work rather than a claimed achievement.",
            S["body"],
        ),
    ]

    story += [
        section_heading("8", "Limitations and Future Work"),
        academic_table(
            ["Limitation", "Reason", "Future improvement"],
            [
                ["Limited Thai OCR", "Configured ML Kit uses the Latin recognition script",
                 "Evaluate Thai models, preprocessing, and a hybrid recognition workflow"],
                ["No measured OCR accuracy", "No controlled slip-image dataset and recorded test protocol",
                 "Create 50–100-slip corpus and report precision/recall and field accuracy"],
                ["No cloud synchronization", "Design intentionally local-first",
                 "Add optional encrypted synchronization while retaining offline mode"],
                ["Exchange rates require network", "Frankfurter is an external service",
                 "Improve cache freshness and offline status messaging"],
                ["PIN/backup threat model", "Local backup and PIN data require platform security",
                 "Encrypted export, version migration, and threat-model testing"],
                ["No formal usability study", "Development was primarily technical and emulator-based",
                 "Conduct supervised task completion and SUS/user-satisfaction evaluation"],
            ],
            [42 * mm, 56 * mm, 74 * mm],
        ),
    ]

    story += [
        section_heading("9", "Conclusion"),
        para(
            "BahtBuddy demonstrates a complete local-first mobile application for personal financial tracking. The project satisfies the proposed course scope through manual entry, slip-assisted OCR review, SQLite persistence, category budgets, history, reports, alerts, localization, authentication, and backup/restore. The central engineering lesson is that mobile AI or OCR features should remain transparent and reversible: recognized text is a draft until the user verifies it. The project also demonstrates that useful financial feedback can be implemented with deterministic rules, avoiding the need for a cloud language model.",
            S["body"],
        ),
        para(
            "Future work should prioritize Thai OCR evaluation, a measured slip-accuracy protocol, encrypted backup protection, and optional synchronization. These improvements would strengthen the scientific evidence and security posture without changing the application’s privacy-preserving local core.",
            S["body"],
        ),
    ]

    story += [
        section_heading("10", "Responsibilities of Each Team Member"),
        academic_table(
            ["Team member", "Frontend/UI", "Data/services", "Testing/docs"],
            [
                ["Jirathiwat Suntipreedatham · 6788122",
                 "Flutter pages, navigation, visual themes, reports and charts",
                 "Riverpod providers, settings and UI data flow",
                 "Widget/unit test review, screenshots, report and presentation"],
                ["Sakkaraj Tuvajit · 6788140",
                 "Entry and slip review integration",
                 "Drift schema, migrations, repositories, OCR/parser/services",
                 "Platform configuration, debugging, source-code maintenance"],
            ],
            [44 * mm, 46 * mm, 48 * mm, 34 * mm],
        ),
    ]

    story += [
        section_heading("11", "References"),
        para("[1] Google, “Flutter Documentation,” 2026. [Online]. Available: https://docs.flutter.dev.", S["small"]),
        para("[2] S. Binder, “Drift: SQLite Persistence for Dart and Flutter,” 2026. [Online]. Available: https://drift.simonbinder.eu.", S["small"]),
        para("[3] Google, “ML Kit Text Recognition,” 2026. [Online]. Available: https://developers.google.com/ml-kit/vision/text-recognition.", S["small"]),
        para("[4] flutter_riverpod Contributors, “Riverpod Documentation,” 2026. [Online]. Available: https://riverpod.dev.", S["small"]),
        para("[5] Simon Leier, “fl_chart Documentation,” 2026. [Online]. Available: https://pub.dev/packages/fl_chart.", S["small"]),
        para("[6] Frankfurter, “Public Exchange Rates API,” 2026. [Online]. Available: https://www.frankfurter.app.", S["small"]),
        para("[7] pub.dev, “Dart and Flutter Package Documentation,” 2026. [Online]. Available: https://pub.dev.", S["small"]),
        para("[8] Sakkaraj/BahtBuddy, “BahtBuddy Source Repository,” 2026. [Online]. Available: https://github.com/Sakkaraj/BahtBuddy.", S["small"]),
        para("[9] ITCS259 Course Staff, “Final Project Submission Instructions,” 2026.", S["small"]),
        PageBreak(),
        para("Appendix A: Repository Verification", S["h1"]),
        para(
            "The submission source should include the complete Flutter project folder, assets, Android and iOS configuration, test folder, README installation instructions, backup implementation, and this documentation folder.",
            S["body"],
        ),
        para("Appendix B: Key Source Files", S["h2"]),
        academic_table(
            ["Concern", "Source"],
            [
                ["Application and routes", "lib/app.dart"],
                ["State and dependency providers", "lib/providers.dart"],
                ["Drift schema and migrations", "lib/data/db/app_database.dart"],
                ["Transaction save and duplicate logic", "lib/data/repositories/transaction_repository.dart"],
                ["ML Kit recognition", "lib/services/slip_ocr.dart"],
                ["Slip parser", "lib/features/slips/slip_parser.dart"],
                ["CSV/JSON backup", "lib/data/repositories/backup_repository.dart"],
                ["Exchange-rate cache", "lib/services/exchange_rates.dart"],
                ["Test suite", "test/*.dart"],
            ],
            [52 * mm, 120 * mm],
        ),
    ]

    doc.build(story, onFirstPage=cover_footer, onLaterPages=report_footer)


W, H = 960, 540


def slide_base(c, number, title, kicker):
    c.setFillColor(HexColor("#F7F9FB"))
    c.rect(0, 0, W, H, fill=1, stroke=0)
    c.setFillColor(NAVY)
    c.rect(0, H - 8, W, 8, fill=1, stroke=0)
    c.setFillColor(TEAL)
    c.rect(0, 0, W, 28, fill=1, stroke=0)
    c.setFillColor(WHITE)
    c.setFont("Segoe", 9)
    c.drawString(34, 9, "ITCS259 · BahtBuddy")
    c.drawRightString(W - 34, 9, f"{number:02d}")
    c.setFillColor(TEAL)
    c.setFont("SegoeSemi", 10)
    c.drawString(42, H - 42, kicker.upper())
    c.setFillColor(NAVY)
    c.setFont("SegoeBold", 27)
    c.drawString(42, H - 78, title)
    c.setFillColor(LINE)
    c.rect(42, H - 91, W - 84, 1, fill=1, stroke=0)


def slide_paragraph(c, text, x, y, width, size=16, leading=21, color=INK):
    style = ParagraphStyle("slide", fontName="Segoe", fontSize=size,
                           leading=leading, textColor=color)
    p = Paragraph(text, style)
    _, h = p.wrap(width, H)
    p.drawOn(c, x, y - h)
    return h


def slide_bullets(c, items, x, y, width, size=15):
    for item in items:
        c.setFillColor(TEAL)
        c.circle(x + 5, y - 5, 4, fill=1, stroke=0)
        h = slide_paragraph(c, item, x + 18, y + 7, width - 18, size, size + 6)
        y -= max(h + 10, 35)
    return y


def build_slides():
    path = OUT / "BahtBuddy_Presentation_Slides.pdf"
    c = canvas.Canvas(str(path), pagesize=(W, H))
    c.setTitle("BahtBuddy — ITCS259 Final Presentation")
    c.setAuthor("Jirathiwat Suntipreedatham and Sakkaraj Tuvajit")

    # 1 Cover
    c.setFillColor(NAVY); c.rect(0, 0, W, H, fill=1, stroke=0)
    c.setFillColor(TEAL); c.rect(0, 0, 14, H, fill=1, stroke=0)
    c.setFillColor(TEAL); c.setFont("SegoeSemi", 12)
    c.drawString(48, H - 72, "ITCS259 · MOBILE APPLICATION DEVELOPMENT")
    c.setFillColor(WHITE); c.setFont("SegoeBold", 52)
    c.drawString(48, H - 148, "BahtBuddy")
    c.setFillColor(HexColor("#D8EBE7")); c.setFont("Segoe", 19)
    c.drawString(48, H - 188, "Offline-first expense tracking with on-device slip reading")
    c.setStrokeColor(TEAL); c.setLineWidth(3); c.line(48, 300, 260, 300)
    c.setFillColor(WHITE); c.setFont("Segoe", 15)
    c.drawString(48, 150, "Jirathiwat Suntipreedatham · 6788122")
    c.drawString(48, 124, "Sakkaraj Tuvajit · 6788140")
    c.setFillColor(HexColor("#A6D8CF")); c.setFont("Segoe", 12)
    c.drawString(48, 64, "Final presentation · 26 November 2026")
    c.showPage()

    slide_base(c, 2, "Problem and motivation", "Introduction")
    slide_bullets(c, [
        "Small digital or cash purchases are easy to forget.",
        "Notebook entry is slow and provides little long-term analysis.",
        "Bank applications confirm transfers but are not category budget tools.",
        "Slips already contain amount, date, recipient, and reference.",
        "The objective is privacy-preserving entry with a final human review.",
    ], 48, 405, 840, 17)
    c.showPage()

    slide_base(c, 3, "Related work and design position", "Related work")
    cols = [
        ("Notebook", "Private and offline", "No OCR or analysis"),
        ("Cloud app", "Sync and rich charts", "Account and cloud receipt"),
        ("Banking app", "Trusted transfer data", "Limited personal budgets"),
        ("BahtBuddy", "Local OCR and ledger", "Review before save"),
    ]
    x = 42
    for i, (name, strength, gap) in enumerate(cols):
        c.setFillColor(WHITE); c.roundRect(x, 120, 205, 245, 14, fill=1, stroke=0)
        c.setFillColor(TEAL if i == 3 else NAVY)
        c.roundRect(x, 315, 205, 50, 14, fill=1, stroke=0)
        c.setFillColor(WHITE); c.setFont("SegoeBold", 16); c.drawCentredString(x + 102, 335, name)
        c.setFillColor(NAVY); c.setFont("SegoeBold", 12)
        c.drawString(x + 16, 280, "Strength")
        slide_paragraph(c, strength, x + 16, 260, 170, 11, 15)
        c.setFillColor(NAVY); c.setFont("SegoeBold", 12)
        c.drawString(x + 16, 210, "Limitation / role")
        slide_paragraph(c, gap, x + 16, 190, 170, 11, 15)
        x += 220
    c.showPage()

    slide_base(c, 4, "Completed product", "Features")
    left = [
        "Manual expense and income",
        "Slip camera or photo-library entry",
        "Editable OCR draft before save",
        "Duplicate slip-reference check",
        "Recipient category learning",
    ]
    right = [
        "History search and filters",
        "Monthly category budgets",
        "Reports and charts",
        "PIN and biometric lock",
        "CSV/JSON backup and restore",
    ]
    slide_bullets(c, left, 48, 405, 410, 15)
    slide_bullets(c, right, 500, 405, 410, 15)
    c.showPage()

    slide_base(c, 5, "Live interface evidence", "Demonstration")
    c.setFillColor(WHITE); c.roundRect(42, 75, 260, 330, 14, fill=1, stroke=0)
    c.drawImage(str(OUT / "screen_home.png"), 58, 92, width=228, height=295,
                preserveAspectRatio=True, anchor="c")
    c.setFillColor(NAVY); c.setFont("SegoeBold", 13)
    c.drawCentredString(172, 83, "Home")
    c.setFillColor(WHITE); c.roundRect(325, 75, 260, 330, 14, fill=1, stroke=0)
    c.drawImage(str(OUT / "screen_reports.png"), 341, 92, width=228, height=295,
                preserveAspectRatio=True, anchor="c")
    c.setFillColor(NAVY); c.setFont("SegoeBold", 13)
    c.drawCentredString(455, 83, "Reports")
    slide_paragraph(c,
                    "<b>Demonstration flow</b><br/>"
                    "Home → History or Add → manual/Slip entry → Reports.",
                    625, 360, 290, 15, 21)
    slide_paragraph(c,
                    "Figures are authentic screenshots from the Android debug build.",
                    625, 260, 290, 12, 17, MUTED)
    c.showPage()

    slide_base(c, 6, "System architecture", "Methodology")
    boxes = [
        ("Presentation", "Screens · Entry · Shell"),
        ("State", "Riverpod providers"),
        ("Repositories", "Save · Query · Restore"),
        ("Drift/SQLite", "5 typed local tables"),
    ]
    x = 42
    for i, (name, detail) in enumerate(boxes):
        c.setFillColor(NAVY if i % 2 == 0 else TEAL)
        c.roundRect(x, 190, 188, 150, 14, fill=1, stroke=0)
        c.setFillColor(WHITE); c.setFont("SegoeBold", 14)
        c.drawString(x + 14, 300, name)
        c.setFont("Segoe", 11)
        slide_paragraph(c, detail, x + 14, 270, 160, 11, 15, WHITE)
        if i < 3:
            c.setFillColor(NAVY); c.setFont("SegoeBold", 20)
            c.drawString(x + 198, 250, "›")
        x += 226
    slide_paragraph(c,
                    "Adjacent services: ML Kit OCR, slip parser, notifications, exchange-rate cache, and local-auth.",
                    42, 145, 880, 13, 17)
    c.showPage()

    slide_base(c, 7, "Slip and transaction workflow", "Implementation")
    workflow = [
        ("1", "Image"),
        ("2", "OCR"),
        ("3", "Parser"),
        ("4", "Review"),
        ("5", "Validate"),
        ("6", "SQLite"),
    ]
    x = 42
    for i, (n, label) in enumerate(workflow):
        c.setFillColor(TEAL); c.circle(x + 45, 285, 36, fill=1, stroke=0)
        c.setFillColor(WHITE); c.setFont("SegoeBold", 18)
        c.drawCentredString(x + 45, 278, n)
        c.setFillColor(NAVY); c.setFont("SegoeBold", 13)
        c.drawCentredString(x + 45, 225, label)
        if i < 5:
            c.setStrokeColor(NAVY); c.setLineWidth(2)
            c.line(x + 81, 285, x + 115, 285)
        x += 148
    slide_paragraph(c,
                    "<b>Safety rule:</b> OCR proposes fields; the user confirms the amount, category, date, recipient, and reference. Duplicate references are blocked unless the user is editing the existing record.",
                    42, 175, 870, 14, 19)
    c.showPage()

    slide_base(c, 8, "Data model", "Implementation")
    rows = [
        ("Categories", "Code, English/Thai name, income flag"),
        ("MoneyTransactions", "Amount, type, category, date, recipient, slip reference"),
        ("Budgets", "One monthly limit per category"),
        ("RecipientRules", "Normalized recipient → learned category"),
        ("Preferences", "Theme, language, PIN, biometrics, reminder, timezone"),
    ]
    y = 410
    for name, detail in rows:
        c.setFillColor(NAVY)
        c.roundRect(42, y - 35, 220, 50, 10, fill=1, stroke=0)
        c.setFillColor(WHITE); c.setFont("SegoeBold", 12)
        c.drawCentredString(152, y - 16, name)
        c.setFillColor(WHITE); c.roundRect(278, y - 35, 640, 50, 10, fill=1, stroke=0)
        c.setFillColor(INK); c.setFont("Segoe", 12)
        c.drawString(298, y - 16, detail)
        y -= 65
    c.showPage()

    slide_base(c, 9, "Testing and validation", "Results")
    cards = [
        ("Parser", "Thai/English slip text, dates, references"),
        ("Repository", "Duplicate references and category learning"),
        ("Widget", "Manual entry and slip confirmation"),
        ("Android", "Home, history, reports, add, and settings"),
    ]
    x = 42
    for i, (name, detail) in enumerate(cards):
        c.setFillColor(WHITE); c.roundRect(x, 150, 205, 220, 14, fill=1, stroke=0)
        c.setFillColor(TEAL); c.rect(x, 320, 205, 50, fill=1, stroke=0)
        c.setFillColor(WHITE); c.setFont("SegoeBold", 15)
        c.drawCentredString(x + 102, 338, name)
        slide_paragraph(c, detail, x + 18, 285, 170, 12, 16)
        x += 220
    slide_paragraph(c,
                    "<b>Verified evidence:</b> the complete Flutter suite passed 23 tests on 24 November 2026. Android emulator workflows were exercised for Home, History, Reports, Add/Slip, and Settings.",
                    42, 125, 880, 12, 16, MUTED)
    c.showPage()

    slide_base(c, 10, "Limitations and future work", "Evaluation")
    slide_bullets(c, [
        "The configured ML Kit recognizer uses the Latin model, not complete Thai-script OCR.",
        "No controlled 50-slip OCR accuracy study has been completed.",
        "Cloud synchronization is intentionally outside the local-first scope.",
        "Future work: Thai recognition, dataset evaluation, encrypted backup, and optional synchronization.",
        "Future evaluation: usability testing and SUS/task-completion metrics.",
    ], 48, 405, 840, 15)
    c.showPage()

    slide_base(c, 11, "Conclusion and team responsibilities", "Conclusion")
    slide_paragraph(c,
                    "<b>Conclusion</b><br/>"
                    "BahtBuddy provides a complete local-first course implementation combining slip-assisted entry, SQLite storage, budgets, reports, security, and customization.",
                    48, 390, 860, 16, 21)
    slide_paragraph(c,
                    "<b>Jirathiwat Suntipreedatham — 6788122</b><br/>"
                    "Frontend UI, Riverpod state, reports, testing, documentation, presentation.",
                    48, 270, 860, 13, 18)
    slide_paragraph(c,
                    "<b>Sakkaraj Tuvajit — 6788140</b><br/>"
                    "Database, repositories, OCR/parser integration, services, platform configuration.",
                    48, 205, 860, 13, 18)
    slide_paragraph(c,
                    "Source: github.com/Sakkaraj/BahtBuddy",
                    48, 115, 860, 12, 16, MUTED)
    c.showPage()

    c.save()


if __name__ == "__main__":
    build_report()
    build_slides()
    print(f"Final report and slide deck written to {OUT}")
