import 'package:flutter/material.dart';

class LiteRollingSwitch extends StatefulWidget {
  final bool tValue;
  final double width;
  final String textOff;
  final Color textOffColor;
  final String textOn;
  final Color textOnColor;
  final Color colorOn;
  final Color colorOff;
  final double textSize;
  final Duration animationDuration;
  final IconData iconOn;
  final IconData iconOff;
  final Future<bool> Function(bool newValue)? onToggle;

  const LiteRollingSwitch({
    super.key,
    this.tValue = false,
    this.width = 110, // عرض أنيق ومناسب للـ AppBar بجانب الجرس
    this.textOff = "أوفلاين",
    this.textOn = "أونلاين",
    this.textSize = 12.0, // حجم خط مدروس ليكون واضحاً ومتناسقاً
    this.colorOn = const Color(0xFF00C853), // لون أخضر "أفندي" زاهي للـ Online
    this.colorOff = const Color(0xFF607D8B), // لون رمادي-أزرق هادئ للـ Offline
    this.iconOff = Icons.power_settings_new_rounded,
    this.iconOn = Icons.check_circle_rounded,
    this.animationDuration = const Duration(milliseconds: 250), // حركة أسرع وأنعم (ملاحظة 1)
    this.textOffColor = Colors.white,
    this.textOnColor = Colors.white,
    this.onToggle,
  });

  @override
  State<LiteRollingSwitch> createState() => _LiteRollingSwitchState();
}

class _LiteRollingSwitchState extends State<LiteRollingSwitch> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late bool _isON;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isON = widget.tValue;
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    if (_isON) _controller.value = 1.0;

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack, // تأثير حركة "ارتداد" خفيف لاحترافية أكبر
    );
  }

  @override
  void didUpdateWidget(LiteRollingSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tValue != widget.tValue) {
      _updateState(widget.tValue);
    }
  }

  void _updateState(bool state) {
    if (mounted) {
      setState(() => _isON = state);
      state ? _controller.forward() : _controller.reverse();
    }
  }

  Future<void> _handleToggle() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final bool newValue = !_isON;
    bool success = true;

    if (widget.onToggle != null) {
      success = await widget.onToggle!(newValue);
    }

    if (success) {
      _updateState(newValue);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double padding = 2.5; // تقليل البادينج الداخلي قليلاً لمظهر أرشق
    const double height = 36.0; // ارتفاع أنيق يتماشى مع جرس الإشعارات وصورة الـ Profile
    final double handleSize = height - (padding * 2);
    final double maxMovement = widget.width - handleSize - (padding * 2);

    return GestureDetector(
      onTap: _handleToggle,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          // دمج الألوان بذكاء بناءً على حالة الأنيماشين (ملاحظة 2)
          final Color bgColor = Color.lerp(widget.colorOff, widget.colorOn, _animation.value)!;

          return Container(
            width: widget.width,
            height: height,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(height / 2),
              boxShadow: [
                BoxShadow(
                  color: bgColor.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                // النص العربي الديناميكي - حل عبقري لمشكلة الـ Overflow (ملاحظة 3)
                AnimatedAlign(
                  duration: widget.animationDuration,
                  alignment: _isON ? Alignment.centerLeft : Alignment.centerRight,
                  child: Padding(
                    // ترك مسافة آمنة للأيقونة المنزلقة
                    padding: EdgeInsets.symmetric(horizontal: handleSize + 5),
                    child: FittedBox(
                      // النص سيصغر تلقائياً ولن يكسر التصميم أبداً
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _isON ? widget.textOn : widget.textOff,
                        style: _textStyle(_isON ? widget.textOnColor : widget.textOffColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),

                // الدائرة المتحركة (The Handle)
                Positioned(
                  left: padding + (maxMovement * _animation.value),
                  top: padding,
                  child: Container(
                    width: handleSize,
                    height: handleSize,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1)),
                      ],
                    ),
                    child: _isLoading
                        ? Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: CircularProgressIndicator(strokeWidth: 2, color: bgColor),
                          )
                        : Icon(
                            _isON ? widget.iconOn : widget.iconOff,
                            size: 18,
                            color: bgColor,
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  TextStyle _textStyle(Color color) => TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        fontSize: widget.textSize,
        fontFamily: 'Cairo', // يفضل استخدام خط يدعم العربية بشكل جميل واحترافي
      );
}
