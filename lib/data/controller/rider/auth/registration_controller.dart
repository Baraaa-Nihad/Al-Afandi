import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/data/repo/rider/auth/signup_repo.dart';
import 'package:ovoride/data/repo/shared/auth/general_setting_repo.dart';
import 'package:ovoride/presentation/components/snack_bar/show_custom_snackbar.dart';

import 'package:ovoride/data/model/auth/sign_up_model/sign_up_model.dart';
import 'package:ovoride/data/model/user_post_model/user_post_model.dart';
import 'package:ovoride/data/model/country_model/country_model.dart';
import 'package:ovoride/data/model/rider/auth/authorization_response_model.dart';

import 'package:ovoride/data/repo/rider/account/profile_repo.dart';

import 'package:ovoride/core/route/route.dart';

class RegistrationController extends GetxController {
  final RegistrationRepo registrationRepo;
  final GeneralSettingRepo generalSettingRepo;
  final ProfileRepo profileRepo;

  RegistrationController({
    required this.registrationRepo,
    required this.generalSettingRepo,
    required this.profileRepo,
  });
  Future<void> initData() async {
    countryList = profileRepo.apiClient.getOperatingCountries();

    if (countryList.isNotEmpty) {
      selectedCountryData = countryList.first;
    }

    update();

    await _prepareInitialLocation();
  }

  /// =======================
  /// 🔹 Controllers (الأصلية)
  /// =======================
  TextEditingController fNameController = TextEditingController();
  TextEditingController lNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cPasswordController = TextEditingController();
  TextEditingController referNameController = TextEditingController();

  /// =======================
  /// 🔹 Controllers (المضافة)
  /// =======================
  TextEditingController userNameController = TextEditingController();
  TextEditingController mobileNoController = TextEditingController();
  TextEditingController referController = TextEditingController();

  /// =======================
  /// 🔹 Map + Location
  /// =======================
  final Completer<GoogleMapController> mapControllerCompleter = Completer<GoogleMapController>();

  GoogleMapController? googleMapController;
  LatLng? _cameraTarget;

  double selectedLatitude = 0;
  double selectedLongitude = 0;

  String selectedAddressText = '';
  String selectedStreetAddress = '';
  String selectedCity = '';
  String selectedState = '';
  String selectedZipCode = '';
  String selectedCountryName = '';

  bool hasConfirmedLocation = false;
  bool isProgrammaticMove = false;

  List<Countries> countryList = [];
  Countries selectedCountryData = Countries();

  /// =======================
  /// 🔹 UI State
  /// =======================
  bool agreeTC = false;
  bool submitLoading = false;

  /// =======================
  /// 🔹 INIT
  /// =======================

  /// =======================
  /// 🔹 REGISTER
  /// =======================
  Future<void> signUpUser() async {
    if (!agreeTC) {
      CustomSnackBar.error(errorList: [MyStrings.accept]);
      return;
    }

    submitLoading = true;
    update();

    final model = SignUpModel(
      firstName: fNameController.text.trim(),
      lastName: lNameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      refference: "",
      agree: agreeTC,
    );

    final response = await registrationRepo.registerUser(model);

    if (response.status?.toLowerCase() == 'success') {
      await completeProfileAfterRegister();
    } else {
      CustomSnackBar.error(
        errorList: response.message ?? [MyStrings.somethingWentWrong],
      );
    }

    submitLoading = false;
    update();
  }

  /// =======================
  /// 🔥 PROFILE COMPLETE
  /// =======================
  Future<void> completeProfileAfterRegister() async {
    if (!hasConfirmedLocation) {
      CustomSnackBar.error(errorList: ['حدد موقعك']);
      return;
    }

    final userPostModel = UserPostModel(
      image: null,
      firstname: fNameController.text.trim(),
      lastName: lNameController.text.trim(),
      mobile: mobileNoController.text.trim(),
      email: '',
      username: userNameController.text.trim(),
      countryCode: selectedCountryData.countryCode.toString(),
      country: selectedCountryData.country.toString(),
      mobileCode: selectedCountryData.dialCode.toString(),
      address: selectedStreetAddress.isNotEmpty ? selectedStreetAddress : selectedAddressText,
      state: selectedState,
      zip: selectedZipCode,
      city: selectedCity,
      refer: "",
    );

    final AuthorizationResponseModel response = await profileRepo.updateProfile(userPostModel, false);

    if (response.status == "success") {
      Get.offAllNamed(RouteHelper.riderDashboard);
    } else {
      CustomSnackBar.error(
        errorList: response.message ?? ['فشل الإكمال'],
      );
    }
  }

  /// =======================
  /// 🗺️ MAP
  /// =======================
  void onMapCreated(GoogleMapController controller) {
    googleMapController = controller;

    if (!mapControllerCompleter.isCompleted) {
      mapControllerCompleter.complete(controller);
    }
  }

  void onCameraMove(CameraPosition position) {
    _cameraTarget = position.target;
  }

  void onCameraIdle() {
    if (_cameraTarget == null) return;

    if (isProgrammaticMove) {
      isProgrammaticMove = false;
      return;
    }

    selectedLatitude = _cameraTarget!.latitude;
    selectedLongitude = _cameraTarget!.longitude;

    hasConfirmedLocation = true;

    _updateAddressFromCoordinates(
      latitude: selectedLatitude,
      longitude: selectedLongitude,
    );
  }

  Future<void> moveToCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition();

    selectedLatitude = position.latitude;
    selectedLongitude = position.longitude;

    await animateToSelectedLocation();
  }

  Future<void> animateToSelectedLocation() async {
    GoogleMapController controller;

    if (googleMapController != null) {
      controller = googleMapController!;
    } else {
      controller = await mapControllerCompleter.future;
    }

    isProgrammaticMove = true;

    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(selectedLatitude, selectedLongitude),
        16,
      ),
    );
  }

  /// =======================
  /// 📍 LOCATION INIT
  /// =======================
  Future<void> _prepareInitialLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        selectedAddressText = 'يرجى تشغيل خدمة الموقع';
        update();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        selectedAddressText = 'يرجى السماح بالوصول إلى الموقع';
        update();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      selectedLatitude = position.latitude;
      selectedLongitude = position.longitude;
      _cameraTarget = LatLng(selectedLatitude, selectedLongitude);
      hasConfirmedLocation = true;

      await _updateAddressFromCoordinates(
        latitude: selectedLatitude,
        longitude: selectedLongitude,
      );

      update();

      await Future.delayed(const Duration(milliseconds: 300));
      await animateToSelectedLocation();
    } catch (_) {
      selectedAddressText = 'تعذر تحديد موقعك الحالي';
      update();
    }
  }

  /// =======================
  /// 📍 ADDRESS
  /// =======================
  Future<void> _updateAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        selectedStreetAddress = place.street ?? '';
        selectedCity = place.locality ?? '';
        selectedState = place.administrativeArea ?? '';
        selectedZipCode = place.postalCode ?? '';

        selectedAddressText = "${selectedStreetAddress}, ${selectedCity}";
      }
    } catch (_) {}
  }

  /// =======================
  /// 🔹 DISPOSE
  /// =======================
  @override
  void onClose() {
    fNameController.dispose();
    lNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    cPasswordController.dispose();
    referNameController.dispose();

    userNameController.dispose();
    mobileNoController.dispose();

    googleMapController?.dispose();

    super.onClose();
  }
}
