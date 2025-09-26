import 'package:flutter/material.dart';

class PriorityMultiSelect extends StatefulWidget {
  final String provider;
  final List<String> models;
  final List<String> current;
  final ValueChanged<List<String>> onChanged;
  const PriorityMultiSelect(
      {super.key,
      required this.provider,
      required this.models,
      required this.current,
      required this.onChanged});

  @override
  State<PriorityMultiSelect> createState() => _PriorityMultiSelectState();
}

class _PriorityMultiSelectState extends State<PriorityMultiSelect> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = [...widget.current.where((m) => widget.models.contains(m))];
  }

  void _openPicker() async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final available = widget.models;
        final sel = [..._selected];
        return StatefulBuilder(builder: (ctx, setSheet) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                height: MediaQuery.of(ctx).size.height * 0.7,
                child: Column(
                  children: [
                    Row(children: [
                      Text('Priority Models (${widget.provider})',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      IconButton(
                          onPressed: () => Navigator.pop(ctx, sel),
                          icon: const Icon(Icons.check))
                    ]),
                    const SizedBox(height: 8),
                    Expanded(
                        child: ReorderableListView(
                      onReorder: (oldIndex, newIndex) {
                        setSheet(() {
                          var oi = oldIndex;
                          var ni = newIndex;
                          if (ni > oi) ni--;
                          final itm = sel.removeAt(oi);
                          sel.insert(ni, itm);
                        });
                      },
                      children: [
                        for (final m in sel)
                          Dismissible(
                            key: ValueKey(m),
                            background: Container(color: Colors.redAccent),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) {
                              setSheet(() => sel.remove(m));
                            },
                            child: ListTile(
                              title: Text(m, overflow: TextOverflow.ellipsis),
                              leading: const Icon(Icons.drag_handle),
                              trailing: CircleAvatar(
                                  radius: 10,
                                  child: Text('${sel.indexOf(m) + 1}',
                                      style: const TextStyle(fontSize: 10))),
                            ),
                          ),
                      ],
                    )),
                    const SizedBox(height: 8),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Tap to add/remove models',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 11))),
                    Expanded(
                      child: LayoutBuilder(builder: (ctx2, constraints) {
                        return SingleChildScrollView(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final m in available)
                                FilterChip(
                                  label:
                                      Text(m, overflow: TextOverflow.ellipsis),
                                  selected: sel.contains(m),
                                  onSelected: (on) {
                                    setSheet(
                                        () => on ? sel.add(m) : sel.remove(m));
                                  },
                                ),
                            ],
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      Text('${sel.length} selected',
                          style: const TextStyle(fontSize: 12)),
                      const Spacer(),
                      TextButton(
                          onPressed: () => setSheet(() => sel.clear()),
                          child: const Text('Clear')),
                      const SizedBox(width: 8),
                      ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, sel),
                          child: const Text('Save'))
                    ]),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
    if (result != null) {
      setState(() => _selected = result);
      widget.onChanged(_selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = _selected.isEmpty
        ? 'Select priority models'
        : _selected.take(3).join(', ') + (_selected.length > 3 ? '…' : '');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: OutlinedButton.icon(
        onPressed: _openPicker,
        icon: const Icon(Icons.list_alt),
        label: Align(
            alignment: Alignment.centerLeft,
            child: Text(label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color))),
      ),
    );
  }
}
