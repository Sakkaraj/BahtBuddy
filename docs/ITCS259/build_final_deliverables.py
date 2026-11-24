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
from PIL import Image as PILImage


OUT = Path(__file__).resolve().parent
ROOT = OUT.parent.parent

pdfmetrics.registerFont(TTFont("Segoe", r"C:\Windows\Fonts\segoeui.ttf"))
pdfmetrics.registerFont(TTFont("SegoeBold", r"C:\Windows\Fonts\segoeuib.ttf"))
pdfmetrics.registerFont(TTFont("SegoeSemi", r"C:\Windows\Fonts\seguisb.ttf"))
_FONT = ROOT / "assets" / "fonts"
pdfmetrics.registerFont(TTFont("Jakarta", str(_FONT / "PlusJakartaSans-Regular.ttf")))
pdfmetrics.registerFont(TTFont("JakartaMed", str(_FONT / "PlusJakartaSans-Medium.ttf")))
pdfmetrics.registerFont(TTFont("JakartaSemi", str(_FONT / "PlusJakartaSans-SemiBold.ttf")))
pdfmetrics.registerFont(TTFont("JakartaBold", str(_FONT / "PlusJakartaSans-Bold.ttf")))
pdfmetrics.registerFont(TTFont("JakartaExtra", str(_FONT / "PlusJakartaSans-ExtraBold.ttf")))

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


def fitted_image(name, height):
    path = OUT / name
    with PILImage.open(path) as im:
        aspect = im.width / float(im.height)
    image = RLImage(str(path), width=height * aspect, height=height)
    image.hAlign = "CENTER"
    return image


PAGES = [
    ("screen_home.png", "Home: month balance, safe-to-spend, rates, and shortcuts."),
    ("screen_history.png", "History: search, income or expense filter, and the ledger."),
    ("screen_reports.png", "Reports: period balance, glance facts, and spending tips."),
    ("screen_reports_charts.png", "Reports: category share and spending over the month."),
    ("screen_settings.png", "Settings: theme, language, time zone, lock, and reminders."),
    ("screen_timezone.png", "Time zone: follow the phone, or choose another zone."),
    ("screen_expense.png", "Expense entry: amount, category, date, note, and receipt."),
    ("screen_income.png", "Income entry: salary plus bonus, freelance, gift, and other types."),
    ("screen_budgets.png", "Budgets: a monthly limit for each expense category."),
    ("screen_exchange.png", "Exchange: this month’s balance converted into each currency."),
    ("screen_add.png", "Add: camera, photo library, or manual entry."),
]


def add_screen_gallery(story):
    height = 180 * mm
    col = 87 * mm
    for start in range(0, len(PAGES), 2):
        chunk = PAGES[start:start + 2]
        images, captions = [], []
        for offset, (name, caption) in enumerate(chunk):
            number = start + offset + 1
            images.append(fitted_image(name, height))
            captions.append(para(f"<b>Figure A{number}.</b> {caption}", S["caption"]))
        while len(images) < 2:
            images.append("")
            captions.append("")
        table = Table([images, captions], colWidths=[col, col])
        table.setStyle(TableStyle([
            ("VALIGN", (0, 0), (-1, -1), "TOP"),
            ("ALIGN", (0, 0), (-1, -1), "CENTER"),
            ("LEFTPADDING", (0, 0), (-1, -1), 4),
            ("RIGHTPADDING", (0, 0), (-1, -1), 4),
            ("TOPPADDING", (0, 0), (-1, 0), 6),
            ("BOTTOMPADDING", (0, -1), (-1, -1), 8),
        ]))
        story.append(table)


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
                ["3", "Methodology"],
                ["4", "Results"],
                ["5", "Conclusion"],
                ["6", "Responsibilities of Each Team Member"],
                ["7", "References"],
                ["A", "Interface screenshots"],
                ["B", "Principal source files"],
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
        section_heading("3", "Methodology"),
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
        para("3.5 Technology stack", S["h2"]),
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
        para("3.6 Implementation", S["h2"]),
        para("3.6.1 Data model", S["h2"]),
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
        para("3.6.2 Transaction persistence and duplicate protection", S["h2"]),
        Preformatted(
            "if (reference != null) {\n"
            "  final existing =\n"
            "      await _db.transactionByReference(reference);\n"
            "  if (existing != null && existing.id != draft.id) {\n"
            "    return SaveStatus.duplicate;\n"
            "  }\n"
            "}\n"
            "if (draft.id == null) {\n"
            "  await _db.insertTransaction(companion);\n"
            "} else {\n"
            "  await _db.updateTransaction(draft.id!, companion);\n"
            "}\n"
            "await _db.learnRecipient(\n"
            "  CategorySuggester.normalize(recipient), draft.categoryId);",
            S["code"],
        ),
        para(
            "A duplicate is prevented when a slip reference already exists, unless the user is editing the same transaction. Blank references are not enforced as unique values.",
            S["body"],
        ),
        para("3.6.3 Rule-based slip parsing", S["h2"]),
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
        para("3.6.4 Reporting logic", S["h2"]),
        para(
            "The reports page calculates period balances, average daily spending, comparison with the previous period, category proportions, and ranked textual tips. A tip engine warns for spending above income, high category concentration, a 15 percent or larger period change, thin or strong remaining balances, forecast daily pace, and unusually large individual records.",
            S["body"],
        ),
    ]

    story += [
        section_heading("4", "Results"),
        para(
            "The finished application includes Home, History, Reports, Settings, expense entry, income entry, budgets, the add sheet, the exchange converter, and the time-zone picker. Appendix A presents the corresponding screens. Android and iOS share one Flutter widget tree. The Material theme sets the platform to Android and uses the same page transition and scroll physics on both, so the two builds present the same interface.",
            S["body"],
        ),
    ]
    story += [
        para("4.1 Implemented features", S["h2"]),
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
                ["Localization and themes", "Completed", "English/Thai and six visual themes"],
                ["Time zone", "Completed", "Automatic phone zone or a chosen IANA zone, on Android and iOS"],
                ["Exchange rates", "Completed", "Month balance converted with a cached Frankfurter rate"],
            ],
            [46 * mm, 25 * mm, 101 * mm],
        ),
    ]

    story += [
        para("4.2 Testing and evaluation", S["h2"]),
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
                ["bangkok_time_test.dart", "Wall-clock conversion and a selected time zone",
                 "Unit tests"],
            ],
            [42 * mm, 92 * mm, 38 * mm],
        ),
        para("4.2.1 Emulator verification", S["h2"]),
        para(
            "Every route and sheet in Appendix A was opened on the Android emulator: Home, History, Reports, Settings, expense entry, income entry, budgets, the add sheet, the currency converter, and the time-zone list. No new record was saved during that check. The figures use the ledger already on the device and are presented as interface evidence.",
            S["body"],
        ),
        para("4.2.2 Evaluation status", S["h2"]),
        para(
            "<b>Verified status:</b> the complete Flutter test suite passed on 24 November 2026 with 23 tests successful and no failures. Coverage includes Bangkok time-zone behavior, duplicate references, history filtering, PIN-pad behavior, manual entry, slip confirmation, exchange-rate parsing, report tips, and repository learning. OCR accuracy was not measured on a recorded 50-slip data set, so that item remains future work rather than a claimed achievement.",
            S["body"],
        ),
    ]

    story += [
        para("4.3 Limitations and future work", S["h2"]),
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
        section_heading("5", "Conclusion"),
        para(
            "BahtBuddy is a complete local-first mobile application for personal financial tracking. The implementation covers manual entry, slip-assisted text recognition with user confirmation, SQLite persistence, category budgets, history, reports, alerts, localization, authentication, and backup and restore. Recognized slip text remains a draft until the user verifies it. Period tips are produced by deterministic rules applied to the stored ledger.",
            S["body"],
        ),
        para(
            "Future work should prioritize Thai OCR evaluation, a measured slip-accuracy protocol, encrypted backup protection, and optional synchronization. These improvements would strengthen the scientific evidence and security posture without changing the application’s privacy-preserving local core.",
            S["body"],
        ),
    ]

    story += [
        section_heading("6", "Responsibilities of Each Team Member"),
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
        PageBreak(),
        section_heading("7", "References"),
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
        para("Appendix A. Interface Screenshots", S["h1"]),
        para(
            "Figures A1–A11 were captured from the Android debug build on 24 November 2026. The sample ledger contains ฿600 of income and ฿20 of food expense, giving a month balance of ฿580. Image proportions follow the 1344×2992 capture. The same screens are produced on iOS by the shared Flutter code and the Android visual theme described in Section 4.",
            S["body"],
        ),
    ]
    add_screen_gallery(story)
    story += [
        para("Appendix B. Principal Source Files", S["h1"]),
        para(
            "The repository contains the Flutter project, Android and iOS project configuration, the automated test folder, and this report. Table B1 maps the principal implementation files to the architecture in Section 3.",
            S["body"],
        ),
        academic_table(
            ["Component", "Source file"],
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

DEEP = HexColor("#0B3A82")
OCEAN = HexColor("#1D4ED8")
SKY = HexColor("#38BDF8")
SLIDE_INK = HexColor("#0E1C2F")
SLIDE_TEAL = HexColor("#0E9F8A")
SLIDE_GREEN = HexColor("#12B981")
SLIDE_RED = HexColor("#FF5A6A")
SLIDE_MUTED = HexColor("#5C6E82")
MIST = HexColor("#E7F2FB")
CARD_SHADOW = HexColor("#C5D7EE")


def _mix(a, b, t):
    return colors.Color(
        a.red + (b.red - a.red) * t,
        a.green + (b.green - a.green) * t,
        a.blue + (b.blue - a.blue) * t,
    )


def hgrad(c, x, y, w, h, left, right, steps=48):
    c.saveState()
    path = c.beginPath()
    path.rect(x, y, w, h)
    c.clipPath(path, stroke=0, fill=0)
    for i in range(steps):
        c.setFillColor(_mix(left, right, i / (steps - 1)))
        c.rect(x + w * i / steps, y, w / steps + 1, h, stroke=0, fill=1)
    c.restoreState()


def vgrad(c, x, y, w, h, top, bottom, steps=36):
    c.saveState()
    path = c.beginPath()
    path.rect(x, y, w, h)
    c.clipPath(path, stroke=0, fill=0)
    for i in range(steps):
        c.setFillColor(_mix(bottom, top, i / (steps - 1)))
        c.rect(x, y + h * i / steps, w, h / steps + 1, stroke=0, fill=1)
    c.restoreState()


def slide_paragraph(c, text, x, y, width, size=16, leading=21, color=SLIDE_INK, font="Jakarta", align="left"):
    style = ParagraphStyle(
        "slide", fontName=font, fontSize=size, leading=leading, textColor=color,
        alignment=TA_CENTER if align == "center" else TA_LEFT,
    )
    block = Paragraph(text, style)
    _, height = block.wrap(width, H)
    block.drawOn(c, x, y - height)
    return height


def soft_card(c, x, y, w, h, radius=18):
    c.setFillColor(CARD_SHADOW)
    c.roundRect(x + 2, y - 3, w, h, radius, fill=1, stroke=0)
    c.setFillColor(WHITE)
    c.roundRect(x, y, w, h, radius, fill=1, stroke=0)


def pill(c, x, y, text, fill=SLIDE_TEAL, size=9):
    c.setFont("JakartaSemi", size)
    width = c.stringWidth(text, "JakartaSemi", size) + 16
    c.setFillColor(fill)
    c.roundRect(x, y - 4, width, size + 10, (size + 10) / 2, fill=1, stroke=0)
    c.setFillColor(WHITE)
    c.drawString(x + 8, y, text)
    return width


def slide_chrome(c, number, title, kicker):
    vgrad(c, 0, 0, W, H, HexColor("#D7E8FB"), HexColor("#F8FBFF"))
    c.setFillColor(HexColor("#D3E6FA"))
    c.circle(910, 500, 70, fill=1, stroke=0)
    hgrad(c, 0, H - 86, W, 86, DEEP, SKY)
    c.setFillColor(SLIDE_TEAL)
    c.rect(0, H - 90, W, 4, fill=1, stroke=0)
    c.setFillColor(HexColor("#D7F6F0"))
    c.setFont("JakartaSemi", 10)
    c.drawString(36, H - 32, kicker.upper())
    c.setFillColor(WHITE)
    c.setFont("JakartaBold", 24)
    c.drawString(36, H - 62, title)
    c.setFillColor(SLIDE_INK)
    c.rect(0, 0, W, 28, fill=1, stroke=0)
    c.setFillColor(SLIDE_TEAL)
    c.circle(22, 14, 4, fill=1, stroke=0)
    c.setFillColor(WHITE)
    c.setFont("Jakarta", 10)
    c.drawString(34, 10, "BahtBuddy  ·  Ocean theme  ·  ITCS259")
    c.setFillColor(HexColor("#9FB0C4"))
    c.drawRightString(W - 58, 10, "26 November 2026")
    c.setFillColor(SLIDE_TEAL)
    c.roundRect(W - 46, 6, 30, 16, 8, fill=1, stroke=0)
    c.setFillColor(WHITE)
    c.setFont("JakartaSemi", 9)
    c.drawCentredString(W - 31, 10, f"{number:02d}")


def phone_box(path, height):
    with PILImage.open(path) as im:
        return height * im.width / float(im.height), height


def draw_phone(c, path, x, y, height):
    width, box_h = phone_box(path, height)
    c.setFillColor(HexColor("#B9D0EA"))
    c.roundRect(x + 3, y - 4, width, box_h, 16, fill=1, stroke=0)
    c.setFillColor(WHITE)
    c.setStrokeColor(HexColor("#D5E6F6"))
    c.setLineWidth(1)
    c.roundRect(x - 4, y - 4, width + 8, box_h + 8, 18, fill=1, stroke=1)
    c.drawImage(
        str(path), x, y, width=width, height=box_h,
        preserveAspectRatio=True, anchor="c", mask="auto",
    )
    return width


def gallery(c, number, title, kicker, intro, items):
    slide_chrome(c, number, title, kicker)
    slide_paragraph(c, intro, 36, 438, 880, 12, 16, SLIDE_MUTED, "JakartaMed")
    height = 286
    widths = [phone_box(OUT / name, height)[0] for name, _cap, _fact in items]
    gap = 36
    total = sum(widths) + gap * (len(items) - 1)
    x = (W - total) / 2
    for (name, caption, fact), width in zip(items, widths):
        draw_phone(c, OUT / name, x, 108, height)
        c.setFillColor(SLIDE_INK)
        c.setFont("JakartaBold", 12)
        c.drawCentredString(x + width / 2, 88, caption)
        slide_paragraph(
            c, fact, x - 6, 76, width + 12, 9, 11.5, SLIDE_MUTED, "Jakarta", "center",
        )
        x += width + gap


def build_slides():
    path = OUT / "BahtBuddy_Presentation_Slides.pdf"
    c = canvas.Canvas(str(path), pagesize=(W, H))
    c.setTitle("BahtBuddy — ITCS259 Final Presentation")
    c.setAuthor("Jirathiwat Suntipreedatham and Sakkaraj Tuvajit")

    # 1 Cover — Ocean banner, the same gradient as the home balance card.
    hgrad(c, 0, 0, W, H, DEEP, SKY)
    c.setFillColor(HexColor("#1677C9"))
    c.circle(820, 250, 210, fill=1, stroke=0)
    c.setFillColor(HexColor("#0A3474"))
    c.circle(880, 460, 80, fill=1, stroke=0)
    draw_phone(c, OUT / "screen_home.png", 690, 48, 430)
    c.setFillColor(HexColor("#D7F6F0"))
    c.setFont("JakartaSemi", 12)
    c.drawString(44, H - 64, "ITCS259   ·   MOBILE APPLICATION DEVELOPMENT")
    c.setFillColor(WHITE)
    c.setFont("JakartaExtra", 52)
    c.drawString(44, H - 128, "BahtBuddy")
    slide_paragraph(
        c,
        "A local money app for a Thai student. The ledger stays on the phone. A slip becomes a draft, and you confirm it before it is saved.",
        44, H - 150, 600, 15, 21, HexColor("#E7F4FF"), "Jakarta",
    )
    facts = [
        ("On this phone", "SQLite ledger, no account"),
        ("Slip review", "Latin text, then you confirm"),
        ("English and Thai", "Six themes; Ocean is shown"),
        ("23 tests", "Passed 24 November 2026"),
    ]
    x = 44
    for title, detail in facts:
        c.setFillColor(HexColor("#F4F9FF"))
        c.roundRect(x, 108, 146, 84, 14, fill=1, stroke=0)
        c.setFillColor(SLIDE_TEAL)
        c.rect(x, 108, 146, 4, fill=1, stroke=0)
        c.setFillColor(SLIDE_INK)
        c.setFont("JakartaBold", 11)
        c.drawString(x + 12, 166, title)
        slide_paragraph(c, detail, x + 12, 156, 122, 9, 12, SLIDE_MUTED)
        x += 158
    c.setFillColor(WHITE)
    c.setFont("JakartaMed", 13)
    c.drawString(44, 78, "Jirathiwat Suntipreedatham  ·  6788122")
    c.drawString(44, 56, "Sakkaraj Tuvajit  ·  6788140")
    c.setFillColor(HexColor("#D7F6F0"))
    c.setFont("Jakarta", 11)
    c.drawString(44, 28, "Final presentation  ·  26 November 2026  ·  4 minutes")
    c.showPage()

    # 2 Problem
    slide_chrome(c, 2, "Why a student still loses the month", "Introduction")
    problems = [
        ("The moment passes", "A coffee, a bus fare, or a transfer is easy to forget once the screen is gone. The month becomes a guess."),
        ("A notebook is private", "It works with no account and no network. It cannot read a slip, budget a category, or show the month."),
        ("A bank app confirms", "The transfer is trusted. Cash, a personal category, and a tip about this month sit outside that screen."),
    ]
    x = 32
    for title, body in problems:
        soft_card(c, x, 168, 290, 230)
        c.setFillColor(SLIDE_TEAL)
        c.circle(x + 28, 358, 8, fill=1, stroke=0)
        c.setFillColor(SLIDE_INK)
        c.setFont("JakartaBold", 16)
        c.drawString(x + 46, 352, title)
        slide_paragraph(c, body, x + 20, 328, 250, 13, 18)
        x += 306
    hgrad(c, 32, 48, 896, 100, DEEP, OCEAN)
    c.setFillColor(WHITE)
    c.setFont("JakartaBold", 14)
    c.drawString(52, 118, "Design response")
    slide_paragraph(
        c,
        "The ledger, the budgets, and the tips stay on the phone. A record can come from the camera, the photo library, or a typed amount. The slip remains a draft until the user saves it. The interface is available in English and Thai, with six visual themes.",
        52, 108, 850, 12, 16, HexColor("#E7F4FF"),
    )
    c.showPage()

    # 3 Related work
    slide_chrome(c, 3, "Where BahtBuddy sits", "Related work")
    rows = [
        ["", "Notebook", "Cloud app", "Bank app", "BahtBuddy"],
        ["Offline", "Yes", "Account required", "Partial", "Yes, the ledger is local"],
        ["A transfer slip", "Copy by hand", "Upload the image", "No reading", "On device, then confirm"],
        ["Cash and transfer", "Both, by hand", "Usually both", "Mostly the transfer", "Both, one entry form"],
        ["Budget and tips", "None", "Often in the cloud", "Rarely", "Local rules, no model"],
        ["Who can read it", "Only you", "The service", "The bank", "This phone only"],
    ]
    col_w = [150, 170, 180, 180, 196]
    row_h = 46
    top = 424
    left = 36
    total_w = sum(col_w)
    for r, row in enumerate(rows):
        yy = top - (r + 1) * row_h
        if r == 0:
            hgrad(c, left, yy, total_w, row_h, DEEP, OCEAN)
        else:
            c.setFillColor(WHITE if r % 2 else MIST)
            c.rect(left, yy, total_w, row_h, stroke=0, fill=1)
            c.setFillColor(HexColor("#E5F7F3"))
            c.rect(left + sum(col_w[:-1]), yy, col_w[-1], row_h, stroke=0, fill=1)
        cx = left
        for i, (cell, w) in enumerate(zip(row, col_w)):
            if r == 0:
                color, font, size = WHITE, "JakartaSemi", 11
            elif i == 0:
                color, font, size = SLIDE_INK, "JakartaSemi", 11
            elif i == len(row) - 1:
                color, font, size = HexColor("#0B6B5C"), "JakartaSemi", 10.5
            else:
                color, font, size = SLIDE_INK, "Jakarta", 10.5
            slide_paragraph(c, cell, cx + 10, yy + row_h - 14, w - 18, size, size + 3, color, font)
            cx += w
    slide_paragraph(
        c,
        "The parser still understands Thai and English amount labels. The recognizer itself reads Latin letters and digits, so the review form stays mandatory.",
        40, 118, 880, 12, 16, SLIDE_MUTED, "JakartaMed",
    )
    c.showPage()

    # 4 Features
    slide_chrome(c, 4, "What the finished app can do", "The application")
    features = [
        ("Entry", SLIDE_TEAL, "Expense in red, income in green. The baht sign stays with the amount. Date, note, shop, and reference."),
        ("Categories", OCEAN, "Food through Other for spending. Salary, bonus, freelance, gift, interest, refund, and other income."),
        ("Slip draft", SLIDE_TEAL, "Camera or photo library. Latin text is parsed into fields. Nothing is written until you press Save."),
        ("Budgets", OCEAN, "One monthly limit for each expense category. The phone warns when a category crosses 80% and 100%."),
        ("Reports", SLIDE_TEAL, "Today, this week, or this month. Kept share, a day’s pace, last period, category share, and the month line."),
        ("Local tips", OCEAN, "Ranked from the ledger: spending above income, one category taking the month, a thin buffer, a large row."),
        ("Six currencies", SLIDE_TEAL, "This month’s baht balance in USD, EUR, JPY, CNY, GBP, and SGD. The board is cached after Frankfurter."),
        ("Zone, lock, backup", OCEAN, "Follow the phone or pick a zone. A hashed PIN and biometrics. A JSON backup you can restore later."),
    ]
    for i, (title, tone, body) in enumerate(features):
        col, row = i % 4, i // 4
        x = 28 + col * 232
        y = 246 - row * 176
        soft_card(c, x, y, 220, 164)
        c.setFillColor(tone)
        c.roundRect(x + 14, y + 124, 8, 22, 4, fill=1, stroke=0)
        c.setFillColor(SLIDE_INK)
        c.setFont("JakartaBold", 13)
        c.drawString(x + 30, y + 128, title)
        slide_paragraph(c, body, x + 14, y + 114, 192, 10.5, 14)
    c.showPage()

    gallery(c, 5, "The four tabs", "Application",
            "Home shows this month. History is the ledger. Reports explain it. Settings holds the look, the language, the zone, and the lock.",
            [
                ("screen_home.png", "Home", "฿580 this month, and the balance in six currencies."),
                ("screen_history.png", "History", "Search, then All, Expense, or Income."),
                ("screen_reports.png", "Reports", "Kept 97%. Two tips from three rows."),
                ("screen_settings.png", "Settings", "Ocean, English, and the zone on Automatic."),
            ])
    c.showPage()

    gallery(c, 6, "How a record gets in", "Application",
            "The add sheet offers the camera, the photo library, or a manual amount. Expense opens in red. Income opens in green, with more than salary.",
            [
                ("screen_add.png", "Add", "Scan a slip, or enter cash that has no picture."),
                ("screen_expense.png", "Expense", "Food first. The baht sign stays on the amount."),
                ("screen_income.png", "Income", "Salary, bonus, freelance, gift, and more."),
                ("screen_budgets.png", "Budgets", "A monthly limit on each expense category."),
            ])
    c.showPage()

    gallery(c, 7, "Rates, the zone, and the month line", "Application",
            "The chips and the converter use this month’s balance. The clock follows the phone, or a zone you pick. The report line is the real spending, day by day.",
            [
                ("screen_exchange.png", "Exchange", "฿580.00 becomes 17.04 USD on the 23 November board."),
                ("screen_timezone.png", "Time zone", "Automatic is Asia/Bangkok, GMT+7, on this phone."),
                ("screen_reports_charts.png", "Over time", "Food is the one expense, on the day it was saved."),
            ])
    c.showPage()

    # 8 Architecture
    slide_chrome(c, 8, "How a tap becomes a saved row", "Methodology")
    layers = [
        ("Screens", "Home, History, Reports, Settings, entry, and budgets."),
        ("Riverpod", "The open pages share one state, including the active time zone."),
        ("Repositories", "Save a row, refuse a repeated slip reference, export a backup."),
        ("SQLite", "Categories, the ledger, budgets, recipient rules, and preferences."),
    ]
    y = 360
    for i, (name, detail) in enumerate(layers):
        hgrad(c, 32, y, 430, 58, DEEP if i < 3 else SLIDE_TEAL, OCEAN if i < 3 else HexColor("#14B8A6"))
        c.setFillColor(WHITE)
        c.setFont("JakartaBold", 14)
        c.drawString(48, y + 32, name)
        slide_paragraph(c, detail, 48, y + 26, 398, 11, 14, HexColor("#E7F4FF"))
        if i < 3:
            c.setFillColor(SLIDE_TEAL)
            c.setFont("JakartaBold", 12)
            c.drawCentredString(247, y - 14, "↓")
        y -= 76
    soft_card(c, 488, 78, 440, 336)
    c.setFillColor(SLIDE_TEAL)
    c.setFont("JakartaBold", 14)
    c.drawString(508, 386, "On the phone")
    stack = [
        "Flutter and Dart, Material 3, Plus Jakarta Sans",
        "Riverpod for state, go_router for the four tabs",
        "Drift and SQLite, schema version 3",
        "fl_chart for the share and the month line",
        "ML Kit text recognition, Latin script",
        "A rule parser for Thai and English labels",
        "flutter_timezone, so Automatic matches the phone",
        "local_auth for the PIN and biometrics",
        "Frankfurter for the rate board, then a local cache",
        "One network call, dated in the active zone",
    ]
    yy = 352
    for item in stack:
        c.setFillColor(SLIDE_TEAL)
        c.circle(516, yy - 4, 3, fill=1, stroke=0)
        slide_paragraph(c, item, 528, yy + 6, 380, 11, 14)
        yy -= 28
    c.showPage()

    # 9 Slip path
    slide_chrome(c, 9, "From a slip to a saved record", "Implementation")
    steps = [
        ("1", "Image", "Camera or the photo library. The picture stays with the draft."),
        ("2", "Read", "ML Kit returns Latin letters, digits, and the reference line."),
        ("3", "Parse", "Rules take the amount, the date, the shop, and the reference."),
        ("4", "Review", "Every field can change. A past recipient can suggest the category."),
        ("5", "Check", "A reference already stored in the ledger is refused."),
        ("6", "Save", "The row is stored at that moment in the active time zone."),
    ]
    for i, (num, title, body) in enumerate(steps):
        col, row = i % 3, i // 3
        x = 32 + col * 308
        y = 248 - row * 168
        soft_card(c, x, y, 294, 152)
        c.setFillColor(SLIDE_TEAL)
        c.circle(x + 28, y + 112, 16, fill=1, stroke=0)
        c.setFillColor(WHITE)
        c.setFont("JakartaBold", 13)
        c.drawCentredString(x + 28, y + 107, num)
        c.setFillColor(SLIDE_INK)
        c.setFont("JakartaBold", 15)
        c.drawString(x + 54, y + 106, title)
        slide_paragraph(c, body, x + 16, y + 86, 262, 12, 16)
    c.showPage()

    # 10 Time, rates, lock
    slide_chrome(c, 10, "Time, money in other units, and the lock", "Implementation")
    blocks = [
        (SLIDE_TEAL, "Time zone", [
            "Automatic reads the phone’s IANA zone. On this emulator that is Asia/Bangkok, GMT+7.",
            "You can pick another zone. Day grouping, reports, and the rate request follow it.",
            "A stored row keeps its instant. The screen shows that instant in the zone you chose.",
            "The daily reminder, when it is on, fires in that same zone.",
        ]),
        (OCEAN, "Exchange", [
            "The home chips convert this month’s balance, not a single mid-market quote.",
            "USD, EUR, JPY, CNY, GBP, and SGD. Yen is shown with no decimals.",
            "The request asks Frankfurter for the active zone’s calendar day, then falls back to the latest board.",
            "The board is cached, so the chips still appear when the network is down.",
        ]),
        (DEEP, "Lock and backup", [
            "The PIN is stored as a hash. Biometrics uses the phone’s own secure check.",
            "Backup writes versioned JSON, including the time zone choice.",
            "Restore reads the file you pick. A missing zone comes back as Automatic.",
            "Sharing the file uses the system sheet on Android and on iPhone.",
        ]),
    ]
    x = 28
    for tone, title, lines in blocks:
        soft_card(c, x, 52, 296, 360)
        c.setFillColor(tone)
        c.roundRect(x, 364, 296, 48, 18, fill=1, stroke=0)
        c.rect(x, 364, 296, 20, fill=1, stroke=0)
        c.setFillColor(WHITE)
        c.setFont("JakartaBold", 16)
        c.drawString(x + 16, 380, title)
        yy = 340
        for line in lines:
            c.setFillColor(tone)
            c.circle(x + 18, yy - 6, 3.5, fill=1, stroke=0)
            h = slide_paragraph(c, line, x + 30, yy + 6, 248, 11, 14)
            yy -= max(h + 12, 48)
        x += 312
    c.showPage()

    # 11 Testing
    slide_chrome(c, 11, "What was checked, and what was not", "Results")
    soft_card(c, 28, 48, 520, 364)
    c.setFillColor(SLIDE_GREEN)
    c.roundRect(48, 360, 150, 26, 13, fill=1, stroke=0)
    c.setFillColor(WHITE)
    c.setFont("JakartaBold", 12)
    c.drawCentredString(123, 368, "23 passed")
    c.setFillColor(SLIDE_INK)
    c.setFont("JakartaBold", 14)
    c.drawString(210, 366, "24 November 2026")
    tests = [
        ("slip_parser_test", "Thai and English slips, dates, references, categories"),
        ("duplicate_test", "A stored slip reference is rejected"),
        ("widget_test", "Manual save, and the slip confirmation fields"),
        ("exchange_rates_test", "Baht converted with the cached board and the dated URL"),
        ("history_filter_test", "Search, type, and the Bangkok day"),
        ("report_tips_test", "Glance facts and the ranked tip rules"),
        ("pin_pad_test", "Six digits complete the PIN"),
        ("bangkok_time_test", "Wall clock, a picked time, and a chosen UTC zone"),
    ]
    yy = 340
    for name, detail in tests:
        c.setFillColor(OCEAN)
        c.setFont("JakartaSemi", 10)
        c.drawString(48, yy, name)
        slide_paragraph(c, detail, 210, yy + 12, 310, 10, 13, SLIDE_MUTED)
        yy -= 34
    soft_card(c, 564, 48, 368, 364)
    c.setFillColor(SLIDE_RED)
    c.roundRect(584, 360, 118, 26, 13, fill=1, stroke=0)
    c.setFillColor(WHITE)
    c.setFont("JakartaBold", 12)
    c.drawCentredString(643, 368, "Limits")
    limits = [
        ("Latin slip text", "Thai script is outside the current recognizer. The user confirms every draft."),
        ("Accuracy study", "A 50-slip corpus was not recorded, so no accuracy score is reported."),
        ("Cloud sync", "The ledger remains on the device. The application has no account."),
        ("Exchange rates", "The first request needs a network. Later views use the saved board."),
        ("iOS build", "The same screens run on iOS. The walkthrough used the Android emulator."),
    ]
    yy = 336
    for title, detail in limits:
        c.setFillColor(SLIDE_INK)
        c.setFont("JakartaBold", 12)
        c.drawString(584, yy, title)
        h = slide_paragraph(c, detail, 584, yy - 4, 328, 11, 14, SLIDE_MUTED)
        yy -= h + 22
    c.showPage()

    # 12 Close
    hgrad(c, 0, 0, W, H, DEEP, SKY)
    c.setFillColor(HexColor("#0A3474"))
    c.circle(860, 430, 90, fill=1, stroke=0)
    c.setFillColor(HexColor("#D7F6F0"))
    c.setFont("JakartaSemi", 12)
    c.drawString(44, H - 52, "CONCLUSION")
    c.setFillColor(WHITE)
    c.setFont("JakartaExtra", 32)
    c.drawString(44, H - 96, "A local ledger for the month")
    slide_paragraph(
        c,
        "BahtBuddy records expenses and income on the phone: a reviewed slip, a ledger, budgets, reports, a lock, and a backup. Tips are calculated from the stored rows.",
        44, H - 118, 860, 14, 19, HexColor("#E7F4FF"),
    )
    shipped = [
        ("Demonstration", "Home balance, Add, an editable draft, History, then Reports."),
        ("Settings", "Ocean theme, Automatic time zone, and ฿580 shown in USD."),
        ("Evidence", "SQLite on the device, Latin slip reading, and 23 passing tests."),
    ]
    x = 44
    for title, body in shipped:
        c.setFillColor(HexColor("#F4F9FF"))
        c.roundRect(x, 168, 286, 110, 16, fill=1, stroke=0)
        c.setFillColor(SLIDE_TEAL)
        c.rect(x, 168, 286, 4, fill=1, stroke=0)
        c.setFillColor(SLIDE_INK)
        c.setFont("JakartaBold", 14)
        c.drawString(x + 16, 244, title)
        slide_paragraph(c, body, x + 16, 230, 254, 12, 16)
        x += 302
    c.setFillColor(WHITE)
    c.setFont("JakartaMed", 12)
    c.drawString(44, 124, "Jirathiwat Suntipreedatham  ·  6788122  —  screens, state, reports, tests, and this presentation")
    c.drawString(44, 102, "Sakkaraj Tuvajit  ·  6788140  —  database, save rules, slip reading, and the phone build")
    c.setFillColor(SLIDE_TEAL)
    c.roundRect(44, 44, 300, 34, 12, fill=1, stroke=0)
    c.setFillColor(WHITE)
    c.setFont("JakartaSemi", 12)
    c.drawString(60, 56, "github.com/Sakkaraj/BahtBuddy")
    c.setFillColor(HexColor("#D7F6F0"))
    c.setFont("Jakarta", 11)
    c.drawRightString(W - 44, 56, "26 November 2026")
    c.showPage()

    c.save()


if __name__ == "__main__":
    build_report()
    build_slides()
    print("Wrote report and slides to", OUT)
