import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/backup_crypto.dart';
import '../../core/clock.dart';
import '../../core/format.dart';
import '../../core/pin_hash.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../lock/pin_flow.dart';
import 'time_zone_sheet.dart';
import '../../widgets/bb_grouped_section.dart';
import '../../widgets/bb_scaffold.dart';
import '../../widgets/motion.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    return BbScaffold(
      title: l10n.navSettings,
      slivers: [
        settings.when(
          loading: () => const SliverFillRemaining(
            child: Center(child: CupertinoActivityIndicator()),
          ),
          error: (error, _) =>
              SliverFillRemaining(child: Center(child: Text('$error'))),
          data: (prefs) {
            final themeName = _themeLabel(l10n, prefs.themeMode);
            final languageName = prefs.localeCode == 'th'
                ? l10n.thai
                : l10n.english;
            final zoneName = prefs.timeZoneId == autoTimeZone
                ? l10n.timeZoneAutomatic
                : zoneCity(prefs.timeZoneId);
            return SliverList(
              delegate: SliverChildListDelegate([
                Appear(
                  child: _LookCard(
                    title: l10n.appTitle,
                    theme: themeName,
                    language: languageName,
                    onTheme: () => _pickTheme(context, ref, prefs.themeMode),
                    onLanguage: () =>
                        _pickLanguage(context, ref, prefs.localeCode),
                  ),
                ),
                Appear(
                  delay: const Duration(milliseconds: 50),
                  child: BbGroupedSection(
                    header: l10n.appearance,
                    children: [
                      _NavRow(
                        title: l10n.theme,
                        value: themeName,
                        icon: Icons.palette_rounded,
                        color: bahtSky,
                        onTap: () => _pickTheme(context, ref, prefs.themeMode),
                      ),
                      _NavRow(
                        title: l10n.language,
                        value: languageName,
                        icon: Icons.translate_rounded,
                        color: bahtSky,
                        onTap: () =>
                            _pickLanguage(context, ref, prefs.localeCode),
                      ),
                      _NavRow(
                        title: l10n.timeZone,
                        value: zoneName,
                        icon: Icons.public_rounded,
                        color: bahtSky,
                        onTap: () =>
                            _pickTimeZone(context, ref, prefs.timeZoneId),
                      ),
                    ],
                  ),
                ),
                Appear(
                  delay: const Duration(milliseconds: 60),
                  child: BbGroupedSection(
                    header: l10n.security,
                    children: [
                      _NavRow(
                        title: prefs.pinHash == null
                            ? l10n.setPin
                            : l10n.changePin,
                        icon: Icons.lock_rounded,
                        color: bahtAccent,
                        onTap: () => _setPin(context, ref, prefs.pinHash),
                      ),
                      if (prefs.pinHash != null)
                        _NavRow(
                          title: l10n.removePin,
                          icon: Icons.lock_open_rounded,
                          color: bahtExpense,
                          destructive: true,
                          onTap: () => _removePin(context, ref, prefs.pinHash!),
                        ),
                      _SwitchRow(
                        title: l10n.biometrics,
                        icon: Icons.fingerprint_rounded,
                        color: bahtSky,
                        value: prefs.biometricsEnabled,
                        onChanged: prefs.pinHash == null
                            ? null
                            : (value) => _setBiometrics(context, ref, value),
                      ),
                    ],
                  ),
                ),
                Appear(
                  delay: const Duration(milliseconds: 140),
                  child: BbGroupedSection(
                    header: l10n.reminders,
                    children: [
                      _SwitchRow(
                        title: l10n.dailyReminder,
                        icon: Icons.notifications_active_rounded,
                        color: bahtSun,
                        value: prefs.dailyReminder,
                        onChanged: (value) => _setReminder(context, ref, value),
                      ),
                    ],
                  ),
                ),
                Appear(
                  delay: const Duration(milliseconds: 180),
                  child: BbGroupedSection(
                    header: l10n.budgets,
                    children: [
                      _NavRow(
                        title: l10n.budgets,
                        icon: Icons.savings_rounded,
                        color: bahtIncome,
                        onTap: () => context.push('/budgets'),
                      ),
                    ],
                  ),
                ),
                Appear(
                  delay: const Duration(milliseconds: 220),
                  child: BbGroupedSection(
                    header: l10n.dataSection,
                    children: [
                      _NavRow(
                        title: l10n.exportCsv,
                        icon: Icons.table_chart_rounded,
                        color: bahtSky,
                        onTap: () => _shareFile(context, ref, csv: true),
                      ),
                      _NavRow(
                        title: l10n.backup,
                        icon: Icons.cloud_upload_rounded,
                        color: const Color(0xFF1E4B7A),
                        onTap: () => _shareFile(context, ref, csv: false),
                      ),
                      _NavRow(
                        title: l10n.restore,
                        icon: Icons.cloud_download_rounded,
                        color: bahtAccent,
                        onTap: () => _restore(context, ref),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ]),
            );
          },
        ),
      ],
    );
  }

  String _themeLabel(AppLocalizations l10n, String mode) {
    return switch (mode) {
      'white' || 'light' => l10n.white,
      'color' => l10n.colorTheme,
      'ocean' => l10n.ocean,
      'dark' => l10n.dark,
      'black' => l10n.black,
      _ => l10n.system,
    };
  }

  Future<void> _pickTheme(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final l10n = AppLocalizations.of(context);
    final selected = current == 'light' ? 'white' : current;
    final choices = <_ThemeChoice>[
      _ThemeChoice('system', l10n.system, const [
        Color(0xFFD6E4F0),
        Color(0xFFF8FAFC),
        Color(0xFF1D4ED8),
        Color(0xFF070E1C),
      ], stops: const [0, 0.5, 0.5, 1]),
      _ThemeChoice('white', l10n.white, const [
        Color(0xFFFFFFFF),
        Color(0xFF5EEAD4),
        Color(0xFFF5C542),
      ]),
      _ThemeChoice('color', l10n.colorTheme, const [
        Color(0xFF6EE7B7),
        Color(0xFF059669),
        Color(0xFF047857),
      ]),
      _ThemeChoice('ocean', l10n.ocean, const [
        Color(0xFF22D3EE),
        Color(0xFF0284C7),
        Color(0xFF0369A1),
      ]),
      _ThemeChoice('dark', l10n.dark, const [
        Color(0xFF38BDF8),
        Color(0xFF2563EB),
        Color(0xFF070E1C),
      ]),
      _ThemeChoice('black', l10n.black, const [
        Color(0xFF0A0906),
        Color(0xFFE8B84A),
        Color(0xFFF5C542),
      ]),
    ];
    final mode = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.theme,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.15,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final choice in choices)
                    _ThemeTile(
                      choice: choice,
                      selected: choice.id == selected ||
                          (choice.id == 'system' && selected == 'system'),
                      onTap: () => Navigator.pop(context, choice.id),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
    if (mode != null && mode != selected) {
      await ref.read(settingsProvider.notifier).setTheme(mode);
    }
  }

  Future<void> _pickLanguage(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final l10n = AppLocalizations.of(context);
    final code = await showCupertinoModalPopup<String>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(l10n.language),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, 'en'),
            child: Text(l10n.english),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, 'th'),
            child: Text(l10n.thai),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
      ),
    );
    if (code != null && code != current) {
      await ref.read(settingsProvider.notifier).setLocale(code);
    }
  }

  Future<void> _pickTimeZone(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final l10n = AppLocalizations.of(context);
    final choice = await pickTimeZone(context, current: current);
    if (choice == null || choice == current) return;
    await ref.read(settingsProvider.notifier).setTimeZone(choice);
    final prefs = ref.read(settingsProvider).asData?.value;
    if (prefs != null && prefs.dailyReminder) {
      await ref.read(budgetAlertsProvider).setDailyReminder(
        enabled: true,
        hour: prefs.reminderHour,
        minute: prefs.reminderMinute,
        title: l10n.reminderTitle,
        body: l10n.reminderBody,
      );
    }
    await ref.read(exchangeRatesProvider.notifier).refresh();
  }

  Future<void> _setPin(
    BuildContext context,
    WidgetRef ref,
    String? currentHash,
  ) async {
    final pin = await PinFlow.push(
      context,
      kind: currentHash == null ? PinFlowKind.set : PinFlowKind.change,
      currentHash: currentHash,
    );
    if (pin == null) return;
    await ref.read(settingsProvider.notifier).setPin(hashPin(pin));
    ref.read(sessionUnlockedProvider.notifier).unlock();
  }

  Future<void> _removePin(
    BuildContext context,
    WidgetRef ref,
    String currentHash,
  ) async {
    final pin = await PinFlow.push(
      context,
      kind: PinFlowKind.remove,
      currentHash: currentHash,
    );
    if (pin == null) return;
    await ref.read(settingsProvider.notifier).setPin(null);
  }

  Future<void> _setBiometrics(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    final l10n = AppLocalizations.of(context);
    if (!enabled) {
      await ref.read(settingsProvider.notifier).setBiometrics(false);
      return;
    }
    try {
      final ok = await LocalAuthentication().authenticate(
        localizedReason: l10n.unlock,
        biometricOnly: true,
      );
      if (ok) {
        await ref.read(settingsProvider.notifier).setBiometrics(true);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.biometricsUnavailable)),
        );
      }
    }
  }

  Future<void> _setReminder(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    final l10n = AppLocalizations.of(context);
    await ref.read(settingsProvider.notifier).setReminder(enabled: enabled);
    await ref.read(budgetAlertsProvider).setDailyReminder(
      enabled: enabled,
      hour: 20,
      minute: 0,
      title: l10n.reminderTitle,
      body: l10n.reminderBody,
    );
  }

  Future<void> _shareFile(
    BuildContext context,
    WidgetRef ref, {
    required bool csv,
  }) async {
    final l10n = AppLocalizations.of(context);
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null && box.hasSize
        ? box.localToGlobal(Offset.zero) & box.size
        : null;
    ref.read(suppressLockProvider.notifier).setValue(true);
    try {
      final repo = ref.read(backupRepositoryProvider);
      late final File file;
      if (csv) {
        file = await repo.exportCsv();
      } else {
        final hash = ref.read(settingsProvider).asData?.value.pinHash;
        if (hash == null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.backupNeedsPin)),
            );
          }
          return;
        }
        final pin = await PinFlow.push(
          context,
          kind: PinFlowKind.verify,
          currentHash: hash,
          prompt: l10n.backupUnlock,
        );
        if (pin == null) return;
        file = await repo.exportBackup(pin);
      }
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          title: l10n.appTitle,
          sharePositionOrigin: origin,
        ),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.exportDone)));
      }
    } finally {
      ref.read(suppressLockProvider.notifier).setValue(false);
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    ref.read(suppressLockProvider.notifier).setValue(true);
    try {
      final picked = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (picked == null) return;
      final text = utf8.decode(await picked.readAsBytes());
      String? pin;
      if (backupIsSealed(text)) {
        if (!context.mounted) return;
        pin = await PinFlow.push(
          context,
          kind: PinFlowKind.collect,
          prompt: l10n.restoreUnlock,
        );
        if (pin == null) return;
      }
      try {
        await ref.read(backupRepositoryProvider).restore(text, pin: pin);
      } on FormatException {
        if (context.mounted && pin != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.wrongBackupPin)),
          );
        } else {
          rethrow;
        }
        return;
      }
      ref.invalidate(settingsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.restoreDone)));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.restoreFailed)));
      }
    } finally {
      ref.read(suppressLockProvider.notifier).setValue(false);
    }
  }
}

class _LookCard extends StatelessWidget {
  const _LookCard({
    required this.title,
    required this.theme,
    required this.language,
    required this.onTheme,
    required this.onLanguage,
  });

  final String title;
  final String theme;
  final String language;
  final VoidCallback onTheme;
  final VoidCallback onLanguage;

  @override
  Widget build(BuildContext context) {
    final look = BuddyLook.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: look.banner,
          borderRadius: BorderRadius.circular(26),
          border: look.bannerFilled
              ? null
              : Border.all(color: look.bannerInk.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF12324F).withValues(
                alpha: look.brightness == Brightness.dark ? 0.28 : 0.12,
              ),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: look.bannerFilled
                          ? Colors.white.withValues(alpha: 0.2)
                          : bahtAccent.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(
                      width: 42,
                      height: 42,
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: look.bannerFilled ? Colors.white : bahtAccent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: look.bannerInk,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _LookChip(
                      icon: Icons.palette_rounded,
                      label: theme,
                      ink: look.bannerInk,
                      onTap: onTheme,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _LookChip(
                      icon: Icons.translate_rounded,
                      label: language,
                      ink: look.bannerInk,
                      onTap: onLanguage,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LookChip extends StatelessWidget {
  const _LookChip({
    required this.icon,
    required this.label,
    required this.ink,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color ink;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ink.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 16, color: ink),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.value,
    this.destructive = false,
  });

  final String title;
  final IconData icon;
  final Color color;
  final String? value;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final ink = destructive ? Theme.of(context).colorScheme.error : null;
    return BbRow(
      onTap: onTap,
      child: Row(
        children: [
          _IconBadge(icon: icon, color: destructive ? bahtExpense : color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: ink, fontWeight: FontWeight.w600),
            ),
          ),
          if (value != null)
            Text(
              value!,
              style: TextStyle(
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(width: 4),
          Icon(
            CupertinoIcons.chevron_forward,
            size: 16,
            color: CupertinoColors.tertiaryLabel.resolveFrom(context),
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.icon,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final IconData icon;
  final Color color;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return BbRow(
      child: Row(
        children: [
          _IconBadge(icon: icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: color,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

class _ThemeChoice {
  const _ThemeChoice(this.id, this.label, this.colors, {this.stops});

  final String id;
  final String label;
  final List<Color> colors;
  final List<double>? stops;
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.choice,
    required this.selected,
    required this.onTap,
  });

  final _ThemeChoice choice;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);
    final outline = selected ? 2.5 : 1.5;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: selected
                  ? BuddyLook.of(context).accent
                  : bahtInk.withValues(alpha: 0.42),
              width: outline,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(outline),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: choice.colors,
                  stops: choice.stops,
                ),
                borderRadius: BorderRadius.circular(18 - outline),
                border: Border.all(
                  color: Colors.white.withValues(alpha: selected ? 0 : 0.95),
                  width: selected ? 0 : 1.25,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: choice.stops == null
                      ? _ThemeLabel(choice: choice)
                      : FractionallySizedBox(
                          widthFactor: 0.46,
                          alignment: Alignment.centerLeft,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: _ThemeLabel(choice: choice),
                          ),
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

class _ThemeLabel extends StatelessWidget {
  const _ThemeLabel({required this.choice});

  final _ThemeChoice choice;

  @override
  Widget build(BuildContext context) {
    return Text(
      choice.label,
      maxLines: 1,
      style: TextStyle(
        color: choice.colors.first.computeLuminance() > 0.7
            ? const Color(0xFF142033)
            : Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: 14,
      ),
    );
  }
}
