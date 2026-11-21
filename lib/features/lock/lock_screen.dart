import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../core/format.dart';
import '../../core/pin_hash.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../../widgets/pin_pad.dart';

class LockGate extends ConsumerStatefulWidget {
  const LockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<LockGate> createState() => _LockGateState();
}

class _LockGateState extends ConsumerState<LockGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && !ref.read(suppressLockProvider)) {
      ref.read(sessionUnlockedProvider.notifier).lock();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final unlocked = ref.watch(sessionUnlockedProvider);
    final locked = settings.maybeWhen(
      data: (prefs) => prefs.pinHash != null && !unlocked,
      orElse: () => false,
    );
    return Stack(
      children: [
        widget.child,
        if (settings.isLoading)
          Positioned.fill(
            child: ColoredBox(
              color: groupedBackground(context),
              child: const Center(child: CupertinoActivityIndicator()),
            ),
          ),
        if (locked) const Positioned.fill(child: LockScreen()),
      ],
    );
  }
}

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String? _error;
  var _triedBiometrics = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prefs = ref.watch(settingsProvider).asData?.value;
    if (prefs?.biometricsEnabled == true && !_triedBiometrics) {
      _triedBiometrics = true;
      Future<void>.microtask(_biometrics);
    }
    return Scaffold(
      backgroundColor: groupedBackground(context),
      body: PinPad(
        title: l10n.enterPin,
        subtitle: l10n.lockSubtitle,
        errorText: _error,
        onBiometrics: prefs?.biometricsEnabled == true ? _biometrics : null,
        onInput: () {
          if (_error != null) setState(() => _error = null);
        },
        onCompleted: (pin) async {
          final hash = ref.read(settingsProvider).asData?.value.pinHash;
          if (hash != null && hashPin(pin) == hash) {
            ref.read(sessionUnlockedProvider.notifier).unlock();
            return true;
          }
          setState(() => _error = l10n.wrongPin);
          return false;
        },
      ),
    );
  }

  Future<void> _biometrics() async {
    final l10n = AppLocalizations.of(context);
    try {
      final ok = await LocalAuthentication().authenticate(
        localizedReason: l10n.unlock,
        biometricOnly: true,
      );
      if (ok) ref.read(sessionUnlockedProvider.notifier).unlock();
    } catch (_) {
      if (mounted) setState(() => _error = l10n.biometricsUnavailable);
    }
  }
}
