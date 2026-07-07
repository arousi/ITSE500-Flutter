import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_app_itse500/features/chat/logic/chat_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/repositories/model_repository.dart';
import 'package:flutter_app_itse500/core/models/model_descriptor.dart';

// --- Extracted parts ---
part 'provider_config_parts/connection_field.dart';
part 'provider_config_parts/filter_panel.dart';
part 'provider_config_parts/model_group_list.dart';

typedef GroupingStrategy = Map<String, List<String>> Function(
    List<String> models);
typedef MetadataBuilder = Map<String, String> Function(String modelId);

// Sorting option for pricing. If metadata absent, sorting falls back to original order.
enum PriceSort { none, asc, desc }

class ProviderConfigBlock extends StatefulWidget {
  final String providerKey; // openai, openrouter, google (gemini), lmstudio
  final String displayName;
  final bool isEditable;
  final bool usesApiKey; // if false treat field as endpoint/base url
  final TextEditingController controller;
  final Future<bool> Function(String value)
      onValidate; // key/endpoint validation
  final Future<List<String>> Function(String value)
      onFetchModels; // fetch models
  final GroupingStrategy groupingStrategy;
  final MetadataBuilder metadataBuilder;
  final String fieldLabel;
  final String docsUrl;
  final bool autoValidateOnChange; // for API key providers maybe true

  const ProviderConfigBlock({
    super.key,
    required this.providerKey,
    required this.displayName,
    required this.isEditable,
    required this.usesApiKey,
    required this.controller,
    required this.onValidate,
    required this.onFetchModels,
    required this.groupingStrategy,
    required this.metadataBuilder,
    required this.fieldLabel,
    required this.docsUrl,
    this.autoValidateOnChange = true,
  });

  @override
  State<ProviderConfigBlock> createState() => _ProviderConfigBlockState();
}

class _ProviderConfigBlockState extends State<ProviderConfigBlock> {
  bool _connected = false;
  bool _checking = false;
  bool _loadingModels = false;
  List<String> _models = [];
  final Set<String> _selectedModels = {};
  final Map<String, bool> _expandedGroups = {}; // collapsed by default
  bool _modelsSectionExpanded = false; // wrapper for all model groups
  bool _bootstrappedFallback = false;
  bool _showFilters = false;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();
  // Persisted UI state keys
  static const _kExpandedModelsKey = 'prov_models_expanded';
  static const _kExpandedGroupsKey = 'prov_groups_expanded';

  // Filtering state
  PriceSort _priceSort = PriceSort.none;
  final Set<String> _typeFilters =
      {}; // chat, vision, embeddings, imagegen, audio
  final Set<String> _ioFilters =
      {}; // 'in:text','in:image','in:audio','out:text','out:image','out:audio'

  @override
  void initState() {
    super.initState();
    _loadPersisted();
  }

  Future<void> _loadPersisted() async {
    const storage = FlutterSecureStorage();
    final modelsStored =
        await storage.read(key: '${widget.providerKey}_models');
    if (modelsStored != null) {
      _models = modelsStored.split('|').where((e) => e.isNotEmpty).toList();
    }
    final selectedStored =
        await storage.read(key: '${widget.providerKey}_models_selected');
    if (selectedStored != null) {
      _selectedModels
          .addAll(selectedStored.split('|').where((e) => e.isNotEmpty));
    }
    // Push to global cubit to hydrate dropdowns
    final chatCubit = context.read<ChatCubit>();
    if (_models.isNotEmpty) {
      chatCubit.setProviderLLMs(widget.providerKey, _models);
    }
    if (_selectedModels.isNotEmpty) {
      chatCubit.setSelectedProviderLLMs(
          widget.providerKey, _selectedModels.toList());
    }
    // Restore expansion state
    final expanded =
        await storage.read(key: '${widget.providerKey}_$_kExpandedModelsKey');
    _modelsSectionExpanded = expanded == '1';
    final groupsStr =
        await storage.read(key: '${widget.providerKey}_$_kExpandedGroupsKey');
    if (groupsStr != null && groupsStr.isNotEmpty) {
      for (final part in groupsStr.split('|')) {
        final kv = part.split('=');
        if (kv.length == 2) {
          _expandedGroups[kv[0]] = kv[1] == '1';
        }
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _persistExpansion() async {
    const storage = FlutterSecureStorage();
    await storage.write(
        key: '${widget.providerKey}_$_kExpandedModelsKey',
        value: _modelsSectionExpanded ? '1' : '0');
    final buf = StringBuffer();
    bool first = true;
    _expandedGroups.forEach((k, v) {
      if (!first) buf.write('|');
      first = false;
      buf
        ..write(k)
        ..write('=')
        ..write(v ? '1' : '0');
    });
    await storage.write(
        key: '${widget.providerKey}_$_kExpandedGroupsKey',
        value: buf.toString());
  }

  ProviderType _toProviderType(String key) {
    switch (key) {
      case 'openai':
        return ProviderType.openai;
      case 'openrouter':
        return ProviderType.openrouter;
      case 'gemini':
      case 'google':
        return ProviderType.gemini;
      case 'lmstudio':
        return ProviderType.lmstudio;
      default:
        return ProviderType.openai;
    }
  }

  Future<void> _loadFallbackModelsIfNeeded() async {
    if (_bootstrappedFallback) return;
    final chatCubit = context.read<ChatCubit>();
    final enabled = chatCubit.providerEnabled[widget.providerKey] ?? false;
    if (!enabled) return;
    // If not connected or no key, and we have no models loaded, use fallback catalog
    final keyOrEndpoint = widget.controller.text.trim();
    final hasCred = keyOrEndpoint.isNotEmpty;
    if (_models.isEmpty && (!hasCred || !_connected)) {
      final pt = _toProviderType(widget.providerKey);
      try {
        final list = await ModelRepository.I
            .getModels(provider: pt, apiKeyOrEndpoint: null);
        final ids = list.whereType<ModelDescriptor>().map((d) => d.id).toList();
        setState(() {
          _models = ids;
          _bootstrappedFallback = true;
        });
        await _persistModels();
        chatCubit.setProviderLLMs(widget.providerKey, ids);
      } catch (_) {
        // ignore fallback errors
      }
    }
  }

  Future<void> _persistModels() async {
    const storage = FlutterSecureStorage();
    await storage.write(
        key: '${widget.providerKey}_models', value: _models.join('|'));
    await storage.write(
        key: '${widget.providerKey}_models_selected',
        value: _selectedModels.join('|'));
  }

  // ---------- Filtering helpers ----------
  bool _matchesSearch(String id, Map<String, String> meta) {
    if (_searchQuery.trim().isEmpty) return true;
    final q = _searchQuery.toLowerCase();
    return id.toLowerCase().contains(q) ||
        (meta['vendor']?.toLowerCase().contains(q) ?? false) ||
        (meta['modality']?.toLowerCase().contains(q) ?? false) ||
        (meta['in']?.toLowerCase().contains(q) ?? false) ||
        (meta['out']?.toLowerCase().contains(q) ?? false);
  }

  String _deriveType(String id, Map<String, String> meta) {
    final lower = id.toLowerCase();
    final modality = (meta['modality'] ?? '').toLowerCase();
    final inMods = (meta['in'] ?? '').toLowerCase();
    final outMods = (meta['out'] ?? '').toLowerCase();
    if (lower.contains('embed') ||
        lower.contains('embedding') ||
        modality.contains('embed')) {
      return 'embeddings';
    }
    if (outMods.contains('image') || modality.contains('text->image')) {
      return 'imagegen';
    }
    if (outMods.contains('audio')) return 'audio';
    if (inMods.contains('image') || outMods.contains('image')) return 'vision';
    return 'chat';
  }

  // Multi-label type extraction so a model can be both 'vision' and 'imagegen', etc.
  Set<String> _typesForModel(String id, Map<String, String> meta) {
    final types = <String>{};
    final lower = id.toLowerCase();
    final modality = (meta['modality'] ?? '').toLowerCase();
    final inMods = (meta['in'] ?? '').toLowerCase();
    final outMods = (meta['out'] ?? '').toLowerCase();
    if (lower.contains('embed') ||
        lower.contains('embedding') ||
        modality.contains('embed')) {
      types.add('embeddings');
    }
    // Image out implies generation capability
    if (outMods.contains('image') || modality.contains('text->image')) {
      types.add('imagegen');
    }
    if (outMods.contains('audio')) types.add('audio');
    // Vision means accepts images (image-in); some gens may also be vision if they support image prompts
    if (inMods.contains('image')) types.add('vision');
    // If no explicit label added, assume chat
    if (types.isEmpty) types.add('chat');
    // A text-in/text-out chat model also counts as 'chat'
    if (inMods.contains('text') || outMods.contains('text')) types.add('chat');
    return types;
  }

  bool _matchesType(String id, Map<String, String> meta) {
    if (_typeFilters.isEmpty) return true;
    final types = _typesForModel(id, meta);
    // Require all selected types to be present (AND semantics)
    return _typeFilters.every(types.contains);
  }

  bool _matchesIO(String id, Map<String, String> meta) {
    if (_ioFilters.isEmpty) return true;
    final inMods = (meta['in'] ?? '').toLowerCase();
    final outMods = (meta['out'] ?? '').toLowerCase();
    bool has(String dir, String what) {
      if (dir == 'in') return inMods.contains(what);
      return outMods.contains(what);
    }

    // All selected IO chips must be satisfied
    for (final f in _ioFilters) {
      final parts = f.split(':');
      if (parts.length != 2) continue;
      if (!has(parts[0], parts[1])) return false;
    }
    return true;
  }

  // Parse a comparable price value, preferring the smaller of prompt/completion; infinity if unknown
  double _priceValue(Map<String, String> meta) {
    double parse(String? s) =>
        (s == null) ? double.nan : (double.tryParse(s) ?? double.nan);
    final p = parse(meta['prompt_price']);
    final c = parse(meta['completion_price']);
    final values = [p, c].where((v) => v.isFinite).toList();
    if (values.isEmpty) return double.infinity;
    return values.reduce((a, b) => a < b ? a : b);
  }

  List<String> _applyFilters(List<String> models) {
    return models.where((id) {
      final meta = widget.metadataBuilder(id);
      return _matchesSearch(id, meta) &&
          _matchesType(id, meta) &&
          _matchesIO(id, meta);
    }).toList();
  }

  List<String> _applySort(List<String> models) {
    if (_priceSort == PriceSort.none) return models;
    final sorted = [...models];
    sorted.sort((a, b) {
      final pa = _priceValue(widget.metadataBuilder(a));
      final pb = _priceValue(widget.metadataBuilder(b));
      int cmp;
      if (pa == pb) {
        cmp = a.compareTo(b);
      } else if (pa.isInfinite && pb.isInfinite) {
        cmp = a.compareTo(b);
      } else if (pa.isInfinite) {
        cmp = 1; // unknowns last in asc
      } else if (pb.isInfinite) {
        cmp = -1;
      } else {
        cmp = pa.compareTo(pb);
      }
      return _priceSort == PriceSort.asc ? cmp : -cmp;
    });
    return sorted;
  }

  // Counts for chips based on current search and current selections (intersection semantics)
  int _countWith({String? typeLabel, String? ioLabel}) {
    final typeSel = {..._typeFilters};
    final ioSel = {..._ioFilters};
    if (typeLabel != null) typeSel.add(typeLabel);
    if (ioLabel != null) ioSel.add(ioLabel);
    return _models.where((id) {
      final meta = widget.metadataBuilder(id);
      if (!_matchesSearch(id, meta)) return false;
      // type match with augmented selection
      if (typeSel.isNotEmpty) {
        final types = _typesForModel(id, meta);
        if (!typeSel.every(types.contains)) return false;
      }
      // IO match with augmented selection
      if (ioSel.isNotEmpty) {
        final inMods = (meta['in'] ?? '').toLowerCase();
        final outMods = (meta['out'] ?? '').toLowerCase();
        bool has(String dir, String what) =>
            dir == 'in' ? inMods.contains(what) : outMods.contains(what);
        for (final f in ioSel) {
          final parts = f.split(':');
          if (parts.length != 2) continue;
          if (!has(parts[0], parts[1])) return false;
        }
      }
      return true;
    }).length;
  }

  Future<void> _validateAndMaybeFetch() async {
    final chatCubit = context.read<ChatCubit>();
    final enabled = chatCubit.providerEnabled[widget.providerKey] ?? false;
    if (!enabled) return;
    final value = widget.controller.text.trim();
    if (value.isEmpty) return;
    setState(() => _checking = true);
    try {
      final ok = await widget.onValidate(value);
      setState(() => _connected = ok);
      // Propagate connection status to global cubit for shared UI (e.g., configure dialog)
      context.read<ChatCubit>().setProviderConnected(widget.providerKey, ok);
    } finally {
      setState(() => _checking = false);
    }
    // If validation did not connect, ensure we at least have fallback models for UI
    await _loadFallbackModelsIfNeeded();
  }

  Future<void> _fetchModels() async {
    final chatCubit = context.read<ChatCubit>();
    final enabled = chatCubit.providerEnabled[widget.providerKey] ?? false;
    if (!enabled || !_connected) return; // only fetch when connected
    setState(() => _loadingModels = true);
    try {
      final list = await widget.onFetchModels(widget.controller.text.trim());
      setState(() {
        _models = list;
        // Auto-expand models section on first successful load
        if (!_modelsSectionExpanded) _modelsSectionExpanded = true;
      });
      await _persistModels();
      chatCubit.setProviderLLMs(widget.providerKey, list);
      await _persistExpansion();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Fetch models failed for ${widget.displayName}: $e')),
        );
      }
    } finally {
      setState(() => _loadingModels = false);
    }
  }

  void _deleteKeyAndData() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: '${widget.providerKey}_key');
    await storage.delete(key: '${widget.providerKey}_endpoint');
    await storage.delete(key: '${widget.providerKey}_models');
    await storage.delete(key: '${widget.providerKey}_models_selected');
    widget.controller.clear();
    setState(() {
      _connected = false;
      _models = [];
      _selectedModels.clear();
    });
  }

  Map<String, List<String>> _grouped() {
    final filtered = _applyFilters(_models);
    final grouped = widget.groupingStrategy(filtered);
    if (_priceSort != PriceSort.none) {
      // sort models within each group by price
      grouped.updateAll((key, list) => _applySort(list));
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final chatCubit = context.read<ChatCubit>();
    final enabled = chatCubit.providerEnabled[widget.providerKey] ?? false;
    // Source of truth for connection: fall back to local _connected only if global not set yet.
    final effectiveConnected =
        chatCubit.providerConnected[widget.providerKey] ?? _connected;

    Color statusColor;
    String statusText;
    if (!enabled) {
      statusColor = Colors.grey;
      statusText = 'Disabled';
    } else if (_checking) {
      statusColor = Colors.orange;
      statusText = 'Checking...';
    } else if (effectiveConnected) {
      statusColor = Colors.green;
      statusText = 'Connected';
    } else if (widget.controller.text.isEmpty) {
      statusColor = Colors.grey;
      statusText = 'Not set';
    } else {
      statusColor = Colors.red;
      statusText = 'Disconnected';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConnectionField(
          displayName: widget.displayName,
          providerKey: widget.providerKey,
          enabled: enabled,
          statusColor: statusColor,
          statusText: statusText,
          controller: widget.controller,
          usesApiKey: widget.usesApiKey,
          isEditable: widget.isEditable,
          checking: _checking,
          connected: effectiveConnected,
          fieldLabel: widget.fieldLabel,
          docsUrl: widget.docsUrl,
          onToggleEnabled: (val) async {
            chatCubit.setProviderEnabled(widget.providerKey, val);
            if (!val) {
              _deleteKeyAndData();
              // Collapse credentials section when disabled
              if (_modelsSectionExpanded) {
                setState(() {
                  _modelsSectionExpanded = false;
                });
                await _persistExpansion();
              }
            } else {
              await _validateAndMaybeFetch();
              await _loadFallbackModelsIfNeeded();
            }
            if (mounted) setState(() {});
          },
          onChanged: (val) async {
            const storage = FlutterSecureStorage();
            if (widget.usesApiKey) {
              await storage.write(key: '${widget.providerKey}_key', value: val);
              await storage.write(
                  key: '${widget.providerKey}_api_key', value: val);
            } else {
              await storage.write(
                  key: '${widget.providerKey}_endpoint', value: val);
            }
            if (!widget.autoValidateOnChange) return;
            await _validateAndMaybeFetch();
          },
          onFieldSubmitted: () => _validateAndMaybeFetch(),
        ),
        if (_loadingModels)
          const Padding(
              padding: EdgeInsets.only(top: 4),
              child: LinearProgressIndicator(minHeight: 2)),
        if (enabled && effectiveConnected)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => setState(() => _showFilters = !_showFilters),
                icon: const Icon(Icons.filter_list, size: 16),
                label: const Text('Filter'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _fetchModels,
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Fetch Models'),
              ),
            ],
          ),
        if (_showFilters)
          FilterPanel(
            searchController: _searchCtrl,
            priceSort: _priceSort,
            typeFilters: _typeFilters,
            ioFilters: _ioFilters,
            countWith: _countWith,
            onSearchChanged: (v) => setState(() => _searchQuery = v),
            onPriceSortChanged: (ps) => setState(() => _priceSort = ps),
            onReset: () => setState(() {
              _priceSort = PriceSort.none;
              _typeFilters.clear();
              _ioFilters.clear();
              _searchCtrl.clear();
              _searchQuery = '';
            }),
            onToggleType: (t, sel) => setState(
                () => sel ? _typeFilters.add(t) : _typeFilters.remove(t)),
            onToggleIO: (io, sel) => setState(
                () => sel ? _ioFilters.add(io) : _ioFilters.remove(io)),
          ),
        if (_models.isNotEmpty)
          ModelGroupList(
            models: _models,
            grouped: _grouped(),
            selectedModels: _selectedModels,
            providerKey: widget.providerKey,
            expandedGroups: _expandedGroups,
            modelsSectionExpanded: _modelsSectionExpanded,
            onExpansionChanged: (v) async {
              setState(() => _modelsSectionExpanded = v);
              await _persistExpansion();
            },
            onGroupExpansionChanged: (g, v) async {
              setState(() => _expandedGroups[g] = v);
              await _persistExpansion();
            },
            onSelectGroup: (groupModels, allSelected) {
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
                chatCubit.setSelectedProviderLLMs(
                    widget.providerKey, _selectedModels.toList());
                _persistModels();
              });
            },
            onToggleModel: (m, sel) {
              setState(() {
                if (sel) {
                  _selectedModels.add(m);
                } else {
                  _selectedModels.remove(m);
                }
                chatCubit.setSelectedProviderLLMs(
                    widget.providerKey, _selectedModels.toList());
                _persistModels();
              });
            },
            metadataBuilder: widget.metadataBuilder,
          ),
      ],
    );
  }
}
