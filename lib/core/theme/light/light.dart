import 'package:flutter/material.dart';

import '../../utils/my_color.dart';

ThemeData lightThemeData = ThemeData.light().copyWith(
  primaryColor: const Color.fromRGBO(81, 78, 183, 1),
  primaryColorDark: MyColor.primaryColor,
  secondaryHeaderColor: Colors.yellow,

  // Define the default brightness and colors.
  scaffoldBackgroundColor: MyColor.screenBgColor,

  colorScheme: ColorScheme.fromSeed(
    seedColor: MyColor.primaryColor,
    brightness: Brightness.light,
  ),

  drawerTheme: const DrawerThemeData(
    backgroundColor: MyColor.screenBgColor,
    surfaceTintColor: MyColor.transparentColor,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 57,
      fontWeight: FontWeight.bold,
      color: MyColor.titleColor,
    ),
    displaySmall: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 45,
      fontWeight: FontWeight.normal,
      color: MyColor.colorBlack,
    ),
    bodyLarge: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: MyColor.colorBlack,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: MyColor.colorBlack,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: MyColor.colorBlack,
    ),
    displayMedium: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 41,
      fontWeight: FontWeight.normal,
      color: MyColor.colorBlack,
    ),
    headlineLarge: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 32,
      fontWeight: FontWeight.w600,
      color: MyColor.colorBlack,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 28,
      fontWeight: FontWeight.w500,
      color: MyColor.colorBlack,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 24,
      fontWeight: FontWeight.w500,
      color: MyColor.colorBlack,
    ),
    labelMedium: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: MyColor.colorBlack,
    ),
    labelSmall: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: MyColor.colorBlack,
    ),
    labelLarge: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: MyColor.colorBlack,
    ),
    titleLarge: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: MyColor.colorBlack,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: MyColor.bodyTextColor,
    ),
    titleSmall: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: MyColor.bodyTextColor,
    ),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: MyColor.getPrimaryColor(),
    selectionColor: MyColor.getPrimaryColor().withValues(alpha: 0.2),
    selectionHandleColor: MyColor.getPrimaryColor(),
  ),
  bannerTheme: MaterialBannerThemeData(
    backgroundColor: MyColor.primaryColor.withValues(alpha: .1),
  ),
  splashColor: MyColor.primaryColor,
  //Bottom Navbar
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: MyColor.colorWhite,
    selectedItemColor: MyColor.primaryColor,
    unselectedItemColor: MyColor.colorWhite,
  ),
  inputDecorationTheme: const InputDecorationTheme(),
);

String googleMapActiveRideKey = '''

[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "elementType": "labels",
    "stylers": [
      {
        "color": "#ff0000"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "color": "#1471c8"
      }
    ]
  },
  {
    "elementType": "labels.text",
    "stylers": [
      {
        "color": "#1471c8"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#ff9d00"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#263c3f"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#6b9a76"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#38414e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#212a37"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9ca5b3"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "stylers": [
      {
        "lightness": 5
      },
      {
        "weight": 1
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#2750b0"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#1f2835"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.icon",
    "stylers": [
      {
        "color": "#ff05b0"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#f3d19c"
      }
    ]
  },
  {
    "featureType": "road.local",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#fafafa"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#fafafa"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#fafafa"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#2f3948"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#7fa2f5"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#515c6d"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  }
]
''';

String googleMapLightStyleJson = '''
''';
