import 'package:ovoride/core/utils/my_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovoride/core/route/route.dart';
import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/core/utils/style.dart';
import 'package:ovoride/data/controller/rider/auth/login_controller.dart';
import 'package:ovoride/data/controller/shared/auth/social_auth_controller.dart';
import 'package:ovoride/data/repo/rider/auth/login_repo.dart';
import 'package:ovoride/data/repo/shared/auth/social_auth_repo.dart';
import 'package:ovoride/presentation/components/annotated_region/annotated_region_widget.dart';
import 'package:ovoride/presentation/components/buttons/rounded_button.dart';
import 'package:ovoride/presentation/components/image/custom_svg_picture.dart';
import 'package:ovoride/presentation/components/text-form-field/custom_text_field.dart';
import 'package:ovoride/presentation/components/text/default_text.dart';
import 'package:ovoride/presentation/components/will_pop_widget.dart';
import 'package:ovoride/presentation/screens/shared/auth/auth_background.dart';
import 'package:ovoride/presentation/screens/shared/auth/social_auth/social_auth_section.dart';
// مهم للتحقق من الدور

import 'package:ovoride/core/utils/my_images.dart';
import 'package:ovoride/presentation/components/divider/custom_spacer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final String userRole = 'rider';

  @override
  void initState() {
    Get.put(LoginRepo(apiClient: Get.find()));
    Get.put(LoginController(loginRepo: Get.find()));
    Get.put(SocialAuthRepo(apiClient: Get.find()));
    Get.put(SocialAuthController(authRepo: Get.find()));

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<LoginController>().remember = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopWidget(
      nextRoute: '',
      child: AnnotatedRegionWidget(
        statusBarColor: Colors.transparent,
        child: Scaffold(
          backgroundColor: MyColor.colorWhite,
          body: GetBuilder<LoginController>(
            builder: (controller) => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AuthBackgroundWidget(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: Dimensions.space20, vertical: Dimensions.space10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          spaceDown(Dimensions.space15),
                          Center(
                            child: Image.asset(
                              MyImages.appLogoWhite,
                              width: MediaQuery.of(context).size.width / 2,
                            ),
                          ),
                          spaceDown(Dimensions.space15),
                          // تعديل العنوان بناءً على براند الأفنـدي الجديد
                          Text(
                            userRole == 'driver' ? "أهلاً بك يا كابتن" : "جاهز لمشوارك؟",
                            style: boldExtraLarge.copyWith(
                              fontSize: 32,
                              color: MyColor.colorWhite,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          spaceDown(Dimensions.space5),
                          Text(
                            userRole == 'driver' ? "سجل دخولك وابدأ في تحقيق الأرباح" : "سجل دخولك واستمتع برحلة آمنة مع الأفنـدي",
                            style: regularDefault.copyWith(
                              color: MyColor.colorWhite,
                              fontSize: Dimensions.fontLarge,
                            ),
                          ),
                          spaceDown(Dimensions.space40),
                        ],
                      ),
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
                            color: MyColor.colorBlack.withValues(alpha: 0.05),
                            offset: const Offset(0, -30),
                            blurRadius: 15,
                            spreadRadius: -3,
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SocialAuthSection(),
                          Form(
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                spaceDown(Dimensions.space20),
                                CustomTextField(
                                  controller: controller.emailController,
                                  hintText: MyStrings.usernameOrEmail.tr,
                                  onChanged: (value) {},
                                  focusNode: controller.emailFocusNode,
                                  nextFocus: controller.passwordFocusNode,
                                  textInputType: TextInputType.emailAddress,
                                  inputAction: TextInputAction.next,
                                  prefixIcon: Padding(
                                    padding: EdgeInsetsDirectional.only(start: Dimensions.space12, end: Dimensions.space8),
                                    child: CustomSvgPicture(
                                      image: MyIcons.user,
                                      color: MyColor.primaryColor,
                                      height: Dimensions.space30,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return MyStrings.fieldErrorMsg.tr;
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                                spaceDown(Dimensions.space20),
                                CustomTextField(
                                  hintText: MyStrings.password.tr,
                                  controller: controller.passwordController,
                                  focusNode: controller.passwordFocusNode,
                                  onChanged: (value) {},
                                  isShowSuffixIcon: true,
                                  isPassword: true,
                                  textInputType: TextInputType.text,
                                  inputAction: TextInputAction.done,
                                  prefixIcon: Padding(
                                    padding: EdgeInsetsDirectional.only(start: Dimensions.space12, end: Dimensions.space8),
                                    child: CustomSvgPicture(
                                      image: MyIcons.password,
                                      color: MyColor.primaryColor,
                                      height: Dimensions.space30,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return MyStrings.fieldErrorMsg.tr;
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                                spaceDown(Dimensions.space15),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 28,
                                          height: 28,
                                          child: Checkbox(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(Dimensions.space5),
                                            ),
                                            activeColor: MyColor.primaryColor,
                                            checkColor: MyColor.colorWhite,
                                            value: controller.remember,
                                            onChanged: (value) {
                                              controller.changeRememberMe();
                                            },
                                          ),
                                        ),
                                        spaceSide(Dimensions.space8),
                                        InkWell(
                                          onTap: () => controller.changeRememberMe(),
                                          child: DefaultText(
                                            text: MyStrings.rememberMe.tr,
                                            textColor: MyColor.getBodyTextColor(),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    InkWell(
                                      onTap: () {
                                        controller.clearTextField();
                                        Get.toNamed(RouteHelper.forgotPasswordScreen);
                                      },
                                      child: DefaultText(
                                        text: MyStrings.forgotPassword.tr,
                                        textColor: MyColor.redCancelTextColor,
                                        textStyle: boldDefault.copyWith(fontSize: Dimensions.fontLarge),
                                      ),
                                    ),
                                  ],
                                ),
                                spaceDown(Dimensions.space25),
                                RoundedButton(
                                  isLoading: controller.isSubmitLoading,
                                  text: MyStrings.logIn.tr,
                                  press: () {
                                    if (formKey.currentState!.validate()) {
                                      // --- النقطة 4: ضمان تفعيل الدخول وربطه بالسيرفر (Cron Job Logic) ---
                                      // في الكنترولر، تأكد أن عملية loginUser() ترسل الـ Role للسيرفر
                                      // لكي يقوم الـ Cron Job بتحديث حالة السائق فوراً كـ Active.
                                      controller.loginUser();
                                    }
                                  },
                                ),
                                spaceDown(Dimensions.space30),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      MyStrings.doNotHaveAccount.tr,
                                      style: boldLarge.copyWith(
                                        color: MyColor.getBodyTextColor(),
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    const SizedBox(width: Dimensions.space5),
                                    TextButton(
                                      onPressed: () {
                                        Get.offAndToNamed(RouteHelper.riderRegistartionScreen);
                                      },
                                      child: Text(
                                        MyStrings.register.tr,
                                        style: boldLarge.copyWith(color: MyColor.getPrimaryColor()),
                                      ),
                                    ),
                                  ],
                                ),
                                spaceDown(Dimensions.space15),

                                // --- النقطة 2: Role Reminder & Switcher ---
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                  decoration: BoxDecoration(
                                    color: MyColor.primaryColor.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(Dimensions.radius25),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        userRole == 'driver' ? "ترجع تسجل كراكب ؟" : "ترجع تسجل ككابتن ؟",
                                        style: boldDefault.copyWith(color: MyColor.primaryColor),
                                      ),
                                      InkWell(
                                        onTap: () => Get.offAllNamed(RouteHelper.userRoleScreen),
                                        child: Text(
                                          "تغيير الدور؟",
                                          style: regularDefault.copyWith(
                                            color: MyColor.redCancelTextColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                spaceDown(Dimensions.space20),
                              ],
                            ),
                          ),
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
