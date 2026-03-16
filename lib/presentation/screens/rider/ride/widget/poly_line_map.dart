import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ovoride/data/controller/rider/map/ride_map_controller.dart';

import 'package:ovoride/environment.dart';

class RiderPolyLineMapScreen extends StatefulWidget {
  const RiderPolyLineMapScreen({super.key});

  @override
  State<RiderPolyLineMapScreen> createState() => _RiderPolyLineMapScreenState();
}

class _RiderPolyLineMapScreenState extends State<RiderPolyLineMapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<RideMapController>(
      tag: 'rider',
        builder: (controller) {
          return GoogleMap(
            trafficEnabled: false,
            indoorViewEnabled: false,
            zoomControlsEnabled: false,
            zoomGesturesEnabled: true,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false,
            initialCameraPosition: CameraPosition(
              target: controller.pickupLatLng,
              zoom: Environment.mapDefaultZoom,
            ),
            onMapCreated: (googleMapController) {
              // controller.setMapFitToTour(Set<Polyline>.of(controller.polylines.values));
              controller.mapController = googleMapController;
              double southWestLat;
              double southWestLong;
              double northEastLat;
              double northEastLong;

              if (controller.pickupLatLng.latitude <= controller.destinationLatLng.latitude) {
                southWestLat = controller.pickupLatLng.latitude;
                northEastLat = controller.destinationLatLng.latitude;
              } else {
                northEastLat = controller.pickupLatLng.latitude;
                southWestLat = controller.destinationLatLng.latitude;
              }

              if (controller.pickupLatLng.longitude <= controller.destinationLatLng.longitude) {
                southWestLong = controller.pickupLatLng.longitude;
                northEastLong = controller.destinationLatLng.longitude;
              } else {
                northEastLong = controller.pickupLatLng.longitude;
                southWestLong = controller.destinationLatLng.longitude;
              }
              LatLngBounds bounds = LatLngBounds(
                northeast: LatLng(northEastLat, northEastLong),
                southwest: LatLng(southWestLat, southWestLong),
              );

              controller.mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
            },
            markers: controller.getMarkers(
              pickup: controller.pickupLatLng,
              destination: controller.destinationLatLng,
              // driverLatLng: controller.driverLatLng,
            ),
            polylines: Set<Polyline>.of(controller.polylines.values),
          );
        },
      ),
    );
  }
}
