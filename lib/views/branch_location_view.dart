import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/location_controller.dart';
import '../models/branch_model.dart';
import '../services/location_service.dart'; // ⭐ TAMBAHKAN INI

class BranchLocationView extends StatelessWidget {
  const BranchLocationView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(LocationController());
    final mapController = MapController();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1A237E),
        title: const Text(
          'Branch Locations',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          // Provider Mode Toggle
          Obx(() {
            final isGps = ctrl.currentProvider.value == LocationProvider.gps;
            return IconButton(
              icon: Icon(
                isGps ? Icons.gps_fixed : Icons.gps_not_fixed,
                color: Colors.white,
              ),
              onPressed: () => _showProviderDialog(context, ctrl),
            );
          }),
          // Refresh location
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => ctrl.refreshLocation(),
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading branches...'),
              ],
            ),
          );
        }

        return Stack(
          children: [
            // Map
            _buildMap(ctrl, mapController),

            // Loading overlay
            if (ctrl.isLoadingLocation.value)
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          ctrl.getProviderIcon() + ' Getting location...',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Provider Info
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Obx(() => Text(
                  ctrl.getProviderIcon() + ' ' + ctrl.getProviderInfo(),
                  style: const TextStyle(fontSize: 11),
                )),
              ),
            ),

            // Branch List
            DraggableScrollableSheet(
              initialChildSize: 0.3,
              minChildSize: 0.15,
              maxChildSize: 0.7,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Handle
                      Container(
                        margin: const EdgeInsets.only(top: 8, bottom: 4),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Title
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: Color(0xFF1A237E)),
                            const SizedBox(width: 8),
                            Obx(() => Text(
                              'Nearby Branches (${ctrl.branches.length})',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                          ],
                        ),
                      ),
                      // List
                      Expanded(
                        child: Obx(() => ListView.builder(
                          controller: scrollController,
                          itemCount: ctrl.branches.length,
                          itemBuilder: (context, index) {
                            final branch = ctrl.branches[index];
                            return _BranchListItem(
                              branch: branch,
                              ctrl: ctrl,
                              onTap: () {
                                ctrl.selectBranch(branch);
                                mapController.move(
                                  branch.coordinates,
                                  16.0,
                                );
                              },
                            );
                          },
                        )),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Floating Action Buttons
            Positioned(
              right: 16,
              bottom: 120,
              child: Column(
                children: [
                  // Center on user
                  FloatingActionButton.small(
                    heroTag: 'center_user',
                    backgroundColor: Colors.white,
                    onPressed: () {
                      if (ctrl.userLocation.value != null) {
                        mapController.move(
                          ctrl.userLocation.value!,
                          15.0,
                        );
                      }
                    },
                    child: const Icon(Icons.my_location, color: Color(0xFF1A237E)),
                  ),
                  const SizedBox(height: 8),
                  // Zoom in
                  FloatingActionButton.small(
                    heroTag: 'zoom_in',
                    backgroundColor: Colors.white,
                    onPressed: () {
                      final currentZoom = mapController.camera.zoom;
                      mapController.move(
                        mapController.camera.center,
                        currentZoom + 1,
                      );
                    },
                    child: const Icon(Icons.add, color: Color(0xFF1A237E)),
                  ),
                  const SizedBox(height: 8),
                  // Zoom out
                  FloatingActionButton.small(
                    heroTag: 'zoom_out',
                    backgroundColor: Colors.white,
                    onPressed: () {
                      final currentZoom = mapController.camera.zoom;
                      mapController.move(
                        mapController.camera.center,
                        currentZoom - 1,
                      );
                    },
                    child: const Icon(Icons.remove, color: Color(0xFF1A237E)),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMap(LocationController ctrl, MapController mapController) {
    return Obx(() {
      final userLoc = ctrl.userLocation.value;
      final selectedBranch = ctrl.selectedBranch.value;

      // Center point
      final center = selectedBranch?.coordinates ??
          userLoc ??
          const LatLng(-7.9797, 112.6304); // Default: Malang

      return FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: center,
          initialZoom: ctrl.mapZoom.value,
          minZoom: 10,
          maxZoom: 18,
        ),
        children: [
          // OpenStreetMap tiles
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.conatus.academy',
          ),

          // Branch markers
          MarkerLayer(
            markers: ctrl.branches.map((branch) {
              final isSelected = selectedBranch?.id == branch.id;
              return Marker(
                point: branch.coordinates,
                width: isSelected ? 50 : 40,
                height: isSelected ? 50 : 40,
                child: GestureDetector(
                  onTap: () => ctrl.selectBranch(branch),
                  child: Icon(
                    Icons.location_on,
                    size: isSelected ? 50 : 40,
                    color: isSelected ? Colors.red : const Color(0xFF1A237E),
                  ),
                ),
              );
            }).toList(),
          ),

          // User location marker
          if (userLoc != null && ctrl.showUserMarker.value)
            MarkerLayer(
              markers: [
                Marker(
                  point: userLoc,
                  width: 30,
                  height: 30,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                  ),
                ),
              ],
            ),
        ],
      );
    });
  }

  void _showProviderDialog(BuildContext context, LocationController ctrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Provider'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.wifi, color: Colors.green),
              title: const Text('Network Mode'),
              subtitle: const Text('Fast, less accurate (50-500m)'),
              trailing: Obx(() => Radio<LocationProvider>(
                value: LocationProvider.network,
                groupValue: ctrl.currentProvider.value,
                onChanged: (_) {},
              )),
              onTap: () {
                Get.back();
                ctrl.switchToNetworkMode();
              },
            ),
            ListTile(
              leading: const Icon(Icons.gps_fixed, color: Colors.blue),
              title: const Text('GPS Mode'),
              subtitle: const Text('Accurate, slower (5-10m)'),
              trailing: Obx(() => Radio<LocationProvider>(
                value: LocationProvider.gps,
                groupValue: ctrl.currentProvider.value,
                onChanged: (_) {},
              )),
              onTap: () {
                Get.back();
                ctrl.switchToGpsMode();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Branch List Item Widget
class _BranchListItem extends StatelessWidget {
  final BranchModel branch;
  final LocationController ctrl;
  final VoidCallback onTap;

  const _BranchListItem({
    required this.branch,
    required this.ctrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title & Distance
              Row(
                children: [
                  Expanded(
                    child: Text(
                      branch.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Obx(() {
                    if (ctrl.userLocation.value != null) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          ctrl.getDistanceTo(branch),
                          style: TextStyle(
                            color: Colors.green[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
              const SizedBox(height: 4),
              // Address
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      branch.address,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Operating hours
              if (branch.operatingHours != null)
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      branch.operatingHours!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              // Action buttons
              Row(
                children: [
                  if (branch.phone != null)
                    _ActionButton(
                      icon: Icons.phone,
                      label: 'Call',
                      onTap: () => ctrl.callBranch(branch),
                    ),
                  if (branch.phone != null) const SizedBox(width: 8),
                  _ActionButton(
                    icon: Icons.directions,
                    label: 'Directions',
                    onTap: () => ctrl.getDirections(branch),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF1A237E)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF1A237E)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1A237E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}