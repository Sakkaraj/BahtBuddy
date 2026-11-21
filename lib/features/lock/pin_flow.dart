import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/pin_hash.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/pin_pad.dart';

enum PinFlowKind { set, change, remove }

class PinFlow {
  static Future<String?> push(
    BuildContext context, {
    required PinFlowKind kind,
    String? currentHash,
  }) {
    return Navigator.of(context).push<String>(
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (context) => PinFlowPage(
          kind: kind,
          currentHash: currentHash,
        ),
      ),
    );
  }
}

enum _Step { current, create, confirm }

class PinFlowPage extends StatefulWidget {
  const PinFlowPage({super.key, required this.kind, this.currentHash});

  final PinFlowKind kind;
  final String? currentHash;

  @override
  State<PinFlowPage> createState() => _PinFlowPageState();
}

class _PinFlowPageState extends State<PinFlowPage> {
  late _Step _step;
  String? _created;
  String? _error;

  @override
  void initState() {
    super.initState();
    _step = widget.kind == PinFlowKind.set ? _Step.create : _Step.current;
  }

  String _title(AppLocalizations l10n) {
    return switch (_step) {
      _Step.current => l10n.enterCurrentPin,
      _Step.create => l10n.createPin,
      _Step.confirm => l10n.confirmNewPin,
    };
  }

  Future<bool> _onCompleted(String pin) async {
    final l10n = AppLocalizations.of(context);
    switch (_step) {
      case _Step.current:
        if (widget.currentHash == null ||
            hashPin(pin) != widget.currentHash) {
          setState(() => _error = l10n.wrongPin);
          return false;
        }
        if (widget.kind == PinFlowKind.remove) {
          Navigator.of(context).pop(pin);
          return true;
        }
        setState(() {
          _error = null;
          _step = _Step.create;
        });
        return true;
      case _Step.create:
        setState(() {
          _created = pin;
          _error = null;
          _step = _Step.confirm;
        });
        return true;
      case _Step.confirm:
        if (pin != _created) {
          setState(() {
            _error = l10n.pinMismatchTryAgain;
            _created = null;
            _step = _Step.create;
          });
          return false;
        }
        Navigator.of(context).pop(pin);
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: groupedBackground(context),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 88,
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
      ),
      body: PinPad(
        key: ValueKey(_step),
        title: _title(l10n),
        errorText: _error,
        onInput: () {
          if (_error != null) setState(() => _error = null);
        },
        onCompleted: _onCompleted,
      ),
    );
  }
}
