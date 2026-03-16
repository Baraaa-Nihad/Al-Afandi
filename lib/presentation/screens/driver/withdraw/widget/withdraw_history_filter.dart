import 'package:ovoride/core/utils/debouncer.dart';
import 'package:flutter/material.dart';

import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_icons.dart';
import 'package:get/get.dart';
import 'package:ovoride/presentation/components/card/custom_app_card.dart';
import 'package:ovoride/presentation/components/image/my_local_image_widget.dart';
import 'package:ovoride/presentation/components/text-form-field/custom_text_field.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/data/controller/driver/withdraw/withdraw_history_controller.dart';

class WithdrawHistoryFilter extends StatefulWidget {
  const WithdrawHistoryFilter({super.key});

  @override
  State<WithdrawHistoryFilter> createState() => _WithdrawHistoryFilterState();
}

class _WithdrawHistoryFilterState extends State<WithdrawHistoryFilter> {
  final MyDeBouncer _debouncer = MyDeBouncer(
    delay: const Duration(milliseconds: 600),
  );
  @override
  Widget build(BuildContext context) {
    return GetBuilder<WithdrawHistoryController>(
      builder: (controller) => CustomAppCard(
        child: CustomTextField(
          controller: controller.searchController,
          onChanged: (value) {
            _debouncer.run(() {
              controller.filterData();
            });
          },
          hintText: MyStrings.searchByTrxId.tr,
          isShowSuffixIcon: true,
          suffixWidget: Padding(
            padding: const EdgeInsetsDirectional.only(end: Dimensions.space10),
            child: InkWell(
              onTap: () {
                controller.filterData();
              },
              child: MyLocalImageWidget(
                imagePath: MyIcons.searchIcon,
                width: Dimensions.space35,
                height: Dimensions.space35,
                imageOverlayColor: MyColor.getPrimaryColor(),
                boxFit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
