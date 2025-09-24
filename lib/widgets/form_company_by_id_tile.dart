import 'package:flutter/material.dart';
import 'package:wfs/features/company/models/company.dart';
import 'package:wfs/utility/app_text.dart';
import 'package:wfs/widgets/app_sheet.dart';
import 'package:wfs/widgets/form_info_tile.dart';

class FormCompanyByIDTile extends StatelessWidget {
  final String companyID;
  final String companyName;
  final void Function(Company company) onSelected;
  final void Function(String companyID) onRemove;

  const FormCompanyByIDTile({required this.companyID, required this.companyName, required this.onSelected, required this.onRemove, super.key});

  @override
  Widget build(BuildContext context) {
    return FormInfoTile(
      label: 'company',
      value: companyID == "" || companyName == ""
          ? GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => AppSheet.openCompanyByIDSheet(context: context, companyID: companyID, onSelected: onSelected),
              child: const SizedBox(
                height: 44,
                child: Row(
                  spacing: 16,
                  children: [
                    Icon(Icons.add_circle, color: Color(0xFF31C859), size: 24),
                    AppText(label: 'add company'),
                  ],
                ),
              ),
            )
          : Row(
              children: [
                GestureDetector(
                  onTap: () => onRemove(companyID),
                  child: Icon(Icons.remove_circle, color: Color(0xFFFF382B), size: 24),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => AppSheet.openCompanyByIDSheet(context: context, companyID: companyID, onSelected: onSelected),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: AppText(label: companyName),
                    ),
                  ),
                ),
              ],
            ),
      isShowBorderBottom: true,
      isHideIcon: true,
    );
  }
}
