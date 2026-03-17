import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/core/utils/style.dart';
import 'package:ovoride/data/controller/driver/ride/ride_action/ride_action_controller.dart';
import 'package:ovoride/data/controller/driver/ride/all_ride/all_ride_controller.dart';
import 'package:ovoride/data/repo/driver/ride/ride_repo.dart';
import 'package:ovoride/presentation/screens/driver/ride_history/all_ride/all_ride_list_section.dart';

class RideActivityScreen extends StatefulWidget {
  final VoidCallback? onBackPress;
  const RideActivityScreen({super.key, this.onBackPress});

  @override
  State<RideActivityScreen> createState() => _RideActivityScreenState();
}

class _RideActivityScreenState extends State<RideActivityScreen> with SingleTickerProviderStateMixin {
  ScrollController scrollController = ScrollController();
  static const int totalTabls = 6;

  void scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (Get.find<AllRideController>(tag: 'driver').hasNext()) {
        Get.find<AllRideController>(tag: 'driver').getAllRide();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // تهيئة الكونترولرز
    Get.put(RideRepo(apiClient: Get.find()), tag: 'driver');
    Get.put(RideActionController(repo: Get.find(tag: 'driver')));
    var controller = Get.put(AllRideController(repo: Get.find(tag: 'driver')), tag: 'driver');

    controller.tabController = TabController(
      length: totalTabls,
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
      // خلفية فاتحة جداً تعطي شعوراً بالنظافة (تجنب الرمادي الغامق)
      backgroundColor: const Color.fromARGB(197, 158, 152, 157),
      body: GetBuilder<AllRideController>(
        tag: 'driver',
        builder: (controller) {
          return Column(
            children: [
              SizedBox(
                height: 40,
              ),
              Container(
                padding: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: MyColor.colorWhite,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: TabBar(
                  controller: controller.tabController,
                  physics: const BouncingScrollPhysics(),
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: MyColor.primaryColor,
                  unselectedLabelColor: MyColor.colorGrey,
                  labelStyle: boldDefault.copyWith(fontSize: 14),
                  unselectedLabelStyle: regularDefault.copyWith(fontSize: 14),
                  indicatorSize: TabBarIndicatorSize.label, // المؤشر تحت النص فقط
                  indicator: const UnderlineTabIndicator(
                    borderSide: BorderSide(width: 3, color: MyColor.primaryColor),
                    insets: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  onTap: (i) => controller.changeTab(i),
                  tabs: [
                    Tab(text: MyStrings.allRide.tr),
                    Tab(text: MyStrings.acceptedRide.tr),
                    Tab(text: MyStrings.activeRide.tr),
                    Tab(text: MyStrings.runningRide.tr),
                    Tab(text: MyStrings.completedRides.tr),
                    Tab(text: MyStrings.canceledRides.tr),
                  ],
                ),
              ),

              // --- قائمة الرحلات ---
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: AllRideListSection(scrollController: scrollController),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
