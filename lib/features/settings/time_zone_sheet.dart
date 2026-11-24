import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/clock.dart';
import '../../l10n/app_localizations.dart';

Future<String?> pickTimeZone(BuildContext context, {required String current}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.86,
      child: _TimeZoneSheet(current: current),
    ),
  );
}

class _TimeZoneSheet extends StatefulWidget {
  const _TimeZoneSheet({required this.current});

  final String current;

  @override
  State<_TimeZoneSheet> createState() => _TimeZoneSheetState();
}

class _TimeZoneSheetState extends State<_TimeZoneSheet> {
  final _query = TextEditingController();
  late final List<String> _zones = timeZoneIds();
  String? _phoneId;

  @override
  void initState() {
    super.initState();
    _query.addListener(() => setState(() {}));
    deviceTimeZoneId().then((id) {
      if (mounted) setState(() => _phoneId = id);
    });
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final needle = _query.text.trim().toLowerCase();
    final zones = [
      for (final id in _zones)
        if (needle.isEmpty ||
            id.toLowerCase().contains(needle) ||
            zoneLabel(id).toLowerCase().contains(needle))
          id,
    ];
    final showAuto =
        needle.isEmpty ||
        l10n.timeZoneAutomatic.toLowerCase().contains(needle) ||
        (_phoneId ?? '').toLowerCase().contains(needle);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.timeZone,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _query,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.timeZoneSearch,
                prefixIcon: const Icon(Icons.search_rounded),
                isDense: true,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                if (showAuto)
                  _ZoneTile(
                    title: l10n.timeZoneAutomatic,
                    detail: _phoneId == null
                        ? null
                        : '${zoneLabel(_phoneId!)} · ${zoneGmt(_phoneId!)}',
                    selected: widget.current == autoTimeZone,
                    onTap: () => Navigator.pop(context, autoTimeZone),
                  ),
                for (final id in zones)
                  _ZoneTile(
                    title: zoneLabel(id),
                    detail: zoneGmt(id),
                    selected: widget.current == id,
                    onTap: () => Navigator.pop(context, id),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoneTile extends StatelessWidget {
  const _ZoneTile({
    required this.title,
    required this.selected,
    required this.onTap,
    this.detail,
  });

  final String title;
  final String? detail;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return ListTile(
      onTap: onTap,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
      subtitle: detail == null ? null : Text(detail!),
      trailing: selected
          ? Icon(CupertinoIcons.check_mark, color: accent, size: 18)
          : null,
    );
  }
}
