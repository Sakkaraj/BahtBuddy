import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../features/budgets/budget_math.dart';
import '../../features/slips/category_suggester.dart';
import '../../features/slips/slip_parser.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../../widgets/bb_grouped_section.dart';

class EntryArgs {
  const EntryArgs({this.existing, this.draft, this.imagePath});

  final MoneyTransaction? existing;
  final SlipDraft? draft;
  final String? imagePath;
}

class EntryScreen extends ConsumerStatefulWidget {
  const EntryScreen({super.key, this.args});

  final EntryArgs? args;

  @override
  ConsumerState<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends ConsumerState<EntryScreen> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  final _recipient = TextEditingController();
  final _reference = TextEditingController();
  DateTime _when = DateTime.now();
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
      _when = draft.date ?? DateTime.now();
      _pendingKey =
          draft.suggestedKey ??
          CategorySuggester.suggest(recipient: draft.recipient);
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    _recipient.dispose();
    _reference.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = ref.watch(categoriesProvider);
    final isSlip = widget.args?.draft != null;
    return Scaffold(
      backgroundColor: groupedBackground(context),
      appBar: AppBar(
        title: Text(isSlip ? l10n.reviewSlip : l10n.manualEntry),
        actions: [
          categories.maybeWhen(
            data: (rows) => CupertinoButton(
              key: const Key('save-entry'),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              onPressed: _saving ? null : () => _save(rows),
              child: _saving
                  ? const CupertinoActivityIndicator()
                  : Text(
                      l10n.save,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
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
          return ListView(
            children: [
              if (_imagePath != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Image.file(
                          File(_imagePath!),
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        TextButton(
                          onPressed: () => setState(() => _imagePath = null),
                          child: Text(l10n.removePhoto),
                        ),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: TextField(
                  key: const Key('amount-field'),
                  controller: _amount,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    prefixText: '฿ ',
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Center(
                  child: CupertinoSlidingSegmentedControl<String>(
                    groupValue: _type,
                    children: {
                      'expense': Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Text(l10n.expense),
                      ),
                      'income': Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Text(l10n.income),
                      ),
                    },
                    onValueChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _type = value;
                        _ensureCategory(rows, force: true);
                      });
                    },
                  ),
                ),
              ),
              BbGroupedSection(
                children: [
                  BbRow(
                    onTap: _pickDateTime,
                    child: _LabeledValue(
                      label: l10n.date,
                      value: formatWhen(locale, _when),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: DropdownButtonFormField<int>(
                      key: ValueKey('$_type-$_categoryId'),
                      initialValue: options.any((c) => c.id == _categoryId)
                          ? _categoryId
                          : null,
                      decoration: InputDecoration(
                        labelText: l10n.category,
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      items: [
                        for (final category in options)
                          DropdownMenuItem(
                            value: category.id,
                            child: Text(categoryLabel(category, locale)),
                          ),
                      ],
                      onChanged: (value) => setState(() {
                        _categoryId = value;
                        _pendingKey = null;
                      }),
                    ),
                  ),
                  if (_pendingKey != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Text(
                        l10n.suggested,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: bahtAccent,
                        ),
                      ),
                    ),
                ],
              ),
              BbGroupedSection(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextField(
                      controller: _note,
                      decoration: InputDecoration(
                        labelText: l10n.note,
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextField(
                      controller: _recipient,
                      decoration: InputDecoration(
                        labelText: l10n.recipient,
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextField(
                      controller: _reference,
                      decoration: InputDecoration(
                        labelText: l10n.reference,
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
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
      (c) => c.key == (_type == 'income' ? 'salary' : 'other'),
      orElse: () => options.first,
    );
    _categoryId = match.id;
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _when,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_when),
    );
    if (!mounted) return;
    setState(() {
      _when = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? _when.hour,
        time?.minute ?? _when.minute,
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
          await ref.read(budgetAlertsProvider).notify(
            id: category.id,
            title: l10n.reminderTitle,
            body: body,
          );
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

class _LabeledValue extends StatelessWidget {
  const _LabeledValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          CupertinoIcons.chevron_forward,
          size: 16,
          color: CupertinoColors.tertiaryLabel.resolveFrom(context),
        ),
      ],
    );
  }
}

class ReportMonth {
  ReportMonth(this.start, this.end);

  final DateTime start;
  final DateTime end;

  factory ReportMonth.of(DateTime date) {
    return ReportMonth(
      DateTime(date.year, date.month),
      DateTime(date.year, date.month + 1),
    );
  }
}
