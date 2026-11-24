import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/format.dart';
import 'motion.dart';

/// The theme photograph under a frosted panel tinted to that same look.
class GlassPhotoCard extends StatelessWidget {
  const GlassPhotoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 18, 20, 16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final look = BuddyLook.of(context);
    return PopCard(
      child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(look.cardImage, fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: look.glass,
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.42),
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
              ),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    ),
    );
  }
}
