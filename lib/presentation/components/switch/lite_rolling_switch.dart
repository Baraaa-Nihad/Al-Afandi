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
    this.width = 130,
    this.textOff = "Offline",
    this.textOn = "Online",
    this.textSize = 14.0,
    this.colorOn = Colors.green,
    this.colorOff = Colors.red,
    this.iconOff = Icons.signal_wifi_off,
    this.iconOn = Icons.network_check,
    this.animationDuration = const Duration(milliseconds: 300),
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
      curve: Curves.easeInOut,
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
    setState(() => _isON = state);
    state ? _controller.forward() : _controller.reverse();
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
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // حسابات دقيقة لمنع خروج الأيقونة
    const double padding = 4.0;
    const double height = 45.0; // ارتفاع ثابت واحترافي
    final double handleSize = height - (padding * 2);
    final double maxMovement = widget.width - handleSize - (padding * 2);

    return GestureDetector(
      onTap: _handleToggle,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final Color bgColor = Color.lerp(widget.colorOff, widget.colorOn, _animation.value)!;

          return Container(
            width: widget.width,
            height: height,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(height / 2),
              boxShadow: [
                BoxShadow(
                  color: bgColor.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // نصوص الحالة
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Opacity(
                        opacity: _animation.value.clamp(0.0, 1.0),
                        child: Text(widget.textOn, style: _textStyle(widget.textOnColor)),
                      ),
                      Opacity(
                        opacity: (1 - _animation.value).clamp(0.0, 1.0),
                        child: Text(widget.textOff, style: _textStyle(widget.textOffColor)),
                      ),
                    ],
                  ),
                ),

                // زر التحكم (Handle)
                Positioned(
                  left: padding + (maxMovement * _animation.value),
                  child: Container(
                    width: handleSize,
                    height: handleSize,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1),
                      ],
                    ),
                    child: _isLoading
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(strokeWidth: 2, color: bgColor),
                          )
                        : Stack(
                            alignment: Alignment.center,
                            children: [
                              Opacity(
                                opacity: (1 - _animation.value).clamp(0.0, 1.0),
                                child: Icon(widget.iconOff, size: 20, color: widget.colorOff),
                              ),
                              Opacity(
                                opacity: _animation.value.clamp(0.0, 1.0),
                                child: Icon(widget.iconOn, size: 20, color: widget.colorOn),
                              ),
                            ],
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
      );
}
