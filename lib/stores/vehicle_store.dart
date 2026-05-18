import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/vehicle.dart';
import '../services/dio_provider.dart';
import 'auth_store.dart';

class VehicleState {
  final List<Vehicle> vehicles;
  final bool isLoading;
  final String? errorMessage;

  VehicleState({
    this.vehicles = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  VehicleState copyWith({
    List<Vehicle>? vehicles,
    bool? isLoading,
    String? errorMessage,
  }) {
    return VehicleState(
      vehicles: vehicles ?? this.vehicles,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

final vehicleProvider = StateNotifierProvider<VehicleNotifier, VehicleState>((ref) {
  return VehicleNotifier(ref);
});

class VehicleNotifier extends StateNotifier<VehicleState> {
  final Ref ref;

  VehicleNotifier(this.ref) : super(VehicleState());

  Dio get _dio => ref.read(dioProvider);

  String? _getDriverId() {
    final user = ref.read(authNotifierProvider).user;
    return user?['id']?.toString() ?? user?['_id']?.toString() ?? user?['uuid']?.toString();
  }

  String _extractErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null) {
        final data = error.response!.data;
        if (data is Map<String, dynamic>) {
          // Handle NestJS validation errors which are often in a list
          if (data['message'] is List) {
            final messages = data['message'] as List;
            if (messages.isNotEmpty) {
              final first = messages[0];
              if (first is Map && first['constraints'] is Map) {
                final constraints = first['constraints'] as Map;
                return constraints.values.first.toString();
              }
              return messages[0].toString();
            }
          }
          return data['message']?.toString() ?? 
                 data['error']?.toString() ?? 
                 error.message ?? 
                 'An error occurred';
        }
      }
      return error.message ?? 'Connection error';
    }
    return error.toString();
  }

  Future<void> fetchVehicles() async {
    final driverId = _getDriverId();

    if (driverId == null) {
      state = state.copyWith(errorMessage: 'Driver ID not found');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _dio.get('vehicles/driver/$driverId');
      
      List<Vehicle> fetchedVehicles = [];
      final responseData = response.data;

      if (responseData is List) {
        fetchedVehicles = responseData.map((json) => Vehicle.fromJson(json)).toList();
      } else if (responseData != null && responseData is Map) {
        final data = responseData['data'] ?? responseData['vehicles'];
        if (data is List) {
          fetchedVehicles = data.map((json) => Vehicle.fromJson(json)).toList();
        }
      }
      
      state = state.copyWith(vehicles: fetchedVehicles, isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _extractErrorMessage(e),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> createVehicle({
    required String type,
    required String plateNumber,
    required String color,
    required String model,
    required int year,
  }) async {
    final driverId = _getDriverId();
    if (driverId == null) {
      state = state.copyWith(errorMessage: 'Driver ID not found');
      return false;
    }

    final vehicle = Vehicle(
      driverId: driverId,
      type: type,
      plateNumber: plateNumber,
      color: color,
      model: model,
      year: year,
    );

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _dio.post('vehicles', data: vehicle.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchVehicles();
        return true;
      }
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to create vehicle');
      return false;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _extractErrorMessage(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateVehicle(String id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _dio.patch('vehicles/$id', data: data);
      if (response.statusCode == 200) {
        await fetchVehicles();
        return true;
      }
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to update vehicle');
      return false;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _extractErrorMessage(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteVehicle(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _dio.delete('vehicles/$id');
      if (response.statusCode == 200 || response.statusCode == 204) {
        await fetchVehicles();
        return true;
      }
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to delete vehicle');
      return false;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _extractErrorMessage(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}
