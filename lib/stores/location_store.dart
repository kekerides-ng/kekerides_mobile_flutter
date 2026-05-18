import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location/location.dart';
import 'package:dio/dio.dart';
import '../services/dio_provider.dart';
import 'auth_store.dart';

class LocationState {
  final LocationData? currentLocation;
  final bool isTracking;
  final List<dynamic> nearbyDrivers;
  final bool isLoading;
  final String? errorMessage;

  LocationState({
    this.currentLocation,
    this.isTracking = false,
    this.nearbyDrivers = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  LocationState copyWith({
    LocationData? currentLocation,
    bool? isTracking,
    List<dynamic>? nearbyDrivers,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LocationState(
      currentLocation: currentLocation ?? this.currentLocation,
      isTracking: isTracking ?? this.isTracking,
      nearbyDrivers: nearbyDrivers ?? this.nearbyDrivers,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier(ref);
});

class LocationNotifier extends StateNotifier<LocationState> {
  final Ref ref;
  final Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;
  Timer? _updateTimer;

  LocationNotifier(this.ref) : super(LocationState());

  Dio get _dio => ref.read(dioProvider);

  String? _getDriverId() {
    final user = ref.read(authNotifierProvider).user;
    return user?['id']?.toString() ?? user?['_id']?.toString() ?? user?['uuid']?.toString();
  }

  Future<bool> checkPermissions() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return false;
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return false;
    }

    return true;
  }

  Future<void> startLocationTracking() async {
    if (state.isTracking) return;

    final hasPermission = await checkPermissions();
    if (!hasPermission) {
      state = state.copyWith(errorMessage: 'Location permissions denied');
      return;
    }

    state = state.copyWith(isTracking: true);

    // Initial location
    try {
      final initialLocation = await _location.getLocation();
      state = state.copyWith(currentLocation: initialLocation);
      _sendLocationToServer(initialLocation);
    } catch (e) {
      print('Error getting initial location: $e');
    }

    // Subscribe to changes
    _locationSubscription = _location.onLocationChanged.listen((LocationData currentLocation) {
      state = state.copyWith(currentLocation: currentLocation);
    });

    // Periodically send to server (every 30 seconds to save battery/bandwidth)
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (state.currentLocation != null) {
        _sendLocationToServer(state.currentLocation!);
      }
    });
  }

  void stopLocationTracking() {
    _locationSubscription?.cancel();
    _updateTimer?.cancel();
    state = state.copyWith(isTracking: false);
  }

  Future<void> _sendLocationToServer(LocationData location) async {
    // Only drivers should send their location
    final user = ref.read(authNotifierProvider).user;
    final isDriver = user?['role'] == 'driver'; // Check based on your role logic
    
    // Also check if online if you have that state
    final isOnline = user?['isOnline'] == true;

    if (!isDriver || !isOnline) return;

    try {
      await _dio.post('driver-locations', data: {
        'latitude': location.latitude,
        'longitude': location.longitude,
      });
    } catch (e) {
      print('Failed to update driver location: $e');
    }
  }

  Future<void> fetchNearbyDrivers(double lat, double lng, {double radius = 5.0}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Assuming GET with query params for nearby
      final response = await _dio.get('driver-locations/nearby', queryParameters: {
        'latitude': lat,
        'longitude': lng,
        'radius': radius,
      });
      
      final data = response.data;
      List<dynamic> drivers = [];
      if (data is List) {
        drivers = data;
      } else if (data is Map && data['data'] is List) {
        drivers = data['data'];
      }

      state = state.copyWith(nearbyDrivers: drivers, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to fetch nearby drivers');
    }
  }

  Future<Map<String, dynamic>?> getDriverLocation(String driverId) async {
    try {
      final response = await _dio.get('driver-locations/driver/$driverId');
      return response.data;
    } catch (e) {
      print('Error fetching specific driver location: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _updateTimer?.cancel();
    super.dispose();
  }
}
