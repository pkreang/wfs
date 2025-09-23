import 'package:flutter/material.dart';
import 'package:wfs/features/company/models/company.dart';
import 'package:wfs/utility/app_text.dart';
import 'package:wfs/widgets/app_sheet.dart';
import 'package:wfs/widgets/form_info_tile.dart';

class FormCompanyTile extends StatelessWidget {
  final String companyID;
  final String companyName;
  final void Function(Company company) onSelected;
  final void Function(String companyID) onRemove;

  const FormCompanyTile({required this.companyID, required this.companyName, required this.onSelected, required this.onRemove, super.key});

  @override
  Widget build(BuildContext context) {
    return FormInfoTile(
      label: 'company',
      value: companyID == ""
          ? GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => AppSheet.openCompanySheet(context: context, companyID: companyID, onSelected: onSelected),
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
                    onTap: () => AppSheet.openCompanySheet(context: context, companyID: companyID, onSelected: onSelected),
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
//     // return Container(
//     //   decoration: const BoxDecoration(
//     //     color: Colors.white,
//     //     border: Border(top: AppUtility.borderSide, bottom: AppUtility.borderSide),
//     //   ),
//     //   child: Stack(
//     //     children: [
//     //       const Positioned(
//     //         left: 16 + 100,
//     //         top: 0,
//     //         bottom: 0,
//     //         child: SizedBox(
//     //           width: AppUtility.borderWidth,
//     //           child: ColoredBox(color: AppUtility.colorGrey),
//     //         ),
//     //       ),
//     //       Row(
//     //         crossAxisAlignment: CrossAxisAlignment.center,
//     //         children: [
//     //           const SizedBox(width: 16),
//     //           const SizedBox(
//     //             width: 100,
//     //             child: Center(
//     //               child: AppText(label: 'companys', textColor: AppUtility.colorPrimary),
//     //             ),
//     //           ),
//     //           Expanded(
//     //             child: Column(
//     //               mainAxisSize: MainAxisSize.min,
//     //               crossAxisAlignment: CrossAxisAlignment.start,
//     //               children: [
//     //                 ListView.builder(
//     //                   padding: EdgeInsets.zero,
//     //                   shrinkWrap: true,
//     //                   physics: const NeverScrollableScrollPhysics(),
//     //                   itemCount: companies.length,
//     //                   itemBuilder: (_, index) {
//     //                     final company = companies[index];

//     //                     return Container(
//     //                       decoration: const BoxDecoration(
//     //                         border: Border(
//     //                           bottom: BorderSide(color: AppUtility.colorGrey, width: AppUtility.borderWidth),
//     //                         ),
//     //                       ),
//     //                       height: 44,
//     //                       child: Row(
//     //                         children: [
//     //                           GestureDetector(
//     //                             // onTap: () => removeCompany(company, companys),
//     //                             child: const Padding(
//     //                               padding: EdgeInsets.only(left: 16),
//     //                               child: Icon(Icons.remove_circle, color: Color(0xFFFF382B), size: 24),
//     //                             ),
//     //                           ),
//     //                           Expanded(
//     //                             child: GestureDetector(
//     //                               onTap: () => AppSheet.openCompanySheet(context: context, companyID: company.companyID ?? '', onSelected: onSelected),
//     //                               child: Padding(
//     //                                 padding: const EdgeInsets.only(left: 16),
//     //                                 child: AppText(label: company.companyName ?? ""),
//     //                               ),
//     //                             ),
//     //                           ),
//     //                         ],
//     //                       ),
//     //                     );
//     //                   },
//     //                 ),
//     //                 if (companies.isEmpty)
//     //                   GestureDetector(
//     //                     onTap: () => AppSheet.openCompanySheet(context: context, companyID: '', onSelected: onSelected),
//     //                     child: const SizedBox(
//     //                       height: 44,
//     //                       child: Row(
//     //                         children: [
//     //                           SizedBox(width: 16),
//     //                           Icon(Icons.add_circle, color: Color(0xFF31C859), size: 24),
//     //                           SizedBox(width: 16),
//     //                           AppText(label: 'add company'),
//     //                         ],
//     //                       ),
//     //                     ),
//     //                   ),
//     //               ],
//     //             ),
//     //           ),
//     //         ],
//     //       ),
//     //     ],
//     //   ),
//     // );
//   }
// }
