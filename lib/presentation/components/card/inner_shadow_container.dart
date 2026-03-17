import 'dart:ui';
import 'package:flutter/material.dart';

class InnerShadowContainer extends StatelessWidget {
  final double? height;
  final double? width;
  final double borderRadius;
  final Color backgroundColor;

  final bool isShadowTopLeft;
  final bool isShadowTopRight;
  final bool isShadowBottomRight;
  final bool isShadowBottomLeft;

  final double blur;
  final Offset offset;
  final Color shadowColor;

  final Widget? child;
  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry padding; // تم تقليل القيمة الافتراضية لضبط المساحة
  final EdgeInsetsGeometry margin;

  final List<BoxShadow>? outerShadows;
  final Border? border;
  final Gradient? gradient;

  const InnerShadowContainer({
    super.key,
    this.height,
    this.width,
    this.borderRadius = 24,
    this.backgroundColor = Colors.white,
    this.isShadowTopLeft = false,
    this.isShadowTopRight = false,
    this.isShadowBottomRight = false,
    this.isShadowBottomLeft = false,
    this.blur = 4, // تقليل التغبيش لمنع مظهر "الضباب" حول النص
    this.offset = const Offset(1.5, 1.5), // إزاحة دقيقة جداً
    this.shadowColor = const Color(0x12000000),
    this.child,
    this.alignment = Alignment.center,
    this.padding = EdgeInsets.zero, // تغيير القيمة الافتراضية إلى صفر لمنع الـ Overflow
    this.margin = EdgeInsets.zero,
    this.outerShadows,
    this.border,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final hasShadow = isShadowTopLeft || isShadowTopRight || isShadowBottomRight || isShadowBottomLeft;

    return Container(
      height: height,
      width: width,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: outerShadows ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          fit: StackFit.loose, // يضمن أن المحتوى يملأ الحاوية بالكامل
          // fit: StackFit.expand, // يضمن أن المحتوى يملأ الحاوية بالكامل
          children: [
            // الطبقة الأساسية (الخلفية والحدود)
            Container(
              alignment: alignment,
              decoration: BoxDecoration(
                color: gradient == null ? backgroundColor : null,
                gradient: gradient,
                borderRadius: BorderRadius.circular(borderRadius),
                border: border ??
                    Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
              ),
              child: Padding(
                padding: padding,
                child: child,
              ),
            ),

            if (hasShadow)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: InnerShadowPainter(
                      shadowColor: shadowColor,
                      blur: blur,
                      offset: offset,
                      borderRadius: borderRadius,
                      isShadowTopLeft: isShadowTopLeft,
                      isShadowTopRight: isShadowTopRight,
                      isShadowBottomRight: isShadowBottomRight,
                      isShadowBottomLeft: isShadowBottomLeft,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class InnerShadowPainter extends CustomPainter {
  final Color shadowColor;
  final double blur;
  final Offset offset;
  final double borderRadius;
  final bool isShadowTopLeft;
  final bool isShadowTopRight;
  final bool isShadowBottomRight;
  final bool isShadowBottomLeft;

  InnerShadowPainter({
    required this.shadowColor,
    required this.blur,
    required this.offset,
    required this.borderRadius,
    this.isShadowTopLeft = false,
    this.isShadowTopRight = false,
    this.isShadowBottomRight = false,
    this.isShadowBottomLeft = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

    final path = Path()..addRRect(rrect);

    canvas.save();
    canvas.clipRRect(rrect);

    void drawShadow(double dx, double dy) {
      final shadowPath = Path.combine(
        PathOperation.difference,
        Path()..addRect(rect.inflate(blur * 3)), // زيادة مساحة التمدد للنعومة
        path.shift(Offset(dx, dy)),
      );
      canvas.drawPath(shadowPath, shadowPaint);
    }

    if (isShadowTopLeft) drawShadow(offset.dx, offset.dy);
    if (isShadowBottomRight) drawShadow(-offset.dx, -offset.dy);
    if (isShadowTopRight) drawShadow(-offset.dx, offset.dy);
    if (isShadowBottomLeft) drawShadow(offset.dx, -offset.dy);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant InnerShadowPainter oldDelegate) => false;
}
