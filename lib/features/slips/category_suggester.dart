class CategorySuggester {
  static const keywords = <String, List<String>>{
    'food': [
      '7-eleven',
      '7 eleven',
      '7eleven',
      'เซเว่น',
      'grabfood',
      'foodpanda',
      'lineman',
      'mcdonald',
      'kfc',
      'starbucks',
      'cafe',
      'coffee',
      'อาหาร',
      'ร้านอาหาร',
    ],
    'transport': [
      'bts',
      'mrt',
      'แอร์พอร์ต',
      'ทางด่วน',
      'bolt',
      'taxi',
      'grab',
      'วินมอเตอร์ไซค์',
    ],
    'shopping': [
      'shopee',
      'lazada',
      'ช้อปปี้',
      'ลาซาด้า',
      'lotus',
      'big c',
      'บิ๊กซี',
    ],
    'bills': [
      'การไฟฟ้า',
      'ประปา',
      'electric',
      'internet',
      'ais',
      'true',
      'dtac',
    ],
    'entertainment': [
      'netflix',
      'spotify',
      'youtube',
      'major cineplex',
      'หนัง',
    ],
    'health': ['โรงพยาบาล', 'คลินิก', 'pharmacy', 'โรงยา'],
    'education': ['tuition', 'ค่าเทอม', 'มหาวิทยาลัย', 'มหาลัย', 'school'],
  };

  static String normalize(String recipient) =>
      recipient.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  /// A category the user already corrected for this recipient wins.
  /// Otherwise the first matching keyword is used, longest phrase first.
  static String? suggest({String? recipient, String? learnedKey}) {
    if (learnedKey != null && learnedKey.isNotEmpty) return learnedKey;
    final text = normalize(recipient ?? '');
    if (text.isEmpty) return null;
    final pairs = <(String, String)>[];
    for (final entry in keywords.entries) {
      for (final word in entry.value) {
        pairs.add((entry.key, word));
      }
    }
    pairs.sort((a, b) => b.$2.length.compareTo(a.$2.length));
    for (final pair in pairs) {
      if (text.contains(pair.$2)) return pair.$1;
    }
    return null;
  }
}
