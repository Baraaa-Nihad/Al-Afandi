import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ovoride/core/helper/string_format_helper.dart';
import 'package:ovoride/core/route/route.dart';
import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/core/utils/style.dart';
import 'package:ovoride/core/utils/url_container.dart';
import 'package:ovoride/data/controller/shared/account/profile_complete_controller.dart';
import 'package:ovoride/data/repo/shared/account/profile_repo.dart';
import 'package:ovoride/presentation/components/annotated_region/annotated_region_widget.dart';
import 'package:ovoride/presentation/components/buttons/rounded_button.dart';
import 'package:ovoride/presentation/components/custom_loader/custom_loader.dart';
import 'package:ovoride/presentation/components/divider/custom_spacer.dart';
import 'package:ovoride/presentation/components/image/my_network_image_widget.dart';
import 'package:ovoride/presentation/components/text-form-field/custom_text_field.dart';
import 'package:ovoride/presentation/components/will_pop_widget.dart';
import 'package:ovoride/presentation/screens/shared/auth/auth_background.dart';
import 'package:ovoride/presentation/screens/shared/auth/registration/widget/country_bottom_sheet.dart';
import 'package:ovoride/presentation/screens/shared/auth/registration/widget/zone_bottom_sheet.dart';

class ProfileCompleteScreen extends StatefulWidget {
  const ProfileCompleteScreen({super.key});

  @override
  State<ProfileCompleteScreen> createState() => _ProfileCompleteScreenState();
}

class _ProfileCompleteScreenState extends State<ProfileCompleteScreen> {
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    Get.put(ProfileRepo(apiClient: Get.find()));
    final controller = Get.put(
      DriverProfileCompleteController(profileRepo: Get.find()),
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.initialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopWidget(
      nextRoute: '',
      child: AnnotatedRegionWidget(
        child: Scaffold(
          backgroundColor: MyColor.colorWhite,
          body: GetBuilder<DriverProfileCompleteController>(
            builder: (controller) => SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AuthBackgroundWidget(
                    colors: [
                      MyColor.colorWhite.withValues(alpha: 0.9),
                      MyColor.colorWhite.withValues(alpha: 0.8),
                    ],
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
                                Get.offAllNamed(RouteHelper.getLoginScreen());
                              },
                              icon: Icon(
                                Icons.close,
                                size: Dimensions.space30,
                                color: MyColor.getHeadingTextColor(),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.space20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                MyStrings.profileCompleteTitle.tr,
                                style: boldExtraLarge.copyWith(
                                  fontSize: 32,
                                  color: MyColor.getHeadingTextColor(),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              spaceDown(Dimensions.space5),
                              Text(
                                MyStrings.profileCompleteSubTitle.tr,
                                style: regularDefault.copyWith(
                                  color: MyColor.getBodyTextColor(),
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
                    offset: const Offset(0, -Dimensions.space20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: MyColor.colorWhite,
                        borderRadius: const BorderRadius.only(
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.space20,
                        vertical: Dimensions.space20,
                      ),
                      child: controller.isLoading
                          ? const CustomLoader()
                          : Form(
                              key: formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTextField(
                                    labelText: MyStrings.username.tr,
                                    hintText: "${MyStrings.enterYour.tr} ${MyStrings.username.toLowerCase().tr}",
                                    textInputType: TextInputType.text,
                                    inputAction: TextInputAction.next,
                                    focusNode: controller.userNameFocusNode,
                                    controller: controller.userNameController,
                                    nextFocus: controller.mobileNoFocusNode,
                                    onChanged: (value) {
                                      return;
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return MyStrings.enterYourUsername.tr;
                                      } else if (value.length < 6) {
                                        return MyStrings.kShortUserNameError;
                                      } else {
                                        return null;
                                      }
                                    },
                                  ),
                                  const SizedBox(
                                    height: Dimensions.space20,
                                  ),
                                  CustomTextField(
                                    labelText: MyStrings.phone.tr,
                                    hintText: "XXX-XXX-XXXX",
                                    textInputType: TextInputType.number,
                                    inputAction: TextInputAction.done,
                                    focusNode: controller.mobileNoFocusNode,
                                    controller: controller.mobileNoController,
                                    prefixIcon: IntrinsicWidth(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: Dimensions.space10,
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            CountryBottomSheet.profileBottomSheet(
                                              context,
                                              controller,
                                            );
                                          },
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              spaceSide(Dimensions.space3),
                                              MyImageWidget(
                                                imageUrl: UrlContainer.countryFlagImageLink.replaceAll(
                                                  "{countryCode}",
                                                  controller.selectedCountryData.countryCode.toString().toLowerCase(),
                                                ),
                                                height: Dimensions.space25,
                                                width: Dimensions.space40,
                                              ),
                                              spaceSide(Dimensions.space5),
                                              Text(
                                                "+${controller.selectedCountryData.dialCode}",
                                                style: regularMediumLarge.copyWith(
                                                  fontSize: Dimensions.fontOverLarge,
                                                ),
                                              ),
                                              Icon(
                                                Icons.keyboard_arrow_down_rounded,
                                                color: MyColor.getBodyTextColor(),
                                              ),
                                              spaceSide(Dimensions.space2),
                                              Container(
                                                color: MyColor.naturalTextColor,
                                                width: 1,
                                                height: Dimensions.space30,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      return;
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return MyStrings.enterYourPhoneNumber.tr;
                                      } else {
                                        return null;
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 20),

                                  /// 🔥 Zone (رجعناه)
                                  CustomTextField(
                                      readOnly: true,
                                      labelText: MyStrings.selectYourZone.tr,
                                      hintText: MyStrings.selectYourZone.tr,
                                      controller: TextEditingController(
                                        text: controller.selectedZone.id == "-1" ? MyStrings.selectYourZone.tr : (controller.selectedZone.name ?? '').toTitleCase(),
                                      ),
                                      onTap: () {
                                        ZoneBottomSheet.bottomSheet(
                                          context,
                                          controller,
                                        );
                                      },
                                      onChanged: (value) {}),

                                  const SizedBox(height: 20),
                                  const SizedBox(
                                    height: Dimensions.space20,
                                  ),

                                  Text(
                                    'الموقع الحـالي :',
                                    style: boldLarge.copyWith(
                                      color: MyColor.getHeadingTextColor(),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  const SizedBox(height: Dimensions.space15),

                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radius25,
                                    ),
                                    child: SizedBox(
                                      height: 150,
                                      width: double.infinity,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          GoogleMap(
                                            initialCameraPosition: CameraPosition(
                                              target: LatLng(
                                                controller.selectedLatitude,
                                                controller.selectedLongitude,
                                              ),
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
                                      borderRadius: BorderRadius.circular(
                                        Dimensions.radius25,
                                      ),
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
                                            controller.selectedAddressText.isEmpty ? 'جارٍ تحديد العنوان...' : controller.selectedAddressText,
                                            style: regularDefault.copyWith(
                                              color: MyColor.getHeadingTextColor(),
                                              height: 1.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // const SizedBox(height: Dimensions.space12),

                                  // Align(
                                  //   alignment: AlignmentDirectional.centerStart,
                                  //   child: InkWell(
                                  //     onTap: controller.moveToCurrentLocation,
                                  //     borderRadius: BorderRadius.circular(50),
                                  //     child: Container(
                                  //       padding: const EdgeInsets.symmetric(
                                  //         horizontal: 14,
                                  //         vertical: 10,
                                  //       ),
                                  //       decoration: BoxDecoration(
                                  //         color: MyColor.colorWhite,
                                  //         borderRadius: BorderRadius.circular(50),
                                  //         border: Border.all(
                                  //           color: MyColor.primaryColor.withValues(alpha: 0.15),
                                  //         ),
                                  //         boxShadow: [
                                  //           BoxShadow(
                                  //             color: MyColor.colorBlack.withValues(alpha: 0.06),
                                  //             blurRadius: 10,
                                  //             offset: const Offset(0, 4),
                                  //           ),
                                  //         ],
                                  //       ),
                                  //       child: Row(
                                  //         mainAxisSize: MainAxisSize.min,
                                  //         children: [
                                  //           Icon(
                                  //             Icons.my_location,
                                  //             color: MyColor.primaryColor,
                                  //             size: 18,
                                  //           ),
                                  //           const SizedBox(width: 8),
                                  //           Text(
                                  //             'تغيـير الموقع الحالي ؟',
                                  //             style: regularDefault.copyWith(
                                  //               color: MyColor.getHeadingTextColor(),
                                  //               fontWeight: FontWeight.w500,
                                  //             ),
                                  //           ),
                                  //         ],
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),

                                  const SizedBox(
                                    height: Dimensions.space35,
                                  ),

                                  RoundedButton(
                                    isLoading: controller.submitLoading,
                                    text: MyStrings.completeProfile.tr,
                                    press: () {
                                      if (formKey.currentState!.validate()) {
                                        controller.updateProfile();
                                      }
                                    },
                                  ),
                                ],
                              ),
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
