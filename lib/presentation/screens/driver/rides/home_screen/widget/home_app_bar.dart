import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovoride/core/helper/string_format_helper.dart';
import 'package:ovoride/core/route/route.dart';
import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_icons.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/core/utils/style.dart';
import 'package:ovoride/core/utils/url_container.dart';
import 'package:ovoride/data/controller/driver/dashboard/dashboard_controller.dart';
import 'package:ovoride/presentation/components/divider/custom_spacer.dart';
import 'package:ovoride/presentation/components/image/custom_svg_picture.dart';
import 'package:ovoride/presentation/components/image/my_network_image_widget.dart';
import 'package:ovoride/presentation/components/switch/lite_rolling_switch.dart';
import 'package:ovoride/presentation/components/text/header_text.dart';

class HomeScreenAppBar extends StatelessWidget {
  final DashBoardController controller; // أضفت final للممارسة البرمجية الصحيحة
  const HomeScreenAppBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.space16,
          vertical: Dimensions.space12, // تقليل الـ vertical قليلاً لرشاقة التصميم
        ),
        decoration: BoxDecoration(
          color: MyColor.getCardBgColor(), // اختيار لون خلفية متناسق
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 1. قسم بيانات السائق (صورة + اسم + موقع)
            Expanded(
              child: Row(
                children: [
                  // صورة البروفايل
                  GestureDetector(
                    onTap: () => Get.toNamed(RouteHelper.profileScreen),
                    child: MyImageWidget(
                      imageUrl: '${UrlContainer.domainUrl}/${controller.userImagePath}/${controller.driver.image}',
                      height: 45,
                      width: 45,
                      radius: 45,
                      isProfile: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // النصوص (الاسم والموقع)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          controller.driver.id == '-1' ? controller.repo.apiClient.getUserName().toTitleCase() : controller.driver.getFullName(),
                          style: boldLarge.copyWith(
                            color: MyColor.getTextColor(),
                            fontSize: Dimensions.fontLarge,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            CustomSvgPicture(
                              image: MyIcons.currentLocation,
                              color: MyColor.primaryColor,
                              height: 14,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                controller.currentAddress,
                                style: regularDefault.copyWith(
                                  color: MyColor.getBodyTextColor(),
                                  fontSize: Dimensions.fontSmall,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. فاصل مرن لضمان عدم التلامس
            const SizedBox(width: 12),

            // 3. قسم السويتش (أونلاين / أوفلاين)
            // تحديد SizedBox ثابت هنا هو السر في منع الـ Overflow
            SizedBox(
              width: 115,
              height: 42,
              child: LiteRollingSwitch(
                tValue: controller.userOnline,
                width: 115,
                textOn: MyStrings.onLine.tr,
                textOff: MyStrings.offLine.tr,
                textOnColor: MyColor.colorWhite,
                colorOn: MyColor.colorGreen,
                colorOff: MyColor.colorGrey,
                iconOn: Icons.network_check,
                iconOff: Icons.signal_wifi_off,
                animationDuration: const Duration(milliseconds: 300),
                onToggle: (newValue) async {
                  try {
                    await controller.changeOnlineStatus(newValue);
                    return true;
                  } catch (e) {
                    return false;
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
