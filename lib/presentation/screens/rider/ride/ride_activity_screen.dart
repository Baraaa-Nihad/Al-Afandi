import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/core/utils/style.dart'; // تأكد من استيراد ملف الستايبل
import 'package:ovoride/data/controller/rider/ride/all_ride_controller.dart';
import 'package:ovoride/presentation/screens/rider/ride/section/all_rides_list_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RiderRideActivityScreen extends StatefulWidget {
  final VoidCallback? onBackPress;
  const RiderRideActivityScreen({super.key, this.onBackPress});

  @override
  State<RiderRideActivityScreen> createState() => _RiderRideActivityScreenState();
}

class _RiderRideActivityScreenState extends State<RiderRideActivityScreen> with SingleTickerProviderStateMixin {
  ScrollController scrollController = ScrollController();
  static const int totalTabs = 3;

  void scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (Get.find<AllRideController>().hasNext()) {
        Get.find<AllRideController>().getAllRide();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    var controller = Get.find<AllRideController>();
    controller.tabController = TabController(length: totalTabs, vsync: this, initialIndex: controller.selectedTab);

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
      // لون خلفية هادئ جداً ليبرز البطاقات البيضاء
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: GetBuilder<AllRideController>(
          builder: (controller) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- الجزء العلوي الإبداعي (Header) ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(Dimensions.space20, Dimensions.space20, Dimensions.space20, Dimensions.space10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // العنوان الجريء (Modern Large Title)
                      Text(
                        MyStrings.allRides.tr, // أو "مشاويري"
                        style: boldExtraLarge.copyWith(
                          fontSize: 28,
                          color: MyColor.getHeadingTextColor(),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: Dimensions.space5),
                      Text(
                        "تابع سجل رحلاتك وحالتها الحالية",
                        style: regularDefault.copyWith(color: MyColor.getGreyColor(), fontSize: 13),
                      ),
                    ],
                  ),
                ),

                // --- شريط التبويبات بنظام الكبسولة (Pill Tabs) ---
                Container(
                  height: 50,
                  margin: const EdgeInsets.symmetric(vertical: Dimensions.space5),
                  child: Stack(
                    children: [
                      // 👇 التاب بار نفسه
                      TabBar(
                        controller: controller.tabController,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        onTap: (i) => controller.changeTab(i),
                        indicatorColor: Colors.transparent,
                        dividerColor: Colors.transparent,
                        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                        tabs: [
                          _buildPillTab(MyStrings.allRides.tr, 0, controller.selectedTab),
                          _buildPillTab(MyStrings.activeRide.tr, 1, controller.selectedTab),
                          _buildPillTab(MyStrings.newRide.tr, 2, controller.selectedTab),
                          _buildPillTab(MyStrings.runningRide.tr, 3, controller.selectedTab),
                          _buildPillTab(MyStrings.completedRides.tr, 4, controller.selectedTab),
                          _buildPillTab(MyStrings.canceledRides.tr, 5, controller.selectedTab),
                        ],
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
                ),

                // --- مساحة القائمة ---
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.space15),
                    child: AllRidesListSection(
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

  // دالة بناء الكبسولة (The Pill Tab UI)
  Widget _buildPillTab(String text, int index, int selectedIndex) {
    bool isSelected = index == selectedIndex;
    return Tab(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? MyColor.getPrimaryColor() : MyColor.colorWhite,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? MyColor.getPrimaryColor() : MyColor.borderColor.withOpacity(0.5),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: MyColor.getPrimaryColor().withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Text(
          text,
          style: boldDefault.copyWith(
            color: isSelected ? MyColor.colorWhite : MyColor.getGreyColor(),
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
