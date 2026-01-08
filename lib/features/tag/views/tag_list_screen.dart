import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/features/tag/models/tag.dart';
import 'package:wfs/features/tag/views/widgets/tag_list_view.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/utility/validator.dart';
import 'package:wfs/widgets/app_text.dart';
import 'package:wfs/widgets/app_text_form_field.dart';

class TagListScreen extends ConsumerWidget {
  final String title;
  final ValueChanged<Tag>? onTap;
  final ValueChanged<List<Tag>>? onSubmitSelected;
  final List<Tag> initialSelected;

  const TagListScreen({this.title = 'Tags', this.onTap, this.onSubmitSelected, this.initialSelected = const [], super.key});

  Future<bool> showCreateTagDialog({required BuildContext context, required WidgetRef ref}) async {
    var tagNameValue = '';
    var completed = false;
    String? validationError;

    await showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) => CupertinoAlertDialog(
            title: const Text("Create tag", textScaler: TextScaler.noScaling),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Material(
                  color: Colors.transparent,
                  child: AppTextFormField(
                    controller: null,
                    hintText: 'tag name',
                    isShowBorder: true,
                    onChanged: (v) {
                      tagNameValue = v;
                      if (validationError != null) setState(() => validationError = null);
                    },
                  ),
                ),
                if ((validationError ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'กรุณากรอก tag name',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                    textScaler: TextScaler.noScaling,
                  ),
                ],
              ],
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: AppText(label: 'Cancel', textColor: AppUtility.textGray),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () async {
                  final tagName = tagNameValue.trim();
                  if (Validator.required(tagName) != null) {
                    setState(() => validationError = 'required');
                    return;
                  }

                  try {
                    await ref
                        .read(tagCreateProvider.notifier)
                        .createTag(
                          tagName: tagName,
                          onSuccess: () {
                            ref.refresh(tagListProvider);
                            // final now = DateTime.now();
                            // final bool isSameDate = currentDate.year == now.year && currentDate.month == now.month && currentDate.day == now.day;

                            // if (isSameDate) {
                            //   ref.invalidate(appointmentsProvider(DateTime(currentDate.year, currentDate.month, currentDate.day)));
                            //   ref.invalidate(appointmentSummaryProvider(DateTime(currentDate.year, currentDate.month, currentDate.day)));
                            // }

                            // ref.read(selectedMonthProvider.notifier).setMonth(currentDate);
                            // ref.read(selectedDateProvider.notifier).setDate(currentDate);

                            // ref.read(appointmentMarkDateProvider(DateTime(currentDate.year, currentDate.month, 1)).notifier).refresh();
                            // ref.read(appointmentsByDateProvider(DateFormat("yyyy-MM-dd").format(currentDate)).notifier).refresh();
                          },
                        );
                    completed = true;
                  } finally {
                    Navigator.of(dialogContext).pop();
                  }
                },
                child: AppText(label: 'Create', textColor: AppUtility.colorPrimary),
              ),
            ],
          ),
        );
      },
    );

    return completed;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tagListProvider);
    final tagsAsync = state.tags;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: AppUtility.borderWidth,
        iconTheme: const IconThemeData(color: AppUtility.colorPrimary),
        title: Text(
          title,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          if (onSubmitSelected != null)
            TextButton(
              onPressed: state.selected.isNotEmpty
                  ? () {
                      ref.read(tagListProvider.notifier).setSelected(state.selected);
                      onSubmitSelected?.call(state.selected);
                      // Navigator.of(context).pop();
                      Navigator.of(context).pop(state.selected);
                    }
                  : null,
              child: AppText(label: 'เลือก', textColor: state.selected.isNotEmpty ? AppUtility.colorPrimary : AppUtility.textGray),
            ),
        ],
      ),
      body: tagsAsync.when(
        data: (tags) {
          final selected = initialSelected.isNotEmpty ? initialSelected : state.selected;
          return TagListView(
            tags: tags,
            onTap: onTap,
            initialSelected: selected,
            physics: const ClampingScrollPhysics(),
            onSelectionChanged: (selectedTags) {
              ref.read(tagListProvider.notifier).setSelected(selectedTags);
            },
            onSubmitSelected: (selectedTags) {
              ref.read(tagListProvider.notifier).setSelected(selectedTags);
              onSubmitSelected?.call(selectedTags);
              // Navigator.of(context).pop(selectedTags);
            },
          );
        },
        error: (err, _) => Center(
          child: AppText(label: err.toString(), textColor: AppUtility.colorRed),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      backgroundColor: const Color(0xFFF2F2F7),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: TextButton.icon(
          // onPressed: () => _showAddTagDialog(context, ref),
          onPressed: () => showCreateTagDialog(context: context, ref: ref),

          icon: const Icon(Icons.add, size: 18),
          label: AppText(label: 'เพิ่มแท็ก', textColor: AppUtility.colorPrimary),
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue,
            backgroundColor: const Color(0xFFE3F2FD),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
    );
  }
}
