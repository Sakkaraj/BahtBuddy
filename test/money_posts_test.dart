import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:project/services/money_posts.dart';

void main() {
  test('reads BBC business items and picks four in a new order', () {
    const xml = '''
<rss><channel>
<item>
  <title><![CDATA[Prices rose again]]></title>
  <description><![CDATA[Food <b>costs</b> are higher &amp; rents followed.]]></description>
  <link>https://www.bbc.co.uk/news/articles/abc?at_medium=RSS&amp;at_campaign=rss</link>
  <pubDate>Tue, 24 Nov 2026 17:04:20 GMT</pubDate>
  <media:thumbnail width="240" height="135" url="https://ichef.bbci.co.uk/ace/standard/240/cpsprodpb/sample.jpg"/>
</item>
<item><title>Second</title><description></description><link>https://www.bbc.co.uk/2</link></item>
<item><title>Third</title><description></description><link></link></item>
<item><title>Fourth</title><description></description><link></link></item>
<item><title>Fifth is dropped</title><description></description><link></link></item>
<item><title> </title><description>blank</description><link></link></item>
</channel></rss>
''';
    final posts = parseBbcRss(xml);
    expect(posts, hasLength(5));
    expect(posts.first.title, 'Prices rose again');
    final one = pickPosts(posts, Random(1)).map((post) => post.title).join('|');
    final two = pickPosts(posts, Random(99)).map((post) => post.title).join('|');
    expect(one.split('|'), hasLength(4));
    expect(one == two, isFalse);
    expect(posts.first.summary, 'Food costs are higher & rents followed.');
    expect(
      posts.first.link,
      'https://www.bbc.co.uk/news/articles/abc?at_medium=RSS&at_campaign=rss',
    );
    expect(posts.first.source, 'BBC News');
    expect(
      posts.first.imageUrl,
      'https://ichef.bbci.co.uk/ace/standard/976/cpsprodpb/sample.jpg',
    );
    expect(posts[1].imageUrl, isEmpty);
    expect(posts.first.published, DateTime.utc(2026, 11, 24, 17, 4));
    expect(posts.last.title, 'Fifth is dropped');
    expect(parseBbcRss('<rss></rss>'), isEmpty);
    expect(parseRssDate('not a date'), isNull);
  });
}
