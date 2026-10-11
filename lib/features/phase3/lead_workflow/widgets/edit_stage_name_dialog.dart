import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';
import 'package:wfs/widgets/app_text_form_field.dart';

class EditStageNameDialog {
  static Future<String?> show({required BuildContext context, required String title, String initialValue = '', required bool Function(String name) isDuplicateName}) async {
    return showCupertinoDialog<String>(
      context: context,
      builder: (dialogContext) {
        return _EditStageNameDialogContent(title: title, initialValue: initialValue, isDuplicateName: isDuplicateName);
      },
    );
  }
}

class _EditStageNameDialogContent extends StatefulWidget {
  final String title;
  final String initialValue;
  final bool Function(String name) isDuplicateName;

  const _EditStageNameDialogContent({required this.title, required this.initialValue, required this.isDuplicateName});

  @override
  State<_EditStageNameDialogContent> createState() => _EditStageNameDialogContentState();
}

class _EditStageNameDialogContentState extends State<_EditStageNameDialogContent> {
  late final TextEditingController _controller;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _validationError = 'State name is required');
      return;
    }
    if (widget.isDuplicateName(name)) {
      setState(() => _validationError = 'State name already exists');
      return;
    }
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(widget.title, textScaler: TextScaler.noScaling),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: AppTextFormField(
              controller: _controller,
              hintText: 'State name',
              isShowBorder: true,
              onChanged: (_) {
                if (_validationError != null) {
                  setState(() => _validationError = null);
                }
              },
            ),
          ),
          if (_validationError != null) ...[
            const SizedBox(height: 8),
            Text(
              _validationError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
              textScaler: TextScaler.noScaling,
            ),
          ],
        ],
      ),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(context).pop(),
          child: AppText(label: 'Cancel', textColor: AppUtility.textGray),
        ),
        CupertinoDialogAction(
          onPressed: _save,
          child: AppText(label: 'Save', textColor: AppUtility.colorPrimary),
        ),
      ],
    );
  }
}
