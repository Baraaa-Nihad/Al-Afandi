import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ovoride/core/helper/shared_preference_helper.dart';
import 'package:ovoride/core/helper/string_format_helper.dart';
import 'package:ovoride/core/route/route.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/data/model/country_model/country_model.dart';
import 'package:ovoride/data/model/profile/rider_profile_response_model.dart';
import 'package:ovoride/data/model/rider/auth/authorization_response_model.dart';
import 'package:ovoride/data/model/user_post_model/user_post_model.dart';
import 'package:ovoride/data/repo/rider/account/profile_repo.dart';
import 'package:ovoride/presentation/components/snack_bar/show_custom_snackbar.dart';

class ProfileCompleteController extends GetxController {
  final ProfileRepo profileRepo;

  ProfileCompleteController({required this.profileRepo});

  RiderProfileResponseModel model = RiderProfileResponseModel();
  RiderProfileResponseModel profileResponseModel = RiderProfileResponseModel();

  TextEditingController userNameController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileNoController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController referController = TextEditingController();
  TextEditingController searchCountryController = TextEditingController();

  FocusNode userNameFocusNode = FocusNode();
  FocusNode firstNameFocusNode = FocusNode();
  FocusNode lastNameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode mobileNoFocusNode = FocusNode();
  FocusNode countryFocusNode = FocusNode();

  bool isLoading = false;
  bool submitLoading = false;
  bool countryLoading = true;

  String imageUrl = '';
  File? imageFile;

  String emailData = '';
  String countryData = '';
  String countryCodeData = '';
  String phoneCodeData = '';
  String phoneData = '';
  String loginType = '';

  List<Countries> countryList = [];
  List<Countries> filteredCountries = [];
  Countries selectedCountryData = Countries();

  GoogleMapController? googleMapController;
  LatLng? _cameraTarget;

  double selectedLatitude = 33.5138;
  double selectedLongitude = 36.2765;

  String selectedAddressText = '';
  String selectedStreetAddress = '';
  String selectedCity = '';
  String selectedState = '';
  String selectedZipCode = '';
  String selectedCountryName = '';

  bool isMapReady = false;
  bool isFetchingLocation = false;
  bool isReverseGeocoding = false;
  bool hasConfirmedLocation = false;

  Future<void> initialData() async {
    countryList = profileRepo.apiClient.getOperatingCountries();
    if (countryList.isNotEmpty) {
      selectCountryData(countryList.first);
    }
    update();

    await _prepareInitialLocation();
  }

  void selectCountryData(Countries value) {
    selectedCountryData = value;
    update();
  }

  Future<void> loadProfileInfo() async {
    isLoading = true;
    update();

    try {
      profileResponseModel = await profileRepo.loadProfileInfo();

      if (profileResponseModel.data != null && profileResponseModel.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
        emailData = profileResponseModel.data?.user?.email ?? '';
        countryData = profileResponseModel.data?.user?.country ?? '';
        countryCodeData = profileResponseModel.data?.user?.countryCode ?? '';
        phoneData = profileResponseModel.data?.user?.mobile ?? '';
        loginType = '';
      }
    } catch (_) {
      // ignore
    }

    isLoading = false;
    update();
  }

  Future<void> _prepareInitialLocation() async {
    isFetchingLocation = true;
    update();

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        selectedAddressText = 'يرجى تشغيل خدمة الموقع ثم تحديد موقعك من الخريطة';
        isFetchingLocation = false;
        update();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        selectedAddressText = 'تم رفض إذن الموقع، يرجى تحديد موقعك يدويًا من الخريطة';
        isFetchingLocation = false;
        update();
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        selectedAddressText = 'إذن الموقع مرفوض نهائيًا، يرجى تحديد موقعك يدويًا من الخريطة';
        isFetchingLocation = false;
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

      await animateToSelectedLocation();
    } catch (_) {
      selectedAddressText = 'تعذر جلب موقعك الحالي، يمكنك تحديده يدويًا من الخريطة';
    }

    isFetchingLocation = false;
    update();
  }

  void onMapCreated(GoogleMapController controller) {
    print('MAP CREATED');

    googleMapController = controller;
    isMapReady = true;

    update();
  }

  void onCameraMove(CameraPosition position) {
    _cameraTarget = position.target;
    print('CAMERA MOVING: ${position.target.latitude}, ${position.target.longitude}');
  }

  void onCameraIdle() {
    print('CAMERA IDLE');

    if (_cameraTarget == null) return;

    selectedLatitude = _cameraTarget!.latitude;
    selectedLongitude = _cameraTarget!.longitude;

    hasConfirmedLocation = true;

    _updateAddressFromCoordinates(
      latitude: selectedLatitude,
      longitude: selectedLongitude,
    );

    update();
  }

  Future<void> moveToCurrentLocation() async {
    print('MOVE TO CURRENT LOCATION CLICKED');

    selectedLatitude = 24.7136;
    selectedLongitude = 46.6753;

    if (googleMapController != null) {
      await animateToSelectedLocation();
    } else {
      print('⏳ Map not ready yet');
    }
  }

  Future<void> animateToSelectedLocation() async {
    print('ANIMATE TO SELECTED LOCATION');

    if (googleMapController == null) {
      print('❌ googleMapController is NULL');
      return;
    }

    await googleMapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(selectedLatitude, selectedLongitude),
          zoom: 16,
        ),
      ),
    );
  }

  Future<void> _updateAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    isReverseGeocoding = true;
    update();

    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        selectedStreetAddress = [
          place.street,
          place.subLocality,
        ].where((e) => (e ?? '').trim().isNotEmpty).join(', ');

        selectedCity = (place.locality ?? '').trim();
        selectedState = (place.administrativeArea ?? '').trim();
        selectedZipCode = (place.postalCode ?? '').trim();
        selectedCountryName = (place.country ?? '').trim();

        selectedAddressText = [
          if (selectedStreetAddress.isNotEmpty) selectedStreetAddress,
          if (selectedCity.isNotEmpty) selectedCity,
          if (selectedState.isNotEmpty) selectedState,
        ].join('، ');

        selectedAddressText = selectedAddressText.trim();

        if (selectedAddressText.isEmpty) {
          selectedAddressText = 'تم تحديد الموقع بنجاح (${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)})';
        }

        if (selectedCountryData.country.toString().isEmpty && selectedCountryName.isNotEmpty) {
          final matchedCountry = countryList.where((country) {
            return country.country?.toLowerCase().trim() == selectedCountryName.toLowerCase().trim() || country.countryCode?.toLowerCase().trim() == selectedCountryName.toLowerCase().trim();
          }).toList();

          if (matchedCountry.isNotEmpty) {
            selectedCountryData = matchedCountry.first;
          }
        }
      } else {
        selectedAddressText = 'تم تحديد الموقع، لكن تعذر استخراج العنوان النصي';
      }
    } catch (_) {
      selectedAddressText = 'تم تحديد الموقع، لكن تعذر استخراج العنوان النصي';
    }

    isReverseGeocoding = false;
    update();
  }

  Future<void> updateProfile() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();

    if (!hasConfirmedLocation) {
      CustomSnackBar.error(
        errorList: ['يرجى تحديد موقعك على الخريطة قبل إكمال التسجيل'],
      );
      return;
    }

    if (selectedLatitude == 0 || selectedLongitude == 0) {
      CustomSnackBar.error(
        errorList: ['إحداثيات الموقع غير صالحة، يرجى تحديد موقعك مرة أخرى'],
      );
      return;
    }

    printD("model.username");

    submitLoading = true;
    update();

    final userPostModel = UserPostModel(
      image: null,
      firstname: firstName,
      lastName: lastName,
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

    final AuthorizationResponseModel responseModel = await profileRepo.updateProfile(userPostModel, false);

    if (responseModel.status == "success") {
      await profileRepo.apiClient.sharedPreferences.setString(
        SharedPreferenceHelper.userFullNameKey,
        '$firstName $lastName',
      );

      await profileRepo.apiClient.sharedPreferences.setDouble(
        'rider_selected_latitude',
        selectedLatitude,
      );

      await profileRepo.apiClient.sharedPreferences.setDouble(
        'rider_selected_longitude',
        selectedLongitude,
      );

      await profileRepo.apiClient.sharedPreferences.setString(
        'rider_selected_address',
        selectedAddressText,
      );

      CustomSnackBar.success(
        successList: responseModel.message ?? [MyStrings.requestSuccess],
      );

      RouteHelper.checkRiderStatusAndGoToNextStep(responseModel.data?.user);
    } else {
      CustomSnackBar.error(
        errorList: responseModel.message ?? [MyStrings.somethingWentWrong],
      );
    }

    submitLoading = false;
    update();
  }

  @override
  void onClose() {
    userNameController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    mobileNoController.dispose();
    searchController.dispose();
    referController.dispose();
    searchCountryController.dispose();

    userNameFocusNode.dispose();
    firstNameFocusNode.dispose();
    lastNameFocusNode.dispose();
    emailFocusNode.dispose();
    mobileNoFocusNode.dispose();
    countryFocusNode.dispose();

    googleMapController?.dispose();

    super.onClose();
  }
}
