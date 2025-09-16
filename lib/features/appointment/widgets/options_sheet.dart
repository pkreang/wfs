import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/features/appointment/widgets/app_cupertino_option.dart';

Future<void> openOptionsSheet<T>({
  required BuildContext context,
  required String title,
  required ProviderListenable<AsyncValue<List<T>>> provider,
  required String Function(T) label,
  required String Function(T) initialKey,
  required String initialValue,
  required void Function(T) onSelected,
}) async {
  final selected = await CupertinoOptionsPicker.show<T>(
    context: context,
    title: title,
    provider: provider,
    label: label,
    initialKey: initialKey,
    initialValue: initialValue,
  );

  if (selected == null) return;
  onSelected(selected);
}

