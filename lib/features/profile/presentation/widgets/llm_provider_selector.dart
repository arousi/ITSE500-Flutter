import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class LLMProviderSelector extends StatefulWidget {
  final Map<String, String> providerApiKeys; // providerName -> apiKey
  final Map<String, List<String>> providerLLMs; // providerName -> LLMs
  final Map<String, List<String>> selectedLLMs; // providerName -> selected LLMs
  final void Function(String provider, List<String> llms) onSelectionChanged;
  final void Function(String provider, String apiKey) onApiKeyChanged;

  const LLMProviderSelector({
    super.key,
    required this.providerApiKeys,
    required this.providerLLMs,
    required this.selectedLLMs,
    required this.onSelectionChanged,
    required this.onApiKeyChanged,
  });

  @override
  State<LLMProviderSelector> createState() => _LLMProviderSelectorState();
}

class _LLMProviderSelectorState extends State<LLMProviderSelector> {
  late Map<String, TextEditingController> _apiKeyControllers;

  @override
  void initState() {
    super.initState();
    _apiKeyControllers = {
      for (final entry in widget.providerApiKeys.entries)
        entry.key: TextEditingController(text: entry.value)
    };
  }

  @override
  void dispose() {
    for (final c in _apiKeyControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build unified provider list from union of apiKeys & llms maps to avoid missing new providers.
    final providerSet = <String>{
      ...widget.providerApiKeys.keys,
      ...widget.providerLLMs.keys,
      ...widget.selectedLLMs.keys,
    };
    final providers = providerSet.toList()..sort();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: providers.map((provider) {
        final apiKey = widget.providerApiKeys[provider] ?? '';
        final llms = widget.providerLLMs[provider] ?? [];
        final selected = widget.selectedLLMs[provider] ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(provider,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _apiKeyControllers[provider],
                    decoration: InputDecoration(
                      labelText: '$provider API Key',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      widget.onApiKeyChanged(provider, val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (apiKey.isNotEmpty)
              MultiSelectDialogField<String>(
                items: llms.map((llm) => MultiSelectItem(llm, llm)).toList(),
                initialValue: selected,
                title: Text('Select $provider LLMs'),
                buttonText: const Text('Pick LLMs'),
                searchable: true,
                onConfirm: (values) {
                  widget.onSelectionChanged(provider, values);
                },
              )
            else
              const Text('Enter API key to fetch LLMs',
                  style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
          ],
        );
      }).toList(),
    );
  }
}
