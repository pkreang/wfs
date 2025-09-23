import 'package:flutter/material.dart';
import 'package:wfs/widgets/app_sheet.dart';
import 'package:wfs/features/company/models/company.dart';
import 'package:wfs/widgets/form_info_tile.dart';
import 'package:wfs/utility/app_text.dart';

class FormCompanyWithDataTile extends StatelessWidget {
  final List<Company> companies;
  final String companyID;
  final String companyName;
  final void Function(Company company) onSelected;
  final void Function(String companyID) onRemove;

  const FormCompanyWithDataTile({required this.companyID, required this.companyName, required this.companies, required this.onSelected, required this.onRemove, super.key});

  @override
  Widget build(BuildContext context) {
    return FormInfoTile(
      label: 'company',
      value: companyID == ""
          ? GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => AppSheet.openCompanyWithDataSheet(context: context, companyID: companyID, companyies: companies, onSelected: onSelected),
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
                    onTap: () => AppSheet.openCompanyWithDataSheet(context: context, companyID: companyID, companyies: companies, onSelected: onSelected),
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
