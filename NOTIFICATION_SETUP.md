# Flutter Local Notifications - การตั้งค่าและการใช้งาน

## สิ่งที่ได้ทำการตั้งค่าแล้ว

### 1. Dependencies ที่เพิ่มใน pubspec.yaml
```yaml
flutter_local_notifications: ^20.0.0
timezone: ^0.10.0
flutter_timezone: ^3.0.0
```

### 2. Android Configuration

#### build.gradle.kts
- อัพเดท `compileSdk` เป็น 35
- เปิดใช้งาน desugaring สำหรับ flutter_local_notifications
- เพิ่ม dependency: `desugar_jdk_libs:2.0.4`

#### AndroidManifest.xml
เพิ่ม permissions:
- `POST_NOTIFICATIONS` - สำหรับแจ้งเตือนบน Android 13+
- `VIBRATE` - สำหรับการสั่น
- `RECEIVE_BOOT_COMPLETED` - สำหรับ scheduled notifications
- `SCHEDULE_EXACT_ALARM` - สำหรับกำหนดเวลาแจ้งเตือนแบบแม่นยำ

เพิ่ม receivers:
- `ScheduledNotificationReceiver` - จัดการ scheduled notifications
- `ScheduledNotificationBootReceiver` - กู้คืน notifications หลังรีบูต
- `ActionBroadcastReceiver` - จัดการ notification actions

### 3. iOS Configuration

#### AppDelegate.swift
- เพิ่ม import `flutter_local_notifications`
- ตั้งค่า `UNUserNotificationCenter.current().delegate`
- ตั้งค่า `FlutterLocalNotificationsPlugin.setPluginRegistrantCallback`

### 4. NotificationService

สร้าง `lib/services/notification_service.dart` ที่มีฟังก์ชัน:

- `initialize()` - เริ่มต้น notification service
- `requestPermissions()` - ขอสิทธิ์แจ้งเตือน
- `showNotification()` - แสดงการแจ้งเตือนทันที
- `scheduleNotification()` - กำหนดเวลาแจ้งเตือน
- `schedulePeriodicNotification()` - แจ้งเตือนแบบซ้ำ
- `cancelNotification()` - ยกเลิกการแจ้งเตือน
- `cancelAllNotifications()` - ยกเลิกทั้งหมด
- `getPendingNotifications()` - ดู notifications ที่รอ
- `getActiveNotifications()` - ดู notifications ที่กำลังแสดง

### 5. Provider

สร้าง `lib/providers/notification_provider.dart`:
```dart
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
```

### 6. Main.dart

เพิ่มการ initialize ใน `main()`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();
  runApp(const ProviderScope(child: MyApp()));
}
```

## การใช้งาน

### 1. แสดง Notification ทันที

```dart
final notificationService = ref.read(notificationServiceProvider);

await notificationService.showNotification(
  id: 1,
  title: 'แจ้งเตือนใหม่',
  body: 'คุณมีนัดหมายใหม่',
  payload: 'appointment_123',
);
```

### 2. กำหนดเวลาแจ้งเตือน

```dart
final scheduledDate = DateTime.now().add(Duration(hours: 1));

await notificationService.scheduleNotification(
  id: 2,
  title: 'นัดหมายในอีก 1 ชั่วโมง',
  body: 'เตรียมตัวสำหรับการประชุม',
  scheduledDate: scheduledDate,
  payload: 'meeting_456',
);
```

### 3. แจ้งเตือนแบบซ้ำ

```dart
await notificationService.schedulePeriodicNotification(
  id: 3,
  title: 'การแจ้งเตือนประจำ',
  body: 'เช็คข้อมูลอัพเดท',
  repeatInterval: RepeatInterval.everyMinute, // หรือ hourly, daily, weekly
  payload: 'periodic_check',
);
```

### 4. ตัวอย่างการใช้กับ API

```dart
// ใน Service หรือ Provider
Future<void> checkAndNotify() async {
  try {
    // Fetch ข้อมูลจาก API
    final response = await http.get(apiUrl);
    final data = json.decode(response.body);
    
    // ตรวจสอบเงื่อนไข
    if (data['hasNewAppointment']) {
      final notificationService = NotificationService();
      
      await notificationService.showNotification(
        id: data['appointmentId'],
        title: 'นัดหมายใหม่',
        body: data['appointmentDetails'],
        payload: 'appointment_${data['appointmentId']}',
      );
    }
  } catch (e) {
    print('Error checking notifications: $e');
  }
}

// ตั้งเวลาเช็คข้อมูลทุก 15 นาที
void startPeriodicCheck() {
  Timer.periodic(Duration(minutes: 15), (timer) {
    checkAndNotify();
  });
}
```

### 5. จัดการเมื่อมีการกดที่ Notification

ใน `notification_service.dart` มี callback `_onDidReceiveNotificationResponse` ที่สามารถแก้ไขได้:

```dart
void _onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse) {
  final String? payload = notificationResponse.payload;
  
  // ตัวอย่าง: Navigate ไปหน้าที่เกี่ยวข้อง
  if (payload != null && payload.startsWith('appointment_')) {
    final appointmentId = payload.split('_')[1];
    // Navigator.push(...) หรือใช้ go_router
  }
}
```

## ไฟล์ตัวอย่าง

สร้างไฟล์ `lib/screens/notification_example_page.dart` ที่มีตัวอย่างการใช้งานครบถ้วน

## ขั้นตอนถัดไป

1. รัน `flutter pub get` (ทำแล้ว)
2. ทดสอบบน Android/iOS device จริง (emulator อาจมีข้อจำกัด)
3. ขอ permission จากผู้ใช้ก่อนแสดง notification
4. Customize notification details ตามต้องการ
5. เพิ่ม notification icons สำหรับ Android ใน `android/app/src/main/res/drawable/`

## หมายเหตุสำคัญ

- การแจ้งเตือนบน iOS ต้องทดสอบบน device จริง (ไม่ทำงานบน Simulator)
- Android 13+ ต้องขอ permission `POST_NOTIFICATIONS`
- Scheduled notifications อาจไม่ทำงานบางรุ่นมือถือ (Xiaomi, Huawei) ที่มี battery optimization
- ใช้ unique ID สำหรับแต่ละ notification เพื่อไม่ให้ซ้อนทับกัน

## การ Debug

```dart
// ดู pending notifications
final pending = await notificationService.getPendingNotifications();
print('Pending: ${pending.length}');

// ดู active notifications
final active = await notificationService.getActiveNotifications();
print('Active: ${active.length}');
```
