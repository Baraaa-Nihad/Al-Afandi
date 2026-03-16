import 'package:flutter/material.dart';
import 'package:ovoride/core/helper/string_format_helper.dart';
import 'package:ovoride/data/controller/driver/transaction/transactions_controller.dart';
import 'package:get/get.dart';
import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/style.dart';
import 'package:ovoride/presentation/components/bottom-sheet/custom_bottom_sheet.dart';
import 'package:ovoride/presentation/components/row_widget/bottom_sheet_top_row.dart';

void showTrxBottomSheet(
  List<String>? list,
  int callFrom,
  String header, {
  required BuildContext context,
}) {
  if (list != null && list.isNotEmpty) {
    CustomBottomSheet(
      bgColor: MyColor.getScreenBgColor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BottomSheetTopRow(header: header, bgColor: MyColor.colorWhite),
          SizedBox(
            child: ListView.builder(
              itemCount: list.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      String selectedValue = list[index];
                      final controller = Get.find<TransactionsController>();

                      if (callFrom == 1) {
                        controller.changeSelectedTrxType(selectedValue);
                        controller.filterData();
                      } else if (callFrom == 2) {
                        controller.changeSelectedRemark(selectedValue);
                        controller.filterData();
                      }

                      Navigator.pop(context);
                      FocusScopeNode currentFocus = FocusScope.of(context);

                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: MyColor.getCardBgColor(),
                      ),
                      child: Text(
                        ' ${callFrom == 2 ? StringConverter.replaceUnderscoreWithSpace(list[index].capitalizeFirst ?? '') : list[index]}',
                        style: regularDefault.copyWith(
                          fontSize: Dimensions.fontDefault,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ).customBottomSheet(context);
  }
}
