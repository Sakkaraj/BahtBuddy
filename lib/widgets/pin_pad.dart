import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const pinLength = 6;

class PinPad extends StatefulWidget {
  const PinPad({
    super.key,
    required this.title,
    required this.onCompleted,
    this.subtitle,
    this.errorText,
    this.onBiometrics,
    this.onInput,
  });

  final String title;
  final String? subtitle;
  final String? errorText;
  final Future<bool> Function(String pin) onCompleted;
  final VoidCallback? onBiometrics;
  final VoidCallback? onInput;

  @override
  State<PinPad> createState() => PinPadState();
}

class PinPadState extends State<PinPad> with SingleTickerProviderStateMixin {
  String _pin = '';
  var _busy = false;
  late final AnimationController _shake;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
  }

  @override
  void didUpdateWidget(PinPad oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title) {
      _pin = '';
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  void clear() {
    setState(() => _pin = '');
  }

  Future<void> _fail() async {
    HapticFeedback.heavyImpact();
    await _shake.forward(from: 0);
    if (mounted) setState(() => _pin = '');
  }

  Future<void> _append(String digit) async {
    if (_busy || _pin.length >= pinLength) return;
    widget.onInput?.call();
    HapticFeedback.selectionClick();
    final next = '$_pin$digit';
    setState(() => _pin = next);
    if (next.length < pinLength) return;
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final ok = await widget.onCompleted(next);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) await _fail();
  }

  void _delete() {
    if (_busy || _pin.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final labelColor = CupertinoColors.secondaryLabel.resolveFrom(context);
    final offset = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -12), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12, end: 12), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 12, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shake, curve: Curves.linear));
    return SafeArea(
      child: Column(
        children: [
          const Spacer(flex: 2),
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (widget.subtitle != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                widget.subtitle!,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: labelColor),
              ),
            ),
          ],
          const SizedBox(height: 28),
          AnimatedBuilder(
            animation: offset,
            builder: (context, child) => Transform.translate(
              offset: Offset(offset.value, 0),
              child: child,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < pinLength; i++) ...[
                  if (i > 0) const SizedBox(width: 16),
                  _Dot(filled: i < _pin.length, error: widget.errorText != null),
                ],
              ],
            ),
          ),
          if (widget.errorText != null) ...[
            const SizedBox(height: 12),
            Text(
              widget.errorText!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const Spacer(flex: 3),
          _Keypad(
            onDigit: _append,
            onDelete: _delete,
            onBiometrics: widget.onBiometrics,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.filled, required this.error});

  final bool filled;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final color = error
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.onSurface;
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? color : Colors.transparent,
        border: Border.all(color: color, width: 1.4),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({
    required this.onDigit,
    required this.onDelete,
    this.onBiometrics,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  final VoidCallback? onBiometrics;

  @override
  Widget build(BuildContext context) {
    Widget digit(String value) => _Key(
      key: Key('pin-key-$value'),
      onPressed: () => onDigit(value),
      child: Text(
        value,
        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w400),
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        children: [
          for (final row in const [
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9'],
          ]) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [for (final value in row) digit(value)],
            ),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Key(
                key: const Key('pin-key-biometrics'),
                onPressed: onBiometrics,
                child: onBiometrics == null
                    ? const SizedBox.shrink()
                    : const Icon(CupertinoIcons.person_crop_circle, size: 32),
              ),
              digit('0'),
              _Key(
                key: const Key('pin-key-delete'),
                onPressed: onDelete,
                child: const Icon(CupertinoIcons.delete_left, size: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({super.key, required this.child, this.onPressed});

  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final fill = CupertinoColors.secondarySystemFill.resolveFrom(context);
    return SizedBox(
      width: 76,
      height: 76,
      child: onPressed == null
          ? const SizedBox.expand()
          : Material(
              color: fill,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onPressed,
                child: Center(child: child),
              ),
            ),
    );
  }
}
