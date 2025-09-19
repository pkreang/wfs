import 'package:flutter/material.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';

class AppActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final Color splashColor;

  const AppActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.width = 70,
    this.height = 58,
    this.borderRadius = 11,
    this.padding = const EdgeInsets.all(6),
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.iconColor = AppUtility.colorPrimary,
    this.textColor = AppUtility.colorPrimary,
    this.splashColor = const Color(0x33007AFF),
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    return Material(
      color: backgroundColor,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        splashColor: splashColor,
        highlightColor: Colors.transparent,
        child: SizedBox(
          width: width,
          height: height,
          child: Padding(
            padding: padding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor, size: 24),
                AppText(label: title, textColor: textColor, fontSize: 12, lineHeight: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

