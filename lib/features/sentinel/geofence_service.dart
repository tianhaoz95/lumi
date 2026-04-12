// GeofenceService skeleton for Phase 4 Sentinel
// Provides initialize(), addFence(), removeFence(), and an onGeofenceExit callback.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

import '../../shared/bridge/lumi_core_bridge.dart';
import 'notification_service.dart';

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

  // Keep a registry of registered fences so we can map identifier -> vendorName/coords
  final Map<String, VendorFence> _registeredFences = {};

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

      bg.BackgroundGeolocation.onGeofence((bg.GeofenceEvent event) async {
        // Only handle EXIT events here
        if (event.action == 'EXIT') {
          final stored = _registeredFences[event.identifier];

          final fence = VendorFence(
            id: event.identifier,
            vendorName: stored?.vendorName ?? event.identifier,
            lat: stored?.lat ?? event.location.coords.latitude,
            lng: stored?.lng ?? event.location.coords.longitude,
            radiusMeters: stored?.radiusMeters ?? 150.0,
          );

          // Increment visit count in native DB (fire-and-forget)
          try {
            LumiCoreBridge.incrementVisit(fence.id);
          } catch (e) {
            if (kDebugMode) debugPrint('incrementVisit failed for ${fence.id}: $e');
          }

          // Show a geofence notification with vendor metadata
          try {
            NotificationService().showGeofenceAlert(fence.vendorName, lat: fence.lat, lng: fence.lng);
          } catch (e) {
            if (kDebugMode) debugPrint('showGeofenceAlert failed for ${fence.vendorName}: $e');
          }

          if (onGeofenceExitCallback != null) {
            try {
              await onGeofenceExitCallback!(fence);
            } catch (e) {
              if (kDebugMode) debugPrint('onGeofenceExitCallback error: $e');
            }
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
      // store in registry for later mapping on events
      _registeredFences[fence.id] = fence;

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
      _registeredFences.remove(vendorId);
      await bg.BackgroundGeolocation.removeGeofence(vendorId);
    } catch (e) {
      if (kDebugMode) debugPrint('removeFence error: $e');
    }
  }
}
