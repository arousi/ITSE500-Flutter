part of '../provider_config_block.dart';

class ModelGroupList extends StatelessWidget {
  final List<String> models;
  final Map<String, List<String>> grouped;
  final Set<String> selectedModels;
  final String providerKey;
  final Map<String, bool> expandedGroups;
  final bool modelsSectionExpanded;
  final ValueChanged<bool> onExpansionChanged;
  final void Function(String groupKey, bool expanded) onGroupExpansionChanged;
  final void Function(List<String> groupModels, bool allSelected) onSelectGroup;
  final void Function(String modelId, bool selected) onToggleModel;
  final MetadataBuilder metadataBuilder;

  const ModelGroupList({
    super.key,
    required this.models,
    required this.grouped,
    required this.selectedModels,
    required this.providerKey,
    required this.expandedGroups,
    required this.modelsSectionExpanded,
    required this.onExpansionChanged,
    required this.onGroupExpansionChanged,
    required this.onSelectGroup,
    required this.onToggleModel,
    required this.metadataBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final badgeBg = scheme.surfaceContainerHighest;
    final badgeOn = scheme.onSurfaceVariant;
    final selectedBadgeBg = scheme.primaryContainer;
    final selectedBadgeOn = scheme.onPrimaryContainer;
    final groupSelectedBadgeBg = scheme.secondaryContainer;
    final groupSelectedBadgeOn = scheme.onSecondaryContainer;

    return Card(
      elevation: 0,
      color: theme.cardColor,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: modelsSectionExpanded,
          onExpansionChanged: onExpansionChanged,
          title: Row(
            children: [
              const Text('Models',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: selectedModels.isEmpty ? badgeBg : selectedBadgeBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${selectedModels.length}/${models.length}',
                  style: TextStyle(
                      fontSize: 10,
                      color:
                          selectedModels.isEmpty ? badgeOn : selectedBadgeOn),
                ),
              ),
            ],
          ),
          children: grouped.entries.map((entry) {
            final groupKey = '$providerKey|${entry.key}';
            final expanded = expandedGroups[groupKey] ?? false;
            final groupModels = entry.value;
            final selectedCount =
                groupModels.where(selectedModels.contains).length;
            final allSelected =
                selectedCount == groupModels.length && groupModels.isNotEmpty;
            final someSelected = selectedCount > 0 && !allSelected;
            return Card(
              elevation: 0,
              color: theme.cardColor,
              margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
              child: ExpansionTile(
                initiallyExpanded: expanded,
                onExpansionChanged: (v) => onGroupExpansionChanged(groupKey, v),
                title: Row(
                  children: [
                    Text(entry.key,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: someSelected ? groupSelectedBadgeBg : badgeBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$selectedCount/${groupModels.length}',
                        style: TextStyle(
                            fontSize: 10,
                            color:
                                someSelected ? groupSelectedBadgeOn : badgeOn),
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: () => onSelectGroup(groupModels, allSelected),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: allSelected
                              ? scheme.tertiaryContainer
                              : scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          allSelected
                              ? 'All'
                              : someSelected
                                  ? 'Partial'
                                  : 'None',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: allSelected
                                ? scheme.onTertiaryContainer
                                : scheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                        start: 8, end: 8, bottom: 8),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: -4,
                      children: groupModels.map((m) {
                        final meta = metadataBuilder(m);
                        final tooltip = meta.entries
                            .map((e) => '${e.key}: ${e.value}')
                            .join('\n');
                        final inMods = (meta['in'] ?? '').toLowerCase();
                        final modality = (meta['modality'] ?? '').toLowerCase();
                        final acceptsImageIn = inMods.contains('image');
                        final acceptsTextIn = inMods.contains('text');
                        final isEmbed = m.toLowerCase().contains('embed') ||
                            modality.contains('embed');
                        final caps = <String>[];
                        final isMultimodal = acceptsImageIn &&
                            acceptsTextIn; // text + image input
                        if (acceptsImageIn) caps.add('vision');
                        if (isMultimodal) caps.add('multimodal');
                        if (isEmbed) caps.add('embeddings');
                        final suffix =
                            caps.isEmpty ? '' : ' • ${caps.join(',')}';
                        return Tooltip(
                          message: tooltip,
                          waitDuration: const Duration(milliseconds: 400),
                          child: FilterChip(
                            label: Text('$m$suffix',
                                style: const TextStyle(fontSize: 11)),
                            selected: selectedModels.contains(m),
                            onSelected: (sel) => onToggleModel(m, sel),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  // Optional capability badges row
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                        start: 12, end: 12, bottom: 8),
                    child: Wrap(
                      spacing: 4,
                      runSpacing: -6,
                      children: groupModels.map((m) {
                        final meta = metadataBuilder(m);
                        final inMods = (meta['in'] ?? '').toLowerCase();
                        final outMods = (meta['out'] ?? '').toLowerCase();
                        final modality = (meta['modality'] ?? '').toLowerCase();
                        final isChat =
                            inMods.contains('text') && outMods.contains('text');
                        final isVision = inMods.contains('image');
                        final isImageGen = outMods.contains('image') ||
                            modality.contains('text->image');
                        final isAudio = outMods.contains('audio') ||
                            inMods.contains('audio');
                        final isEmb = modality.contains('embed') ||
                            m.toLowerCase().contains('embed');
                        final chips = <Widget>[];
                        Widget chip(IconData i, String t, Color c) => Chip(
                              visualDensity: VisualDensity.compact,
                              backgroundColor: c.withOpacity(.18),
                              side: BorderSide.none,
                              labelPadding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              avatar: Icon(i, size: 14, color: c),
                              label: Text(t,
                                  style: TextStyle(fontSize: 10, color: c)),
                            );
                        if (isChat) {
                          chips.add(chip(Icons.chat_bubble_outline, 'chat',
                              Colors.blueGrey));
                        }
                        if (isVision) {
                          chips.add(chip(Icons.visibility_outlined, 'vision',
                              Colors.deepPurple));
                        }
                        if (isImageGen) {
                          chips.add(
                              chip(Icons.image_outlined, 'image', Colors.teal));
                        }
                        if (isEmb) {
                          chips.add(chip(
                              Icons.linear_scale, 'embeddings', Colors.indigo));
                        }
                        if (isAudio) {
                          chips.add(
                              chip(Icons.graphic_eq, 'audio', Colors.orange));
                        }
                        if (chips.isEmpty) return const SizedBox.shrink();
                        return Wrap(spacing: 4, children: chips);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
