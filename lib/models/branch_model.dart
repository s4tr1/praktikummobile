import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';

part 'branch_model.g.dart';

@HiveType(typeId: 3)
class BranchModel extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String address;

  @HiveField(3)
  double latitude;

  @HiveField(4)
  double longitude;

  @HiveField(5)
  String? phone;

  @HiveField(6)
  String? email;

  @HiveField(7)
  String? operatingHours;

  @HiveField(8)
  String? description;

  @HiveField(9)
  bool isActive;

  @HiveField(10)
  DateTime? createdAt;

  BranchModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.email,
    this.operatingHours,
    this.description,
    this.isActive = true,
    this.createdAt,
  });

  // Get LatLng for map
  LatLng get coordinates => LatLng(latitude, longitude);

  // Calculate distance from user location (in kilometers)
  double distanceFrom(LatLng userLocation) {
    const Distance distance = Distance();
    return distance.as(
      LengthUnit.Kilometer,
      userLocation,
      coordinates,
    );
  }

  // Format distance for display
  String formatDistance(LatLng userLocation) {
    final dist = distanceFrom(userLocation);
    if (dist < 1) {
      return '${(dist * 1000).toStringAsFixed(0)} m';
    }
    return '${dist.toStringAsFixed(1)} km';
  }

  // From Supabase JSON
  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      operatingHours: json['operating_hours'] as String?,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  // To Supabase JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'email': email,
      'operating_hours': operatingHours,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Backward compatibility
  factory BranchModel.fromMap(Map<String, dynamic> map) {
    return BranchModel.fromJson(map);
  }

  Map<String, dynamic> toMap() => toJson();

  // Google Maps URL
  String get googleMapsUrl =>
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

  // Directions URL (from user location)
  String getDirectionsUrl(LatLng userLocation) =>
      'https://www.google.com/maps/dir/?api=1&origin=${userLocation.latitude},${userLocation.longitude}&destination=$latitude,$longitude';
}