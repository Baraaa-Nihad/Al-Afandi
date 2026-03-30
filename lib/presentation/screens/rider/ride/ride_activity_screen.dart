import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/data/controller/rider/ride/all_ride_controller.dart';
import 'package:ovoride/presentation/screens/rider/ride/section/all_rides_list_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RiderRideActivityScreen extends StatefulWidget {
  final VoidCallback? onBackPress;
  const RiderRideActivityScreen({super.key, this.onBackPress});

  @override
  State<RiderRideActivityScreen> createState() =>
      _RiderRideActivityScreenState();
}

class _RiderRideActivityScreenState extends State<RiderRideActivityScreen>
    with SingleTickerProviderStateMixin {
  ScrollController scrollController = ScrollController();
  static const int totalTabs = 6;

  void scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (Get.find<AllRideController>().hasNext()) {
        Get.find<AllRideController>().getAllRide();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    var controller = Get.find<AllRideController>();
    controller.tabController = TabController(
      length: totalTabs,
      vsync: this,
      initialIndex: controller.selectedTab,
    );

    WidgetsBinding.instance.addPostFrameCallback((time) {
      controller.initialData(
        shouldLoading: true,
        tabID: controller.selectedTab,
        rideType: "${Get.arguments ?? ""}",
      );
      scrollController.addListener(scrollListener);
    });
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: GetBuilder<AllRideController>(
          builder: (controller) {
            return Column(
              children: [
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: MyColor.colorWhite,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.09),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: Dimensions.space10),
                      TabBar(
                        controller: controller.tabController,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        labelColor: MyColor.primaryColor,
                        unselectedLabelColor: MyColor.colorBlack.withValues(
                          alpha: 0.6,
                        ),
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                        ),
                        indicatorColor: MyColor.primaryColor,
                        indicatorWeight: 3,
                        indicatorSize: TabBarIndicatorSize.label,
                        dividerColor: Colors
                            .transparent, // إخفاء الخط الفاصل الافتراضي لشكل أنظف
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                        onTap: (i) {
                          controller.changeTab(i);
                        },
                        tabs: [
                          Tab(text: MyStrings.allRides.tr),
                          Tab(text: MyStrings.activeRide.tr),
                          Tab(text: MyStrings.newRide.tr),
                          Tab(text: MyStrings.runningRide.tr),
                          Tab(text: MyStrings.completedRides.tr),
                          Tab(text: MyStrings.canceledRides.tr),
                        ],
                      ),
                    ],
                  ),
                ),

                // مساحة فاصلة بسيطة
                const SizedBox(height: Dimensions.space10),

                // عرض القائمة
                Expanded(
                  child: AllRidesListSection(
                    scrollController: scrollController,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
