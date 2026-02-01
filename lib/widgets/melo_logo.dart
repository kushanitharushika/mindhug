import 'package:flutter/material.dart';

class MeloLogo extends StatefulWidget {
  final double size;
  final bool showText;

  const MeloLogo({super.key, this.size = 56, this.showText = false});

  @override
  State<MeloLogo> createState() => _MeloLogoState();
}

class _MeloLogoState extends State<MeloLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.size;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: Tween(
            begin: 0.96,
            end: 1.04,
          ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut)),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade600, Colors.pink.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.22),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: size * 0.18,
                  child: Icon(
                    Icons.chat_bubble_rounded,
                    color: Colors.white.withOpacity(0.12),
                    size: size * 0.9,
                  ),
                ),
                Icon(Icons.favorite, color: Colors.white, size: size * 0.5),
              ],
            ),
          ),
        ),
        if (widget.showText) ...[
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.purple, Colors.pink],
                ).createShader(bounds),
                child: const Text(
                  'Melo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Here to listen',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.grey[400] 
                      : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
