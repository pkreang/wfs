// import 'package:flutter/material.dart';
// import 'package:wfs/features/phase3/lead/models/phase3_lead_create_request.dart';
// import 'package:wfs/features/phase3/lead/models/phase3_lead_model.dart';
// import 'package:wfs/features/phase3/lead/repositories/phase3_lead_repository.dart';
// import 'package:wfs/features/phase3/lead/services/phase3_lead_service.dart';
// import 'package:wfs/features/phase3/lead/widgets/phase3_lead_form.dart';
// import 'package:wfs/utility/app_utility.dart';
// import 'package:wfs/utility/appdialogs.dart';
// import 'package:wfs/widgets/app_text.dart';

// class Phase3LeadCreatePage extends StatefulWidget {
//   const Phase3LeadCreatePage({super.key});

//   @override
//   State<Phase3LeadCreatePage> createState() => _Phase3LeadCreatePageState();
// }

// class _Phase3LeadCreatePageState extends State<Phase3LeadCreatePage> {
//   final Phase3LeadRepository _repository = Phase3LeadRepository(
//     service: Phase3LeadService(),
//   );
//   final TextEditingController _leadNameController = TextEditingController();
//   final TextEditingController _companyNameController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _sourceController = TextEditingController();
//   final TextEditingController _interestedProductController =
//       TextEditingController();
//   final TextEditingController _dealValueController = TextEditingController();
//   final TextEditingController _noteController = TextEditingController();
//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _leadNameController.dispose();
//     _companyNameController.dispose();
//     _phoneController.dispose();
//     _emailController.dispose();
//     _sourceController.dispose();
//     _interestedProductController.dispose();
//     _dealValueController.dispose();
//     _noteController.dispose();
//     super.dispose();
//   }

//   Future<void> _createLead() async {
//     final leadName = _leadNameController.text.trim();
//     final phone = _phoneController.text.trim();
//     final email = _emailController.text.trim();
//     final dealValueText = _dealValueController.text.trim();

//     if (leadName.isEmpty) {
//       AppDialogs.error(context, message: 'กรุณากรอก Lead name');
//       return;
//     }
//     if (phone.isEmpty && email.isEmpty) {
//       AppDialogs.error(context, message: 'กรุณากรอก Phone หรือ Email');
//       return;
//     }
//     final dealValue = dealValueText.isEmpty
//         ? null
//         : double.tryParse(dealValueText);
//     if (dealValueText.isNotEmpty && dealValue == null) {
//       AppDialogs.error(context, message: 'Deal value ต้องเป็นตัวเลข');
//       return;
//     }

//     setState(() => _isLoading = true);
//     try {
//       final lead = await _repository.createLead(
//         Phase3LeadCreateRequest(
//           leadName: leadName,
//           companyName: _emptyToNull(_companyNameController.text),
//           phone: _emptyToNull(phone),
//           email: _emptyToNull(email),
//           source: _emptyToNull(_sourceController.text),
//           interestedProduct: _emptyToNull(_interestedProductController.text),
//           dealValue: dealValue,
//           note: _emptyToNull(_noteController.text),
//         ),
//       );
//       if (!mounted) return;
//       Navigator.of(context).pop<Phase3LeadModel>(lead);
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   String? _emptyToNull(String value) {
//     final trimmed = value.trim();
//     return trimmed.isEmpty ? null : trimmed;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         GestureDetector(
//           behavior: HitTestBehavior.opaque,
//           onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
//           child: Scaffold(
//             backgroundColor: const Color(0xFFEEEEEE),
//             appBar: AppBar(
//               centerTitle: true,
//               backgroundColor: const Color(0xFFEEEEEE),
//               leadingWidth: 100,
//               leading: GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: Row(
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.chevron_left),
//                       onPressed: null,
//                       style: ButtonStyle(
//                         iconColor: WidgetStateProperty.all(
//                           AppUtility.colorPrimary,
//                         ),
//                       ),
//                     ),
//                     const AppText(
//                       label: 'Back',
//                       textColor: AppUtility.colorPrimary,
//                     ),
//                   ],
//                 ),
//               ),
//               title: const AppText(
//                 label: 'Create Lead',
//                 fontSize: 17,
//                 fontWeight: FontWeight.w600,
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: _createLead,
//                   style: TextButton.styleFrom(
//                     foregroundColor: AppUtility.colorPrimary,
//                   ),
//                   child: const AppText(
//                     label: 'Done',
//                     textColor: AppUtility.colorPrimary,
//                   ),
//                 ),
//               ],
//             ),
//             body: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               child: Phase3LeadForm(
//                 leadNameController: _leadNameController,
//                 companyNameController: _companyNameController,
//                 phoneController: _phoneController,
//                 emailController: _emailController,
//                 sourceController: _sourceController,
//                 interestedProductController: _interestedProductController,
//                 dealValueController: _dealValueController,
//                 noteController: _noteController,
//               ),
//             ),
//           ),
//         ),
//         if (_isLoading) ...[
//           const ModalBarrier(color: Color(0x66000000), dismissible: false),
//           const Center(
//             child: CircularProgressIndicator(color: AppUtility.colorPrimary),
//           ),
//         ],
//       ],
//     );
//   }
// }
