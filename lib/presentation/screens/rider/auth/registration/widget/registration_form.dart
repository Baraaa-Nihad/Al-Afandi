import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ovoride/core/route/route.dart';
import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_icons.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/core/utils/style.dart';
import 'package:ovoride/data/controller/rider/auth/registration_controller.dart';
import 'package:ovoride/presentation/components/buttons/rounded_button.dart';
import 'package:ovoride/presentation/components/image/custom_svg_picture.dart';
import 'package:ovoride/presentation/components/text-form-field/custom_text_field.dart';

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final formKey = GlobalKey<FormState>();

  final FocusNode firstNameFocusNode = FocusNode();
  final FocusNode lastNameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode userNameFocusNode = FocusNode();
  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();
  final FocusNode referFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<RegistrationController>(tag: 'rider');
      controller.initData();
    });
  }

  @override
  void dispose() {
    firstNameFocusNode.dispose();
    lastNameFocusNode.dispose();
    emailFocusNode.dispose();
    userNameFocusNode.dispose();
    phoneFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    referFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RegistrationController>(
      tag: 'rider',
      builder: (controller) {
        final double mapLat = controller.selectedLatitude == 0 ? 33.5138 : controller.selectedLatitude;
        final double mapLng = controller.selectedLongitude == 0 ? 36.2765 : controller.selectedLongitude;

        return Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                hintText: MyStrings.firstName.tr,
                controller: controller.fNameController,
                focusNode: firstNameFocusNode,
                textInputType: TextInputType.text,
                nextFocus: lastNameFocusNode,
                prefixIcon: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: Dimensions.space12,
                    end: Dimensions.space8,
                  ),
                  child: CustomSvgPicture(
                    image: MyIcons.user,
                    color: MyColor.primaryColor,
                    height: Dimensions.space30,
                  ),
                ),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return MyStrings.kFirstNameNullError.tr;
                  }
                  return null;
                },
                onChanged: (value) {},
              ),
              const SizedBox(height: Dimensions.space20),
              CustomTextField(
                hintText: MyStrings.lastName.tr,
                controller: controller.lNameController,
                focusNode: lastNameFocusNode,
                textInputType: TextInputType.text,
                nextFocus: emailFocusNode,
                prefixIcon: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: Dimensions.space12,
                    end: Dimensions.space8,
                  ),
                  child: CustomSvgPicture(
                    image: MyIcons.user,
                    color: MyColor.primaryColor,
                    height: Dimensions.space30,
                  ),
                ),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return MyStrings.kLastNameNullError.tr;
                  }
                  return null;
                },
                onChanged: (value) {},
              ),
              const SizedBox(height: Dimensions.space20),
              CustomTextField(
                hintText: MyStrings.email.tr,
                controller: controller.emailController,
                focusNode: emailFocusNode,
                nextFocus: userNameFocusNode,
                textInputType: TextInputType.emailAddress,
                inputAction: TextInputAction.next,
                prefixIcon: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: Dimensions.space12,
                    end: Dimensions.space8,
                  ),
                  child: CustomSvgPicture(
                    image: MyIcons.email,
                    color: MyColor.primaryColor,
                    height: Dimensions.space30,
                  ),
                ),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return MyStrings.enterYourEmail.tr;
                  } else if (!MyStrings.emailValidatorRegExp.hasMatch(
                    value ?? '',
                  )) {
                    return MyStrings.invalidEmailMsg.tr;
                  }
                  return null;
                },
                onChanged: (value) {},
              ),
              const SizedBox(height: Dimensions.space20),
              CustomTextField(
                hintText: MyStrings.username.tr,
                controller: controller.userNameController,
                focusNode: userNameFocusNode,
                nextFocus: phoneFocusNode,
                textInputType: TextInputType.text,
                inputAction: TextInputAction.next,
                prefixIcon: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: Dimensions.space12,
                    end: Dimensions.space8,
                  ),
                  child: CustomSvgPicture(
                    image: MyIcons.user,
                    color: MyColor.primaryColor,
                    height: Dimensions.space30,
                  ),
                ),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return MyStrings.enterYourUsername.tr;
                  } else if ((value ?? '').trim().length < 3) {
                    return MyStrings.kShortUserNameError.tr;
                  }
                  return null;
                },
                onChanged: (value) {},
              ),
              const SizedBox(height: Dimensions.space20),
              CustomTextField(
                hintText: MyStrings.phone.tr,
                controller: controller.mobileNoController,
                focusNode: phoneFocusNode,
                nextFocus: passwordFocusNode,
                textInputType: TextInputType.phone,
                inputAction: TextInputAction.next,
                prefixIcon: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: Dimensions.space12,
                    end: Dimensions.space8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: Dimensions.space8),
                      Text(
                        controller.selectedCountryData.dialCode?.isNotEmpty == true ? '+${controller.selectedCountryData.dialCode}' : '+880',
                        style: regularMediumLarge.copyWith(
                          color: MyColor.getHeadingTextColor(),
                        ),
                      ),
                      const SizedBox(width: Dimensions.space8),
                      Container(
                        width: 1,
                        height: 24,
                        color: MyColor.getTextFieldDisableBorder(),
                      ),
                      const SizedBox(width: Dimensions.space8),
                    ],
                  ),
                ),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return MyStrings.enterYourPhoneNumber.tr;
                  }
                  return null;
                },
                onChanged: (value) {},
              ),
              const SizedBox(height: Dimensions.space20),
              CustomTextField(
                isShowSuffixIcon: true,
                isPassword: true,
                hintText: MyStrings.password.tr,
                controller: controller.passwordController,
                focusNode: passwordFocusNode,
                nextFocus: confirmPasswordFocusNode,
                textInputType: TextInputType.text,
                inputAction: TextInputAction.next,
                prefixIcon: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: Dimensions.space12,
                    end: Dimensions.space8,
                  ),
                  child: CustomSvgPicture(
                    image: MyIcons.password,
                    color: MyColor.primaryColor,
                    height: Dimensions.space30,
                  ),
                ),
                validator: (value) {
                  if ((value ?? '').isEmpty) {
                    return "دخل الباسوورد";
                  } else if ((value ?? '').length < 6) {
                    return "كلمة المرور قصيرة";
                  }
                  return null;
                },
                onChanged: (value) {},
              ),
              const SizedBox(height: Dimensions.space20),
              CustomTextField(
                hintText: MyStrings.confirmPassword.tr,
                controller: controller.cPasswordController,
                focusNode: confirmPasswordFocusNode,
                nextFocus: referFocusNode,
                inputAction: TextInputAction.next,
                isShowSuffixIcon: true,
                isPassword: true,
                prefixIcon: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: Dimensions.space12,
                    end: Dimensions.space8,
                  ),
                  child: CustomSvgPicture(
                    image: MyIcons.password,
                    color: MyColor.primaryColor,
                    height: Dimensions.space30,
                  ),
                ),
                onChanged: (value) {},
                validator: (value) {
                  if ((value ?? '').isEmpty) {
                    return MyStrings.confirmYourPassword.tr;
                  } else if (controller.passwordController.text != controller.cPasswordController.text) {
                    return MyStrings.kMatchPassError.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: Dimensions.space25),
              Text(
                'الموقع الحـالي : ',
                style: boldLarge.copyWith(
                  color: MyColor.getHeadingTextColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: Dimensions.space15),
              ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radius25),
                child: SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(mapLat, mapLng),
                          zoom: 16,
                        ),
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                        scrollGesturesEnabled: true,
                        zoomGesturesEnabled: true,
                        rotateGesturesEnabled: true,
                        tiltGesturesEnabled: true,
                        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                          Factory<OneSequenceGestureRecognizer>(
                            () => EagerGestureRecognizer(),
                          ),
                        },
                        onMapCreated: controller.onMapCreated,
                        onCameraMove: controller.onCameraMove,
                        onCameraIdle: controller.onCameraIdle,
                      ),
                      const IgnorePointer(
                        child: Icon(
                          Icons.location_pin,
                          size: 42,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.space15),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: MyColor.primaryColor.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(Dimensions.radius25),
                  border: Border.all(
                    color: MyColor.primaryColor.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.place_outlined,
                      color: MyColor.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        controller.selectedAddressText.isEmpty
                            ? 'جارٍ تحديد العنوان...'
                            : " مكانك الآن : ${controller.selectedAddressText.split(RegExp(r'[,|،]')) // التقسيم سواء كانت الفاصلة عربية (،) أو إنجليزية (,)
                                .map((e) => e.trim()) // تنظيف المسافات من الجانبين
                                .where((e) => e.isNotEmpty) // استبعاد الفراغات
                                .toSet() // حذف الكلمات المكررة
                                .join(' - ')}", // الدمج باستخدام الشرطة (-)
                        style: regularDefault.copyWith(
                          color: MyColor.getHeadingTextColor(),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.space25),
              Row(
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: Checkbox(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          Dimensions.defaultRadius,
                        ),
                      ),
                      activeColor: MyColor.primaryColor,
                      checkColor: MyColor.colorWhite,
                      value: controller.agreeTC,
                      side: WidgetStateBorderSide.resolveWith(
                        (states) => BorderSide(
                          width: 2.0,
                          color: controller.agreeTC ? MyColor.getTextFieldEnableBorder() : MyColor.getTextFieldDisableBorder(),
                        ),
                      ),
                      onChanged: (bool? value) {
                        controller.agreeTC = value ?? false;
                        controller.update();
                      },
                    ),
                  ),
                  const SizedBox(width: Dimensions.space8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        controller.agreeTC = !controller.agreeTC;
                        controller.update();
                      },
                      child: RichText(
                        text: TextSpan(
                          text: MyStrings.regTerm.tr,
                          style: lightDefault.copyWith(
                            color: MyColor.colorGrey,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: " ${MyStrings.privacyPolicy.tr}",
                              style: boldDefault.copyWith(
                                color: MyColor.colorGrey,
                                fontWeight: FontWeight.w600,
                                height: 1.7,
                                fontSize: 14,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Get.toNamed(RouteHelper.privacyScreen);
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.space30),
              RoundedButton(
                isLoading: controller.submitLoading,
                text: MyStrings.register.tr,
                press: () {
                  if (!controller.hasConfirmedLocation) {
                    Get.snackbar(
                      'تنبيه',
                      'يرجى تحديد موقعك على الخريطة أولاً',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }

                  if (formKey.currentState!.validate()) {
                    controller.signUpUser();
                  }
                },
              ),
              const SizedBox(height: Dimensions.space30),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    MyStrings.alreadyAccount.tr,
                    overflow: TextOverflow.ellipsis,
                    style: lightLarge.copyWith(
                      color: MyColor.getBodyTextColor(),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(width: Dimensions.space5),
                  TextButton(
                    onPressed: () {
                      Get.offAllNamed(RouteHelper.riderLoginScreen);
                    },
                    child: Text(
                      MyStrings.logIn.tr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: boldLarge.copyWith(
                        color: MyColor.getPrimaryColor(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
