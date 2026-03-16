import 'package:ovoride/core/utils/debouncer.dart';
import 'package:flutter/material.dart';

import 'package:ovoride/core/utils/my_icons.dart';
import 'package:get/get.dart';
import 'package:ovoride/presentation/components/card/custom_app_card.dart';
import 'package:ovoride/presentation/components/image/my_local_image_widget.dart';
import 'package:ovoride/presentation/components/text-form-field/custom_text_field.dart';
import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/data/controller/driver/deposit/deposit_history_controller.dart';

class DepositHistoryTop extends StatefulWidget {
  const DepositHistoryTop({super.key});

  @override
  State<DepositHistoryTop> createState() => _DepositHistoryTopState();
}

class _DepositHistoryTopState extends State<DepositHistoryTop> {
  final MyDeBouncer _debouncer = MyDeBouncer(
    delay: const Duration(milliseconds: 600),
  );
  @override
  Widget build(BuildContext context) {
    return GetBuilder<DepositController>(
      builder: (controller) => CustomAppCard(
        child: CustomTextField(
          controller: controller.searchController,
          onChanged: (value) {
            _debouncer.run(() {
              controller.searchDepositTrx();
            });
          },
          hintText: MyStrings.searchByTrxId.tr,
          isShowSuffixIcon: true,
          suffixWidget: Padding(
            padding: const EdgeInsetsDirectional.only(end: Dimensions.space10),
            child: InkWell(
              onTap: () {
                controller.searchDepositTrx();
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
