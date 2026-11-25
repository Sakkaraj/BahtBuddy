import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/format.dart';
import '../../features/entry/entry_screen.dart';
import '../../features/slips/slip_parser.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../../services/slip_image_store.dart';
import '../../widgets/motion.dart';

enum AddChoice { camera, gallery, manual }

Future<void> showAddActions(BuildContext context, WidgetRef ref) async {
  final choice = await showModalBottomSheet<AddChoice>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => const _AddSheet(),
  );
  if (!context.mounted || choice == null) return;
  switch (choice) {
    case AddChoice.manual:
      await context.push('/entry', extra: const EntryArgs());
    case AddChoice.camera:
      await scanSlip(context, ref, ImageSource.camera);
    case AddChoice.gallery:
      await scanSlip(context, ref, ImageSource.gallery);
  }
}

Future<void> readSampleSlip(BuildContext context, WidgetRef ref) async {
  final data = await rootBundle.load('assets/sample_slip.png');
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/sample_slip.png');
  await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
  if (!context.mounted) return;
  await readSlipFile(context, ref, file.path);
}

Future<void> scanSlip(
  BuildContext context,
  WidgetRef ref,
  ImageSource source,
) async {
  ref.read(suppressLockProvider.notifier).setValue(true);
  try {
    final file = await ImagePicker().pickImage(
      source: source,
      imageQuality: 95,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (file == null || !context.mounted) return;
    await readSlipFile(context, ref, file.path);
  } finally {
    ref.read(suppressLockProvider.notifier).setValue(false);
  }
}

Future<void> readSlipFile(
  BuildContext context,
  WidgetRef ref,
  String sourcePath,
) async {
  final l10n = AppLocalizations.of(context);
  ref.read(suppressLockProvider.notifier).setValue(true);
  var dialogOpen = false;
  try {
    dialogOpen = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0E9F8A), Color(0xFF12324F)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CupertinoActivityIndicator(radius: 14, color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  l10n.parsingSlip,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    final stored = await persistSlipImage(sourcePath);
    var failed = false;
    var text = '';
    try {
      text = await ref.read(slipOcrProvider).recognize(stored);
    } catch (error, stack) {
      failed = true;
      debugPrint('BahtBuddy OCR failed: $error\n$stack');
    }
    final draft = SlipParser.parse(text);
    final suggested = await ref
        .read(transactionRepositoryProvider)
        .suggestKey(draft.recipient);
    if (!context.mounted) return;
    if (dialogOpen) {
      Navigator.of(context, rootNavigator: true).pop();
      dialogOpen = false;
    }
    await context.push(
      '/entry',
      extra: EntryArgs(
        draft: draft.copyWith(suggestedKey: suggested),
        imagePath: stored,
      ),
    );
    if (failed && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.ocrFailed)));
    }
  } finally {
    ref.read(suppressLockProvider.notifier).setValue(false);
    if (dialogOpen && context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}

class _AddSheet extends StatelessWidget {
  const _AddSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: groupedSurface(context),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                l10n.scanSlip,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.cashHint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
              ),
              const SizedBox(height: 16),
              Appear(
                child: _ChoiceTile(
                  icon: Icons.photo_camera_rounded,
                  colors: const [Color(0xFF14B8A6), Color(0xFF0E9F8A)],
                  label: l10n.camera,
                  onTap: () => Navigator.pop(context, AddChoice.camera),
                ),
              ),
              const SizedBox(height: 10),
              Appear(
                delay: const Duration(milliseconds: 50),
                child: _ChoiceTile(
                  icon: Icons.photo_library_rounded,
                  colors: const [Color(0xFF1E4B7A), Color(0xFF163A5F)],
                  label: l10n.gallery,
                  onTap: () => Navigator.pop(context, AddChoice.gallery),
                ),
              ),
              const SizedBox(height: 10),
              Appear(
                delay: const Duration(milliseconds: 100),
                child: _ChoiceTile(
                  icon: Icons.edit_rounded,
                  colors: const [Color(0xFF12324F), Color(0xFF0E7C72)],
                  label: l10n.manualEntry,
                  onTap: () => Navigator.pop(context, AddChoice.manual),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.icon,
    required this.colors,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final List<Color> colors;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: colors.first.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colors.last),
          ],
        ),
      ),
    );
  }
}
