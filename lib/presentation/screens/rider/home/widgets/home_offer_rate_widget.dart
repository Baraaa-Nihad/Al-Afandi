import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/core/utils/style.dart';
import 'package:ovoride/data/controller/rider/home/home_controller.dart';
import 'package:ovoride/presentation/components/bottom-sheet/my_bottom_sheet_bar.dart';
import 'package:ovoride/presentation/components/snack_bar/show_custom_snackbar.dart';
import 'package:ovoride/presentation/components/buttons/rounded_button.dart';
import 'package:ovoride/presentation/components/divider/custom_spacer.dart';
import 'package:ovoride/presentation/components/text/header_text.dart';

class HomeOfferRateWidget extends StatefulWidget {
  const HomeOfferRateWidget({super.key});

  @override
  State<HomeOfferRateWidget> createState() => _HomeOfferRateWidgetState();
}

class _HomeOfferRateWidgetState extends State<HomeOfferRateWidget> {
  @override
  void initState() {
    super.initState();
    // تعيين السعر المقترح كقيمة افتراضية عند فتح الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<HomeController>();
      double recAmount = double.tryParse(controller.selectedService.recommendAmount.toString()) ?? 0.0;
      controller.amountController.text = recAmount.toStringAsFixed(1);
      setState(() {});
    });
  }

  // دالة قوية لتحديث السعر تضمن التغيير في كل ضغطة
  void _modifyPrice(double amountToAdd, HomeController controller, {bool isSetExplicit = false}) {
    // 1. قراءة القيمة الحالية من الحقل وتحويلها لرقم
    double current = double.tryParse(controller.amountController.text) ?? 0.0;

    // 2. الحساب (إما إضافة أو وضع قيمة ثابتة)
    double newValue = isSetExplicit ? amountToAdd : (current + amountToAdd);

    // 3. التحقق من الحدود (Min/Max)
    double min = double.tryParse(controller.selectedService.minAmount ?? '0') ?? 0;
    double max = double.tryParse(controller.selectedService.maxAmount ?? '999999') ?? 999999;

    if (newValue < min) newValue = min;
    if (newValue > max) newValue = max;

    // 4. التحديث الفعلي للحقل (هذا ما سيراه المستخدم)
    controller.amountController.text = newValue.toStringAsFixed(1);

    // 5. إجبار الواجهة على إعادة البناء
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        // نأخذ القيمة من الـ Controller مباشرة في كل عملية Build
        double currentDisplayAmount = double.tryParse(controller.amountController.text) ?? 0.0;
        double recAmount = double.tryParse(controller.selectedService.recommendAmount.toString()) ?? 0.0;
        double minAmount = double.tryParse(controller.selectedService.minAmount ?? '0') ?? 0.0;
        double maxAmount = double.tryParse(controller.selectedService.maxAmount ?? '0') ?? 0.0;
        String currency = controller.defaultCurrencySymbol;

        return Container(
          decoration: const BoxDecoration(
            color: MyColor.colorWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.space20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const MyBottomSheetBar(),

              // --- زاوية الحدود (Min/Max) بتصميم جميل ---
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLimitBadge("الأدنى", "$currency$minAmount", Colors.blue),
                    _buildLimitBadge("الأقصى", "$currency$maxAmount", Colors.red),
                  ],
                ),
              ),

              spaceDown(Dimensions.space10),
              HeaderText(
                text: MyStrings.offerYourRate.tr,
                style: boldExtraLarge.copyWith(fontSize: 22, color: MyColor.getRideTitleColor()),
              ),
              spaceDown(Dimensions.space15),

              // السعر المقترح
              _buildRecommendedBox(controller, currency, recAmount),

              spaceDown(Dimensions.space30),

              // --- منطقة التحكم الرئيسية ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCircleControl(Icons.remove, () => _modifyPrice(-1, controller)),
                  Column(
                    children: [
                      Text(
                        "$currency${currentDisplayAmount.toStringAsFixed(1)}",
                        style: boldExtraLarge.copyWith(fontSize: 45, color: MyColor.primaryColor, letterSpacing: -1),
                      ),
                      Text("سعرك الحالي", style: regularSmall.copyWith(color: Colors.grey)),
                    ],
                  ),
                  _buildCircleControl(Icons.add, () => _modifyPrice(1, controller)),
                ],
              ),

              spaceDown(Dimensions.space30),

              // --- كبسولات الإضافة التراكمية (تزيد في كل ضغطة) ---
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildAddButton("+5", 5, controller),
                    _buildAddButton("+10", 10, controller),
                    _buildAddButton("+20", 20, controller),

                    // فاصل
                    Container(margin: const EdgeInsets.symmetric(horizontal: 10), height: 20, width: 1, color: Colors.grey.shade300),

                    // زر جبر الكسور
                    _buildSpecialAction("جبر الكسور", Icons.auto_fix_high, () {
                      _modifyPrice(currentDisplayAmount.ceilToDouble(), controller, isSetExplicit: true);
                    }, (currentDisplayAmount % 1 != 0)),

                    // زر العودة للمقترح
                    _buildSpecialAction("المقترح", Icons.history, () {
                      _modifyPrice(recAmount, controller, isSetExplicit: true);
                    }, true),
                  ],
                ),
              ),

              spaceDown(Dimensions.space40),

              RoundedButton(
                text: MyStrings.done.tr.toUpperCase(),
                press: () {
                  if (currentDisplayAmount >= minAmount && currentDisplayAmount <= (maxAmount + 0.5)) {
                    controller.updateMainAmount(currentDisplayAmount);
                    Get.back();
                  } else {
                    CustomSnackBar.error(errorList: ['السعر خارج النطاق المسموح']);
                  }
                },
              ),
              spaceDown(Dimensions.space25),
            ],
          ),
        );
      },
    );
  }

  // ويدجت زر الإضافة (يضيف في كل ضغطة)
  Widget _buildAddButton(String label, double val, HomeController controller) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => _modifyPrice(val, controller),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: MyColor.primaryColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: MyColor.primaryColor.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Text(label, style: boldDefault.copyWith(color: Colors.white)),
        ),
      ),
    );
  }

  // شارة الحدود (Min/Max)
  Widget _buildLimitBadge(String title, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          CircleAvatar(radius: 3, backgroundColor: color),
          const SizedBox(width: 5),
          Text("$title: ", style: regularSmall.copyWith(fontSize: 11)),
          Text(val, style: boldDefault.copyWith(fontSize: 11, color: color)),
        ],
      ),
    );
  }

  // صندوق السعر المقترح
  Widget _buildRecommendedBox(HomeController controller, String currency, double recAmount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Text(
        // نقوم بعمل الترجمة أولاً، ثم استبدال القيم يدوياً لضمان الظهور
        MyStrings.recommendedPrice.tr.replaceAll('{priceKey}', "$currency${recAmount.toStringAsFixed(1)}").replaceAll('{distanceKey}', "${controller.distance.toPrecision(2)} كم"),
        style: mediumDefault.copyWith(color: Colors.grey.shade700),
        textAlign: TextAlign.center,
      ),
    );
  }

  // أزرار العمليات الخاصة
  Widget _buildSpecialAction(String label, IconData icon, VoidCallback onTap, bool active) {
    return Opacity(
      opacity: active ? 1.0 : 0.4,
      child: ActionChip(
        onPressed: active ? onTap : null,
        label: Text(label, style: mediumSmall.copyWith(fontSize: 11)),
        avatar: Icon(icon, size: 14),
        backgroundColor: Colors.amber.shade50,
        shape: StadiumBorder(side: BorderSide(color: Colors.amber.shade200)),
      ),
    );
  }

  Widget _buildCircleControl(IconData icon, VoidCallback onTap) {
    return IconButton.filled(
      onPressed: onTap,
      icon: Icon(icon, size: 24),
      style: IconButton.styleFrom(
        backgroundColor: MyColor.primaryColor.withOpacity(0.1),
        foregroundColor: MyColor.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.all(12),
      ),
    );
  }
}
