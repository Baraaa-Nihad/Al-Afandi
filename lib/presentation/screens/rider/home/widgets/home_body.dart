import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovoride/data/controller/rider/home/home_controller.dart';
import 'package:ovoride/presentation/screens/rider/home/section/ride_create_form.dart';
import 'package:ovoride/presentation/screens/rider/home/section/ride_service_section.dart';
import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/core/utils/style.dart';
import 'package:ovoride/core/utils/util.dart';
import 'package:ovoride/presentation/components/divider/custom_spacer.dart';

class HomeBody extends StatefulWidget {
  final HomeController controller;
  const HomeBody({super.key, required this.controller});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //SERVICES
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.controller.isLoading == false && widget.controller.appServicesList.isEmpty) ...[
              Container(
                decoration: BoxDecoration(
                  color: MyColor.getCardBgColor(),
                  boxShadow: MyUtils.getCardShadow(),
                  borderRadius: BorderRadius.circular(Dimensions.moreRadius),
                ),
                width: double.infinity,
                padding: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space16, vertical: Dimensions.space16),
                child: Center(
                  child: Text(
                    MyStrings.noServiceAvailable.tr,
                    style: regularDefault.copyWith(
                      color: MyColor.bodyTextColor,
                    ),
                  ),
                ),
              ),
            ] else ...[
              RideServiceSection(),
            ],
          ],
        ),
        spaceDown(Dimensions.space20),
        Container(
          decoration: BoxDecoration(
            color: MyColor.getCardBgColor(),
            boxShadow: MyUtils.getCardShadow(),
            borderRadius: BorderRadius.circular(Dimensions.moreRadius),
          ),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.space16,
            vertical: Dimensions.space16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RideCreateForm(),
              spaceDown(Dimensions.space15),
            ],
          ),
        ),
        spaceDown(Dimensions.space50 + 20),
      ],
    );
  }
}
