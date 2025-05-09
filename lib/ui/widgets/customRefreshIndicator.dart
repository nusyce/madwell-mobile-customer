import 'package:madwell/app/generalImports.dart';
import 'package:flutter/material.dart';

class CustomRefreshIndicator extends StatelessWidget {
  const CustomRefreshIndicator({
    required this.onRefreshCallback,
    required this.child,
    required this.displacment,
    final Key? key,
  }) : super(key: key);
  final Widget child;
  final Function onRefreshCallback;
  final double displacment;

  @override
  Widget build(final BuildContext context) => RefreshIndicator(
        displacement: displacment,
        color: context.colorScheme.accentColor,
        onRefresh: () async {
          onRefreshCallback();
        },
        child: child,
      );
}
