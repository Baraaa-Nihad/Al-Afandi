import 'package:get/get.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/core/utils/style.dart';
import 'package:flutter/material.dart';
import 'package:ovoride/core/helper/shared_preference_helper.dart';
import 'package:ovoride/data/services/api_client.dart';
import 'package:ovoride/core/utils/util.dart';
import 'package:ovoride/presentation/components/divider/custom_spacer.dart';
import 'package:ovoride/presentation/components/text/header_text.dart';

import 'package:ovoride/core/route/route.dart';
import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_icons.dart';
import 'package:ovoride/presentation/components/image/custom_svg_picture.dart';

class AccountUserBalanceCard extends StatelessWidget {
  final String? balance;

  const AccountUserBalanceCard({super.key, this.balance});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final role = Get.find<ApiClient>().sharedPreferences.getString(SharedPreferenceHelper.userRoleKey) ?? 'driver';
        if (role == 'driver') {
          Get.toNamed(RouteHelper.myWalletScreen);
        }
      },
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(Dimensions.space20),
            decoration: BoxDecoration(
              color: MyColor.getPrimaryColor(),
              borderRadius: BorderRadius.circular(Dimensions.space20),
              boxShadow: MyUtils.getCardShadow(),
            ),
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomSvgPicture(
                      image: MyIcons.walletIcon,
                      color: MyColor.colorWhite,
                    ),
                    spaceSide(Dimensions.space10),
                    HeaderText(
                      text: MyStrings.walletBalance,
                      style: semiBoldDefault.copyWith(
                        color: MyColor.colorWhite,
                        fontSize: Dimensions.fontLarge,
                      ),
                    ),
                  ],
                ),
                spaceDown(Dimensions.space20),
                HeaderText(
                  text: "$balance",
                  style: boldLarge.copyWith(
                    color: MyColor.colorWhite,
                    fontSize: Dimensions.fontBig28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: Dimensions.space15,
            bottom: 0,
            child: CustomSvgPicture(
              image: MyIcons.arrowForward,
              color: MyColor.colorWhite,
              height: Dimensions.space30,
            ),
          ),
        ],
      ),
    );
  }
}
