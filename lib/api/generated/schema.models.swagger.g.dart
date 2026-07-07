// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.models.swagger.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attachment _$AttachmentFromJson(Map<String, dynamic> json) => Attachment(
  id: json['id'] as String?,
  attachmentId: json['attachment_id'] as String?,
  userId: json['user_id'] as String?,
  conversationId: json['conversation_id'] as String,
  messageId: json['message_id'] as String,
  type: json['type'] as String,
  mimeType: json['mime_type'] as String?,
  filePath: json['file_path'] as String?,
  encryptedBlob: json['encrypted_blob'] as String?,
  sizeBytes: (json['size_bytes'] as num?)?.toInt(),
  width: (json['width'] as num?)?.toInt(),
  height: (json['height'] as num?)?.toInt(),
  sha256: json['sha256'] as String?,
  isEncrypted: json['is_encrypted'] as bool?,
  encAlgo: json['enc_algo'] as String?,
  ivBase64: json['iv_base64'] as String?,
  keyRef: json['key_ref'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$AttachmentToJson(Attachment instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'attachment_id': ?instance.attachmentId,
      'user_id': ?instance.userId,
      'conversation_id': instance.conversationId,
      'message_id': instance.messageId,
      'type': instance.type,
      'mime_type': ?instance.mimeType,
      'file_path': ?instance.filePath,
      'encrypted_blob': ?instance.encryptedBlob,
      'size_bytes': ?instance.sizeBytes,
      'width': ?instance.width,
      'height': ?instance.height,
      'sha256': ?instance.sha256,
      'is_encrypted': ?instance.isEncrypted,
      'enc_algo': ?instance.encAlgo,
      'iv_base64': ?instance.ivBase64,
      'key_ref': ?instance.keyRef,
      'created_at': ?instance.createdAt?.toIso8601String(),
    };

AttachmentDoc _$AttachmentDocFromJson(Map<String, dynamic> json) =>
    AttachmentDoc(
      attachmentId: json['attachment_id'] as String?,
      messageId: json['message_id'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$AttachmentDocToJson(AttachmentDoc instance) =>
    <String, dynamic>{
      'attachment_id': ?instance.attachmentId,
      'message_id': ?instance.messageId,
      'url': ?instance.url,
    };

AttachmentRequest _$AttachmentRequestFromJson(Map<String, dynamic> json) =>
    AttachmentRequest(
      id: json['id'] as String?,
      conversationId: json['conversation_id'] as String,
      messageId: json['message_id'] as String,
      type: json['type'] as String,
      mimeType: json['mime_type'] as String?,
      filePath: json['file_path'] as String?,
      encryptedBlob: json['encrypted_blob'] as String?,
      sizeBytes: (json['size_bytes'] as num?)?.toInt(),
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      sha256: json['sha256'] as String?,
      isEncrypted: json['is_encrypted'] as bool?,
      encAlgo: json['enc_algo'] as String?,
      ivBase64: json['iv_base64'] as String?,
      keyRef: json['key_ref'] as String?,
    );

Map<String, dynamic> _$AttachmentRequestToJson(AttachmentRequest instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'conversation_id': instance.conversationId,
      'message_id': instance.messageId,
      'type': instance.type,
      'mime_type': ?instance.mimeType,
      'file_path': ?instance.filePath,
      'encrypted_blob': ?instance.encryptedBlob,
      'size_bytes': ?instance.sizeBytes,
      'width': ?instance.width,
      'height': ?instance.height,
      'sha256': ?instance.sha256,
      'is_encrypted': ?instance.isEncrypted,
      'enc_algo': ?instance.encAlgo,
      'iv_base64': ?instance.ivBase64,
      'key_ref': ?instance.keyRef,
    };

AttachmentUpload _$AttachmentUploadFromJson(Map<String, dynamic> json) =>
    AttachmentUpload(
      attachmentId: json['attachment_id'] as String?,
      messageId: json['message_id'] as String?,
      type: json['type'] as String,
      mimeType: json['mime_type'] as String?,
      encryptedBlob: json['encrypted_blob'] as String?,
      sizeBytes: (json['size_bytes'] as num?)?.toInt(),
      sha256: json['sha256'] as String?,
      isEncrypted: json['is_encrypted'] as bool?,
      encAlgo: json['enc_algo'] as String?,
      ivBase64: json['iv_base64'] as String?,
      keyRef: json['key_ref'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$AttachmentUploadToJson(AttachmentUpload instance) =>
    <String, dynamic>{
      'attachment_id': ?instance.attachmentId,
      'message_id': ?instance.messageId,
      'type': instance.type,
      'mime_type': ?instance.mimeType,
      'encrypted_blob': ?instance.encryptedBlob,
      'size_bytes': ?instance.sizeBytes,
      'sha256': ?instance.sha256,
      'is_encrypted': ?instance.isEncrypted,
      'enc_algo': ?instance.encAlgo,
      'iv_base64': ?instance.ivBase64,
      'key_ref': ?instance.keyRef,
      'created_at': ?instance.createdAt?.toIso8601String(),
    };

AttachmentUploadRequest _$AttachmentUploadRequestFromJson(
  Map<String, dynamic> json,
) => AttachmentUploadRequest(
  type: json['type'] as String,
  mimeType: json['mime_type'] as String?,
  encryptedBlob: json['encrypted_blob'] as String?,
  isEncrypted: json['is_encrypted'] as bool?,
  encAlgo: json['enc_algo'] as String?,
  ivBase64: json['iv_base64'] as String?,
  keyRef: json['key_ref'] as String?,
);

Map<String, dynamic> _$AttachmentUploadRequestToJson(
  AttachmentUploadRequest instance,
) => <String, dynamic>{
  'type': instance.type,
  'mime_type': ?instance.mimeType,
  'encrypted_blob': ?instance.encryptedBlob,
  'is_encrypted': ?instance.isEncrypted,
  'enc_algo': ?instance.encAlgo,
  'iv_base64': ?instance.ivBase64,
  'key_ref': ?instance.keyRef,
};

Conversation _$ConversationFromJson(Map<String, dynamic> json) => Conversation(
  conversationId: json['conversation_id'] as String?,
  userId: json['user_id'] as String?,
  title: json['title'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  localOnly: json['local_only'] as bool?,
  messages:
      (json['messages'] as List<dynamic>?)
          ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$ConversationToJson(Conversation instance) =>
    <String, dynamic>{
      'conversation_id': ?instance.conversationId,
      'user_id': ?instance.userId,
      'title': ?instance.title,
      'created_at': ?instance.createdAt?.toIso8601String(),
      'updated_at': ?instance.updatedAt?.toIso8601String(),
      'local_only': ?instance.localOnly,
      'messages': ?instance.messages?.map((e) => e.toJson()).toList(),
    };

ConversationDoc _$ConversationDocFromJson(Map<String, dynamic> json) =>
    ConversationDoc(
      conversationId: json['conversation_id'] as String,
      title: json['title'] as String?,
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map((e) => MessageDoc.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$ConversationDocToJson(ConversationDoc instance) =>
    <String, dynamic>{
      'conversation_id': instance.conversationId,
      'title': ?instance.title,
      'updated_at': ?instance.updatedAt?.toIso8601String(),
      'messages': instance.messages.map((e) => e.toJson()).toList(),
    };

ConversationRequest _$ConversationRequestFromJson(Map<String, dynamic> json) =>
    ConversationRequest(
      title: json['title'] as String?,
      localOnly: json['local_only'] as bool?,
    );

Map<String, dynamic> _$ConversationRequestToJson(
  ConversationRequest instance,
) => <String, dynamic>{
  'title': ?instance.title,
  'local_only': ?instance.localOnly,
};

DeprecatedEndpointResponse _$DeprecatedEndpointResponseFromJson(
  Map<String, dynamic> json,
) => DeprecatedEndpointResponse(detail: json['detail'] as String);

Map<String, dynamic> _$DeprecatedEndpointResponseToJson(
  DeprecatedEndpointResponse instance,
) => <String, dynamic>{'detail': instance.detail};

EmailPinVerifyRequestRequest _$EmailPinVerifyRequestRequestFromJson(
  Map<String, dynamic> json,
) => EmailPinVerifyRequestRequest(
  email: json['email'] as String,
  pin: json['pin'] as String,
);

Map<String, dynamic> _$EmailPinVerifyRequestRequestToJson(
  EmailPinVerifyRequestRequest instance,
) => <String, dynamic>{'email': instance.email, 'pin': instance.pin};

EmailPinVerifyResponse _$EmailPinVerifyResponseFromJson(
  Map<String, dynamic> json,
) => EmailPinVerifyResponse(message: json['message'] as String);

Map<String, dynamic> _$EmailPinVerifyResponseToJson(
  EmailPinVerifyResponse instance,
) => <String, dynamic>{'message': instance.message};

FullChat _$FullChatFromJson(Map<String, dynamic> json) => FullChat(
  conversations:
      (json['conversations'] as List<dynamic>?)
          ?.map((e) => Conversation.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  messages:
      (json['messages'] as List<dynamic>?)
          ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  messageRequest:
      (json['message_request'] as List<dynamic>?)
          ?.map((e) => MessageRequest.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  messageResponse:
      (json['message_response'] as List<dynamic>?)
          ?.map((e) => MessageResponse.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  messageOutput:
      (json['message_output'] as List<dynamic>?)
          ?.map((e) => MessageOutput.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  attachments:
      (json['attachments'] as List<dynamic>?)
          ?.map((e) => Attachment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$FullChatToJson(FullChat instance) => <String, dynamic>{
  'conversations': ?instance.conversations?.map((e) => e.toJson()).toList(),
  'messages': ?instance.messages?.map((e) => e.toJson()).toList(),
  'message_request': ?instance.messageRequest?.map((e) => e.toJson()).toList(),
  'message_response': ?instance.messageResponse
      ?.map((e) => e.toJson())
      .toList(),
  'message_output': ?instance.messageOutput?.map((e) => e.toJson()).toList(),
  'attachments': ?instance.attachments?.map((e) => e.toJson()).toList(),
};

FullProfile _$FullProfileFromJson(Map<String, dynamic> json) => FullProfile(
  userId: json['user_id'] as String?,
  username: json['username'] as String,
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  email: json['email'] as String,
  phoneNumber: json['phone_number'] as String?,
  lastModified: json['last_modified'] == null
      ? null
      : DateTime.parse(json['last_modified'] as String),
  devicesId: json['devices_id'],
  tempId: json['temp_id'] as String?,
  relatedDevices: json['related_devices'],
  emailPinCreated: json['email_pin_created'] == null
      ? null
      : DateTime.parse(json['email_pin_created'] as String),
  emailVerified: json['email_verified'] as bool?,
  isArchived: json['is_archived'] as bool?,
  isGoogleUser: json['is_google_user'] as bool?,
  isOpenrouterUser: json['is_openrouter_user'] as bool?,
  isMicrosoftUser: json['is_microsoft_user'] as bool?,
  isGithubUser: json['is_github_user'] as bool?,
  isActive: json['is_active'] as bool?,
  isStaff: json['is_staff'] as bool?,
);

Map<String, dynamic> _$FullProfileToJson(FullProfile instance) =>
    <String, dynamic>{
      'user_id': ?instance.userId,
      'username': instance.username,
      'first_name': ?instance.firstName,
      'last_name': ?instance.lastName,
      'email': instance.email,
      'phone_number': ?instance.phoneNumber,
      'last_modified': ?instance.lastModified?.toIso8601String(),
      'devices_id': ?instance.devicesId,
      'temp_id': ?instance.tempId,
      'related_devices': ?instance.relatedDevices,
      'email_pin_created': ?instance.emailPinCreated?.toIso8601String(),
      'email_verified': ?instance.emailVerified,
      'is_archived': ?instance.isArchived,
      'is_google_user': ?instance.isGoogleUser,
      'is_openrouter_user': ?instance.isOpenrouterUser,
      'is_microsoft_user': ?instance.isMicrosoftUser,
      'is_github_user': ?instance.isGithubUser,
      'is_active': ?instance.isActive,
      'is_staff': ?instance.isStaff,
    };

FullProfileRequest _$FullProfileRequestFromJson(Map<String, dynamic> json) =>
    FullProfileRequest(
      username: json['username'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String,
      userPassword: json['user_password'] as String?,
      phoneNumber: json['phone_number'] as String?,
      devicesId: json['devices_id'],
      tempId: json['temp_id'] as String?,
      relatedDevices: json['related_devices'],
      emailPinCreated: json['email_pin_created'] == null
          ? null
          : DateTime.parse(json['email_pin_created'] as String),
      emailVerified: json['email_verified'] as bool?,
      isArchived: json['is_archived'] as bool?,
      isGoogleUser: json['is_google_user'] as bool?,
      isOpenrouterUser: json['is_openrouter_user'] as bool?,
      isMicrosoftUser: json['is_microsoft_user'] as bool?,
      isGithubUser: json['is_github_user'] as bool?,
      isActive: json['is_active'] as bool?,
      isStaff: json['is_staff'] as bool?,
    );

Map<String, dynamic> _$FullProfileRequestToJson(FullProfileRequest instance) =>
    <String, dynamic>{
      'username': instance.username,
      'first_name': ?instance.firstName,
      'last_name': ?instance.lastName,
      'email': instance.email,
      'user_password': ?instance.userPassword,
      'phone_number': ?instance.phoneNumber,
      'devices_id': ?instance.devicesId,
      'temp_id': ?instance.tempId,
      'related_devices': ?instance.relatedDevices,
      'email_pin_created': ?instance.emailPinCreated?.toIso8601String(),
      'email_verified': ?instance.emailVerified,
      'is_archived': ?instance.isArchived,
      'is_google_user': ?instance.isGoogleUser,
      'is_openrouter_user': ?instance.isOpenrouterUser,
      'is_microsoft_user': ?instance.isMicrosoftUser,
      'is_github_user': ?instance.isGithubUser,
      'is_active': ?instance.isActive,
      'is_staff': ?instance.isStaff,
    };

HealthCheckResponse _$HealthCheckResponseFromJson(Map<String, dynamic> json) =>
    HealthCheckResponse(
      status: json['status'] as String,
      message: json['message'] as String,
    );

Map<String, dynamic> _$HealthCheckResponseToJson(
  HealthCheckResponse instance,
) => <String, dynamic>{'status': instance.status, 'message': instance.message};

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
  identifier: json['identifier'] as String?,
  email: json['email'],
  username: json['username'] as String?,
  userPassword: json['user_password'] as String?,
);

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'identifier': ?instance.identifier,
      'email': ?instance.email,
      'username': ?instance.username,
      'user_password': ?instance.userPassword,
    };

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      message: json['message'] as String,
      userId: json['user_id'] as String,
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      emailVerified: json['email_verified'] as bool,
      conversations:
          (json['conversations'] as List<dynamic>?)
              ?.map((e) => ConversationDoc.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      attachments:
          (json['attachments'] as List<dynamic>?)
              ?.map((e) => AttachmentDoc.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'user_id': instance.userId,
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'email_verified': instance.emailVerified,
      'conversations': instance.conversations.map((e) => e.toJson()).toList(),
      'attachments': instance.attachments.map((e) => e.toJson()).toList(),
    };

LogoutRequestRequest _$LogoutRequestRequestFromJson(
  Map<String, dynamic> json,
) => LogoutRequestRequest(refreshToken: json['refresh_token'] as String?);

Map<String, dynamic> _$LogoutRequestRequestToJson(
  LogoutRequestRequest instance,
) => <String, dynamic>{'refresh_token': ?instance.refreshToken};

LogoutResponse _$LogoutResponseFromJson(Map<String, dynamic> json) =>
    LogoutResponse(detail: json['detail'] as String);

Map<String, dynamic> _$LogoutResponseToJson(LogoutResponse instance) =>
    <String, dynamic>{'detail': instance.detail};

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
  messageId: json['message_id'] as String?,
  userId: json['user_id'] as String?,
  conversationId: json['conversation_id'] as String,
  requestId: json['request_id'] as String?,
  responseId: json['response_id'] as String?,
  outputId: (json['output_id'] as num?)?.toInt(),
  timestamp: json['timestamp'] == null
      ? null
      : DateTime.parse(json['timestamp'] as String),
  status: statusEnumNullableFromJson(json['status']),
  vote: json['vote'] as bool?,
  hasImage: json['has_image'] as bool?,
  imgUrl: json['img_Url'] as String?,
  metadata: json['metadata'],
  hasEmbedding: json['has_embedding'] as bool?,
  hasDocument: json['has_document'] as bool?,
  docUrl: json['doc_url'] as String?,
  request: json['request'] == null
      ? null
      : MessageRequest.fromJson(json['request'] as Map<String, dynamic>),
  response: json['response'] == null
      ? null
      : MessageResponse.fromJson(json['response'] as Map<String, dynamic>),
  output: json['output'] == null
      ? null
      : MessageOutput.fromJson(json['output'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
  'message_id': ?instance.messageId,
  'user_id': ?instance.userId,
  'conversation_id': instance.conversationId,
  'request_id': ?instance.requestId,
  'response_id': ?instance.responseId,
  'output_id': ?instance.outputId,
  'timestamp': ?instance.timestamp?.toIso8601String(),
  'status': ?statusEnumNullableToJson(instance.status),
  'vote': ?instance.vote,
  'has_image': ?instance.hasImage,
  'img_Url': ?instance.imgUrl,
  'metadata': ?instance.metadata,
  'has_embedding': ?instance.hasEmbedding,
  'has_document': ?instance.hasDocument,
  'doc_url': ?instance.docUrl,
  'request': ?instance.request?.toJson(),
  'response': ?instance.response?.toJson(),
  'output': ?instance.output?.toJson(),
};

MessageDoc _$MessageDocFromJson(Map<String, dynamic> json) => MessageDoc(
  messageId: json['message_id'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  hasImage: json['has_image'] as bool?,
  hasDocument: json['has_document'] as bool?,
);

Map<String, dynamic> _$MessageDocToJson(MessageDoc instance) =>
    <String, dynamic>{
      'message_id': instance.messageId,
      'timestamp': instance.timestamp.toIso8601String(),
      'has_image': ?instance.hasImage,
      'has_document': ?instance.hasDocument,
    };

MessageOutput _$MessageOutputFromJson(Map<String, dynamic> json) =>
    MessageOutput(
      id: (json['id'] as num?)?.toInt(),
      outputType: json['output_type'] as String?,
      outputId: json['output_id'] as String?,
      outputStatus: json['output_status'] as String?,
      outputRole: json['output_role'] as String?,
      outputContentType: json['output_content_type'] as String?,
      outputContentText: json['output_content_text'] as String?,
      outputContentAnnotations: json['output_content_annotations'] as String?,
    );

Map<String, dynamic> _$MessageOutputToJson(MessageOutput instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'output_type': ?instance.outputType,
      'output_id': ?instance.outputId,
      'output_status': ?instance.outputStatus,
      'output_role': ?instance.outputRole,
      'output_content_type': ?instance.outputContentType,
      'output_content_text': ?instance.outputContentText,
      'output_content_annotations': ?instance.outputContentAnnotations,
    };

MessageOutputRequest _$MessageOutputRequestFromJson(
  Map<String, dynamic> json,
) => MessageOutputRequest(
  outputType: json['output_type'] as String?,
  outputId: json['output_id'] as String?,
  outputStatus: json['output_status'] as String?,
  outputRole: json['output_role'] as String?,
  outputContentType: json['output_content_type'] as String?,
  outputContentText: json['output_content_text'] as String?,
  outputContentAnnotations: json['output_content_annotations'] as String?,
);

Map<String, dynamic> _$MessageOutputRequestToJson(
  MessageOutputRequest instance,
) => <String, dynamic>{
  'output_type': ?instance.outputType,
  'output_id': ?instance.outputId,
  'output_status': ?instance.outputStatus,
  'output_role': ?instance.outputRole,
  'output_content_type': ?instance.outputContentType,
  'output_content_text': ?instance.outputContentText,
  'output_content_annotations': ?instance.outputContentAnnotations,
};

MessageRequest _$MessageRequestFromJson(Map<String, dynamic> json) =>
    MessageRequest(
      requestId: json['request_id'] as String?,
      requestModel: json['request_model'] as String?,
      requestInput: json['request_input'] as String?,
      requestSystemRole: json['request_system_role'] as String?,
      requestSystemContent: json['request_system_content'] as String?,
      requestSystemPrompt: json['request_system_prompt'] as String?,
      requestUserStructuredOutput:
          json['request_user_structured_output'] as bool?,
      requestStructuredSchema: json['request_structured_schema'] as String?,
      requestUserRole: json['request_user_role'] as String?,
      requestUserContent: json['request_user_content'] as String?,
      requestMinP: (json['request_min_p'] as num?)?.toDouble(),
      requestTemperature: (json['request_temperature'] as num?)?.toDouble(),
      requestTopP: (json['request_top_p'] as num?)?.toDouble(),
      requestN: (json['request_n'] as num?)?.toInt(),
      requestTopK: (json['request_top_k'] as num?)?.toInt(),
      requestStream: json['request_stream'] as bool?,
      requestStop: json['request_stop'] as String?,
      requestMaxTokens: (json['request_max_tokens'] as num?)?.toInt(),
      repeatPenalty: (json['repeat_penalty'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$MessageRequestToJson(MessageRequest instance) =>
    <String, dynamic>{
      'request_id': ?instance.requestId,
      'request_model': ?instance.requestModel,
      'request_input': ?instance.requestInput,
      'request_system_role': ?instance.requestSystemRole,
      'request_system_content': ?instance.requestSystemContent,
      'request_system_prompt': ?instance.requestSystemPrompt,
      'request_user_structured_output': ?instance.requestUserStructuredOutput,
      'request_structured_schema': ?instance.requestStructuredSchema,
      'request_user_role': ?instance.requestUserRole,
      'request_user_content': ?instance.requestUserContent,
      'request_min_p': ?instance.requestMinP,
      'request_temperature': ?instance.requestTemperature,
      'request_top_p': ?instance.requestTopP,
      'request_n': ?instance.requestN,
      'request_top_k': ?instance.requestTopK,
      'request_stream': ?instance.requestStream,
      'request_stop': ?instance.requestStop,
      'request_max_tokens': ?instance.requestMaxTokens,
      'repeat_penalty': ?instance.repeatPenalty,
    };

MessageRequestRequest _$MessageRequestRequestFromJson(
  Map<String, dynamic> json,
) => MessageRequestRequest(
  requestModel: json['request_model'] as String?,
  requestInput: json['request_input'] as String?,
  requestSystemRole: json['request_system_role'] as String?,
  requestSystemContent: json['request_system_content'] as String?,
  requestSystemPrompt: json['request_system_prompt'] as String?,
  requestUserStructuredOutput: json['request_user_structured_output'] as bool?,
  requestStructuredSchema: json['request_structured_schema'] as String?,
  requestUserRole: json['request_user_role'] as String?,
  requestUserContent: json['request_user_content'] as String?,
  requestMinP: (json['request_min_p'] as num?)?.toDouble(),
  requestTemperature: (json['request_temperature'] as num?)?.toDouble(),
  requestTopP: (json['request_top_p'] as num?)?.toDouble(),
  requestN: (json['request_n'] as num?)?.toInt(),
  requestTopK: (json['request_top_k'] as num?)?.toInt(),
  requestStream: json['request_stream'] as bool?,
  requestStop: json['request_stop'] as String?,
  requestMaxTokens: (json['request_max_tokens'] as num?)?.toInt(),
  repeatPenalty: (json['repeat_penalty'] as num?)?.toDouble(),
);

Map<String, dynamic> _$MessageRequestRequestToJson(
  MessageRequestRequest instance,
) => <String, dynamic>{
  'request_model': ?instance.requestModel,
  'request_input': ?instance.requestInput,
  'request_system_role': ?instance.requestSystemRole,
  'request_system_content': ?instance.requestSystemContent,
  'request_system_prompt': ?instance.requestSystemPrompt,
  'request_user_structured_output': ?instance.requestUserStructuredOutput,
  'request_structured_schema': ?instance.requestStructuredSchema,
  'request_user_role': ?instance.requestUserRole,
  'request_user_content': ?instance.requestUserContent,
  'request_min_p': ?instance.requestMinP,
  'request_temperature': ?instance.requestTemperature,
  'request_top_p': ?instance.requestTopP,
  'request_n': ?instance.requestN,
  'request_top_k': ?instance.requestTopK,
  'request_stream': ?instance.requestStream,
  'request_stop': ?instance.requestStop,
  'request_max_tokens': ?instance.requestMaxTokens,
  'repeat_penalty': ?instance.repeatPenalty,
};

MessageResponse _$MessageResponseFromJson(Map<String, dynamic> json) =>
    MessageResponse(
      responseId: json['response_id'] as String,
      object: json['object'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      status: json['status'] as String?,
      error: json['error'] as String?,
      modelName: json['model_name'] as String?,
      parallelToolCalls: json['parallel_tool_calls'] as bool?,
      previousResponseId: json['previous_response_id'] as String?,
      instructions: json['instructions'] as String?,
      reasoningEffort: json['reasoning_effort'] as String?,
      reasoningSummary: json['reasoning_summary'] as String?,
      store: json['store'] as bool?,
      temperature: (json['temperature'] as num?)?.toDouble(),
      textFormatType: json['text_format_type'] as String?,
      toolChoice: json['tool_choice'] as String?,
      tools: json['tools'] as String?,
      topP: (json['top_p'] as num?)?.toDouble(),
      truncation: json['truncation'] as String?,
      usageInputTokens: (json['usage_input_tokens'] as num?)?.toInt(),
      usageOutputTokens: (json['usage_output_tokens'] as num?)?.toInt(),
      usageTotalTokens: (json['usage_total_tokens'] as num?)?.toInt(),
      user: json['user'] as String?,
      metadata: json['metadata'],
      incompleteDetails: json['incomplete_details'] as String?,
      maxOutputTokens: (json['max_output_tokens'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MessageResponseToJson(MessageResponse instance) =>
    <String, dynamic>{
      'response_id': instance.responseId,
      'object': ?instance.object,
      'created_at': ?instance.createdAt?.toIso8601String(),
      'status': ?instance.status,
      'error': ?instance.error,
      'model_name': ?instance.modelName,
      'parallel_tool_calls': ?instance.parallelToolCalls,
      'previous_response_id': ?instance.previousResponseId,
      'instructions': ?instance.instructions,
      'reasoning_effort': ?instance.reasoningEffort,
      'reasoning_summary': ?instance.reasoningSummary,
      'store': ?instance.store,
      'temperature': ?instance.temperature,
      'text_format_type': ?instance.textFormatType,
      'tool_choice': ?instance.toolChoice,
      'tools': ?instance.tools,
      'top_p': ?instance.topP,
      'truncation': ?instance.truncation,
      'usage_input_tokens': ?instance.usageInputTokens,
      'usage_output_tokens': ?instance.usageOutputTokens,
      'usage_total_tokens': ?instance.usageTotalTokens,
      'user': ?instance.user,
      'metadata': ?instance.metadata,
      'incomplete_details': ?instance.incompleteDetails,
      'max_output_tokens': ?instance.maxOutputTokens,
    };

MessageResponseRequest _$MessageResponseRequestFromJson(
  Map<String, dynamic> json,
) => MessageResponseRequest(
  responseId: json['response_id'] as String,
  object: json['object'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  status: json['status'] as String?,
  error: json['error'] as String?,
  modelName: json['model_name'] as String?,
  parallelToolCalls: json['parallel_tool_calls'] as bool?,
  previousResponseId: json['previous_response_id'] as String?,
  instructions: json['instructions'] as String?,
  reasoningEffort: json['reasoning_effort'] as String?,
  reasoningSummary: json['reasoning_summary'] as String?,
  store: json['store'] as bool?,
  temperature: (json['temperature'] as num?)?.toDouble(),
  textFormatType: json['text_format_type'] as String?,
  toolChoice: json['tool_choice'] as String?,
  tools: json['tools'] as String?,
  topP: (json['top_p'] as num?)?.toDouble(),
  truncation: json['truncation'] as String?,
  usageInputTokens: (json['usage_input_tokens'] as num?)?.toInt(),
  usageOutputTokens: (json['usage_output_tokens'] as num?)?.toInt(),
  usageTotalTokens: (json['usage_total_tokens'] as num?)?.toInt(),
  metadata: json['metadata'],
  incompleteDetails: json['incomplete_details'] as String?,
  maxOutputTokens: (json['max_output_tokens'] as num?)?.toInt(),
);

Map<String, dynamic> _$MessageResponseRequestToJson(
  MessageResponseRequest instance,
) => <String, dynamic>{
  'response_id': instance.responseId,
  'object': ?instance.object,
  'created_at': ?instance.createdAt?.toIso8601String(),
  'status': ?instance.status,
  'error': ?instance.error,
  'model_name': ?instance.modelName,
  'parallel_tool_calls': ?instance.parallelToolCalls,
  'previous_response_id': ?instance.previousResponseId,
  'instructions': ?instance.instructions,
  'reasoning_effort': ?instance.reasoningEffort,
  'reasoning_summary': ?instance.reasoningSummary,
  'store': ?instance.store,
  'temperature': ?instance.temperature,
  'text_format_type': ?instance.textFormatType,
  'tool_choice': ?instance.toolChoice,
  'tools': ?instance.tools,
  'top_p': ?instance.topP,
  'truncation': ?instance.truncation,
  'usage_input_tokens': ?instance.usageInputTokens,
  'usage_output_tokens': ?instance.usageOutputTokens,
  'usage_total_tokens': ?instance.usageTotalTokens,
  'metadata': ?instance.metadata,
  'incomplete_details': ?instance.incompleteDetails,
  'max_output_tokens': ?instance.maxOutputTokens,
};

MessageWrite _$MessageWriteFromJson(Map<String, dynamic> json) => MessageWrite(
  messageId: json['message_id'] as String?,
  userId: json['user_id'] as String?,
  conversationId: json['conversation_id'] as String?,
  requestId: json['request_id'] as String?,
  responseId: json['response_id'] as String?,
  outputId: (json['output_id'] as num?)?.toInt(),
  timestamp: json['timestamp'] == null
      ? null
      : DateTime.parse(json['timestamp'] as String),
  status: statusEnumNullableFromJson(json['status']),
  vote: json['vote'] as bool?,
  hasImage: json['has_image'] as bool?,
  imgUrl: json['img_Url'] as String?,
  metadata: json['metadata'],
  hasEmbedding: json['has_embedding'] as bool?,
  hasDocument: json['has_document'] as bool?,
  docUrl: json['doc_url'] as String?,
  request: json['request'] == null
      ? null
      : MessageRequest.fromJson(json['request'] as Map<String, dynamic>),
  response: json['response'] == null
      ? null
      : MessageResponse.fromJson(json['response'] as Map<String, dynamic>),
  output: json['output'] == null
      ? null
      : MessageOutput.fromJson(json['output'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MessageWriteToJson(MessageWrite instance) =>
    <String, dynamic>{
      'message_id': ?instance.messageId,
      'user_id': ?instance.userId,
      'conversation_id': ?instance.conversationId,
      'request_id': ?instance.requestId,
      'response_id': ?instance.responseId,
      'output_id': ?instance.outputId,
      'timestamp': ?instance.timestamp?.toIso8601String(),
      'status': ?statusEnumNullableToJson(instance.status),
      'vote': ?instance.vote,
      'has_image': ?instance.hasImage,
      'img_Url': ?instance.imgUrl,
      'metadata': ?instance.metadata,
      'has_embedding': ?instance.hasEmbedding,
      'has_document': ?instance.hasDocument,
      'doc_url': ?instance.docUrl,
      'request': ?instance.request?.toJson(),
      'response': ?instance.response?.toJson(),
      'output': ?instance.output?.toJson(),
    };

MessageWriteRequest _$MessageWriteRequestFromJson(Map<String, dynamic> json) =>
    MessageWriteRequest(
      conversationId: json['conversation_id'] as String?,
      requestId: json['request_id'] as String?,
      responseId: json['response_id'] as String?,
      outputId: (json['output_id'] as num?)?.toInt(),
      status: statusEnumNullableFromJson(json['status']),
      vote: json['vote'] as bool?,
      hasImage: json['has_image'] as bool?,
      imgUrl: json['img_Url'] as String?,
      metadata: json['metadata'],
      hasEmbedding: json['has_embedding'] as bool?,
      hasDocument: json['has_document'] as bool?,
      docUrl: json['doc_url'] as String?,
    );

Map<String, dynamic> _$MessageWriteRequestToJson(
  MessageWriteRequest instance,
) => <String, dynamic>{
  'conversation_id': ?instance.conversationId,
  'request_id': ?instance.requestId,
  'response_id': ?instance.responseId,
  'output_id': ?instance.outputId,
  'status': ?statusEnumNullableToJson(instance.status),
  'vote': ?instance.vote,
  'has_image': ?instance.hasImage,
  'img_Url': ?instance.imgUrl,
  'metadata': ?instance.metadata,
  'has_embedding': ?instance.hasEmbedding,
  'has_document': ?instance.hasDocument,
  'doc_url': ?instance.docUrl,
};

OAuthCallbackResponse _$OAuthCallbackResponseFromJson(
  Map<String, dynamic> json,
) => OAuthCallbackResponse(
  message: json['message'] as String,
  userId: json['user_id'] as String,
  username: json['username'] as String?,
  accessToken: json['access_token'] as String,
  refreshToken: json['refresh_token'] as String,
  providerScope: json['provider_scope'] as String?,
  providerExpiresAt: json['provider_expires_at'] as String?,
  providerAccessToken: json['provider_access_token'] as String?,
  providerRefreshToken: json['provider_refresh_token'] as String?,
  providerTokenType: json['provider_token_type'] as String?,
  idToken: json['id_token'] as String?,
  email: json['email'] as String?,
  emailVerified: json['email_verified'] as bool?,
  isGoogleUser: json['is_google_user'] as bool?,
  isOpenrouterUser: json['is_openrouter_user'] as bool?,
  isGithubUser: json['is_github_user'] as bool?,
  isMsUser: json['is_ms_user'] as bool?,
);

Map<String, dynamic> _$OAuthCallbackResponseToJson(
  OAuthCallbackResponse instance,
) => <String, dynamic>{
  'message': instance.message,
  'user_id': instance.userId,
  'username': ?instance.username,
  'access_token': instance.accessToken,
  'refresh_token': instance.refreshToken,
  'provider_scope': ?instance.providerScope,
  'provider_expires_at': ?instance.providerExpiresAt,
  'provider_access_token': ?instance.providerAccessToken,
  'provider_refresh_token': ?instance.providerRefreshToken,
  'provider_token_type': ?instance.providerTokenType,
  'id_token': ?instance.idToken,
  'email': ?instance.email,
  'email_verified': ?instance.emailVerified,
  'is_google_user': ?instance.isGoogleUser,
  'is_openrouter_user': ?instance.isOpenrouterUser,
  'is_github_user': ?instance.isGithubUser,
  'is_ms_user': ?instance.isMsUser,
};

PaginatedAttachmentUploadList _$PaginatedAttachmentUploadListFromJson(
  Map<String, dynamic> json,
) => PaginatedAttachmentUploadList(
  count: (json['count'] as num).toInt(),
  next: json['next'] as String?,
  previous: json['previous'] as String?,
  results:
      (json['results'] as List<dynamic>?)
          ?.map((e) => AttachmentUpload.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$PaginatedAttachmentUploadListToJson(
  PaginatedAttachmentUploadList instance,
) => <String, dynamic>{
  'count': instance.count,
  'next': ?instance.next,
  'previous': ?instance.previous,
  'results': instance.results.map((e) => e.toJson()).toList(),
};

PaginatedConversationList _$PaginatedConversationListFromJson(
  Map<String, dynamic> json,
) => PaginatedConversationList(
  count: (json['count'] as num).toInt(),
  next: json['next'] as String?,
  previous: json['previous'] as String?,
  results:
      (json['results'] as List<dynamic>?)
          ?.map((e) => Conversation.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$PaginatedConversationListToJson(
  PaginatedConversationList instance,
) => <String, dynamic>{
  'count': instance.count,
  'next': ?instance.next,
  'previous': ?instance.previous,
  'results': instance.results.map((e) => e.toJson()).toList(),
};

PaginatedMessageList _$PaginatedMessageListFromJson(
  Map<String, dynamic> json,
) => PaginatedMessageList(
  count: (json['count'] as num).toInt(),
  next: json['next'] as String?,
  previous: json['previous'] as String?,
  results:
      (json['results'] as List<dynamic>?)
          ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$PaginatedMessageListToJson(
  PaginatedMessageList instance,
) => <String, dynamic>{
  'count': instance.count,
  'next': ?instance.next,
  'previous': ?instance.previous,
  'results': instance.results.map((e) => e.toJson()).toList(),
};

PatchedConversationRequest _$PatchedConversationRequestFromJson(
  Map<String, dynamic> json,
) => PatchedConversationRequest(
  title: json['title'] as String?,
  localOnly: json['local_only'] as bool?,
);

Map<String, dynamic> _$PatchedConversationRequestToJson(
  PatchedConversationRequest instance,
) => <String, dynamic>{
  'title': ?instance.title,
  'local_only': ?instance.localOnly,
};

PatchedProfileRequest _$PatchedProfileRequestFromJson(
  Map<String, dynamic> json,
) => PatchedProfileRequest(
  username: json['username'] as String?,
  email: json['email'] as String?,
  phoneNumber: json['phone_number'] as String?,
  biometricEnabled: json['biometric_enabled'] as bool?,
);

Map<String, dynamic> _$PatchedProfileRequestToJson(
  PatchedProfileRequest instance,
) => <String, dynamic>{
  'username': ?instance.username,
  'email': ?instance.email,
  'phone_number': ?instance.phoneNumber,
  'biometric_enabled': ?instance.biometricEnabled,
};

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
  userId: json['user_id'] as String?,
  username: json['username'] as String,
  email: json['email'] as String,
  phoneNumber: json['phone_number'] as String?,
  biometricEnabled: json['biometric_enabled'] as bool?,
);

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
  'user_id': ?instance.userId,
  'username': instance.username,
  'email': instance.email,
  'phone_number': ?instance.phoneNumber,
  'biometric_enabled': ?instance.biometricEnabled,
};

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      username: json['username'] as String,
      email: json['email'] as String?,
      userPassword: json['user_password'],
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'username': instance.username,
      'email': ?instance.email,
      'user_password': ?instance.userPassword,
    };

RegisterResponse _$RegisterResponseFromJson(Map<String, dynamic> json) =>
    RegisterResponse(
      message: json['message'] as String,
      userId: json['user_id'] as String,
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      email: json['email'] as String,
      onboarding: json['onboarding'] as bool,
      conversations:
          (json['conversations'] as List<dynamic>?)
              ?.map((e) => ConversationDoc.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      tempId: json['temp_id'] as String?,
      deviceId: json['device_id'] as String?,
      relatedDevices:
          (json['related_devices'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );

Map<String, dynamic> _$RegisterResponseToJson(RegisterResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'user_id': instance.userId,
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'email': instance.email,
      'onboarding': instance.onboarding,
      'conversations': instance.conversations.map((e) => e.toJson()).toList(),
      'temp_id': ?instance.tempId,
      'device_id': ?instance.deviceId,
      'related_devices': ?instance.relatedDevices,
    };

SetPasswordAfterEmailVerifyRequestRequest
_$SetPasswordAfterEmailVerifyRequestRequestFromJson(
  Map<String, dynamic> json,
) => SetPasswordAfterEmailVerifyRequestRequest(
  email: json['email'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$SetPasswordAfterEmailVerifyRequestRequestToJson(
  SetPasswordAfterEmailVerifyRequestRequest instance,
) => <String, dynamic>{'email': instance.email, 'password': instance.password};

SetPasswordAfterEmailVerifyResponse
_$SetPasswordAfterEmailVerifyResponseFromJson(Map<String, dynamic> json) =>
    SetPasswordAfterEmailVerifyResponse(message: json['message'] as String);

Map<String, dynamic> _$SetPasswordAfterEmailVerifyResponseToJson(
  SetPasswordAfterEmailVerifyResponse instance,
) => <String, dynamic>{'message': instance.message};

TokenRefresh _$TokenRefreshFromJson(Map<String, dynamic> json) => TokenRefresh(
  access: json['access'] as String?,
  refresh: json['refresh'] as String,
);

Map<String, dynamic> _$TokenRefreshToJson(TokenRefresh instance) =>
    <String, dynamic>{'access': ?instance.access, 'refresh': instance.refresh};

TokenRefreshRequest _$TokenRefreshRequestFromJson(Map<String, dynamic> json) =>
    TokenRefreshRequest(refresh: json['refresh'] as String);

Map<String, dynamic> _$TokenRefreshRequestToJson(
  TokenRefreshRequest instance,
) => <String, dynamic>{'refresh': instance.refresh};

UMKErrorResponse _$UMKErrorResponseFromJson(Map<String, dynamic> json) =>
    UMKErrorResponse(error: json['error'] as String);

Map<String, dynamic> _$UMKErrorResponseToJson(UMKErrorResponse instance) =>
    <String, dynamic>{'error': instance.error};

UMKGetResponse _$UMKGetResponseFromJson(Map<String, dynamic> json) =>
    UMKGetResponse(
      user: (json['user'] as num).toInt(),
      umkB64: json['umk_b64'] as String,
      version: (json['version'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      exists: json['exists'] as bool? ?? true,
    );

Map<String, dynamic> _$UMKGetResponseToJson(UMKGetResponse instance) =>
    <String, dynamic>{
      'user': instance.user,
      'umk_b64': instance.umkB64,
      'version': instance.version,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'exists': ?instance.exists,
    };

UMKProvisionRequestRequest _$UMKProvisionRequestRequestFromJson(
  Map<String, dynamic> json,
) => UMKProvisionRequestRequest(umkB64: json['umk_b64'] as String?);

Map<String, dynamic> _$UMKProvisionRequestRequestToJson(
  UMKProvisionRequestRequest instance,
) => <String, dynamic>{'umk_b64': ?instance.umkB64};

UMKProvisionResponse _$UMKProvisionResponseFromJson(
  Map<String, dynamic> json,
) => UMKProvisionResponse(
  user: (json['user'] as num).toInt(),
  umkB64: json['umk_b64'] as String,
  version: (json['version'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$UMKProvisionResponseToJson(
  UMKProvisionResponse instance,
) => <String, dynamic>{
  'user': instance.user,
  'umk_b64': instance.umkB64,
  'version': instance.version,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

UnifiedSyncDeleteResponse _$UnifiedSyncDeleteResponseFromJson(
  Map<String, dynamic> json,
) => UnifiedSyncDeleteResponse(
  message: json['message'] as String,
  deleted: json['deleted'] == null
      ? null
      : UnifiedSyncDeleteStats.fromJson(
          json['deleted'] as Map<String, dynamic>,
        ),
  archived: json['archived'] == null
      ? null
      : UnifiedSyncDeleteStats.fromJson(
          json['archived'] as Map<String, dynamic>,
        ),
  exportUrls: json['export_urls'] as Map<String, dynamic>?,
  profile: json['profile'] == null
      ? null
      : FullProfile.fromJson(json['profile'] as Map<String, dynamic>),
  chat: json['chat'] == null
      ? null
      : FullChat.fromJson(json['chat'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UnifiedSyncDeleteResponseToJson(
  UnifiedSyncDeleteResponse instance,
) => <String, dynamic>{
  'message': instance.message,
  'deleted': ?instance.deleted?.toJson(),
  'archived': ?instance.archived?.toJson(),
  'export_urls': ?instance.exportUrls,
  'profile': ?instance.profile?.toJson(),
  'chat': ?instance.chat?.toJson(),
};

UnifiedSyncDeleteStats _$UnifiedSyncDeleteStatsFromJson(
  Map<String, dynamic> json,
) => UnifiedSyncDeleteStats(
  attachments: (json['attachments'] as num?)?.toInt(),
  messages: (json['messages'] as num?)?.toInt(),
  conversations: (json['conversations'] as num?)?.toInt(),
  tokens: (json['tokens'] as num?)?.toInt(),
  user: (json['user'] as num?)?.toInt(),
);

Map<String, dynamic> _$UnifiedSyncDeleteStatsToJson(
  UnifiedSyncDeleteStats instance,
) => <String, dynamic>{
  'attachments': ?instance.attachments,
  'messages': ?instance.messages,
  'conversations': ?instance.conversations,
  'tokens': ?instance.tokens,
  'user': ?instance.user,
};

UnifiedSyncGetResponse _$UnifiedSyncGetResponseFromJson(
  Map<String, dynamic> json,
) => UnifiedSyncGetResponse(
  userId: json['user_id'] as String?,
  isNew: json['is_new'] as bool,
  tempId: json['temp_id'] as String?,
  profile: json['profile'] == null
      ? null
      : FullProfile.fromJson(json['profile'] as Map<String, dynamic>),
  chat: json['chat'] == null
      ? null
      : FullChat.fromJson(json['chat'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UnifiedSyncGetResponseToJson(
  UnifiedSyncGetResponse instance,
) => <String, dynamic>{
  'user_id': ?instance.userId,
  'is_new': instance.isNew,
  'temp_id': ?instance.tempId,
  'profile': ?instance.profile?.toJson(),
  'chat': ?instance.chat?.toJson(),
};

UnifiedSyncPatchResponse _$UnifiedSyncPatchResponseFromJson(
  Map<String, dynamic> json,
) => UnifiedSyncPatchResponse(
  profile: Profile.fromJson(json['profile'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UnifiedSyncPatchResponseToJson(
  UnifiedSyncPatchResponse instance,
) => <String, dynamic>{'profile': instance.profile.toJson()};

UnifiedSyncPostRequestRequest _$UnifiedSyncPostRequestRequestFromJson(
  Map<String, dynamic> json,
) => UnifiedSyncPostRequestRequest(
  profile: json['profile'] == null
      ? null
      : FullProfileRequest.fromJson(json['profile'] as Map<String, dynamic>),
  conversations:
      (json['conversations'] as List<dynamic>?)
          ?.map((e) => ConversationRequest.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  messages:
      (json['messages'] as List<dynamic>?)
          ?.map((e) => MessageRequest.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  messageRequests:
      (json['message_requests'] as List<dynamic>?)
          ?.map(
            (e) => MessageRequestRequest.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      [],
  messageResponses:
      (json['message_responses'] as List<dynamic>?)
          ?.map(
            (e) => MessageResponseRequest.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      [],
  messageOutputs:
      (json['message_outputs'] as List<dynamic>?)
          ?.map((e) => MessageOutputRequest.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  attachments:
      (json['attachments'] as List<dynamic>?)
          ?.map((e) => AttachmentRequest.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$UnifiedSyncPostRequestRequestToJson(
  UnifiedSyncPostRequestRequest instance,
) => <String, dynamic>{
  'profile': ?instance.profile?.toJson(),
  'conversations': ?instance.conversations?.map((e) => e.toJson()).toList(),
  'messages': ?instance.messages?.map((e) => e.toJson()).toList(),
  'message_requests': ?instance.messageRequests
      ?.map((e) => e.toJson())
      .toList(),
  'message_responses': ?instance.messageResponses
      ?.map((e) => e.toJson())
      .toList(),
  'message_outputs': ?instance.messageOutputs?.map((e) => e.toJson()).toList(),
  'attachments': ?instance.attachments?.map((e) => e.toJson()).toList(),
};

UnifiedSyncPostResponse _$UnifiedSyncPostResponseFromJson(
  Map<String, dynamic> json,
) => UnifiedSyncPostResponse(
  summary: UnifiedSyncUpsertSummary.fromJson(
    json['summary'] as Map<String, dynamic>,
  ),
  errors: json['errors'] as Map<String, dynamic>?,
  userId: json['user_id'] as String?,
  tempId: json['temp_id'] as String?,
  profile: json['profile'] == null
      ? null
      : FullProfile.fromJson(json['profile'] as Map<String, dynamic>),
  chat: json['chat'] == null
      ? null
      : FullChat.fromJson(json['chat'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UnifiedSyncPostResponseToJson(
  UnifiedSyncPostResponse instance,
) => <String, dynamic>{
  'summary': instance.summary.toJson(),
  'errors': ?instance.errors,
  'user_id': ?instance.userId,
  'temp_id': ?instance.tempId,
  'profile': ?instance.profile?.toJson(),
  'chat': ?instance.chat?.toJson(),
};

UnifiedSyncUpsertSummary _$UnifiedSyncUpsertSummaryFromJson(
  Map<String, dynamic> json,
) => UnifiedSyncUpsertSummary(
  profileUpdated: json['profile_updated'] as bool?,
  conversationsCreated: (json['conversations_created'] as num?)?.toInt(),
  conversationsUpdated: (json['conversations_updated'] as num?)?.toInt(),
  messagesCreated: (json['messages_created'] as num?)?.toInt(),
  messagesUpdated: (json['messages_updated'] as num?)?.toInt(),
  requestsCreated: (json['requests_created'] as num?)?.toInt(),
  requestsUpdated: (json['requests_updated'] as num?)?.toInt(),
  responsesCreated: (json['responses_created'] as num?)?.toInt(),
  responsesUpdated: (json['responses_updated'] as num?)?.toInt(),
  outputsCreated: (json['outputs_created'] as num?)?.toInt(),
  outputsUpdated: (json['outputs_updated'] as num?)?.toInt(),
  attachmentsCreated: (json['attachments_created'] as num?)?.toInt(),
  attachmentsUpdated: (json['attachments_updated'] as num?)?.toInt(),
);

Map<String, dynamic> _$UnifiedSyncUpsertSummaryToJson(
  UnifiedSyncUpsertSummary instance,
) => <String, dynamic>{
  'profile_updated': ?instance.profileUpdated,
  'conversations_created': ?instance.conversationsCreated,
  'conversations_updated': ?instance.conversationsUpdated,
  'messages_created': ?instance.messagesCreated,
  'messages_updated': ?instance.messagesUpdated,
  'requests_created': ?instance.requestsCreated,
  'requests_updated': ?instance.requestsUpdated,
  'responses_created': ?instance.responsesCreated,
  'responses_updated': ?instance.responsesUpdated,
  'outputs_created': ?instance.outputsCreated,
  'outputs_updated': ?instance.outputsUpdated,
  'attachments_created': ?instance.attachmentsCreated,
  'attachments_updated': ?instance.attachmentsUpdated,
};
