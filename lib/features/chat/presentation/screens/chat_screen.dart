import 'package:flutter/material.dart';
import 'package:flutter_app_itse500/core/utils/unified_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../chat/logic/chat_cubit.dart';
import '../../../../core/models/message_request.dart';
import '../../../chat_inference/logic/inference_settings_cubit.dart';
import '../../../../core/models/message.dart';
import 'package:flutter_app_itse500/features/chat/widgets/message_bubble.dart';
import 'package:flutter_app_itse500/features/chat/widgets/message_input.dart';
import '../../../chat/logic/chat_state.dart';
import 'package:flutter_app_itse500/core/widgets/toaster.dart';
import 'package:go_router/go_router.dart';
// inference settings import already present above

class ChatScreen extends StatefulWidget {
  final String? conversationId;
  const ChatScreen({super.key, this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Map<String, String> get _providerApiKeys =>
      context.watch<ChatCubit>().providerApiKeys;
  Map<String, List<String>> get _providerModels =>
      context.watch<ChatCubit>().providerLLMs;
  String? _apiKey;
  final logger = UnifiedLogger.instance;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedProvider = 'openai';
  String? _activeConversationId;
  // Filter out providers disabled for chat (e.g., huggingface alpha) while keeping them elsewhere
  List<String> get _providers => context
      .read<ChatCubit>()
      .supportedProviders
      .where((p) => p != 'huggingface')
      .toList();
  List<Message> _messages = [];
  String? _selectedModel;
  String? _lastError; // retain last error to display without clearing messages
  bool _showGoDown = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the route provided a new conversationId while keeping the same screen type,
    // reload the thread for that conversation.
    if (widget.conversationId != oldWidget.conversationId &&
        widget.conversationId != null) {
      _activeConversationId = widget.conversationId;
      final chatCubit = context.read<ChatCubit>();
      chatCubit.setActiveConversationId(_activeConversationId!);
      chatCubit.loadConversation(_activeConversationId!, emitLoaded: true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) GoRouter.of(context).go('/chat');
      });
    }
  }

  Future<void> _sendMessage() async {
    final chatCubit = BlocProvider.of<ChatCubit>(context);
    final inference = context.read<InferenceSettingsCubit>().state;
    final content = _messageController.text.trim();
    if (content.isEmpty) return;
    // Guard: provider must be enabled, connected, and have a key
    final isEnabled = chatCubit.providerEnabled[_selectedProvider] ?? false;
    final isConnected = chatCubit.providerConnected[_selectedProvider] ?? false;
    final key = await chatCubit.getApiKey(_selectedProvider);
    final hasKey = key != null && key.isNotEmpty;
    if (!(isEnabled && isConnected && hasKey)) {
      Toaster.show(context,
          'Selected provider is disabled or not configured. Enable it in Config/Profile.');
      return;
    }
    final requestId = DateTime.now().millisecondsSinceEpoch.toString();
    const capability = {
      'openai': {'temperature', 'top_p'},
      'openrouter': {
        'temperature',
        'top_p',
        'top_k',
        'min_p',
        'repeat_penalty'
      },
      'gemini': {'temperature', 'top_p'},
      'lmstudio': {'temperature', 'top_p', 'top_k', 'repeat_penalty'},
    };
    final supported = capability[_selectedProvider] ?? <String>{};
    final req = MessageRequest(
      requestId: requestId,
      requestUserRole: 'user',
      requestUserContent: content,
      requestModel: _selectedModel,
      requestStream: true,
      requestTemperature:
          inference.useTemperature && supported.contains('temperature')
              ? inference.temperature
              : null,
      requestTopP: inference.useTopP && supported.contains('top_p')
          ? inference.topP
          : null,
      requestTopK: inference.useTopK && supported.contains('top_k')
          ? inference.topK
          : null,
      requestMinP: inference.useMinP && supported.contains('min_p')
          ? inference.minP
          : null,
      repeatPenalty:
          inference.useRepeatPenalty && supported.contains('repeat_penalty')
              ? inference.repeatPenalty
              : null,
    );
    // Force single-provider dispatch so we don't hit all providers unintentionally
    await chatCubit.sendMessage(
      request: req,
      conversationId: _activeConversationId,
      multiProvider: false,
      singleProviderOverride: _selectedProvider,
      inferenceSettings: inference,
    );
    _messageController.clear();
  }

  @override
  void initState() {
    super.initState();
    logger.i('Chat Screen Entered');
    _scrollController.addListener(_onScroll);
    _bootstrapConversation();
    // Ensure initial provider is first supported (avoids mismatch if list changed)
    final sup = _providers;
    if (sup.isNotEmpty && !sup.contains(_selectedProvider)) {
      _selectedProvider = sup.first;
    }
    _checkApiKeyAndLoadModels(_selectedProvider);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    final atBottom = (pos.maxScrollExtent - pos.pixels) <= 200;
    final shouldShow = !atBottom && pos.maxScrollExtent > 200;
    if (shouldShow != _showGoDown) {
      setState(() {
        _showGoDown = shouldShow;
      });
    }
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    final target = _scrollController.position.maxScrollExtent;
    if (animated) {
      _scrollController.animateTo(target,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      _scrollController.jumpTo(target);
    }
  }

  Future<void> _bootstrapConversation() async {
    final chatCubit = context.read<ChatCubit>();
    final provided = widget.conversationId;
    if (provided != null && provided.isNotEmpty) {
      _activeConversationId = provided;
      chatCubit.setActiveConversationId(provided);
    } else {
      final existing = chatCubit.activeConversationId;
      if (existing != null) {
        _activeConversationId = existing;
      } else {
        _activeConversationId = chatCubit.ensureConversation();
      }
    }
    // Load messages from DB for current conversation
    await chatCubit.loadConversation(_activeConversationId!, emitLoaded: true);
    if (mounted && widget.conversationId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) GoRouter.of(context).go('/chat');
      });
    }
  }

  Future<void> _checkApiKeyAndLoadModels(String provider) async {
    final chatCubit = BlocProvider.of<ChatCubit>(context);
    Map<String, String> apiKeys = {};
    for (final p in _providers) {
      final key = await chatCubit.getApiKey(p);
      apiKeys[p] = key ?? '';
    }
    setState(() {
      _apiKey = apiKeys[provider];
    });
    if (_apiKey == null || _apiKey!.isEmpty) {
      // Don’t force a model when no key; let user pick from dropdown if available
      if (mounted)
        setState(() {
          _selectedModel = _selectedModel;
        });
      return;
    }
    final selected =
        chatCubit.selectedProviderLLMs[provider] ?? const <String>[];
    // Only default a model if none is selected yet
    if (_selectedModel == null || _selectedProvider != provider) {
      if (mounted)
        setState(() {
          _selectedModel = selected.isNotEmpty ? selected.first : null;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.i('Chat Screen build');
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: Column(
          children: [
            // Conversation chips removed per request; use drawer to navigate conversations.
            const SizedBox.shrink(),
            Expanded(
              child: BlocListener<ChatCubit, ChatState>(
                listenWhen: (prev, curr) =>
                    curr is ChatLoaded ||
                    curr is ChatError ||
                    curr is ChatGeneratingImage ||
                    curr is ChatImageGenerated ||
                    curr is ChatGeneratingEmbedding ||
                    curr is ChatEmbeddingGenerated,
                listener: (context, state) {
                  if (state is ChatLoaded) {
                    setState(() {
                      _messages = state.messages;
                    });
                    WidgetsBinding.instance.addPostFrameCallback(
                        (_) => _scrollToBottom(animated: true));
                  } else if (state is ChatError) {
                    setState(() {
                      _lastError = state.error;
                    });
                    Toaster.show(context, state.error);
                  } else if (state is ChatGeneratingImage) {
                    Toaster.show(context, 'Generating image…');
                  } else if (state is ChatImageGenerated) {
                    Toaster.show(context, 'Image generated');
                  } else if (state is ChatGeneratingEmbedding) {
                    Toaster.show(context, 'Generating embedding…');
                  } else if (state is ChatEmbeddingGenerated) {
                    Toaster.show(
                        context, 'Embedding generated (${state.dims} dims)');
                  }
                },
                child: Stack(
                  children: [
                    if (_messages.isEmpty)
                      const Center(child: Text('No messages yet'))
                    else
                      ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) =>
                            MessageBubble(message: _messages[index]),
                      ),
                    // Go Down button
                    if (_showGoDown)
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: FloatingActionButton.small(
                          tooltip: 'Go to latest',
                          onPressed: () => _scrollToBottom(animated: true),
                          child: const Icon(Icons.arrow_downward),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MessageInput(
                selectedProvider: _selectedProvider,
                providers: _providers,
                providerApiKeys: _providerApiKeys,
                providerModels: _providerModels,
                onProviderModelChanged: (provider, model) {
                  setState(() {
                    _selectedProvider = provider;
                    _selectedModel = model;
                  });
                  context
                      .read<ChatCubit>()
                      .setActiveProviderModel(provider, model);
                },
                controller: _messageController,
                onSend: () {
                  _sendMessage();
                },
                selectedModel: _selectedModel,
                errorText: _lastError,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
