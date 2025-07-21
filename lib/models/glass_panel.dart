import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double topLeft;
  final double topRight;
  final double botLeft;
  final double botRight;
  final double fromGradient;
  final double toGradient;
  final double borderSize;
  final Color color;
  final Color color2;
  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 30.0,
    this.fromGradient = 0.3,
    this.toGradient = 0.15,
    this.borderSize = 0.3,
    this.color = Colors.white,
    Color? color2,
    double? topLeft,
    double? topRight,
    double? botLeft,
    double? botRight,
  }) : color2 = color2 ?? color,
       topLeft = topLeft ?? borderRadius,
       topRight = topRight ?? borderRadius,
       botLeft = botLeft ?? borderRadius,
       botRight = botRight ?? borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(topLeft),
        topRight: Radius.circular(topRight),
        bottomLeft: Radius.circular(botLeft),
        bottomRight: Radius.circular(botRight),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(fromGradient),
                color2.withOpacity(toGradient),
              ],
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(topLeft),
              topRight: Radius.circular(topRight),
              bottomLeft: Radius.circular(botLeft),
              bottomRight: Radius.circular(botRight),
            ),
            border: Border.all(color: Colors.white.withOpacity(borderSize)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
