part of '../provider_config_block.dart';

class FilterPanel extends StatelessWidget {
  final TextEditingController searchController;
  final PriceSort priceSort;
  final Set<String> typeFilters;
  final Set<String> ioFilters;
  final int Function({String? typeLabel, String? ioLabel}) countWith;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<PriceSort> onPriceSortChanged;
  final VoidCallback onReset;
  final void Function(String type, bool selected) onToggleType;
  final void Function(String io, bool selected) onToggleIO;

  const FilterPanel({
    super.key,
    required this.searchController,
    required this.priceSort,
    required this.typeFilters,
    required this.ioFilters,
    required this.countWith,
    required this.onSearchChanged,
    required this.onPriceSortChanged,
    required this.onReset,
    required this.onToggleType,
    required this.onToggleIO,
  });

  @override
  Widget build(BuildContext context) {
    Widget buildTypeChip(String label, String keyVal) => FilterChip(
          label: Text('$label (${countWith(typeLabel: keyVal)})'),
          selected: typeFilters.contains(keyVal),
          onSelected: (s) => onToggleType(keyVal, s),
        );
    Widget buildIOChip(String label, String keyVal) => FilterChip(
          label: Text('$label (${countWith(ioLabel: keyVal)})'),
          selected: ioFilters.contains(keyVal),
          onSelected: (s) => onToggleIO(keyVal, s),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Search by name, vendor, modality...',
            prefixIcon: Icon(Icons.search, size: 18),
            border: OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: onSearchChanged,
        ),
        const SizedBox(height: 6),
        Wrap(spacing: 6, runSpacing: -6, children: [
          ChoiceChip(
            label: const Text('Price ↑'),
            selected: priceSort == PriceSort.asc,
            onSelected: (_) => onPriceSortChanged(PriceSort.asc),
          ),
          ChoiceChip(
            label: const Text('Price ↓'),
            selected: priceSort == PriceSort.desc,
            onSelected: (_) => onPriceSortChanged(PriceSort.desc),
          ),
          ChoiceChip(
            label: const Text('Default order'),
            selected: priceSort == PriceSort.none,
            onSelected: (_) => onPriceSortChanged(PriceSort.none),
          ),
        ]),
        const SizedBox(height: 6),
        Wrap(spacing: 6, runSpacing: -6, children: [
          buildTypeChip('Chat', 'chat'),
          buildTypeChip('Vision', 'vision'),
          buildTypeChip('Embeddings', 'embeddings'),
          buildTypeChip('ImageGen', 'imagegen'),
          buildTypeChip('Audio/TTS', 'audio'),
        ]),
        const SizedBox(height: 6),
        Wrap(spacing: 6, runSpacing: -6, children: [
          buildIOChip('Text In', 'in:text'),
          buildIOChip('Image In', 'in:image'),
          buildIOChip('Audio In', 'in:audio'),
          buildIOChip('Text Out', 'out:text'),
          buildIOChip('Image Out', 'out:image'),
          buildIOChip('Audio Out', 'out:audio'),
          TextButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Reset'),
          ),
        ]),
      ],
    );
  }
}
