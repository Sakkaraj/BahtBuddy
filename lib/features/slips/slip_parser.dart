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
  static final _currencyFirst = RegExp(
    r'(?:thb|฿)\s*([0-9][0-9,]*(?:\.[0-9]{1,2})?)',
    caseSensitive: false,
  );
  static final _currencyAfter = RegExp(
    r'([0-9][0-9,]*(?:\.[0-9]{1,2})?)\s*(?:บาท|thb|฿)',
    caseSensitive: false,
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
    r'(?:เลขที่รายการ|หมายเลขอ้างอิง|เลขอ้างอิง|transaction\s*id|reference|ref\.?)\s*[:：#]?\s*([A-Za-z0-9]{6,})',
    caseSensitive: false,
  );
  static final _recipient = RegExp(
    r'(?:^|\n)\s*(?:ไปยัง|ผู้รับเงิน|ผู้รับ|recipient|to)\s*[:：]?\s*([^\n]+)',
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
    final text = raw.replaceAll('\r\n', '\n').trim();
    return SlipDraft(
      amount: _amount(text),
      date: _date(text),
      recipient: _clean(_recipient.firstMatch(text)?.group(1)),
      reference: _reference.firstMatch(text)?.group(1),
      rawText: text,
    );
  }

  static double? _amount(String text) {
    final labeled = _labeledAmount.firstMatch(text);
    if (labeled != null) return _number(labeled.group(1)!);
    final first = _currencyFirst.firstMatch(text);
    if (first != null) return _number(first.group(1)!);
    final after = _currencyAfter.firstMatch(text);
    if (after != null) return _number(after.group(1)!);
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
    return trimmed;
  }
}
