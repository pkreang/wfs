import 'package:flutter/material.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';
import 'package:wfs/utility/app_utility.dart';

class FormInfoTile extends StatelessWidget {
  final String label;
  final Widget value;
  final VoidCallback? onTap;
  final double height;
  final bool isHideLabel;
  final bool isHideBorderTop;
  final bool isShowBorderMiddle;
  final bool isShowBorderBottom;
  final bool isHideIcon;

  const FormInfoTile({
    required this.label,
    required this.value,
    this.onTap,
    this.height = 44,
    this.isHideLabel = false,
    this.isHideBorderTop = false,
    this.isShowBorderMiddle = true,
    this.isShowBorderBottom = false,
    this.isHideIcon = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          border: Border(top: isHideBorderTop ? BorderSide.none : AppUtility.borderSide, bottom: isShowBorderBottom ? AppUtility.borderSide : BorderSide.none),
        ),
        child: Row(
          children: [
            if (!isHideLabel) ...[
              const SizedBox(width: 16),
              Container(
                width: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: BorderDirectional(
                    end: isShowBorderMiddle ? const BorderSide(color: AppUtility.colorGray, width: AppUtility.borderWidth) : BorderSide.none,
                  ),
                ),
                child: AppText(label: label, textColor: AppUtility.colorPrimary),
              ),
              const SizedBox(width: 16),
            ],

            Expanded(
              child: Align(alignment: Alignment.centerLeft, child: value),
            ),
            if (!isHideIcon) ...[const Icon(Icons.chevron_right, size: 24, color: AppUtility.colorGray), const SizedBox(width: 8)],
          ],
        ),
      ),
    );
  }
}
