import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../models/model_descriptor.dart';
import 'manual_pricing_loader.dart';

/// Developer utility that attempts to update assets/pricing/manual_pricing.md with
/// pricing captured from dynamically fetched model catalogs (e.g. OpenRouter).
///
/// Notes:
/// - Bundled assets are read-only in release builds; failures are silently ignored.
/// - Only rows with at least one price (prompt or completion) are considered.
/// - Existing rows (provider+model_id) are updated in-place; new rows appended.
/// - A simple ISO date (YYYY-MM-DD) is written as effective_date.
class PricingMarkdownWriter {
  PricingMarkdownWriter._();
  static final PricingMarkdownWriter I = PricingMarkdownWriter._();

  Future<void> upsertFromModels(List<ModelDescriptor> models,
      {DateTime? effectiveDate}) async {
    final file = File('assets/pricing/manual_pricing.md');
    if (!await file.exists()) return; // nothing to do (or path mismatch)
    String original;
    try {
      original = await file.readAsString();
    } catch (_) {
      return;
    }

    final lines = const LineSplitter().convert(original).toList();
    // Build index of existing rows
    final index = <String, int>{};
    for (var i = 0; i < lines.length; i++) {
      final l = lines[i].trim();
      if (!l.startsWith('|') || l.startsWith('| provider')) continue;
      final parts = l.split('|').map((s) => s.trim()).toList();
      if (parts.length < 7) continue;
      final provider = parts[1].toLowerCase();
      final modelId = parts[2].toLowerCase();
      index['$provider|$modelId'] = i;
    }

    bool changed = false;
    final dateStr =
        (effectiveDate ?? DateTime.now()).toIso8601String().split('T').first;
    for (final m in models) {
      final pp = m.promptPrice;
      final cp = m.completionPrice;
      if (pp == null && cp == null) continue;
      final key = '${m.provider.name.toLowerCase()}|${m.id.toLowerCase()}';
      final row =
          '| ${m.provider.name} | ${m.id} | ${pp?.toStringAsFixed(6) ?? '-'} | ${cp?.toStringAsFixed(6) ?? '-'} | auto-captured | $dateStr |';
      if (index.containsKey(key)) {
        final existingIdx = index[key]!;
        if (lines[existingIdx] != row) {
          lines[existingIdx] = row;
          changed = true;
        }
      } else {
        lines.add(row);
        changed = true;
        index[key] = lines.length - 1;
      }
    }

    if (changed) {
      try {
        await file.writeAsString(lines.join('\n'));
      } catch (_) {/* ignore */}
      // Refresh loader cache for current process
      unawaited(ManualPricingLoader.I.forceReload());
    }
  }
}
