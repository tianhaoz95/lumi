// GeofenceService skeleton for Phase 4 Sentinel
// Provides initialize(), addFence(), removeFence(), and an onGeofenceExit callback.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

class VendorFence {
  final String id;
  final String vendorName;
  final double lat;
  final double lng;
  final double radiusMeters;

  VendorFence({
    required this.id,
    required this.vendorName,
    required this.lat,
    required this.lng,
    this.radiusMeters = 150.0,
  });
}

typedef GeofenceExitCallback = FutureOr<void> Function(VendorFence fence);

class GeofenceService {
  GeofenceService._();
  static final GeofenceService instance = GeofenceService._();

  GeofenceExitCallback? onGeofenceExitCallback;

  Future<void> initialize({GeofenceExitCallback? onExit}) async {
    onGeofenceExitCallback = onExit;
    try {
      await bg.BackgroundGeolocation.ready(bg.Config(
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
        distanceFilter: 50,
        stopOnTerminate: false,
        startOnBoot: true,
        enableHeadless: true,
      ));

      bg.BackgroundGeolocation.onGeofence((bg.GeofenceEvent event) {
        // Only handle EXIT events here
        if (event.action == 'EXIT') {
          final fence = VendorFence(
            id: event.identifier,
            vendorName: event.identifier,
            lat: event.location.coords.latitude,
            lng: event.location.coords.longitude,
            radiusMeters: 150.0,
          );
          if (onGeofenceExitCallback != null) {
            onGeofenceExitCallback!(fence);
          }
        }
      });

      // Start background geolocation in a paused state; callers can start when needed.
      await bg.BackgroundGeolocation.start();
    } catch (e) {
      if (kDebugMode) debugPrint('GeofenceService.initialize error: $e');
    }
  }

  Future<String> addFence(VendorFence fence) async {
    try {
      await bg.BackgroundGeolocation.addGeofence(bg.Geofence(
        identifier: fence.id,
        radius: fence.radiusMeters,
        latitude: fence.lat,
        longitude: fence.lng,
        notifyOnEntry: false,
        notifyOnExit: true,
      ));
      return fence.id;
    } catch (e) {
      if (kDebugMode) debugPrint('addFence error: $e');
      rethrow;
    }
  }

  Future<void> removeFence(String vendorId) async {
    try {
      await bg.BackgroundGeolocation.removeGeofence(vendorId);
    } catch (e) {
      if (kDebugMode) debugPrint('removeFence error: $e');
    }
  }
}
