import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/core/utils/util.dart';
import 'package:ovoride/data/controller/rider/payment_history/payment_history_controller.dart';
import 'package:ovoride/presentation/components/annotated_region/annotated_region_widget.dart';
import 'package:ovoride/presentation/components/app-bar/custom_appbar.dart';
import 'package:ovoride/presentation/components/custom_loader/custom_loader.dart';
import 'package:ovoride/presentation/components/no_data.dart';
import 'package:ovoride/presentation/components/shimmer/transaction_card_shimmer.dart';
import 'package:ovoride/presentation/screens/rider/payment_history/widget/custom_payment_card.dart';

class RiderPaymentHistoryScreen extends StatefulWidget {
  const RiderPaymentHistoryScreen({super.key});

  @override
  State<RiderPaymentHistoryScreen> createState() => _RiderPaymentHistoryScreenState();
}

class _RiderPaymentHistoryScreenState extends State<RiderPaymentHistoryScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<PaymentHistoryController>();
      controller.initData();
      scrollController.addListener(_scrollListener);
    });
  }

  void _scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      final controller = Get.find<PaymentHistoryController>();
      if (controller.hasNext()) {
        controller.loadTransaction();
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
    return GetBuilder<PaymentHistoryController>(
      builder: (controller) => AnnotatedRegionWidget(
        child: Scaffold(
          backgroundColor: MyColor.secondaryScreenBgColor,
          appBar: CustomAppBar(
            isTitleCenter: false,
            elevation: 0.5,
            title: MyStrings.payment,
          ),
          body: RefreshIndicator(
            color: MyColor.primaryColor,
            backgroundColor: MyColor.colorWhite,
            onRefresh: () async {
              controller.initData(shouldLoad: true);
            },
            child: _buildUI(controller),
          ),
        ),
      ),
    );
  }

  Widget _buildUI(PaymentHistoryController controller) {
    // حالة التحميل الأولية
    if (controller.isLoading) {
      return ListView.separated(
        itemCount: 10,
        padding: const EdgeInsets.all(Dimensions.space15),
        separatorBuilder: (context, index) => const SizedBox(height: Dimensions.space12),
        itemBuilder: (context, index) => _shimmerContainer(),
      );
    }

    // حالة عدم وجود بيانات
    if (controller.transactionList.isEmpty) {
      return const Center(child: NoDataWidget(text: MyStrings.noTrxFound));
    }

    // القائمة الفعلية
    return ListView.separated(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space20),
      itemCount: controller.transactionList.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: Dimensions.space12),
      itemBuilder: (context, index) {
        if (index == controller.transactionList.length) {
          return controller.hasNext()
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: Dimensions.space15),
                  child: CustomLoader(),
                )
              : const SizedBox(height: Dimensions.space20);
        }

        // استخدام الكارد الأصلي مع تحسين بسيط في الحاوية الخارجية لجمالية التصميم
        return Container(
          decoration: BoxDecoration(
            boxShadow: MyUtils.getCardShadow(),
            borderRadius: BorderRadius.circular(Dimensions.mediumRadius),
          ),
          child: RiderCustomPaymentCard(
            index: index,
            expandIndex: controller.expandIndex,
          ),
        );
      },
    );
  }

  Widget _shimmerContainer() {
    return Container(
      padding: const EdgeInsets.all(Dimensions.space15),
      decoration: BoxDecoration(
        color: MyColor.getCardBgColor(),
        borderRadius: BorderRadius.circular(Dimensions.mediumRadius),
        boxShadow: MyUtils.getCardShadow(),
      ),
      child: const TransactionCardShimmer(),
    );
  }
}
