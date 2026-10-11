import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wfs/providers/notification_provider.dart';

/// ตัวอย่างการใช้งาน NotificationService
///
/// ใช้สำหรับแสดง notification จากข้อมูลที่ fetch จาก API
/// ไม่ใช้ FCM (Firebase Cloud Messaging)
class NotificationExamplePage extends ConsumerStatefulWidget {
  const NotificationExamplePage({super.key});

  @override
  ConsumerState<NotificationExamplePage> createState() => _NotificationExamplePageState();
}

class _NotificationExamplePageState extends ConsumerState<NotificationExamplePage> {
  int _notificationId = 0;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    final notificationService = ref.watch(notificationServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Examples')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('ตัวอย่างการใช้งาน Local Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // แสดง notification ทันที
          ElevatedButton(
            onPressed: () async {
              await notificationService.showNotification(id: _notificationId++, title: 'แจ้งเตือนทันที', body: 'นี่คือข้อความที่ fetch จาก API', payload: 'instant_notification');
            },
            child: const Text('แสดง Notification ทันที'),
          ),
          const SizedBox(height: 10),

          // กำหนดเวลาแสดง notification
          ElevatedButton(
            onPressed: () async {
              final scheduledDate = DateTime.now().add(const Duration(seconds: 5));
              await notificationService.scheduleNotification(
                id: _notificationId++,
                title: 'แจ้งเตือนตามเวลา',
                body: 'นัดหมายในอีก 5 วินาที',
                scheduledDate: scheduledDate,
                payload: 'scheduled_notification',
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ตั้งเวลาแจ้งเตือนในอีก 5 วินาที')));
              }
            },
            child: const Text('ตั้งเวลาแจ้งเตือน (5 วินาที)'),
          ),
          const SizedBox(height: 10),

          // แสดง notification แบบซ้ำ
          ElevatedButton(
            onPressed: () async {
              await notificationService.schedulePeriodicNotification(
                id: 999, // ใช้ ID เดียวกันเพื่อไม่ให้ซ้ำ
                title: 'แจ้งเตือนซ้ำ',
                body: 'แจ้งเตือนทุกนาที',
                repeatInterval: RepeatInterval.everyMinute,
                payload: 'periodic_notification',
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ตั้งค่าแจ้งเตือนทุกนาที')));
              }
            },
            child: const Text('แจ้งเตือนทุกนาที'),
          ),
          const SizedBox(height: 20),

          // ยกเลิก notification
          ElevatedButton.icon(
            onPressed: () async {
              await notificationService.cancelNotification(999);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ยกเลิกการแจ้งเตือนซ้ำแล้ว')));
              }
            },
            icon: const Icon(Icons.cancel),
            label: const Text('ยกเลิกการแจ้งเตือนซ้ำ'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          ),
          const SizedBox(height: 10),

          // ยกเลิกทั้งหมด
          ElevatedButton.icon(
            onPressed: () async {
              await notificationService.cancelAllNotifications();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ยกเลิกการแจ้งเตือนทั้งหมดแล้ว')));
              }
            },
            icon: const Icon(Icons.clear_all),
            label: const Text('ยกเลิกทั้งหมด'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
          const SizedBox(height: 20),

          // แสดง pending notifications
          ElevatedButton.icon(
            onPressed: () async {
              final pending = await notificationService.getPendingNotifications();
              if (mounted) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Pending Notifications'),
                    content: Text(pending.isEmpty ? 'ไม่มีการแจ้งเตือนที่รอ' : 'จำนวน: ${pending.length}\n\n${pending.map((e) => '- ${e.title}').join('\n')}'),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('ปิด'))],
                  ),
                );
              }
            },
            icon: const Icon(Icons.list),
            label: const Text('ดู Pending Notifications'),
          ),
          const SizedBox(height: 20),

          // ตัวอย่างการใช้กับ API
          const Divider(),
          const Text('ตัวอย่างการใช้กับ API:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
            child: const Text('''// ตัวอย่างใน Service หรือ Provider
Future<void> fetchAndNotify() async {
  // Fetch data from API
  final response = await api.getData();
  
  // ตรวจสอบเงื่อนไขแจ้งเตือน
  if (response.hasNewAppointment) {
    await NotificationService().showNotification(
      id: response.id,
      title: 'นัดหมายใหม่',
      body: 'คุณมีนัดหมายใหม่: \${response.title}',
      payload: 'appointment_\${response.id}',
    );
  }
}

// ตั้งเวลาเช็คข้อมูลจาก API
void scheduleDataCheck() {
  Timer.periodic(Duration(minutes: 15), (timer) {
    fetchAndNotify();
  });
}''', style: TextStyle(fontFamily: 'monospace', fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
