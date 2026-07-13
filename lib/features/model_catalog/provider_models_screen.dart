import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app_itse500/features/chat/logic/chat_cubit.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/repositories/data_repository.dart';
import 'logic/model_catalog_cubit.dart';
import 'package:flutter_app_itse500/core/models/model_descriptor.dart';
import 'package:flutter_app_itse500/l10n/app_localizations.dart';

class ProviderModelsScreen extends StatefulWidget {
  final String provider;
  const ProviderModelsScreen({super.key, required this.provider});

  @override
  State<ProviderModelsScreen> createState() => _ProviderModelsScreenState();
}

class _ProviderModelsScreenState extends State<ProviderModelsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _raw = [];
  String? _error;
  DateTime? _updatedAt;
  bool _usingDescriptors = false;
  String _search = '';
  bool _showBillingOnly = false;
  bool _showEmbeddings = true;
  bool _showImage = true;
  bool _showChat = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    final pt = _toProviderType(widget.provider);
    if (pt == ProviderType.openai ||
        pt == ProviderType.lmstudio ||
        pt == ProviderType.huggingface) {
      _usingDescriptors = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context
            .read<ModelCatalogCubit>()
            .ensureLoaded(provider: pt!, credential: null);
      });
      setState(() => _loading = false);
    } else {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final dataRepo = DataRepository();
      final chatCubit = context.read<ChatCubit>();
      final key = await chatCubit.getApiKey(widget.provider) ?? '';
      if (widget.provider == 'openrouter' && key.isNotEmpty) {
        _raw = await dataRepo.fetchOpenRouterModelsRaw(key, forceRefresh: true);
        _raw = _dedupeRaw(_raw);
      } else if (widget.provider == 'gemini' && key.isNotEmpty) {
        _raw =
            await dataRepo.fetchGoogleGeminiModelsRaw(key, forceRefresh: true);
        _raw = _dedupeRaw(_raw);
      } else if (widget.provider == 'openai') {
        // Use catalog cubit cached descriptors (if any) else fallback to selected list.
        final mc = context.read<ModelCatalogCubit>();
        final loaded = mc.state.models[ProviderType.openai];
        if (loaded != null && loaded.isNotEmpty) {
          _raw = loaded.map((d) => {'id': d.id}).toList();
          _raw = _dedupeRaw(_raw);
        } else {
          final models = chatCubit.providerLLMs['openai'] ?? [];
          _raw = models.map((m) => {'id': m}).toList();
          _raw = _dedupeRaw(_raw);
        }
      } else if (widget.provider == 'lmstudio') {
        final mc = context.read<ModelCatalogCubit>();
        final loaded = mc.state.models[ProviderType.lmstudio];
        if (loaded != null && loaded.isNotEmpty) {
          _raw = loaded.map((d) => {'id': d.id}).toList();
          _raw = _dedupeRaw(_raw);
        } else {
          final models = chatCubit.providerLLMs['lmstudio'] ?? [];
          _raw = models.map((m) => {'id': m}).toList();
          _raw = _dedupeRaw(_raw);
        }
      }
      _updatedAt = DateTime.now();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _providerUrl() {
    switch (widget.provider) {
      case 'openrouter':
        return 'https://openrouter.ai/models';
      case 'openai':
        return 'https://platform.openai.com/docs/pricing';
      case 'gemini':
        return 'https://ai.google.dev/gemini-api/docs/models';
      case 'lmstudio':
        return 'https://lmstudio.ai';
      case 'huggingface':
        return 'https://huggingface.co/models';
      default:
        return 'https://';
    }
  }

  ProviderType? _toProviderType(String key) {
    switch (key) {
      case 'openrouter':
        return ProviderType.openrouter;
      case 'openai':
        return ProviderType.openai;
      case 'gemini':
        return ProviderType.gemini;
      case 'lmstudio':
        return ProviderType.lmstudio;
      case 'huggingface':
        return ProviderType.huggingface;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No nested AppBar: main screen provides it. Inline header gives context + actions.
      body: SafeArea(
        top: false,
        child: _usingDescriptors
            ? BlocBuilder<ModelCatalogCubit, ModelCatalogState>(
                builder: (context, state) {
                  final pt = _toProviderType(widget.provider)!;
                  final list = state.models[pt] ?? const [];
                  // Apply filters
                  final filtered = list.where((d) {
                    if (_showBillingOnly && !d.requiresBilling) return false;
                    if (_search.isNotEmpty) {
                      final s = _search.toLowerCase();
                      if (!d.id.toLowerCase().contains(s) &&
                          !d.displayName.toLowerCase().contains(s)) {
                        return false;
                      }
                    }
                    final isChat = d.isChat;
                    final isEmb = d.isEmbedding;
                    final isImg = d.isImageGen || d.visionCapable;
                    if (!_showChat && isChat) return false;
                    if (!_showEmbeddings && isEmb) return false;
                    if (!_showImage && isImg) return false;
                    return true;
                  }).toList();
                  final isLoading = state.loading && list.isEmpty;
                  final err = state.error;
                  return _buildBody(
                    context,
                    loading: isLoading,
                    error: err,
                    empty: !isLoading && err == null && filtered.isEmpty,
                    updatedAt: state.lastUpdated[pt],
                    itemCount: filtered.length,
                    itemBuilder: (i) {
                      final d = filtered[i];
                      return ListTile(
                        dense: true,
                        title: Row(
                          children: [
                            Expanded(child: Text(d.displayName)),
                            if (d.requiresBilling)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                    color: Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(4)),
                                child: Text(
                                    AppLocalizations.of(context)!.billing,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.orange,
                                        fontWeight: FontWeight.w600)),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d.id, style: const TextStyle(fontSize: 11)),
                            if (d.promptPrice != null ||
                                d.completionPrice != null)
                              Text(_priceLine(d),
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.black87)),
                          ],
                        ),
                      );
                    },
                    onRefresh: () => context
                        .read<ModelCatalogCubit>()
                        .ensureLoaded(
                            provider: pt, credential: null, forceRefresh: true),
                  );
                },
              )
            : _buildBody(
                context,
                loading: _loading,
                error: _error,
                empty: !_loading && _error == null && _filterRaw(_raw).isEmpty,
                updatedAt: _updatedAt,
                itemCount: _filterRaw(_raw).length,
                itemBuilder: (i) {
                  final view = _filterRaw(_raw);
                  final m = view[i];
                  final id = (m['id'] ?? m['name'] ?? '').toString();
                  if (widget.provider == 'openrouter') {
                    final pricing = m['pricing'] as Map?;
                    final prompt = pricing?['prompt'];
                    final comp = pricing?['completion'];
                    final arch = m['architecture'] as Map?;
                    final modality = arch?['modality'];
                    return ListTile(
                      dense: true,
                      title: Text(id,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500)),
                      subtitle: Text(
                          'prompt: ${prompt ?? '—'} | completion: ${comp ?? '—'}\n$modality',
                          style: const TextStyle(fontSize: 11)),
                      isThreeLine: true,
                    );
                  }
                  if (widget.provider == 'gemini') {
                    final inputLimit = m['inputTokenLimit'];
                    final methods =
                        (m['supportedGenerationMethods'] as List?)?.join(',');
                    return ListTile(
                      dense: true,
                      title: Text(id),
                      subtitle: Text(
                          'input tokens: ${inputLimit ?? '—'} | methods: ${methods ?? '—'}',
                          style: const TextStyle(fontSize: 11)),
                    );
                  }
                  return ListTile(dense: true, title: Text(id));
                },
                onRefresh: _load,
              ),
      ),
    );
  }

  // Helpers: raw list dedupe and filtering
  String _canon(String id) {
    final s = id.startsWith('models/') ? id.substring('models/'.length) : id;
    return s.toLowerCase();
  }

  List<Map<String, dynamic>> _dedupeRaw(List<Map<String, dynamic>> input) {
    final seen = <String>{};
    final out = <Map<String, dynamic>>[];
    for (final m in input) {
      final rawId = ((m['id'] ?? m['name']) ?? '').toString();
      final key = _canon(rawId);
      if (key.isEmpty) {
        out.add(m); // keep unknowns
      } else if (seen.add(key)) {
        out.add(m);
      }
    }
    return out;
  }

  List<Map<String, dynamic>> _filterRaw(List<Map<String, dynamic>> input) {
    if (_search.isEmpty) return input;
    final s = _search.toLowerCase();
    return input.where((m) {
      final id = ((m['id'] ?? m['name']) ?? '').toString().toLowerCase();
      return id.contains(s);
    }).toList();
  }

  String _priceLine(ModelDescriptor d) {
    // Stored per 1K internally; display per 1M tokens in whole or 2-dec digits.
    String fmt(double v) {
      final perMillion = v * 1000; // convert per 1K -> per 1M
      if (perMillion >= 1) return perMillion.toStringAsFixed(2);
      if (perMillion >= 0.01) return perMillion.toStringAsFixed(2);
      return perMillion.toStringAsFixed(4);
    }

    final pIn = d.promptPrice != null ? '\$${fmt(d.promptPrice!)}' : '—';
    final pOut =
        d.completionPrice != null ? '\$${fmt(d.completionPrice!)}' : '—';
    return 'USD / 1M tokens  prompt $pIn  •  completion $pOut';
  }

  Widget _buildBody(
    BuildContext context, {
    required bool loading,
    required String? error,
    required bool empty,
    required DateTime? updatedAt,
    required int itemCount,
    required Widget Function(int) itemBuilder,
    required VoidCallback onRefresh,
  }) {
    final l10n = AppLocalizations.of(context)!;
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) return Center(child: Text(l10n.errorPrefix(error)));
    if (empty) {
      return Center(child: Text(l10n.noModelsData));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 8, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                    l10n.providerModelsTitle(widget.provider.toUpperCase()),
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              IconButton(
                onPressed: onRefresh,
                tooltip: l10n.refresh,
                icon: const Icon(Icons.refresh, size: 20),
              ),
              IconButton(
                onPressed: () => launchUrl(Uri.parse(_providerUrl())),
                tooltip: l10n.openDocs,
                icon: const Icon(Icons.open_in_new, size: 20),
              ),
            ],
          ),
        ),
        // Filters / Search bar
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 4),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                    isDense: true,
                    prefixIcon: const Icon(Icons.search),
                    hintText: l10n.searchModels),
                onChanged: (v) => setState(() => _search = v.trim()),
              ),
              const SizedBox(height: 4),
              Wrap(spacing: 8, runSpacing: 4, children: [
                FilterChip(
                    label: Text(l10n.chat),
                    selected: _showChat,
                    onSelected: (v) => setState(() => _showChat = v)),
                FilterChip(
                    label: Text(l10n.embeddings),
                    selected: _showEmbeddings,
                    onSelected: (v) => setState(() => _showEmbeddings = v)),
                FilterChip(
                    label: Text(l10n.imageVision),
                    selected: _showImage,
                    onSelected: (v) => setState(() => _showImage = v)),
                FilterChip(
                    label: Text(l10n.billingRequired),
                    selected: _showBillingOnly,
                    onSelected: (v) => setState(() => _showBillingOnly = v)),
              ]),
            ],
          ),
        ),
        if (updatedAt != null)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 4),
            child: Text(
              l10n.lastUpdate(updatedAt.toUtc().toIso8601String()),
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(fontSize: 11),
            ),
          ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (ctx, i) => itemBuilder(i),
          ),
        ),
      ],
    );
  }
}
