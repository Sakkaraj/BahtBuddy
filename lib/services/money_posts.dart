import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';

/// A business headline from the public BBC News RSS feed.
class MoneyPost {
  const MoneyPost({
    required this.title,
    required this.summary,
    required this.link,
    required this.imageUrl,
    required this.published,
    required this.source,
  });

  final String title;
  final String summary;
  final String link;
  final String imageUrl;
  final DateTime? published;
  final String source;

  Map<String, dynamic> toJson() => {
    'title': title,
    'summary': summary,
    'link': link,
    'imageUrl': imageUrl,
    'published': published?.toIso8601String(),
    'source': source,
  };

  static MoneyPost fromJson(Map<String, dynamic> json) {
    final raw = json['published'] as String?;
    return MoneyPost(
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      link: json['link'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      published: raw == null ? null : DateTime.tryParse(raw),
      source: json['source'] as String? ?? MoneyPosts.sourceName,
    );
  }
}

/// BBC News publishes this feed with no key. The banner credits the source
/// and links to the story. The posts are headlines, not a recommendation.
class MoneyPosts {
  static const feedUrl = 'https://feeds.bbci.co.uk/news/business/rss.xml';
  static const sourceName = 'BBC News';
  static const postLimit = 4;
  static const poolLimit = 20;

  static Future<List<MoneyPost>> load({Random? random}) async {
    final roll = random ?? Random();
    try {
      final fresh = await fetch();
      if (fresh.isNotEmpty) {
        await _write(fresh);
        return pickPosts(fresh, roll);
      }
    } catch (_) {}
    final saved = await _read();
    if (saved != null && saved.isNotEmpty) return pickPosts(saved, roll);
    return const [];
  }

  static Future<List<MoneyPost>> fetch() async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(feedUrl));
      request.headers.set(HttpHeaders.userAgentHeader, 'BahtBuddy');
      final response = await request.close().timeout(
        const Duration(seconds: 12),
      );
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode != 200) {
        throw HttpException('Money feed failed');
      }
      return parseBbcRss(body);
    } finally {
      client.close();
    }
  }

  static Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/money_posts.json');
  }

  static Future<void> _write(List<MoneyPost> posts) async {
    final file = await _file();
    await file.writeAsString(
      jsonEncode(posts.map((post) => post.toJson()).toList()),
    );
  }

  static Future<List<MoneyPost>?> _read() async {
    try {
      final file = await _file();
      if (!await file.exists()) return null;
      final json = jsonDecode(await file.readAsString());
      if (json is! List) return null;
      return json
          .whereType<Map>()
          .map((item) => MoneyPost.fromJson(Map<String, dynamic>.from(item)))
          .where((post) => post.title.isNotEmpty)
          .take(poolLimit)
          .toList();
    } catch (_) {
      return null;
    }
  }
}

List<MoneyPost> parseBbcRss(String xml) {
  final posts = <MoneyPost>[];
  final items = RegExp(
    r'<item\b[^>]*>(.*?)</item>',
    dotAll: true,
  ).allMatches(xml);
  for (final item in items) {
    final block = item.group(1) ?? '';
    final title = _tagText(block, 'title');
    if (title.isEmpty) continue;
    posts.add(
      MoneyPost(
        title: title,
        summary: _tagText(block, 'description'),
        link: _tagText(block, 'link'),
        imageUrl: _picture(block),
        published: parseRssDate(_tagText(block, 'pubDate')),
        source: MoneyPosts.sourceName,
      ),
    );
    if (posts.length == MoneyPosts.poolLimit) break;
  }
  return posts;
}

/// Four stories for this visit. The same feed can come back in another order.
List<MoneyPost> pickPosts(List<MoneyPost> posts, Random random) {
  final copy = List<MoneyPost>.of(posts)..shuffle(random);
  if (copy.length <= MoneyPosts.postLimit) return copy;
  return copy.take(MoneyPosts.postLimit).toList();
}

DateTime? parseRssDate(String raw) {
  final match = RegExp(
    r'(\d{1,2}) ([A-Za-z]{3}) (\d{4}) (\d{2}):(\d{2})',
  ).firstMatch(raw);
  if (match == null) return null;
  const months = {
    'Jan': 1,
    'Feb': 2,
    'Mar': 3,
    'Apr': 4,
    'May': 5,
    'Jun': 6,
    'Jul': 7,
    'Aug': 8,
    'Sep': 9,
    'Oct': 10,
    'Nov': 11,
    'Dec': 12,
  };
  final month = months[match.group(2)];
  if (month == null) return null;
  return DateTime.utc(
    int.parse(match.group(3)!),
    month,
    int.parse(match.group(1)!),
    int.parse(match.group(4)!),
    int.parse(match.group(5)!),
  );
}

String rssPlain(String raw) {
  final withoutCdata = raw.replaceAllMapped(
    RegExp(r'<!\[CDATA\[(.*?)\]\]>', dotAll: true),
    (match) => match.group(1) ?? '',
  );
  final withoutTags = withoutCdata.replaceAll(RegExp(r'<[^>]+>'), ' ');
  return withoutTags
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&apos;', "'")
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String _picture(String block) {
  final match = RegExp(
    r'<media:thumbnail\b[^>]*\burl="([^"]+)"',
  ).firstMatch(block);
  if (match == null) return '';
  final url = rssPlain(match.group(1) ?? '');
  return url.replaceFirst('/ace/standard/240/', '/ace/standard/976/');
}

String _tagText(String block, String name) {
  final match = RegExp(
    '<$name\\b[^>]*>(.*?)</$name>',
    dotAll: true,
  ).firstMatch(block);
  if (match == null) return '';
  return rssPlain(match.group(1) ?? '');
}
