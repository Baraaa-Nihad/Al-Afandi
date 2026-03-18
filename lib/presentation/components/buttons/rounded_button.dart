import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/style.dart';

class RoundedButton extends StatefulWidget {
  final bool isColorChange;
  final String text;
  final VoidCallback press;
  final Color? bgColor;
  final Color? textColor;
  final double width;
  final double height;
  final double cornerRadius;
  final bool isOutlined;
  final Widget? child;
  final TextStyle? textStyle;
  final bool isLoading;
  final Color borderColor;
  final bool isDisabled;

  const RoundedButton({
    super.key,
    this.isColorChange = false,
    this.width = 1,
    this.child,
    this.cornerRadius = 14,
    this.height = 56,
    required this.text,
    required this.press,
    this.isOutlined = false,
    this.bgColor,
    this.textColor,
    this.textStyle,
    this.isLoading = false,
    this.borderColor = MyColor.primaryButtonColor,
    this.isDisabled = false,
  });

  @override
  State<RoundedButton> createState() => _RoundedButtonState();
}

class _RoundedButtonState extends State<RoundedButton> {
  bool _isPressed = false;

  void _onPointerDown(PointerDownEvent event) {
    if (widget.isDisabled || widget.isLoading) return;
    setState(() => _isPressed = true);
  }

  void _onPointerUp(PointerUpEvent event) {
    if (widget.isDisabled || widget.isLoading) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final double buttonScale = _isPressed ? 0.95 : 1.0;
    final double buttonOpacity = widget.isDisabled ? 0.6 : 1.0;

    // دالة ذكية لتحديد لون المحتوى (نص أو مؤشر تحميل) لضمان التباين
    Color getContentColor() {
      if (widget.isOutlined) {
        // إذا كان مفرغاً: الأولوية لـ textColor الممرر، ثم bgColor، ثم اللون الأساسي للتطبيق
        return widget.textColor ?? widget.bgColor ?? MyColor.primaryButtonColor;
      } else {
        // إذا كان ملوناً بالكامل: الأولوية لـ textColor الممرر، وإلا فالأبيض الصريح
        return widget.textColor ?? MyColor.colorWhite;
      }
    }

    final Color contentColor = getContentColor();

    final effectiveTextStyle = widget.textStyle ??
        regularDefault.copyWith(
          color: contentColor,
          fontSize: 16,
          fontWeight: FontWeight.w600, // زيادة السماكة قليلاً للوضوح
          letterSpacing: 1.1,
        );

    Widget buttonContent = widget.isLoading
        ? SpinKitFadingCircle(
            color: contentColor,
            size: 25.0,
          )
        : widget.child ?? Text(widget.text.tr, style: effectiveTextStyle);

    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      child: AnimatedScale(
        scale: buttonScale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: buttonOpacity,
          duration: const Duration(milliseconds: 150),
          child: widget.isOutlined ? buildOutLineButtonStyleWidget(buttonContent) : buildButtonStyleWidget(buttonContent),
        ),
      ),
    );
  }

  // تصميم الزر الملون (الأساسي)
  Widget buildButtonStyleWidget(Widget buttonContent) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.cornerRadius),
        border: Border.all(
          color: (widget.bgColor ?? MyColor.primaryButtonColor).withValues(alpha: 0.5),
          width: 1.5,
        ),
        color: (widget.bgColor ?? MyColor.primaryButtonColor),
      ),
      child: Stack(
        children: [
          // إضافة تأثيرات التدرج (Gradients) كما في الكود الأصلي
          _buildGradientLayer(Alignment(0.0, -1.0), Alignment(0.0, -0.7)),
          _buildGradientLayer(Alignment(1.0, 0.0), Alignment(0.97, 0.0)),
          _buildGradientLayer(Alignment(-1.0, 0.0), Alignment(-0.97, 0.0)),

          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(widget.cornerRadius),
              onTap: widget.press,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: buttonContent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // تصميم الزر المفرغ (Outlined)
  Widget buildOutLineButtonStyleWidget(Widget buttonContent) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.cornerRadius),
        border: Border.all(
          color: widget.borderColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        color: (widget.bgColor ?? MyColor.colorWhite), // خلفية بيضاء افتراضياً للـ Outlined
        boxShadow: [
          BoxShadow(
            color: MyColor.colorBlack.withValues(alpha: 0.02),
            offset: const Offset(0, 3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(widget.cornerRadius),
          onTap: widget.press,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: buttonContent,
            ),
          ),
        ),
      ),
    );
  }

  // دالة مساعدة لبناء طبقات التدرج
  Widget _buildGradientLayer(Alignment begin, Alignment end) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.cornerRadius),
          gradient: LinearGradient(
            colors: [
              MyColor.secondaryButtonColor.withValues(alpha: 0.2),
              const Color.fromRGBO(255, 255, 255, 0.0),
            ],
            begin: begin,
            end: end,
          ),
        ),
      ),
    );
  }
}
