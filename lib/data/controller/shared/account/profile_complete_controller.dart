import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ovoride/core/helper/string_format_helper.dart';
import 'package:ovoride/core/route/route.dart';
import 'package:ovoride/core/utils/my_strings.dart';
import 'package:ovoride/data/model/country_model/country_model.dart';
import 'package:ovoride/data/model/global/response_model/response_model.dart';
import 'package:ovoride/data/model/profile/profile_response_model.dart';
import 'package:ovoride/data/model/profile_complete/profile_complete_post_model.dart';
import 'package:ovoride/data/model/profile_complete/profile_complete_response_model.dart';
import 'package:ovoride/data/model/zone/zone_list_response_model.dart';
import 'package:ovoride/data/repo/shared/account/profile_repo.dart';
import 'package:ovoride/presentation/components/snack_bar/show_custom_snackbar.dart';

class DriverProfileCompleteController extends GetxController {
  ProfileRepo profileRepo;

  DriverProfileCompleteController({required this.profileRepo});

  ProfileResponseModel model = ProfileResponseModel();
  ProfileResponseModel profileResponseModel = ProfileResponseModel();

  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileNoController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController referController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController searchCountryController = TextEditingController();
  TextEditingController searchZoneController = TextEditingController();

  FocusNode emailFocusNode = FocusNode();
  FocusNode mobileNoFocusNode = FocusNode();
  FocusNode zoneFocusNode = FocusNode();
  FocusNode addressFocusNode = FocusNode();
  FocusNode stateFocusNode = FocusNode();
  FocusNode zipCodeFocusNode = FocusNode();
  FocusNode cityFocusNode = FocusNode();
  FocusNode countryFocusNode = FocusNode();
  final FocusNode mobileFocusNode = FocusNode();
  FocusNode userNameFocusNode = FocusNode();

  String imageUrl = '';
  File? imageFile;

  String emailData = '';
  String countryData = '';
  String countryCodeData = '';
  String phoneCodeData = '';
  String phoneData = '';
  String loginType = '';

  String? countryName;
  String? countryCode;
  String? dialCode;

  bool countryLoading = true;
  bool isLoading = true;
  bool submitLoading = false;
  bool zoneLoading = false;

  List<Countries> countryList = [];
  List<Countries> filteredCountries = [];
  Countries selectedCountryData = Countries();

  int page = 0;
  List<ZoneData> zoneList = [];
  ZoneData selectedZone = ZoneData(id: "-1");
  String? nextPageUrl;

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
  bool isProgrammaticCameraMove = false;

  Future<void> initialData() async {
    countryList = profileRepo.apiClient.getOperatingCountries();
    filteredCountries = List.from(countryList);

    if (countryList.isNotEmpty) {
      selectCountryData(countryList.first);
    }

    isLoading = false;
    update();

    if (countryList.isNotEmpty) {
      printX(countryList.first.toJson());
    }

    await _prepareInitialLocation();
  }

  Future<void> loadProfileInfo() async {
    isLoading = true;
    update();

    try {
      profileResponseModel = await profileRepo.loadProfileInfo();

      if (profileResponseModel.data != null && profileResponseModel.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
        emailData = profileResponseModel.data?.driver?.email ?? '';
        countryData = profileResponseModel.data?.driver?.countryName ?? '';
        countryCodeData = profileResponseModel.data?.driver?.countryCode ?? '';
        phoneData = profileResponseModel.data?.driver?.mobile ?? '';
      }
    } catch (e) {
      printE(e);
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
    } catch (e) {
      printE(e);
      selectedAddressText = 'تعذر جلب موقعك الحالي، يمكنك تحديده يدويًا من الخريطة';
    }

    isFetchingLocation = false;
    update();
  }

  void onMapCreated(GoogleMapController controller) {
    googleMapController = controller;
    isMapReady = true;
    update();
  }

  void onCameraMove(CameraPosition position) {
    _cameraTarget = position.target;
  }

  void onCameraIdle() {
    if (_cameraTarget == null) return;

    if (isProgrammaticCameraMove) {
      isProgrammaticCameraMove = false;
      return;
    }

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
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        CustomSnackBar.error(
          errorList: ['يرجى تشغيل خدمة الموقع أولاً'],
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        CustomSnackBar.error(
          errorList: ['تم رفض إذن الموقع، يمكنك تحديد موقعك يدويًا من الخريطة'],
        );
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        CustomSnackBar.error(
          errorList: ['إذن الموقع مرفوض نهائيًا، فعّل الإذن من إعدادات الجهاز'],
        );
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
    } catch (e) {
      printE(e);
      CustomSnackBar.error(
        errorList: ['تعذر الوصول إلى موقعك الحالي'],
      );
    }
  }

  Future<void> animateToSelectedLocation() async {
    if (googleMapController == null) return;

    isProgrammaticCameraMove = true;

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

        addressController.text = selectedStreetAddress;
        cityController.text = selectedCity;
        stateController.text = selectedState;
        zipCodeController.text = selectedZipCode;

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
    } catch (e) {
      printE(e);
      selectedAddressText = 'تم تحديد الموقع، لكن تعذر استخراج العنوان النصي';
    }

    isReverseGeocoding = false;
    update();
  }

  Future<void> updateProfile() async {
    if (mobileNoController.text.isEmpty) {
      CustomSnackBar.error(errorList: [MyStrings.enterYourPhoneNumber.tr]);
      return;
    }

    if (selectedZone.id == '-1') {
      CustomSnackBar.error(errorList: [MyStrings.selectYourZone]);
      return;
    }

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

    String username = userNameController.text.trim();
    String mobileNumber = mobileNoController.text.trim();
    String address = selectedStreetAddress.isNotEmpty ? selectedStreetAddress : selectedAddressText;
    String city = selectedCity;
    String zip = selectedZipCode;
    String state = selectedState;
    String zoneId = selectedZone.id ?? '';

    submitLoading = true;
    update();

    ProfileCompletePostModel model = ProfileCompletePostModel(
      username: username,
      countryName: selectedCountryData.country ?? '',
      countryCode: selectedCountryData.countryCode ?? '',
      mobileNumber: mobileNumber,
      mobileCode: selectedCountryData.dialCode ?? '',
      address: address,
      state: state,
      zip: zip,
      city: city,
      image: null,
      zone: zoneId,
    );

    ResponseModel responseModel = await profileRepo.completeProfile(model);

    if (responseModel.statusCode == 200) {
      ProfileCompleteResponseModel responseData = ProfileCompleteResponseModel.fromJson(responseModel.responseJson);

      if (responseData.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
        RouteHelper.checkUserStatusAndGoToNextStep(responseData.data?.user);
      } else {
        CustomSnackBar.error(
          errorList: responseData.message ?? [MyStrings.requestFail],
        );
      }
    } else {
      CustomSnackBar.error(errorList: [responseModel.message]);
    }

    submitLoading = false;
    update();
  }

  void selectCountryData(Countries value) {
    selectedCountryData = value;
    update();
  }

  Future<void> initZoneData({bool shouldLoad = false}) async {
    zoneLoading = shouldLoad;
    page = 0;
    if (shouldLoad) {
      searchZoneController.clear();
    }
    update();
    await getZoneData(shouldLoad: shouldLoad);
  }

  Future<dynamic> getZoneData({bool shouldLoad = false}) async {
    try {
      page = page + 1;

      if (page == 1) {
        zoneLoading = shouldLoad;
        update();
      }

      ResponseModel mainResponse = await profileRepo.getZoneList(
        page.toString(),
        search: searchZoneController.text,
      );

      if (mainResponse.statusCode == 200) {
        ZoneListResponseModel model = ZoneListResponseModel.fromJson(mainResponse.responseJson);

        if (model.status == MyStrings.success) {
          nextPageUrl = model.data?.zones?.nextPageUrl;
          List<ZoneData>? tempList = model.data?.zones?.data;

          if (page == 1) {
            zoneList.clear();
          }

          if (tempList != null && tempList.isNotEmpty) {
            zoneList.addAll(tempList);
          }

          zoneLoading = false;
          update();
        }
      } else {
        CustomSnackBar.error(errorList: [mainResponse.message]);
        zoneLoading = false;
        update();
      }
    } catch (e) {
      printE(e);
    } finally {
      zoneLoading = false;
      update();
    }
  }

  bool hasNext() {
    return nextPageUrl != null && nextPageUrl!.isNotEmpty && nextPageUrl != 'null';
  }

  void selectZone(ZoneData zone) {
    selectedZone = zone;
    update();
  }

  @override
  void onClose() {
    userNameController.dispose();
    emailController.dispose();
    mobileNoController.dispose();
    addressController.dispose();
    stateController.dispose();
    zipCodeController.dispose();
    cityController.dispose();
    referController.dispose();
    countryController.dispose();
    searchController.dispose();
    searchCountryController.dispose();
    searchZoneController.dispose();

    emailFocusNode.dispose();
    mobileNoFocusNode.dispose();
    zoneFocusNode.dispose();
    addressFocusNode.dispose();
    stateFocusNode.dispose();
    zipCodeFocusNode.dispose();
    cityFocusNode.dispose();
    countryFocusNode.dispose();
    mobileFocusNode.dispose();
    userNameFocusNode.dispose();

    googleMapController?.dispose();

    super.onClose();
  }
}
