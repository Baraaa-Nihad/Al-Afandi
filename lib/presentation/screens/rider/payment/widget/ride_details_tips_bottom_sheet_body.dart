import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ovoride/core/utils/my_icons.dart';
import 'package:ovoride/data/controller/rider/ride/ride_details/ride_details_controller.dart';
import 'package:ovoride/presentation/components/buttons/rounded_button.dart';
import 'package:ovoride/presentation/components/card/custom_app_card.dart';
import 'package:ovoride/presentation/components/image/custom_svg_picture.dart';
import 'package:ovoride/presentation/components/text-form-field/custom_text_field.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/core/utils/style.dart';
import 'package:ovoride/presentation/components/bottom-sheet/bottom_sheet_header_row.dart';
import 'package:ovoride/presentation/components/divider/custom_spacer.dart';

class RideDetailsTipsBottomSheet extends StatelessWidget {
  const RideDetailsTipsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideDetailsController>(
      tag: 'rider',
      builder: (controller) {
        return Container(
          height: context.height * .4,
          color: MyColor.colorWhite,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const BottomSheetHeaderRow(),
              spaceDown(Dimensions.space20),
              Flexible(
                child: ListView(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        spacing: 15,
                        children: List.generate(
                          controller.tipsList.length,
                          (index) => ZoomTapAnimation(
                            onTap: () {
                              controller.updateTips(controller.tipsList[index]);
                            },
                            child: CustomAppCard(
                              backgroundColor: MyColor.appBarColor.withValues(alpha: 0.1),
                              radius: Dimensions.largeRadius,
                              child: Text(
                                "${controller.currencySym}${controller.tipsList[index]}",
                                style: regularDefault.copyWith(
                                  color: MyColor.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    spaceDown(Dimensions.space30),
                    CustomTextField(
                      controller: controller.tipsController,
                      hintText: MyStrings.tipsAmount.tr,
                      onChanged: (value) {},
                      textInputType: TextInputType.numberWithOptions(
                        decimal: false,
                        signed: false,
                      ),
                      inputAction: TextInputAction.done,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(6),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: CustomSvgPicture(
                          image: MyIcons.coin,
                          color: MyColor.primaryColor,
                        ),
                      ),
                      validator: (value) {
                        return;
                      },
                    ),
                    spaceDown(Dimensions.space30),
                    RoundedButton(
                      text: MyStrings.continue_.tr,
                      press: () {
                        Get.back();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
