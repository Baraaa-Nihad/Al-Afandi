import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovoride/core/route/route.dart';
import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/core/utils/style.dart';
import 'package:ovoride/data/controller/rider/auth/registration_controller.dart';
import 'package:ovoride/data/repo/shared/auth/general_setting_repo.dart';
import 'package:ovoride/data/repo/rider/auth/signup_repo.dart';
import 'package:ovoride/presentation/components/annotated_region/annotated_region_widget.dart';
import 'package:ovoride/presentation/components/custom_no_data_found_class.dart';
import 'package:ovoride/presentation/components/will_pop_widget.dart';
import 'package:ovoride/presentation/screens/shared/auth/auth_background.dart';
import 'package:ovoride/presentation/screens/rider/auth/registration/widget/registration_form.dart';
import 'package:ovoride/presentation/screens/shared/auth/social_auth/social_auth_section.dart';

import 'package:ovoride/presentation/components/divider/custom_spacer.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final formKey = GlobalKey<FormState>();
  @override
  void initState() {
    Get.put(GeneralSettingRepo(apiClient: Get.find()));
    Get.put(RegistrationRepo(apiClient: Get.find()), tag: 'rider');
    Get.put(
      RegistrationController(
        registrationRepo: Get.find(tag: 'rider'),
        generalSettingRepo: Get.find(),
      ),
      tag: 'rider',
    );

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<RegistrationController>(tag: 'rider').initData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopWidget(
      nextRoute: RouteHelper.riderLoginScreen,
      child: AnnotatedRegionWidget(
        statusBarColor: Colors.transparent,
        child: GetBuilder<RegistrationController>(
          tag: 'rider',
          builder: (controller) => Scaffold(
            backgroundColor: MyColor.colorWhite,
            body: controller.noInternet
                ? NoDataOrInternetScreen(
                    isNoInternet: true,
                    onChanged: () {
                      controller.initData();
                    },
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AuthBackgroundWidget(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    end: Dimensions.space5,
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      Get.offAllNamed(
                                        RouteHelper.riderLoginScreen,
                                      );
                                    },
                                    icon: Icon(
                                      Icons.close,
                                      size: Dimensions.space30,
                                      color: MyColor.colorWhite,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: Dimensions.space20,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      MyStrings.regRiderScreenTitle.tr,
                                      style: boldExtraLarge.copyWith(
                                        fontSize: 32,
                                        color: MyColor.colorWhite,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    spaceDown(Dimensions.space5),
                                    Text(
                                      MyStrings.regRiderScreenSubTitle.tr,
                                      style: regularDefault.copyWith(
                                        color: MyColor.colorWhite,
                                        fontSize: Dimensions.fontLarge,
                                      ),
                                    ),
                                    spaceDown(Dimensions.space40),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Transform.translate(
                          offset: Offset(0, -Dimensions.space20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: MyColor.colorWhite,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(Dimensions.radius25),
                                topRight: Radius.circular(Dimensions.radius25),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: MyColor.colorBlack.withValues(
                                    alpha: 0.05,
                                  ), // soft top shadow
                                  offset: const Offset(
                                    0,
                                    -30,
                                  ), // ⬆️ Shadow goes up
                                  blurRadius: 15,
                                  spreadRadius: -3,
                                ),
                              ],
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimensions.space15,
                              vertical: Dimensions.space15,
                            ),
                            child: Column(
                              children: [
                                spaceDown(Dimensions.space20),
                                SocialAuthSection(
                                  googleAuthTitle: MyStrings.regGoogle,
                                ),
                                spaceDown(Dimensions.space15),
                                const RegistrationForm(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
