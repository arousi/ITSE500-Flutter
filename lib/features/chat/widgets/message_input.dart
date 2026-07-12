import 'package:flutter/material.dart';
// Removed unused imports
import 'package:flutter_app_itse500/features/chat/logic/chat_cubit.dart';
// import 'package:flutter_app_itse500/features/chat_inference/logic/inference_settings_cubit.dart'; // not used currently
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app_itse500/core/widgets/toaster.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app_itse500/features/chat/logic/chat_state.dart';
import 'package:flutter_app_itse500/l10n/app_localizations.dart';

class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final List<String> providers;
  final Map<String, String?> providerApiKeys;
  final Map<String, List<String>> providerModels;
  final String selectedProvider;
  final String? selectedModel;
  final Function(String provider, String model) onProviderModelChanged;
  final String? errorText;

  const MessageInput({
    super.key,
    required this.controller,
    required this.onSend,
    required this.providers,
    required this.providerApiKeys,
    required this.providerModels,
    required this.selectedProvider,
    required this.selectedModel,
    required this.onProviderModelChanged,
    this.errorText,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  Map<String, String?> _apiKeys = {};

  // Heuristic model classification
  String _classify(String provider, String model) {
    final lower = model.toLowerCase();
    if (lower.contains('embed')) return 'Embedding';
    if (lower.contains('image') || lower.contains('dall')) return 'Image';
    if (lower.contains('whisper') ||
        lower.contains('audio') ||
        lower.contains('tts')) return 'Audio';
    if (lower.contains('vision')) return 'Vision';
    if (provider == 'gemini' || provider == 'google') {
      if (lower.contains('flash') || lower.contains('pro')) return 'Multimodal';
    }
    if (lower.contains('gpt-4o') || lower.contains('gpt-5'))
      return 'Multimodal';
    return 'Text Chat';
  }

  // Strip vendor prefix (e.g., openrouter 'vendor/model') for cleaner display
  String _displayName(String provider, String model) {
    if (provider == 'openrouter' && model.contains('/')) {
      return model.split('/').last;
    }
    if (provider == 'gemini' && model.startsWith('models/')) {
      return model.replaceFirst('models/', '');
    }
    return model;
  }

  @override
  void initState() {
    super.initState();
    _fetchApiKeys();
  }

  Future<void> _fetchApiKeys() async {
    final chatCubit = context.read<ChatCubit>();
    Map<String, String?> keys = {};
    for (final provider in widget.providers) {
      keys[provider] = await chatCubit.getApiKey(provider);
    }
    setState(() {
      _apiKeys = keys;
    });
  }

  @override
  Widget build(BuildContext context) {
    String fmtBytes(int bytes) {
      const units = ['B', 'KB', 'MB', 'GB'];
      double v = bytes.toDouble();
      int i = 0;
      while (v >= 1024 && i < units.length - 1) {
        v /= 1024;
        i++;
      }
      return '${v.toStringAsFixed(v >= 10 || i == 0 ? 0 : 1)} ${units[i]}';
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF121212) : Colors.grey[100];
    final iconColor = isDark ? Colors.white70 : Colors.grey;
    final inputFill = Theme.of(context).inputDecorationTheme.fillColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: bg,
      child: MultiBlocListener(
        listeners: [
          BlocListener<ChatCubit, ChatState>(
            listenWhen: (prev, curr) => curr is ChatConfigChanged,
            listener: (context, state) {
              _fetchApiKeys(); // refresh keys from storage on any config change
            },
          ),
          BlocListener<ChatCubit, ChatState>(
            listenWhen: (prev, curr) =>
                curr is AttachmentPicked || curr is ChatError,
            listener: (context, state) {
              if (state is AttachmentPicked) {
                final f = state.file;
                final size = f.size;
                Toaster.show(
                    context, 'Attachment added: ${f.name} (${fmtBytes(size)})');
              } else if (state is ChatError) {
                final msg = state.error;
                if (msg.toLowerCase().contains('attach') ||
                    msg.contains('5 MB')) {
                  Toaster.show(context, msg);
                }
              }
            },
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                final chatCubit = context.read<ChatCubit>();
                // Determine active provider (defaults to first enabled or first in list)
                final activeProvider = widget.selectedProvider.isNotEmpty
                    ? widget.selectedProvider
                    : (widget.providers.firstWhere(
                        (p) => (chatCubit.providerEnabled[p] ?? false),
                        orElse: () => widget.providers.isNotEmpty
                            ? widget.providers.first
                            : '',
                      ));

                final List<DropdownMenuItem<String>> items = [];

                for (final provider in widget.providers) {
                  final connected =
                      chatCubit.providerConnected[provider] ?? false;
                  final enabled = chatCubit.providerEnabled[provider] ?? false;
                  final hasKey = _apiKeys[provider] != null &&
                      _apiKeys[provider]!.isNotEmpty;

                  // Only show user-selected (pinned) models in Chat UI
                  final pinned = [
                    ...(chatCubit.selectedProviderLLMs[provider] ??
                        const <String>[])
                  ];
                  // Canonicalize to unprefixed IDs and de-dupe while preserving order
                  String canon(String m) => m.startsWith('models/')
                      ? m.replaceFirst('models/', '')
                      : m;
                  final seen = <String>{};
                  final sourceModels = <String>[];
                  for (final m in pinned) {
                    final key = canon(m);
                    if (seen.add(key)) sourceModels.add(key);
                  }

                  // Header per provider
                  items.add(DropdownMenuItem<String>(
                    enabled: false,
                    value: null,
                    child: InkWell(
                      onTap: () {
                        if (!(connected && hasKey && enabled)) {
                          context.push('/profile');
                        }
                      },
                      child: Row(
                        children: [
                          Text(
                            provider,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: provider == activeProvider
                                  ? Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                  : Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color
                                      ?.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.vpn_key,
                              color: (connected && hasKey && enabled)
                                  ? Colors.green
                                  : Colors.red,
                              size: 18),
                        ],
                      ),
                    ),
                  ));

                  // Build favorites (routing priority) composite entry if user set it
                  final favorites = chatCubit.providerModelPriority[provider] ??
                      const <String>[];
                  if (favorites.isNotEmpty) {
                    // De-dupe in case legacy stored duplicates
                    final seenFav = <String>{};
                    final favList =
                        favorites.where((f) => seenFav.add(f)).toList();
                    final favLabel = 'Favorites: ${favList.take(3).join(', ')}';
                    items.add(DropdownMenuItem<String>(
                      enabled: (connected && hasKey && enabled),
                      value: '$provider|__favorites__',
                      child: Padding(
                        padding:
                            const EdgeInsetsDirectional.only(start: 24, top: 4, bottom: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.star,
                                size: 14, color: Colors.amber),
                            const SizedBox(width: 6),
                            Expanded(
                                child: Text(favLabel,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500))),
                          ],
                        ),
                      ),
                    ));
                  }
                  if (sourceModels.isNotEmpty) {
                    items.addAll(sourceModels.map((model) {
                      final name = _displayName(provider, model);
                      final kind = _classify(provider, model);
                      final isSelected = widget.selectedProvider == provider &&
                          widget.selectedModel == model;
                      return DropdownMenuItem<String>(
                        enabled: (connected && hasKey && enabled),
                        value: '$provider|${canon(model)}',
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 24, top: 4, bottom: 4),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 18,
                                child: isSelected
                                    ? Icon(Icons.check,
                                        size: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary)
                                    : const SizedBox.shrink(),
                              ),
                              Expanded(
                                child: Text(
                                  name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                kind,
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color
                                        ?.withOpacity(0.7)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }));
                  } else {
                    // When no selected models, show a subtle hint row
                    items.add(DropdownMenuItem<String>(
                      enabled: false,
                      value: null,
                      child: Padding(
                        padding:
                            const EdgeInsetsDirectional.only(
                                start: 24, top: 6, bottom: 6),
                        child: Text(
                          'No models selected — open Profile to pick',
                          style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withOpacity(0.7)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ));
                  }
                }

                String? selectedValue;
                if (widget.selectedModel != null &&
                    widget.selectedProvider.isNotEmpty) {
                  selectedValue =
                      '${widget.selectedProvider}|${widget.selectedModel}';
                } else {
                  // When only favorites configured and no explicit model chosen
                  final favs = context
                          .read<ChatCubit>()
                          .providerModelPriority[widget.selectedProvider] ??
                      const <String>[];
                  if (favs.isNotEmpty)
                    selectedValue = '${widget.selectedProvider}|__favorites__';
                }
                final valueExists = selectedValue == null ||
                    items.any((i) => i.value == selectedValue);
                return DropdownButton<String>(
                  value: valueExists ? selectedValue : null,
                  hint: const Text('Select Provider & Model'),
                  isExpanded: true,
                  isDense: true,
                  items: items,
                  onChanged: (val) async {
                    if (val != null) {
                      final parts = val.split('|');
                      if (parts.length == 2) {
                        final prov = parts[0];
                        final chat = context.read<ChatCubit>();
                        final connected = chat.providerConnected[prov] ?? false;
                        final enabled = chat.providerEnabled[prov] ?? false;
                        final hasKey =
                            (await chat.getApiKey(prov))?.isNotEmpty == true;
                        if (!(connected && enabled && hasKey)) {
                          Toaster.show(context,
                              'Provider "$prov" is disabled or not ready. Enable it from Config/Profile.');
                          return;
                        }
                        if (parts[1] == '__favorites__') {
                          // Use first favorite as active model; routing fallback handles rest
                          final favs = context
                                  .read<ChatCubit>()
                                  .providerModelPriority[prov] ??
                              const <String>[];
                          final primary = favs.isNotEmpty ? favs.first : null;
                          if (primary != null) {
                            widget.onProviderModelChanged(prov, primary);
                          }
                          return;
                        }
                        widget.onProviderModelChanged(prov, parts[1]);
                      }
                    }
                  },
                );
              },
            ),
            // Preview queued attachments
            BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                final cubit = context.read<ChatCubit>();
                final atts = cubit.pendingAttachments;
                if (atts.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: -8,
                    children: [
                      for (int i = 0; i < atts.length; i++)
                        Chip(
                          label: Text(
                            '${atts[i].name} — ${fmtBytes(atts[i].size)}',
                            overflow: TextOverflow.ellipsis,
                          ),
                          onDeleted: () => cubit.removePendingAttachmentAt(i),
                        ),
                    ],
                  ),
                );
              },
            ),
            if (widget.errorText != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  widget.errorText!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            Row(
              children: [
                IconButton(
                  tooltip: AppLocalizations.of(context)!.attachFile,
                  icon: Icon(Icons.add, color: iconColor),
                  onPressed: () {
                    context.read<ChatCubit>().pickAttachment();
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.typeAMessage,
                      border: InputBorder.none,
                      filled: true,
                      fillColor: inputFill,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => widget.onSend(),
                  ),
                ),
                IconButton(
                  tooltip: AppLocalizations.of(context)!.send,
                  icon: Icon(Icons.send, color: iconColor),
                  onPressed: () {
                    final text = widget.controller.text.trim();
                    final chatCubit = context.read<ChatCubit>();
                    // Image generation slash commands: support /img and /image aliases (prompt required)
                    if (text.startsWith('/img ') || text == '/img') {
                      final prompt =
                          text.length > 4 ? text.substring(5).trim() : '';
                      if (prompt.isNotEmpty) {
                        chatCubit.generateImageCommand(prompt);
                        widget.controller.clear();
                        return;
                      }
                    } else if (text.startsWith('/image ') || text == '/image') {
                      final prompt =
                          text.length > 6 ? text.substring(7).trim() : '';
                      if (prompt.isNotEmpty) {
                        chatCubit.generateImageCommand(prompt);
                        widget.controller.clear();
                        return;
                      }
                    } else if (text.startsWith('/embed ')) {
                      final body = text.substring(7).trim();
                      if (body.isNotEmpty) {
                        chatCubit.generateEmbeddingCommand(body);
                        widget.controller.clear();
                        return;
                      }
                    }
                    widget.onSend();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
