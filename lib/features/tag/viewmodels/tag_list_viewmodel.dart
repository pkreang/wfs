import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/features/tag/models/tag.dart';
import 'package:wfs/features/tag/services/tag_service.dart';

@immutable
class TagListState {
  final AsyncValue<List<Tag>> tags;
  final List<Tag> selected;

  const TagListState({required this.tags, this.selected = const []});

  TagListState copyWith({AsyncValue<List<Tag>>? tags, List<Tag>? selected}) {
    return TagListState(tags: tags ?? this.tags, selected: selected ?? this.selected);
  }
}

class TagListViewModel extends StateNotifier<TagListState> {
  TagListViewModel(this.ref, {TagService? service}) : _service = service ?? TagService(), super(const TagListState(tags: AsyncValue.loading())) {
    fetch();
  }

  final Ref ref;
  final TagService _service;
  bool _isFetching = false;

  Future<void> fetch() async {
    if (_isFetching) return;
    _isFetching = true;

    final tagsAsync = await AsyncValue.guard(() => _service.fetchTags(ref));
    state = state.copyWith(tags: tagsAsync);

    _isFetching = false;
  }

  void setSelected(List<Tag> tags) {
    state = state.copyWith(selected: tags);
  }
}
