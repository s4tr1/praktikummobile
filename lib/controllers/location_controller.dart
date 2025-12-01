import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
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
      // Get branches from Supabase
      // For demo, use sample data
      branches.value = _branchService.getSampleBranches();

      // In production, use:
      // branches.value = await _branchService.getAllBranches();

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

    // Center map on selected branch
    mapZoom.value = 16.0;
  }

  // Clear selection
  void clearSelection() {
    selectedBranch.value = null;
    mapZoom.value = 13.0;
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

  // Open in Google Maps
  void openInGoogleMaps(BranchModel branch) async {
    final url = branch.googleMapsUrl;
    // Use url_launcher package
    Get.snackbar(
      'Opening Maps',
      'Launching Google Maps...',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  // Get directions
  void getDirections(BranchModel branch) async {
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

    final url = branch.getDirectionsUrl(userLocation.value!);
    // Use url_launcher package
    Get.snackbar(
      'Getting Directions',
      'Opening navigation...',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  // Call branch
  void callBranch(BranchModel branch) {
    if (branch.phone != null) {
      Get.snackbar(
        'Calling',
        branch.phone!,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    }
  }

  // Email branch
  void emailBranch(BranchModel branch) {
    if (branch.email != null) {
      Get.snackbar(
        'Opening Email',
        branch.email!,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    }
  }
}