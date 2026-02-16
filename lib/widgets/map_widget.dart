import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final Set<Marker> _markers = {};
  GoogleMapController? _mapController;
  LocationData? _currentLocation;
  final Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _requestLocationPermission() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!mounted) return;
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!mounted) return;
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await _location.hasPermission();
    if (!mounted) return;
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (!mounted) return;
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationSubscription = _location.onLocationChanged.listen((LocationData currentLocation) {
      if (!mounted) return;
      setState(() {
        _currentLocation = currentLocation;
        _updateMarker();
      });
    });
  }

  void _updateMarker() {
    if (_currentLocation != null) {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          infoWindow: const InfoWindow(title: 'My Location'),
        ),
      );
    }
  }

  void centerOnUser() {
    if (_currentLocation != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
            zoom: 16.0,
          ),
        ),
      );
    }
  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(6.5244, 3.3792), // Lagos, Nigeria
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: _kGooglePlex,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      markers: _markers,
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
      },
    );
  }
}
