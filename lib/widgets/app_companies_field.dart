import 'package:flutter/material.dart';
import 'package:wfs/models/company_model.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';

class AppCompaniesField extends StatelessWidget {
  final List<Company> companies;
  final VoidCallback onAdd;
  final void Function(Company company) onEdit;
  final void Function(Company company) onRemove;
  final String label;
  final double labelWidth;

  const AppCompaniesField({
    super.key,
    required this.companies,
    required this.onAdd,
    required this.onEdit,
    required this.onRemove,
    this.label = 'companys',
    this.labelWidth = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: AppUtility.borderSide, bottom: AppUtility.borderSide),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 16 + labelWidth,
            top: 0,
            bottom: 0,
            child: const SizedBox(
              width: AppUtility.borderWidth,
              child: ColoredBox(color: AppUtility.colorGray),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 16),
              SizedBox(
                width: labelWidth,
                child: Center(
                  child: AppText(label: label, textColor: AppUtility.colorPrimary),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: companies.length,
                      itemBuilder: (_, index) {
                        final company = companies[index];

                        return Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: AppUtility.colorGray, width: AppUtility.borderWidth),
                            ),
                          ),
                          height: 44,
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => onRemove(company),
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 16),
                                  child: Icon(Icons.remove_circle, color: Color(0xFFFF382B), size: 24),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => onEdit(company),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: AppText(label: company.companyName ?? ''),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    if (companies.isEmpty)
                      GestureDetector(
                        onTap: onAdd,
                        child: const SizedBox(
                          height: 44,
                          child: Row(
                            children: [
                              SizedBox(width: 16),
                              Icon(Icons.add_circle, color: Color(0xFF31C859), size: 24),
                              SizedBox(width: 16),
                              AppText(label: 'add company'),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

