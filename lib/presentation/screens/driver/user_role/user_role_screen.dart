import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovoride/core/route/route.dart';
import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_images.dart';
import 'package:ovoride/core/utils/style.dart';
import 'package:ovoride/core/helper/shared_preference_helper.dart';
import 'package:ovoride/presentation/components/annotated_region/annotated_region_widget.dart';
import 'package:ovoride/presentation/components/divider/custom_spacer.dart';
import 'package:ovoride/presentation/screens/shared/auth/auth_background.dart';
import 'package:shared_preferences/shared_preferences.dart';


class UserRoleScreen extends StatelessWidget {
  const UserRoleScreen({super.key});

  Future<void> _selectRole(String role) async {
    final prefs = await SharedPreferences.getInstance();

    // حفظ الدور المختار وحالة الدخول لأول مرة لضمان عدم ظهور الشاشة مجدداً
    await prefs.setString(SharedPreferenceHelper.userRoleKey, role);
    await prefs.setBool('is_role_selected', true);

    if (role == 'driver') {
      Get.offAllNamed(RouteHelper.loginScreen);
    } else {
      Get.offAllNamed(RouteHelper.riderLoginScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegionWidget(
      statusBarColor: Colors.transparent,
      child: Scaffold(
        backgroundColor: MyColor.colorWhite,
        body: Column(
          children: [
            AuthBackgroundWidget(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.space20, vertical: Dimensions.space10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        spaceDown(Dimensions.space15),
                        // شعار Saro الجديد الموحد
                        Image.asset(
                          MyImages.appLogoWhite,
                          color: MyColor.colorWhite,
                          width: MediaQuery.of(context).size.width / 2.5,
                        ),
                        spaceDown(Dimensions.space20),
                        Text(
                          "عايز تكمل إزاي؟", // نص ترحيبي يتناسب مع الهوية البصرية
                          style: regularDefault.copyWith(
                            color: MyColor.colorWhite,
                            fontSize: Dimensions.fontLarge,
                          ),
                        ),
                        spaceDown(Dimensions.space40),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Transform.translate(
                offset: Offset(0, -Dimensions.space20),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: MyColor.colorWhite,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(Dimensions.radius25),
                      topRight: Radius.circular(Dimensions.radius25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: MyColor.colorBlack.withValues(alpha: 0.05),
                        offset: const Offset(0, -30),
                        blurRadius: 15,
                        spreadRadius: -3,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.space15,
                    vertical: Dimensions.space30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      spaceDown(Dimensions.space10),
                      Text(
                        "اختار دورك في Saro", // تخصيص العنوان باسم البراند الجديد
                        style: boldExtraLarge.copyWith(
                          color: MyColor.getTextColor(),
                          fontSize: 22,
                        ),
                      ),
                      spaceDown(Dimensions.space30),

                      // كارت الراكب - تم تحسين النصوص بناءً على رؤية "سارو" للراحة
                      _buildRoleCard(
                        icon: Icons.person_pin_circle_outlined,
                        title: "أنا راكب",
                        subtitle: "احجز مشوار لأي مكان وفي أي وقت بآمان وراحة.",
                        onTap: () => _selectRole('rider'),
                        isDriver: false,
                      ),

                      spaceDown(Dimensions.space25),

                      // كارت السائق - تم تحسين النص بناءً على مبدأ الربح والاستقلال
                      _buildRoleCard(
                        icon: Icons.directions_car_filled_outlined,
                        title: "أنا سواق",
                        subtitle: "اكسب فلوس وحقق أرباح بشروطك وبأقل عمولة.",
                        onTap: () => _selectRole('driver'),
                        isDriver: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDriver,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radius25),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(Dimensions.space20),
        decoration: BoxDecoration(
          color: MyColor.colorWhite,
          borderRadius: BorderRadius.circular(Dimensions.radius25),
          border: Border.all(
            color: isDriver
                ? Colors.amber.withValues(alpha: 0.4) // لمسة ذهبية للسائق توحي بالربح
                : MyColor.primaryColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          gradient: LinearGradient(
            // تدرج لوني خفيف للفخامة
            colors: [MyColor.colorWhite, isDriver ? Colors.amber.withValues(alpha: 0.03) : MyColor.primaryColor.withValues(alpha: 0.03)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: isDriver ? Colors.amber.withValues(alpha: 0.07) : MyColor.primaryColor.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(Dimensions.space12),
              decoration: BoxDecoration(
                color: isDriver ? Colors.amber.withValues(alpha: 0.1) : MyColor.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isDriver ? Colors.orange : MyColor.primaryColor,
                size: 32,
              ),
            ),
            spaceSide(Dimensions.space15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: boldLarge.copyWith(
                      color: isDriver ? Colors.orange.shade800 : MyColor.primaryColor,
                      fontSize: Dimensions.fontExtraLarge,
                    ),
                  ),
                  spaceDown(Dimensions.space5),
                  Text(
                    subtitle,
                    style: regularDefault.copyWith(
                      color: MyColor.getBodyTextColor(),
                      fontSize: Dimensions.fontDefault,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDriver ? Colors.orange : MyColor.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
