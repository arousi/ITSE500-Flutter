import 'package:flutter/material.dart';
import 'package:flutter_app_itse500/core/models/message_request.dart';
import 'package:flutter_app_itse500/features/chat/widgets/message_input.dart';
import 'package:flutter_app_itse500/features/chat/widgets/message_list.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app_itse500/features/chat/logic/chat_cubit.dart';
import 'package:flutter_app_itse500/features/chat/logic/chat_state.dart';
import 'package:flutter_app_itse500/features/chat_inference/logic/inference_settings_cubit.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatCubit = context.read<ChatCubit>();
    // Derive current selection from ChatCubit to avoid resetting the user's choice
    final selectedProvider = chatCubit.activeProvider ??
        (chatCubit.providerLLMs.keys.isNotEmpty
            ? chatCubit.providerLLMs.keys.first
            : '');
    final selectedModelsForProvider = selectedProvider.isNotEmpty
        ? (chatCubit.selectedProviderLLMs[selectedProvider] ?? const <String>[])
        : const <String>[];
    final selectedModel = chatCubit.activeModel ??
        (selectedModelsForProvider.isNotEmpty
            ? selectedModelsForProvider.first
            : null);
    return Column(
      children: [
        // Chat content only; AppBar & Drawer provided by MainScreen
        Expanded(
          child: BlocBuilder<ChatCubit, ChatState>(
            builder: (context, state) {
              if (state is ChatLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ChatLoaded) {
                return MessageList(messages: state.messages);
              } else if (state is ChatError) {
                return Center(child: Text('Error: ${state.error}'));
              }
              return const Center(child: Text('No messages yet.'));
            },
          ),
        ),
        MessageInput(
          controller: _controller,
          onSend: () {
            final text = _controller.text.trim();
            if (text.isEmpty) return;
            final inference = context.read<InferenceSettingsCubit>().state;
            final request = MessageRequest(
              requestModel: selectedModel,
              requestUserRole: 'user',
              requestUserContent: text,
              requestTemperature:
                  inference.useTemperature ? inference.temperature : null,
              requestTopP: inference.useTopP ? inference.topP : null,
              requestN: 1,
              requestStream: false,
              requestStop: null,
              requestMaxTokens: 512,
              requestTopK: inference.useTopK ? inference.topK : null,
              repeatPenalty:
                  inference.useRepeatPenalty ? inference.repeatPenalty : null,
              requestMinP: inference.useMinP ? inference.minP : null,
              requestId: '',
            );
            chatCubit
                .sendMessage(
              request: request,
              inferenceSettings: inference,
            )
                .then((_) {
              _controller.clear();
            });
          },
          providers: chatCubit.providerLLMs.keys.toList(),
          providerApiKeys: chatCubit.providerApiKeys,
          providerModels: chatCubit.providerLLMs,
          selectedProvider: selectedProvider,
          selectedModel: selectedModel,
          onProviderModelChanged: (provider, model) {
            chatCubit.setActiveProviderModel(provider, model);
          },
        ),
      ],
    );
  }
}
