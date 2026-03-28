import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ovoride/data/controller/shared/common/theme_controller.dart';
import 'package:ovoride/data/controller/shared/localization/localization_controller.dart';
import 'package:ovoride/data/controller/shared/splash/splash_controller.dart';
import 'package:ovoride/data/repo/shared/auth/general_setting_repo.dart';
import 'package:ovoride/data/repo/shared/splash/splash_repo.dart';
import 'package:ovoride/data/services/api_client.dart';
// Rider repos
import 'package:ovoride/data/repo/rider/home/home_repo.dart';
import 'package:ovoride/data/repo/rider/refer/reference_repo.dart';
import 'package:ovoride/data/repo/rider/location/location_search_repo.dart';
import 'package:ovoride/data/repo/rider/payment/payment_repo.dart';
import 'package:ovoride/data/repo/rider/payment_history/payment_history_repo.dart';
import 'package:ovoride/data/repo/rider/ride/ride_repo.dart';
import 'package:ovoride/data/repo/rider/message/message_repo.dart';
import 'package:ovoride/data/repo/rider/coupon/coupon_repo.dart';
import 'package:ovoride/data/repo/rider/menu_repo/menu_repo.dart';
import 'package:ovoride/data/repo/rider/review/review_repo.dart';
import 'package:ovoride/data/repo/rider/account/profile_repo.dart' as riderProfile;
import 'package:ovoride/data/controller/rider/account/profile_controller.dart' as riderProfileCtrl;
// Rider controllers
import 'package:ovoride/data/controller/rider/home/home_controller.dart';
import 'package:ovoride/data/controller/rider/location/app_location_controller.dart';
import 'package:ovoride/data/controller/rider/payment_history/payment_history_controller.dart';
import 'package:ovoride/data/controller/rider/ride/all_ride_controller.dart';
import 'package:ovoride/data/controller/rider/map/ride_map_controller.dart';
import 'package:ovoride/data/controller/rider/review/review_controller.dart';
import 'package:ovoride/data/controller/rider/menu/my_menu_controller.dart';
import 'package:ovoride/data/controller/rider/account/profile_complete_controller.dart' as riderProfileCompleteCtrl;
import 'package:ovoride/data/repo/rider/auth/signup_repo.dart' as riderSignUp;
import 'package:ovoride/data/controller/rider/auth/registration_controller.dart' as riderRegistration;
// Driver repos (aliased to avoid name conflicts)
import 'package:ovoride/data/repo/driver/ride/ride_repo.dart' as driverRide;
import 'package:ovoride/data/repo/driver/review/review_repo.dart' as driverReview;
import 'package:ovoride/data/repo/driver/payment_history/payment_history_repo.dart' as driverPaymentHistory;
import 'package:ovoride/data/repo/driver/meassage/meassage_repo.dart' as driverMessage;

Future<Map<String, Map<String, String>>> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  Get.lazyPut(() => sharedPreferences, fenix: true);
  Get.lazyPut(() => ApiClient(sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => GeneralSettingRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => SplashRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => LocalizationController(sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => SplashController(repo: Get.find(), localizationController: Get.find()), fenix: true);
  Get.lazyPut(() => ThemeController(sharedPreferences: Get.find()), fenix: true);

  // Rider repos (no tag = rider by default)
  Get.lazyPut(() => HomeRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => ReferenceRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => LocationSearchRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => PaymentRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => PaymentHistoryRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => RideRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => MessageRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => CouponRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => MenuRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => ReviewRepo(apiClient: Get.find()), fenix: true);

// Rider controllers (no tag = rider by default)
  Get.lazyPut(() => AppLocationController(), fenix: true);
  Get.lazyPut(() => HomeController(homeRepo: Get.find(), appLocationController: Get.find()), fenix: true);
  Get.lazyPut(() => PaymentHistoryController(paymentRepo: Get.find()), fenix: true);
  Get.lazyPut(() => AllRideController(repo: Get.find()), fenix: true);
  Get.lazyPut(() => RideMapController(), fenix: true);
  Get.lazyPut(() => ReviewController(repo: Get.find()), fenix: true);
  Get.lazyPut(() => riderProfile.ProfileRepo(apiClient: Get.find()), fenix: true, tag: 'rider');
  Get.lazyPut(() => riderProfileCtrl.ProfileController(profileRepo: Get.find(tag: 'rider')), fenix: true, tag: 'rider');
  Get.lazyPut(() => MyMenuController(menuRepo: Get.find(), repo: Get.find()), fenix: true);
  Get.lazyPut(() => riderSignUp.RegistrationRepo(apiClient: Get.find()), fenix: true, tag: 'rider');
  Get.lazyPut(
    () => riderRegistration.RegistrationController(
      registrationRepo: Get.find(tag: 'rider'),
      generalSettingRepo: Get.find(),
      profileRepo: Get.find(tag: 'rider'),
    ),
    fenix: true,
    tag: 'rider',
  );
  // Driver repos with 'driver' tag
  Get.lazyPut(() => driverRide.RideRepo(apiClient: Get.find()), fenix: true, tag: 'driver');
  Get.lazyPut(() => driverReview.ReviewRepo(apiClient: Get.find()), fenix: true, tag: 'driver');
  Get.lazyPut(() => driverPaymentHistory.PaymentHistoryRepo(apiClient: Get.find()), fenix: true, tag: 'driver');
  Get.lazyPut(() => driverMessage.MessageRepo(apiClient: Get.find()), fenix: true, tag: 'driver');

  Map<String, Map<String, String>> language = {};
  language['en_US'] = {'': ''};

  return language;
}
