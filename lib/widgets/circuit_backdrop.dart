import 'package:flutter/material.dart';

class CircuitBackdrop extends StatelessWidget {
  final Widget child;
  const CircuitBackdrop({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: Theme.of(context).scaffoldBackgroundColor, child: child);
  }
}
