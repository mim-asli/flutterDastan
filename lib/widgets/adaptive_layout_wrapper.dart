import 'package:flutter/material.dart';

/// A utility widget that provides responsive layout capabilities.
/// It builds different widgets based on the screen width.
class AdaptiveLayoutWrapper extends StatelessWidget {
  final Widget Function(
          BuildContext context, bool isMobile, bool isTablet, bool isDesktop)
      builder;

  const AdaptiveLayoutWrapper({super.key, required this.builder});

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1000;
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1000;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final mobile = width < 600;
        final tablet = width >= 600 && width < 1000;
        final desktop = width >= 1000;

        return builder(context, mobile, tablet, desktop);
      },
    );
  }
}
