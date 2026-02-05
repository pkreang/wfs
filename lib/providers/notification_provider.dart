import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/services/notification_service.dart';

/// Provider สำหรับ NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
