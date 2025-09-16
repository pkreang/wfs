import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

class AppDialogs {
  static void success(BuildContext context, {String? message, void Function()? btnOkOnPress}) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      customHeader: Icon(Icons.check_circle, color: Colors.green, size: 50),
      animType: AnimType.bottomSlide,
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
      title: 'สำเร็จ',
      desc: message ?? 'บันทึกข้อมูลเรียบร้อยแล้ว',
      btnOkOnPress: btnOkOnPress,
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
      title: 'กรอกข้อมูลไม่ครบ',
      desc: message ?? 'ไม่สามารถบันทึกข้อมูลได้',
      btnOkOnPress: () {},
    ).show();
  }

  static void custom(BuildContext context, {required Widget widget}) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.leftSlide,
      padding: const EdgeInsets.symmetric(vertical: 24),
      dismissOnTouchOutside: false,
      body: widget,
    ).show();
  }
}
