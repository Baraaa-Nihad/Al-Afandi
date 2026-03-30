import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovoride/core/helper/string_format_helper.dart';
import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/core/helper/shared_preference_helper.dart';
import 'package:ovoride/data/services/api_client.dart';
import 'package:ovoride/data/controller/shared/account/profile_controller.dart';
import 'package:ovoride/data/controller/rider/account/profile_controller.dart'
    as rider_profile_ctrl;
import 'package:ovoride/data/repo/rider/account/profile_repo.dart'
    as rider_profile;
import 'package:ovoride/data/repo/shared/account/profile_repo.dart';
import 'package:ovoride/presentation/components/annotated_region/annotated_region_widget.dart';
import 'package:ovoride/presentation/components/app-bar/custom_appbar.dart';
import 'package:ovoride/presentation/components/custom_loader/custom_loader.dart';
import 'package:ovoride/presentation/components/divider/custom_spacer.dart';

import 'package:ovoride/presentation/components/card/app_body_card.dart';
import 'package:ovoride/presentation/components/image/my_network_image_widget.dart';
import 'widget/card_column.dart';
import 'widget/profile_view_bottom_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    final role =
        Get.find<ApiClient>().sharedPreferences.getString(
          SharedPreferenceHelper.userRoleKey,
        ) ??
        'driver';
    if (role == 'rider') {
      if (!Get.isRegistered<rider_profile_ctrl.ProfileController>(
        tag: 'rider',
      )) {
        Get.put(
          rider_profile_ctrl.ProfileController(
            profileRepo: Get.find<rider_profile.ProfileRepo>(tag: 'rider'),
          ),
          tag: 'rider',
        );
      }
    } else {
      Get.put(ProfileRepo(apiClient: Get.find()));
      Get.put(ProfileController(profileRepo: Get.find()));
    }
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Get.find<ProfileController>().loadProfileInfo();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (controller) {
        return AnnotatedRegionWidget(
          child: Scaffold(
            backgroundColor: MyColor.secondaryScreenBgColor,
            appBar: CustomAppBar(title: MyStrings.profile.tr),
            body: controller.isLoading
                ? const CustomLoader()
                : SingleChildScrollView(
                    padding: Dimensions.screenPaddingHV,
                    physics: const BouncingScrollPhysics(),
                    child: SizedBox(
                      width: double.infinity,
                      // color: Colors.orange,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Details Section
                          Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  top: Dimensions.space50,
                                ),
                                child: AppBodyWidgetCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      spaceDown(Dimensions.space50),
                                      ProfileCardColumn(
                                        header: MyStrings.username.tr
                                            .toUpperCase(),
                                        body:
                                            controller
                                                .model
                                                .data
                                                ?.driver
                                                ?.username ??
                                            "",
                                      ),
                                      spaceDown(Dimensions.space10),
                                      ProfileCardColumn(
                                        header: MyStrings.fullName.tr
                                            .toUpperCase(),
                                        body:
                                            '${controller.model.data?.driver?.firstname ?? ''} ${controller.model.data?.driver?.lastname ?? ''}'
                                                .toTitleCase(),
                                      ),
                                      spaceDown(Dimensions.space10),
                                      ProfileCardColumn(
                                        header: MyStrings.email.tr
                                            .toUpperCase(),
                                        body:
                                            controller.model.data?.driver?.email
                                                ?.toLowerCase() ??
                                            "",
                                      ),
                                      spaceDown(Dimensions.space10),
                                      ProfileCardColumn(
                                        header: MyStrings.phone.tr
                                            .toUpperCase(),
                                        body:
                                            "+${controller.model.data?.driver?.dialCode?.toLowerCase() ?? ""}${controller.model.data?.driver?.mobile?.toLowerCase() ?? ""}",
                                      ),
                                      spaceDown(Dimensions.space10),
                                      ProfileCardColumn(
                                        header: MyStrings.country.tr
                                            .toUpperCase(),
                                        body:
                                            controller
                                                .model
                                                .data
                                                ?.driver
                                                ?.countryName
                                                ?.toTitleCase() ??
                                            "",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                left: 0,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: MyColor.screenBgColor,
                                        width: Dimensions.mediumRadius,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    height: Dimensions.space50 + 60,
                                    width: Dimensions.space50 + 60,
                                    child: ClipOval(
                                      child: MyImageWidget(
                                        imageUrl: controller.imageUrl,
                                        boxFit: BoxFit.cover,
                                        height: Dimensions.space50 + 60,
                                        width: Dimensions.space50 + 60,
                                        isProfile: true,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
            bottomNavigationBar: const ProfileViewBottomNavBar(),
          ),
        );
      },
    );
  }
}
