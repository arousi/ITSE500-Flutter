import 'package:flutter/material.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/repositories/data_repository.dart';

class LMStudioSection extends StatefulWidget {
  final bool enabled;
  final String endpoint;
  final String status; // 'up','down','checking','not_set'
  final ValueChanged<bool> onToggle; // parent maintains enabled flag
  final ValueChanged<String> onEndpointChanged; // parent maintains endpoint
  final VoidCallback onCheckStatus; // triggers parent health check

  const LMStudioSection({
    super.key,
    required this.enabled,
    required this.endpoint,
    required this.status,
    required this.onToggle,
    required this.onEndpointChanged,
    required this.onCheckStatus,
  });

  @override
  State<LMStudioSection> createState() => _LMStudioSectionState();
}

class _LMStudioSectionState extends State<LMStudioSection> {
  final TextEditingController _endpointController = TextEditingController();
  bool _loadingModels = false;
  List<String> _models = [];
  final Set<String> _selectedModels = {};
  final Map<String, bool> _expandedGroups = {};

  @override
  void initState() {
    super.initState();
    _endpointController.text = widget.endpoint;
  }

  @override
  void didUpdateWidget(covariant LMStudioSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.endpoint != widget.endpoint) {
      _endpointController.text = widget.endpoint;
    }
    // When toggled on & status is up but models empty, fetch
    if (widget.enabled &&
        widget.status == 'up' &&
        _models.isEmpty &&
        !_loadingModels) {
      _fetchModels();
    }
  }

  Future<void> _fetchModels() async {
    setState(() => _loadingModels = true);
    try {
      final repo = DataRepository();
      final list = await repo.fetchLmStudioModels(baseUrl: widget.endpoint);
      setState(() => _models = list);
    } finally {
      if (mounted) setState(() => _loadingModels = false);
    }
  }

  Map<String, List<String>> _groupModels(List<String> models) {
    final Map<String, List<String>> grouped = {};
    for (final m in models) {
      // LM Studio sometimes returns just model file names. Group by heuristic: before first '_' or '-' as family.
      String cat = 'Other';
      if (m.contains('-')) {
        cat = m.split('-').first;
      } else if (m.contains('_')) cat = m.split('_').first;
      grouped.putIfAbsent(cat, () => []).add(m);
    }
    final keys = grouped.keys.toList()..sort();
    return {for (final k in keys) k: (grouped[k]!..sort())};
  }

  Widget _buildGroupedModels() {
    final grouped = _groupModels(_models);
    return Column(
      children: grouped.entries.map((e) {
        final gKey = 'lmstudio|${e.key}';
        final expanded = _expandedGroups[gKey] ?? false; // collapsed by default
        final groupModels = e.value;
        final selectedCount =
            groupModels.where(_selectedModels.contains).length;
        final allSelected =
            selectedCount == groupModels.length && groupModels.isNotEmpty;
        final someSelected = selectedCount > 0 && !allSelected;
        return Card(
          elevation: 0,
          color: Colors.grey.shade50,
          margin: const EdgeInsets.symmetric(vertical: 3),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: expanded,
              onExpansionChanged: (v) =>
                  setState(() => _expandedGroups[gKey] = v),
              title: Row(
                children: [
                  Text(e.key,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: someSelected
                          ? Colors.blue.shade100
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('$selectedCount/${groupModels.length}',
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey.shade800)),
                  ),
                  const Spacer(),
                  InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () {
                      setState(() {
                        if (allSelected) {
                          for (final m in groupModels) {
                            _selectedModels.remove(m);
                          }
                        } else {
                          for (final m in groupModels) {
                            _selectedModels.add(m);
                          }
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: allSelected
                            ? Colors.green.shade100
                            : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                          allSelected
                              ? 'All'
                              : someSelected
                                  ? 'Partial'
                                  : 'None',
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w500)),
                    ),
                  )
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                      start: 8, end: 8, bottom: 8),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: -4,
                    children: groupModels
                        .map((m) => FilterChip(
                              label:
                                  Text(m, style: const TextStyle(fontSize: 11)),
                              selected: _selectedModels.contains(m),
                              onSelected: (sel) {
                                setState(() {
                                  if (sel) {
                                    _selectedModels.add(m);
                                  } else {
                                    _selectedModels.remove(m);
                                  }
                                });
                              },
                            ))
                        .toList(),
                  ),
                )
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    switch (widget.status) {
      case 'up':
        statusColor = Colors.green;
        statusText = 'Connected';
        break;
      case 'down':
        statusColor = Colors.red;
        statusText = 'Disconnected';
        break;
      case 'checking':
        statusColor = Colors.orange;
        statusText = 'Checking...';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Not set';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Switch(
              value: widget.enabled,
              onChanged: (v) {
                widget.onToggle(v);
                if (v) {
                  widget.onCheckStatus();
                }
                setState(() {});
              },
            ),
            const Text('LM-Studio'),
            const SizedBox(width: 12),
            Container(
                width: 12,
                height: 12,
                decoration:
                    BoxDecoration(color: statusColor, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(statusText,
                style: TextStyle(color: statusColor, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _endpointController,
          enabled: widget.enabled,
          decoration: const InputDecoration(
            labelText: 'LM-Studio Base URL',
            border: OutlineInputBorder(),
          ),
          onChanged: widget.onEndpointChanged,
          onFieldSubmitted: (_) => widget.onCheckStatus(),
          onEditingComplete: widget.onCheckStatus,
          onTapOutside: (_) => widget.onCheckStatus(),
        ),
        if (widget.enabled && widget.status == 'up') ...[
          const SizedBox(height: 8),
          if (_loadingModels)
            const LinearProgressIndicator(minHeight: 2)
          else if (_models.isEmpty)
            Row(children: [
              const Icon(Icons.info_outline, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              const Expanded(
                  child: Text('No models discovered yet. Tap refresh.',
                      style: TextStyle(fontSize: 11, color: Colors.grey))),
              IconButton(
                  icon: const Icon(Icons.refresh, size: 16),
                  onPressed: _fetchModels)
            ])
          else ...[
            Row(
              children: [
                Text('Models', style: Theme.of(context).textTheme.bodySmall),
                const Spacer(),
                IconButton(
                    icon: const Icon(Icons.refresh, size: 16),
                    tooltip: 'Refresh',
                    onPressed: _fetchModels),
              ],
            ),
            _buildGroupedModels(),
          ],
        ],
      ],
    );
  }
}
