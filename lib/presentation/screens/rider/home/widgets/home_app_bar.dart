import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ovoride/core/route/route.dart';
import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_icons.dart';
import 'package:ovoride/core/utils/style.dart';
import 'package:ovoride/core/utils/url_container.dart';
import 'package:ovoride/data/controller/rider/home/home_controller.dart';
import 'package:ovoride/data/services/notification_controller.dart';
import 'package:ovoride/presentation/components/divider/custom_spacer.dart';
import 'package:ovoride/presentation/components/image/custom_svg_picture.dart';
import 'package:ovoride/presentation/components/image/my_network_image_widget.dart';
import 'package:ovoride/presentation/components/text/header_text.dart';

class RiderHomeScreenAppBar extends StatelessWidget {
  final HomeController controller; // إضافة final للممارسات الجيدة
  final Function openDrawer;

  const RiderHomeScreenAppBar({
    super.key,
    required this.controller,
    required this.openDrawer,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.space16, vertical: Dimensions.space16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.toNamed(RouteHelper.riderProfileScreen),
                        child: MyImageWidget(
                          imageUrl: controller.user.image != null ? '${UrlContainer.domainUrl}/${controller.userImagePath}/${controller.user.image}' : '', // سيقوم MyImageWidget بعرض صورة افتراضية في هذه الحالة
                          height: 50,
                          width: 50,
                          radius: 50,
                          isProfile: true,
                        ),
                      ),
                      spaceSide(Dimensions.space10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: HeaderText(
                                text: (controller.user.id == '-1' || controller.user.id == null) ? "الأفندي" : controller.user.getFullName(),
                                style: boldLarge.copyWith(
                                  color: MyColor.getTextColor(),
                                  fontSize: Dimensions.fontLarge,
                                ),
                              ),
                            ),
                            spaceDown(Dimensions.space3),
                            Row(
                              children: [
                                CustomSvgPicture(
                                  image: MyIcons.currentLocation,
                                  color: MyColor.primaryColor,
                                ),
                                spaceSide(Dimensions.space5),
                                Expanded(
                                  child: Text(
                                    controller.appLocationController.currentAddress,
                                    style: regularDefault.copyWith(
                                      color: MyColor.getBodyTextColor(),
                                      fontSize: Dimensions.fontDefault,
                                      fontWeight: FontWeight.w400,
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

                // --- الجزء المضاف: أيقونة الإشعارات الذكية ---
                GetBuilder<NotificationController>(builder: (notificationController) {
                  return InkWell(
                    onTap: () => Get.toNamed(RouteHelper.notificationScreen),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: MyColor.cardBgColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: MyColor.naturalTextColor.withOpacity(0.2)),
                          ),
                          child: Icon(
                            Icons.notifications_none_rounded,
                            color: MyColor.primaryColor,
                            size: 24,
                          ),
                        ),
                        if (notificationController.unreadCount > 0)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                              child: Text(
                                '${notificationController.unreadCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
                // ------------------------------------------

                spaceSide(Dimensions.space10),

                InkWell(
                  onTap: () => openDrawer(),
                  splashFactory: NoSplash.splashFactory,
                  splashColor: MyColor.transparentColor,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: MyColor.cardBgColor,
                      border: Border.all(color: MyColor.naturalTextColor),
                      borderRadius: BorderRadius.circular(Dimensions.largeRadius),
                    ),
                    child: SvgPicture.asset(MyIcons.sideMenu),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
