import 'package:flutter/material.dart';

class Appear extends StatelessWidget {
  const Appear({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 520) + delay,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final start = delay.inMilliseconds /
            (520 + delay.inMilliseconds).clamp(1, 2000);
        final t = ((value - start) / (1 - start)).clamp(0.0, 1.0);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 18),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class PressScale extends StatefulWidget {
  const PressScale({super.key, required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        transformAlignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.002)
          ..rotateX(_pressed ? -0.12 : 0)
          ..translateByDouble(0, _pressed ? -6 : 0, 0, 1)
          ..scaleByDouble(
            _pressed ? 0.97 : 1,
            _pressed ? 0.97 : 1,
            1,
            1,
          ),
        child: widget.child,
      ),
    );
  }
}

/// Lifts a card toward the finger and tilts it, then settles back.
class PopCard extends StatefulWidget {
  const PopCard({super.key, required this.child});

  final Widget child;

  @override
  State<PopCard> createState() => _PopCardState();
}

class _PopCardState extends State<PopCard> with SingleTickerProviderStateMixin {
  late final AnimationController _settle;
  var _tiltX = 0.0;
  var _tiltY = 0.0;
  var _lift = 0.0;
  var _fromX = 0.0;
  var _fromY = 0.0;
  var _fromLift = 0.0;

  @override
  void initState() {
    super.initState();
    _settle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..addListener(() {
      if (!mounted) return;
      final t = Curves.easeOutBack.transform(_settle.value);
      setState(() {
        _tiltX = _fromX * (1 - t);
        _tiltY = _fromY * (1 - t);
        _lift = _fromLift * (1 - t);
      });
    });
  }

  @override
  void dispose() {
    _settle.dispose();
    super.dispose();
  }

  void _press(Offset local) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || box.size.width == 0 || box.size.height == 0) return;
    _settle.stop();
    final dx = ((local.dx / box.size.width) - 0.5).clamp(-0.5, 0.5);
    final dy = ((local.dy / box.size.height) - 0.5).clamp(-0.5, 0.5);
    setState(() {
      _tiltY = dx * 0.22;
      _tiltX = -dy * 0.16;
      _lift = 1;
    });
  }

  void _release() {
    _fromX = _tiltX;
    _fromY = _tiltY;
    _fromLift = _lift;
    _settle.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) => _press(event.localPosition),
      onPointerUp: (_) => _release(),
      onPointerCancel: (_) => _release(),
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0012)
          ..rotateX(_tiltX)
          ..rotateY(_tiltY)
          ..translateByDouble(0, -12 * _lift, 0, 1),
        child: DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF12324F).withValues(alpha: 0.12 + 0.16 * _lift),
                blurRadius: 16 + 18 * _lift,
                offset: Offset(18 * _tiltY, 10 + 8 * _lift),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
