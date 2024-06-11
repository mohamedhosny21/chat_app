import 'package:flutter/material.dart';

class VerticalSwipeBackNavigator extends StatelessWidget {
  final Widget child;
  const VerticalSwipeBackNavigator({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.vertical,
      child: child,
      onDismissed: (direction) {
        Navigator.pop(context);
      },
    );
  }
}
