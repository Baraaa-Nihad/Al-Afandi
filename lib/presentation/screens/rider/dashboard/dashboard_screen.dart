import 'package:get/get.dart';
import 'package:ovoride/core/utils/my_icons.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/core/utils/util.dart';
import 'package:ovoride/data/controller/rider/menu/my_menu_controller.dart';
import 'package:ovoride/data/controller/rider/pusher/global_pusher_controller.dart';
import 'package:ovoride/data/controller/rider/ride/all_ride_controller.dart';
import 'package:ovoride/data/repo/shared/auth/general_setting_repo.dart';
import 'package:ovoride/data/repo/rider/menu_repo/menu_repo.dart';
import 'package:ovoride/presentation/components/annotated_region/annotated_region_widget.dart';
import 'package:ovoride/presentation/components/image/custom_svg_picture.dart';
import 'package:ovoride/presentation/screens/rider/home/home_screen.dart';
import 'package:ovoride/presentation/screens/shared/profile_and_settings/profile_and_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:ovoride/presentation/screens/rider/ride/ride_activity_screen.dart';
import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/presentation/components/will_pop_widget.dart';
import 'package:ovoride/presentation/packages/flutter_floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:ovoride/presentation/screens/rider/dashboard/drawer/drawer_screen.dart';

class RiderDashBoardScreen extends StatefulWidget {
  const RiderDashBoardScreen({super.key});

  @override
  State<RiderDashBoardScreen> createState() => _RiderDashBoardScreenState();
}

class _RiderDashBoardScreenState extends State<RiderDashBoardScreen> {
  late GlobalKey<ScaffoldState> _dashBoardScaffoldKey;
  late List<Widget> _widgets;
  int selectedIndex = 0;

  @override
  void initState() {
    int index = Get.arguments ?? 0;
    selectedIndex = index;
    super.initState();

    Get.put(GeneralSettingRepo(apiClient: Get.find()));
    Get.put(MenuRepo(apiClient: Get.find()));
    Get.put(MyMenuController(menuRepo: Get.find(), repo: Get.find()));
    final pusherController = Get.put(GlobalPusherController(apiClient: Get.find()));
    _dashBoardScaffoldKey = GlobalKey<ScaffoldState>();

    _widgets = <Widget>[
      RiderHomeScreen(dashBoardScaffoldKey: _dashBoardScaffoldKey),
      RiderRideActivityScreen(
        onBackPress: () {
          changeScreen(0);
        },
      ),
      const ProfileAndSettingsScreen(),
    ];
    WidgetsBinding.instance.addPostFrameCallback((t) {
      pusherController.ensureConnection();
    });
  }

  void closeDrawer() {
    _dashBoardScaffoldKey.currentState!.closeEndDrawer();
  }

  void changeScreen(int val) {
    setState(() {
      selectedIndex = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        MyUtils.closeKeyboard();
      },
      child: AnnotatedRegionWidget(
        systemNavigationBarColor: MyColor.colorWhite,
        statusBarColor: MyColor.transparentColor,
        child: GetBuilder<MyMenuController>(
          builder: (controller) {
            return Scaffold(
              key: _dashBoardScaffoldKey,
              extendBody: true,
              endDrawer: AppDrawerScreen(
                closeFunction: closeDrawer,
                callback: (val) {
                  selectedIndex = val;
                  setState(() {});
                  closeDrawer(); // closeDrawer
                },
              ),
              body: WillPopWidget(child: IndexedStack(index: selectedIndex, children: _widgets)),
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
                  controller.repo.apiClient.storeCurrentTab(val.toString());
                  changeScreen(val);
                  if (Get.isRegistered<AllRideController>()) {
                    Get.find<AllRideController>().changeTab(0);
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
                    icon: LineIcons.home,
                    title: MyStrings.home.tr,
                    customWidget: CustomSvgPicture(
                      image: selectedIndex == 0 ? MyIcons.homeActive : MyIcons.home,
                      color: selectedIndex == 0 ? MyColor.primaryColor : MyColor.bodyMutedTextColor,
                    ),
                  ),
                  FloatingNavbarItem(
                    icon: LineIcons.city,
                    title: MyStrings.activity.tr,
                    customWidget: CustomSvgPicture(
                      image: selectedIndex == 1 ? MyIcons.activityActive : MyIcons.activity,
                      color: selectedIndex == 1 ? MyColor.primaryColor : MyColor.bodyMutedTextColor,
                    ),
                  ),
                  FloatingNavbarItem(
                    icon: LineIcons.list,
                    title: MyStrings.menu.tr,
                    customWidget: CustomSvgPicture(
                      image: selectedIndex == 2 ? MyIcons.menuActive : MyIcons.menu,
                      color: selectedIndex == 2 ? MyColor.primaryColor : MyColor.bodyMutedTextColor,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
