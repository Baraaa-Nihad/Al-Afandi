import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/core/utils/style.dart';
import 'package:ovoride/data/controller/driver/dashboard/dashboard_controller.dart';
import 'package:ovoride/data/model/global/ride/ride_model.dart';
import 'package:ovoride/presentation/components/bottom-sheet/bottom_sheet_header_row.dart';
import 'package:ovoride/presentation/components/snack_bar/show_custom_snackbar.dart';
import 'package:ovoride/presentation/components/text/header_text.dart';

class OfferBidBottomSheet extends StatefulWidget {
  final RideModel ride;
  const OfferBidBottomSheet({super.key, required this.ride});

  @override
  State<OfferBidBottomSheet> createState() => _OfferBidBottomSheetState();
}

class _OfferBidBottomSheetState extends State<OfferBidBottomSheet> {
  @override
  void initState() {
    super.initState();
    // تهيئة السعر عند الفتح ليكون سعر الراكب هو نقطة الانطلاق
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<DashBoardController>();

      // الأولوية لسعر الراكب (amount)، ثم سعر النظام (recommendAmount) كخيار بديل
      double initialPrice = double.tryParse(widget.ride.amount.toString()) ?? double.tryParse(widget.ride.recommendAmount.toString()) ?? 0;

      controller.bidAmountController.text = initialPrice.round().toString();
      controller.update();
    });
  }

  static int formatInt(String value, {int defaultValue = 0}) {
    try {
      if (value == "" || value == "null") {
        return defaultValue;
      }
      // نقوم أولاً بالتحويل لـ double ثم لـ int لضمان التعامل مع الأرقام مثل "10.0"
      return double.parse(value).round();
    } catch (e) {
      return defaultValue;
    }
  }

  // دالة زيادة المبلغ بمقدار 5
  void _incrementAmount(DashBoardController controller) {
    int current = int.tryParse(controller.bidAmountController.text) ?? 0;
    int max = formatInt(widget.ride.maxAmount ?? '999999');

    if (current + 5 <= max) {
      int newValue = current + 5;
      controller.bidAmountController.text = newValue.toString();
      controller.update();
    } else {
      CustomSnackBar.error(errorList: ['لا يمكن تجاوز الحد الأقصى وهو $max']);
    }
  }

  // دالة نقصان المبلغ بمقدار 5
  void _decrementAmount(DashBoardController controller) {
    int current = int.tryParse(controller.bidAmountController.text) ?? 0;
    int min = formatInt(widget.ride.minAmount ?? '0');

    if (current - 5 >= min) {
      int newValue = current - 5;
      controller.bidAmountController.text = newValue.toString();
      controller.update();
    } else {
      CustomSnackBar.error(errorList: ['وصلت للحد الأدنى المسموح به وهو $min']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashBoardController>(
      builder: (controller) {
        return Container(
          decoration: const BoxDecoration(
            color: MyColor.colorWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.space20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BottomSheetHeaderRow(),
                  const SizedBox(height: Dimensions.space10),

                  HeaderText(
                    text: "قدّم عرضـك يا افندي",
                    style: boldLarge.copyWith(
                      color: MyColor.getRideTitleColor(),
                      fontSize: Dimensions.fontOverLarge + 2,
                    ),
                  ),
                  const SizedBox(height: Dimensions.space20),

                  _buildInstructionCard(),
                  const SizedBox(height: Dimensions.space15),

                  // عرض سعر الراكب الحالي كمرجع واضح للسائق
                  _buildRiderPriceInfo(controller),

                  const SizedBox(height: Dimensions.space30),

                  // منطقة التحكم بالسعر (Stepper)
                  _buildPriceStepper(controller),

                  const SizedBox(height: Dimensions.space40),

                  // زر التقديم النهائي
                  _buildSubmitButton(controller),

                  const SizedBox(height: Dimensions.space20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // مكوّن: تعليمات الراكب (مع معالجة الـ null)
  Widget _buildInstructionCard() {
    bool hasNote = widget.ride.note != null && widget.ride.note!.toLowerCase() != "null" && widget.ride.note!.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.space15),
      decoration: BoxDecoration(color: MyColor.colorWhite, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(hasNote ? Icons.info_outline_rounded : Icons.notes_rounded, size: 20, color: hasNote ? MyColor.primaryColor : Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${MyStrings.riderInstruction.tr}:", style: boldDefault.copyWith(color: MyColor.getBodyTextColor().withOpacity(0.7), fontSize: 12)),
                const SizedBox(height: 4),
                Text(hasNote ? widget.ride.note! : "لا توجد تعليمات إضافية", style: regularDefault.copyWith(color: hasNote ? MyColor.getBodyTextColor() : Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // مكوّن: عرض سعر الراكب بوضوح
  Widget _buildRiderPriceInfo(DashBoardController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.space12),
      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.withOpacity(0.2))),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: regularDefault.copyWith(color: MyColor.getBodyTextColor(), fontSize: 14),
          children: [
            const TextSpan(text: "عرض الراكب : "),
            TextSpan(
              text: "${controller.currencySym}${widget.ride.amount.toString().split('.').first}",
              style: boldDefault.copyWith(color: Colors.blue.shade800, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // مكوّن: منطقة الـ Stepper لإدخال السعر
  Widget _buildPriceStepper(DashBoardController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(color: MyColor.colorWhite, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _stepperButton("-5", Icons.remove_rounded, () => _decrementAmount(controller), Colors.red),
          Column(
            children: [
              Text(controller.currencySym, style: boldDefault.copyWith(color: MyColor.primaryColor.withOpacity(0.5))),
              IntrinsicWidth(
                child: TextFormField(
                  controller: controller.bidAmountController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: boldExtraLarge.copyWith(fontSize: 55, color: MyColor.primaryColor),
                  decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero),
                ),
              ),
            ],
          ),
          _stepperButton("+5", Icons.add_rounded, () => _incrementAmount(controller), MyColor.primaryColor),
        ],
      ),
    );
  }

  // مكوّن: زر الـ Stepper مع التسمية النصية
  Widget _stepperButton(String label, IconData icon, VoidCallback onTap, Color color) {
    return Column(
      children: [
        Material(
          color: color.withOpacity(0.1),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(width: 60, height: 60, child: Icon(icon, color: color, size: 32)),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: boldDefault.copyWith(color: color, fontSize: 12)),
      ],
    );
  }

  // مكوّن: زر تقديم العرض
  Widget _buildSubmitButton(DashBoardController controller) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () async {
          int enterValue = int.tryParse(controller.bidAmountController.text) ?? 0;
          int min = formatInt(widget.ride.minAmount ?? '0');
          int max = formatInt(widget.ride.maxAmount ?? '0');

          if (enterValue >= min && enterValue <= max) {
            await controller.sendBid(widget.ride.id ?? '-1', amount: enterValue.toString(), onActon: () => Get.back());
          } else {
            CustomSnackBar.error(errorList: ['يجب أن يكون العرض بين ${controller.currencySym}$min و ${controller.currencySym}$max']);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: MyColor.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
        ),
        child: controller.isSendBidLoading ? const CircularProgressIndicator(color: Colors.white) : Text("قدّم عرضك انت ", style: boldLarge.copyWith(color: Colors.white)),
      ),
    );
  }
}
