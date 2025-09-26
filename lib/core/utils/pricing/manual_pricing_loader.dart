import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle; // for asset load
import '../../models/model_descriptor.dart';

class ManualPricingLoader {
  ManualPricingLoader._();
  static final ManualPricingLoader I = ManualPricingLoader._();

  Map<String, _PricingEntry>? _cache; // key: provider|model_id (lowercase)

  bool get isLoaded => _cache != null;

  Future<void> ensureLoaded() async {
    if (_cache != null) return;
    try {
      final raw =
          await rootBundle.loadString('assets/pricing/manual_pricing.md');
      _cache = _parseMarkdown(raw);
    } catch (_) {
      _cache = {};
    }
  }

  Future<void> forceReload() async {
    _cache = null;
    await ensureLoaded();
  }

  _PricingEntry? lookup(ProviderType provider, String modelId) {
    final key = '${provider.name}|${modelId.toLowerCase()}';
    return _cache?[key];
  }

  Map<String, _PricingEntry> _parseMarkdown(String md) {
    final lines = const LineSplitter().convert(md);
    final map = <String, _PricingEntry>{};
    bool inTable = false;
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('| provider')) {
        inTable = true;
        continue;
      }
      if (!inTable) continue;
      if (trimmed.isEmpty || trimmed.startsWith('|---')) continue;
      if (!trimmed.startsWith('|')) break; // end of table
      final cols = trimmed.split('|').map((c) => c.trim()).toList();
      if (cols.length < 7) continue;
      final provider = cols[1].toLowerCase();
      final modelId = cols[2];
      double? pPrompt = double.tryParse(cols[3]);
      double? pComp = double.tryParse(cols[4]);
      if (cols[3] == '-') pPrompt = null;
      if (cols[4] == '-') pComp = null;
      final eff = cols[6];
      final key = '$provider|${modelId.toLowerCase()}';
      map[key] =
          _PricingEntry(prompt: pPrompt, completion: pComp, effective: eff);
    }
    return map;
  }
}

class _PricingEntry {
  final double? prompt;
  final double? completion;
  final String effective;
  const _PricingEntry({this.prompt, this.completion, required this.effective});
}
