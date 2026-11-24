"""Render labeled transfer slips for the on-device reading check.

Each image is a white confirmation screen in Leelawadee UI. The manifest
records the amount, date, recipient, and reference the parser should recover.
"""

import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

OUT = Path(__file__).resolve().parents[1] / "assets" / "slip_corpus"
FONT = ImageFont.truetype(r"C:\Windows\Fonts\LeelawUI.ttf", 42)
TITLE = ImageFont.truetype(r"C:\Windows\Fonts\LeelaUIb.ttf", 52)

SLIPS = [
    {
        "file": "slip_01.png",
        "lines": ["โอนเงินสำเร็จ", "จำนวนเงิน 65.00 บาท", "วันที่ 17/11/2026 12:30", "ไปยัง 7-Eleven", "เลขที่รายการ 20261117000123"],
        "amount": 65.0, "date": "2026-11-17T12:30:00", "recipient": "7-Eleven", "reference": "20261117000123",
    },
    {
        "file": "slip_02.png",
        "lines": ["PromptPay", "Amount: THB 1,250.50", "Date: 01 Nov 2026", "To: BTS", "Ref: ABC123456789"],
        "amount": 1250.50, "date": "2026-11-01T00:00:00", "recipient": "BTS", "reference": "ABC123456789",
    },
    {
        "file": "slip_03.png",
        "lines": ["โอนเงิน", "120.00 บาท", "17 พ.ย. 2569", "ผู้รับเงิน GrabFood", "เลขอ้างอิง TX99887766"],
        "amount": 120.0, "date": "2026-11-17T00:00:00", "recipient": "GrabFood", "reference": "TX99887766",
    },
    {
        "file": "slip_04.png",
        "lines": ["รายการสำเร็จ", "ยอดเงิน 89.50 บาท", "วันที่ 24/11/2026", "ไปยัง Cafe Amazon", "เลขที่รายการ REF890012"],
        "amount": 89.50, "date": "2026-11-24T00:00:00", "recipient": "Cafe Amazon", "reference": "REF890012",
    },
    {
        "file": "slip_05.png",
        "lines": ["Transfer", "Amount THB 45.00", "02/11/2026 18:05", "To Lotus", "Reference REF450001"],
        "amount": 45.0, "date": "2026-11-02T18:05:00", "recipient": "Lotus", "reference": "REF450001",
    },
    {
        "file": "slip_06.png",
        "lines": ["โอนเงินสำเร็จ", "จำนวนเงิน 2,480.00 บาท", "03/11/2026 09:15", "ไปยัง Big C", "เลขที่รายการ REF248000"],
        "amount": 2480.0, "date": "2026-11-03T09:15:00", "recipient": "Big C", "reference": "REF248000",
    },
    {
        "file": "slip_07.png",
        "lines": ["จ่ายเงิน", "จำนวนเงิน 35.00 บาท", "04/11/2026", "ผู้รับเงิน Tops", "หมายเลขอ้างอิง REF350001"],
        "amount": 35.0, "date": "2026-11-04T00:00:00", "recipient": "Tops", "reference": "REF350001",
    },
    {
        "file": "slip_08.png",
        "lines": ["PromptPay", "฿ 220.00", "05/11/2026 21:40", "Recipient MK", "Transaction ID TX220045"],
        "amount": 220.0, "date": "2026-11-05T21:40:00", "recipient": "MK", "reference": "TX220045",
    },
    {
        "file": "slip_09.png",
        "lines": ["โอนเงินสำเร็จ", "จำนวนเงิน 15.00 บาท", "06 พ.ย. 2569 07:10", "ไปยัง Win", "เลขที่รายการ WIN150006"],
        "amount": 15.0, "date": "2026-11-06T07:10:00", "recipient": "Win", "reference": "WIN150006",
    },
    {
        "file": "slip_10.png",
        "lines": ["Payment", "Amount: 99.00 THB", "07/11/2026", "To: Shopee", "Ref: SH990007"],
        "amount": 99.0, "date": "2026-11-07T00:00:00", "recipient": "Shopee", "reference": "SH990007",
    },
    {
        "file": "slip_11.png",
        "lines": ["โอนเงินสำเร็จ", "ยอดเงิน 500.00 บาท", "08/11/2026 13:13", "ผู้รับเงิน Mama", "เลขที่รายการ MAMA50008"],
        "amount": 500.0, "date": "2026-11-08T13:13:00", "recipient": "Mama", "reference": "MAMA50008",
    },
    {
        "file": "slip_12.png",
        "lines": ["Transfer complete", "Amount: THB 76.25", "09 Nov 2026 16:45", "To: FamilyMart", "Reference FM762512"],
        "amount": 76.25, "date": "2026-11-09T16:45:00", "recipient": "FamilyMart", "reference": "FM762512",
    },
    {
        "file": "slip_13.png",
        "lines": ["โอนเงิน", "จำนวนเงิน 8.50 บาท", "10/11/2026", "ไปยัง 7-Eleven", "เลขอ้างอิง SEV850013"],
        "amount": 8.50, "date": "2026-11-10T00:00:00", "recipient": "7-Eleven", "reference": "SEV850013",
    },
    {
        "file": "slip_14.png",
        "lines": ["PromptPay", "Amount 3,000.00 THB", "11/11/2026 11:11", "To: Tuition", "Ref: EDU300014"],
        "amount": 3000.0, "date": "2026-11-11T11:11:00", "recipient": "Tuition", "reference": "EDU300014",
    },
    {
        "file": "slip_15.png",
        "lines": ["โอนเงินสำเร็จ", "จำนวนเงิน 640.00 บาท", "12 พฤศจิกายน 2569", "ไปยัง BTS", "เลขที่รายการ BTS640015"],
        "amount": 640.0, "date": "2026-11-12T00:00:00", "recipient": "BTS", "reference": "BTS640015",
    },
    {
        "file": "slip_16.png",
        "lines": ["Paid", "THB 18.00", "13/11/2026 08:20", "To: Bus", "Transaction ID BUS180016"],
        "amount": 18.0, "date": "2026-11-13T08:20:00", "recipient": "Bus", "reference": "BUS180016",
    },
    {
        "file": "slip_17.png",
        "lines": ["โอนเงินสำเร็จ", "จำนวนเงิน 1,100.75 บาท", "14/11/2026 19:02", "ผู้รับเงิน Rent", "เลขที่รายการ RENT11017"],
        "amount": 1100.75, "date": "2026-11-14T19:02:00", "recipient": "Rent", "reference": "RENT11017",
    },
    {
        "file": "slip_18.png",
        "lines": ["PromptPay", "Amount: 250.00 บาท", "15/11/2026", "To: Pharmacy", "Ref: MED250018"],
        "amount": 250.0, "date": "2026-11-15T00:00:00", "recipient": "Pharmacy", "reference": "MED250018",
    },
    {
        "file": "slip_19.png",
        "lines": ["โอนเงินสำเร็จ", "ยอดเงิน 42.00 บาท", "16/11/2026 22:05", "ไปยัง KFC", "หมายเลขอ้างอิง KFC420019"],
        "amount": 42.0, "date": "2026-11-16T22:05:00", "recipient": "KFC", "reference": "KFC420019",
    },
    {
        "file": "slip_20.png",
        "lines": ["Transfer", "จำนวนเงิน 999.99 บาท", "20 Nov 2026 10:00", "To: Cinema", "เลขที่รายการ MOV999020"],
        "amount": 999.99, "date": "2026-11-20T10:00:00", "recipient": "Cinema", "reference": "MOV999020",
    },
]


def render(slip):
    width = 900
    line_gap = 86
    height = 80 + line_gap * len(slip["lines"]) + 40
    image = Image.new("RGB", (width, height), "white")
    draw = ImageDraw.Draw(image)
    y = 40
    for index, line in enumerate(slip["lines"]):
        draw.text((48, y), line, fill="#0E1C2F", font=TITLE if index == 0 else FONT)
        y += line_gap
    image.save(OUT / slip["file"], "PNG")


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    manifest = []
    for slip in SLIPS:
        render(slip)
        manifest.append({
            "file": slip["file"],
            "text": "\n".join(slip["lines"]),
            "amount": slip["amount"],
            "date": slip["date"],
            "recipient": slip["recipient"],
            "reference": slip["reference"],
        })
    (OUT / "manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"Wrote {len(manifest)} slips to {OUT}")


if __name__ == "__main__":
    main()
