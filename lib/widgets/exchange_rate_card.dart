import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/format.dart';
import '../l10n/app_localizations.dart';
import '../providers.dart';
import '../services/exchange_rates.dart';

class ExchangeRateCard extends ConsumerWidget {
  const ExchangeRateCard({super.key, required this.balance});

  final double balance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final rates = ref.watch(exchangeRatesProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: cardWash(context),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: bahtSky.withValues(alpha: 0.14),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: rates.when(
            loading: () => const SizedBox(
              height: 72,
              child: Center(child: CupertinoActivityIndicator()),
            ),
            error: (_, _) => _Offline(
              message: l10n.exchangeOffline,
              action: l10n.exchangeRetry,
              onRetry: () => ref.read(exchangeRatesProvider.notifier).refresh(),
            ),
            data: (board) {
              if (board == null) {
                return _Offline(
                  message: l10n.exchangeOffline,
                  action: l10n.exchangeRetry,
                  onRetry: () =>
                      ref.read(exchangeRatesProvider.notifier).refresh(),
                );
              }
              final date = DateFormat.MMMd(locale.languageCode).format(board.date);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.currency_exchange_rounded, color: bahtAccent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.exchangeRates,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () =>
                            ref.read(exchangeRatesProvider.notifier).refresh(),
                        icon: const Icon(Icons.refresh_rounded, size: 20),
                      ),
                    ],
                  ),
                  Text(
                    '${formatBaht(locale, balance)} · ${l10n.exchangeAsOf(date)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 72,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: exchangeCodes.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final code = exchangeCodes[index];
                        if (board.bahtPerUnit[code] == null) {
                          return const SizedBox.shrink();
                        }
                        final foreign = foreignFromBaht(board, code, balance);
                        return _RateChip(
                          code: code,
                          value: formatForeign(code, foreign),
                          onTap: () => _openConverter(context, board, code),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        ),
      ),
    );
  }

  void _openConverter(BuildContext context, ExchangeBoard board, String code) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _Converter(
        board: board,
        initial: code,
        balance: balance,
      ),
    );
  }
}

String formatForeign(String code, double amount) {
  final digits = code == 'JPY' ? 0 : 2;
  return NumberFormat.currency(
    name: code,
    symbol: '',
    decimalDigits: digits,
  ).format(amount).trim();
}

class _RateChip extends StatelessWidget {
  const _RateChip({
    required this.code,
    required this.value,
    required this.onTap,
  });

  final String code;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bahtAccent.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                code,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: bahtAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Offline extends StatelessWidget {
  const _Offline({
    required this.message,
    required this.action,
    required this.onRetry,
  });

  final String message;
  final String action;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.currency_exchange_rounded, color: bahtAccent),
        const SizedBox(width: 10),
        Expanded(child: Text(message)),
        TextButton(onPressed: onRetry, child: Text(action)),
      ],
    );
  }
}

class _Converter extends StatefulWidget {
  const _Converter({
    required this.board,
    required this.initial,
    required this.balance,
  });

  final ExchangeBoard board;
  final String initial;
  final double balance;

  @override
  State<_Converter> createState() => _ConverterState();
}

class _ConverterState extends State<_Converter> {
  late String _code = widget.initial;
  late final _amount = TextEditingController(
    text: widget.balance.toStringAsFixed(2),
  );

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final input = double.tryParse(_amount.text.replaceAll(',', '')) ?? 0;
    final result = foreignFromBaht(widget.board, _code, input);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${l10n.balance} · $_code',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amount,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            style: Theme.of(context).textTheme.headlineSmall,
            decoration: InputDecoration(labelText: l10n.amount),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final code in exchangeCodes)
                ChoiceChip(
                  label: Text(code),
                  selected: code == _code,
                  onSelected: (_) => setState(() => _code = code),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${formatForeign(_code, result)} $_code',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: bahtAccent,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
