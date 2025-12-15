import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latlong2/latlong.dart';
import '../models/branch_model.dart';
import '../config/supabase_config.dart';

class BranchService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _tableName = 'branches';

  // Get all active branches
  Future<List<BranchModel>> getAllBranches() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('is_active', true)
          .order('name', ascending: true);

      return (response as List)
          .map((json) => BranchModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch branches: $e');
    }
  }

  // Get branch by ID
  Future<BranchModel?> getBranchById(int id) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();

      return BranchModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch branch: $e');
    }
  }

  // Get nearest branches (sorted by distance)
  Future<List<BranchModel>> getNearestBranches({
    required LatLng userLocation,
    int limit = 10,
  }) async {
    try {
      final allBranches = await getAllBranches();

      // Sort by distance
      allBranches.sort((a, b) {
        final distA = a.distanceFrom(userLocation);
        final distB = b.distanceFrom(userLocation);
        return distA.compareTo(distB);
      });

      // Return limited results
      return allBranches.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get nearest branches: $e');
    }
  }

  // Get branches within radius (in kilometers)
  Future<List<BranchModel>> getBranchesInRadius({
    required LatLng userLocation,
    required double radiusKm,
  }) async {
    try {
      final allBranches = await getAllBranches();

      // Filter by radius
      return allBranches.where((branch) {
        final distance = branch.distanceFrom(userLocation);
        return distance <= radiusKm;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get branches in radius: $e');
    }
  }

  // Create branch (Admin only)
  Future<BranchModel> createBranch({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    String? phone,
    String? email,
    String? operatingHours,
    String? description,
  }) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .insert({
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'phone': phone,
        'email': email,
        'operating_hours': operatingHours,
        'description': description,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
      })
          .select()
          .single();

      return BranchModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create branch: $e');
    }
  }

  // Update branch (Admin only)
  Future<void> updateBranch({
    required int id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
    String? operatingHours,
    String? description,
    bool? isActive,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (address != null) updates['address'] = address;
      if (latitude != null) updates['latitude'] = latitude;
      if (longitude != null) updates['longitude'] = longitude;
      if (phone != null) updates['phone'] = phone;
      if (email != null) updates['email'] = email;
      if (operatingHours != null) updates['operating_hours'] = operatingHours;
      if (description != null) updates['description'] = description;
      if (isActive != null) updates['is_active'] = isActive;

      await _supabase
          .from(_tableName)
          .update(updates)
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to update branch: $e');
    }
  }

  // Delete branch (Admin only)
  Future<void> deleteBranch(int id) async {
    try {
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete branch: $e');
    }
  }

  // Search branches by name or address
  Future<List<BranchModel>> searchBranches(String query) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .or('name.ilike.%$query%,address.ilike.%$query%')
          .eq('is_active', true)
          .order('name', ascending: true);

      return (response as List)
          .map((json) => BranchModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search branches: $e');
    }
  }

  // Get sample branches (for demo purposes)
  List<BranchModel> getSampleBranches() {
    return [
      // Malang area branches
      BranchModel(
        id: 1,
        name: 'Conatus Academy Malang Pusat',
        address: 'Jl. Veteran No. 10, Malang',
        latitude: -7.9797,
        longitude: 112.6304,
        phone: '(0341) 123456',
        email: 'malang@conatus.com',
        operatingHours: 'Mon-Sat: 08:00-17:00',
        description: 'Cabang utama di pusat kota Malang',
        isActive: true,
      ),
      BranchModel(
        id: 2,
        name: 'Conatus Academy Dinoyo',
        address: 'Jl. MT. Haryono No. 167, Malang',
        latitude: -7.9553,
        longitude: 112.6212,
        phone: '(0341) 234567',
        email: 'dinoyo@conatus.com',
        operatingHours: 'Mon-Sat: 09:00-18:00',
        description: 'Cabang Dinoyo dekat kampus',
        isActive: true,
      ),
      BranchModel(
        id: 3,
        name: 'Conatus Academy Soekarno Hatta',
        address: 'Jl. Soekarno Hatta No. 20, Malang',
        latitude: -7.9519,
        longitude: 112.6150,
        phone: '(0341) 345678',
        email: 'soehat@conatus.com',
        operatingHours: 'Mon-Fri: 08:00-20:00',
        description: 'Cabang Soekarno Hatta',
        isActive: true,
      ),
      BranchModel(
        id: 4,
        name: 'Conatus Academy Lawang',
        address: 'Jl. Raya Lawang No. 50, Lawang',
        latitude: -7.8353,
        longitude: 112.6942,
        phone: '(0341) 456789',
        email: 'lawang@conatus.com',
        operatingHours: 'Mon-Sat: 08:00-17:00',
        description: 'Cabang Lawang',
        isActive: true,
      ),
      BranchModel(
        id: 5,
        name: 'Conatus Academy Batu',
        address: 'Jl. Panglima Sudirman No. 99, Batu',
        latitude: -7.8700,
        longitude: 112.5285,
        phone: '(0341) 567890',
        email: 'batu@conatus.com',
        operatingHours: 'Mon-Sat: 09:00-18:00',
        description: 'Cabang Batu kota wisata',
        isActive: true,
      ),
    ];
  }
}