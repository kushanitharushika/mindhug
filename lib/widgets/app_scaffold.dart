import 'package:flutter/material.dart';
import 'mindhug_logo.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.child,
    this.showLogo = true,
    this.padding,
  });

  final Widget child;
  final bool showLogo;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: const SizedBox.shrink(),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [const Color(0xFF121212), Colors.black],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.purple.shade50, Colors.white],
                ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: padding ?? const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showLogo) ...[
                  const MindHugLogo(size: 56),
                  const SizedBox(height: 6),
                ],
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
