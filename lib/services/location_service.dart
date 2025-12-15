import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

enum LocationProvider {
  network, // Fast, less accurate
  gps, // Slow, very accurate
}

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Check if location service is enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Check location permissions
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  // Request location permissions
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  // Handle permission logic
  Future<bool> handleLocationPermission() async {
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable it in your device settings.');
    }

    LocationPermission permission = await checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied. Please enable it in app settings.',
      );
    }

    return true;
  }

  // Get current location based on provider type
  Future<LatLng> getCurrentLocation({
    LocationProvider provider = LocationProvider.network,
  }) async {
    try {
      // Check permissions first
      await handleLocationPermission();

      // Configure location accuracy based on provider
      LocationAccuracy accuracy;

      if (provider == LocationProvider.gps) {
        accuracy = LocationAccuracy.best; // GPS Mode: High accuracy
      } else {
        accuracy = LocationAccuracy.low; // Network Mode: Low accuracy, faster
      }

      // Get position with the specified accuracy
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
      );

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      throw Exception('Failed to get location: ${e.toString()}');
    }
  }

  // Get location with Network provider (Fast)
  Future<LatLng> getNetworkLocation() async {
    return await getCurrentLocation(provider: LocationProvider.network);
  }

  // Get location with GPS provider (Accurate)
  Future<LatLng> getGpsLocation() async {
    return await getCurrentLocation(provider: LocationProvider.gps);
  }

  // Stream location updates (for real-time tracking)
  Stream<LatLng> getLocationStream({
    LocationProvider provider = LocationProvider.gps,
  }) {
    LocationAccuracy accuracy;
    int distanceFilter;

    if (provider == LocationProvider.gps) {
      accuracy = LocationAccuracy.best;
      distanceFilter = 10; // Update every 10 meters
    } else {
      accuracy = LocationAccuracy.low;
      distanceFilter = 100; // Update every 100 meters
    }

    final locationSettings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings)
        .map((position) => LatLng(position.latitude, position.longitude));
  }

  // Calculate distance between two coordinates (in meters)
  double calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  // Calculate distance in kilometers
  double calculateDistanceInKm(LatLng start, LatLng end) {
    return calculateDistance(start, end) / 1000;
  }

  // Format distance for display
  String formatDistance(LatLng start, LatLng end) {
    final distanceInMeters = calculateDistance(start, end);

    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
    }
  }

  // Open device location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  // Open app settings
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  // Get accuracy info
  String getAccuracyInfo(LocationProvider provider) {
    if (provider == LocationProvider.gps) {
      return 'GPS Mode: High accuracy (5-10m)';
    } else {
      return 'Network Mode: Fast location (50-500m)';
    }
  }

  // Get provider icon
  String getProviderIcon(LocationProvider provider) {
    if (provider == LocationProvider.gps) {
      return '📡'; // GPS satellite
    } else {
      return '📶'; // Network signal
    }
  }
}