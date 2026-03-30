import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_images.dart';
import 'package:ovoride/core/utils/util.dart';
import 'package:ovoride/data/controller/shared/localization/localization_controller.dart';
import 'package:ovoride/data/controller/shared/splash/splash_controller.dart';
import 'package:ovoride/data/repo/shared/auth/general_setting_repo.dart';
import 'package:ovoride/presentation/components/annotated_region/annotated_region_widget.dart';
import 'package:ovoride/presentation/components/custom_no_data_found_class.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    MyUtils.splashScreen();

    Get.put(GeneralSettingRepo(apiClient: Get.find()));
    Get.put(LocalizationController(sharedPreferences: Get.find()));
    final controller = Get.put(
      SplashController(repo: Get.find(), localizationController: Get.find()),
    );

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.gotoNextPage();
    });
  }

  @override
  void dispose() {
    MyUtils.allScreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      builder: (controller) => AnnotatedRegionWidget(
        bottom: false,
        statusBarColor: MyColor.transparentColor,
        systemNavigationBarColor: const Color.fromARGB(255, 124, 77, 255),
        child: Scaffold(
          body: controller.noInternet
              ? NoDataOrInternetScreen(
                  isNoInternet: true,
                  onChanged: () {
                    controller.gotoNextPage();
                  },
                )
              : Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        MyImages.backgroundImage,
                        height: double.infinity,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.85,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.center,
                              end: Alignment.bottomCenter,
                              colors: [
                                const Color.fromARGB(
                                  255,
                                  4,
                                  2,
                                  10,
                                ), // Left-side purple
                                const Color.fromARGB(
                                  255,
                                  112,
                                  94,
                                  167,
                                ).withValues(
                                  alpha: 0.8,
                                ), // Right-side lighter purple
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        MyImages.logoWhite,
                        height: double.infinity,
                        width: MediaQuery.of(context).size.height * 0.4,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
