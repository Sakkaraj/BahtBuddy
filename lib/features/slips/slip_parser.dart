class SlipDraft {
  const SlipDraft({
    this.amount,
    this.date,
    this.recipient,
    this.reference,
    this.rawText = '',
    this.suggestedKey,
  });

  final double? amount;
  final DateTime? date;
  final String? recipient;
  final String? reference;
  final String rawText;
  final String? suggestedKey;

  SlipDraft copyWith({String? suggestedKey}) {
    return SlipDraft(
      amount: amount,
      date: date,
      recipient: recipient,
      reference: reference,
      rawText: rawText,
      suggestedKey: suggestedKey ?? this.suggestedKey,
    );
  }
}

class SlipParser {
  static const _day = r'\d{1,2}';
  static const _monthNames =
      'ม\\.ค\\.|มกราคม|ก\\.พ\\.|กุมภาพันธ์|มี\\.ค\\.|มีนาคม|เม\\.ย\\.|เมษายน|พ\\.ค\\.|พฤษภาคม|มิ\\.ย\\.|มิถุนายน|ก\\.ค\\.|กรกฎาคม|ส\\.ค\\.|สิงหาคม|ก\\.ย\\.|กันยายน|ต\\.ค\\.|ตุลาคม|พ\\.ย\\.|พฤศจิกายน|ธ\\.ค\\.|ธันวาคม|jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|jun(?:e)?|jul(?:y)?|aug(?:ust)?|sep(?:t(?:ember)?)?|oct(?:ober)?|nov(?:ember)?|dec(?:ember)?';

  static final _labeledAmount = RegExp(
    r'(?:จำนวนเงิน|ยอดเงิน|amount)\s*[:：]?\s*(?:thb|บาท|฿)?\s*([0-9][0-9,]*(?:\.[0-9]{1,2})?)',
    caseSensitive: false,
  );
  static final _grandTotal = RegExp(
    r'(?:รวมทั้งสิ้น|ยอดสุทธิ|ยอดรวมสุทธิ|รวมสุทธิ|ยอดชำระ|รวมเงิน|รวมราคา|grand\s*total|net\s*total|net\s*amount|amount\s*due|total\s*due|bill\s*total)\s*[:：]?\s*(?:thb|บาท|฿)?\s*([0-9][0-9,]*(?:\.[0-9]{1,2})?)',
    caseSensitive: false,
  );
  static final _plainTotal = RegExp(
    r'(?:^|\s)(?:(?<!sub)total|ยอดรวม|รวมเงิน|รวม)\s*[:：]?\s*(?:thb|บาท|฿)?\s*([0-9][0-9,]*(?:\.[0-9]{1,2})?)',
    caseSensitive: false,
  );
  static final _notTheBill = RegExp(
    r'เงินทอน|change|เงินสด|cash|tender|vat|ภาษี|tax|ส่วนลด|discount|sub\s*total|ยอดย่อย|qty|จำนวน\s*\d',
    caseSensitive: false,
  );
  static final _receiptNo = RegExp(
    r'(?:เลขที่ใบเสร็จ|ใบเสร็จเลขที่|เลขที่บิล|receipt\s*(?:no|number|#)?\.?|tax\s*inv(?:oice)?\.?|bill\s*no\.?)\s*[:：#]?\s*([A-Za-z0-9\-]{4,})',
    caseSensitive: false,
  );
  static final _shopLineSkip = RegExp(
    r'(?:จำนวนเงิน|ยอด|amount|total|รวม|vat|ภาษี|cash|เงินสด|change|เงินทอน|date|วันที่|time|เวลา|tel|โทร|tax|เลขที่|receipt|bill|ref|www\.|http|@|\.co\.|\.th\b|โอนเงิน|สำเร็จ|สลิป|promptpay|ธนาคาร|bank|ไปยัง|ผู้รับ|to\b)',
    caseSensitive: false,
  );
  static final _looksLikeReceipt = RegExp(
    r'(?:รวมทั้งสิ้น|ยอดสุทธิ|ยอดชำระ|รวมเงิน|grand\s*total|total\s*due|(?<!sub)total|เงินทอน|change|เงินสด|cash|vat|ภาษี|ใบเสร็จ|receipt)',
    caseSensitive: false,
  );
  static final _knownShops = <(RegExp, String)>[
    (RegExp(r'7\s*[-–]?\s*(?:eleven|11)|เซเว่น', caseSensitive: false), '7-Eleven'),
    (RegExp(r'family\s*mart|แฟมิลี่\s*มาร์ท', caseSensitive: false), 'FamilyMart'),
    (RegExp(r'lotus|โลตัส', caseSensitive: false), 'Lotus'),
    (RegExp(r'big\s*c|บิ๊ก\s*ซี', caseSensitive: false), 'Big C'),
    (RegExp(r'mcdonald|แมคโดนัลด์', caseSensitive: false), "McDonald's"),
    (RegExp(r'\bkfc\b|เคเอฟซี', caseSensitive: false), 'KFC'),
    (RegExp(r'starbucks|สตาร์บัคส์', caseSensitive: false), 'Starbucks'),
    (RegExp(r'cafe\s*amazon|คาเฟ่\s*อเมซอน', caseSensitive: false), 'Cafe Amazon'),
    (RegExp(r'tops?\s*market|ท็อปส์', caseSensitive: false), 'Tops'),
    (RegExp(r'makro|แม็คโคร', caseSensitive: false), 'Makro'),
  ];
  static final _currencyFirst = RegExp(
    r'(?:thb|฿|(?<![A-Za-z])[bB])\s+([0-9][0-9,]*(?:\.[0-9]{1,2})?)',
    caseSensitive: false,
  );
  static final _currencyAfter = RegExp(
    r'([0-9][0-9,]*(?:\.[0-9]{1,2})?)\s*(?:บาท|thb|฿)',
    caseSensitive: false,
  );
  static final _decimalAmount = RegExp(
    r'(?:^|\n)\s*([0-9]{1,7}(?:,[0-9]{3})*\.[0-9]{2})\s*(?=\n|$)',
  );
  static final _numericDate = RegExp(
    r'(\d{1,2})[\/\-.](\d{1,2})[\/\-.](\d{4}|\d{2})(?!\d)',
  );
  static final _namedDate = RegExp(
    '($_day)\\s+($_monthNames)\\s+(\\d{4})',
    caseSensitive: false,
  );
  static final _time = RegExp(r'(?<!\d)(\d{1,2}):(\d{2})(?!\d)');
  static final _reference = RegExp(
    r'(?:เลขที่รายการ|เลขทีรายการ|หมายเลขอ้างอิง|เลขอ้างอิง|transaction\s*id|reference|ref\.?)\s*[:：#]?\s*([A-Za-z0-9]{6,})',
    caseSensitive: false,
  );
  static final _recipient = RegExp(
    r'(?:^|\n)\s*(?:ไปยัง|ผู้รับเงิน|ผู้รับ|recipient|\bto\b)\s*[:：]?\s*([^\n]+)',
    caseSensitive: false,
  );

  static const _months = <String, int>{
    'ม.ค.': 1,
    'มกราคม': 1,
    'ก.พ.': 2,
    'กุมภาพันธ์': 2,
    'มี.ค.': 3,
    'มีนาคม': 3,
    'เม.ย.': 4,
    'เมษายน': 4,
    'พ.ค.': 5,
    'พฤษภาคม': 5,
    'มิ.ย.': 6,
    'มิถุนายน': 6,
    'ก.ค.': 7,
    'กรกฎาคม': 7,
    'ส.ค.': 8,
    'สิงหาคม': 8,
    'ก.ย.': 9,
    'กันยายน': 9,
    'ต.ค.': 10,
    'ตุลาคม': 10,
    'พ.ย.': 11,
    'พฤศจิกายน': 11,
    'ธ.ค.': 12,
    'ธันวาคม': 12,
    'jan': 1,
    'january': 1,
    'feb': 2,
    'february': 2,
    'mar': 3,
    'march': 3,
    'apr': 4,
    'april': 4,
    'may': 5,
    'jun': 6,
    'june': 6,
    'jul': 7,
    'july': 7,
    'aug': 8,
    'august': 8,
    'sep': 9,
    'sept': 9,
    'september': 9,
    'oct': 10,
    'october': 10,
    'nov': 11,
    'november': 11,
    'dec': 12,
    'december': 12,
  };

  static SlipDraft parse(String raw) {
    final text = _normalize(raw);
    return SlipDraft(
      amount: _amount(text),
      date: _date(text),
      recipient: _recipientName(text) ?? _shopName(text),
      reference:
          _reference.firstMatch(text)?.group(1) ??
          _receiptNo.firstMatch(text)?.group(1),
      rawText: text,
    );
  }

  static String _normalize(String raw) {
    return raw
        .replaceAll('\r\n', '\n')
        .replaceAll('\u0E4D\u0E32', '\u0E33')
        .replaceAll('\u0E32\u0E4D', '\u0E33')
        .trim();
  }

  static String? _recipientName(String text) {
    for (final match in _recipient.allMatches(text)) {
      final value = _clean(match.group(1));
      if (value == null) continue;
      if (value.contains('สแกน') || value.contains('คิวอาร์')) continue;
      return value;
    }
    return null;
  }

  static double? _amount(String text) {
    final labeled = _labeledAmount.firstMatch(text);
    if (labeled != null) return _number(labeled.group(1)!);
    final grand = _grandTotal.firstMatch(text);
    if (grand != null) return _number(grand.group(1)!);
    final total = _lastBillTotal(text);
    if (total != null) return total;
    final first = _currencyFirst.firstMatch(text);
    if (first != null) return _number(first.group(1)!);
    final after = _currencyAfter.firstMatch(text);
    if (after != null) return _number(after.group(1)!);
    final plain = _decimalAmount.firstMatch(text);
    if (plain != null) return _number(plain.group(1)!);
    return null;
  }

  static double? _lastBillTotal(String text) {
    double? found;
    for (final line in text.split('\n')) {
      if (_notTheBill.hasMatch(line)) continue;
      final match = _plainTotal.firstMatch(line);
      if (match != null) found = _number(match.group(1)!);
    }
    return found;
  }

  /// A shop or restaurant receipt names the store on its own line, not under ผู้รับ.
  static String? _shopName(String text) {
    final lines = text.split('\n').map((line) => line.trim()).where((line) {
      return line.isNotEmpty && line.length <= 48;
    }).toList();
    for (final line in lines) {
      for (final shop in _knownShops) {
        if (shop.$1.hasMatch(line)) return shop.$2;
      }
    }
    for (final line in lines.take(8)) {
      final lower = line.toLowerCase();
      if (_shopLineSkip.hasMatch(line)) continue;
      if (line.contains('ร้าน') ||
          lower.contains('restaurant') ||
          lower.contains('cafe') ||
          lower.contains('coffee') ||
          lower.contains('bistro') ||
          lower.contains('kitchen') ||
          line.contains('ครัว') ||
          line.contains('กาแฟ')) {
        return line;
      }
    }
    if (!_looksLikeReceipt.hasMatch(text)) return null;
    for (final line in lines.take(5)) {
      if (_shopLineSkip.hasMatch(line)) continue;
      if (_decimalAmount.hasMatch(line) || _numericDate.hasMatch(line)) {
        continue;
      }
      if (RegExp(r'^[\d\s:./\-]+$').hasMatch(line)) continue;
      if (line.length < 3) continue;
      return line;
    }
    return null;
  }

  static double _number(String raw) =>
      double.parse(raw.replaceAll(',', ''));

  static DateTime? _date(String text) {
    int? day;
    int? month;
    int? year;
    final numeric = _numericDate.firstMatch(text);
    if (numeric != null) {
      day = int.parse(numeric.group(1)!);
      month = int.parse(numeric.group(2)!);
      year = _year(int.parse(numeric.group(3)!));
    } else {
      final named = _namedDate.firstMatch(text);
      if (named != null) {
        day = int.parse(named.group(1)!);
        month = _months[named.group(2)!.toLowerCase()];
        year = _year(int.parse(named.group(3)!));
      }
    }
    if (day == null || month == null || year == null) return null;
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    var hour = 0;
    var minute = 0;
    final time = _time.firstMatch(text);
    if (time != null) {
      hour = int.parse(time.group(1)!);
      minute = int.parse(time.group(2)!);
      if (hour > 23 || minute > 59) {
        hour = 0;
        minute = 0;
      }
    }
    return DateTime(year, month, day, hour, minute);
  }

  static int _year(int year) {
    if (year > 2400) return year - 543;
    if (year < 100) return 2000 + year;
    return year;
  }

  static String? _clean(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    // Tesseract sometimes keeps the tail of ผู้รับเงิน on the name.
    final withoutLabelTail = trimmed.replaceFirst(RegExp(r'^งิน\s+'), '');
    return withoutLabelTail.isEmpty ? trimmed : withoutLabelTail;
  }
}
