import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

class AppDialogs {
  static void success(BuildContext context, {String? message}) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      customHeader: Icon(Icons.check_circle, color: Colors.green, size: 50),
      animType: AnimType.bottomSlide,
      title: 'สำเร็จ ✅',
      desc: message ?? 'บันทึกข้อมูลเรียบร้อยแล้ว',
      btnOkOnPress: () {},
    ).show();
  }

  static void alert(BuildContext context, {String? message, String? title}) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      customHeader: Icon(Icons.check_circle, color: Colors.green, size: 50),
      animType: AnimType.bottomSlide,
      title: title ?? "",
      desc: message ?? "",
      btnOkOnPress: () {},
    ).show();
  }

  static void error(BuildContext context, {String? message}) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      customHeader: Icon(Icons.cancel, color: Colors.green, size: 50),
      animType: AnimType.leftSlide,
      title: 'ผิดพลาด ❌',
      desc: message ?? 'ไม่สามารถบันทึกข้อมูลได้',
      btnOkOnPress: () {},
    ).show();
  }
}
