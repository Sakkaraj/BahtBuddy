import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../features/entry/entry_screen.dart';
import '../../features/slips/slip_parser.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../../services/slip_image_store.dart';

enum AddChoice { camera, gallery, manual }

Future<void> showAddActions(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final choice = await showCupertinoModalPopup<AddChoice>(
    context: context,
    builder: (context) => CupertinoActionSheet(
      title: Text(l10n.scanSlip),
      message: Text(l10n.cashHint),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context, AddChoice.camera),
          child: Text(l10n.camera),
        ),
        CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context, AddChoice.gallery),
          child: Text(l10n.gallery),
        ),
        CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context, AddChoice.manual),
          child: Text(l10n.manualEntry),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        isDefaultAction: true,
        onPressed: () => Navigator.pop(context),
        child: Text(l10n.cancel),
      ),
    ),
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

Future<void> scanSlip(
  BuildContext context,
  WidgetRef ref,
  ImageSource source,
) async {
  final l10n = AppLocalizations.of(context);
  ref.read(suppressLockProvider.notifier).setValue(true);
  var dialogOpen = false;
  try {
    final file = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
    );
    if (file == null || !context.mounted) return;
    dialogOpen = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CupertinoActivityIndicator(radius: 14),
              const SizedBox(height: 12),
              Text(
                l10n.parsingSlip,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
    final stored = await persistSlipImage(file.path);
    var failed = false;
    var text = '';
    try {
      text = await ref.read(slipOcrProvider).recognize(stored);
    } catch (_) {
      failed = true;
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
