import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/clock.dart';
import '../../core/format.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../features/budgets/budget_math.dart';
import '../../features/slips/category_suggester.dart';
import '../../features/slips/slip_parser.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../../services/slip_image_store.dart';
import '../../widgets/bb_grouped_section.dart';
import '../../widgets/motion.dart';

class EntryArgs {
  const EntryArgs({
    this.existing,
    this.draft,
    this.imagePath,
    this.initialType = 'expense',
  });

  final MoneyTransaction? existing;
  final SlipDraft? draft;
  final String? imagePath;
  final String initialType;
}

class EntryScreen extends ConsumerStatefulWidget {
  const EntryScreen({super.key, this.args});

  final EntryArgs? args;

  @override
  ConsumerState<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends ConsumerState<EntryScreen> {
  final _amount = TextEditingController();
  final _amountFocus = FocusNode();
  final _note = TextEditingController();
  final _recipient = TextEditingController();
  final _reference = TextEditingController();
  DateTime _when = zoneInstant(zoneNow());
  String _type = 'expense';
  int? _categoryId;
  String? _imagePath;
  String? _pendingKey;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.args?.existing;
    final draft = widget.args?.draft;
    _type = widget.args?.initialType ?? 'expense';
    _imagePath = widget.args?.imagePath ?? existing?.imagePath;
    if (existing != null) {
      _amount.text = existing.amount.toStringAsFixed(2);
      _note.text = existing.note;
      _recipient.text = existing.recipient ?? '';
      _reference.text = existing.slipReference ?? '';
      _when = existing.occurredAt;
      _type = existing.type;
      _categoryId = existing.categoryId;
    } else if (draft != null) {
      if (draft.amount != null) {
        _amount.text = draft.amount!.toStringAsFixed(2);
      }
      _recipient.text = draft.recipient ?? '';
      _reference.text = draft.reference ?? '';
      _when = draft.date == null
          ? zoneInstant(zoneNow())
          : zoneInstant(draft.date!);
      _pendingKey =
          draft.suggestedKey ??
          CategorySuggester.suggest(recipient: draft.recipient);
    }
    _amount.addListener(_refreshAmount);
  }

  void _refreshAmount() {
    if (mounted) setState(() {});
  }

  double _digitsWidth(TextStyle? style) {
    final sample = _amount.text.isEmpty ? '0.00' : _amount.text;
    final painter = TextPainter(
      text: TextSpan(text: sample, style: style),
      textDirection: Directionality.of(context),
      maxLines: 1,
    )..layout();
    return painter.width + 16;
  }

  @override
  void dispose() {
    _amount.removeListener(_refreshAmount);
    _amount.dispose();
    _amountFocus.dispose();
    _note.dispose();
    _recipient.dispose();
    _reference.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(timeZoneProvider);
    final l10n = AppLocalizations.of(context);
    final categories = ref.watch(categoriesProvider);
    final isSlip = widget.args?.draft != null;
    return BuddyBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            isSlip
                ? l10n.reviewSlip
                : _type == 'income'
                ? l10n.income
                : l10n.manualEntry,
          ),
        ),
        body: categories.when(
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (error, _) => Center(child: Text('$error')),
          data: (rows) {
            _ensureCategory(rows);
            final options = rows
                .where((c) => c.isIncome == (_type == 'income'))
                .toList();
            final locale = Localizations.localeOf(context);
            final income = _type == 'income';
            final accent = income ? bahtIncome : bahtExpense;
            Category? chosen;
            for (final category in options) {
              if (category.id == _categoryId) chosen = category;
            }
            final amountStyle = Theme.of(context).textTheme.displaySmall
                ?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: accent,
                  height: 1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                );
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 12),
                    children: [
                      Appear(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: cardWash(context),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: accent.withValues(alpha: 0.22),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withValues(alpha: 0.12),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                16,
                                16,
                                18,
                              ),
                              child: Column(
                                children: [
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final half =
                                          (constraints.maxWidth - 4) / 2;
                                      return CupertinoSlidingSegmentedControl<
                                        String
                                      >(
                                        groupValue: _type,
                                        children: {
                                          'expense': SizedBox(
                                            width: half,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
                                              child: Text(
                                                l10n.expense,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          'income': SizedBox(
                                            width: half,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
                                              child: Text(
                                                l10n.income,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        },
                                        onValueChanged: (value) {
                                          if (value == null) return;
                                          setState(() {
                                            _type = value;
                                            _ensureCategory(rows, force: true);
                                          });
                                        },
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 18),
                                  GestureDetector(
                                    onTap: () => _amountFocus.requestFocus(),
                                    behavior: HitTestBehavior.opaque,
                                    child: Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text('฿', style: amountStyle),
                                          const SizedBox(width: 2),
                                          SizedBox(
                                            width: _digitsWidth(
                                              amountStyle,
                                            ).clamp(56.0, 240.0),
                                            child: TextField(
                                              key: const Key('amount-field'),
                                              focusNode: _amountFocus,
                                              controller: _amount,
                                              textAlign: TextAlign.left,
                                              keyboardType:
                                                  const TextInputType.numberWithOptions(
                                                    decimal: true,
                                                  ),
                                              style: amountStyle,
                                              cursorColor: accent,
                                              decoration: InputDecoration(
                                                hintText: '0.00',
                                                hintStyle: amountStyle
                                                    ?.copyWith(
                                                      color: accent.withValues(
                                                        alpha: 0.28,
                                                      ),
                                                    ),
                                                isCollapsed: true,
                                                contentPadding: EdgeInsets.zero,
                                                filled: false,
                                                border: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (chosen != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      categoryLabel(chosen, locale),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            color: categoryStyle(
                                              chosen.key,
                                            ).color,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_imagePath != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Image.file(
                                  File(_imagePath!),
                                  height: 160,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.45,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: TextButton(
                                      onPressed: () =>
                                          setState(() => _imagePath = null),
                                      child: Text(
                                        l10n.removePhoto,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (widget.args?.draft != null &&
                          widget.args!.draft!.rawText.isNotEmpty)
                        Appear(
                          delay: const Duration(milliseconds: 80),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: cardWash(context),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.ocrText,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(color: bahtAccent),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      widget.args!.draft!.rawText,
                                      maxLines: 8,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      Appear(
                        delay: const Duration(milliseconds: 90),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
                          child: Text(
                            l10n.type.toUpperCase(),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  letterSpacing: 0.6,
                                  color: CupertinoColors.secondaryLabel
                                      .resolveFrom(context),
                                ),
                          ),
                        ),
                      ),
                      Appear(
                        delay: const Duration(milliseconds: 110),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 280),
                          switchInCurve: Curves.easeOutCubic,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.08),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: Padding(
                            key: ValueKey(_type),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                const columns = 4;
                                final width =
                                    (constraints.maxWidth - 18) / columns;
                                return Wrap(
                                  spacing: 6,
                                  runSpacing: 14,
                                  children: [
                                    for (final category in options)
                                      SizedBox(
                                        width: width,
                                        child: _TypeChip(
                                          label: categoryLabel(
                                            category,
                                            locale,
                                          ),
                                          style: categoryStyle(category.key),
                                          selected: category.id == _categoryId,
                                          onTap: () => setState(() {
                                            _categoryId = category.id;
                                            _pendingKey = null;
                                          }),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      if (_pendingKey != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 16, 0),
                          child: Text(
                            l10n.suggested,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: bahtAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      BbGroupedSection(
                        children: [
                          BbRow(
                            onTap: _pickDateTime,
                            child: _DetailLine(
                              icon: Icons.calendar_today_rounded,
                              label: l10n.date,
                              value: formatWhen(locale, _when),
                            ),
                          ),
                          _DetailField(
                            icon: Icons.notes_rounded,
                            label: l10n.note,
                            controller: _note,
                          ),
                          _DetailField(
                            icon: Icons.person_outline_rounded,
                            label: l10n.recipient,
                            controller: _recipient,
                          ),
                          _DetailField(
                            icon: Icons.tag_rounded,
                            label: l10n.reference,
                            controller: _reference,
                          ),
                          if (_imagePath == null)
                            BbRow(
                              onTap: _pickPhoto,
                              child: _DetailLine(
                                icon: Icons.add_a_photo_outlined,
                                label: l10n.optionalPhoto,
                              ),
                            ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: SizedBox(
                          width: double.infinity,
                          child: CupertinoButton(
                            key: const Key('save-entry'),
                            color: accent,
                            borderRadius: BorderRadius.circular(18),
                            onPressed: _saving ? null : () => _save(rows),
                            child: _saving
                                ? const CupertinoActivityIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    l10n.save,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _pickPhoto() async {
    ref.read(suppressLockProvider.notifier).setValue(true);
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file == null) return;
      final stored = await persistSlipImage(file.path);
      if (!mounted) return;
      setState(() => _imagePath = stored);
    } finally {
      ref.read(suppressLockProvider.notifier).setValue(false);
    }
  }

  void _ensureCategory(List<Category> rows, {bool force = false}) {
    final options = rows
        .where((c) => c.isIncome == (_type == 'income'))
        .toList();
    if (options.isEmpty) return;
    if (!force && options.any((c) => c.id == _categoryId)) return;
    Category? match;
    if (_pendingKey != null) {
      for (final category in options) {
        if (category.key == _pendingKey) match = category;
      }
    }
    match ??= options.firstWhere(
      (c) => c.key == (_type == 'income' ? 'salary' : 'food'),
      orElse: () => options.first,
    );
    _categoryId = match.id;
  }

  Future<void> _pickDateTime() async {
    final shown = zoneWall(_when);
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(shown.year, shown.month, shown.day),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: shown.hour, minute: shown.minute),
    );
    if (!mounted) return;
    setState(() {
      _when = zoneInstant(
        DateTime(
          date.year,
          date.month,
          date.day,
          time?.hour ?? shown.hour,
          time?.minute ?? shown.minute,
        ),
      );
    });
  }

  Future<void> _save(List<Category> rows) async {
    final l10n = AppLocalizations.of(context);
    final amount = double.tryParse(_amount.text.replaceAll(',', ''));
    if (amount == null || amount <= 0 || _categoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.requiredAmount)));
      return;
    }
    setState(() => _saving = true);
    final draft = TransactionDraft(
      id: widget.args?.existing?.id,
      amount: amount,
      type: _type,
      categoryId: _categoryId!,
      occurredAt: _when,
      note: _note.text.trim(),
      recipient: _recipient.text,
      slipReference: _reference.text,
      imagePath: _imagePath,
    );
    final repo = ref.read(transactionRepositoryProvider);
    final db = ref.read(databaseProvider);
    final month = ReportMonth.of(_when);
    final previous = _type == 'expense' || widget.args?.existing != null
        ? await db.expenseSpent(
            categoryId: _categoryId!,
            start: month.start,
            end: month.end,
            excludingId: draft.id,
          )
        : 0.0;
    var status = await repo.save(draft);
    if (status == SaveStatus.duplicate && mounted) {
      final strip = await showCupertinoDialog<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(l10n.duplicateTitle),
          content: Text(l10n.duplicateBody),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.saveWithoutReference),
            ),
          ],
        ),
      );
      if (strip == true) {
        status = await repo.save(
          TransactionDraft(
            id: draft.id,
            amount: draft.amount,
            type: draft.type,
            categoryId: draft.categoryId,
            occurredAt: draft.occurredAt,
            note: draft.note,
            recipient: draft.recipient,
            imagePath: draft.imagePath,
          ),
        );
      }
    }
    if (status == SaveStatus.saved && _type == 'expense') {
      final budget = await db.budgetFor(_categoryId!);
      if (budget != null) {
        final crossing = budgetCrossing(
          previousSpent: previous,
          nextSpent: previous + amount,
          limit: budget.monthlyLimit,
        );
        if (crossing != BudgetCrossing.none && mounted) {
          final category = rows.firstWhere((c) => c.id == _categoryId);
          final name = categoryLabel(category, Localizations.localeOf(context));
          final body = crossing == BudgetCrossing.reached
              ? l10n.budgetReached(name)
              : l10n.budgetWarning(name);
          await ref
              .read(budgetAlertsProvider)
              .notify(id: category.id, title: l10n.reminderTitle, body: body);
        }
      }
    }
    if (!mounted) return;
    setState(() => _saving = false);
    if (status == SaveStatus.saved) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.saved)));
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    }
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.icon, required this.label, this.value});

  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final muted = CupertinoColors.secondaryLabel.resolveFrom(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: muted),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        if (value != null) ...[
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(color: muted),
            ),
          ),
          const SizedBox(width: 4),
          Icon(CupertinoIcons.chevron_forward, size: 16, color: muted),
        ],
      ],
    );
  }
}

class _DetailField extends StatelessWidget {
  const _DetailField({
    required this.icon,
    required this.label,
    required this.controller,
  });

  final IconData icon;
  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final muted = CupertinoColors.secondaryLabel.resolveFrom(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 12, 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: muted),
          const SizedBox(width: 12),
          SizedBox(
            width: 96,
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.end,
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: '—',
                hintStyle: TextStyle(color: muted.withValues(alpha: 0.7)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.style,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final CategoryStyle style;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final muted = CupertinoColors.secondaryLabel.resolveFrom(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: selected
                  ? style.color
                  : style.color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: style.color.withValues(alpha: 0.28),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              style.icon,
              color: selected ? Colors.white : style.color,
              size: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: selected ? style.color : muted,
            ),
          ),
        ],
      ),
    );
  }
}

class ReportMonth {
  ReportMonth(this.start, this.end);

  final DateTime start;
  final DateTime end;

  factory ReportMonth.of(DateTime date) {
    final wall = zoneWall(date);
    return ReportMonth(
      zoneInstant(DateTime(wall.year, wall.month)),
      zoneInstant(DateTime(wall.year, wall.month + 1)),
    );
  }
}
