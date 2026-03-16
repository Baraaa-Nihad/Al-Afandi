import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_icons.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/data/controller/driver/dashboard/dashboard_controller.dart';
import 'package:ovoride/data/controller/driver/pusher/global_pusher_controller.dart';
import 'package:ovoride/data/controller/driver/ride/ride_action/ride_action_controller.dart';
import 'package:ovoride/data/controller/driver/ride/all_ride/all_ride_controller.dart';
import 'package:ovoride/data/repo/driver/dashboard/dashboard_repo.dart';
import 'package:ovoride/data/repo/driver/ride/ride_repo.dart';
import 'package:ovoride/presentation/components/annotated_region/annotated_region_widget.dart';
import 'package:ovoride/presentation/components/image/custom_svg_picture.dart';
import 'package:ovoride/presentation/screens/driver/ride_history/ride_activity_screen.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/presentation/components/will_pop_widget.dart';
import 'package:ovoride/presentation/screens/shared/profile_and_settings/profile_and_settings_screen.dart';
import 'package:ovoride/presentation/screens/driver/rides/home_screen/home_screen.dart';
import 'package:ovoride/presentation/packages/flutter_floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  int selectedIndex = 0;
  late List<Widget> _widgets;

  @override
  void initState() {
    Get.put(RideRepo(apiClient: Get.find()), tag: 'driver');
    Get.put(DashBoardRepo(apiClient: Get.find()));
    Get.put(DashBoardController(repo: Get.find()));
    var globalPusherController = Get.put(
      GlobalPusherController(
        apiClient: Get.find(),
        dashBoardController: Get.find(),
      ),
    );
    Get.put(RideActionController(repo: Get.find(tag: 'driver')));
    Get.put(AllRideController(repo: Get.find(tag: 'driver')), tag: 'driver');
    _widgets = <Widget>[
      HomeScreen(),
      RideActivityScreen(
        onBackPress: () {
          changeScreen(0);
        },
      ),
      const ProfileAndSettingsScreen(),
    ];
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      globalPusherController.ensureConnection();
    });
  }

  void changeScreen(int val) {
    setState(() {
      selectedIndex = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopWidget(
      child: AnnotatedRegionWidget(
        systemNavigationBarColor: MyColor.colorWhite,
        statusBarColor: MyColor.transparentColor,
        child: GetBuilder<DashBoardController>(
          builder: (controller) => Scaffold(
            extendBody: true,
            body: IndexedStack(index: selectedIndex, children: _widgets),
            bottomNavigationBar: FloatingNavbar(
              inLine: true,
              fontSize: Dimensions.fontMedium,
              backgroundColor: MyColor.colorWhite,
              unselectedItemColor: MyColor.bodyMutedTextColor,
              selectedItemColor: MyColor.primaryColor,
              borderRadius: Dimensions.space50,
              itemBorderRadius: Dimensions.space50,
              selectedBackgroundColor: MyColor.primaryColor.withValues(
                alpha: 0.09,
              ),
              onTap: (int val) {
                changeScreen(val);
                if (Get.isRegistered<AllRideController>(tag: 'driver')) {
                  Get.find<AllRideController>(tag: 'driver').changeTab(0);
                }
              },
              margin: const EdgeInsetsDirectional.only(
                start: Dimensions.space20,
                end: Dimensions.space20,
                bottom: Dimensions.space15,
              ),
              currentIndex: selectedIndex,
              items: [
                FloatingNavbarItem(
                  icon: Icons.home,
                  title: MyStrings.home.tr,
                  customWidget: CustomSvgPicture(
                    image: selectedIndex == 0 ? MyIcons.homeActive : MyIcons.home,
                    color: selectedIndex == 0 ? MyColor.primaryColor : MyColor.bodyMutedTextColor,
                  ),
                ),
                FloatingNavbarItem(
                  icon: Icons.location_city,
                  title: MyStrings.activity.tr,
                  customWidget: CustomSvgPicture(
                    image: selectedIndex == 1 ? MyIcons.activityActive : MyIcons.activity,
                    color: selectedIndex == 1 ? MyColor.primaryColor : MyColor.bodyMutedTextColor,
                  ),
                ),
                FloatingNavbarItem(
                  icon: Icons.list,
                  title: MyStrings.menu.tr,
                  customWidget: CustomSvgPicture(
                    image: selectedIndex == 2 ? MyIcons.menuActive : MyIcons.menu,
                    color: selectedIndex == 2 ? MyColor.primaryColor : MyColor.bodyMutedTextColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
