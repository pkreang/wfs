import 'package:flutter/material.dart';

/// A reusable modal bottom sheet layout for filter controls.
class AppFilterSheet extends StatelessWidget {
  const AppFilterSheet({
    required this.child,
    required this.onSearch,
    this.onClear,
    this.onClose,
    this.title = 'ตัวกรอง',
    this.clearText = 'ล้างค่า',
    this.searchText = 'ค้นหา',
    super.key,
  });

  final Widget child;
  final VoidCallback onSearch;
  final VoidCallback? onClear;
  final VoidCallback? onClose;
  final String title;
  final String clearText;
  final String searchText;

  /// Shows an [AppFilterSheet] in a modal bottom sheet.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    required VoidCallback onSearch,
    VoidCallback? onClear,
    VoidCallback? onClose,
    String title = 'ตัวกรอง',
    String clearText = 'ล้างค่า',
    String searchText = 'ค้นหา',
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.9,
            ),
            child: AppFilterSheet(
              title: title,
              clearText: clearText,
              searchText: searchText,
              onClear: onClear,
              onClose: onClose,
              onSearch: onSearch,
              child: child,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      onClose?.call();
                      Navigator.of(context).pop();
                    },
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: child,
            ),
          ),
          Divider(
            height: 0.05,
            color: theme.dividerColor.withValues(alpha: 0.25),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: onClear,
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      disabledForegroundColor: theme.disabledColor,
                    ),
                    child: Text(
                      clearText,
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        onSearch();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        searchText,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
