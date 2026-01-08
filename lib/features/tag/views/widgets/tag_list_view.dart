import 'package:flutter/material.dart';
import 'package:wfs/features/tag/models/tag.dart';
import 'package:wfs/utility/app_utility.dart';
import 'package:wfs/widgets/app_text.dart';

class TagListView extends StatefulWidget {
  final List<Tag> tags;
  final ValueChanged<Tag>? onTap;
  final ValueChanged<List<Tag>>? onSubmitSelected;
  final ValueChanged<List<Tag>>? onSelectionChanged;
  final List<Tag> initialSelected;
  final EdgeInsetsGeometry padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const TagListView({
    required this.tags,
    this.onTap,
    this.onSubmitSelected,
    this.onSelectionChanged,
    this.initialSelected = const [],
    this.padding = const EdgeInsets.symmetric(vertical: 8),
    this.physics,
    this.shrinkWrap = false,
    super.key,
  });

  @override
  State<TagListView> createState() => _TagListViewState();
}

class _TagListViewState extends State<TagListView> {
  late Set<int> _selectedIndexes;

  bool get _enableMultiSelect => widget.onSubmitSelected != null;

  @override
  void initState() {
    super.initState();
    _syncSelectedFromInitial();
  }

  @override
  void didUpdateWidget(covariant TagListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSelected != widget.initialSelected || oldWidget.tags != widget.tags) {
      _syncSelectedFromInitial();
    }
  }

  void _syncSelectedFromInitial() {
    _selectedIndexes = <int>{};
    if (widget.initialSelected.isNotEmpty) {
      for (var i = 0; i < widget.tags.length; i++) {
        final tag = widget.tags[i];
        if (widget.initialSelected.any((t) => t.tagId == tag.tagId)) {
          _selectedIndexes.add(i);
        }
      }
    }
  }

  void _toggleSelect(int index) {
    if (!_enableMultiSelect) {
      widget.onTap?.call(widget.tags[index]);
      return;
    }
    setState(() {
      if (_selectedIndexes.contains(index)) {
        _selectedIndexes.remove(index);
      } else {
        _selectedIndexes.add(index);
      }
    });
    final selectedTags = _selectedIndexes.map((i) => widget.tags[i]).toList();
    widget.onSelectionChanged?.call(selectedTags);
  }

  void _handleSubmit() {
    if (!_enableMultiSelect || _selectedIndexes.isEmpty) return;
    final selectedTags = _selectedIndexes.map((i) => widget.tags[i]).toList();
    widget.onSubmitSelected?.call(selectedTags);
  }

  @override
  Widget build(BuildContext context) {
    final listView = ListView.separated(
      padding: widget.padding,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      itemCount: widget.tags.length,
      itemBuilder: (context, index) {
        final tag = widget.tags[index];
        final isSelected = _selectedIndexes.contains(index);
        return InkWell(
          onTap: () => _toggleSelect(index),
          child: Container(
            color: isSelected ? const Color(0xFFE8F0FF) : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: AppText(label: tag.tagName ?? '', fontSize: 15, fontWeight: FontWeight.w600, lineHeight: 20),
                ),
                if (_enableMultiSelect) Icon(isSelected ? Icons.check_circle : Icons.radio_button_unchecked, color: isSelected ? AppUtility.colorPrimary : AppUtility.textGray, size: 20),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const Divider(height: 1, thickness: AppUtility.borderWidth, color: AppUtility.colorGray),
    );

    // Keep original behavior for shrinkWrap; otherwise, return the list directly (no Expanded outside Flex)
    return widget.shrinkWrap ? listView : listView;
  }
}
