import 'package:flutter/material.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_images.dart';

class AuthBackgroundWidget extends StatelessWidget {
  final List<Color>? colors;
  final Widget child;

  const AuthBackgroundWidget({
    super.key,
    this.colors,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(MyImages.backgroundImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: colors ??
                [
                  MyColor.primaryColor.withValues(alpha: 0.95),
                  MyColor.primaryColor.withValues(alpha: 0.85),
                  MyColor.primaryColor.withValues(alpha: 0.80),
                ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: child,
        ),
      ),
    );
  }
}
