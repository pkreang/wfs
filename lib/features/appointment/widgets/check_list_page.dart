import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/features/appointment/widgets/app_text.dart';

typedef ItemLabel<T> = String Function(T item);
typedef ItemKeyOf<T, K> = K Function(T item);

enum SelectionMode { single, multiple }

class CheckListPage<T, K> extends ConsumerStatefulWidget {
  final String title;
  final AutoDisposeFutureProvider<List<T>> items;
  final ItemLabel<T> label;
  final ItemKeyOf<T, K> keyOf;
  final Iterable<K> initial;

  final SelectionMode mode;

  const CheckListPage({super.key, required this.title, required this.items, required this.label, required this.keyOf, this.initial = const [], this.mode = SelectionMode.multiple});

  @override
  ConsumerState<CheckListPage<T, K>> createState() => _CheckListPageState<T, K>();
}

class _CheckListPageState<T, K> extends ConsumerState<CheckListPage<T, K>> {
  static const colorPrimary = Color(0xFF007AFF);

  late Set<K> _selectedKeys;
  List<T> _currentItems = const [];

  bool get _isMulti => widget.mode == SelectionMode.multiple;

  @override
  void initState() {
    super.initState();
    _selectedKeys = widget.initial.toSet();
    if (!_isMulti && _selectedKeys.length > 1) {
      _selectedKeys = {_selectedKeys.first};
    }
  }

  bool _selected(T item) => _selectedKeys.contains(widget.keyOf(item));

  void _toggle(T item) {
    final k = widget.keyOf(item);
    setState(() {
      if (_isMulti) {
        _selectedKeys.contains(k) ? _selectedKeys.remove(k) : _selectedKeys.add(k);
      } else {
        if (!_selectedKeys.contains(k)) _selectedKeys = {k};
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemsState = ref.watch(widget.items);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: [
              IconButton(icon: const Icon(Icons.chevron_left), onPressed: null, style: ButtonStyle(iconColor: WidgetStateProperty.all(colorPrimary))),
              AppText(label: 'Back', textColor: colorPrimary),
            ],
          ),
        ),
        title: AppText(label: widget.title, fontSize: 17, fontWeight: FontWeight.w600),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Done', style: TextStyle(color: colorPrimary)))],
      ),
      body: itemsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (items) {
          _currentItems = items;

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final item = items[i];
              final selected = _selected(item);

              return ListTile(
                onTap: () => _toggle(item),
                leading:
                    _isMulti
                        ? (selected ? const Icon(Icons.check_circle_outline, color: Color(0xFF31C859)) : null)
                        : Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: selected ? colorPrimary : null),
                title: AppText(label: widget.label(item)),
                // trailing:
                //     _isMulti
                //         ? (selected ? const Icon(Icons.check, color: colorPrimary) : null)
                //         : Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: selected ? colorPrimary : null),
              );
            },
          );
        },
      ),
    );
  }
}

// late final Set<T> _selected = widget.mode == SelectionMode.single && widget.initial.isNotEmpty ? {widget.initial.first} : {...widget.initial};

//   void _toggle(T item) {
//     // if (widget.mode == SelectionMode.single) {
//     //   setState(
//     //     () =>
//     //         _selected
//     //           ..clear()
//     //           ..add(item),
//     //   );
//     //   widget.onChanged?.call(Set.unmodifiable(_selected));
//     //   if (widget.autoPopOnTapWhenSingle) {
//     //     Navigator.pop(context, Set.unmodifiable(_selected));
//     //   }
//     //   return;
//     // }
//     // // multiple
//     // setState(() => !_selected.remove(item) ? _selected.add(item) : null);
//     // widget.onChanged?.call(Set.unmodifiable(_selected));
//   }

//   void _finish() {
//     // if (widget.autoPopOnDone) {
//     //   Navigator.pop(context, Set.unmodifiable(_selected));
//     // }
//   }

// body: ListView.separated(
  //   itemCount: widget.items.length,
  //   separatorBuilder: (_, __) => const Divider(height: 1),
  //   itemBuilder: (_, i) {
  //     final item = widget.items[i];
  //     final checked = _selected.contains(item);
  //     return ListTile(
  //       // title: Text(widget.label(item)),
  //       onTap: () => _toggle(item),
  //       leading: checked ? const Icon(CupertinoIcons.check_mark_circled, color: Color(0xFF31C859)) : null,
  //       dense: true,
  //       visualDensity: VisualDensity.compact,
  //     );
  //   },
  // ),

  //   return Scaffold(
  //     appBar: AppBar(title: Text(widget.title ?? (isMulti ? 'เลือกหลายรายการ' : 'เลือกหนึ่งรายการ')), actions: [if (isMulti) TextButton(onPressed: _finish, child: const Text('เสร็จ'))]),
  //     body: ListView.separated(
  //       itemCount: widget.items.length,
  //       separatorBuilder: (_, __) => const Divider(height: 1),
  //       itemBuilder: (_, i) {
  //         final item = widget.items[i];
  //         final checked = _selected.contains(item);
  //         return ListTile(
  //           // title: Text(widget.label(item)),
  //           onTap: () => _toggle(item),
  //           trailing: checked ? const Icon(CupertinoIcons.check_mark) : null,
  //           dense: true,
  //           visualDensity: VisualDensity.compact,
  //         );
  //       },
  //     ),
  //   );
  // }
