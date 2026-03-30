import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/data/controller/rider/home/home_controller.dart';
import 'package:ovoride/data/controller/rider/location/app_location_controller.dart';
import 'package:ovoride/data/repo/rider/home/home_repo.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovoride/data/services/notification_controller.dart';
import 'package:ovoride/presentation/components/divider/custom_spacer.dart';
import 'package:ovoride/presentation/screens/rider/dashboard/dashboard_background.dart';
import 'package:ovoride/presentation/screens/rider/home/widgets/home_app_bar.dart';
import 'package:ovoride/presentation/screens/rider/home/widgets/home_body.dart';

import 'widgets/location_pickup_widget.dart';

class RiderHomeScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState>? dashBoardScaffoldKey;

  const RiderHomeScreen({super.key, this.dashBoardScaffoldKey});

  @override
  State<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends State<RiderHomeScreen>
    with SingleTickerProviderStateMixin {
  double appBarSize = 90.0;

  @override
  void initState() {
    Get.find<NotificationController>();
    Get.put(HomeRepo(apiClient: Get.find()));
    Get.put(AppLocationController());
    final controller = Get.put(
      HomeController(homeRepo: Get.find(), appLocationController: Get.find()),
    );
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.initialData(shouldLoad: true);
    });
  }

  void openDrawer() {
    if (widget.dashBoardScaffoldKey != null) {
      widget.dashBoardScaffoldKey?.currentState?.openEndDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return RiderDashboardBackground(
          child: Scaffold(
            extendBody: true,
            backgroundColor: MyColor.transparentColor,
            extendBodyBehindAppBar: false,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(appBarSize),
              child: RiderHomeScreenAppBar(
                controller: controller,
                openDrawer: openDrawer,
              ),
            ),
            body: RefreshIndicator(
              color: MyColor.primaryColor,
              backgroundColor: MyColor.colorWhite,
              onRefresh: () async {
                controller.initialData(shouldLoad: true);
              },
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.space16),
                physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics(),
                ),
                child: Column(
                  children: [
                    LocationPickUpHomeWidget(controller: controller),
                    spaceDown(Dimensions.space20),
                    HomeBody(controller: controller),
                    spaceDown(Dimensions.space20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
