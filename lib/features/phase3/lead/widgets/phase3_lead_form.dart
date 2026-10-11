import 'package:flutter/material.dart';
import 'package:wfs/widgets/app_text_form_field.dart';
import 'package:wfs/widgets/form_info_tile.dart';

class Phase3LeadForm extends StatelessWidget {
  final TextEditingController leadNameController;
  final TextEditingController companyNameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController sourceController;
  final TextEditingController interestedProductController;
  final TextEditingController dealValueController;
  final TextEditingController noteController;

  const Phase3LeadForm({
    required this.leadNameController,
    required this.companyNameController,
    required this.phoneController,
    required this.emailController,
    required this.sourceController,
    required this.interestedProductController,
    required this.dealValueController,
    required this.noteController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FormInfoTile(
          label: 'Lead Name',
          value: AppTextFormField(controller: leadNameController),
          isHideIcon: true,
        ),
        FormInfoTile(
          label: 'Company',
          value: AppTextFormField(controller: companyNameController),
          isHideIcon: true,
        ),
        FormInfoTile(
          label: 'Phone',
          value: AppTextFormField(
            controller: phoneController,
            isNumberOnly: true,
          ),
          isHideIcon: true,
        ),
        FormInfoTile(
          label: 'Email',
          value: AppTextFormField(controller: emailController),
          isHideIcon: true,
        ),
        FormInfoTile(
          label: 'Source',
          value: AppTextFormField(controller: sourceController),
          isHideIcon: true,
        ),
        FormInfoTile(
          label: 'Product',
          value: AppTextFormField(controller: interestedProductController),
          isHideIcon: true,
        ),
        FormInfoTile(
          label: 'Deal Value',
          value: AppTextFormField(
            controller: dealValueController,
            isNumberOnly: true,
            allowDecimal: true,
          ),
          isHideIcon: true,
        ),
        FormInfoTile(
          label: 'Note',
          value: AppTextFormField(controller: noteController, maxLines: 4),
          height: 112,
          isHideIcon: true,
          isShowBorderBottom: true,
        ),
      ],
    );
  }
}
