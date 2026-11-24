import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/format.dart';
import '../l10n/app_localizations.dart';
import '../providers.dart';
import 'motion.dart';

class PromoBanner extends ConsumerStatefulWidget {
  const PromoBanner({super.key});

  @override
  ConsumerState<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends ConsumerState<PromoBanner> {
  final _controller = PageController();
  Timer? _timer;
  var _index = 0;
  var _mixKey = '';
  var _jumpToStart = false;
  List<_Slide> _mixed = const [];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted || !_controller.hasClients) return;
      final pages = _pageCount;
      if (pages <= 1) return;
      _index = (_index + 1) % pages;
      _controller.animateToPage(
        _index,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeOutCubic,
      );
    });
  }

  int _pageCount = 1;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final look = BuddyLook.of(context);
    final posts = ref.watch(moneyPostsProvider).asData?.value ?? const [];
    final mix = ref.watch(bannerMixProvider);
    final slides = <_Slide>[
      _Slide.photo(
        image: 'assets/save_banner.jpg',
        title: l10n.bannerSaveTitle,
        body: l10n.bannerSaveBody,
        alignEnd: false,
        onTap: () => context.push('/budgets'),
      ),
      _Slide.photo(
        image: 'assets/track_banner.jpg',
        title: l10n.bannerTrackTitle,
        body: l10n.bannerTrackBody,
        alignEnd: true,
        onTap: () => context.go('/reports'),
      ),
      _Slide.note(
        image: 'assets/know_month.jpg',
        kicker: l10n.mustKnow,
        title: l10n.knowMonthTitle,
        body: l10n.knowMonthBody,
        disclaimer: l10n.mustKnowDisclaimer,
      ),
      _Slide.note(
        image: 'assets/know_buffer.jpg',
        kicker: l10n.mustKnow,
        title: l10n.knowBufferTitle,
        body: l10n.knowBufferBody,
        disclaimer: l10n.mustKnowDisclaimer,
      ),
      _Slide.note(
        image: 'assets/know_fees.jpg',
        kicker: l10n.mustKnow,
        title: l10n.knowFeesTitle,
        body: l10n.knowFeesBody,
        disclaimer: l10n.mustKnowDisclaimer,
      ),
      _Slide.note(
        image: 'assets/know_spread.jpg',
        kicker: l10n.mustKnow,
        title: l10n.knowSpreadTitle,
        body: l10n.knowSpreadBody,
        disclaimer: l10n.mustKnowDisclaimer,
      ),
      for (final post in posts)
        _Slide.news(
          kicker: l10n.moneyNews,
          title: post.title,
          body: post.summary,
          disclaimer: l10n.moneyNewsDisclaimer,
          source: post.source,
          when: _shortDate(post.published),
          link: post.link,
          readLabel: l10n.readStory,
          networkImage: post.imageUrl,
        ),
    ];
    final mixKey = '$mix\n${slides.map((slide) => slide.title).join('\n')}';
    if (mixKey != _mixKey) {
      _mixKey = mixKey;
      _mixed = List<_Slide>.of(slides)..shuffle(Random());
      _index = 0;
      _jumpToStart = true;
    }
    if (_jumpToStart) {
      _jumpToStart = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _controller.hasClients) {
          _controller.jumpToPage(0);
        }
      });
    }
    final deck = _mixed;
    _pageCount = deck.length;
    if (_index >= deck.length) _index = 0;
    return PopCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Column(
          children: [
            SizedBox(
              height: 168,
              child: PageView.builder(
                controller: _controller,
                itemCount: deck.length,
                onPageChanged: (value) => setState(() => _index = value),
                itemBuilder: (context, index) {
                  final slide = deck[index];
                  if (slide.networkImage.isNotEmpty ||
                      (slide.image != null && slide.kicker.isNotEmpty)) {
                    return _NewsSlide(slide: slide, fallback: look.banner);
                  }
                  if (slide.image != null) {
                    return _BannerSlide(slide: slide);
                  }
                  return _NoteSlide(slide: slide, gradient: look.banner);
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < deck.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _index ? 18 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i == _index
                          ? bahtAccent
                          : bahtAccent.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _shortDate(DateTime? date) {
  if (date == null) return '';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final local = date.toLocal();
  return '${local.day} ${months[local.month - 1]}';
}

class _Slide {
  const _Slide.photo({
    required this.image,
    required this.title,
    required this.body,
    required this.alignEnd,
    required this.onTap,
  }) : kicker = '',
       disclaimer = '',
       source = '',
       when = '',
       link = '',
       readLabel = '',
       networkImage = '';

  const _Slide.note({
    required this.image,
    required this.kicker,
    required this.title,
    required this.body,
    required this.disclaimer,
  }) : alignEnd = false,
       onTap = null,
       source = '',
       when = '',
       link = '',
       readLabel = '',
       networkImage = '';

  const _Slide.news({
    required this.kicker,
    required this.title,
    required this.body,
    required this.disclaimer,
    required this.source,
    required this.when,
    required this.link,
    required this.readLabel,
    required this.networkImage,
  }) : image = null,
       alignEnd = false,
       onTap = null;

  final String? image;
  final String networkImage;
  final String kicker;
  final String title;
  final String body;
  final bool alignEnd;
  final VoidCallback? onTap;
  final String disclaimer;
  final String source;
  final String when;
  final String link;
  final String readLabel;
}

class _NewsSlide extends StatelessWidget {
  const _NewsSlide({required this.slide, required this.fallback});

  final _Slide slide;
  final LinearGradient fallback;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => _openNote(context, slide),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: fallback,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: slide.networkImage.isNotEmpty
                        ? Image.network(
                            slide.networkImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) =>
                                const SizedBox.shrink(),
                          )
                        : Image.asset(slide.image!, fit: BoxFit.cover),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x22000000), Color(0xD010241F)],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          slide.kicker.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          slide.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          [
                            slide.source,
                            slide.when,
                          ].where((part) => part.isNotEmpty).join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BannerSlide extends StatelessWidget {
  const _BannerSlide({required this.slide});

  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: slide.onTap,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                image: DecorationImage(
                  image: AssetImage(slide.image!),
                  fit: BoxFit.cover,
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: slide.alignEnd
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    end: slide.alignEnd
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    colors: [
                      Colors.transparent,
                      const Color(0xFF10241F).withValues(alpha: 0.72),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                  child: Column(
                    crossAxisAlignment: slide.alignEnd
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      Text(
                        slide.title,
                        textAlign: slide.alignEnd
                            ? TextAlign.end
                            : TextAlign.start,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        slide.body,
                        textAlign: slide.alignEnd
                            ? TextAlign.end
                            : TextAlign.start,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NoteSlide extends StatelessWidget {
  const _NoteSlide({required this.slide, required this.gradient});

  final _Slide slide;
  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    final ink = BuddyLook.of(context).bannerInk;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _openNote(context, slide),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: gradient,
              border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slide.kicker.toUpperCase(),
                    style: TextStyle(
                      color: ink.withValues(alpha: 0.72),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    slide.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    slide.body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: ink.withValues(alpha: 0.88),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                    ),
                  ),
                  const Spacer(),
                  if (slide.source.isNotEmpty || slide.when.isNotEmpty)
                    Text(
                      [
                        slide.source,
                        slide.when,
                      ].where((part) => part.isNotEmpty).join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ink.withValues(alpha: 0.72),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _openNote(BuildContext context, _Slide slide) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    showDragHandle: true,
    builder: (context) {
      final muted = Theme.of(context).colorScheme.onSurfaceVariant;
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (slide.networkImage.isNotEmpty || slide.image != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: slide.networkImage.isNotEmpty
                    ? Image.network(
                        slide.networkImage,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) =>
                            const SizedBox.shrink(),
                      )
                    : Image.asset(
                        slide.image!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              slide.kicker,
              style: const TextStyle(
                color: bahtAccent,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              slide.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(slide.body, style: const TextStyle(height: 1.35)),
            const SizedBox(height: 10),
            Text(
              slide.disclaimer,
              style: TextStyle(color: muted, fontSize: 13),
            ),
            if (slide.link.startsWith('https://')) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  final uri = Uri.parse(slide.link);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Text(slide.readLabel),
              ),
            ],
          ],
        ),
      );
    },
  );
}
