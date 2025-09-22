import 'package:flutter/material.dart';
import 'package:wfs/features/appointment/models/address.dart';
import 'package:wfs/features/appointment/widgets/app_sheet.dart';
import 'package:wfs/lib/widgets/form_info_tile.dart';
import 'package:wfs/models/district_model.dart';
import 'package:wfs/models/province_model.dart';
import 'package:wfs/models/subdistrict_model.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text_form_field.dart';

import '../../features/appointment/widgets/app_text.dart';

class FormAddress extends StatelessWidget {
  final TextEditingController addressController;
  final Address address;
  final void Function(Address) onSelected;

  const FormAddress({required this.addressController, required this.address, required this.onSelected, super.key});

  void handleProvinceSelected(Province province) {
    onSelected(
      address.copyWith(
        address: address.address,
        provinceID: province.provinceID,
        provinceName: province.provinceName,
        districtID: null,
        districtName: null,
        subDistrictID: null,
        subDistrictName: null,
        postCode: null,
      ),
    );
  }

  void handleDistrictSelected(District district) {
    onSelected(address.copyWith(districtID: district.districtID, districtName: district.districtName, subDistrictID: null, subDistrictName: null, postCode: null));
  }

  void handleSubDistrictSelected(Subdistrict subDistrict) {
    onSelected(address.copyWith(subDistrictID: subDistrict.subDistrictID, subDistrictName: subDistrict.subDistrictName, postCode: subDistrict.postCode));
  }

  @override
  Widget build(BuildContext context) {
    addressController.text = address.address ?? '';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: AppUtility.borderSide, bottom: AppUtility.borderSide),
      ),
      child: Stack(
        children: [
          const Positioned(
            left: 16 + 100,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: AppUtility.borderWidth,
              child: ColoredBox(color: AppUtility.colorGray),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 16),
              const SizedBox(
                width: 100,
                child: Center(
                  child: AppText(label: 'address', textColor: Color(0xFF007AFF)),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    addressField(
                      child: AppTextFormField(
                        controller: addressController,
                        hintText: 'ที่อยู่',
                        onChanged: (value) {
                          addressController.text = value;
                          onSelected(address.copyWith(address: value));
                        },
                      ),
                    ),
                    addressField(
                      hasRightBorder: true,
                      child: FormInfoTile(
                        label: address.provinceName ?? '',
                        value: address.provinceName == null || address.provinceName == '' ? textHint(label: 'จังหวัด') : AppText(label: address.provinceName ?? ''),
                        onTap: () => AppSheet.openProvinceSheet(context: context, provinceID: (address.provinceID ?? "").toString(), onSelected: (province) => handleProvinceSelected(province)),
                        isHideLabel: true,
                        isHideBorderTop: true,
                        isShowBorderMiddle: false,
                        isHideIcon: true,
                      ),
                    ),
                    addressField(
                      child: FormInfoTile(
                        label: address.districtName ?? '',
                        value: address.districtName == null || address.districtName == '' ? textHint(label: 'เขต/อําเภอ') : AppText(label: address.districtName ?? ''),
                        onTap: () => AppSheet.openDistrictSheet(
                          context: context,
                          provinceID: (address.provinceID ?? "").toString(),
                          districtID: (address.districtID ?? "").toString(),
                          onSelected: (district) => handleDistrictSelected(district),
                        ),
                        // isShowBorderBottom: true,
                        isHideLabel: true,
                        isHideBorderTop: true,
                        isShowBorderMiddle: false,
                        isHideIcon: true,
                      ),
                    ),
                    addressField(
                      hasRightBorder: false,
                      child: FormInfoTile(
                        label: address.subDistrictName ?? '',
                        value: address.subDistrictName == null || address.subDistrictName == '' ? textHint(label: 'แขวง/ตำบล') : AppText(label: address.subDistrictName ?? ''),
                        onTap: () => AppSheet.openSubDistrictSheet(
                          context: context,
                          districtID: (address.districtID ?? "").toString(),
                          subdistrictID: (address.subDistrictID ?? "").toString(),
                          onSelected: (subDistrict) => handleSubDistrictSelected(subDistrict),
                        ),
                        isHideLabel: true,
                        isHideBorderTop: true,
                        isShowBorderMiddle: false,
                        // isShowBorderBottom: true,
                        isHideIcon: true,
                      ),
                    ),
                    addressField(
                      child: address.postCode == null || address.postCode == '' ? textHint(label: 'รหัสไปรษณีย์') : AppText(label: address.postCode ?? ""),
                      hasBottomBorder: false,
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

  Widget addressField({required Widget child, bool hasRightBorder = false, bool hasBottomBorder = true}) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        border: Border(right: hasRightBorder ? AppUtility.borderSide : BorderSide.none, bottom: hasBottomBorder ? AppUtility.borderSide : BorderSide.none),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 16),
      child: child,
    );
  }

  Widget textHint({required String label}) {
    return AppText(label: label, textColor: Colors.grey.shade400);
  }
}
