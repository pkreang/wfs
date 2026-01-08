import 'package:flutter/material.dart';
import 'package:wfs/features/tag/models/tag.dart';
import 'package:wfs/features/tag/views/tag_list_screen.dart';
import 'package:wfs/utility/app_text.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/capsule_widget.dart';
import 'package:wfs/widgets/form_info_tile.dart';

class FormTagWithDataTile extends StatelessWidget {
  final List<Tag> selectedTags;
  final void Function(List<Tag> tags) onSelected;
  final VoidCallback? onClear;
  final bool isEnableRemove;

  const FormTagWithDataTile({required this.selectedTags, required this.onSelected, this.onClear, this.isEnableRemove = true, super.key});

  Future<void> _openSelector(BuildContext context) async {
    final selected = await Navigator.of(context).push<List<Tag>>(
      MaterialPageRoute(
        builder: (_) => TagListScreen(title: 'Tags', initialSelected: selectedTags, onSubmitSelected: (list) => {}),
      ),
    );

    if (selected != null) {
      onSelected(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormInfoTile(
      label: 'tags',
      value: selectedTags.isEmpty
          ? GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _openSelector(context),
              child: const SizedBox(
                height: 44,
                child: Row(
                  spacing: 16,
                  children: [
                    Icon(Icons.add_circle, color: Color(0xFF31C859), size: 24),
                    AppText(label: 'add tag'),
                  ],
                ),
              ),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (isEnableRemove) ...[
                  GestureDetector(
                    onTap: onClear ?? () => onSelected(const []),
                    child: const Icon(Icons.remove_circle, color: Color(0xFFFF382B), size: 24),
                  ),
                  const SizedBox(width: 12),
                ],
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _openSelector(context),
                  child: CapsuleWidget(label: '${selectedTags.length} tag(s)', capsuleStyle: CapsuleStyle(Color(0xFF0689FF), Color.fromRGBO(47, 128, 237, 0.2))),
                ),
              ],
            ),
      isShowBorderBottom: true,
      isHideIcon: true,
    );
  }
}
