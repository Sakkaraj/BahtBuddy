import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/format.dart';

class BbScaffold extends StatelessWidget {
  const BbScaffold({
    super.key,
    required this.title,
    required this.slivers,
    this.trailing,
    this.leading,
  });

  final String title;
  final List<Widget> slivers;
  final Widget? trailing;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return BuddyBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              largeTitle: Text(title),
              leading: leading,
              trailing: trailing,
              border: null,
              backgroundColor: Colors.transparent,
              automaticBackgroundVisibility: false,
            ),
            ...slivers,
          ],
        ),
      ),
    );
  }
}

class BbAddButton extends StatelessWidget {
  const BbAddButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: const Icon(CupertinoIcons.add, size: 28),
    );
  }
}
