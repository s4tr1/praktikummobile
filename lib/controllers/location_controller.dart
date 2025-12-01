import 'dart:convert'; // ADDED
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http; // ADDED
import 'package:url_launcher/url_launcher.dart';
import '../models/branch_model.dart';
import '../services/location_service.dart';
import '../services/branch_service.dart';

class LocationController extends GetxController {
  final LocationService _locationService = LocationService();
  final BranchService _branchService = BranchService();

  // Observable states
  final isLoading = false.obs;
  final isLoadingLocation = false.obs;
  final errorMessage = ''.obs;

  // Location
  final userLocation = Rxn<LatLng>();
  final currentProvider = LocationProvider.network.obs;

  // Branches
  final branches = <BranchModel>[].obs;
  final selectedBranch = Rxn<BranchModel>();

  // Map state
  final mapZoom = 13.0.obs;
  final showUserMarker = true.obs;

  // ADDED: route points for polyline in-app (Directions)
  final routePoints = <LatLng>[].obs;
  final isRouting = false.obs; // optional: to show loading while route fetched

  @override
  void onInit() {
    super.onInit();
    _initializeLocation();
  }

  // Initialize with network location (fast)
  Future<void> _initializeLocation() async {
    await loadBranches();
    await getUserLocation(provider: LocationProvider.network);
  }

  // Load all branches
  Future<void> loadBranches() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      branches.value = _branchService.getSampleBranches();
      print('✅ Loaded ${branches.length} branches');
    } catch (e) {
      errorMessage.value = 'Failed to load branches: ${e.toString()}';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get user location
  Future<void> getUserLocation({
    LocationProvider provider = LocationProvider.network,
  }) async {
    isLoadingLocation.value = true;
    errorMessage.value = '';
    currentProvider.value = provider;

    try {
      final location = await _locationService.getCurrentLocation(
        provider: provider,
      );

      userLocation.value = location;
      showUserMarker.value = true;

      // Sort branches by distance
      _sortBranchesByDistance();

      final providerName = provider == LocationProvider.gps ? 'GPS' : 'Network';
      print('✅ Location updated ($providerName): ${location.latitude}, ${location.longitude}');

      Get.snackbar(
        '📍 Location Updated',
        'Using $providerName provider',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      errorMessage.value = e.toString();

      // Show user-friendly error dialog
      if (e.toString().contains('denied')) {
        _showPermissionDialog();
      } else {
        Get.snackbar(
          'Location Error',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } finally {
      isLoadingLocation.value = false;
    }
  }

  // Switch to GPS mode (high accuracy)
  Future<void> switchToGpsMode() async {
    await getUserLocation(provider: LocationProvider.gps);
  }

  // Switch to Network mode (fast)
  Future<void> switchToNetworkMode() async {
    await getUserLocation(provider: LocationProvider.network);
  }

  // Refresh location
  Future<void> refreshLocation() async {
    await getUserLocation(provider: currentProvider.value);
  }

  // Sort branches by distance from user
  void _sortBranchesByDistance() {
    if (userLocation.value != null) {
      branches.sort((a, b) {
        final distA = a.distanceFrom(userLocation.value!);
        final distB = b.distanceFrom(userLocation.value!);
        return distA.compareTo(distB);
      });
      branches.refresh();
    }
  }

  // Select branch
  void selectBranch(BranchModel branch) {
    selectedBranch.value = branch;
    mapZoom.value = 16.0;
  }

  // Clear selection
  void clearSelection() {
    selectedBranch.value = null;
    mapZoom.value = 13.0;
    routePoints.clear(); // clear route when selection cleared
  }

  // Get distance to branch
  String getDistanceTo(BranchModel branch) {
    if (userLocation.value == null) {
      return 'Unknown';
    }
    return branch.formatDistance(userLocation.value!);
  }

  // Get nearest branch
  BranchModel? getNearestBranch() {
    if (branches.isEmpty || userLocation.value == null) {
      return null;
    }
    return branches.first;
  }

  // Center map on user location
  void centerOnUser() {
    if (userLocation.value != null) {
      mapZoom.value = 15.0;
    }
  }

  // Center map on all branches
  void centerOnBranches() {
    mapZoom.value = 11.0;
  }

  // Show permission dialog
  void _showPermissionDialog() {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_off, color: Colors.red),
            SizedBox(width: 12),
            Text('Location Permission'),
          ],
        ),
        content: const Text(
          'Location permission is required to find nearest branches.\n\n'
              'Please enable location permission in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _locationService.openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
            ),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // Get provider info
  String getProviderInfo() {
    return _locationService.getAccuracyInfo(currentProvider.value);
  }

  // Get provider icon
  String getProviderIcon() {
    return _locationService.getProviderIcon(currentProvider.value);
  }

  // PERBAIKAN: Open in Google Maps dengan url_launcher (fallback)
  Future<void> openInGoogleMaps(BranchModel branch) async {
    final url = Uri.parse(branch.googleMapsUrl);
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Could not open Google Maps',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open Google Maps: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // OLD: external get directions (ke Google Maps) - tetap disimpan sebagai fallback
  Future<void> getDirections(BranchModel branch) async {
    if (userLocation.value == null) {
      Get.snackbar(
        'Error',
        'Location not available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final urlString = branch.getDirectionsUrl(userLocation.value!);
    final url = Uri.parse(urlString);
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        
        Get.snackbar(
          'Opening Navigation',
          'Launching Google Maps...',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Error',
          'Could not open navigation',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open navigation: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // -----------------------
  // NEW: Get internal directions (draw route in-app)
  // Uses OSRM public server (no API key). Works well for demo.
  // -----------------------
  Future<void> getDirectionsInternal(BranchModel branch) async {
    if (userLocation.value == null) {
      Get.snackbar(
        'Error',
        'Location not available. Please allow location permission.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isRouting.value = true;
      routePoints.clear();

      final start = userLocation.value!;
      final end = branch.coordinates;

      // OSRM HTTP API (public)
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
        '?overview=full&geometries=geojson',
      );

      final resp = await http.get(url).timeout(const Duration(seconds: 10));

      if (resp.statusCode != 200) {
        throw Exception('Routing API returned ${resp.statusCode}');
      }

      final data = jsonDecode(resp.body);

      if (data['routes'] == null || data['routes'].isEmpty) {
        throw Exception('No route found');
      }

      final coords = data['routes'][0]['geometry']['coordinates'] as List<dynamic>;

      final List<LatLng> pts = coords.map<LatLng>((c) {
        final double lon = (c[0] as num).toDouble();
        final double lat = (c[1] as num).toDouble();
        return LatLng(lat, lon);
      }).toList();

      routePoints.assignAll(pts);

      // Keep selected branch for UI highlight
      selectedBranch.value = branch;

      Get.snackbar(
        'Route ready',
        'Route displayed on map.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Routing Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isRouting.value = false;
    }
  }

  // PERBAIKAN: Call branch dengan url_launcher
  Future<void> callBranch(BranchModel branch) async {
    if (branch.phone == null) return;
    
    // Remove spaces and format phone number
    final phoneNumber = branch.phone!.replaceAll(RegExp(r'[^0-9+]'), '');
    final url = Uri.parse('tel:$phoneNumber');
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
        
        Get.snackbar(
          'Calling',
          branch.phone!,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 1),
        );
      } else {
        Get.snackbar(
          'Error',
          'Could not make call',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to make call: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // PERBAIKAN: Email branch dengan url_launcher
  Future<void> emailBranch(BranchModel branch) async {
    if (branch.email == null) return;
    
    final url = Uri.parse('mailto:${branch.email}');
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
        
        Get.snackbar(
          'Opening Email',
          branch.email!,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 1),
        );
      } else {
        Get.snackbar(
          'Error',
          'Could not open email',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open email: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
