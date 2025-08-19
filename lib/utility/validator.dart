class Validator {
  static String? required(String? value, {String message = "กรุณากรอกข้อมูล"}) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? email(String? value, {String message = "อีเมลไม่ถูกต้อง"}) {
    if (value == null || value.trim().isEmpty) {
      return null; // ให้ required ตรวจเอง
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return message;
    }
    return null;
  }

  static String? minLength(String? value, int min, {String? message}) {
    if (value == null || value.length < min) {
      return message ?? "กรุณากรอกอย่างน้อย $min ตัวอักษร";
    }
    return null;
  }

  static String? maxLength(String? value, int max, {String? message}) {
    if (value != null && value.length > max) {
      return message ?? "กรุณากรอกไม่เกิน $max ตัวอักษร";
    }
    return null;
  }

  static String? number(String? value, {String message = "กรุณากรอกตัวเลข"}) {
    if (value == null || value.isEmpty) return null;
    if (double.tryParse(value) == null) {
      return message;
    }
    return null;
  }
}
