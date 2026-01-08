import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/core/http/api_client.dart';
import 'package:wfs/features/tag/models/tag.dart';
import 'package:wfs/features/tag/services/tag_service.dart';

@immutable
class TagCreateState {
  final AsyncValue<Tag> data;
  final bool isDirty;
  final bool isLoading;
  final String? errorMessage;

  const TagCreateState({required this.data, this.isDirty = false, this.isLoading = false, this.errorMessage});

  TagCreateState copyWith({AsyncValue<Tag>? data, bool? isDirty, bool? isLoading, String? errorMessage, bool clearErrorMessage = false}) =>
      TagCreateState(data: data ?? this.data, isDirty: isDirty ?? this.isDirty, isLoading: isLoading ?? this.isLoading, errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage));
}

class TagCreateViewModel extends StateNotifier<TagCreateState> {
  TagCreateViewModel(this.ref) : super(const TagCreateState(data: AsyncValue.loading())) {
    state = state.copyWith(data: AsyncValue.data(Tag()), isDirty: false);
  }

  final Ref ref;

  TagService get _tagService => ref.read(tagServiceProvider);

  void setTagName(String tagName) {
    state = state.copyWith(data: state.data.whenData((v) => v.copyWith(tagName: tagName)), isDirty: true, clearErrorMessage: true);
  }

  Future<bool> createTag({required String tagName, required VoidCallback onSuccess}) async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await _tagService.createTag(ref, name: tagName);
      if (result) {
        onSuccess.call();
      }

      return result;
    } catch (e, st) {
      state = state.copyWith(errorMessage: e is ApiException ? e.message : 'Request failed');
    } finally {
      state = state.copyWith(isLoading: false);
    }

    return false;
  }
}
