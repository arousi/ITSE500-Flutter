import 'package:file_picker/file_picker.dart';
import 'package:flutter_app_itse500/core/models/message.dart';
import 'package:flutter_app_itse500/core/models/conversation.dart';

class AttachmentPicked extends ChatState {
  final PlatformFile file;
  AttachmentPicked(this.file);
}

abstract class ChatState {}

class ChatConfigChanged extends ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<Conversation> conversations;
  final List<Message> messages;
  final String? attachmentUrl; // Added attachmentUrl field

  ChatLoaded({
    required this.conversations,
    required this.messages,
    this.attachmentUrl, // Added attachmentUrl to constructor
  });
}

class ChatMessageSending extends ChatState {}

class ChatMessageSent extends ChatState {
  final Message message;
  ChatMessageSent({required this.message});
}

class ChatSyncing extends ChatState {}

class ChatError extends ChatState {
  final String error;
  ChatError({required this.error});
}

// Artifact generation states
class ChatGeneratingImage extends ChatState {
  final String prompt;
  ChatGeneratingImage(this.prompt);
}

class ChatImageGenerated extends ChatState {
  final String attachmentPath;
  ChatImageGenerated(this.attachmentPath);
}

class ChatGeneratingEmbedding extends ChatState {
  final String text;
  ChatGeneratingEmbedding(this.text);
}

class ChatEmbeddingGenerated extends ChatState {
  final int dims;
  ChatEmbeddingGenerated(this.dims);
}

class ChatSharePreparing extends ChatState {
  final String attachmentPath;
  ChatSharePreparing(this.attachmentPath);
}

class ChatShareFailed extends ChatState {
  final String error;
  ChatShareFailed(this.error);
}
