import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/core/utils/style.dart';
import 'package:ovoride/data/controller/driver/ride/all_ride/all_ride_controller.dart';
import 'package:ovoride/data/controller/driver/ride/ride_action/ride_action_controller.dart';
import 'package:ovoride/data/repo/driver/ride/ride_repo.dart';
import 'package:ovoride/presentation/screens/driver/ride_history/all_ride/all_ride_list_section.dart';

class RideActivityScreen extends StatefulWidget {
  final VoidCallback? onBackPress;

  const RideActivityScreen({
    super.key,
    this.onBackPress,
  });

  @override
  State<RideActivityScreen> createState() => _RideActivityScreenState();
}

class _RideActivityScreenState extends State<RideActivityScreen> with SingleTickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();
  static const int totalTabs = 6;

  void scrollListener() {
    if (!scrollController.hasClients) return;

    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent) {
      final controller = Get.find<AllRideController>(tag: 'driver');
      if (controller.hasNext()) {
        controller.getAllRide();
      }
    }
  }

  @override
  void initState() {
    super.initState();

    Get.put(RideRepo(apiClient: Get.find()), tag: 'driver');
    Get.put(RideActionController(repo: Get.find(tag: 'driver')));
    final controller = Get.put(AllRideController(repo: Get.find(tag: 'driver')), tag: 'driver');

    controller.tabController = TabController(
      length: totalTabs,
      vsync: this,
      initialIndex: controller.selectedTab < totalTabs ? controller.selectedTab : 0,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initialData(
        shouldLoading: true,
        tabID: controller.selectedTab < totalTabs ? controller.selectedTab : 0,
        rideType: "${Get.arguments ?? ""}",
      );

      scrollController.addListener(scrollListener);
    });
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();

    final controller = Get.find<AllRideController>(tag: 'driver');
    controller.tabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: GetBuilder<AllRideController>(
          tag: 'driver',
          builder: (controller) {
            final int selectedIndex = controller.selectedTab < totalTabs ? controller.selectedTab : 0;

            if (controller.tabController.index != selectedIndex) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;

                if (controller.tabController.length > selectedIndex && controller.tabController.index != selectedIndex) {
                  controller.tabController.animateTo(selectedIndex);
                }
              });
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Dimensions.space20,
                    Dimensions.space20,
                    Dimensions.space20,
                    Dimensions.space10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        MyStrings.allRides.tr,
                        style: boldExtraLarge.copyWith(
                          fontSize: 28,
                          color: MyColor.getHeadingTextColor(),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: Dimensions.space5),
                      Text(
                        "تابع سجل مشاويرك وحالتها الحالية",
                        style: regularDefault.copyWith(
                          color: MyColor.getGreyColor(),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Stack(
                  children: [
                    // الـ Container الأصلي الخاص بالـ TabBar
                    Container(
                      height: 60,
                      margin: const EdgeInsets.symmetric(vertical: Dimensions.space5),
                      child: TabBar(
                        controller: controller.tabController,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        physics: const BouncingScrollPhysics(),
                        indicatorColor: Colors.transparent,
                        dividerColor: Colors.transparent,
                        labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                        onTap: (i) => controller.changeTab(i),
                        tabs: [
                          _buildPillTab(MyStrings.allRide.tr, 0, selectedIndex),
                          _buildPillTab(MyStrings.acceptedRide.tr, 1, selectedIndex),
                          _buildPillTab(MyStrings.activeRide.tr, 2, selectedIndex),
                          _buildPillTab(MyStrings.runningRide.tr, 3, selectedIndex),
                          _buildPillTab(MyStrings.completedRides.tr, 4, selectedIndex),
                          _buildPillTab(MyStrings.canceledRides.tr, 5, selectedIndex),
                        ],
                      ),
                    ),

                    // التدرج اللوني من الجهة اليمنى (البداية)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: 30, // عرض منطقة التدرج
                      child: IgnorePointer(
                        // لضمان عدم حجب الضغط عن العناصر تحتها
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                MyColor.getCardBgColor(), // نفس لون خلفية الصفحة ليختفي التاب تحته
                                MyColor.getCardBgColor().withOpacity(0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // التدرج اللوني من الجهة اليسرى (النهاية)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      width: 30,
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                              colors: [
                                MyColor.getCardBgColor(),
                                MyColor.getCardBgColor().withOpacity(0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.space15,
                    ),
                    child: AllRideListSection(
                      scrollController: scrollController,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPillTab(String text, int index, int selectedIndex) {
    final bool isSelected = index == selectedIndex;

    return Tab(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? MyColor.getPrimaryColor() : MyColor.colorWhite,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? MyColor.getPrimaryColor() : MyColor.borderColor.withOpacity(0.5),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: MyColor.getPrimaryColor().withOpacity(0.30),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: boldDefault.copyWith(
            color: isSelected ? MyColor.colorWhite : MyColor.getGreyColor(),
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
