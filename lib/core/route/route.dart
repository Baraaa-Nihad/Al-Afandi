import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ovoride/core/helper/shared_preference_helper.dart';
import 'package:ovoride/data/model/deposit/deposit_insert_response_model.dart';
import 'package:ovoride/data/model/global/user/global_driver_model.dart';
import 'package:ovoride/data/model/global/user/global_user_model.dart';
import 'package:ovoride/data/services/push_notification_service.dart';

// ── Shared screens ──
import 'package:ovoride/presentation/screens/driver/account/change-password/change_password_screen.dart';
import 'package:ovoride/presentation/screens/shared/auth/email_verification_page/email_verification_screen.dart';
import 'package:ovoride/presentation/screens/shared/auth/forget_password/forget_password/forget_password.dart';
import 'package:ovoride/presentation/screens/rider/auth/forget_password/forget_password/forget_password.dart' as riderForgetPw;
import 'package:ovoride/presentation/screens/rider/auth/forget_password/verify_forget_password/verify_forget_password_screen.dart' as riderVerifyForgetPw;
import 'package:ovoride/presentation/screens/rider/auth/forget_password/reset_password/reset_password_screen.dart' as riderResetPw;

import 'package:ovoride/presentation/screens/shared/auth/forget_password/reset_password/reset_password_screen.dart';
import 'package:ovoride/presentation/screens/shared/auth/forget_password/verify_forget_password/verify_forget_password_screen.dart';
import 'package:ovoride/presentation/screens/shared/auth/login/login_screen.dart';
import 'package:ovoride/presentation/screens/rider/auth/login/login_screen.dart' as riderLogin;
import 'package:ovoride/presentation/screens/rider/auth/registration/registration_screen.dart' as riderRegistration;
import 'package:ovoride/presentation/screens/rider/auth/email_verification/email_verification_screen.dart' as riderEmailVerif;
import 'package:ovoride/presentation/screens/rider/auth/sms_verification/sms_verification_screen.dart' as riderSmsVerif;
import 'package:ovoride/presentation/screens/rider/auth/profile_complete/profile_complete_screen.dart' as riderProfileComplete;
import 'package:ovoride/presentation/screens/shared/auth/profile_complete/profile_complete_screen.dart';
import 'package:ovoride/presentation/screens/shared/auth/registration/registration_screen.dart';
import 'package:ovoride/presentation/screens/shared/auth/sms_verification_page/sms_verification_screen.dart';
import 'package:ovoride/presentation/screens/driver/edit_profile/edit_profile_screen.dart';
import 'package:ovoride/presentation/screens/shared/faq/faq_screen.dart';
import 'package:ovoride/presentation/screens/shared/image_preview/preview_image_screen.dart';
import 'package:ovoride/presentation/screens/shared/language/language_screen.dart';
import 'package:ovoride/presentation/screens/shared/maintenance/maintanance_screen.dart';
import 'package:ovoride/presentation/screens/shared/onbaord/onboard_intro_screen.dart';
import 'package:ovoride/presentation/screens/shared/privacy_policy/privacy_policy_screen.dart';
import 'package:ovoride/presentation/screens/driver/profile/profile_screen.dart';
import 'package:ovoride/presentation/screens/shared/profile_and_settings/profile_and_settings_screen.dart';
import 'package:ovoride/presentation/screens/shared/splash/splash_screen.dart';
import 'package:ovoride/presentation/screens/driver/support_ticket/new_ticket_screen/add_new_ticket_screen.dart';
import 'package:ovoride/presentation/screens/driver/support_ticket/support_ticket_screen.dart';
import 'package:ovoride/presentation/screens/driver/support_ticket/ticket_details/ticket_details_screen.dart';

// Driver screens
import 'package:ovoride/presentation/screens/driver/ride_history/ride_activity_screen.dart' as driver_ride_history;
import 'package:ovoride/presentation/screens/driver/ride_details/ride_details_screen.dart' as driver_ride_details;
import 'package:ovoride/presentation/screens/driver/payment_history/payment_history_screen.dart' as driver_payment_history;
import 'package:ovoride/presentation/screens/driver/review/my_review_history_screen.dart' as driver_my_review;
import 'package:ovoride/presentation/screens/driver/review/user_review_history_screen.dart' as driver_user_review;
import 'package:ovoride/presentation/screens/driver/inbox/ride_message_screen.dart' as driver_inbox;

// Rider screens
import 'package:ovoride/presentation/screens/rider/ride/ride_activity_screen.dart' as rider_ride_activity;
import 'package:ovoride/presentation/screens/rider/ride/ride_details_screen.dart' as rider_ride_details;
import 'package:ovoride/presentation/screens/rider/payment_history/payments_history_screen.dart' as rider_payment_history;
import 'package:ovoride/presentation/screens/rider/review/my_review_history_screen.dart' as rider_my_review;
import 'package:ovoride/presentation/screens/rider/review/driver_review_history_screen.dart' as rider_driver_review;
import 'package:ovoride/presentation/screens/rider/review/ride_review_screen.dart' as rider_ride_review;
import 'package:ovoride/presentation/screens/rider/dashboard/dashboard_screen.dart' as rider_dashboard;
import 'package:ovoride/presentation/screens/rider/home/home_screen.dart' as rider_home;
import 'package:ovoride/presentation/screens/rider/account/profile_screen.dart' as rider_profile_screen;
import 'package:ovoride/presentation/screens/rider/support_ticket/support_ticket_screen.dart' as rider_support;
import 'package:ovoride/presentation/screens/rider/support_ticket/new_ticket_screen/add_new_ticket_screen.dart' as rider_new_ticket;
import 'package:ovoride/presentation/screens/rider/support_ticket/ticket_details/ticket_details_screen.dart' as rider_ticket_details;
import 'package:ovoride/presentation/screens/rider/account/edit_profile_screen.dart' as rider_edit_profile_screen;

import 'package:ovoride/presentation/screens/driver/user_role/user_role_screen.dart';
import 'package:ovoride/presentation/screens/driver/dashboard/dashboard_screen.dart';
import 'package:ovoride/presentation/screens/driver/deposits/deposit_webview/my_webview_screen.dart';
import 'package:ovoride/presentation/screens/driver/deposits/deposits_screen.dart';
import 'package:ovoride/presentation/screens/driver/deposits/new_deposit/new_deposit_screen.dart';
import 'package:ovoride/presentation/screens/driver/driver_profile_verification/driver_profile_verification_screen.dart';
import 'package:ovoride/presentation/screens/driver/my_wallet/my_wallet_screen.dart';
import 'package:ovoride/presentation/screens/driver/transaction/transactions_screen.dart';
import 'package:ovoride/presentation/screens/driver/two_factor_screen/two_factor_setup_screen.dart';
import 'package:ovoride/presentation/screens/driver/vehicle_verification/vehicle_verification_screen.dart';
import 'package:ovoride/presentation/screens/driver/withdraw/add_withdraw_screen/add_withdraw_method_screen.dart';
import 'package:ovoride/presentation/screens/driver/withdraw/confirm_withdraw_screen/withdraw_confirm_screen.dart';
import 'package:ovoride/presentation/screens/driver/withdraw/withdraw_history/withdraw_screen.dart';
import 'package:ovoride/presentation/screens/shared/auth/two_factor_screen/two_factor_verification_screen.dart';
import 'package:ovoride/presentation/screens/rider/ride_bid_list/ride_bid_list_screen.dart';
import 'package:ovoride/presentation/screens/rider/payment/payment_screen.dart';
import 'package:ovoride/presentation/screens/rider/coupon/coupon_screen.dart';
import 'package:ovoride/presentation/screens/rider/location/screen/locationpicker/location_picker_screen.dart';
import 'package:ovoride/presentation/screens/rider/location/screen/locationpicker/location_edit_screen.dart';
import 'package:ovoride/presentation/screens/rider/web_view/web_view_screen.dart' as rider_web_view;

import '../../data/services/api_client.dart';

class RouteHelper {
  // ── Shared ──
  static String getLoginScreen() {
    final prefs = Get.find<SharedPreferences>();
    final role = prefs.getString(SharedPreferenceHelper.userRoleKey) ?? 'driver';
    return role == 'rider' ? riderLoginScreen : loginScreen;
  }

  static const String splashScreen = "/splash_screen";
  static const String onboardScreen = "/onboard_screen";
  static const String userRoleScreen = "/user_role_screen";
  static const String loginScreen = "/login_screen";
  static const String riderLoginScreen = "/rider_login_screen";
  static const String forgotPasswordScreen = "/forgot_password_screen";
  static const String changePasswordScreen = "/change_password_screen";
  static const String registrationScreen = "/registration_screen";
  static const String riderRegistartionScreen = "/rider_registration_screen";
  static const String profileCompleteScreen = "/profile_complete_screen";
  static const String riderProfileCompleteScreen = "/rider_profile_complete_screen";
  static const String emailVerificationScreen = "/verify_email_screen";
  static const String riderEmailVerificationScreen = "/rider_verify_email_screen";
  static const String riderSmsVerificationScreen = "/rider_verify_sms_screen";
  static const String smsVerificationScreen = "/verify_sms_screen";
  static const String verifyPassCodeScreen = "/verify_pass_code_screen";
  static const String resetPasswordScreen = "/reset_pass_screen";
  static const String riderForgetPasswordScreen = "/rider_forget_password_screen";
  static const String riderVerifyForgetPasswordScreen = "/rider_verify_forget_password_screen";
  static const String riderResetPasswordScreen = "/rider_reset_password_screen";
  static const String profileScreen = "/profile_screen";
  static const String riderProfileScreen = "/rider_profile_screen";
  static const String riderEditProfileScreen = "/rider_edit_profile_screen";
  static const String profileAndSettingsScreen = "/profile_and_settings_screen";
  static const String editProfileScreen = "/edit_profile_screen";
  static const String privacyScreen = "/privacy-screen";
  static const String languageScreen = '/language_screen';
  static const String faqScreen = "/faq-screen";
  static const String maintenanceScreen = '/maintenance_screen';
  static const String previewImageScreen = "/preview-image-screen";
  static const String paymentHistoryScreen = '/payment_history_screen';
  static const String riderPaymentHistoryScreen = '/rider_payment_history_screen';
  static const String supportTicketScreen = '/support_ticket_screen';
  static const String riderSupportTicketScreen = '/rider_support_ticket_screen';
  static const String riderNewTicketScreen = '/rider_new_ticket_screen';
  static const String riderTicketDetailsScreen = '/rider_ticket_details_screen';
  static const String createSupportTicketScreen = '/create_support_ticket_screen';
  static const String supportTicketDetailsScreen = '/support_ticket_details_screen';
  static const String notificationScreen = "/notification_screen";
  static const String rideMessageScreen = '/inbox_message_screen';

  // ── Driver-only ──
  static const String dashboard = "/dashboard_screen";
  static const String twoFactorScreen = "/two-factor-screen";
  static const String twoFactorSetupScreen = "/two-factor-setup-screen";
  static const String transactionHistoryScreen = "/transaction_history_screen";
  static const String myWalletScreen = "/my_wallet_screen";
  static const String withdrawScreen = "/withdraw-screen";
  static const String newWithdrawScreen = "/new-withdraw-method";
  static const String withdrawConfirmScreenScreen = "/withdraw-preview-screen";
  static const String depositsScreen = "/deposits";
  static const String newDepositScreenScreen = "/deposits_money";
  static const String depositWebViewScreen = '/deposit_webView';
  static const String vehicleVerificationScreen = '/vehicle_verification_screen';
  static const String driverProfileVerificationScreen = '/driver_verification_screen';
  static const String driverRideActivityScreen = '/driver_ride_activity_screen';
  static const String driverRideDetailsScreen = '/driver_ride_details_screen';
  static const String myReviewScreen = '/driver_review_screen';
  static const String riderMyReviewScreen = '/rider_my_review_screen';
  static const String userReviewScreen = '/user_review_screen';
  static const String addMoneyHistoryScreen = "/add_money_history_screen";

  // ── Rider-only ──
  static const String riderDashboard = "/rider_dashboard";
  static const String homeScreen = '/rider_home_screen';
  static const String rideActivityScreen = '/rider_ride_screen';
  static const String riderRideDetailsScreen = '/rider_ride_details_screen';
  static const String rideBidScreen = '/ride_bid_screen';
  static const String paymentScreen = '/payment_screen';
  static const String rideReviewScreen = '/ride_review_screen';
  static const String couponScreen = '/coupon_screen';
  static const String locationPickUpScreen = '/location_pickup_screen';
  static const String editLocationPickUpScreen = '/edit_location_pickup_screen';
  static const String webViewScreen = '/rider_web_view_screen';
  static const String driverReviewScreen = '/driver_review_history_screen';

  List<GetPage> routes = [
    // ── Shared routes ──
    GetPage(name: splashScreen, page: () => const SplashScreen()),
    GetPage(name: onboardScreen, page: () => const OnBoardIntroScreen()),
    GetPage(name: userRoleScreen, page: () => const UserRoleScreen()),
    GetPage(name: loginScreen, page: () => const LoginScreen()),
    GetPage(name: riderRegistartionScreen, page: () => const riderRegistration.RegistrationScreen()),
    GetPage(name: riderLoginScreen, page: () => const riderLogin.LoginScreen()),
    GetPage(name: forgotPasswordScreen, page: () => const ForgetPasswordScreen()),
    GetPage(name: changePasswordScreen, page: () => const ChangePasswordScreen()),
    GetPage(name: registrationScreen, page: () => const RegistrationScreen()),
    GetPage(name: profileCompleteScreen, page: () => const ProfileCompleteScreen()),
    GetPage(name: riderProfileCompleteScreen, page: () => const riderProfileComplete.ProfileCompleteScreen()),
    GetPage(name: profileScreen, page: () => const ProfileScreen()),
    GetPage(name: riderProfileScreen, page: () => const rider_profile_screen.ProfileScreen()),
    GetPage(name: riderEditProfileScreen, page: () => const rider_edit_profile_screen.EditProfileScreen()),
    GetPage(name: editProfileScreen, page: () => const EditProfileScreen()),
    GetPage(
      name: profileAndSettingsScreen,
      page: () => const ProfileAndSettingsScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(name: rideMessageScreen, page: () => driver_inbox.RideMessageScreen(rideID: '-1')),
    GetPage(name: languageScreen, page: () => const LanguageScreen()),
    GetPage(name: paymentHistoryScreen, page: () => const driver_payment_history.PaymentHistoryScreen()),
    GetPage(name: riderPaymentHistoryScreen, page: () => const rider_payment_history.RiderPaymentHistoryScreen()),
    GetPage(name: privacyScreen, page: () => const PrivacyPolicyScreen()),
    GetPage(name: faqScreen, page: () => const FaqScreen()),
    GetPage(name: createSupportTicketScreen, page: () => const AddNewTicketScreen()),
    GetPage(name: supportTicketScreen, page: () => const SupportTicketScreen()),
    GetPage(name: riderSupportTicketScreen, page: () => const rider_support.SupportTicketScreen()),
    GetPage(name: riderNewTicketScreen, page: () => const rider_new_ticket.AddNewTicketScreen()),
    GetPage(name: riderTicketDetailsScreen, page: () => const rider_ticket_details.TicketDetailsScreen()),
    GetPage(name: supportTicketDetailsScreen, page: () => const TicketDetailsScreen()),
    GetPage(name: previewImageScreen, page: () => PreviewImageScreen(url: Get.arguments)),
    GetPage(name: maintenanceScreen, page: () => MaintenanceScreen()),
    GetPage(name: smsVerificationScreen, page: () => const SmsVerificationScreen()),
    GetPage(name: riderSmsVerificationScreen, page: () => const riderSmsVerif.SmsVerificationScreen()),
    GetPage(name: riderEmailVerificationScreen, page: () => const riderEmailVerif.EmailVerificationScreen()),
    GetPage(name: verifyPassCodeScreen, page: () => const VerifyForgetPassScreen()),
    GetPage(name: resetPasswordScreen, page: () => const ResetPasswordScreen()),
    GetPage(name: riderForgetPasswordScreen, page: () => const riderForgetPw.ForgetPasswordScreen()),
    GetPage(name: riderVerifyForgetPasswordScreen, page: () => riderVerifyForgetPw.VerifyForgetPassScreen()),
    GetPage(name: riderResetPasswordScreen, page: () => riderResetPw.ResetPasswordScreen()),

    // ── Driver-only routes ──
    GetPage(
      name: dashboard,
      page: () => const DashBoardScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: driverRideActivityScreen,
      page: () => driver_ride_history.RideActivityScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: driverRideDetailsScreen,
      page: () => driver_ride_details.RideDetailsScreen(rideId: Get.arguments),
    ),
    GetPage(
      name: myWalletScreen,
      page: () => const MyWalletScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(name: withdrawScreen, page: () => const WithdrawScreen()),
    GetPage(name: newWithdrawScreen, page: () => const AddWithdrawMethod()),
    GetPage(name: withdrawConfirmScreenScreen, page: () => const WithdrawConfirmScreen()),
    GetPage(name: transactionHistoryScreen, page: () => const TransactionsScreen()),
    GetPage(name: twoFactorScreen, page: () => TwoFactorVerificationScreen()),
    GetPage(name: twoFactorSetupScreen, page: () => const TwoFactorSetupScreen()),
    GetPage(name: vehicleVerificationScreen, page: () => const VehicleVerificationScreen()),
    GetPage(name: driverProfileVerificationScreen, page: () => const DriverProfileVerificationScreen()),
    GetPage(
      name: depositWebViewScreen,
      page: () => MyWebViewScreen(depositInsertData: Get.arguments as DepositInsertData),
    ),
    GetPage(name: depositsScreen, page: () => const DepositsScreen()),
    GetPage(name: newDepositScreenScreen, page: () => const NewDepositScreen()),
    GetPage(name: myReviewScreen, page: () => driver_my_review.MyReviewHistoryScreen()),
    GetPage(name: userReviewScreen, page: () => driver_user_review.UserReviewHistory()),
    GetPage(
      name: emailVerificationScreen,
      page: () => EmailVerificationScreen(),
    ),

    // ── Rider-only routes ──
    GetPage(
      name: riderDashboard,
      page: () => rider_dashboard.RiderDashBoardScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(name: homeScreen, page: () => rider_home.RiderHomeScreen()),
    GetPage(
      name: rideActivityScreen,
      page: () => rider_ride_activity.RiderRideActivityScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: riderRideDetailsScreen,
      page: () => rider_ride_details.RiderRideDetailsScreen(rideId: Get.arguments.toString()),
    ),
    GetPage(
      name: rideBidScreen,
      page: () => const RideBidListScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: paymentScreen,
      page: () => const PaymentScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: rideReviewScreen,
      page: () => rider_ride_review.RideReviewScreen(rideId: Get.arguments),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: couponScreen,
      page: () => const CouponScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: driverReviewScreen,
      page: () => rider_driver_review.DriverReviewHistoryScreen(driverId: Get.arguments),
    ),
    GetPage(
      name: riderMyReviewScreen,
      page: () => rider_my_review.RiderMyReviewHistoryScreen(avgRating: Get.arguments.toString()),
    ),
    GetPage(
      name: webViewScreen,
      page: () => rider_web_view.RiderWebViewScreen(model: Get.arguments),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: locationPickUpScreen,
      page: () => LocationPickerScreen(pickupLocationForIndex: Get.arguments[0]),
    ),
    GetPage(
      name: editLocationPickUpScreen,
      page: () => EditLocationPickerScreen(selectedIndex: Get.arguments),
    ),
  ];

  // ── Driver login flow ──
  static Future<void> checkUserStatusAndGoToNextStep(
    GlobalDriverInfoModel? user, {
    bool isRemember = false,
    String accessToken = "",
    String tokenType = "",
  }) async {
    bool needEmailVerification = user?.ev == "1" ? false : true;
    bool needSmsVerification = user?.sv == '1' ? false : true;
    bool isTwoFactorEnable = user?.tv == '1' ? false : true;

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool(SharedPreferenceHelper.rememberMeKey, isRemember);
    await sharedPreferences.setString(SharedPreferenceHelper.userIdKey, user?.id.toString() ?? '-1');
    await sharedPreferences.setString(SharedPreferenceHelper.userEmailKey, user?.email ?? '');
    await sharedPreferences.setString(SharedPreferenceHelper.userPhoneNumberKey, user?.mobile ?? '');
    await sharedPreferences.setString(SharedPreferenceHelper.userNameKey, user?.username ?? '');
    await sharedPreferences.setString(SharedPreferenceHelper.userRoleKey, 'driver');

    if (accessToken.isNotEmpty) {
      await sharedPreferences.setString(SharedPreferenceHelper.accessTokenKey, accessToken);
      await sharedPreferences.setString(SharedPreferenceHelper.accessTokenType, tokenType);
      await sharedPreferences.setBool(SharedPreferenceHelper.rememberMeKey, true);
      Get.find<ApiClient>().initToken();
    }

    bool isProfileCompleteEnable = user?.profileComplete == '0';

    if (isProfileCompleteEnable) {
      Get.offAndToNamed(RouteHelper.profileCompleteScreen);
    } else if (needEmailVerification) {
      Get.offAndToNamed(RouteHelper.emailVerificationScreen);
    } else if (needSmsVerification) {
      Get.offAndToNamed(RouteHelper.smsVerificationScreen);
    } else if (isTwoFactorEnable) {
      Get.offAndToNamed(RouteHelper.twoFactorScreen);
    } else {
      PushNotificationService(apiClient: Get.find()).sendUserToken();
      Get.offAndToNamed(RouteHelper.dashboard);
    }
  }

  // ── Rider login flow ──
  static Future<void> checkRiderStatusAndGoToNextStep(
    GlobalUser? user, {
    bool isRemember = true,
    String accessToken = "",
    String tokenType = "",
  }) async {
    bool needEmailVerification = user?.ev == "1" ? false : true;
    bool needSmsVerification = user?.sv == '1' ? false : true;

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool(SharedPreferenceHelper.rememberMeKey, isRemember);
    await sharedPreferences.setString(SharedPreferenceHelper.userIdKey, user?.id.toString() ?? '-1');
    await sharedPreferences.setString(SharedPreferenceHelper.userEmailKey, user?.email ?? '');
    await sharedPreferences.setString(SharedPreferenceHelper.userPhoneNumberKey, user?.mobile ?? '');
    await sharedPreferences.setString(SharedPreferenceHelper.userNameKey, user?.username ?? '');
    await sharedPreferences.setString(SharedPreferenceHelper.userRoleKey, 'rider');

    if (accessToken.isNotEmpty) {
      await sharedPreferences.setString(SharedPreferenceHelper.accessTokenKey, accessToken);
      await sharedPreferences.setString(SharedPreferenceHelper.accessTokenType, tokenType);
      await sharedPreferences.setBool(SharedPreferenceHelper.rememberMeKey, true);
      Get.find<ApiClient>().initToken();
    }

    bool isProfileCompleteEnable = user?.profileComplete == '0';

    if (isProfileCompleteEnable) {
      Get.offAndToNamed(RouteHelper.riderProfileCompleteScreen);
    } else if (needEmailVerification) {
      Get.offAndToNamed(
        RouteHelper.riderEmailVerificationScreen,
        arguments: [needSmsVerification, isProfileCompleteEnable, false],
      );
    } else if (needSmsVerification) {
      Get.offAndToNamed(RouteHelper.riderSmsVerificationScreen);
    } else {
      PushNotificationService(apiClient: Get.find()).sendUserToken();
      Get.offAndToNamed(RouteHelper.riderDashboard);
    }
  }
}
