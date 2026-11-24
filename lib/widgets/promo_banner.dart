import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';

class PromoBanner extends StatefulWidget {
  const PromoBanner({super.key});

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  final _controller = PageController();
  Timer? _timer;
  var _index = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_controller.hasClients) return;
      _index = (_index + 1) % 2;
      _controller.animateToPage(
        _index,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final slides = [
      _Slide(
        image: 'assets/save_banner.jpg',
        title: l10n.bannerSaveTitle,
        body: l10n.bannerSaveBody,
        alignEnd: false,
        onTap: () => context.push('/budgets'),
      ),
      _Slide(
        image: 'assets/track_banner.jpg',
        title: l10n.bannerTrackTitle,
        body: l10n.bannerTrackBody,
        alignEnd: true,
        onTap: () => context.go('/reports'),
      ),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        children: [
          SizedBox(
            height: 168,
            child: PageView.builder(
              controller: _controller,
              itemCount: slides.length,
              onPageChanged: (value) => setState(() => _index = value),
              itemBuilder: (context, index) => _BannerSlide(slide: slides[index]),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < slides.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _index ? 18 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: i == _index
                        ? const Color(0xFF0E9F8A)
                        : const Color(0xFF0E9F8A).withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Slide {
  const _Slide({
    required this.image,
    required this.title,
    required this.body,
    required this.alignEnd,
    required this.onTap,
  });

  final String image;
  final String title;
  final String body;
  final bool alignEnd;
  final VoidCallback onTap;
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
                image: AssetImage(slide.image),
                fit: BoxFit.cover,
              ),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: slide.alignEnd ? Alignment.centerLeft : Alignment.centerRight,
                  end: slide.alignEnd ? Alignment.centerRight : Alignment.centerLeft,
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
                      textAlign: slide.alignEnd ? TextAlign.end : TextAlign.start,
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
                      textAlign: slide.alignEnd ? TextAlign.end : TextAlign.start,
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
