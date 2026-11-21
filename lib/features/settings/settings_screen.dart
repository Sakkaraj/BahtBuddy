import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/pin_hash.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../lock/pin_flow.dart';
import '../../widgets/bb_grouped_section.dart';
import '../../widgets/bb_scaffold.dart';

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
          data: (prefs) => SliverList(
            delegate: SliverChildListDelegate([
              BbGroupedSection(
                header: l10n.appearance,
                children: [
                  _NavRow(
                    title: l10n.theme,
                    value: _themeLabel(l10n, prefs.themeMode),
                    onTap: () => _pickTheme(context, ref, prefs.themeMode),
                  ),
                  _NavRow(
                    title: l10n.language,
                    value: prefs.localeCode == 'th' ? l10n.thai : l10n.english,
                    onTap: () =>
                        _pickLanguage(context, ref, prefs.localeCode),
                  ),
                ],
              ),
              BbGroupedSection(
                header: l10n.security,
                children: [
                  _NavRow(
                    title: prefs.pinHash == null ? l10n.setPin : l10n.changePin,
                    onTap: () => _setPin(context, ref, prefs.pinHash),
                  ),
                  if (prefs.pinHash != null)
                    _NavRow(
                      title: l10n.removePin,
                      destructive: true,
                      onTap: () => _removePin(context, ref, prefs.pinHash!),
                    ),
                  BbRow(
                    child: Row(
                      children: [
                        Expanded(child: Text(l10n.biometrics)),
                        Switch.adaptive(
                          value: prefs.biometricsEnabled,
                          onChanged: prefs.pinHash == null
                              ? null
                              : (value) => _setBiometrics(context, ref, value),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              BbGroupedSection(
                header: l10n.reminders,
                children: [
                  BbRow(
                    child: Row(
                      children: [
                        Expanded(child: Text(l10n.dailyReminder)),
                        Switch.adaptive(
                          value: prefs.dailyReminder,
                          onChanged: (value) =>
                              _setReminder(context, ref, value),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              BbGroupedSection(
                header: l10n.budgets,
                children: [
                  _NavRow(
                    title: l10n.budgets,
                    onTap: () => context.push('/budgets'),
                  ),
                ],
              ),
              BbGroupedSection(
                header: l10n.dataSection,
                children: [
                  _NavRow(
                    title: l10n.exportCsv,
                    onTap: () => _shareFile(context, ref, csv: true),
                  ),
                  _NavRow(
                    title: l10n.backup,
                    onTap: () => _shareFile(context, ref, csv: false),
                  ),
                  _NavRow(
                    title: l10n.restore,
                    onTap: () => _restore(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }

  String _themeLabel(AppLocalizations l10n, String mode) {
    return switch (mode) {
      'light' => l10n.light,
      'dark' => l10n.dark,
      _ => l10n.system,
    };
  }

  Future<void> _pickTheme(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final l10n = AppLocalizations.of(context);
    final mode = await showCupertinoModalPopup<String>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(l10n.theme),
        actions: [
          for (final entry in {
            'system': l10n.system,
            'light': l10n.light,
            'dark': l10n.dark,
          }.entries)
            CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(context, entry.key),
              child: Text(entry.value),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
      ),
    );
    if (mode != null && mode != current) {
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
    ref.read(suppressLockProvider.notifier).setValue(true);
    try {
      final repo = ref.read(backupRepositoryProvider);
      final file = csv ? await repo.exportCsv() : await repo.exportBackup();
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], title: l10n.appTitle),
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
      final text = picked.path != null
          ? await File(picked.path!).readAsString()
          : utf8.decode(await picked.readAsBytes());
      await ref.read(backupRepositoryProvider).restore(text);
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

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.title,
    required this.onTap,
    this.value,
    this.destructive = false,
  });

  final String title;
  final String? value;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return BbRow(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: destructive
                    ? Theme.of(context).colorScheme.error
                    : null,
              ),
            ),
          ),
          if (value != null)
            Text(
              value!,
              style: TextStyle(
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
              ),
            ),
          const SizedBox(width: 6),
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
