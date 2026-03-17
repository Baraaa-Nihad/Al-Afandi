import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ovoride/core/route/route.dart';
import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/core/utils/style.dart';
import 'package:ovoride/data/controller/driver/dashboard/dashboard_controller.dart';
import 'package:ovoride/presentation/components/bottom-sheet/custom_bottom_sheet.dart';
import 'package:ovoride/presentation/components/divider/custom_spacer.dart';
import 'package:ovoride/presentation/components/no_data.dart';
import 'package:ovoride/presentation/components/shimmer/ride_shimmer.dart';
import 'package:ovoride/presentation/screens/driver/dashboard/dashboard_background.dart';
import 'package:ovoride/presentation/screens/driver/dashboard/widgets/driver_kyc_warning_section.dart';
import 'package:ovoride/presentation/screens/driver/dashboard/widgets/vahicle_kyc_warning_section.dart';
import 'package:ovoride/presentation/screens/driver/rides/home_screen/widget/home_app_bar.dart';
import 'package:ovoride/presentation/screens/driver/rides/home_screen/widget/offer_bid_bottom_sheet.dart';
import 'package:ovoride/core/helper/string_format_helper.dart';
import 'widget/new_ride_card.dart';

class HomeScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState>? dashBoardScaffoldKey;
  const HomeScreen({super.key, this.dashBoardScaffoldKey});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController scrollController = ScrollController();
  final double appBarSize = 90.0;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<DashBoardController>();
      controller.initialData(shouldLoad: true);
      scrollController.addListener(_scrollListener);
    });
  }

  void _scrollListener() {
    final controller = Get.find<DashBoardController>();
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (controller.hasNext()) {
        controller.loadData();
      }
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashBoardController>(
      builder: (controller) => DashboardBackground(
        child: Scaffold(
          extendBody: true,
          backgroundColor: MyColor.transparentColor,
          appBar: _buildAppBar(controller),
          body: RefreshIndicator(
            edgeOffset: 80,
            backgroundColor: MyColor.colorWhite,
            color: MyColor.primaryColor,
            onRefresh: () async => controller.initialData(shouldLoad: true),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              controller: scrollController,
              slivers: [
                _buildKYCSections(),
                if (!controller.isLoading) _buildRunningRideSection(controller),
                _buildRideListSection(controller),
                const SliverToBoxAdapter(child: SizedBox(height: Dimensions.space100)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Widgets แยก (Helper Methods) ---

  PreferredSize _buildAppBar(DashBoardController controller) {
    return PreferredSize(
      preferredSize: Size.fromHeight(appBarSize),
      child: HomeScreenAppBar(controller: controller),
    );
  }

  Widget _buildKYCSections() {
    return const SliverToBoxAdapter(
      child: Column(
        children: [
          SizedBox(height: 10),
          DriverKYCWarningSection(),
          SizedBox(height: 2),
          VehicleKYCWarningSection(),
        ],
      ),
    );
  }

  Widget _buildRunningRideSection(DashBoardController controller) {
    if (controller.runningRide == null) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: Dimensions.space10),
        padding: const EdgeInsets.only(bottom: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              MyStrings.runningRide.tr,
              style: semiBoldLarge.copyWith(color: MyColor.primaryColor, fontSize: 16),
            ),
            const SizedBox(height: 10),
            NewRideCardWidget(
              isActive: true,
              ride: controller.runningRide!,
              currency: controller.currencySym,
              driverImagePath: '${controller.userImagePath}/${controller.runningRide?.user?.avatar}',
              press: () => Get.toNamed(RouteHelper.driverRideDetailsScreen, arguments: controller.runningRide!.id),
            ).animate(onPlay: (c) => c.repeat()).shakeX(duration: 1000.ms, delay: 4000.ms, hz: 4),
            spaceDown(Dimensions.space10),
            if (controller.rideList.isNotEmpty) ...[
              Text(
                MyStrings.newRide.tr,
                style: regularDefault.copyWith(color: MyColor.colorBlack, fontSize: 18),
              ),
              spaceDown(Dimensions.space10),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRideListSection(DashBoardController controller) {
    if (controller.isLoading) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.space16),
          child: Column(
            children: List.generate(
                8,
                (index) => const Padding(
                      padding: EdgeInsets.only(bottom: Dimensions.space10),
                      child: RideShimmer(),
                    )),
          ),
        ),
      );
    }

    if (controller.rideList.isEmpty) {
      return SliverToBoxAdapter(
        child: NoDataWidget(
          text: MyStrings.noRideFoundInYourArea.tr,
          isRide: true,
          margin: controller.runningRide?.id != "-1" ? 4 : 8,
        ),
      );
    }

    return SliverList.separated(
      itemCount: controller.rideList.length + (controller.hasNext() ? 1 : 0),
      separatorBuilder: (context, index) => spaceDown(Dimensions.space10),
      itemBuilder: (context, index) {
        if (index == controller.rideList.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.space16),
            child: RideShimmer(),
          );
        }

        final ride = controller.rideList[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.space16),
          child: NewRideCardWidget(
            isActive: true,
            ride: ride,
            currency: controller.currencySym,
            driverImagePath: '${controller.userImagePath}/${ride.user?.avatar}',
            press: () {
              controller.updateMainAmount(StringConverter.formatDouble(ride.amount.toString()));
              CustomBottomSheet(child: OfferBidBottomSheet(ride: ride)).customBottomSheet(context);
            },
          ),
        );
      },
    );
  }
}
