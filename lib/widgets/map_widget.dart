import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import '../stores/location_store.dart';

class MapWidget extends ConsumerStatefulWidget {
  const MapWidget({super.key});

  @override
  ConsumerState<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends ConsumerState<MapWidget> {
  final Set<Marker> _markers = {};
  GoogleMapController? _mapController;
  loc.LocationData? _currentLocation;
  final loc.Location _location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;

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
    loc.PermissionStatus permissionGranted;

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
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (!mounted) return;
      if (permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    _locationSubscription = _location.onLocationChanged.listen((loc.LocationData currentLocation) {
      if (!mounted) return;
      setState(() {
        _currentLocation = currentLocation;
      });
    });
  }

  void _updateMarkers(List<dynamic> nearbyDrivers) {
    _markers.clear();
    
    // User marker (if myLocationEnabled is false, otherwise use built-in)
    /*if (_currentLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          infoWindow: const InfoWindow(title: 'My Location'),
        ),
      );
    }*/

    // Add nearby drivers
    for (var driver in nearbyDrivers) {
      final id = driver['driverId']?.toString() ?? driver['id']?.toString() ?? 'unknown';
      final lat = driver['latitude'] as double?;
      final lng = driver['longitude'] as double?;
      
      if (lat != null && lng != null) {
        _markers.add(
          Marker(
            markerId: MarkerId('driver_$id'),
            position: LatLng(lat, lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
            infoWindow: InfoWindow(title: 'Driver $id'),
          ),
        );
      }
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
    final locationState = ref.watch(locationProvider);
    _updateMarkers(locationState.nearbyDrivers);

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
