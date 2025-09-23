import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';

class CupertinoOptionsPicker {
  CupertinoOptionsPicker._();

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required ProviderListenable<AsyncValue<List<T>>> provider,
    required String Function(T) label,
    required String Function(T) initialKey,
    required String initialValue,
  }) {
    return showCupertinoModalPopup<T>(
      context: context,
      barrierColor: CupertinoColors.black.withOpacity(.25),
      builder: (ctx) {
        final bg = CupertinoColors.systemBackground.resolveFrom(ctx);
        final toolbarHeight = 44.0;
        const itemExtent = 32.0;

        return Align(
          alignment: Alignment.bottomCenter,
          child: CupertinoPopupSurface(
            isSurfacePainted: true,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: SizedBox(
                height: 200,
                child: Consumer(
                  builder: (context, ref, _) {
                    final state = ref.watch(provider);

                    return state.when(
                      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF007AFF))),
                      error: (e, st) {
                        debugPrint(st.toString());
                        debugPrint(e.toString());
                        return Center(child: AppText(label: 'No items available'));
                      },
                      data: (items) {
                        if (items.isEmpty) return const Center(child: AppText(label: 'No items available'));

                        final initialIndex = _initialIndexOf<T, String>(items, initialKey, initialValue);
                        var currentIndex = initialIndex;
                        final controller = FixedExtentScrollController(initialItem: initialIndex);

                        return Column(
                          children: [
                            // Toolbar
                            SizedBox(
                              height: toolbarHeight,
                              child: Row(
                                children: [
                                  const SizedBox(width: 72),
                                  Expanded(
                                    child: Center(
                                      child: AppText(label: title, fontSize: 17, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  CupertinoButton(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    onPressed: () => Navigator.pop<T>(ctx, items[currentIndex]),
                                    child: AppText(label: 'Done', fontSize: 17, textColor: Color(0xFF007AFF)),
                                  ),
                                ],
                              ),
                            ),
                            // Picker
                            Expanded(
                              child: CupertinoPicker.builder(
                                backgroundColor: bg,
                                itemExtent: itemExtent,
                                scrollController: controller,
                                childCount: items.length,
                                onSelectedItemChanged: (i) => currentIndex = i,
                                itemBuilder: (_, i) => Center(child: Text(label(items[i]))),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<T?> showWithData<T, K>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required String Function(T) label,
    required K Function(T) initialKey,
    required K initialValue,
    bool Function(K a, K b)? equals,
  }) {
    return showCupertinoModalPopup<T>(
      context: context,
      barrierColor: CupertinoColors.black.withOpacity(.25),
      builder: (ctx) {
        final bg = CupertinoColors.systemBackground.resolveFrom(ctx);
        final toolbarHeight = 44.0;
        const itemExtent = 32.0;

        final initialIndex = _initialIndexOf<T, K>(items, initialKey, initialValue, equals);
        var currentIndex = initialIndex;
        final controller = FixedExtentScrollController(initialItem: initialIndex);

        return Align(
          alignment: Alignment.bottomCenter,
          child: CupertinoPopupSurface(
            isSurfacePainted: true,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: SizedBox(
                height: 200,
                child: (items.isEmpty)
                    ? const Center(child: AppText(label: 'No items available'))
                    : Column(
                        children: [
                          // Toolbar
                          SizedBox(
                            height: toolbarHeight,
                            child: Row(
                              children: [
                                const SizedBox(width: 72),
                                Expanded(
                                  child: Center(
                                    child: AppText(label: title, fontSize: 17, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                CupertinoButton(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  onPressed: () => Navigator.pop<T>(ctx, items[currentIndex]),
                                  child: AppText(label: 'Done', fontSize: 17, textColor: Color(0xFF007AFF)),
                                ),
                              ],
                            ),
                          ),
                          // Picker
                          Expanded(
                            child: CupertinoPicker.builder(
                              backgroundColor: bg,
                              itemExtent: itemExtent,
                              scrollController: controller,
                              childCount: items.length,
                              onSelectedItemChanged: (i) => currentIndex = i,
                              itemBuilder: (_, i) => Center(child: Text(label(items[i]))),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  static int _initialIndexOf<T, K>(
    List<T> items,
    K Function(T) initialKey,
    K initialValue, [
    bool Function(K a, K b)? equals,
  ]) {
    final eq = equals ?? (K a, K b) => a == b;
    for (var i = 0; i < items.length; i++) {
      if (eq(initialKey(items[i]), initialValue)) return i;
    }
    return 0;
  }
}
