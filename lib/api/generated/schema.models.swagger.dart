// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:json_annotation/json_annotation.dart';
import 'package:collection/collection.dart';
import 'dart:convert';

import 'schema.enums.swagger.dart' as enums;

part 'schema.models.swagger.g.dart';

@JsonSerializable(explicitToJson: true)
class Attachment {
  const Attachment({
    this.id,
    this.attachmentId,
    this.userId,
    required this.conversationId,
    required this.messageId,
    required this.type,
    this.mimeType,
    this.filePath,
    this.encryptedBlob,
    this.sizeBytes,
    this.width,
    this.height,
    this.sha256,
    this.isEncrypted,
    this.encAlgo,
    this.ivBase64,
    this.keyRef,
    this.createdAt,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) =>
      _$AttachmentFromJson(json);

  static const toJsonFactory = _$AttachmentToJson;
  Map<String, dynamic> toJson() => _$AttachmentToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String? id;
  @JsonKey(name: 'attachment_id', includeIfNull: false)
  final String? attachmentId;
  @JsonKey(name: 'user_id', includeIfNull: false)
  final String? userId;
  @JsonKey(name: 'conversation_id', includeIfNull: false)
  final String conversationId;
  @JsonKey(name: 'message_id', includeIfNull: false)
  final String messageId;
  @JsonKey(name: 'type', includeIfNull: false)
  final String type;
  @JsonKey(name: 'mime_type', includeIfNull: false)
  final String? mimeType;
  @JsonKey(name: 'file_path', includeIfNull: false)
  final String? filePath;
  @JsonKey(name: 'encrypted_blob', includeIfNull: false)
  final String? encryptedBlob;
  @JsonKey(name: 'size_bytes', includeIfNull: false)
  final int? sizeBytes;
  @JsonKey(name: 'width', includeIfNull: false)
  final int? width;
  @JsonKey(name: 'height', includeIfNull: false)
  final int? height;
  @JsonKey(name: 'sha256', includeIfNull: false)
  final String? sha256;
  @JsonKey(name: 'is_encrypted', includeIfNull: false)
  final bool? isEncrypted;
  @JsonKey(name: 'enc_algo', includeIfNull: false)
  final String? encAlgo;
  @JsonKey(name: 'iv_base64', includeIfNull: false)
  final String? ivBase64;
  @JsonKey(name: 'key_ref', includeIfNull: false)
  final String? keyRef;
  @JsonKey(name: 'created_at', includeIfNull: false)
  final DateTime? createdAt;
  static const fromJsonFactory = _$AttachmentFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Attachment &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.attachmentId, attachmentId) ||
                const DeepCollectionEquality().equals(
                  other.attachmentId,
                  attachmentId,
                )) &&
            (identical(other.userId, userId) ||
                const DeepCollectionEquality().equals(other.userId, userId)) &&
            (identical(other.conversationId, conversationId) ||
                const DeepCollectionEquality().equals(
                  other.conversationId,
                  conversationId,
                )) &&
            (identical(other.messageId, messageId) ||
                const DeepCollectionEquality().equals(
                  other.messageId,
                  messageId,
                )) &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)) &&
            (identical(other.mimeType, mimeType) ||
                const DeepCollectionEquality().equals(
                  other.mimeType,
                  mimeType,
                )) &&
            (identical(other.filePath, filePath) ||
                const DeepCollectionEquality().equals(
                  other.filePath,
                  filePath,
                )) &&
            (identical(other.encryptedBlob, encryptedBlob) ||
                const DeepCollectionEquality().equals(
                  other.encryptedBlob,
                  encryptedBlob,
                )) &&
            (identical(other.sizeBytes, sizeBytes) ||
                const DeepCollectionEquality().equals(
                  other.sizeBytes,
                  sizeBytes,
                )) &&
            (identical(other.width, width) ||
                const DeepCollectionEquality().equals(other.width, width)) &&
            (identical(other.height, height) ||
                const DeepCollectionEquality().equals(other.height, height)) &&
            (identical(other.sha256, sha256) ||
                const DeepCollectionEquality().equals(other.sha256, sha256)) &&
            (identical(other.isEncrypted, isEncrypted) ||
                const DeepCollectionEquality().equals(
                  other.isEncrypted,
                  isEncrypted,
                )) &&
            (identical(other.encAlgo, encAlgo) ||
                const DeepCollectionEquality().equals(
                  other.encAlgo,
                  encAlgo,
                )) &&
            (identical(other.ivBase64, ivBase64) ||
                const DeepCollectionEquality().equals(
                  other.ivBase64,
                  ivBase64,
                )) &&
            (identical(other.keyRef, keyRef) ||
                const DeepCollectionEquality().equals(other.keyRef, keyRef)) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(attachmentId) ^
      const DeepCollectionEquality().hash(userId) ^
      const DeepCollectionEquality().hash(conversationId) ^
      const DeepCollectionEquality().hash(messageId) ^
      const DeepCollectionEquality().hash(type) ^
      const DeepCollectionEquality().hash(mimeType) ^
      const DeepCollectionEquality().hash(filePath) ^
      const DeepCollectionEquality().hash(encryptedBlob) ^
      const DeepCollectionEquality().hash(sizeBytes) ^
      const DeepCollectionEquality().hash(width) ^
      const DeepCollectionEquality().hash(height) ^
      const DeepCollectionEquality().hash(sha256) ^
      const DeepCollectionEquality().hash(isEncrypted) ^
      const DeepCollectionEquality().hash(encAlgo) ^
      const DeepCollectionEquality().hash(ivBase64) ^
      const DeepCollectionEquality().hash(keyRef) ^
      const DeepCollectionEquality().hash(createdAt) ^
      runtimeType.hashCode;
}

extension $AttachmentExtension on Attachment {
  Attachment copyWith({
    String? id,
    String? attachmentId,
    String? userId,
    String? conversationId,
    String? messageId,
    String? type,
    String? mimeType,
    String? filePath,
    String? encryptedBlob,
    int? sizeBytes,
    int? width,
    int? height,
    String? sha256,
    bool? isEncrypted,
    String? encAlgo,
    String? ivBase64,
    String? keyRef,
    DateTime? createdAt,
  }) {
    return Attachment(
      id: id ?? this.id,
      attachmentId: attachmentId ?? this.attachmentId,
      userId: userId ?? this.userId,
      conversationId: conversationId ?? this.conversationId,
      messageId: messageId ?? this.messageId,
      type: type ?? this.type,
      mimeType: mimeType ?? this.mimeType,
      filePath: filePath ?? this.filePath,
      encryptedBlob: encryptedBlob ?? this.encryptedBlob,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      width: width ?? this.width,
      height: height ?? this.height,
      sha256: sha256 ?? this.sha256,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      encAlgo: encAlgo ?? this.encAlgo,
      ivBase64: ivBase64 ?? this.ivBase64,
      keyRef: keyRef ?? this.keyRef,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Attachment copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String?>? attachmentId,
    Wrapped<String?>? userId,
    Wrapped<String>? conversationId,
    Wrapped<String>? messageId,
    Wrapped<String>? type,
    Wrapped<String?>? mimeType,
    Wrapped<String?>? filePath,
    Wrapped<String?>? encryptedBlob,
    Wrapped<int?>? sizeBytes,
    Wrapped<int?>? width,
    Wrapped<int?>? height,
    Wrapped<String?>? sha256,
    Wrapped<bool?>? isEncrypted,
    Wrapped<String?>? encAlgo,
    Wrapped<String?>? ivBase64,
    Wrapped<String?>? keyRef,
    Wrapped<DateTime?>? createdAt,
  }) {
    return Attachment(
      id: (id != null ? id.value : this.id),
      attachmentId: (attachmentId != null
          ? attachmentId.value
          : this.attachmentId),
      userId: (userId != null ? userId.value : this.userId),
      conversationId: (conversationId != null
          ? conversationId.value
          : this.conversationId),
      messageId: (messageId != null ? messageId.value : this.messageId),
      type: (type != null ? type.value : this.type),
      mimeType: (mimeType != null ? mimeType.value : this.mimeType),
      filePath: (filePath != null ? filePath.value : this.filePath),
      encryptedBlob: (encryptedBlob != null
          ? encryptedBlob.value
          : this.encryptedBlob),
      sizeBytes: (sizeBytes != null ? sizeBytes.value : this.sizeBytes),
      width: (width != null ? width.value : this.width),
      height: (height != null ? height.value : this.height),
      sha256: (sha256 != null ? sha256.value : this.sha256),
      isEncrypted: (isEncrypted != null ? isEncrypted.value : this.isEncrypted),
      encAlgo: (encAlgo != null ? encAlgo.value : this.encAlgo),
      ivBase64: (ivBase64 != null ? ivBase64.value : this.ivBase64),
      keyRef: (keyRef != null ? keyRef.value : this.keyRef),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class AttachmentDoc {
  const AttachmentDoc({this.attachmentId, this.messageId, this.url});

  factory AttachmentDoc.fromJson(Map<String, dynamic> json) =>
      _$AttachmentDocFromJson(json);

  static const toJsonFactory = _$AttachmentDocToJson;
  Map<String, dynamic> toJson() => _$AttachmentDocToJson(this);

  @JsonKey(name: 'attachment_id', includeIfNull: false)
  final String? attachmentId;
  @JsonKey(name: 'message_id', includeIfNull: false)
  final String? messageId;
  @JsonKey(name: 'url', includeIfNull: false)
  final String? url;
  static const fromJsonFactory = _$AttachmentDocFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AttachmentDoc &&
            (identical(other.attachmentId, attachmentId) ||
                const DeepCollectionEquality().equals(
                  other.attachmentId,
                  attachmentId,
                )) &&
            (identical(other.messageId, messageId) ||
                const DeepCollectionEquality().equals(
                  other.messageId,
                  messageId,
                )) &&
            (identical(other.url, url) ||
                const DeepCollectionEquality().equals(other.url, url)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(attachmentId) ^
      const DeepCollectionEquality().hash(messageId) ^
      const DeepCollectionEquality().hash(url) ^
      runtimeType.hashCode;
}

extension $AttachmentDocExtension on AttachmentDoc {
  AttachmentDoc copyWith({
    String? attachmentId,
    String? messageId,
    String? url,
  }) {
    return AttachmentDoc(
      attachmentId: attachmentId ?? this.attachmentId,
      messageId: messageId ?? this.messageId,
      url: url ?? this.url,
    );
  }

  AttachmentDoc copyWithWrapped({
    Wrapped<String?>? attachmentId,
    Wrapped<String?>? messageId,
    Wrapped<String?>? url,
  }) {
    return AttachmentDoc(
      attachmentId: (attachmentId != null
          ? attachmentId.value
          : this.attachmentId),
      messageId: (messageId != null ? messageId.value : this.messageId),
      url: (url != null ? url.value : this.url),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class AttachmentRequest {
  const AttachmentRequest({
    this.id,
    required this.conversationId,
    required this.messageId,
    required this.type,
    this.mimeType,
    this.filePath,
    this.encryptedBlob,
    this.sizeBytes,
    this.width,
    this.height,
    this.sha256,
    this.isEncrypted,
    this.encAlgo,
    this.ivBase64,
    this.keyRef,
  });

  factory AttachmentRequest.fromJson(Map<String, dynamic> json) =>
      _$AttachmentRequestFromJson(json);

  static const toJsonFactory = _$AttachmentRequestToJson;
  Map<String, dynamic> toJson() => _$AttachmentRequestToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String? id;
  @JsonKey(name: 'conversation_id', includeIfNull: false)
  final String conversationId;
  @JsonKey(name: 'message_id', includeIfNull: false)
  final String messageId;
  @JsonKey(name: 'type', includeIfNull: false)
  final String type;
  @JsonKey(name: 'mime_type', includeIfNull: false)
  final String? mimeType;
  @JsonKey(name: 'file_path', includeIfNull: false)
  final String? filePath;
  @JsonKey(name: 'encrypted_blob', includeIfNull: false)
  final String? encryptedBlob;
  @JsonKey(name: 'size_bytes', includeIfNull: false)
  final int? sizeBytes;
  @JsonKey(name: 'width', includeIfNull: false)
  final int? width;
  @JsonKey(name: 'height', includeIfNull: false)
  final int? height;
  @JsonKey(name: 'sha256', includeIfNull: false)
  final String? sha256;
  @JsonKey(name: 'is_encrypted', includeIfNull: false)
  final bool? isEncrypted;
  @JsonKey(name: 'enc_algo', includeIfNull: false)
  final String? encAlgo;
  @JsonKey(name: 'iv_base64', includeIfNull: false)
  final String? ivBase64;
  @JsonKey(name: 'key_ref', includeIfNull: false)
  final String? keyRef;
  static const fromJsonFactory = _$AttachmentRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AttachmentRequest &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.conversationId, conversationId) ||
                const DeepCollectionEquality().equals(
                  other.conversationId,
                  conversationId,
                )) &&
            (identical(other.messageId, messageId) ||
                const DeepCollectionEquality().equals(
                  other.messageId,
                  messageId,
                )) &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)) &&
            (identical(other.mimeType, mimeType) ||
                const DeepCollectionEquality().equals(
                  other.mimeType,
                  mimeType,
                )) &&
            (identical(other.filePath, filePath) ||
                const DeepCollectionEquality().equals(
                  other.filePath,
                  filePath,
                )) &&
            (identical(other.encryptedBlob, encryptedBlob) ||
                const DeepCollectionEquality().equals(
                  other.encryptedBlob,
                  encryptedBlob,
                )) &&
            (identical(other.sizeBytes, sizeBytes) ||
                const DeepCollectionEquality().equals(
                  other.sizeBytes,
                  sizeBytes,
                )) &&
            (identical(other.width, width) ||
                const DeepCollectionEquality().equals(other.width, width)) &&
            (identical(other.height, height) ||
                const DeepCollectionEquality().equals(other.height, height)) &&
            (identical(other.sha256, sha256) ||
                const DeepCollectionEquality().equals(other.sha256, sha256)) &&
            (identical(other.isEncrypted, isEncrypted) ||
                const DeepCollectionEquality().equals(
                  other.isEncrypted,
                  isEncrypted,
                )) &&
            (identical(other.encAlgo, encAlgo) ||
                const DeepCollectionEquality().equals(
                  other.encAlgo,
                  encAlgo,
                )) &&
            (identical(other.ivBase64, ivBase64) ||
                const DeepCollectionEquality().equals(
                  other.ivBase64,
                  ivBase64,
                )) &&
            (identical(other.keyRef, keyRef) ||
                const DeepCollectionEquality().equals(other.keyRef, keyRef)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(conversationId) ^
      const DeepCollectionEquality().hash(messageId) ^
      const DeepCollectionEquality().hash(type) ^
      const DeepCollectionEquality().hash(mimeType) ^
      const DeepCollectionEquality().hash(filePath) ^
      const DeepCollectionEquality().hash(encryptedBlob) ^
      const DeepCollectionEquality().hash(sizeBytes) ^
      const DeepCollectionEquality().hash(width) ^
      const DeepCollectionEquality().hash(height) ^
      const DeepCollectionEquality().hash(sha256) ^
      const DeepCollectionEquality().hash(isEncrypted) ^
      const DeepCollectionEquality().hash(encAlgo) ^
      const DeepCollectionEquality().hash(ivBase64) ^
      const DeepCollectionEquality().hash(keyRef) ^
      runtimeType.hashCode;
}

extension $AttachmentRequestExtension on AttachmentRequest {
  AttachmentRequest copyWith({
    String? id,
    String? conversationId,
    String? messageId,
    String? type,
    String? mimeType,
    String? filePath,
    String? encryptedBlob,
    int? sizeBytes,
    int? width,
    int? height,
    String? sha256,
    bool? isEncrypted,
    String? encAlgo,
    String? ivBase64,
    String? keyRef,
  }) {
    return AttachmentRequest(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      messageId: messageId ?? this.messageId,
      type: type ?? this.type,
      mimeType: mimeType ?? this.mimeType,
      filePath: filePath ?? this.filePath,
      encryptedBlob: encryptedBlob ?? this.encryptedBlob,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      width: width ?? this.width,
      height: height ?? this.height,
      sha256: sha256 ?? this.sha256,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      encAlgo: encAlgo ?? this.encAlgo,
      ivBase64: ivBase64 ?? this.ivBase64,
      keyRef: keyRef ?? this.keyRef,
    );
  }

  AttachmentRequest copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String>? conversationId,
    Wrapped<String>? messageId,
    Wrapped<String>? type,
    Wrapped<String?>? mimeType,
    Wrapped<String?>? filePath,
    Wrapped<String?>? encryptedBlob,
    Wrapped<int?>? sizeBytes,
    Wrapped<int?>? width,
    Wrapped<int?>? height,
    Wrapped<String?>? sha256,
    Wrapped<bool?>? isEncrypted,
    Wrapped<String?>? encAlgo,
    Wrapped<String?>? ivBase64,
    Wrapped<String?>? keyRef,
  }) {
    return AttachmentRequest(
      id: (id != null ? id.value : this.id),
      conversationId: (conversationId != null
          ? conversationId.value
          : this.conversationId),
      messageId: (messageId != null ? messageId.value : this.messageId),
      type: (type != null ? type.value : this.type),
      mimeType: (mimeType != null ? mimeType.value : this.mimeType),
      filePath: (filePath != null ? filePath.value : this.filePath),
      encryptedBlob: (encryptedBlob != null
          ? encryptedBlob.value
          : this.encryptedBlob),
      sizeBytes: (sizeBytes != null ? sizeBytes.value : this.sizeBytes),
      width: (width != null ? width.value : this.width),
      height: (height != null ? height.value : this.height),
      sha256: (sha256 != null ? sha256.value : this.sha256),
      isEncrypted: (isEncrypted != null ? isEncrypted.value : this.isEncrypted),
      encAlgo: (encAlgo != null ? encAlgo.value : this.encAlgo),
      ivBase64: (ivBase64 != null ? ivBase64.value : this.ivBase64),
      keyRef: (keyRef != null ? keyRef.value : this.keyRef),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class AttachmentUpload {
  const AttachmentUpload({
    this.attachmentId,
    this.messageId,
    required this.type,
    this.mimeType,
    this.encryptedBlob,
    this.sizeBytes,
    this.sha256,
    this.isEncrypted,
    this.encAlgo,
    this.ivBase64,
    this.keyRef,
    this.createdAt,
  });

  factory AttachmentUpload.fromJson(Map<String, dynamic> json) =>
      _$AttachmentUploadFromJson(json);

  static const toJsonFactory = _$AttachmentUploadToJson;
  Map<String, dynamic> toJson() => _$AttachmentUploadToJson(this);

  @JsonKey(name: 'attachment_id', includeIfNull: false)
  final String? attachmentId;
  @JsonKey(name: 'message_id', includeIfNull: false)
  final String? messageId;
  @JsonKey(name: 'type', includeIfNull: false)
  final String type;
  @JsonKey(name: 'mime_type', includeIfNull: false)
  final String? mimeType;
  @JsonKey(name: 'encrypted_blob', includeIfNull: false)
  final String? encryptedBlob;
  @JsonKey(name: 'size_bytes', includeIfNull: false)
  final int? sizeBytes;
  @JsonKey(name: 'sha256', includeIfNull: false)
  final String? sha256;
  @JsonKey(name: 'is_encrypted', includeIfNull: false)
  final bool? isEncrypted;
  @JsonKey(name: 'enc_algo', includeIfNull: false)
  final String? encAlgo;
  @JsonKey(name: 'iv_base64', includeIfNull: false)
  final String? ivBase64;
  @JsonKey(name: 'key_ref', includeIfNull: false)
  final String? keyRef;
  @JsonKey(name: 'created_at', includeIfNull: false)
  final DateTime? createdAt;
  static const fromJsonFactory = _$AttachmentUploadFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AttachmentUpload &&
            (identical(other.attachmentId, attachmentId) ||
                const DeepCollectionEquality().equals(
                  other.attachmentId,
                  attachmentId,
                )) &&
            (identical(other.messageId, messageId) ||
                const DeepCollectionEquality().equals(
                  other.messageId,
                  messageId,
                )) &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)) &&
            (identical(other.mimeType, mimeType) ||
                const DeepCollectionEquality().equals(
                  other.mimeType,
                  mimeType,
                )) &&
            (identical(other.encryptedBlob, encryptedBlob) ||
                const DeepCollectionEquality().equals(
                  other.encryptedBlob,
                  encryptedBlob,
                )) &&
            (identical(other.sizeBytes, sizeBytes) ||
                const DeepCollectionEquality().equals(
                  other.sizeBytes,
                  sizeBytes,
                )) &&
            (identical(other.sha256, sha256) ||
                const DeepCollectionEquality().equals(other.sha256, sha256)) &&
            (identical(other.isEncrypted, isEncrypted) ||
                const DeepCollectionEquality().equals(
                  other.isEncrypted,
                  isEncrypted,
                )) &&
            (identical(other.encAlgo, encAlgo) ||
                const DeepCollectionEquality().equals(
                  other.encAlgo,
                  encAlgo,
                )) &&
            (identical(other.ivBase64, ivBase64) ||
                const DeepCollectionEquality().equals(
                  other.ivBase64,
                  ivBase64,
                )) &&
            (identical(other.keyRef, keyRef) ||
                const DeepCollectionEquality().equals(other.keyRef, keyRef)) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(attachmentId) ^
      const DeepCollectionEquality().hash(messageId) ^
      const DeepCollectionEquality().hash(type) ^
      const DeepCollectionEquality().hash(mimeType) ^
      const DeepCollectionEquality().hash(encryptedBlob) ^
      const DeepCollectionEquality().hash(sizeBytes) ^
      const DeepCollectionEquality().hash(sha256) ^
      const DeepCollectionEquality().hash(isEncrypted) ^
      const DeepCollectionEquality().hash(encAlgo) ^
      const DeepCollectionEquality().hash(ivBase64) ^
      const DeepCollectionEquality().hash(keyRef) ^
      const DeepCollectionEquality().hash(createdAt) ^
      runtimeType.hashCode;
}

extension $AttachmentUploadExtension on AttachmentUpload {
  AttachmentUpload copyWith({
    String? attachmentId,
    String? messageId,
    String? type,
    String? mimeType,
    String? encryptedBlob,
    int? sizeBytes,
    String? sha256,
    bool? isEncrypted,
    String? encAlgo,
    String? ivBase64,
    String? keyRef,
    DateTime? createdAt,
  }) {
    return AttachmentUpload(
      attachmentId: attachmentId ?? this.attachmentId,
      messageId: messageId ?? this.messageId,
      type: type ?? this.type,
      mimeType: mimeType ?? this.mimeType,
      encryptedBlob: encryptedBlob ?? this.encryptedBlob,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      sha256: sha256 ?? this.sha256,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      encAlgo: encAlgo ?? this.encAlgo,
      ivBase64: ivBase64 ?? this.ivBase64,
      keyRef: keyRef ?? this.keyRef,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  AttachmentUpload copyWithWrapped({
    Wrapped<String?>? attachmentId,
    Wrapped<String?>? messageId,
    Wrapped<String>? type,
    Wrapped<String?>? mimeType,
    Wrapped<String?>? encryptedBlob,
    Wrapped<int?>? sizeBytes,
    Wrapped<String?>? sha256,
    Wrapped<bool?>? isEncrypted,
    Wrapped<String?>? encAlgo,
    Wrapped<String?>? ivBase64,
    Wrapped<String?>? keyRef,
    Wrapped<DateTime?>? createdAt,
  }) {
    return AttachmentUpload(
      attachmentId: (attachmentId != null
          ? attachmentId.value
          : this.attachmentId),
      messageId: (messageId != null ? messageId.value : this.messageId),
      type: (type != null ? type.value : this.type),
      mimeType: (mimeType != null ? mimeType.value : this.mimeType),
      encryptedBlob: (encryptedBlob != null
          ? encryptedBlob.value
          : this.encryptedBlob),
      sizeBytes: (sizeBytes != null ? sizeBytes.value : this.sizeBytes),
      sha256: (sha256 != null ? sha256.value : this.sha256),
      isEncrypted: (isEncrypted != null ? isEncrypted.value : this.isEncrypted),
      encAlgo: (encAlgo != null ? encAlgo.value : this.encAlgo),
      ivBase64: (ivBase64 != null ? ivBase64.value : this.ivBase64),
      keyRef: (keyRef != null ? keyRef.value : this.keyRef),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class AttachmentUploadRequest {
  const AttachmentUploadRequest({
    required this.type,
    this.mimeType,
    this.encryptedBlob,
    this.isEncrypted,
    this.encAlgo,
    this.ivBase64,
    this.keyRef,
  });

  factory AttachmentUploadRequest.fromJson(Map<String, dynamic> json) =>
      _$AttachmentUploadRequestFromJson(json);

  static const toJsonFactory = _$AttachmentUploadRequestToJson;
  Map<String, dynamic> toJson() => _$AttachmentUploadRequestToJson(this);

  @JsonKey(name: 'type', includeIfNull: false)
  final String type;
  @JsonKey(name: 'mime_type', includeIfNull: false)
  final String? mimeType;
  @JsonKey(name: 'encrypted_blob', includeIfNull: false)
  final String? encryptedBlob;
  @JsonKey(name: 'is_encrypted', includeIfNull: false)
  final bool? isEncrypted;
  @JsonKey(name: 'enc_algo', includeIfNull: false)
  final String? encAlgo;
  @JsonKey(name: 'iv_base64', includeIfNull: false)
  final String? ivBase64;
  @JsonKey(name: 'key_ref', includeIfNull: false)
  final String? keyRef;
  static const fromJsonFactory = _$AttachmentUploadRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AttachmentUploadRequest &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)) &&
            (identical(other.mimeType, mimeType) ||
                const DeepCollectionEquality().equals(
                  other.mimeType,
                  mimeType,
                )) &&
            (identical(other.encryptedBlob, encryptedBlob) ||
                const DeepCollectionEquality().equals(
                  other.encryptedBlob,
                  encryptedBlob,
                )) &&
            (identical(other.isEncrypted, isEncrypted) ||
                const DeepCollectionEquality().equals(
                  other.isEncrypted,
                  isEncrypted,
                )) &&
            (identical(other.encAlgo, encAlgo) ||
                const DeepCollectionEquality().equals(
                  other.encAlgo,
                  encAlgo,
                )) &&
            (identical(other.ivBase64, ivBase64) ||
                const DeepCollectionEquality().equals(
                  other.ivBase64,
                  ivBase64,
                )) &&
            (identical(other.keyRef, keyRef) ||
                const DeepCollectionEquality().equals(other.keyRef, keyRef)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(type) ^
      const DeepCollectionEquality().hash(mimeType) ^
      const DeepCollectionEquality().hash(encryptedBlob) ^
      const DeepCollectionEquality().hash(isEncrypted) ^
      const DeepCollectionEquality().hash(encAlgo) ^
      const DeepCollectionEquality().hash(ivBase64) ^
      const DeepCollectionEquality().hash(keyRef) ^
      runtimeType.hashCode;
}

extension $AttachmentUploadRequestExtension on AttachmentUploadRequest {
  AttachmentUploadRequest copyWith({
    String? type,
    String? mimeType,
    String? encryptedBlob,
    bool? isEncrypted,
    String? encAlgo,
    String? ivBase64,
    String? keyRef,
  }) {
    return AttachmentUploadRequest(
      type: type ?? this.type,
      mimeType: mimeType ?? this.mimeType,
      encryptedBlob: encryptedBlob ?? this.encryptedBlob,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      encAlgo: encAlgo ?? this.encAlgo,
      ivBase64: ivBase64 ?? this.ivBase64,
      keyRef: keyRef ?? this.keyRef,
    );
  }

  AttachmentUploadRequest copyWithWrapped({
    Wrapped<String>? type,
    Wrapped<String?>? mimeType,
    Wrapped<String?>? encryptedBlob,
    Wrapped<bool?>? isEncrypted,
    Wrapped<String?>? encAlgo,
    Wrapped<String?>? ivBase64,
    Wrapped<String?>? keyRef,
  }) {
    return AttachmentUploadRequest(
      type: (type != null ? type.value : this.type),
      mimeType: (mimeType != null ? mimeType.value : this.mimeType),
      encryptedBlob: (encryptedBlob != null
          ? encryptedBlob.value
          : this.encryptedBlob),
      isEncrypted: (isEncrypted != null ? isEncrypted.value : this.isEncrypted),
      encAlgo: (encAlgo != null ? encAlgo.value : this.encAlgo),
      ivBase64: (ivBase64 != null ? ivBase64.value : this.ivBase64),
      keyRef: (keyRef != null ? keyRef.value : this.keyRef),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class Conversation {
  const Conversation({
    this.conversationId,
    this.userId,
    this.title,
    this.createdAt,
    this.updatedAt,
    this.localOnly,
    this.messages,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);

  static const toJsonFactory = _$ConversationToJson;
  Map<String, dynamic> toJson() => _$ConversationToJson(this);

  @JsonKey(name: 'conversation_id', includeIfNull: false)
  final String? conversationId;
  @JsonKey(name: 'user_id', includeIfNull: false)
  final String? userId;
  @JsonKey(name: 'title', includeIfNull: false)
  final String? title;
  @JsonKey(name: 'created_at', includeIfNull: false)
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at', includeIfNull: false)
  final DateTime? updatedAt;
  @JsonKey(name: 'local_only', includeIfNull: false)
  final bool? localOnly;
  @JsonKey(name: 'messages', includeIfNull: false, defaultValue: <Message>[])
  final List<Message>? messages;
  static const fromJsonFactory = _$ConversationFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Conversation &&
            (identical(other.conversationId, conversationId) ||
                const DeepCollectionEquality().equals(
                  other.conversationId,
                  conversationId,
                )) &&
            (identical(other.userId, userId) ||
                const DeepCollectionEquality().equals(other.userId, userId)) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.updatedAt, updatedAt) ||
                const DeepCollectionEquality().equals(
                  other.updatedAt,
                  updatedAt,
                )) &&
            (identical(other.localOnly, localOnly) ||
                const DeepCollectionEquality().equals(
                  other.localOnly,
                  localOnly,
                )) &&
            (identical(other.messages, messages) ||
                const DeepCollectionEquality().equals(
                  other.messages,
                  messages,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(conversationId) ^
      const DeepCollectionEquality().hash(userId) ^
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(updatedAt) ^
      const DeepCollectionEquality().hash(localOnly) ^
      const DeepCollectionEquality().hash(messages) ^
      runtimeType.hashCode;
}

extension $ConversationExtension on Conversation {
  Conversation copyWith({
    String? conversationId,
    String? userId,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? localOnly,
    List<Message>? messages,
  }) {
    return Conversation(
      conversationId: conversationId ?? this.conversationId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      localOnly: localOnly ?? this.localOnly,
      messages: messages ?? this.messages,
    );
  }

  Conversation copyWithWrapped({
    Wrapped<String?>? conversationId,
    Wrapped<String?>? userId,
    Wrapped<String?>? title,
    Wrapped<DateTime?>? createdAt,
    Wrapped<DateTime?>? updatedAt,
    Wrapped<bool?>? localOnly,
    Wrapped<List<Message>?>? messages,
  }) {
    return Conversation(
      conversationId: (conversationId != null
          ? conversationId.value
          : this.conversationId),
      userId: (userId != null ? userId.value : this.userId),
      title: (title != null ? title.value : this.title),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      updatedAt: (updatedAt != null ? updatedAt.value : this.updatedAt),
      localOnly: (localOnly != null ? localOnly.value : this.localOnly),
      messages: (messages != null ? messages.value : this.messages),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ConversationDoc {
  const ConversationDoc({
    required this.conversationId,
    this.title,
    this.updatedAt,
    required this.messages,
  });

  factory ConversationDoc.fromJson(Map<String, dynamic> json) =>
      _$ConversationDocFromJson(json);

  static const toJsonFactory = _$ConversationDocToJson;
  Map<String, dynamic> toJson() => _$ConversationDocToJson(this);

  @JsonKey(name: 'conversation_id', includeIfNull: false)
  final String conversationId;
  @JsonKey(name: 'title', includeIfNull: false)
  final String? title;
  @JsonKey(name: 'updated_at', includeIfNull: false)
  final DateTime? updatedAt;
  @JsonKey(name: 'messages', includeIfNull: false, defaultValue: <MessageDoc>[])
  final List<MessageDoc> messages;
  static const fromJsonFactory = _$ConversationDocFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ConversationDoc &&
            (identical(other.conversationId, conversationId) ||
                const DeepCollectionEquality().equals(
                  other.conversationId,
                  conversationId,
                )) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.updatedAt, updatedAt) ||
                const DeepCollectionEquality().equals(
                  other.updatedAt,
                  updatedAt,
                )) &&
            (identical(other.messages, messages) ||
                const DeepCollectionEquality().equals(
                  other.messages,
                  messages,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(conversationId) ^
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(updatedAt) ^
      const DeepCollectionEquality().hash(messages) ^
      runtimeType.hashCode;
}

extension $ConversationDocExtension on ConversationDoc {
  ConversationDoc copyWith({
    String? conversationId,
    String? title,
    DateTime? updatedAt,
    List<MessageDoc>? messages,
  }) {
    return ConversationDoc(
      conversationId: conversationId ?? this.conversationId,
      title: title ?? this.title,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
    );
  }

  ConversationDoc copyWithWrapped({
    Wrapped<String>? conversationId,
    Wrapped<String?>? title,
    Wrapped<DateTime?>? updatedAt,
    Wrapped<List<MessageDoc>>? messages,
  }) {
    return ConversationDoc(
      conversationId: (conversationId != null
          ? conversationId.value
          : this.conversationId),
      title: (title != null ? title.value : this.title),
      updatedAt: (updatedAt != null ? updatedAt.value : this.updatedAt),
      messages: (messages != null ? messages.value : this.messages),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ConversationRequest {
  const ConversationRequest({this.title, this.localOnly});

  factory ConversationRequest.fromJson(Map<String, dynamic> json) =>
      _$ConversationRequestFromJson(json);

  static const toJsonFactory = _$ConversationRequestToJson;
  Map<String, dynamic> toJson() => _$ConversationRequestToJson(this);

  @JsonKey(name: 'title', includeIfNull: false)
  final String? title;
  @JsonKey(name: 'local_only', includeIfNull: false)
  final bool? localOnly;
  static const fromJsonFactory = _$ConversationRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ConversationRequest &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.localOnly, localOnly) ||
                const DeepCollectionEquality().equals(
                  other.localOnly,
                  localOnly,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(localOnly) ^
      runtimeType.hashCode;
}

extension $ConversationRequestExtension on ConversationRequest {
  ConversationRequest copyWith({String? title, bool? localOnly}) {
    return ConversationRequest(
      title: title ?? this.title,
      localOnly: localOnly ?? this.localOnly,
    );
  }

  ConversationRequest copyWithWrapped({
    Wrapped<String?>? title,
    Wrapped<bool?>? localOnly,
  }) {
    return ConversationRequest(
      title: (title != null ? title.value : this.title),
      localOnly: (localOnly != null ? localOnly.value : this.localOnly),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class DeprecatedEndpointResponse {
  const DeprecatedEndpointResponse({required this.detail});

  factory DeprecatedEndpointResponse.fromJson(Map<String, dynamic> json) =>
      _$DeprecatedEndpointResponseFromJson(json);

  static const toJsonFactory = _$DeprecatedEndpointResponseToJson;
  Map<String, dynamic> toJson() => _$DeprecatedEndpointResponseToJson(this);

  @JsonKey(name: 'detail', includeIfNull: false)
  final String detail;
  static const fromJsonFactory = _$DeprecatedEndpointResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is DeprecatedEndpointResponse &&
            (identical(other.detail, detail) ||
                const DeepCollectionEquality().equals(other.detail, detail)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(detail) ^ runtimeType.hashCode;
}

extension $DeprecatedEndpointResponseExtension on DeprecatedEndpointResponse {
  DeprecatedEndpointResponse copyWith({String? detail}) {
    return DeprecatedEndpointResponse(detail: detail ?? this.detail);
  }

  DeprecatedEndpointResponse copyWithWrapped({Wrapped<String>? detail}) {
    return DeprecatedEndpointResponse(
      detail: (detail != null ? detail.value : this.detail),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class EmailPinVerifyRequestRequest {
  const EmailPinVerifyRequestRequest({required this.email, required this.pin});

  factory EmailPinVerifyRequestRequest.fromJson(Map<String, dynamic> json) =>
      _$EmailPinVerifyRequestRequestFromJson(json);

  static const toJsonFactory = _$EmailPinVerifyRequestRequestToJson;
  Map<String, dynamic> toJson() => _$EmailPinVerifyRequestRequestToJson(this);

  @JsonKey(name: 'email', includeIfNull: false)
  final String email;
  @JsonKey(name: 'pin', includeIfNull: false)
  final String pin;
  static const fromJsonFactory = _$EmailPinVerifyRequestRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is EmailPinVerifyRequestRequest &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.pin, pin) ||
                const DeepCollectionEquality().equals(other.pin, pin)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(pin) ^
      runtimeType.hashCode;
}

extension $EmailPinVerifyRequestRequestExtension
    on EmailPinVerifyRequestRequest {
  EmailPinVerifyRequestRequest copyWith({String? email, String? pin}) {
    return EmailPinVerifyRequestRequest(
      email: email ?? this.email,
      pin: pin ?? this.pin,
    );
  }

  EmailPinVerifyRequestRequest copyWithWrapped({
    Wrapped<String>? email,
    Wrapped<String>? pin,
  }) {
    return EmailPinVerifyRequestRequest(
      email: (email != null ? email.value : this.email),
      pin: (pin != null ? pin.value : this.pin),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class EmailPinVerifyResponse {
  const EmailPinVerifyResponse({required this.message});

  factory EmailPinVerifyResponse.fromJson(Map<String, dynamic> json) =>
      _$EmailPinVerifyResponseFromJson(json);

  static const toJsonFactory = _$EmailPinVerifyResponseToJson;
  Map<String, dynamic> toJson() => _$EmailPinVerifyResponseToJson(this);

  @JsonKey(name: 'message', includeIfNull: false)
  final String message;
  static const fromJsonFactory = _$EmailPinVerifyResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is EmailPinVerifyResponse &&
            (identical(other.message, message) ||
                const DeepCollectionEquality().equals(other.message, message)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(message) ^ runtimeType.hashCode;
}

extension $EmailPinVerifyResponseExtension on EmailPinVerifyResponse {
  EmailPinVerifyResponse copyWith({String? message}) {
    return EmailPinVerifyResponse(message: message ?? this.message);
  }

  EmailPinVerifyResponse copyWithWrapped({Wrapped<String>? message}) {
    return EmailPinVerifyResponse(
      message: (message != null ? message.value : this.message),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class FullChat {
  const FullChat({
    this.conversations,
    this.messages,
    this.messageRequest,
    this.messageResponse,
    this.messageOutput,
    this.attachments,
  });

  factory FullChat.fromJson(Map<String, dynamic> json) =>
      _$FullChatFromJson(json);

  static const toJsonFactory = _$FullChatToJson;
  Map<String, dynamic> toJson() => _$FullChatToJson(this);

  @JsonKey(
    name: 'conversations',
    includeIfNull: false,
    defaultValue: <Conversation>[],
  )
  final List<Conversation>? conversations;
  @JsonKey(name: 'messages', includeIfNull: false, defaultValue: <Message>[])
  final List<Message>? messages;
  @JsonKey(
    name: 'message_request',
    includeIfNull: false,
    defaultValue: <MessageRequest>[],
  )
  final List<MessageRequest>? messageRequest;
  @JsonKey(
    name: 'message_response',
    includeIfNull: false,
    defaultValue: <MessageResponse>[],
  )
  final List<MessageResponse>? messageResponse;
  @JsonKey(
    name: 'message_output',
    includeIfNull: false,
    defaultValue: <MessageOutput>[],
  )
  final List<MessageOutput>? messageOutput;
  @JsonKey(
    name: 'attachments',
    includeIfNull: false,
    defaultValue: <Attachment>[],
  )
  final List<Attachment>? attachments;
  static const fromJsonFactory = _$FullChatFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is FullChat &&
            (identical(other.conversations, conversations) ||
                const DeepCollectionEquality().equals(
                  other.conversations,
                  conversations,
                )) &&
            (identical(other.messages, messages) ||
                const DeepCollectionEquality().equals(
                  other.messages,
                  messages,
                )) &&
            (identical(other.messageRequest, messageRequest) ||
                const DeepCollectionEquality().equals(
                  other.messageRequest,
                  messageRequest,
                )) &&
            (identical(other.messageResponse, messageResponse) ||
                const DeepCollectionEquality().equals(
                  other.messageResponse,
                  messageResponse,
                )) &&
            (identical(other.messageOutput, messageOutput) ||
                const DeepCollectionEquality().equals(
                  other.messageOutput,
                  messageOutput,
                )) &&
            (identical(other.attachments, attachments) ||
                const DeepCollectionEquality().equals(
                  other.attachments,
                  attachments,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(conversations) ^
      const DeepCollectionEquality().hash(messages) ^
      const DeepCollectionEquality().hash(messageRequest) ^
      const DeepCollectionEquality().hash(messageResponse) ^
      const DeepCollectionEquality().hash(messageOutput) ^
      const DeepCollectionEquality().hash(attachments) ^
      runtimeType.hashCode;
}

extension $FullChatExtension on FullChat {
  FullChat copyWith({
    List<Conversation>? conversations,
    List<Message>? messages,
    List<MessageRequest>? messageRequest,
    List<MessageResponse>? messageResponse,
    List<MessageOutput>? messageOutput,
    List<Attachment>? attachments,
  }) {
    return FullChat(
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      messageRequest: messageRequest ?? this.messageRequest,
      messageResponse: messageResponse ?? this.messageResponse,
      messageOutput: messageOutput ?? this.messageOutput,
      attachments: attachments ?? this.attachments,
    );
  }

  FullChat copyWithWrapped({
    Wrapped<List<Conversation>?>? conversations,
    Wrapped<List<Message>?>? messages,
    Wrapped<List<MessageRequest>?>? messageRequest,
    Wrapped<List<MessageResponse>?>? messageResponse,
    Wrapped<List<MessageOutput>?>? messageOutput,
    Wrapped<List<Attachment>?>? attachments,
  }) {
    return FullChat(
      conversations: (conversations != null
          ? conversations.value
          : this.conversations),
      messages: (messages != null ? messages.value : this.messages),
      messageRequest: (messageRequest != null
          ? messageRequest.value
          : this.messageRequest),
      messageResponse: (messageResponse != null
          ? messageResponse.value
          : this.messageResponse),
      messageOutput: (messageOutput != null
          ? messageOutput.value
          : this.messageOutput),
      attachments: (attachments != null ? attachments.value : this.attachments),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class FullProfile {
  const FullProfile({
    this.userId,
    required this.username,
    this.firstName,
    this.lastName,
    required this.email,
    this.phoneNumber,
    this.lastModified,
    this.devicesId,
    this.tempId,
    this.relatedDevices,
    this.emailPinCreated,
    this.emailVerified,
    this.isArchived,
    this.isGoogleUser,
    this.isOpenrouterUser,
    this.isMicrosoftUser,
    this.isGithubUser,
    this.isActive,
    this.isStaff,
  });

  factory FullProfile.fromJson(Map<String, dynamic> json) =>
      _$FullProfileFromJson(json);

  static const toJsonFactory = _$FullProfileToJson;
  Map<String, dynamic> toJson() => _$FullProfileToJson(this);

  @JsonKey(name: 'user_id', includeIfNull: false)
  final String? userId;
  @JsonKey(name: 'username', includeIfNull: false)
  final String username;
  @JsonKey(name: 'first_name', includeIfNull: false)
  final String? firstName;
  @JsonKey(name: 'last_name', includeIfNull: false)
  final String? lastName;
  @JsonKey(name: 'email', includeIfNull: false)
  final String email;
  @JsonKey(name: 'phone_number', includeIfNull: false)
  final String? phoneNumber;
  @JsonKey(name: 'last_modified', includeIfNull: false)
  final DateTime? lastModified;
  @JsonKey(name: 'devices_id', includeIfNull: false)
  final dynamic devicesId;
  @JsonKey(name: 'temp_id', includeIfNull: false)
  final String? tempId;
  @JsonKey(name: 'related_devices', includeIfNull: false)
  final dynamic relatedDevices;
  @JsonKey(name: 'email_pin_created', includeIfNull: false)
  final DateTime? emailPinCreated;
  @JsonKey(name: 'email_verified', includeIfNull: false)
  final bool? emailVerified;
  @JsonKey(name: 'is_archived', includeIfNull: false)
  final bool? isArchived;
  @JsonKey(name: 'is_google_user', includeIfNull: false)
  final bool? isGoogleUser;
  @JsonKey(name: 'is_openrouter_user', includeIfNull: false)
  final bool? isOpenrouterUser;
  @JsonKey(name: 'is_microsoft_user', includeIfNull: false)
  final bool? isMicrosoftUser;
  @JsonKey(name: 'is_github_user', includeIfNull: false)
  final bool? isGithubUser;
  @JsonKey(name: 'is_active', includeIfNull: false)
  final bool? isActive;
  @JsonKey(name: 'is_staff', includeIfNull: false)
  final bool? isStaff;
  static const fromJsonFactory = _$FullProfileFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is FullProfile &&
            (identical(other.userId, userId) ||
                const DeepCollectionEquality().equals(other.userId, userId)) &&
            (identical(other.username, username) ||
                const DeepCollectionEquality().equals(
                  other.username,
                  username,
                )) &&
            (identical(other.firstName, firstName) ||
                const DeepCollectionEquality().equals(
                  other.firstName,
                  firstName,
                )) &&
            (identical(other.lastName, lastName) ||
                const DeepCollectionEquality().equals(
                  other.lastName,
                  lastName,
                )) &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.phoneNumber, phoneNumber) ||
                const DeepCollectionEquality().equals(
                  other.phoneNumber,
                  phoneNumber,
                )) &&
            (identical(other.lastModified, lastModified) ||
                const DeepCollectionEquality().equals(
                  other.lastModified,
                  lastModified,
                )) &&
            (identical(other.devicesId, devicesId) ||
                const DeepCollectionEquality().equals(
                  other.devicesId,
                  devicesId,
                )) &&
            (identical(other.tempId, tempId) ||
                const DeepCollectionEquality().equals(other.tempId, tempId)) &&
            (identical(other.relatedDevices, relatedDevices) ||
                const DeepCollectionEquality().equals(
                  other.relatedDevices,
                  relatedDevices,
                )) &&
            (identical(other.emailPinCreated, emailPinCreated) ||
                const DeepCollectionEquality().equals(
                  other.emailPinCreated,
                  emailPinCreated,
                )) &&
            (identical(other.emailVerified, emailVerified) ||
                const DeepCollectionEquality().equals(
                  other.emailVerified,
                  emailVerified,
                )) &&
            (identical(other.isArchived, isArchived) ||
                const DeepCollectionEquality().equals(
                  other.isArchived,
                  isArchived,
                )) &&
            (identical(other.isGoogleUser, isGoogleUser) ||
                const DeepCollectionEquality().equals(
                  other.isGoogleUser,
                  isGoogleUser,
                )) &&
            (identical(other.isOpenrouterUser, isOpenrouterUser) ||
                const DeepCollectionEquality().equals(
                  other.isOpenrouterUser,
                  isOpenrouterUser,
                )) &&
            (identical(other.isMicrosoftUser, isMicrosoftUser) ||
                const DeepCollectionEquality().equals(
                  other.isMicrosoftUser,
                  isMicrosoftUser,
                )) &&
            (identical(other.isGithubUser, isGithubUser) ||
                const DeepCollectionEquality().equals(
                  other.isGithubUser,
                  isGithubUser,
                )) &&
            (identical(other.isActive, isActive) ||
                const DeepCollectionEquality().equals(
                  other.isActive,
                  isActive,
                )) &&
            (identical(other.isStaff, isStaff) ||
                const DeepCollectionEquality().equals(other.isStaff, isStaff)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(userId) ^
      const DeepCollectionEquality().hash(username) ^
      const DeepCollectionEquality().hash(firstName) ^
      const DeepCollectionEquality().hash(lastName) ^
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(phoneNumber) ^
      const DeepCollectionEquality().hash(lastModified) ^
      const DeepCollectionEquality().hash(devicesId) ^
      const DeepCollectionEquality().hash(tempId) ^
      const DeepCollectionEquality().hash(relatedDevices) ^
      const DeepCollectionEquality().hash(emailPinCreated) ^
      const DeepCollectionEquality().hash(emailVerified) ^
      const DeepCollectionEquality().hash(isArchived) ^
      const DeepCollectionEquality().hash(isGoogleUser) ^
      const DeepCollectionEquality().hash(isOpenrouterUser) ^
      const DeepCollectionEquality().hash(isMicrosoftUser) ^
      const DeepCollectionEquality().hash(isGithubUser) ^
      const DeepCollectionEquality().hash(isActive) ^
      const DeepCollectionEquality().hash(isStaff) ^
      runtimeType.hashCode;
}

extension $FullProfileExtension on FullProfile {
  FullProfile copyWith({
    String? userId,
    String? username,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    DateTime? lastModified,
    dynamic devicesId,
    String? tempId,
    dynamic relatedDevices,
    DateTime? emailPinCreated,
    bool? emailVerified,
    bool? isArchived,
    bool? isGoogleUser,
    bool? isOpenrouterUser,
    bool? isMicrosoftUser,
    bool? isGithubUser,
    bool? isActive,
    bool? isStaff,
  }) {
    return FullProfile(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      lastModified: lastModified ?? this.lastModified,
      devicesId: devicesId ?? this.devicesId,
      tempId: tempId ?? this.tempId,
      relatedDevices: relatedDevices ?? this.relatedDevices,
      emailPinCreated: emailPinCreated ?? this.emailPinCreated,
      emailVerified: emailVerified ?? this.emailVerified,
      isArchived: isArchived ?? this.isArchived,
      isGoogleUser: isGoogleUser ?? this.isGoogleUser,
      isOpenrouterUser: isOpenrouterUser ?? this.isOpenrouterUser,
      isMicrosoftUser: isMicrosoftUser ?? this.isMicrosoftUser,
      isGithubUser: isGithubUser ?? this.isGithubUser,
      isActive: isActive ?? this.isActive,
      isStaff: isStaff ?? this.isStaff,
    );
  }

  FullProfile copyWithWrapped({
    Wrapped<String?>? userId,
    Wrapped<String>? username,
    Wrapped<String?>? firstName,
    Wrapped<String?>? lastName,
    Wrapped<String>? email,
    Wrapped<String?>? phoneNumber,
    Wrapped<DateTime?>? lastModified,
    Wrapped<dynamic>? devicesId,
    Wrapped<String?>? tempId,
    Wrapped<dynamic>? relatedDevices,
    Wrapped<DateTime?>? emailPinCreated,
    Wrapped<bool?>? emailVerified,
    Wrapped<bool?>? isArchived,
    Wrapped<bool?>? isGoogleUser,
    Wrapped<bool?>? isOpenrouterUser,
    Wrapped<bool?>? isMicrosoftUser,
    Wrapped<bool?>? isGithubUser,
    Wrapped<bool?>? isActive,
    Wrapped<bool?>? isStaff,
  }) {
    return FullProfile(
      userId: (userId != null ? userId.value : this.userId),
      username: (username != null ? username.value : this.username),
      firstName: (firstName != null ? firstName.value : this.firstName),
      lastName: (lastName != null ? lastName.value : this.lastName),
      email: (email != null ? email.value : this.email),
      phoneNumber: (phoneNumber != null ? phoneNumber.value : this.phoneNumber),
      lastModified: (lastModified != null
          ? lastModified.value
          : this.lastModified),
      devicesId: (devicesId != null ? devicesId.value : this.devicesId),
      tempId: (tempId != null ? tempId.value : this.tempId),
      relatedDevices: (relatedDevices != null
          ? relatedDevices.value
          : this.relatedDevices),
      emailPinCreated: (emailPinCreated != null
          ? emailPinCreated.value
          : this.emailPinCreated),
      emailVerified: (emailVerified != null
          ? emailVerified.value
          : this.emailVerified),
      isArchived: (isArchived != null ? isArchived.value : this.isArchived),
      isGoogleUser: (isGoogleUser != null
          ? isGoogleUser.value
          : this.isGoogleUser),
      isOpenrouterUser: (isOpenrouterUser != null
          ? isOpenrouterUser.value
          : this.isOpenrouterUser),
      isMicrosoftUser: (isMicrosoftUser != null
          ? isMicrosoftUser.value
          : this.isMicrosoftUser),
      isGithubUser: (isGithubUser != null
          ? isGithubUser.value
          : this.isGithubUser),
      isActive: (isActive != null ? isActive.value : this.isActive),
      isStaff: (isStaff != null ? isStaff.value : this.isStaff),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class FullProfileRequest {
  const FullProfileRequest({
    required this.username,
    this.firstName,
    this.lastName,
    required this.email,
    this.userPassword,
    this.phoneNumber,
    this.devicesId,
    this.tempId,
    this.relatedDevices,
    this.emailPinCreated,
    this.emailVerified,
    this.isArchived,
    this.isGoogleUser,
    this.isOpenrouterUser,
    this.isMicrosoftUser,
    this.isGithubUser,
    this.isActive,
    this.isStaff,
  });

  factory FullProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$FullProfileRequestFromJson(json);

  static const toJsonFactory = _$FullProfileRequestToJson;
  Map<String, dynamic> toJson() => _$FullProfileRequestToJson(this);

  @JsonKey(name: 'username', includeIfNull: false)
  final String username;
  @JsonKey(name: 'first_name', includeIfNull: false)
  final String? firstName;
  @JsonKey(name: 'last_name', includeIfNull: false)
  final String? lastName;
  @JsonKey(name: 'email', includeIfNull: false)
  final String email;
  @JsonKey(name: 'user_password', includeIfNull: false)
  final String? userPassword;
  @JsonKey(name: 'phone_number', includeIfNull: false)
  final String? phoneNumber;
  @JsonKey(name: 'devices_id', includeIfNull: false)
  final dynamic devicesId;
  @JsonKey(name: 'temp_id', includeIfNull: false)
  final String? tempId;
  @JsonKey(name: 'related_devices', includeIfNull: false)
  final dynamic relatedDevices;
  @JsonKey(name: 'email_pin_created', includeIfNull: false)
  final DateTime? emailPinCreated;
  @JsonKey(name: 'email_verified', includeIfNull: false)
  final bool? emailVerified;
  @JsonKey(name: 'is_archived', includeIfNull: false)
  final bool? isArchived;
  @JsonKey(name: 'is_google_user', includeIfNull: false)
  final bool? isGoogleUser;
  @JsonKey(name: 'is_openrouter_user', includeIfNull: false)
  final bool? isOpenrouterUser;
  @JsonKey(name: 'is_microsoft_user', includeIfNull: false)
  final bool? isMicrosoftUser;
  @JsonKey(name: 'is_github_user', includeIfNull: false)
  final bool? isGithubUser;
  @JsonKey(name: 'is_active', includeIfNull: false)
  final bool? isActive;
  @JsonKey(name: 'is_staff', includeIfNull: false)
  final bool? isStaff;
  static const fromJsonFactory = _$FullProfileRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is FullProfileRequest &&
            (identical(other.username, username) ||
                const DeepCollectionEquality().equals(
                  other.username,
                  username,
                )) &&
            (identical(other.firstName, firstName) ||
                const DeepCollectionEquality().equals(
                  other.firstName,
                  firstName,
                )) &&
            (identical(other.lastName, lastName) ||
                const DeepCollectionEquality().equals(
                  other.lastName,
                  lastName,
                )) &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.userPassword, userPassword) ||
                const DeepCollectionEquality().equals(
                  other.userPassword,
                  userPassword,
                )) &&
            (identical(other.phoneNumber, phoneNumber) ||
                const DeepCollectionEquality().equals(
                  other.phoneNumber,
                  phoneNumber,
                )) &&
            (identical(other.devicesId, devicesId) ||
                const DeepCollectionEquality().equals(
                  other.devicesId,
                  devicesId,
                )) &&
            (identical(other.tempId, tempId) ||
                const DeepCollectionEquality().equals(other.tempId, tempId)) &&
            (identical(other.relatedDevices, relatedDevices) ||
                const DeepCollectionEquality().equals(
                  other.relatedDevices,
                  relatedDevices,
                )) &&
            (identical(other.emailPinCreated, emailPinCreated) ||
                const DeepCollectionEquality().equals(
                  other.emailPinCreated,
                  emailPinCreated,
                )) &&
            (identical(other.emailVerified, emailVerified) ||
                const DeepCollectionEquality().equals(
                  other.emailVerified,
                  emailVerified,
                )) &&
            (identical(other.isArchived, isArchived) ||
                const DeepCollectionEquality().equals(
                  other.isArchived,
                  isArchived,
                )) &&
            (identical(other.isGoogleUser, isGoogleUser) ||
                const DeepCollectionEquality().equals(
                  other.isGoogleUser,
                  isGoogleUser,
                )) &&
            (identical(other.isOpenrouterUser, isOpenrouterUser) ||
                const DeepCollectionEquality().equals(
                  other.isOpenrouterUser,
                  isOpenrouterUser,
                )) &&
            (identical(other.isMicrosoftUser, isMicrosoftUser) ||
                const DeepCollectionEquality().equals(
                  other.isMicrosoftUser,
                  isMicrosoftUser,
                )) &&
            (identical(other.isGithubUser, isGithubUser) ||
                const DeepCollectionEquality().equals(
                  other.isGithubUser,
                  isGithubUser,
                )) &&
            (identical(other.isActive, isActive) ||
                const DeepCollectionEquality().equals(
                  other.isActive,
                  isActive,
                )) &&
            (identical(other.isStaff, isStaff) ||
                const DeepCollectionEquality().equals(other.isStaff, isStaff)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(username) ^
      const DeepCollectionEquality().hash(firstName) ^
      const DeepCollectionEquality().hash(lastName) ^
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(userPassword) ^
      const DeepCollectionEquality().hash(phoneNumber) ^
      const DeepCollectionEquality().hash(devicesId) ^
      const DeepCollectionEquality().hash(tempId) ^
      const DeepCollectionEquality().hash(relatedDevices) ^
      const DeepCollectionEquality().hash(emailPinCreated) ^
      const DeepCollectionEquality().hash(emailVerified) ^
      const DeepCollectionEquality().hash(isArchived) ^
      const DeepCollectionEquality().hash(isGoogleUser) ^
      const DeepCollectionEquality().hash(isOpenrouterUser) ^
      const DeepCollectionEquality().hash(isMicrosoftUser) ^
      const DeepCollectionEquality().hash(isGithubUser) ^
      const DeepCollectionEquality().hash(isActive) ^
      const DeepCollectionEquality().hash(isStaff) ^
      runtimeType.hashCode;
}

extension $FullProfileRequestExtension on FullProfileRequest {
  FullProfileRequest copyWith({
    String? username,
    String? firstName,
    String? lastName,
    String? email,
    String? userPassword,
    String? phoneNumber,
    dynamic devicesId,
    String? tempId,
    dynamic relatedDevices,
    DateTime? emailPinCreated,
    bool? emailVerified,
    bool? isArchived,
    bool? isGoogleUser,
    bool? isOpenrouterUser,
    bool? isMicrosoftUser,
    bool? isGithubUser,
    bool? isActive,
    bool? isStaff,
  }) {
    return FullProfileRequest(
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      userPassword: userPassword ?? this.userPassword,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      devicesId: devicesId ?? this.devicesId,
      tempId: tempId ?? this.tempId,
      relatedDevices: relatedDevices ?? this.relatedDevices,
      emailPinCreated: emailPinCreated ?? this.emailPinCreated,
      emailVerified: emailVerified ?? this.emailVerified,
      isArchived: isArchived ?? this.isArchived,
      isGoogleUser: isGoogleUser ?? this.isGoogleUser,
      isOpenrouterUser: isOpenrouterUser ?? this.isOpenrouterUser,
      isMicrosoftUser: isMicrosoftUser ?? this.isMicrosoftUser,
      isGithubUser: isGithubUser ?? this.isGithubUser,
      isActive: isActive ?? this.isActive,
      isStaff: isStaff ?? this.isStaff,
    );
  }

  FullProfileRequest copyWithWrapped({
    Wrapped<String>? username,
    Wrapped<String?>? firstName,
    Wrapped<String?>? lastName,
    Wrapped<String>? email,
    Wrapped<String?>? userPassword,
    Wrapped<String?>? phoneNumber,
    Wrapped<dynamic>? devicesId,
    Wrapped<String?>? tempId,
    Wrapped<dynamic>? relatedDevices,
    Wrapped<DateTime?>? emailPinCreated,
    Wrapped<bool?>? emailVerified,
    Wrapped<bool?>? isArchived,
    Wrapped<bool?>? isGoogleUser,
    Wrapped<bool?>? isOpenrouterUser,
    Wrapped<bool?>? isMicrosoftUser,
    Wrapped<bool?>? isGithubUser,
    Wrapped<bool?>? isActive,
    Wrapped<bool?>? isStaff,
  }) {
    return FullProfileRequest(
      username: (username != null ? username.value : this.username),
      firstName: (firstName != null ? firstName.value : this.firstName),
      lastName: (lastName != null ? lastName.value : this.lastName),
      email: (email != null ? email.value : this.email),
      userPassword: (userPassword != null
          ? userPassword.value
          : this.userPassword),
      phoneNumber: (phoneNumber != null ? phoneNumber.value : this.phoneNumber),
      devicesId: (devicesId != null ? devicesId.value : this.devicesId),
      tempId: (tempId != null ? tempId.value : this.tempId),
      relatedDevices: (relatedDevices != null
          ? relatedDevices.value
          : this.relatedDevices),
      emailPinCreated: (emailPinCreated != null
          ? emailPinCreated.value
          : this.emailPinCreated),
      emailVerified: (emailVerified != null
          ? emailVerified.value
          : this.emailVerified),
      isArchived: (isArchived != null ? isArchived.value : this.isArchived),
      isGoogleUser: (isGoogleUser != null
          ? isGoogleUser.value
          : this.isGoogleUser),
      isOpenrouterUser: (isOpenrouterUser != null
          ? isOpenrouterUser.value
          : this.isOpenrouterUser),
      isMicrosoftUser: (isMicrosoftUser != null
          ? isMicrosoftUser.value
          : this.isMicrosoftUser),
      isGithubUser: (isGithubUser != null
          ? isGithubUser.value
          : this.isGithubUser),
      isActive: (isActive != null ? isActive.value : this.isActive),
      isStaff: (isStaff != null ? isStaff.value : this.isStaff),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class HealthCheckResponse {
  const HealthCheckResponse({required this.status, required this.message});

  factory HealthCheckResponse.fromJson(Map<String, dynamic> json) =>
      _$HealthCheckResponseFromJson(json);

  static const toJsonFactory = _$HealthCheckResponseToJson;
  Map<String, dynamic> toJson() => _$HealthCheckResponseToJson(this);

  @JsonKey(name: 'status', includeIfNull: false)
  final String status;
  @JsonKey(name: 'message', includeIfNull: false)
  final String message;
  static const fromJsonFactory = _$HealthCheckResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is HealthCheckResponse &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.message, message) ||
                const DeepCollectionEquality().equals(other.message, message)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(message) ^
      runtimeType.hashCode;
}

extension $HealthCheckResponseExtension on HealthCheckResponse {
  HealthCheckResponse copyWith({String? status, String? message}) {
    return HealthCheckResponse(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  HealthCheckResponse copyWithWrapped({
    Wrapped<String>? status,
    Wrapped<String>? message,
  }) {
    return HealthCheckResponse(
      status: (status != null ? status.value : this.status),
      message: (message != null ? message.value : this.message),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class LoginRequest {
  const LoginRequest({
    this.identifier,
    this.email,
    this.username,
    this.userPassword,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  static const toJsonFactory = _$LoginRequestToJson;
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);

  @JsonKey(name: 'identifier', includeIfNull: false)
  final String? identifier;
  @JsonKey(name: 'email', includeIfNull: false)
  final dynamic email;
  @JsonKey(name: 'username', includeIfNull: false)
  final String? username;
  @JsonKey(name: 'user_password', includeIfNull: false)
  final String? userPassword;
  static const fromJsonFactory = _$LoginRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is LoginRequest &&
            (identical(other.identifier, identifier) ||
                const DeepCollectionEquality().equals(
                  other.identifier,
                  identifier,
                )) &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.username, username) ||
                const DeepCollectionEquality().equals(
                  other.username,
                  username,
                )) &&
            (identical(other.userPassword, userPassword) ||
                const DeepCollectionEquality().equals(
                  other.userPassword,
                  userPassword,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(identifier) ^
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(username) ^
      const DeepCollectionEquality().hash(userPassword) ^
      runtimeType.hashCode;
}

extension $LoginRequestExtension on LoginRequest {
  LoginRequest copyWith({
    String? identifier,
    dynamic email,
    String? username,
    String? userPassword,
  }) {
    return LoginRequest(
      identifier: identifier ?? this.identifier,
      email: email ?? this.email,
      username: username ?? this.username,
      userPassword: userPassword ?? this.userPassword,
    );
  }

  LoginRequest copyWithWrapped({
    Wrapped<String?>? identifier,
    Wrapped<dynamic>? email,
    Wrapped<String?>? username,
    Wrapped<String?>? userPassword,
  }) {
    return LoginRequest(
      identifier: (identifier != null ? identifier.value : this.identifier),
      email: (email != null ? email.value : this.email),
      username: (username != null ? username.value : this.username),
      userPassword: (userPassword != null
          ? userPassword.value
          : this.userPassword),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class LoginResponse {
  const LoginResponse({
    required this.message,
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    required this.emailVerified,
    required this.conversations,
    required this.attachments,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  static const toJsonFactory = _$LoginResponseToJson;
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);

  @JsonKey(name: 'message', includeIfNull: false)
  final String message;
  @JsonKey(name: 'user_id', includeIfNull: false)
  final String userId;
  @JsonKey(name: 'access_token', includeIfNull: false)
  final String accessToken;
  @JsonKey(name: 'refresh_token', includeIfNull: false)
  final String refreshToken;
  @JsonKey(name: 'email_verified', includeIfNull: false)
  final bool emailVerified;
  @JsonKey(
    name: 'conversations',
    includeIfNull: false,
    defaultValue: <ConversationDoc>[],
  )
  final List<ConversationDoc> conversations;
  @JsonKey(
    name: 'attachments',
    includeIfNull: false,
    defaultValue: <AttachmentDoc>[],
  )
  final List<AttachmentDoc> attachments;
  static const fromJsonFactory = _$LoginResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is LoginResponse &&
            (identical(other.message, message) ||
                const DeepCollectionEquality().equals(
                  other.message,
                  message,
                )) &&
            (identical(other.userId, userId) ||
                const DeepCollectionEquality().equals(other.userId, userId)) &&
            (identical(other.accessToken, accessToken) ||
                const DeepCollectionEquality().equals(
                  other.accessToken,
                  accessToken,
                )) &&
            (identical(other.refreshToken, refreshToken) ||
                const DeepCollectionEquality().equals(
                  other.refreshToken,
                  refreshToken,
                )) &&
            (identical(other.emailVerified, emailVerified) ||
                const DeepCollectionEquality().equals(
                  other.emailVerified,
                  emailVerified,
                )) &&
            (identical(other.conversations, conversations) ||
                const DeepCollectionEquality().equals(
                  other.conversations,
                  conversations,
                )) &&
            (identical(other.attachments, attachments) ||
                const DeepCollectionEquality().equals(
                  other.attachments,
                  attachments,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(message) ^
      const DeepCollectionEquality().hash(userId) ^
      const DeepCollectionEquality().hash(accessToken) ^
      const DeepCollectionEquality().hash(refreshToken) ^
      const DeepCollectionEquality().hash(emailVerified) ^
      const DeepCollectionEquality().hash(conversations) ^
      const DeepCollectionEquality().hash(attachments) ^
      runtimeType.hashCode;
}

extension $LoginResponseExtension on LoginResponse {
  LoginResponse copyWith({
    String? message,
    String? userId,
    String? accessToken,
    String? refreshToken,
    bool? emailVerified,
    List<ConversationDoc>? conversations,
    List<AttachmentDoc>? attachments,
  }) {
    return LoginResponse(
      message: message ?? this.message,
      userId: userId ?? this.userId,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      emailVerified: emailVerified ?? this.emailVerified,
      conversations: conversations ?? this.conversations,
      attachments: attachments ?? this.attachments,
    );
  }

  LoginResponse copyWithWrapped({
    Wrapped<String>? message,
    Wrapped<String>? userId,
    Wrapped<String>? accessToken,
    Wrapped<String>? refreshToken,
    Wrapped<bool>? emailVerified,
    Wrapped<List<ConversationDoc>>? conversations,
    Wrapped<List<AttachmentDoc>>? attachments,
  }) {
    return LoginResponse(
      message: (message != null ? message.value : this.message),
      userId: (userId != null ? userId.value : this.userId),
      accessToken: (accessToken != null ? accessToken.value : this.accessToken),
      refreshToken: (refreshToken != null
          ? refreshToken.value
          : this.refreshToken),
      emailVerified: (emailVerified != null
          ? emailVerified.value
          : this.emailVerified),
      conversations: (conversations != null
          ? conversations.value
          : this.conversations),
      attachments: (attachments != null ? attachments.value : this.attachments),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class LogoutRequestRequest {
  const LogoutRequestRequest({this.refreshToken});

  factory LogoutRequestRequest.fromJson(Map<String, dynamic> json) =>
      _$LogoutRequestRequestFromJson(json);

  static const toJsonFactory = _$LogoutRequestRequestToJson;
  Map<String, dynamic> toJson() => _$LogoutRequestRequestToJson(this);

  @JsonKey(name: 'refresh_token', includeIfNull: false)
  final String? refreshToken;
  static const fromJsonFactory = _$LogoutRequestRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is LogoutRequestRequest &&
            (identical(other.refreshToken, refreshToken) ||
                const DeepCollectionEquality().equals(
                  other.refreshToken,
                  refreshToken,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(refreshToken) ^ runtimeType.hashCode;
}

extension $LogoutRequestRequestExtension on LogoutRequestRequest {
  LogoutRequestRequest copyWith({String? refreshToken}) {
    return LogoutRequestRequest(
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  LogoutRequestRequest copyWithWrapped({Wrapped<String?>? refreshToken}) {
    return LogoutRequestRequest(
      refreshToken: (refreshToken != null
          ? refreshToken.value
          : this.refreshToken),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class LogoutResponse {
  const LogoutResponse({required this.detail});

  factory LogoutResponse.fromJson(Map<String, dynamic> json) =>
      _$LogoutResponseFromJson(json);

  static const toJsonFactory = _$LogoutResponseToJson;
  Map<String, dynamic> toJson() => _$LogoutResponseToJson(this);

  @JsonKey(name: 'detail', includeIfNull: false)
  final String detail;
  static const fromJsonFactory = _$LogoutResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is LogoutResponse &&
            (identical(other.detail, detail) ||
                const DeepCollectionEquality().equals(other.detail, detail)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(detail) ^ runtimeType.hashCode;
}

extension $LogoutResponseExtension on LogoutResponse {
  LogoutResponse copyWith({String? detail}) {
    return LogoutResponse(detail: detail ?? this.detail);
  }

  LogoutResponse copyWithWrapped({Wrapped<String>? detail}) {
    return LogoutResponse(
      detail: (detail != null ? detail.value : this.detail),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class Message {
  const Message({
    this.messageId,
    this.userId,
    required this.conversationId,
    this.requestId,
    this.responseId,
    this.outputId,
    this.timestamp,
    this.status,
    this.vote,
    this.hasImage,
    this.imgUrl,
    this.metadata,
    this.hasEmbedding,
    this.hasDocument,
    this.docUrl,
    this.request,
    this.response,
    this.output,
  });

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  static const toJsonFactory = _$MessageToJson;
  Map<String, dynamic> toJson() => _$MessageToJson(this);

  @JsonKey(name: 'message_id', includeIfNull: false)
  final String? messageId;
  @JsonKey(name: 'user_id', includeIfNull: false)
  final String? userId;
  @JsonKey(name: 'conversation_id', includeIfNull: false)
  final String conversationId;
  @JsonKey(name: 'request_id', includeIfNull: false)
  final String? requestId;
  @JsonKey(name: 'response_id', includeIfNull: false)
  final String? responseId;
  @JsonKey(name: 'output_id', includeIfNull: false)
  final int? outputId;
  @JsonKey(name: 'timestamp', includeIfNull: false)
  final DateTime? timestamp;
  @JsonKey(
    name: 'status',
    includeIfNull: false,
    toJson: statusEnumNullableToJson,
    fromJson: statusEnumNullableFromJson,
  )
  final enums.StatusEnum? status;
  @JsonKey(name: 'vote', includeIfNull: false)
  final bool? vote;
  @JsonKey(name: 'has_image', includeIfNull: false)
  final bool? hasImage;
  @JsonKey(name: 'img_Url', includeIfNull: false)
  final String? imgUrl;
  @JsonKey(name: 'metadata', includeIfNull: false)
  final dynamic metadata;
  @JsonKey(name: 'has_embedding', includeIfNull: false)
  final bool? hasEmbedding;
  @JsonKey(name: 'has_document', includeIfNull: false)
  final bool? hasDocument;
  @JsonKey(name: 'doc_url', includeIfNull: false)
  final String? docUrl;
  @JsonKey(name: 'request', includeIfNull: false)
  final MessageRequest? request;
  @JsonKey(name: 'response', includeIfNull: false)
  final MessageResponse? response;
  @JsonKey(name: 'output', includeIfNull: false)
  final MessageOutput? output;
  static const fromJsonFactory = _$MessageFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Message &&
            (identical(other.messageId, messageId) ||
                const DeepCollectionEquality().equals(
                  other.messageId,
                  messageId,
                )) &&
            (identical(other.userId, userId) ||
                const DeepCollectionEquality().equals(other.userId, userId)) &&
            (identical(other.conversationId, conversationId) ||
                const DeepCollectionEquality().equals(
                  other.conversationId,
                  conversationId,
                )) &&
            (identical(other.requestId, requestId) ||
                const DeepCollectionEquality().equals(
                  other.requestId,
                  requestId,
                )) &&
            (identical(other.responseId, responseId) ||
                const DeepCollectionEquality().equals(
                  other.responseId,
                  responseId,
                )) &&
            (identical(other.outputId, outputId) ||
                const DeepCollectionEquality().equals(
                  other.outputId,
                  outputId,
                )) &&
            (identical(other.timestamp, timestamp) ||
                const DeepCollectionEquality().equals(
                  other.timestamp,
                  timestamp,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.vote, vote) ||
                const DeepCollectionEquality().equals(other.vote, vote)) &&
            (identical(other.hasImage, hasImage) ||
                const DeepCollectionEquality().equals(
                  other.hasImage,
                  hasImage,
                )) &&
            (identical(other.imgUrl, imgUrl) ||
                const DeepCollectionEquality().equals(other.imgUrl, imgUrl)) &&
            (identical(other.metadata, metadata) ||
                const DeepCollectionEquality().equals(
                  other.metadata,
                  metadata,
                )) &&
            (identical(other.hasEmbedding, hasEmbedding) ||
                const DeepCollectionEquality().equals(
                  other.hasEmbedding,
                  hasEmbedding,
                )) &&
            (identical(other.hasDocument, hasDocument) ||
                const DeepCollectionEquality().equals(
                  other.hasDocument,
                  hasDocument,
                )) &&
            (identical(other.docUrl, docUrl) ||
                const DeepCollectionEquality().equals(other.docUrl, docUrl)) &&
            (identical(other.request, request) ||
                const DeepCollectionEquality().equals(
                  other.request,
                  request,
                )) &&
            (identical(other.response, response) ||
                const DeepCollectionEquality().equals(
                  other.response,
                  response,
                )) &&
            (identical(other.output, output) ||
                const DeepCollectionEquality().equals(other.output, output)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(messageId) ^
      const DeepCollectionEquality().hash(userId) ^
      const DeepCollectionEquality().hash(conversationId) ^
      const DeepCollectionEquality().hash(requestId) ^
      const DeepCollectionEquality().hash(responseId) ^
      const DeepCollectionEquality().hash(outputId) ^
      const DeepCollectionEquality().hash(timestamp) ^
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(vote) ^
      const DeepCollectionEquality().hash(hasImage) ^
      const DeepCollectionEquality().hash(imgUrl) ^
      const DeepCollectionEquality().hash(metadata) ^
      const DeepCollectionEquality().hash(hasEmbedding) ^
      const DeepCollectionEquality().hash(hasDocument) ^
      const DeepCollectionEquality().hash(docUrl) ^
      const DeepCollectionEquality().hash(request) ^
      const DeepCollectionEquality().hash(response) ^
      const DeepCollectionEquality().hash(output) ^
      runtimeType.hashCode;
}

extension $MessageExtension on Message {
  Message copyWith({
    String? messageId,
    String? userId,
    String? conversationId,
    String? requestId,
    String? responseId,
    int? outputId,
    DateTime? timestamp,
    enums.StatusEnum? status,
    bool? vote,
    bool? hasImage,
    String? imgUrl,
    dynamic metadata,
    bool? hasEmbedding,
    bool? hasDocument,
    String? docUrl,
    MessageRequest? request,
    MessageResponse? response,
    MessageOutput? output,
  }) {
    return Message(
      messageId: messageId ?? this.messageId,
      userId: userId ?? this.userId,
      conversationId: conversationId ?? this.conversationId,
      requestId: requestId ?? this.requestId,
      responseId: responseId ?? this.responseId,
      outputId: outputId ?? this.outputId,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      vote: vote ?? this.vote,
      hasImage: hasImage ?? this.hasImage,
      imgUrl: imgUrl ?? this.imgUrl,
      metadata: metadata ?? this.metadata,
      hasEmbedding: hasEmbedding ?? this.hasEmbedding,
      hasDocument: hasDocument ?? this.hasDocument,
      docUrl: docUrl ?? this.docUrl,
      request: request ?? this.request,
      response: response ?? this.response,
      output: output ?? this.output,
    );
  }

  Message copyWithWrapped({
    Wrapped<String?>? messageId,
    Wrapped<String?>? userId,
    Wrapped<String>? conversationId,
    Wrapped<String?>? requestId,
    Wrapped<String?>? responseId,
    Wrapped<int?>? outputId,
    Wrapped<DateTime?>? timestamp,
    Wrapped<enums.StatusEnum?>? status,
    Wrapped<bool?>? vote,
    Wrapped<bool?>? hasImage,
    Wrapped<String?>? imgUrl,
    Wrapped<dynamic>? metadata,
    Wrapped<bool?>? hasEmbedding,
    Wrapped<bool?>? hasDocument,
    Wrapped<String?>? docUrl,
    Wrapped<MessageRequest?>? request,
    Wrapped<MessageResponse?>? response,
    Wrapped<MessageOutput?>? output,
  }) {
    return Message(
      messageId: (messageId != null ? messageId.value : this.messageId),
      userId: (userId != null ? userId.value : this.userId),
      conversationId: (conversationId != null
          ? conversationId.value
          : this.conversationId),
      requestId: (requestId != null ? requestId.value : this.requestId),
      responseId: (responseId != null ? responseId.value : this.responseId),
      outputId: (outputId != null ? outputId.value : this.outputId),
      timestamp: (timestamp != null ? timestamp.value : this.timestamp),
      status: (status != null ? status.value : this.status),
      vote: (vote != null ? vote.value : this.vote),
      hasImage: (hasImage != null ? hasImage.value : this.hasImage),
      imgUrl: (imgUrl != null ? imgUrl.value : this.imgUrl),
      metadata: (metadata != null ? metadata.value : this.metadata),
      hasEmbedding: (hasEmbedding != null
          ? hasEmbedding.value
          : this.hasEmbedding),
      hasDocument: (hasDocument != null ? hasDocument.value : this.hasDocument),
      docUrl: (docUrl != null ? docUrl.value : this.docUrl),
      request: (request != null ? request.value : this.request),
      response: (response != null ? response.value : this.response),
      output: (output != null ? output.value : this.output),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class MessageDoc {
  const MessageDoc({
    required this.messageId,
    required this.timestamp,
    this.hasImage,
    this.hasDocument,
  });

  factory MessageDoc.fromJson(Map<String, dynamic> json) =>
      _$MessageDocFromJson(json);

  static const toJsonFactory = _$MessageDocToJson;
  Map<String, dynamic> toJson() => _$MessageDocToJson(this);

  @JsonKey(name: 'message_id', includeIfNull: false)
  final String messageId;
  @JsonKey(name: 'timestamp', includeIfNull: false)
  final DateTime timestamp;
  @JsonKey(name: 'has_image', includeIfNull: false)
  final bool? hasImage;
  @JsonKey(name: 'has_document', includeIfNull: false)
  final bool? hasDocument;
  static const fromJsonFactory = _$MessageDocFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is MessageDoc &&
            (identical(other.messageId, messageId) ||
                const DeepCollectionEquality().equals(
                  other.messageId,
                  messageId,
                )) &&
            (identical(other.timestamp, timestamp) ||
                const DeepCollectionEquality().equals(
                  other.timestamp,
                  timestamp,
                )) &&
            (identical(other.hasImage, hasImage) ||
                const DeepCollectionEquality().equals(
                  other.hasImage,
                  hasImage,
                )) &&
            (identical(other.hasDocument, hasDocument) ||
                const DeepCollectionEquality().equals(
                  other.hasDocument,
                  hasDocument,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(messageId) ^
      const DeepCollectionEquality().hash(timestamp) ^
      const DeepCollectionEquality().hash(hasImage) ^
      const DeepCollectionEquality().hash(hasDocument) ^
      runtimeType.hashCode;
}

extension $MessageDocExtension on MessageDoc {
  MessageDoc copyWith({
    String? messageId,
    DateTime? timestamp,
    bool? hasImage,
    bool? hasDocument,
  }) {
    return MessageDoc(
      messageId: messageId ?? this.messageId,
      timestamp: timestamp ?? this.timestamp,
      hasImage: hasImage ?? this.hasImage,
      hasDocument: hasDocument ?? this.hasDocument,
    );
  }

  MessageDoc copyWithWrapped({
    Wrapped<String>? messageId,
    Wrapped<DateTime>? timestamp,
    Wrapped<bool?>? hasImage,
    Wrapped<bool?>? hasDocument,
  }) {
    return MessageDoc(
      messageId: (messageId != null ? messageId.value : this.messageId),
      timestamp: (timestamp != null ? timestamp.value : this.timestamp),
      hasImage: (hasImage != null ? hasImage.value : this.hasImage),
      hasDocument: (hasDocument != null ? hasDocument.value : this.hasDocument),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class MessageOutput {
  const MessageOutput({
    this.id,
    this.outputType,
    this.outputId,
    this.outputStatus,
    this.outputRole,
    this.outputContentType,
    this.outputContentText,
    this.outputContentAnnotations,
  });

  factory MessageOutput.fromJson(Map<String, dynamic> json) =>
      _$MessageOutputFromJson(json);

  static const toJsonFactory = _$MessageOutputToJson;
  Map<String, dynamic> toJson() => _$MessageOutputToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final int? id;
  @JsonKey(name: 'output_type', includeIfNull: false)
  final String? outputType;
  @JsonKey(name: 'output_id', includeIfNull: false)
  final String? outputId;
  @JsonKey(name: 'output_status', includeIfNull: false)
  final String? outputStatus;
  @JsonKey(name: 'output_role', includeIfNull: false)
  final String? outputRole;
  @JsonKey(name: 'output_content_type', includeIfNull: false)
  final String? outputContentType;
  @JsonKey(name: 'output_content_text', includeIfNull: false)
  final String? outputContentText;
  @JsonKey(name: 'output_content_annotations', includeIfNull: false)
  final String? outputContentAnnotations;
  static const fromJsonFactory = _$MessageOutputFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is MessageOutput &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.outputType, outputType) ||
                const DeepCollectionEquality().equals(
                  other.outputType,
                  outputType,
                )) &&
            (identical(other.outputId, outputId) ||
                const DeepCollectionEquality().equals(
                  other.outputId,
                  outputId,
                )) &&
            (identical(other.outputStatus, outputStatus) ||
                const DeepCollectionEquality().equals(
                  other.outputStatus,
                  outputStatus,
                )) &&
            (identical(other.outputRole, outputRole) ||
                const DeepCollectionEquality().equals(
                  other.outputRole,
                  outputRole,
                )) &&
            (identical(other.outputContentType, outputContentType) ||
                const DeepCollectionEquality().equals(
                  other.outputContentType,
                  outputContentType,
                )) &&
            (identical(other.outputContentText, outputContentText) ||
                const DeepCollectionEquality().equals(
                  other.outputContentText,
                  outputContentText,
                )) &&
            (identical(
                  other.outputContentAnnotations,
                  outputContentAnnotations,
                ) ||
                const DeepCollectionEquality().equals(
                  other.outputContentAnnotations,
                  outputContentAnnotations,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(outputType) ^
      const DeepCollectionEquality().hash(outputId) ^
      const DeepCollectionEquality().hash(outputStatus) ^
      const DeepCollectionEquality().hash(outputRole) ^
      const DeepCollectionEquality().hash(outputContentType) ^
      const DeepCollectionEquality().hash(outputContentText) ^
      const DeepCollectionEquality().hash(outputContentAnnotations) ^
      runtimeType.hashCode;
}

extension $MessageOutputExtension on MessageOutput {
  MessageOutput copyWith({
    int? id,
    String? outputType,
    String? outputId,
    String? outputStatus,
    String? outputRole,
    String? outputContentType,
    String? outputContentText,
    String? outputContentAnnotations,
  }) {
    return MessageOutput(
      id: id ?? this.id,
      outputType: outputType ?? this.outputType,
      outputId: outputId ?? this.outputId,
      outputStatus: outputStatus ?? this.outputStatus,
      outputRole: outputRole ?? this.outputRole,
      outputContentType: outputContentType ?? this.outputContentType,
      outputContentText: outputContentText ?? this.outputContentText,
      outputContentAnnotations:
          outputContentAnnotations ?? this.outputContentAnnotations,
    );
  }

  MessageOutput copyWithWrapped({
    Wrapped<int?>? id,
    Wrapped<String?>? outputType,
    Wrapped<String?>? outputId,
    Wrapped<String?>? outputStatus,
    Wrapped<String?>? outputRole,
    Wrapped<String?>? outputContentType,
    Wrapped<String?>? outputContentText,
    Wrapped<String?>? outputContentAnnotations,
  }) {
    return MessageOutput(
      id: (id != null ? id.value : this.id),
      outputType: (outputType != null ? outputType.value : this.outputType),
      outputId: (outputId != null ? outputId.value : this.outputId),
      outputStatus: (outputStatus != null
          ? outputStatus.value
          : this.outputStatus),
      outputRole: (outputRole != null ? outputRole.value : this.outputRole),
      outputContentType: (outputContentType != null
          ? outputContentType.value
          : this.outputContentType),
      outputContentText: (outputContentText != null
          ? outputContentText.value
          : this.outputContentText),
      outputContentAnnotations: (outputContentAnnotations != null
          ? outputContentAnnotations.value
          : this.outputContentAnnotations),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class MessageOutputRequest {
  const MessageOutputRequest({
    this.outputType,
    this.outputId,
    this.outputStatus,
    this.outputRole,
    this.outputContentType,
    this.outputContentText,
    this.outputContentAnnotations,
  });

  factory MessageOutputRequest.fromJson(Map<String, dynamic> json) =>
      _$MessageOutputRequestFromJson(json);

  static const toJsonFactory = _$MessageOutputRequestToJson;
  Map<String, dynamic> toJson() => _$MessageOutputRequestToJson(this);

  @JsonKey(name: 'output_type', includeIfNull: false)
  final String? outputType;
  @JsonKey(name: 'output_id', includeIfNull: false)
  final String? outputId;
  @JsonKey(name: 'output_status', includeIfNull: false)
  final String? outputStatus;
  @JsonKey(name: 'output_role', includeIfNull: false)
  final String? outputRole;
  @JsonKey(name: 'output_content_type', includeIfNull: false)
  final String? outputContentType;
  @JsonKey(name: 'output_content_text', includeIfNull: false)
  final String? outputContentText;
  @JsonKey(name: 'output_content_annotations', includeIfNull: false)
  final String? outputContentAnnotations;
  static const fromJsonFactory = _$MessageOutputRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is MessageOutputRequest &&
            (identical(other.outputType, outputType) ||
                const DeepCollectionEquality().equals(
                  other.outputType,
                  outputType,
                )) &&
            (identical(other.outputId, outputId) ||
                const DeepCollectionEquality().equals(
                  other.outputId,
                  outputId,
                )) &&
            (identical(other.outputStatus, outputStatus) ||
                const DeepCollectionEquality().equals(
                  other.outputStatus,
                  outputStatus,
                )) &&
            (identical(other.outputRole, outputRole) ||
                const DeepCollectionEquality().equals(
                  other.outputRole,
                  outputRole,
                )) &&
            (identical(other.outputContentType, outputContentType) ||
                const DeepCollectionEquality().equals(
                  other.outputContentType,
                  outputContentType,
                )) &&
            (identical(other.outputContentText, outputContentText) ||
                const DeepCollectionEquality().equals(
                  other.outputContentText,
                  outputContentText,
                )) &&
            (identical(
                  other.outputContentAnnotations,
                  outputContentAnnotations,
                ) ||
                const DeepCollectionEquality().equals(
                  other.outputContentAnnotations,
                  outputContentAnnotations,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(outputType) ^
      const DeepCollectionEquality().hash(outputId) ^
      const DeepCollectionEquality().hash(outputStatus) ^
      const DeepCollectionEquality().hash(outputRole) ^
      const DeepCollectionEquality().hash(outputContentType) ^
      const DeepCollectionEquality().hash(outputContentText) ^
      const DeepCollectionEquality().hash(outputContentAnnotations) ^
      runtimeType.hashCode;
}

extension $MessageOutputRequestExtension on MessageOutputRequest {
  MessageOutputRequest copyWith({
    String? outputType,
    String? outputId,
    String? outputStatus,
    String? outputRole,
    String? outputContentType,
    String? outputContentText,
    String? outputContentAnnotations,
  }) {
    return MessageOutputRequest(
      outputType: outputType ?? this.outputType,
      outputId: outputId ?? this.outputId,
      outputStatus: outputStatus ?? this.outputStatus,
      outputRole: outputRole ?? this.outputRole,
      outputContentType: outputContentType ?? this.outputContentType,
      outputContentText: outputContentText ?? this.outputContentText,
      outputContentAnnotations:
          outputContentAnnotations ?? this.outputContentAnnotations,
    );
  }

  MessageOutputRequest copyWithWrapped({
    Wrapped<String?>? outputType,
    Wrapped<String?>? outputId,
    Wrapped<String?>? outputStatus,
    Wrapped<String?>? outputRole,
    Wrapped<String?>? outputContentType,
    Wrapped<String?>? outputContentText,
    Wrapped<String?>? outputContentAnnotations,
  }) {
    return MessageOutputRequest(
      outputType: (outputType != null ? outputType.value : this.outputType),
      outputId: (outputId != null ? outputId.value : this.outputId),
      outputStatus: (outputStatus != null
          ? outputStatus.value
          : this.outputStatus),
      outputRole: (outputRole != null ? outputRole.value : this.outputRole),
      outputContentType: (outputContentType != null
          ? outputContentType.value
          : this.outputContentType),
      outputContentText: (outputContentText != null
          ? outputContentText.value
          : this.outputContentText),
      outputContentAnnotations: (outputContentAnnotations != null
          ? outputContentAnnotations.value
          : this.outputContentAnnotations),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class MessageRequest {
  const MessageRequest({
    this.requestId,
    this.requestModel,
    this.requestInput,
    this.requestSystemRole,
    this.requestSystemContent,
    this.requestSystemPrompt,
    this.requestUserStructuredOutput,
    this.requestStructuredSchema,
    this.requestUserRole,
    this.requestUserContent,
    this.requestMinP,
    this.requestTemperature,
    this.requestTopP,
    this.requestN,
    this.requestTopK,
    this.requestStream,
    this.requestStop,
    this.requestMaxTokens,
    this.repeatPenalty,
  });

  factory MessageRequest.fromJson(Map<String, dynamic> json) =>
      _$MessageRequestFromJson(json);

  static const toJsonFactory = _$MessageRequestToJson;
  Map<String, dynamic> toJson() => _$MessageRequestToJson(this);

  @JsonKey(name: 'request_id', includeIfNull: false)
  final String? requestId;
  @JsonKey(name: 'request_model', includeIfNull: false)
  final String? requestModel;
  @JsonKey(name: 'request_input', includeIfNull: false)
  final String? requestInput;
  @JsonKey(name: 'request_system_role', includeIfNull: false)
  final String? requestSystemRole;
  @JsonKey(name: 'request_system_content', includeIfNull: false)
  final String? requestSystemContent;
  @JsonKey(name: 'request_system_prompt', includeIfNull: false)
  final String? requestSystemPrompt;
  @JsonKey(name: 'request_user_structured_output', includeIfNull: false)
  final bool? requestUserStructuredOutput;
  @JsonKey(name: 'request_structured_schema', includeIfNull: false)
  final String? requestStructuredSchema;
  @JsonKey(name: 'request_user_role', includeIfNull: false)
  final String? requestUserRole;
  @JsonKey(name: 'request_user_content', includeIfNull: false)
  final String? requestUserContent;
  @JsonKey(name: 'request_min_p', includeIfNull: false)
  final double? requestMinP;
  @JsonKey(name: 'request_temperature', includeIfNull: false)
  final double? requestTemperature;
  @JsonKey(name: 'request_top_p', includeIfNull: false)
  final double? requestTopP;
  @JsonKey(name: 'request_n', includeIfNull: false)
  final int? requestN;
  @JsonKey(name: 'request_top_k', includeIfNull: false)
  final int? requestTopK;
  @JsonKey(name: 'request_stream', includeIfNull: false)
  final bool? requestStream;
  @JsonKey(name: 'request_stop', includeIfNull: false)
  final String? requestStop;
  @JsonKey(name: 'request_max_tokens', includeIfNull: false)
  final int? requestMaxTokens;
  @JsonKey(name: 'repeat_penalty', includeIfNull: false)
  final double? repeatPenalty;
  static const fromJsonFactory = _$MessageRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is MessageRequest &&
            (identical(other.requestId, requestId) ||
                const DeepCollectionEquality().equals(
                  other.requestId,
                  requestId,
                )) &&
            (identical(other.requestModel, requestModel) ||
                const DeepCollectionEquality().equals(
                  other.requestModel,
                  requestModel,
                )) &&
            (identical(other.requestInput, requestInput) ||
                const DeepCollectionEquality().equals(
                  other.requestInput,
                  requestInput,
                )) &&
            (identical(other.requestSystemRole, requestSystemRole) ||
                const DeepCollectionEquality().equals(
                  other.requestSystemRole,
                  requestSystemRole,
                )) &&
            (identical(other.requestSystemContent, requestSystemContent) ||
                const DeepCollectionEquality().equals(
                  other.requestSystemContent,
                  requestSystemContent,
                )) &&
            (identical(other.requestSystemPrompt, requestSystemPrompt) ||
                const DeepCollectionEquality().equals(
                  other.requestSystemPrompt,
                  requestSystemPrompt,
                )) &&
            (identical(
                  other.requestUserStructuredOutput,
                  requestUserStructuredOutput,
                ) ||
                const DeepCollectionEquality().equals(
                  other.requestUserStructuredOutput,
                  requestUserStructuredOutput,
                )) &&
            (identical(
                  other.requestStructuredSchema,
                  requestStructuredSchema,
                ) ||
                const DeepCollectionEquality().equals(
                  other.requestStructuredSchema,
                  requestStructuredSchema,
                )) &&
            (identical(other.requestUserRole, requestUserRole) ||
                const DeepCollectionEquality().equals(
                  other.requestUserRole,
                  requestUserRole,
                )) &&
            (identical(other.requestUserContent, requestUserContent) ||
                const DeepCollectionEquality().equals(
                  other.requestUserContent,
                  requestUserContent,
                )) &&
            (identical(other.requestMinP, requestMinP) ||
                const DeepCollectionEquality().equals(
                  other.requestMinP,
                  requestMinP,
                )) &&
            (identical(other.requestTemperature, requestTemperature) ||
                const DeepCollectionEquality().equals(
                  other.requestTemperature,
                  requestTemperature,
                )) &&
            (identical(other.requestTopP, requestTopP) ||
                const DeepCollectionEquality().equals(
                  other.requestTopP,
                  requestTopP,
                )) &&
            (identical(other.requestN, requestN) ||
                const DeepCollectionEquality().equals(
                  other.requestN,
                  requestN,
                )) &&
            (identical(other.requestTopK, requestTopK) ||
                const DeepCollectionEquality().equals(
                  other.requestTopK,
                  requestTopK,
                )) &&
            (identical(other.requestStream, requestStream) ||
                const DeepCollectionEquality().equals(
                  other.requestStream,
                  requestStream,
                )) &&
            (identical(other.requestStop, requestStop) ||
                const DeepCollectionEquality().equals(
                  other.requestStop,
                  requestStop,
                )) &&
            (identical(other.requestMaxTokens, requestMaxTokens) ||
                const DeepCollectionEquality().equals(
                  other.requestMaxTokens,
                  requestMaxTokens,
                )) &&
            (identical(other.repeatPenalty, repeatPenalty) ||
                const DeepCollectionEquality().equals(
                  other.repeatPenalty,
                  repeatPenalty,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(requestId) ^
      const DeepCollectionEquality().hash(requestModel) ^
      const DeepCollectionEquality().hash(requestInput) ^
      const DeepCollectionEquality().hash(requestSystemRole) ^
      const DeepCollectionEquality().hash(requestSystemContent) ^
      const DeepCollectionEquality().hash(requestSystemPrompt) ^
      const DeepCollectionEquality().hash(requestUserStructuredOutput) ^
      const DeepCollectionEquality().hash(requestStructuredSchema) ^
      const DeepCollectionEquality().hash(requestUserRole) ^
      const DeepCollectionEquality().hash(requestUserContent) ^
      const DeepCollectionEquality().hash(requestMinP) ^
      const DeepCollectionEquality().hash(requestTemperature) ^
      const DeepCollectionEquality().hash(requestTopP) ^
      const DeepCollectionEquality().hash(requestN) ^
      const DeepCollectionEquality().hash(requestTopK) ^
      const DeepCollectionEquality().hash(requestStream) ^
      const DeepCollectionEquality().hash(requestStop) ^
      const DeepCollectionEquality().hash(requestMaxTokens) ^
      const DeepCollectionEquality().hash(repeatPenalty) ^
      runtimeType.hashCode;
}

extension $MessageRequestExtension on MessageRequest {
  MessageRequest copyWith({
    String? requestId,
    String? requestModel,
    String? requestInput,
    String? requestSystemRole,
    String? requestSystemContent,
    String? requestSystemPrompt,
    bool? requestUserStructuredOutput,
    String? requestStructuredSchema,
    String? requestUserRole,
    String? requestUserContent,
    double? requestMinP,
    double? requestTemperature,
    double? requestTopP,
    int? requestN,
    int? requestTopK,
    bool? requestStream,
    String? requestStop,
    int? requestMaxTokens,
    double? repeatPenalty,
  }) {
    return MessageRequest(
      requestId: requestId ?? this.requestId,
      requestModel: requestModel ?? this.requestModel,
      requestInput: requestInput ?? this.requestInput,
      requestSystemRole: requestSystemRole ?? this.requestSystemRole,
      requestSystemContent: requestSystemContent ?? this.requestSystemContent,
      requestSystemPrompt: requestSystemPrompt ?? this.requestSystemPrompt,
      requestUserStructuredOutput:
          requestUserStructuredOutput ?? this.requestUserStructuredOutput,
      requestStructuredSchema:
          requestStructuredSchema ?? this.requestStructuredSchema,
      requestUserRole: requestUserRole ?? this.requestUserRole,
      requestUserContent: requestUserContent ?? this.requestUserContent,
      requestMinP: requestMinP ?? this.requestMinP,
      requestTemperature: requestTemperature ?? this.requestTemperature,
      requestTopP: requestTopP ?? this.requestTopP,
      requestN: requestN ?? this.requestN,
      requestTopK: requestTopK ?? this.requestTopK,
      requestStream: requestStream ?? this.requestStream,
      requestStop: requestStop ?? this.requestStop,
      requestMaxTokens: requestMaxTokens ?? this.requestMaxTokens,
      repeatPenalty: repeatPenalty ?? this.repeatPenalty,
    );
  }

  MessageRequest copyWithWrapped({
    Wrapped<String?>? requestId,
    Wrapped<String?>? requestModel,
    Wrapped<String?>? requestInput,
    Wrapped<String?>? requestSystemRole,
    Wrapped<String?>? requestSystemContent,
    Wrapped<String?>? requestSystemPrompt,
    Wrapped<bool?>? requestUserStructuredOutput,
    Wrapped<String?>? requestStructuredSchema,
    Wrapped<String?>? requestUserRole,
    Wrapped<String?>? requestUserContent,
    Wrapped<double?>? requestMinP,
    Wrapped<double?>? requestTemperature,
    Wrapped<double?>? requestTopP,
    Wrapped<int?>? requestN,
    Wrapped<int?>? requestTopK,
    Wrapped<bool?>? requestStream,
    Wrapped<String?>? requestStop,
    Wrapped<int?>? requestMaxTokens,
    Wrapped<double?>? repeatPenalty,
  }) {
    return MessageRequest(
      requestId: (requestId != null ? requestId.value : this.requestId),
      requestModel: (requestModel != null
          ? requestModel.value
          : this.requestModel),
      requestInput: (requestInput != null
          ? requestInput.value
          : this.requestInput),
      requestSystemRole: (requestSystemRole != null
          ? requestSystemRole.value
          : this.requestSystemRole),
      requestSystemContent: (requestSystemContent != null
          ? requestSystemContent.value
          : this.requestSystemContent),
      requestSystemPrompt: (requestSystemPrompt != null
          ? requestSystemPrompt.value
          : this.requestSystemPrompt),
      requestUserStructuredOutput: (requestUserStructuredOutput != null
          ? requestUserStructuredOutput.value
          : this.requestUserStructuredOutput),
      requestStructuredSchema: (requestStructuredSchema != null
          ? requestStructuredSchema.value
          : this.requestStructuredSchema),
      requestUserRole: (requestUserRole != null
          ? requestUserRole.value
          : this.requestUserRole),
      requestUserContent: (requestUserContent != null
          ? requestUserContent.value
          : this.requestUserContent),
      requestMinP: (requestMinP != null ? requestMinP.value : this.requestMinP),
      requestTemperature: (requestTemperature != null
          ? requestTemperature.value
          : this.requestTemperature),
      requestTopP: (requestTopP != null ? requestTopP.value : this.requestTopP),
      requestN: (requestN != null ? requestN.value : this.requestN),
      requestTopK: (requestTopK != null ? requestTopK.value : this.requestTopK),
      requestStream: (requestStream != null
          ? requestStream.value
          : this.requestStream),
      requestStop: (requestStop != null ? requestStop.value : this.requestStop),
      requestMaxTokens: (requestMaxTokens != null
          ? requestMaxTokens.value
          : this.requestMaxTokens),
      repeatPenalty: (repeatPenalty != null
          ? repeatPenalty.value
          : this.repeatPenalty),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class MessageRequestRequest {
  const MessageRequestRequest({
    this.requestModel,
    this.requestInput,
    this.requestSystemRole,
    this.requestSystemContent,
    this.requestSystemPrompt,
    this.requestUserStructuredOutput,
    this.requestStructuredSchema,
    this.requestUserRole,
    this.requestUserContent,
    this.requestMinP,
    this.requestTemperature,
    this.requestTopP,
    this.requestN,
    this.requestTopK,
    this.requestStream,
    this.requestStop,
    this.requestMaxTokens,
    this.repeatPenalty,
  });

  factory MessageRequestRequest.fromJson(Map<String, dynamic> json) =>
      _$MessageRequestRequestFromJson(json);

  static const toJsonFactory = _$MessageRequestRequestToJson;
  Map<String, dynamic> toJson() => _$MessageRequestRequestToJson(this);

  @JsonKey(name: 'request_model', includeIfNull: false)
  final String? requestModel;
  @JsonKey(name: 'request_input', includeIfNull: false)
  final String? requestInput;
  @JsonKey(name: 'request_system_role', includeIfNull: false)
  final String? requestSystemRole;
  @JsonKey(name: 'request_system_content', includeIfNull: false)
  final String? requestSystemContent;
  @JsonKey(name: 'request_system_prompt', includeIfNull: false)
  final String? requestSystemPrompt;
  @JsonKey(name: 'request_user_structured_output', includeIfNull: false)
  final bool? requestUserStructuredOutput;
  @JsonKey(name: 'request_structured_schema', includeIfNull: false)
  final String? requestStructuredSchema;
  @JsonKey(name: 'request_user_role', includeIfNull: false)
  final String? requestUserRole;
  @JsonKey(name: 'request_user_content', includeIfNull: false)
  final String? requestUserContent;
  @JsonKey(name: 'request_min_p', includeIfNull: false)
  final double? requestMinP;
  @JsonKey(name: 'request_temperature', includeIfNull: false)
  final double? requestTemperature;
  @JsonKey(name: 'request_top_p', includeIfNull: false)
  final double? requestTopP;
  @JsonKey(name: 'request_n', includeIfNull: false)
  final int? requestN;
  @JsonKey(name: 'request_top_k', includeIfNull: false)
  final int? requestTopK;
  @JsonKey(name: 'request_stream', includeIfNull: false)
  final bool? requestStream;
  @JsonKey(name: 'request_stop', includeIfNull: false)
  final String? requestStop;
  @JsonKey(name: 'request_max_tokens', includeIfNull: false)
  final int? requestMaxTokens;
  @JsonKey(name: 'repeat_penalty', includeIfNull: false)
  final double? repeatPenalty;
  static const fromJsonFactory = _$MessageRequestRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is MessageRequestRequest &&
            (identical(other.requestModel, requestModel) ||
                const DeepCollectionEquality().equals(
                  other.requestModel,
                  requestModel,
                )) &&
            (identical(other.requestInput, requestInput) ||
                const DeepCollectionEquality().equals(
                  other.requestInput,
                  requestInput,
                )) &&
            (identical(other.requestSystemRole, requestSystemRole) ||
                const DeepCollectionEquality().equals(
                  other.requestSystemRole,
                  requestSystemRole,
                )) &&
            (identical(other.requestSystemContent, requestSystemContent) ||
                const DeepCollectionEquality().equals(
                  other.requestSystemContent,
                  requestSystemContent,
                )) &&
            (identical(other.requestSystemPrompt, requestSystemPrompt) ||
                const DeepCollectionEquality().equals(
                  other.requestSystemPrompt,
                  requestSystemPrompt,
                )) &&
            (identical(
                  other.requestUserStructuredOutput,
                  requestUserStructuredOutput,
                ) ||
                const DeepCollectionEquality().equals(
                  other.requestUserStructuredOutput,
                  requestUserStructuredOutput,
                )) &&
            (identical(
                  other.requestStructuredSchema,
                  requestStructuredSchema,
                ) ||
                const DeepCollectionEquality().equals(
                  other.requestStructuredSchema,
                  requestStructuredSchema,
                )) &&
            (identical(other.requestUserRole, requestUserRole) ||
                const DeepCollectionEquality().equals(
                  other.requestUserRole,
                  requestUserRole,
                )) &&
            (identical(other.requestUserContent, requestUserContent) ||
                const DeepCollectionEquality().equals(
                  other.requestUserContent,
                  requestUserContent,
                )) &&
            (identical(other.requestMinP, requestMinP) ||
                const DeepCollectionEquality().equals(
                  other.requestMinP,
                  requestMinP,
                )) &&
            (identical(other.requestTemperature, requestTemperature) ||
                const DeepCollectionEquality().equals(
                  other.requestTemperature,
                  requestTemperature,
                )) &&
            (identical(other.requestTopP, requestTopP) ||
                const DeepCollectionEquality().equals(
                  other.requestTopP,
                  requestTopP,
                )) &&
            (identical(other.requestN, requestN) ||
                const DeepCollectionEquality().equals(
                  other.requestN,
                  requestN,
                )) &&
            (identical(other.requestTopK, requestTopK) ||
                const DeepCollectionEquality().equals(
                  other.requestTopK,
                  requestTopK,
                )) &&
            (identical(other.requestStream, requestStream) ||
                const DeepCollectionEquality().equals(
                  other.requestStream,
                  requestStream,
                )) &&
            (identical(other.requestStop, requestStop) ||
                const DeepCollectionEquality().equals(
                  other.requestStop,
                  requestStop,
                )) &&
            (identical(other.requestMaxTokens, requestMaxTokens) ||
                const DeepCollectionEquality().equals(
                  other.requestMaxTokens,
                  requestMaxTokens,
                )) &&
            (identical(other.repeatPenalty, repeatPenalty) ||
                const DeepCollectionEquality().equals(
                  other.repeatPenalty,
                  repeatPenalty,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(requestModel) ^
      const DeepCollectionEquality().hash(requestInput) ^
      const DeepCollectionEquality().hash(requestSystemRole) ^
      const DeepCollectionEquality().hash(requestSystemContent) ^
      const DeepCollectionEquality().hash(requestSystemPrompt) ^
      const DeepCollectionEquality().hash(requestUserStructuredOutput) ^
      const DeepCollectionEquality().hash(requestStructuredSchema) ^
      const DeepCollectionEquality().hash(requestUserRole) ^
      const DeepCollectionEquality().hash(requestUserContent) ^
      const DeepCollectionEquality().hash(requestMinP) ^
      const DeepCollectionEquality().hash(requestTemperature) ^
      const DeepCollectionEquality().hash(requestTopP) ^
      const DeepCollectionEquality().hash(requestN) ^
      const DeepCollectionEquality().hash(requestTopK) ^
      const DeepCollectionEquality().hash(requestStream) ^
      const DeepCollectionEquality().hash(requestStop) ^
      const DeepCollectionEquality().hash(requestMaxTokens) ^
      const DeepCollectionEquality().hash(repeatPenalty) ^
      runtimeType.hashCode;
}

extension $MessageRequestRequestExtension on MessageRequestRequest {
  MessageRequestRequest copyWith({
    String? requestModel,
    String? requestInput,
    String? requestSystemRole,
    String? requestSystemContent,
    String? requestSystemPrompt,
    bool? requestUserStructuredOutput,
    String? requestStructuredSchema,
    String? requestUserRole,
    String? requestUserContent,
    double? requestMinP,
    double? requestTemperature,
    double? requestTopP,
    int? requestN,
    int? requestTopK,
    bool? requestStream,
    String? requestStop,
    int? requestMaxTokens,
    double? repeatPenalty,
  }) {
    return MessageRequestRequest(
      requestModel: requestModel ?? this.requestModel,
      requestInput: requestInput ?? this.requestInput,
      requestSystemRole: requestSystemRole ?? this.requestSystemRole,
      requestSystemContent: requestSystemContent ?? this.requestSystemContent,
      requestSystemPrompt: requestSystemPrompt ?? this.requestSystemPrompt,
      requestUserStructuredOutput:
          requestUserStructuredOutput ?? this.requestUserStructuredOutput,
      requestStructuredSchema:
          requestStructuredSchema ?? this.requestStructuredSchema,
      requestUserRole: requestUserRole ?? this.requestUserRole,
      requestUserContent: requestUserContent ?? this.requestUserContent,
      requestMinP: requestMinP ?? this.requestMinP,
      requestTemperature: requestTemperature ?? this.requestTemperature,
      requestTopP: requestTopP ?? this.requestTopP,
      requestN: requestN ?? this.requestN,
      requestTopK: requestTopK ?? this.requestTopK,
      requestStream: requestStream ?? this.requestStream,
      requestStop: requestStop ?? this.requestStop,
      requestMaxTokens: requestMaxTokens ?? this.requestMaxTokens,
      repeatPenalty: repeatPenalty ?? this.repeatPenalty,
    );
  }

  MessageRequestRequest copyWithWrapped({
    Wrapped<String?>? requestModel,
    Wrapped<String?>? requestInput,
    Wrapped<String?>? requestSystemRole,
    Wrapped<String?>? requestSystemContent,
    Wrapped<String?>? requestSystemPrompt,
    Wrapped<bool?>? requestUserStructuredOutput,
    Wrapped<String?>? requestStructuredSchema,
    Wrapped<String?>? requestUserRole,
    Wrapped<String?>? requestUserContent,
    Wrapped<double?>? requestMinP,
    Wrapped<double?>? requestTemperature,
    Wrapped<double?>? requestTopP,
    Wrapped<int?>? requestN,
    Wrapped<int?>? requestTopK,
    Wrapped<bool?>? requestStream,
    Wrapped<String?>? requestStop,
    Wrapped<int?>? requestMaxTokens,
    Wrapped<double?>? repeatPenalty,
  }) {
    return MessageRequestRequest(
      requestModel: (requestModel != null
          ? requestModel.value
          : this.requestModel),
      requestInput: (requestInput != null
          ? requestInput.value
          : this.requestInput),
      requestSystemRole: (requestSystemRole != null
          ? requestSystemRole.value
          : this.requestSystemRole),
      requestSystemContent: (requestSystemContent != null
          ? requestSystemContent.value
          : this.requestSystemContent),
      requestSystemPrompt: (requestSystemPrompt != null
          ? requestSystemPrompt.value
          : this.requestSystemPrompt),
      requestUserStructuredOutput: (requestUserStructuredOutput != null
          ? requestUserStructuredOutput.value
          : this.requestUserStructuredOutput),
      requestStructuredSchema: (requestStructuredSchema != null
          ? requestStructuredSchema.value
          : this.requestStructuredSchema),
      requestUserRole: (requestUserRole != null
          ? requestUserRole.value
          : this.requestUserRole),
      requestUserContent: (requestUserContent != null
          ? requestUserContent.value
          : this.requestUserContent),
      requestMinP: (requestMinP != null ? requestMinP.value : this.requestMinP),
      requestTemperature: (requestTemperature != null
          ? requestTemperature.value
          : this.requestTemperature),
      requestTopP: (requestTopP != null ? requestTopP.value : this.requestTopP),
      requestN: (requestN != null ? requestN.value : this.requestN),
      requestTopK: (requestTopK != null ? requestTopK.value : this.requestTopK),
      requestStream: (requestStream != null
          ? requestStream.value
          : this.requestStream),
      requestStop: (requestStop != null ? requestStop.value : this.requestStop),
      requestMaxTokens: (requestMaxTokens != null
          ? requestMaxTokens.value
          : this.requestMaxTokens),
      repeatPenalty: (repeatPenalty != null
          ? repeatPenalty.value
          : this.repeatPenalty),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class MessageResponse {
  const MessageResponse({
    required this.responseId,
    this.object,
    this.createdAt,
    this.status,
    this.error,
    this.modelName,
    this.parallelToolCalls,
    this.previousResponseId,
    this.instructions,
    this.reasoningEffort,
    this.reasoningSummary,
    this.store,
    this.temperature,
    this.textFormatType,
    this.toolChoice,
    this.tools,
    this.topP,
    this.truncation,
    this.usageInputTokens,
    this.usageOutputTokens,
    this.usageTotalTokens,
    this.user,
    this.metadata,
    this.incompleteDetails,
    this.maxOutputTokens,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) =>
      _$MessageResponseFromJson(json);

  static const toJsonFactory = _$MessageResponseToJson;
  Map<String, dynamic> toJson() => _$MessageResponseToJson(this);

  @JsonKey(name: 'response_id', includeIfNull: false)
  final String responseId;
  @JsonKey(name: 'object', includeIfNull: false)
  final String? object;
  @JsonKey(name: 'created_at', includeIfNull: false)
  final DateTime? createdAt;
  @JsonKey(name: 'status', includeIfNull: false)
  final String? status;
  @JsonKey(name: 'error', includeIfNull: false)
  final String? error;
  @JsonKey(name: 'model_name', includeIfNull: false)
  final String? modelName;
  @JsonKey(name: 'parallel_tool_calls', includeIfNull: false)
  final bool? parallelToolCalls;
  @JsonKey(name: 'previous_response_id', includeIfNull: false)
  final String? previousResponseId;
  @JsonKey(name: 'instructions', includeIfNull: false)
  final String? instructions;
  @JsonKey(name: 'reasoning_effort', includeIfNull: false)
  final String? reasoningEffort;
  @JsonKey(name: 'reasoning_summary', includeIfNull: false)
  final String? reasoningSummary;
  @JsonKey(name: 'store', includeIfNull: false)
  final bool? store;
  @JsonKey(name: 'temperature', includeIfNull: false)
  final double? temperature;
  @JsonKey(name: 'text_format_type', includeIfNull: false)
  final String? textFormatType;
  @JsonKey(name: 'tool_choice', includeIfNull: false)
  final String? toolChoice;
  @JsonKey(name: 'tools', includeIfNull: false)
  final String? tools;
  @JsonKey(name: 'top_p', includeIfNull: false)
  final double? topP;
  @JsonKey(name: 'truncation', includeIfNull: false)
  final String? truncation;
  @JsonKey(name: 'usage_input_tokens', includeIfNull: false)
  final int? usageInputTokens;
  @JsonKey(name: 'usage_output_tokens', includeIfNull: false)
  final int? usageOutputTokens;
  @JsonKey(name: 'usage_total_tokens', includeIfNull: false)
  final int? usageTotalTokens;
  @JsonKey(name: 'user', includeIfNull: false)
  final String? user;
  @JsonKey(name: 'metadata', includeIfNull: false)
  final dynamic metadata;
  @JsonKey(name: 'incomplete_details', includeIfNull: false)
  final String? incompleteDetails;
  @JsonKey(name: 'max_output_tokens', includeIfNull: false)
  final int? maxOutputTokens;
  static const fromJsonFactory = _$MessageResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is MessageResponse &&
            (identical(other.responseId, responseId) ||
                const DeepCollectionEquality().equals(
                  other.responseId,
                  responseId,
                )) &&
            (identical(other.object, object) ||
                const DeepCollectionEquality().equals(other.object, object)) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.error, error) ||
                const DeepCollectionEquality().equals(other.error, error)) &&
            (identical(other.modelName, modelName) ||
                const DeepCollectionEquality().equals(
                  other.modelName,
                  modelName,
                )) &&
            (identical(other.parallelToolCalls, parallelToolCalls) ||
                const DeepCollectionEquality().equals(
                  other.parallelToolCalls,
                  parallelToolCalls,
                )) &&
            (identical(other.previousResponseId, previousResponseId) ||
                const DeepCollectionEquality().equals(
                  other.previousResponseId,
                  previousResponseId,
                )) &&
            (identical(other.instructions, instructions) ||
                const DeepCollectionEquality().equals(
                  other.instructions,
                  instructions,
                )) &&
            (identical(other.reasoningEffort, reasoningEffort) ||
                const DeepCollectionEquality().equals(
                  other.reasoningEffort,
                  reasoningEffort,
                )) &&
            (identical(other.reasoningSummary, reasoningSummary) ||
                const DeepCollectionEquality().equals(
                  other.reasoningSummary,
                  reasoningSummary,
                )) &&
            (identical(other.store, store) ||
                const DeepCollectionEquality().equals(other.store, store)) &&
            (identical(other.temperature, temperature) ||
                const DeepCollectionEquality().equals(
                  other.temperature,
                  temperature,
                )) &&
            (identical(other.textFormatType, textFormatType) ||
                const DeepCollectionEquality().equals(
                  other.textFormatType,
                  textFormatType,
                )) &&
            (identical(other.toolChoice, toolChoice) ||
                const DeepCollectionEquality().equals(
                  other.toolChoice,
                  toolChoice,
                )) &&
            (identical(other.tools, tools) ||
                const DeepCollectionEquality().equals(other.tools, tools)) &&
            (identical(other.topP, topP) ||
                const DeepCollectionEquality().equals(other.topP, topP)) &&
            (identical(other.truncation, truncation) ||
                const DeepCollectionEquality().equals(
                  other.truncation,
                  truncation,
                )) &&
            (identical(other.usageInputTokens, usageInputTokens) ||
                const DeepCollectionEquality().equals(
                  other.usageInputTokens,
                  usageInputTokens,
                )) &&
            (identical(other.usageOutputTokens, usageOutputTokens) ||
                const DeepCollectionEquality().equals(
                  other.usageOutputTokens,
                  usageOutputTokens,
                )) &&
            (identical(other.usageTotalTokens, usageTotalTokens) ||
                const DeepCollectionEquality().equals(
                  other.usageTotalTokens,
                  usageTotalTokens,
                )) &&
            (identical(other.user, user) ||
                const DeepCollectionEquality().equals(other.user, user)) &&
            (identical(other.metadata, metadata) ||
                const DeepCollectionEquality().equals(
                  other.metadata,
                  metadata,
                )) &&
            (identical(other.incompleteDetails, incompleteDetails) ||
                const DeepCollectionEquality().equals(
                  other.incompleteDetails,
                  incompleteDetails,
                )) &&
            (identical(other.maxOutputTokens, maxOutputTokens) ||
                const DeepCollectionEquality().equals(
                  other.maxOutputTokens,
                  maxOutputTokens,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(responseId) ^
      const DeepCollectionEquality().hash(object) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(error) ^
      const DeepCollectionEquality().hash(modelName) ^
      const DeepCollectionEquality().hash(parallelToolCalls) ^
      const DeepCollectionEquality().hash(previousResponseId) ^
      const DeepCollectionEquality().hash(instructions) ^
      const DeepCollectionEquality().hash(reasoningEffort) ^
      const DeepCollectionEquality().hash(reasoningSummary) ^
      const DeepCollectionEquality().hash(store) ^
      const DeepCollectionEquality().hash(temperature) ^
      const DeepCollectionEquality().hash(textFormatType) ^
      const DeepCollectionEquality().hash(toolChoice) ^
      const DeepCollectionEquality().hash(tools) ^
      const DeepCollectionEquality().hash(topP) ^
      const DeepCollectionEquality().hash(truncation) ^
      const DeepCollectionEquality().hash(usageInputTokens) ^
      const DeepCollectionEquality().hash(usageOutputTokens) ^
      const DeepCollectionEquality().hash(usageTotalTokens) ^
      const DeepCollectionEquality().hash(user) ^
      const DeepCollectionEquality().hash(metadata) ^
      const DeepCollectionEquality().hash(incompleteDetails) ^
      const DeepCollectionEquality().hash(maxOutputTokens) ^
      runtimeType.hashCode;
}

extension $MessageResponseExtension on MessageResponse {
  MessageResponse copyWith({
    String? responseId,
    String? object,
    DateTime? createdAt,
    String? status,
    String? error,
    String? modelName,
    bool? parallelToolCalls,
    String? previousResponseId,
    String? instructions,
    String? reasoningEffort,
    String? reasoningSummary,
    bool? store,
    double? temperature,
    String? textFormatType,
    String? toolChoice,
    String? tools,
    double? topP,
    String? truncation,
    int? usageInputTokens,
    int? usageOutputTokens,
    int? usageTotalTokens,
    String? user,
    dynamic metadata,
    String? incompleteDetails,
    int? maxOutputTokens,
  }) {
    return MessageResponse(
      responseId: responseId ?? this.responseId,
      object: object ?? this.object,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      error: error ?? this.error,
      modelName: modelName ?? this.modelName,
      parallelToolCalls: parallelToolCalls ?? this.parallelToolCalls,
      previousResponseId: previousResponseId ?? this.previousResponseId,
      instructions: instructions ?? this.instructions,
      reasoningEffort: reasoningEffort ?? this.reasoningEffort,
      reasoningSummary: reasoningSummary ?? this.reasoningSummary,
      store: store ?? this.store,
      temperature: temperature ?? this.temperature,
      textFormatType: textFormatType ?? this.textFormatType,
      toolChoice: toolChoice ?? this.toolChoice,
      tools: tools ?? this.tools,
      topP: topP ?? this.topP,
      truncation: truncation ?? this.truncation,
      usageInputTokens: usageInputTokens ?? this.usageInputTokens,
      usageOutputTokens: usageOutputTokens ?? this.usageOutputTokens,
      usageTotalTokens: usageTotalTokens ?? this.usageTotalTokens,
      user: user ?? this.user,
      metadata: metadata ?? this.metadata,
      incompleteDetails: incompleteDetails ?? this.incompleteDetails,
      maxOutputTokens: maxOutputTokens ?? this.maxOutputTokens,
    );
  }

  MessageResponse copyWithWrapped({
    Wrapped<String>? responseId,
    Wrapped<String?>? object,
    Wrapped<DateTime?>? createdAt,
    Wrapped<String?>? status,
    Wrapped<String?>? error,
    Wrapped<String?>? modelName,
    Wrapped<bool?>? parallelToolCalls,
    Wrapped<String?>? previousResponseId,
    Wrapped<String?>? instructions,
    Wrapped<String?>? reasoningEffort,
    Wrapped<String?>? reasoningSummary,
    Wrapped<bool?>? store,
    Wrapped<double?>? temperature,
    Wrapped<String?>? textFormatType,
    Wrapped<String?>? toolChoice,
    Wrapped<String?>? tools,
    Wrapped<double?>? topP,
    Wrapped<String?>? truncation,
    Wrapped<int?>? usageInputTokens,
    Wrapped<int?>? usageOutputTokens,
    Wrapped<int?>? usageTotalTokens,
    Wrapped<String?>? user,
    Wrapped<dynamic>? metadata,
    Wrapped<String?>? incompleteDetails,
    Wrapped<int?>? maxOutputTokens,
  }) {
    return MessageResponse(
      responseId: (responseId != null ? responseId.value : this.responseId),
      object: (object != null ? object.value : this.object),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      status: (status != null ? status.value : this.status),
      error: (error != null ? error.value : this.error),
      modelName: (modelName != null ? modelName.value : this.modelName),
      parallelToolCalls: (parallelToolCalls != null
          ? parallelToolCalls.value
          : this.parallelToolCalls),
      previousResponseId: (previousResponseId != null
          ? previousResponseId.value
          : this.previousResponseId),
      instructions: (instructions != null
          ? instructions.value
          : this.instructions),
      reasoningEffort: (reasoningEffort != null
          ? reasoningEffort.value
          : this.reasoningEffort),
      reasoningSummary: (reasoningSummary != null
          ? reasoningSummary.value
          : this.reasoningSummary),
      store: (store != null ? store.value : this.store),
      temperature: (temperature != null ? temperature.value : this.temperature),
      textFormatType: (textFormatType != null
          ? textFormatType.value
          : this.textFormatType),
      toolChoice: (toolChoice != null ? toolChoice.value : this.toolChoice),
      tools: (tools != null ? tools.value : this.tools),
      topP: (topP != null ? topP.value : this.topP),
      truncation: (truncation != null ? truncation.value : this.truncation),
      usageInputTokens: (usageInputTokens != null
          ? usageInputTokens.value
          : this.usageInputTokens),
      usageOutputTokens: (usageOutputTokens != null
          ? usageOutputTokens.value
          : this.usageOutputTokens),
      usageTotalTokens: (usageTotalTokens != null
          ? usageTotalTokens.value
          : this.usageTotalTokens),
      user: (user != null ? user.value : this.user),
      metadata: (metadata != null ? metadata.value : this.metadata),
      incompleteDetails: (incompleteDetails != null
          ? incompleteDetails.value
          : this.incompleteDetails),
      maxOutputTokens: (maxOutputTokens != null
          ? maxOutputTokens.value
          : this.maxOutputTokens),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class MessageResponseRequest {
  const MessageResponseRequest({
    required this.responseId,
    this.object,
    this.createdAt,
    this.status,
    this.error,
    this.modelName,
    this.parallelToolCalls,
    this.previousResponseId,
    this.instructions,
    this.reasoningEffort,
    this.reasoningSummary,
    this.store,
    this.temperature,
    this.textFormatType,
    this.toolChoice,
    this.tools,
    this.topP,
    this.truncation,
    this.usageInputTokens,
    this.usageOutputTokens,
    this.usageTotalTokens,
    this.metadata,
    this.incompleteDetails,
    this.maxOutputTokens,
  });

  factory MessageResponseRequest.fromJson(Map<String, dynamic> json) =>
      _$MessageResponseRequestFromJson(json);

  static const toJsonFactory = _$MessageResponseRequestToJson;
  Map<String, dynamic> toJson() => _$MessageResponseRequestToJson(this);

  @JsonKey(name: 'response_id', includeIfNull: false)
  final String responseId;
  @JsonKey(name: 'object', includeIfNull: false)
  final String? object;
  @JsonKey(name: 'created_at', includeIfNull: false)
  final DateTime? createdAt;
  @JsonKey(name: 'status', includeIfNull: false)
  final String? status;
  @JsonKey(name: 'error', includeIfNull: false)
  final String? error;
  @JsonKey(name: 'model_name', includeIfNull: false)
  final String? modelName;
  @JsonKey(name: 'parallel_tool_calls', includeIfNull: false)
  final bool? parallelToolCalls;
  @JsonKey(name: 'previous_response_id', includeIfNull: false)
  final String? previousResponseId;
  @JsonKey(name: 'instructions', includeIfNull: false)
  final String? instructions;
  @JsonKey(name: 'reasoning_effort', includeIfNull: false)
  final String? reasoningEffort;
  @JsonKey(name: 'reasoning_summary', includeIfNull: false)
  final String? reasoningSummary;
  @JsonKey(name: 'store', includeIfNull: false)
  final bool? store;
  @JsonKey(name: 'temperature', includeIfNull: false)
  final double? temperature;
  @JsonKey(name: 'text_format_type', includeIfNull: false)
  final String? textFormatType;
  @JsonKey(name: 'tool_choice', includeIfNull: false)
  final String? toolChoice;
  @JsonKey(name: 'tools', includeIfNull: false)
  final String? tools;
  @JsonKey(name: 'top_p', includeIfNull: false)
  final double? topP;
  @JsonKey(name: 'truncation', includeIfNull: false)
  final String? truncation;
  @JsonKey(name: 'usage_input_tokens', includeIfNull: false)
  final int? usageInputTokens;
  @JsonKey(name: 'usage_output_tokens', includeIfNull: false)
  final int? usageOutputTokens;
  @JsonKey(name: 'usage_total_tokens', includeIfNull: false)
  final int? usageTotalTokens;
  @JsonKey(name: 'metadata', includeIfNull: false)
  final dynamic metadata;
  @JsonKey(name: 'incomplete_details', includeIfNull: false)
  final String? incompleteDetails;
  @JsonKey(name: 'max_output_tokens', includeIfNull: false)
  final int? maxOutputTokens;
  static const fromJsonFactory = _$MessageResponseRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is MessageResponseRequest &&
            (identical(other.responseId, responseId) ||
                const DeepCollectionEquality().equals(
                  other.responseId,
                  responseId,
                )) &&
            (identical(other.object, object) ||
                const DeepCollectionEquality().equals(other.object, object)) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.error, error) ||
                const DeepCollectionEquality().equals(other.error, error)) &&
            (identical(other.modelName, modelName) ||
                const DeepCollectionEquality().equals(
                  other.modelName,
                  modelName,
                )) &&
            (identical(other.parallelToolCalls, parallelToolCalls) ||
                const DeepCollectionEquality().equals(
                  other.parallelToolCalls,
                  parallelToolCalls,
                )) &&
            (identical(other.previousResponseId, previousResponseId) ||
                const DeepCollectionEquality().equals(
                  other.previousResponseId,
                  previousResponseId,
                )) &&
            (identical(other.instructions, instructions) ||
                const DeepCollectionEquality().equals(
                  other.instructions,
                  instructions,
                )) &&
            (identical(other.reasoningEffort, reasoningEffort) ||
                const DeepCollectionEquality().equals(
                  other.reasoningEffort,
                  reasoningEffort,
                )) &&
            (identical(other.reasoningSummary, reasoningSummary) ||
                const DeepCollectionEquality().equals(
                  other.reasoningSummary,
                  reasoningSummary,
                )) &&
            (identical(other.store, store) ||
                const DeepCollectionEquality().equals(other.store, store)) &&
            (identical(other.temperature, temperature) ||
                const DeepCollectionEquality().equals(
                  other.temperature,
                  temperature,
                )) &&
            (identical(other.textFormatType, textFormatType) ||
                const DeepCollectionEquality().equals(
                  other.textFormatType,
                  textFormatType,
                )) &&
            (identical(other.toolChoice, toolChoice) ||
                const DeepCollectionEquality().equals(
                  other.toolChoice,
                  toolChoice,
                )) &&
            (identical(other.tools, tools) ||
                const DeepCollectionEquality().equals(other.tools, tools)) &&
            (identical(other.topP, topP) ||
                const DeepCollectionEquality().equals(other.topP, topP)) &&
            (identical(other.truncation, truncation) ||
                const DeepCollectionEquality().equals(
                  other.truncation,
                  truncation,
                )) &&
            (identical(other.usageInputTokens, usageInputTokens) ||
                const DeepCollectionEquality().equals(
                  other.usageInputTokens,
                  usageInputTokens,
                )) &&
            (identical(other.usageOutputTokens, usageOutputTokens) ||
                const DeepCollectionEquality().equals(
                  other.usageOutputTokens,
                  usageOutputTokens,
                )) &&
            (identical(other.usageTotalTokens, usageTotalTokens) ||
                const DeepCollectionEquality().equals(
                  other.usageTotalTokens,
                  usageTotalTokens,
                )) &&
            (identical(other.metadata, metadata) ||
                const DeepCollectionEquality().equals(
                  other.metadata,
                  metadata,
                )) &&
            (identical(other.incompleteDetails, incompleteDetails) ||
                const DeepCollectionEquality().equals(
                  other.incompleteDetails,
                  incompleteDetails,
                )) &&
            (identical(other.maxOutputTokens, maxOutputTokens) ||
                const DeepCollectionEquality().equals(
                  other.maxOutputTokens,
                  maxOutputTokens,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(responseId) ^
      const DeepCollectionEquality().hash(object) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(error) ^
      const DeepCollectionEquality().hash(modelName) ^
      const DeepCollectionEquality().hash(parallelToolCalls) ^
      const DeepCollectionEquality().hash(previousResponseId) ^
      const DeepCollectionEquality().hash(instructions) ^
      const DeepCollectionEquality().hash(reasoningEffort) ^
      const DeepCollectionEquality().hash(reasoningSummary) ^
      const DeepCollectionEquality().hash(store) ^
      const DeepCollectionEquality().hash(temperature) ^
      const DeepCollectionEquality().hash(textFormatType) ^
      const DeepCollectionEquality().hash(toolChoice) ^
      const DeepCollectionEquality().hash(tools) ^
      const DeepCollectionEquality().hash(topP) ^
      const DeepCollectionEquality().hash(truncation) ^
      const DeepCollectionEquality().hash(usageInputTokens) ^
      const DeepCollectionEquality().hash(usageOutputTokens) ^
      const DeepCollectionEquality().hash(usageTotalTokens) ^
      const DeepCollectionEquality().hash(metadata) ^
      const DeepCollectionEquality().hash(incompleteDetails) ^
      const DeepCollectionEquality().hash(maxOutputTokens) ^
      runtimeType.hashCode;
}

extension $MessageResponseRequestExtension on MessageResponseRequest {
  MessageResponseRequest copyWith({
    String? responseId,
    String? object,
    DateTime? createdAt,
    String? status,
    String? error,
    String? modelName,
    bool? parallelToolCalls,
    String? previousResponseId,
    String? instructions,
    String? reasoningEffort,
    String? reasoningSummary,
    bool? store,
    double? temperature,
    String? textFormatType,
    String? toolChoice,
    String? tools,
    double? topP,
    String? truncation,
    int? usageInputTokens,
    int? usageOutputTokens,
    int? usageTotalTokens,
    dynamic metadata,
    String? incompleteDetails,
    int? maxOutputTokens,
  }) {
    return MessageResponseRequest(
      responseId: responseId ?? this.responseId,
      object: object ?? this.object,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      error: error ?? this.error,
      modelName: modelName ?? this.modelName,
      parallelToolCalls: parallelToolCalls ?? this.parallelToolCalls,
      previousResponseId: previousResponseId ?? this.previousResponseId,
      instructions: instructions ?? this.instructions,
      reasoningEffort: reasoningEffort ?? this.reasoningEffort,
      reasoningSummary: reasoningSummary ?? this.reasoningSummary,
      store: store ?? this.store,
      temperature: temperature ?? this.temperature,
      textFormatType: textFormatType ?? this.textFormatType,
      toolChoice: toolChoice ?? this.toolChoice,
      tools: tools ?? this.tools,
      topP: topP ?? this.topP,
      truncation: truncation ?? this.truncation,
      usageInputTokens: usageInputTokens ?? this.usageInputTokens,
      usageOutputTokens: usageOutputTokens ?? this.usageOutputTokens,
      usageTotalTokens: usageTotalTokens ?? this.usageTotalTokens,
      metadata: metadata ?? this.metadata,
      incompleteDetails: incompleteDetails ?? this.incompleteDetails,
      maxOutputTokens: maxOutputTokens ?? this.maxOutputTokens,
    );
  }

  MessageResponseRequest copyWithWrapped({
    Wrapped<String>? responseId,
    Wrapped<String?>? object,
    Wrapped<DateTime?>? createdAt,
    Wrapped<String?>? status,
    Wrapped<String?>? error,
    Wrapped<String?>? modelName,
    Wrapped<bool?>? parallelToolCalls,
    Wrapped<String?>? previousResponseId,
    Wrapped<String?>? instructions,
    Wrapped<String?>? reasoningEffort,
    Wrapped<String?>? reasoningSummary,
    Wrapped<bool?>? store,
    Wrapped<double?>? temperature,
    Wrapped<String?>? textFormatType,
    Wrapped<String?>? toolChoice,
    Wrapped<String?>? tools,
    Wrapped<double?>? topP,
    Wrapped<String?>? truncation,
    Wrapped<int?>? usageInputTokens,
    Wrapped<int?>? usageOutputTokens,
    Wrapped<int?>? usageTotalTokens,
    Wrapped<dynamic>? metadata,
    Wrapped<String?>? incompleteDetails,
    Wrapped<int?>? maxOutputTokens,
  }) {
    return MessageResponseRequest(
      responseId: (responseId != null ? responseId.value : this.responseId),
      object: (object != null ? object.value : this.object),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      status: (status != null ? status.value : this.status),
      error: (error != null ? error.value : this.error),
      modelName: (modelName != null ? modelName.value : this.modelName),
      parallelToolCalls: (parallelToolCalls != null
          ? parallelToolCalls.value
          : this.parallelToolCalls),
      previousResponseId: (previousResponseId != null
          ? previousResponseId.value
          : this.previousResponseId),
      instructions: (instructions != null
          ? instructions.value
          : this.instructions),
      reasoningEffort: (reasoningEffort != null
          ? reasoningEffort.value
          : this.reasoningEffort),
      reasoningSummary: (reasoningSummary != null
          ? reasoningSummary.value
          : this.reasoningSummary),
      store: (store != null ? store.value : this.store),
      temperature: (temperature != null ? temperature.value : this.temperature),
      textFormatType: (textFormatType != null
          ? textFormatType.value
          : this.textFormatType),
      toolChoice: (toolChoice != null ? toolChoice.value : this.toolChoice),
      tools: (tools != null ? tools.value : this.tools),
      topP: (topP != null ? topP.value : this.topP),
      truncation: (truncation != null ? truncation.value : this.truncation),
      usageInputTokens: (usageInputTokens != null
          ? usageInputTokens.value
          : this.usageInputTokens),
      usageOutputTokens: (usageOutputTokens != null
          ? usageOutputTokens.value
          : this.usageOutputTokens),
      usageTotalTokens: (usageTotalTokens != null
          ? usageTotalTokens.value
          : this.usageTotalTokens),
      metadata: (metadata != null ? metadata.value : this.metadata),
      incompleteDetails: (incompleteDetails != null
          ? incompleteDetails.value
          : this.incompleteDetails),
      maxOutputTokens: (maxOutputTokens != null
          ? maxOutputTokens.value
          : this.maxOutputTokens),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class MessageWrite {
  const MessageWrite({
    this.messageId,
    this.userId,
    this.conversationId,
    this.requestId,
    this.responseId,
    this.outputId,
    this.timestamp,
    this.status,
    this.vote,
    this.hasImage,
    this.imgUrl,
    this.metadata,
    this.hasEmbedding,
    this.hasDocument,
    this.docUrl,
    this.request,
    this.response,
    this.output,
  });

  factory MessageWrite.fromJson(Map<String, dynamic> json) =>
      _$MessageWriteFromJson(json);

  static const toJsonFactory = _$MessageWriteToJson;
  Map<String, dynamic> toJson() => _$MessageWriteToJson(this);

  @JsonKey(name: 'message_id', includeIfNull: false)
  final String? messageId;
  @JsonKey(name: 'user_id', includeIfNull: false)
  final String? userId;
  @JsonKey(name: 'conversation_id', includeIfNull: false)
  final String? conversationId;
  @JsonKey(name: 'request_id', includeIfNull: false)
  final String? requestId;
  @JsonKey(name: 'response_id', includeIfNull: false)
  final String? responseId;
  @JsonKey(name: 'output_id', includeIfNull: false)
  final int? outputId;
  @JsonKey(name: 'timestamp', includeIfNull: false)
  final DateTime? timestamp;
  @JsonKey(
    name: 'status',
    includeIfNull: false,
    toJson: statusEnumNullableToJson,
    fromJson: statusEnumNullableFromJson,
  )
  final enums.StatusEnum? status;
  @JsonKey(name: 'vote', includeIfNull: false)
  final bool? vote;
  @JsonKey(name: 'has_image', includeIfNull: false)
  final bool? hasImage;
  @JsonKey(name: 'img_Url', includeIfNull: false)
  final String? imgUrl;
  @JsonKey(name: 'metadata', includeIfNull: false)
  final dynamic metadata;
  @JsonKey(name: 'has_embedding', includeIfNull: false)
  final bool? hasEmbedding;
  @JsonKey(name: 'has_document', includeIfNull: false)
  final bool? hasDocument;
  @JsonKey(name: 'doc_url', includeIfNull: false)
  final String? docUrl;
  @JsonKey(name: 'request', includeIfNull: false)
  final MessageRequest? request;
  @JsonKey(name: 'response', includeIfNull: false)
  final MessageResponse? response;
  @JsonKey(name: 'output', includeIfNull: false)
  final MessageOutput? output;
  static const fromJsonFactory = _$MessageWriteFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is MessageWrite &&
            (identical(other.messageId, messageId) ||
                const DeepCollectionEquality().equals(
                  other.messageId,
                  messageId,
                )) &&
            (identical(other.userId, userId) ||
                const DeepCollectionEquality().equals(other.userId, userId)) &&
            (identical(other.conversationId, conversationId) ||
                const DeepCollectionEquality().equals(
                  other.conversationId,
                  conversationId,
                )) &&
            (identical(other.requestId, requestId) ||
                const DeepCollectionEquality().equals(
                  other.requestId,
                  requestId,
                )) &&
            (identical(other.responseId, responseId) ||
                const DeepCollectionEquality().equals(
                  other.responseId,
                  responseId,
                )) &&
            (identical(other.outputId, outputId) ||
                const DeepCollectionEquality().equals(
                  other.outputId,
                  outputId,
                )) &&
            (identical(other.timestamp, timestamp) ||
                const DeepCollectionEquality().equals(
                  other.timestamp,
                  timestamp,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.vote, vote) ||
                const DeepCollectionEquality().equals(other.vote, vote)) &&
            (identical(other.hasImage, hasImage) ||
                const DeepCollectionEquality().equals(
                  other.hasImage,
                  hasImage,
                )) &&
            (identical(other.imgUrl, imgUrl) ||
                const DeepCollectionEquality().equals(other.imgUrl, imgUrl)) &&
            (identical(other.metadata, metadata) ||
                const DeepCollectionEquality().equals(
                  other.metadata,
                  metadata,
                )) &&
            (identical(other.hasEmbedding, hasEmbedding) ||
                const DeepCollectionEquality().equals(
                  other.hasEmbedding,
                  hasEmbedding,
                )) &&
            (identical(other.hasDocument, hasDocument) ||
                const DeepCollectionEquality().equals(
                  other.hasDocument,
                  hasDocument,
                )) &&
            (identical(other.docUrl, docUrl) ||
                const DeepCollectionEquality().equals(other.docUrl, docUrl)) &&
            (identical(other.request, request) ||
                const DeepCollectionEquality().equals(
                  other.request,
                  request,
                )) &&
            (identical(other.response, response) ||
                const DeepCollectionEquality().equals(
                  other.response,
                  response,
                )) &&
            (identical(other.output, output) ||
                const DeepCollectionEquality().equals(other.output, output)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(messageId) ^
      const DeepCollectionEquality().hash(userId) ^
      const DeepCollectionEquality().hash(conversationId) ^
      const DeepCollectionEquality().hash(requestId) ^
      const DeepCollectionEquality().hash(responseId) ^
      const DeepCollectionEquality().hash(outputId) ^
      const DeepCollectionEquality().hash(timestamp) ^
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(vote) ^
      const DeepCollectionEquality().hash(hasImage) ^
      const DeepCollectionEquality().hash(imgUrl) ^
      const DeepCollectionEquality().hash(metadata) ^
      const DeepCollectionEquality().hash(hasEmbedding) ^
      const DeepCollectionEquality().hash(hasDocument) ^
      const DeepCollectionEquality().hash(docUrl) ^
      const DeepCollectionEquality().hash(request) ^
      const DeepCollectionEquality().hash(response) ^
      const DeepCollectionEquality().hash(output) ^
      runtimeType.hashCode;
}

extension $MessageWriteExtension on MessageWrite {
  MessageWrite copyWith({
    String? messageId,
    String? userId,
    String? conversationId,
    String? requestId,
    String? responseId,
    int? outputId,
    DateTime? timestamp,
    enums.StatusEnum? status,
    bool? vote,
    bool? hasImage,
    String? imgUrl,
    dynamic metadata,
    bool? hasEmbedding,
    bool? hasDocument,
    String? docUrl,
    MessageRequest? request,
    MessageResponse? response,
    MessageOutput? output,
  }) {
    return MessageWrite(
      messageId: messageId ?? this.messageId,
      userId: userId ?? this.userId,
      conversationId: conversationId ?? this.conversationId,
      requestId: requestId ?? this.requestId,
      responseId: responseId ?? this.responseId,
      outputId: outputId ?? this.outputId,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      vote: vote ?? this.vote,
      hasImage: hasImage ?? this.hasImage,
      imgUrl: imgUrl ?? this.imgUrl,
      metadata: metadata ?? this.metadata,
      hasEmbedding: hasEmbedding ?? this.hasEmbedding,
      hasDocument: hasDocument ?? this.hasDocument,
      docUrl: docUrl ?? this.docUrl,
      request: request ?? this.request,
      response: response ?? this.response,
      output: output ?? this.output,
    );
  }

  MessageWrite copyWithWrapped({
    Wrapped<String?>? messageId,
    Wrapped<String?>? userId,
    Wrapped<String?>? conversationId,
    Wrapped<String?>? requestId,
    Wrapped<String?>? responseId,
    Wrapped<int?>? outputId,
    Wrapped<DateTime?>? timestamp,
    Wrapped<enums.StatusEnum?>? status,
    Wrapped<bool?>? vote,
    Wrapped<bool?>? hasImage,
    Wrapped<String?>? imgUrl,
    Wrapped<dynamic>? metadata,
    Wrapped<bool?>? hasEmbedding,
    Wrapped<bool?>? hasDocument,
    Wrapped<String?>? docUrl,
    Wrapped<MessageRequest?>? request,
    Wrapped<MessageResponse?>? response,
    Wrapped<MessageOutput?>? output,
  }) {
    return MessageWrite(
      messageId: (messageId != null ? messageId.value : this.messageId),
      userId: (userId != null ? userId.value : this.userId),
      conversationId: (conversationId != null
          ? conversationId.value
          : this.conversationId),
      requestId: (requestId != null ? requestId.value : this.requestId),
      responseId: (responseId != null ? responseId.value : this.responseId),
      outputId: (outputId != null ? outputId.value : this.outputId),
      timestamp: (timestamp != null ? timestamp.value : this.timestamp),
      status: (status != null ? status.value : this.status),
      vote: (vote != null ? vote.value : this.vote),
      hasImage: (hasImage != null ? hasImage.value : this.hasImage),
      imgUrl: (imgUrl != null ? imgUrl.value : this.imgUrl),
      metadata: (metadata != null ? metadata.value : this.metadata),
      hasEmbedding: (hasEmbedding != null
          ? hasEmbedding.value
          : this.hasEmbedding),
      hasDocument: (hasDocument != null ? hasDocument.value : this.hasDocument),
      docUrl: (docUrl != null ? docUrl.value : this.docUrl),
      request: (request != null ? request.value : this.request),
      response: (response != null ? response.value : this.response),
      output: (output != null ? output.value : this.output),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class MessageWriteRequest {
  const MessageWriteRequest({
    this.conversationId,
    this.requestId,
    this.responseId,
    this.outputId,
    this.status,
    this.vote,
    this.hasImage,
    this.imgUrl,
    this.metadata,
    this.hasEmbedding,
    this.hasDocument,
    this.docUrl,
  });

  factory MessageWriteRequest.fromJson(Map<String, dynamic> json) =>
      _$MessageWriteRequestFromJson(json);

  static const toJsonFactory = _$MessageWriteRequestToJson;
  Map<String, dynamic> toJson() => _$MessageWriteRequestToJson(this);

  @JsonKey(name: 'conversation_id', includeIfNull: false)
  final String? conversationId;
  @JsonKey(name: 'request_id', includeIfNull: false)
  final String? requestId;
  @JsonKey(name: 'response_id', includeIfNull: false)
  final String? responseId;
  @JsonKey(name: 'output_id', includeIfNull: false)
  final int? outputId;
  @JsonKey(
    name: 'status',
    includeIfNull: false,
    toJson: statusEnumNullableToJson,
    fromJson: statusEnumNullableFromJson,
  )
  final enums.StatusEnum? status;
  @JsonKey(name: 'vote', includeIfNull: false)
  final bool? vote;
  @JsonKey(name: 'has_image', includeIfNull: false)
  final bool? hasImage;
  @JsonKey(name: 'img_Url', includeIfNull: false)
  final String? imgUrl;
  @JsonKey(name: 'metadata', includeIfNull: false)
  final dynamic metadata;
  @JsonKey(name: 'has_embedding', includeIfNull: false)
  final bool? hasEmbedding;
  @JsonKey(name: 'has_document', includeIfNull: false)
  final bool? hasDocument;
  @JsonKey(name: 'doc_url', includeIfNull: false)
  final String? docUrl;
  static const fromJsonFactory = _$MessageWriteRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is MessageWriteRequest &&
            (identical(other.conversationId, conversationId) ||
                const DeepCollectionEquality().equals(
                  other.conversationId,
                  conversationId,
                )) &&
            (identical(other.requestId, requestId) ||
                const DeepCollectionEquality().equals(
                  other.requestId,
                  requestId,
                )) &&
            (identical(other.responseId, responseId) ||
                const DeepCollectionEquality().equals(
                  other.responseId,
                  responseId,
                )) &&
            (identical(other.outputId, outputId) ||
                const DeepCollectionEquality().equals(
                  other.outputId,
                  outputId,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.vote, vote) ||
                const DeepCollectionEquality().equals(other.vote, vote)) &&
            (identical(other.hasImage, hasImage) ||
                const DeepCollectionEquality().equals(
                  other.hasImage,
                  hasImage,
                )) &&
            (identical(other.imgUrl, imgUrl) ||
                const DeepCollectionEquality().equals(other.imgUrl, imgUrl)) &&
            (identical(other.metadata, metadata) ||
                const DeepCollectionEquality().equals(
                  other.metadata,
                  metadata,
                )) &&
            (identical(other.hasEmbedding, hasEmbedding) ||
                const DeepCollectionEquality().equals(
                  other.hasEmbedding,
                  hasEmbedding,
                )) &&
            (identical(other.hasDocument, hasDocument) ||
                const DeepCollectionEquality().equals(
                  other.hasDocument,
                  hasDocument,
                )) &&
            (identical(other.docUrl, docUrl) ||
                const DeepCollectionEquality().equals(other.docUrl, docUrl)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(conversationId) ^
      const DeepCollectionEquality().hash(requestId) ^
      const DeepCollectionEquality().hash(responseId) ^
      const DeepCollectionEquality().hash(outputId) ^
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(vote) ^
      const DeepCollectionEquality().hash(hasImage) ^
      const DeepCollectionEquality().hash(imgUrl) ^
      const DeepCollectionEquality().hash(metadata) ^
      const DeepCollectionEquality().hash(hasEmbedding) ^
      const DeepCollectionEquality().hash(hasDocument) ^
      const DeepCollectionEquality().hash(docUrl) ^
      runtimeType.hashCode;
}

extension $MessageWriteRequestExtension on MessageWriteRequest {
  MessageWriteRequest copyWith({
    String? conversationId,
    String? requestId,
    String? responseId,
    int? outputId,
    enums.StatusEnum? status,
    bool? vote,
    bool? hasImage,
    String? imgUrl,
    dynamic metadata,
    bool? hasEmbedding,
    bool? hasDocument,
    String? docUrl,
  }) {
    return MessageWriteRequest(
      conversationId: conversationId ?? this.conversationId,
      requestId: requestId ?? this.requestId,
      responseId: responseId ?? this.responseId,
      outputId: outputId ?? this.outputId,
      status: status ?? this.status,
      vote: vote ?? this.vote,
      hasImage: hasImage ?? this.hasImage,
      imgUrl: imgUrl ?? this.imgUrl,
      metadata: metadata ?? this.metadata,
      hasEmbedding: hasEmbedding ?? this.hasEmbedding,
      hasDocument: hasDocument ?? this.hasDocument,
      docUrl: docUrl ?? this.docUrl,
    );
  }

  MessageWriteRequest copyWithWrapped({
    Wrapped<String?>? conversationId,
    Wrapped<String?>? requestId,
    Wrapped<String?>? responseId,
    Wrapped<int?>? outputId,
    Wrapped<enums.StatusEnum?>? status,
    Wrapped<bool?>? vote,
    Wrapped<bool?>? hasImage,
    Wrapped<String?>? imgUrl,
    Wrapped<dynamic>? metadata,
    Wrapped<bool?>? hasEmbedding,
    Wrapped<bool?>? hasDocument,
    Wrapped<String?>? docUrl,
  }) {
    return MessageWriteRequest(
      conversationId: (conversationId != null
          ? conversationId.value
          : this.conversationId),
      requestId: (requestId != null ? requestId.value : this.requestId),
      responseId: (responseId != null ? responseId.value : this.responseId),
      outputId: (outputId != null ? outputId.value : this.outputId),
      status: (status != null ? status.value : this.status),
      vote: (vote != null ? vote.value : this.vote),
      hasImage: (hasImage != null ? hasImage.value : this.hasImage),
      imgUrl: (imgUrl != null ? imgUrl.value : this.imgUrl),
      metadata: (metadata != null ? metadata.value : this.metadata),
      hasEmbedding: (hasEmbedding != null
          ? hasEmbedding.value
          : this.hasEmbedding),
      hasDocument: (hasDocument != null ? hasDocument.value : this.hasDocument),
      docUrl: (docUrl != null ? docUrl.value : this.docUrl),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class OAuthCallbackResponse {
  const OAuthCallbackResponse({
    required this.message,
    required this.userId,
    this.username,
    required this.accessToken,
    required this.refreshToken,
    this.providerScope,
    this.providerExpiresAt,
    this.providerAccessToken,
    this.providerRefreshToken,
    this.providerTokenType,
    this.idToken,
    this.email,
    this.emailVerified,
    this.isGoogleUser,
    this.isOpenrouterUser,
    this.isGithubUser,
    this.isMsUser,
  });

  factory OAuthCallbackResponse.fromJson(Map<String, dynamic> json) =>
      _$OAuthCallbackResponseFromJson(json);

  static const toJsonFactory = _$OAuthCallbackResponseToJson;
  Map<String, dynamic> toJson() => _$OAuthCallbackResponseToJson(this);

  @JsonKey(name: 'message', includeIfNull: false)
  final String message;
  @JsonKey(name: 'user_id', includeIfNull: false)
  final String userId;
  @JsonKey(name: 'username', includeIfNull: false)
  final String? username;
  @JsonKey(name: 'access_token', includeIfNull: false)
  final String accessToken;
  @JsonKey(name: 'refresh_token', includeIfNull: false)
  final String refreshToken;
  @JsonKey(name: 'provider_scope', includeIfNull: false)
  final String? providerScope;
  @JsonKey(name: 'provider_expires_at', includeIfNull: false)
  final String? providerExpiresAt;
  @JsonKey(name: 'provider_access_token', includeIfNull: false)
  final String? providerAccessToken;
  @JsonKey(name: 'provider_refresh_token', includeIfNull: false)
  final String? providerRefreshToken;
  @JsonKey(name: 'provider_token_type', includeIfNull: false)
  final String? providerTokenType;
  @JsonKey(name: 'id_token', includeIfNull: false)
  final String? idToken;
  @JsonKey(name: 'email', includeIfNull: false)
  final String? email;
  @JsonKey(name: 'email_verified', includeIfNull: false)
  final bool? emailVerified;
  @JsonKey(name: 'is_google_user', includeIfNull: false)
  final bool? isGoogleUser;
  @JsonKey(name: 'is_openrouter_user', includeIfNull: false)
  final bool? isOpenrouterUser;
  @JsonKey(name: 'is_github_user', includeIfNull: false)
  final bool? isGithubUser;
  @JsonKey(name: 'is_ms_user', includeIfNull: false)
  final bool? isMsUser;
  static const fromJsonFactory = _$OAuthCallbackResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is OAuthCallbackResponse &&
            (identical(other.message, message) ||
                const DeepCollectionEquality().equals(
                  other.message,
                  message,
                )) &&
            (identical(other.userId, userId) ||
                const DeepCollectionEquality().equals(other.userId, userId)) &&
            (identical(other.username, username) ||
                const DeepCollectionEquality().equals(
                  other.username,
                  username,
                )) &&
            (identical(other.accessToken, accessToken) ||
                const DeepCollectionEquality().equals(
                  other.accessToken,
                  accessToken,
                )) &&
            (identical(other.refreshToken, refreshToken) ||
                const DeepCollectionEquality().equals(
                  other.refreshToken,
                  refreshToken,
                )) &&
            (identical(other.providerScope, providerScope) ||
                const DeepCollectionEquality().equals(
                  other.providerScope,
                  providerScope,
                )) &&
            (identical(other.providerExpiresAt, providerExpiresAt) ||
                const DeepCollectionEquality().equals(
                  other.providerExpiresAt,
                  providerExpiresAt,
                )) &&
            (identical(other.providerAccessToken, providerAccessToken) ||
                const DeepCollectionEquality().equals(
                  other.providerAccessToken,
                  providerAccessToken,
                )) &&
            (identical(other.providerRefreshToken, providerRefreshToken) ||
                const DeepCollectionEquality().equals(
                  other.providerRefreshToken,
                  providerRefreshToken,
                )) &&
            (identical(other.providerTokenType, providerTokenType) ||
                const DeepCollectionEquality().equals(
                  other.providerTokenType,
                  providerTokenType,
                )) &&
            (identical(other.idToken, idToken) ||
                const DeepCollectionEquality().equals(
                  other.idToken,
                  idToken,
                )) &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.emailVerified, emailVerified) ||
                const DeepCollectionEquality().equals(
                  other.emailVerified,
                  emailVerified,
                )) &&
            (identical(other.isGoogleUser, isGoogleUser) ||
                const DeepCollectionEquality().equals(
                  other.isGoogleUser,
                  isGoogleUser,
                )) &&
            (identical(other.isOpenrouterUser, isOpenrouterUser) ||
                const DeepCollectionEquality().equals(
                  other.isOpenrouterUser,
                  isOpenrouterUser,
                )) &&
            (identical(other.isGithubUser, isGithubUser) ||
                const DeepCollectionEquality().equals(
                  other.isGithubUser,
                  isGithubUser,
                )) &&
            (identical(other.isMsUser, isMsUser) ||
                const DeepCollectionEquality().equals(
                  other.isMsUser,
                  isMsUser,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(message) ^
      const DeepCollectionEquality().hash(userId) ^
      const DeepCollectionEquality().hash(username) ^
      const DeepCollectionEquality().hash(accessToken) ^
      const DeepCollectionEquality().hash(refreshToken) ^
      const DeepCollectionEquality().hash(providerScope) ^
      const DeepCollectionEquality().hash(providerExpiresAt) ^
      const DeepCollectionEquality().hash(providerAccessToken) ^
      const DeepCollectionEquality().hash(providerRefreshToken) ^
      const DeepCollectionEquality().hash(providerTokenType) ^
      const DeepCollectionEquality().hash(idToken) ^
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(emailVerified) ^
      const DeepCollectionEquality().hash(isGoogleUser) ^
      const DeepCollectionEquality().hash(isOpenrouterUser) ^
      const DeepCollectionEquality().hash(isGithubUser) ^
      const DeepCollectionEquality().hash(isMsUser) ^
      runtimeType.hashCode;
}

extension $OAuthCallbackResponseExtension on OAuthCallbackResponse {
  OAuthCallbackResponse copyWith({
    String? message,
    String? userId,
    String? username,
    String? accessToken,
    String? refreshToken,
    String? providerScope,
    String? providerExpiresAt,
    String? providerAccessToken,
    String? providerRefreshToken,
    String? providerTokenType,
    String? idToken,
    String? email,
    bool? emailVerified,
    bool? isGoogleUser,
    bool? isOpenrouterUser,
    bool? isGithubUser,
    bool? isMsUser,
  }) {
    return OAuthCallbackResponse(
      message: message ?? this.message,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      providerScope: providerScope ?? this.providerScope,
      providerExpiresAt: providerExpiresAt ?? this.providerExpiresAt,
      providerAccessToken: providerAccessToken ?? this.providerAccessToken,
      providerRefreshToken: providerRefreshToken ?? this.providerRefreshToken,
      providerTokenType: providerTokenType ?? this.providerTokenType,
      idToken: idToken ?? this.idToken,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      isGoogleUser: isGoogleUser ?? this.isGoogleUser,
      isOpenrouterUser: isOpenrouterUser ?? this.isOpenrouterUser,
      isGithubUser: isGithubUser ?? this.isGithubUser,
      isMsUser: isMsUser ?? this.isMsUser,
    );
  }

  OAuthCallbackResponse copyWithWrapped({
    Wrapped<String>? message,
    Wrapped<String>? userId,
    Wrapped<String?>? username,
    Wrapped<String>? accessToken,
    Wrapped<String>? refreshToken,
    Wrapped<String?>? providerScope,
    Wrapped<String?>? providerExpiresAt,
    Wrapped<String?>? providerAccessToken,
    Wrapped<String?>? providerRefreshToken,
    Wrapped<String?>? providerTokenType,
    Wrapped<String?>? idToken,
    Wrapped<String?>? email,
    Wrapped<bool?>? emailVerified,
    Wrapped<bool?>? isGoogleUser,
    Wrapped<bool?>? isOpenrouterUser,
    Wrapped<bool?>? isGithubUser,
    Wrapped<bool?>? isMsUser,
  }) {
    return OAuthCallbackResponse(
      message: (message != null ? message.value : this.message),
      userId: (userId != null ? userId.value : this.userId),
      username: (username != null ? username.value : this.username),
      accessToken: (accessToken != null ? accessToken.value : this.accessToken),
      refreshToken: (refreshToken != null
          ? refreshToken.value
          : this.refreshToken),
      providerScope: (providerScope != null
          ? providerScope.value
          : this.providerScope),
      providerExpiresAt: (providerExpiresAt != null
          ? providerExpiresAt.value
          : this.providerExpiresAt),
      providerAccessToken: (providerAccessToken != null
          ? providerAccessToken.value
          : this.providerAccessToken),
      providerRefreshToken: (providerRefreshToken != null
          ? providerRefreshToken.value
          : this.providerRefreshToken),
      providerTokenType: (providerTokenType != null
          ? providerTokenType.value
          : this.providerTokenType),
      idToken: (idToken != null ? idToken.value : this.idToken),
      email: (email != null ? email.value : this.email),
      emailVerified: (emailVerified != null
          ? emailVerified.value
          : this.emailVerified),
      isGoogleUser: (isGoogleUser != null
          ? isGoogleUser.value
          : this.isGoogleUser),
      isOpenrouterUser: (isOpenrouterUser != null
          ? isOpenrouterUser.value
          : this.isOpenrouterUser),
      isGithubUser: (isGithubUser != null
          ? isGithubUser.value
          : this.isGithubUser),
      isMsUser: (isMsUser != null ? isMsUser.value : this.isMsUser),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class PaginatedAttachmentUploadList {
  const PaginatedAttachmentUploadList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedAttachmentUploadList.fromJson(Map<String, dynamic> json) =>
      _$PaginatedAttachmentUploadListFromJson(json);

  static const toJsonFactory = _$PaginatedAttachmentUploadListToJson;
  Map<String, dynamic> toJson() => _$PaginatedAttachmentUploadListToJson(this);

  @JsonKey(name: 'count', includeIfNull: false)
  final int count;
  @JsonKey(name: 'next', includeIfNull: false)
  final String? next;
  @JsonKey(name: 'previous', includeIfNull: false)
  final String? previous;
  @JsonKey(
    name: 'results',
    includeIfNull: false,
    defaultValue: <AttachmentUpload>[],
  )
  final List<AttachmentUpload> results;
  static const fromJsonFactory = _$PaginatedAttachmentUploadListFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PaginatedAttachmentUploadList &&
            (identical(other.count, count) ||
                const DeepCollectionEquality().equals(other.count, count)) &&
            (identical(other.next, next) ||
                const DeepCollectionEquality().equals(other.next, next)) &&
            (identical(other.previous, previous) ||
                const DeepCollectionEquality().equals(
                  other.previous,
                  previous,
                )) &&
            (identical(other.results, results) ||
                const DeepCollectionEquality().equals(other.results, results)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(count) ^
      const DeepCollectionEquality().hash(next) ^
      const DeepCollectionEquality().hash(previous) ^
      const DeepCollectionEquality().hash(results) ^
      runtimeType.hashCode;
}

extension $PaginatedAttachmentUploadListExtension
    on PaginatedAttachmentUploadList {
  PaginatedAttachmentUploadList copyWith({
    int? count,
    String? next,
    String? previous,
    List<AttachmentUpload>? results,
  }) {
    return PaginatedAttachmentUploadList(
      count: count ?? this.count,
      next: next ?? this.next,
      previous: previous ?? this.previous,
      results: results ?? this.results,
    );
  }

  PaginatedAttachmentUploadList copyWithWrapped({
    Wrapped<int>? count,
    Wrapped<String?>? next,
    Wrapped<String?>? previous,
    Wrapped<List<AttachmentUpload>>? results,
  }) {
    return PaginatedAttachmentUploadList(
      count: (count != null ? count.value : this.count),
      next: (next != null ? next.value : this.next),
      previous: (previous != null ? previous.value : this.previous),
      results: (results != null ? results.value : this.results),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class PaginatedConversationList {
  const PaginatedConversationList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedConversationList.fromJson(Map<String, dynamic> json) =>
      _$PaginatedConversationListFromJson(json);

  static const toJsonFactory = _$PaginatedConversationListToJson;
  Map<String, dynamic> toJson() => _$PaginatedConversationListToJson(this);

  @JsonKey(name: 'count', includeIfNull: false)
  final int count;
  @JsonKey(name: 'next', includeIfNull: false)
  final String? next;
  @JsonKey(name: 'previous', includeIfNull: false)
  final String? previous;
  @JsonKey(
    name: 'results',
    includeIfNull: false,
    defaultValue: <Conversation>[],
  )
  final List<Conversation> results;
  static const fromJsonFactory = _$PaginatedConversationListFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PaginatedConversationList &&
            (identical(other.count, count) ||
                const DeepCollectionEquality().equals(other.count, count)) &&
            (identical(other.next, next) ||
                const DeepCollectionEquality().equals(other.next, next)) &&
            (identical(other.previous, previous) ||
                const DeepCollectionEquality().equals(
                  other.previous,
                  previous,
                )) &&
            (identical(other.results, results) ||
                const DeepCollectionEquality().equals(other.results, results)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(count) ^
      const DeepCollectionEquality().hash(next) ^
      const DeepCollectionEquality().hash(previous) ^
      const DeepCollectionEquality().hash(results) ^
      runtimeType.hashCode;
}

extension $PaginatedConversationListExtension on PaginatedConversationList {
  PaginatedConversationList copyWith({
    int? count,
    String? next,
    String? previous,
    List<Conversation>? results,
  }) {
    return PaginatedConversationList(
      count: count ?? this.count,
      next: next ?? this.next,
      previous: previous ?? this.previous,
      results: results ?? this.results,
    );
  }

  PaginatedConversationList copyWithWrapped({
    Wrapped<int>? count,
    Wrapped<String?>? next,
    Wrapped<String?>? previous,
    Wrapped<List<Conversation>>? results,
  }) {
    return PaginatedConversationList(
      count: (count != null ? count.value : this.count),
      next: (next != null ? next.value : this.next),
      previous: (previous != null ? previous.value : this.previous),
      results: (results != null ? results.value : this.results),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class PaginatedMessageList {
  const PaginatedMessageList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedMessageList.fromJson(Map<String, dynamic> json) =>
      _$PaginatedMessageListFromJson(json);

  static const toJsonFactory = _$PaginatedMessageListToJson;
  Map<String, dynamic> toJson() => _$PaginatedMessageListToJson(this);

  @JsonKey(name: 'count', includeIfNull: false)
  final int count;
  @JsonKey(name: 'next', includeIfNull: false)
  final String? next;
  @JsonKey(name: 'previous', includeIfNull: false)
  final String? previous;
  @JsonKey(name: 'results', includeIfNull: false, defaultValue: <Message>[])
  final List<Message> results;
  static const fromJsonFactory = _$PaginatedMessageListFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PaginatedMessageList &&
            (identical(other.count, count) ||
                const DeepCollectionEquality().equals(other.count, count)) &&
            (identical(other.next, next) ||
                const DeepCollectionEquality().equals(other.next, next)) &&
            (identical(other.previous, previous) ||
                const DeepCollectionEquality().equals(
                  other.previous,
                  previous,
                )) &&
            (identical(other.results, results) ||
                const DeepCollectionEquality().equals(other.results, results)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(count) ^
      const DeepCollectionEquality().hash(next) ^
      const DeepCollectionEquality().hash(previous) ^
      const DeepCollectionEquality().hash(results) ^
      runtimeType.hashCode;
}

extension $PaginatedMessageListExtension on PaginatedMessageList {
  PaginatedMessageList copyWith({
    int? count,
    String? next,
    String? previous,
    List<Message>? results,
  }) {
    return PaginatedMessageList(
      count: count ?? this.count,
      next: next ?? this.next,
      previous: previous ?? this.previous,
      results: results ?? this.results,
    );
  }

  PaginatedMessageList copyWithWrapped({
    Wrapped<int>? count,
    Wrapped<String?>? next,
    Wrapped<String?>? previous,
    Wrapped<List<Message>>? results,
  }) {
    return PaginatedMessageList(
      count: (count != null ? count.value : this.count),
      next: (next != null ? next.value : this.next),
      previous: (previous != null ? previous.value : this.previous),
      results: (results != null ? results.value : this.results),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class PatchedConversationRequest {
  const PatchedConversationRequest({this.title, this.localOnly});

  factory PatchedConversationRequest.fromJson(Map<String, dynamic> json) =>
      _$PatchedConversationRequestFromJson(json);

  static const toJsonFactory = _$PatchedConversationRequestToJson;
  Map<String, dynamic> toJson() => _$PatchedConversationRequestToJson(this);

  @JsonKey(name: 'title', includeIfNull: false)
  final String? title;
  @JsonKey(name: 'local_only', includeIfNull: false)
  final bool? localOnly;
  static const fromJsonFactory = _$PatchedConversationRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PatchedConversationRequest &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.localOnly, localOnly) ||
                const DeepCollectionEquality().equals(
                  other.localOnly,
                  localOnly,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(localOnly) ^
      runtimeType.hashCode;
}

extension $PatchedConversationRequestExtension on PatchedConversationRequest {
  PatchedConversationRequest copyWith({String? title, bool? localOnly}) {
    return PatchedConversationRequest(
      title: title ?? this.title,
      localOnly: localOnly ?? this.localOnly,
    );
  }

  PatchedConversationRequest copyWithWrapped({
    Wrapped<String?>? title,
    Wrapped<bool?>? localOnly,
  }) {
    return PatchedConversationRequest(
      title: (title != null ? title.value : this.title),
      localOnly: (localOnly != null ? localOnly.value : this.localOnly),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class PatchedProfileRequest {
  const PatchedProfileRequest({
    this.username,
    this.email,
    this.phoneNumber,
    this.biometricEnabled,
  });

  factory PatchedProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$PatchedProfileRequestFromJson(json);

  static const toJsonFactory = _$PatchedProfileRequestToJson;
  Map<String, dynamic> toJson() => _$PatchedProfileRequestToJson(this);

  @JsonKey(name: 'username', includeIfNull: false)
  final String? username;
  @JsonKey(name: 'email', includeIfNull: false)
  final String? email;
  @JsonKey(name: 'phone_number', includeIfNull: false)
  final String? phoneNumber;
  @JsonKey(name: 'biometric_enabled', includeIfNull: false)
  final bool? biometricEnabled;
  static const fromJsonFactory = _$PatchedProfileRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PatchedProfileRequest &&
            (identical(other.username, username) ||
                const DeepCollectionEquality().equals(
                  other.username,
                  username,
                )) &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.phoneNumber, phoneNumber) ||
                const DeepCollectionEquality().equals(
                  other.phoneNumber,
                  phoneNumber,
                )) &&
            (identical(other.biometricEnabled, biometricEnabled) ||
                const DeepCollectionEquality().equals(
                  other.biometricEnabled,
                  biometricEnabled,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(username) ^
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(phoneNumber) ^
      const DeepCollectionEquality().hash(biometricEnabled) ^
      runtimeType.hashCode;
}

extension $PatchedProfileRequestExtension on PatchedProfileRequest {
  PatchedProfileRequest copyWith({
    String? username,
    String? email,
    String? phoneNumber,
    bool? biometricEnabled,
  }) {
    return PatchedProfileRequest(
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );
  }

  PatchedProfileRequest copyWithWrapped({
    Wrapped<String?>? username,
    Wrapped<String?>? email,
    Wrapped<String?>? phoneNumber,
    Wrapped<bool?>? biometricEnabled,
  }) {
    return PatchedProfileRequest(
      username: (username != null ? username.value : this.username),
      email: (email != null ? email.value : this.email),
      phoneNumber: (phoneNumber != null ? phoneNumber.value : this.phoneNumber),
      biometricEnabled: (biometricEnabled != null
          ? biometricEnabled.value
          : this.biometricEnabled),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class Profile {
  const Profile({
    this.userId,
    required this.username,
    required this.email,
    this.phoneNumber,
    this.biometricEnabled,
  });

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  static const toJsonFactory = _$ProfileToJson;
  Map<String, dynamic> toJson() => _$ProfileToJson(this);

  @JsonKey(name: 'user_id', includeIfNull: false)
  final String? userId;
  @JsonKey(name: 'username', includeIfNull: false)
  final String username;
  @JsonKey(name: 'email', includeIfNull: false)
  final String email;
  @JsonKey(name: 'phone_number', includeIfNull: false)
  final String? phoneNumber;
  @JsonKey(name: 'biometric_enabled', includeIfNull: false)
  final bool? biometricEnabled;
  static const fromJsonFactory = _$ProfileFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Profile &&
            (identical(other.userId, userId) ||
                const DeepCollectionEquality().equals(other.userId, userId)) &&
            (identical(other.username, username) ||
                const DeepCollectionEquality().equals(
                  other.username,
                  username,
                )) &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.phoneNumber, phoneNumber) ||
                const DeepCollectionEquality().equals(
                  other.phoneNumber,
                  phoneNumber,
                )) &&
            (identical(other.biometricEnabled, biometricEnabled) ||
                const DeepCollectionEquality().equals(
                  other.biometricEnabled,
                  biometricEnabled,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(userId) ^
      const DeepCollectionEquality().hash(username) ^
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(phoneNumber) ^
      const DeepCollectionEquality().hash(biometricEnabled) ^
      runtimeType.hashCode;
}

extension $ProfileExtension on Profile {
  Profile copyWith({
    String? userId,
    String? username,
    String? email,
    String? phoneNumber,
    bool? biometricEnabled,
  }) {
    return Profile(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );
  }

  Profile copyWithWrapped({
    Wrapped<String?>? userId,
    Wrapped<String>? username,
    Wrapped<String>? email,
    Wrapped<String?>? phoneNumber,
    Wrapped<bool?>? biometricEnabled,
  }) {
    return Profile(
      userId: (userId != null ? userId.value : this.userId),
      username: (username != null ? username.value : this.username),
      email: (email != null ? email.value : this.email),
      phoneNumber: (phoneNumber != null ? phoneNumber.value : this.phoneNumber),
      biometricEnabled: (biometricEnabled != null
          ? biometricEnabled.value
          : this.biometricEnabled),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class RegisterRequest {
  const RegisterRequest({
    required this.username,
    this.email,
    this.userPassword,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);

  static const toJsonFactory = _$RegisterRequestToJson;
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);

  @JsonKey(name: 'username', includeIfNull: false)
  final String username;
  @JsonKey(name: 'email', includeIfNull: false)
  final String? email;
  @JsonKey(name: 'user_password', includeIfNull: false)
  final dynamic userPassword;
  static const fromJsonFactory = _$RegisterRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is RegisterRequest &&
            (identical(other.username, username) ||
                const DeepCollectionEquality().equals(
                  other.username,
                  username,
                )) &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.userPassword, userPassword) ||
                const DeepCollectionEquality().equals(
                  other.userPassword,
                  userPassword,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(username) ^
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(userPassword) ^
      runtimeType.hashCode;
}

extension $RegisterRequestExtension on RegisterRequest {
  RegisterRequest copyWith({
    String? username,
    String? email,
    dynamic userPassword,
  }) {
    return RegisterRequest(
      username: username ?? this.username,
      email: email ?? this.email,
      userPassword: userPassword ?? this.userPassword,
    );
  }

  RegisterRequest copyWithWrapped({
    Wrapped<String>? username,
    Wrapped<String?>? email,
    Wrapped<dynamic>? userPassword,
  }) {
    return RegisterRequest(
      username: (username != null ? username.value : this.username),
      email: (email != null ? email.value : this.email),
      userPassword: (userPassword != null
          ? userPassword.value
          : this.userPassword),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class RegisterResponse {
  const RegisterResponse({
    required this.message,
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    required this.email,
    required this.onboarding,
    required this.conversations,
    this.tempId,
    this.deviceId,
    this.relatedDevices,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseFromJson(json);

  static const toJsonFactory = _$RegisterResponseToJson;
  Map<String, dynamic> toJson() => _$RegisterResponseToJson(this);

  @JsonKey(name: 'message', includeIfNull: false)
  final String message;
  @JsonKey(name: 'user_id', includeIfNull: false)
  final String userId;
  @JsonKey(name: 'access_token', includeIfNull: false)
  final String accessToken;
  @JsonKey(name: 'refresh_token', includeIfNull: false)
  final String refreshToken;
  @JsonKey(name: 'email', includeIfNull: false)
  final String email;
  @JsonKey(name: 'onboarding', includeIfNull: false)
  final bool onboarding;
  @JsonKey(
    name: 'conversations',
    includeIfNull: false,
    defaultValue: <ConversationDoc>[],
  )
  final List<ConversationDoc> conversations;
  @JsonKey(name: 'temp_id', includeIfNull: false)
  final String? tempId;
  @JsonKey(name: 'device_id', includeIfNull: false)
  final String? deviceId;
  @JsonKey(
    name: 'related_devices',
    includeIfNull: false,
    defaultValue: <String>[],
  )
  final List<String>? relatedDevices;
  static const fromJsonFactory = _$RegisterResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is RegisterResponse &&
            (identical(other.message, message) ||
                const DeepCollectionEquality().equals(
                  other.message,
                  message,
                )) &&
            (identical(other.userId, userId) ||
                const DeepCollectionEquality().equals(other.userId, userId)) &&
            (identical(other.accessToken, accessToken) ||
                const DeepCollectionEquality().equals(
                  other.accessToken,
                  accessToken,
                )) &&
            (identical(other.refreshToken, refreshToken) ||
                const DeepCollectionEquality().equals(
                  other.refreshToken,
                  refreshToken,
                )) &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.onboarding, onboarding) ||
                const DeepCollectionEquality().equals(
                  other.onboarding,
                  onboarding,
                )) &&
            (identical(other.conversations, conversations) ||
                const DeepCollectionEquality().equals(
                  other.conversations,
                  conversations,
                )) &&
            (identical(other.tempId, tempId) ||
                const DeepCollectionEquality().equals(other.tempId, tempId)) &&
            (identical(other.deviceId, deviceId) ||
                const DeepCollectionEquality().equals(
                  other.deviceId,
                  deviceId,
                )) &&
            (identical(other.relatedDevices, relatedDevices) ||
                const DeepCollectionEquality().equals(
                  other.relatedDevices,
                  relatedDevices,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(message) ^
      const DeepCollectionEquality().hash(userId) ^
      const DeepCollectionEquality().hash(accessToken) ^
      const DeepCollectionEquality().hash(refreshToken) ^
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(onboarding) ^
      const DeepCollectionEquality().hash(conversations) ^
      const DeepCollectionEquality().hash(tempId) ^
      const DeepCollectionEquality().hash(deviceId) ^
      const DeepCollectionEquality().hash(relatedDevices) ^
      runtimeType.hashCode;
}

extension $RegisterResponseExtension on RegisterResponse {
  RegisterResponse copyWith({
    String? message,
    String? userId,
    String? accessToken,
    String? refreshToken,
    String? email,
    bool? onboarding,
    List<ConversationDoc>? conversations,
    String? tempId,
    String? deviceId,
    List<String>? relatedDevices,
  }) {
    return RegisterResponse(
      message: message ?? this.message,
      userId: userId ?? this.userId,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      email: email ?? this.email,
      onboarding: onboarding ?? this.onboarding,
      conversations: conversations ?? this.conversations,
      tempId: tempId ?? this.tempId,
      deviceId: deviceId ?? this.deviceId,
      relatedDevices: relatedDevices ?? this.relatedDevices,
    );
  }

  RegisterResponse copyWithWrapped({
    Wrapped<String>? message,
    Wrapped<String>? userId,
    Wrapped<String>? accessToken,
    Wrapped<String>? refreshToken,
    Wrapped<String>? email,
    Wrapped<bool>? onboarding,
    Wrapped<List<ConversationDoc>>? conversations,
    Wrapped<String?>? tempId,
    Wrapped<String?>? deviceId,
    Wrapped<List<String>?>? relatedDevices,
  }) {
    return RegisterResponse(
      message: (message != null ? message.value : this.message),
      userId: (userId != null ? userId.value : this.userId),
      accessToken: (accessToken != null ? accessToken.value : this.accessToken),
      refreshToken: (refreshToken != null
          ? refreshToken.value
          : this.refreshToken),
      email: (email != null ? email.value : this.email),
      onboarding: (onboarding != null ? onboarding.value : this.onboarding),
      conversations: (conversations != null
          ? conversations.value
          : this.conversations),
      tempId: (tempId != null ? tempId.value : this.tempId),
      deviceId: (deviceId != null ? deviceId.value : this.deviceId),
      relatedDevices: (relatedDevices != null
          ? relatedDevices.value
          : this.relatedDevices),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class SetPasswordAfterEmailVerifyRequestRequest {
  const SetPasswordAfterEmailVerifyRequestRequest({
    required this.email,
    required this.password,
  });

  factory SetPasswordAfterEmailVerifyRequestRequest.fromJson(
    Map<String, dynamic> json,
  ) => _$SetPasswordAfterEmailVerifyRequestRequestFromJson(json);

  static const toJsonFactory =
      _$SetPasswordAfterEmailVerifyRequestRequestToJson;
  Map<String, dynamic> toJson() =>
      _$SetPasswordAfterEmailVerifyRequestRequestToJson(this);

  @JsonKey(name: 'email', includeIfNull: false)
  final String email;
  @JsonKey(name: 'password', includeIfNull: false)
  final String password;
  static const fromJsonFactory =
      _$SetPasswordAfterEmailVerifyRequestRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is SetPasswordAfterEmailVerifyRequestRequest &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.password, password) ||
                const DeepCollectionEquality().equals(
                  other.password,
                  password,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(password) ^
      runtimeType.hashCode;
}

extension $SetPasswordAfterEmailVerifyRequestRequestExtension
    on SetPasswordAfterEmailVerifyRequestRequest {
  SetPasswordAfterEmailVerifyRequestRequest copyWith({
    String? email,
    String? password,
  }) {
    return SetPasswordAfterEmailVerifyRequestRequest(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  SetPasswordAfterEmailVerifyRequestRequest copyWithWrapped({
    Wrapped<String>? email,
    Wrapped<String>? password,
  }) {
    return SetPasswordAfterEmailVerifyRequestRequest(
      email: (email != null ? email.value : this.email),
      password: (password != null ? password.value : this.password),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class SetPasswordAfterEmailVerifyResponse {
  const SetPasswordAfterEmailVerifyResponse({required this.message});

  factory SetPasswordAfterEmailVerifyResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$SetPasswordAfterEmailVerifyResponseFromJson(json);

  static const toJsonFactory = _$SetPasswordAfterEmailVerifyResponseToJson;
  Map<String, dynamic> toJson() =>
      _$SetPasswordAfterEmailVerifyResponseToJson(this);

  @JsonKey(name: 'message', includeIfNull: false)
  final String message;
  static const fromJsonFactory = _$SetPasswordAfterEmailVerifyResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is SetPasswordAfterEmailVerifyResponse &&
            (identical(other.message, message) ||
                const DeepCollectionEquality().equals(other.message, message)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(message) ^ runtimeType.hashCode;
}

extension $SetPasswordAfterEmailVerifyResponseExtension
    on SetPasswordAfterEmailVerifyResponse {
  SetPasswordAfterEmailVerifyResponse copyWith({String? message}) {
    return SetPasswordAfterEmailVerifyResponse(
      message: message ?? this.message,
    );
  }

  SetPasswordAfterEmailVerifyResponse copyWithWrapped({
    Wrapped<String>? message,
  }) {
    return SetPasswordAfterEmailVerifyResponse(
      message: (message != null ? message.value : this.message),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class TokenRefresh {
  const TokenRefresh({this.access, required this.refresh});

  factory TokenRefresh.fromJson(Map<String, dynamic> json) =>
      _$TokenRefreshFromJson(json);

  static const toJsonFactory = _$TokenRefreshToJson;
  Map<String, dynamic> toJson() => _$TokenRefreshToJson(this);

  @JsonKey(name: 'access', includeIfNull: false)
  final String? access;
  @JsonKey(name: 'refresh', includeIfNull: false)
  final String refresh;
  static const fromJsonFactory = _$TokenRefreshFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TokenRefresh &&
            (identical(other.access, access) ||
                const DeepCollectionEquality().equals(other.access, access)) &&
            (identical(other.refresh, refresh) ||
                const DeepCollectionEquality().equals(other.refresh, refresh)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(access) ^
      const DeepCollectionEquality().hash(refresh) ^
      runtimeType.hashCode;
}

extension $TokenRefreshExtension on TokenRefresh {
  TokenRefresh copyWith({String? access, String? refresh}) {
    return TokenRefresh(
      access: access ?? this.access,
      refresh: refresh ?? this.refresh,
    );
  }

  TokenRefresh copyWithWrapped({
    Wrapped<String?>? access,
    Wrapped<String>? refresh,
  }) {
    return TokenRefresh(
      access: (access != null ? access.value : this.access),
      refresh: (refresh != null ? refresh.value : this.refresh),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class TokenRefreshRequest {
  const TokenRefreshRequest({required this.refresh});

  factory TokenRefreshRequest.fromJson(Map<String, dynamic> json) =>
      _$TokenRefreshRequestFromJson(json);

  static const toJsonFactory = _$TokenRefreshRequestToJson;
  Map<String, dynamic> toJson() => _$TokenRefreshRequestToJson(this);

  @JsonKey(name: 'refresh', includeIfNull: false)
  final String refresh;
  static const fromJsonFactory = _$TokenRefreshRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TokenRefreshRequest &&
            (identical(other.refresh, refresh) ||
                const DeepCollectionEquality().equals(other.refresh, refresh)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(refresh) ^ runtimeType.hashCode;
}

extension $TokenRefreshRequestExtension on TokenRefreshRequest {
  TokenRefreshRequest copyWith({String? refresh}) {
    return TokenRefreshRequest(refresh: refresh ?? this.refresh);
  }

  TokenRefreshRequest copyWithWrapped({Wrapped<String>? refresh}) {
    return TokenRefreshRequest(
      refresh: (refresh != null ? refresh.value : this.refresh),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class UMKErrorResponse {
  const UMKErrorResponse({required this.error});

  factory UMKErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$UMKErrorResponseFromJson(json);

  static const toJsonFactory = _$UMKErrorResponseToJson;
  Map<String, dynamic> toJson() => _$UMKErrorResponseToJson(this);

  @JsonKey(name: 'error', includeIfNull: false)
  final String error;
  static const fromJsonFactory = _$UMKErrorResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is UMKErrorResponse &&
            (identical(other.error, error) ||
                const DeepCollectionEquality().equals(other.error, error)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(error) ^ runtimeType.hashCode;
}

extension $UMKErrorResponseExtension on UMKErrorResponse {
  UMKErrorResponse copyWith({String? error}) {
    return UMKErrorResponse(error: error ?? this.error);
  }

  UMKErrorResponse copyWithWrapped({Wrapped<String>? error}) {
    return UMKErrorResponse(error: (error != null ? error.value : this.error));
  }
}

@JsonSerializable(explicitToJson: true)
class UMKGetResponse {
  const UMKGetResponse({
    required this.user,
    required this.umkB64,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    this.exists,
  });

  factory UMKGetResponse.fromJson(Map<String, dynamic> json) =>
      _$UMKGetResponseFromJson(json);

  static const toJsonFactory = _$UMKGetResponseToJson;
  Map<String, dynamic> toJson() => _$UMKGetResponseToJson(this);

  @JsonKey(name: 'user', includeIfNull: false)
  final int user;
  @JsonKey(name: 'umk_b64', includeIfNull: false)
  final String umkB64;
  @JsonKey(name: 'version', includeIfNull: false)
  final int version;
  @JsonKey(name: 'created_at', includeIfNull: false)
  final DateTime createdAt;
  @JsonKey(name: 'updated_at', includeIfNull: false)
  final DateTime updatedAt;
  @JsonKey(name: 'exists', includeIfNull: false, defaultValue: true)
  final bool? exists;
  static const fromJsonFactory = _$UMKGetResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is UMKGetResponse &&
            (identical(other.user, user) ||
                const DeepCollectionEquality().equals(other.user, user)) &&
            (identical(other.umkB64, umkB64) ||
                const DeepCollectionEquality().equals(other.umkB64, umkB64)) &&
            (identical(other.version, version) ||
                const DeepCollectionEquality().equals(
                  other.version,
                  version,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.updatedAt, updatedAt) ||
                const DeepCollectionEquality().equals(
                  other.updatedAt,
                  updatedAt,
                )) &&
            (identical(other.exists, exists) ||
                const DeepCollectionEquality().equals(other.exists, exists)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(user) ^
      const DeepCollectionEquality().hash(umkB64) ^
      const DeepCollectionEquality().hash(version) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(updatedAt) ^
      const DeepCollectionEquality().hash(exists) ^
      runtimeType.hashCode;
}

extension $UMKGetResponseExtension on UMKGetResponse {
  UMKGetResponse copyWith({
    int? user,
    String? umkB64,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? exists,
  }) {
    return UMKGetResponse(
      user: user ?? this.user,
      umkB64: umkB64 ?? this.umkB64,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      exists: exists ?? this.exists,
    );
  }

  UMKGetResponse copyWithWrapped({
    Wrapped<int>? user,
    Wrapped<String>? umkB64,
    Wrapped<int>? version,
    Wrapped<DateTime>? createdAt,
    Wrapped<DateTime>? updatedAt,
    Wrapped<bool?>? exists,
  }) {
    return UMKGetResponse(
      user: (user != null ? user.value : this.user),
      umkB64: (umkB64 != null ? umkB64.value : this.umkB64),
      version: (version != null ? version.value : this.version),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      updatedAt: (updatedAt != null ? updatedAt.value : this.updatedAt),
      exists: (exists != null ? exists.value : this.exists),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class UMKProvisionRequestRequest {
  const UMKProvisionRequestRequest({this.umkB64});

  factory UMKProvisionRequestRequest.fromJson(Map<String, dynamic> json) =>
      _$UMKProvisionRequestRequestFromJson(json);

  static const toJsonFactory = _$UMKProvisionRequestRequestToJson;
  Map<String, dynamic> toJson() => _$UMKProvisionRequestRequestToJson(this);

  @JsonKey(name: 'umk_b64', includeIfNull: false)
  final String? umkB64;
  static const fromJsonFactory = _$UMKProvisionRequestRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is UMKProvisionRequestRequest &&
            (identical(other.umkB64, umkB64) ||
                const DeepCollectionEquality().equals(other.umkB64, umkB64)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(umkB64) ^ runtimeType.hashCode;
}

extension $UMKProvisionRequestRequestExtension on UMKProvisionRequestRequest {
  UMKProvisionRequestRequest copyWith({String? umkB64}) {
    return UMKProvisionRequestRequest(umkB64: umkB64 ?? this.umkB64);
  }

  UMKProvisionRequestRequest copyWithWrapped({Wrapped<String?>? umkB64}) {
    return UMKProvisionRequestRequest(
      umkB64: (umkB64 != null ? umkB64.value : this.umkB64),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class UMKProvisionResponse {
  const UMKProvisionResponse({
    required this.user,
    required this.umkB64,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UMKProvisionResponse.fromJson(Map<String, dynamic> json) =>
      _$UMKProvisionResponseFromJson(json);

  static const toJsonFactory = _$UMKProvisionResponseToJson;
  Map<String, dynamic> toJson() => _$UMKProvisionResponseToJson(this);

  @JsonKey(name: 'user', includeIfNull: false)
  final int user;
  @JsonKey(name: 'umk_b64', includeIfNull: false)
  final String umkB64;
  @JsonKey(name: 'version', includeIfNull: false)
  final int version;
  @JsonKey(name: 'created_at', includeIfNull: false)
  final DateTime createdAt;
  @JsonKey(name: 'updated_at', includeIfNull: false)
  final DateTime updatedAt;
  static const fromJsonFactory = _$UMKProvisionResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is UMKProvisionResponse &&
            (identical(other.user, user) ||
                const DeepCollectionEquality().equals(other.user, user)) &&
            (identical(other.umkB64, umkB64) ||
                const DeepCollectionEquality().equals(other.umkB64, umkB64)) &&
            (identical(other.version, version) ||
                const DeepCollectionEquality().equals(
                  other.version,
                  version,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.updatedAt, updatedAt) ||
                const DeepCollectionEquality().equals(
                  other.updatedAt,
                  updatedAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(user) ^
      const DeepCollectionEquality().hash(umkB64) ^
      const DeepCollectionEquality().hash(version) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(updatedAt) ^
      runtimeType.hashCode;
}

extension $UMKProvisionResponseExtension on UMKProvisionResponse {
  UMKProvisionResponse copyWith({
    int? user,
    String? umkB64,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UMKProvisionResponse(
      user: user ?? this.user,
      umkB64: umkB64 ?? this.umkB64,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  UMKProvisionResponse copyWithWrapped({
    Wrapped<int>? user,
    Wrapped<String>? umkB64,
    Wrapped<int>? version,
    Wrapped<DateTime>? createdAt,
    Wrapped<DateTime>? updatedAt,
  }) {
    return UMKProvisionResponse(
      user: (user != null ? user.value : this.user),
      umkB64: (umkB64 != null ? umkB64.value : this.umkB64),
      version: (version != null ? version.value : this.version),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      updatedAt: (updatedAt != null ? updatedAt.value : this.updatedAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class UnifiedSyncDeleteResponse {
  const UnifiedSyncDeleteResponse({
    required this.message,
    this.deleted,
    this.archived,
    this.exportUrls,
    this.profile,
    this.chat,
  });

  factory UnifiedSyncDeleteResponse.fromJson(Map<String, dynamic> json) =>
      _$UnifiedSyncDeleteResponseFromJson(json);

  static const toJsonFactory = _$UnifiedSyncDeleteResponseToJson;
  Map<String, dynamic> toJson() => _$UnifiedSyncDeleteResponseToJson(this);

  @JsonKey(name: 'message', includeIfNull: false)
  final String message;
  @JsonKey(name: 'deleted', includeIfNull: false)
  final UnifiedSyncDeleteStats? deleted;
  @JsonKey(name: 'archived', includeIfNull: false)
  final UnifiedSyncDeleteStats? archived;
  @JsonKey(name: 'export_urls', includeIfNull: false)
  final Map<String, dynamic>? exportUrls;
  @JsonKey(name: 'profile', includeIfNull: false)
  final FullProfile? profile;
  @JsonKey(name: 'chat', includeIfNull: false)
  final FullChat? chat;
  static const fromJsonFactory = _$UnifiedSyncDeleteResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is UnifiedSyncDeleteResponse &&
            (identical(other.message, message) ||
                const DeepCollectionEquality().equals(
                  other.message,
                  message,
                )) &&
            (identical(other.deleted, deleted) ||
                const DeepCollectionEquality().equals(
                  other.deleted,
                  deleted,
                )) &&
            (identical(other.archived, archived) ||
                const DeepCollectionEquality().equals(
                  other.archived,
                  archived,
                )) &&
            (identical(other.exportUrls, exportUrls) ||
                const DeepCollectionEquality().equals(
                  other.exportUrls,
                  exportUrls,
                )) &&
            (identical(other.profile, profile) ||
                const DeepCollectionEquality().equals(
                  other.profile,
                  profile,
                )) &&
            (identical(other.chat, chat) ||
                const DeepCollectionEquality().equals(other.chat, chat)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(message) ^
      const DeepCollectionEquality().hash(deleted) ^
      const DeepCollectionEquality().hash(archived) ^
      const DeepCollectionEquality().hash(exportUrls) ^
      const DeepCollectionEquality().hash(profile) ^
      const DeepCollectionEquality().hash(chat) ^
      runtimeType.hashCode;
}

extension $UnifiedSyncDeleteResponseExtension on UnifiedSyncDeleteResponse {
  UnifiedSyncDeleteResponse copyWith({
    String? message,
    UnifiedSyncDeleteStats? deleted,
    UnifiedSyncDeleteStats? archived,
    Map<String, dynamic>? exportUrls,
    FullProfile? profile,
    FullChat? chat,
  }) {
    return UnifiedSyncDeleteResponse(
      message: message ?? this.message,
      deleted: deleted ?? this.deleted,
      archived: archived ?? this.archived,
      exportUrls: exportUrls ?? this.exportUrls,
      profile: profile ?? this.profile,
      chat: chat ?? this.chat,
    );
  }

  UnifiedSyncDeleteResponse copyWithWrapped({
    Wrapped<String>? message,
    Wrapped<UnifiedSyncDeleteStats?>? deleted,
    Wrapped<UnifiedSyncDeleteStats?>? archived,
    Wrapped<Map<String, dynamic>?>? exportUrls,
    Wrapped<FullProfile?>? profile,
    Wrapped<FullChat?>? chat,
  }) {
    return UnifiedSyncDeleteResponse(
      message: (message != null ? message.value : this.message),
      deleted: (deleted != null ? deleted.value : this.deleted),
      archived: (archived != null ? archived.value : this.archived),
      exportUrls: (exportUrls != null ? exportUrls.value : this.exportUrls),
      profile: (profile != null ? profile.value : this.profile),
      chat: (chat != null ? chat.value : this.chat),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class UnifiedSyncDeleteStats {
  const UnifiedSyncDeleteStats({
    this.attachments,
    this.messages,
    this.conversations,
    this.tokens,
    this.user,
  });

  factory UnifiedSyncDeleteStats.fromJson(Map<String, dynamic> json) =>
      _$UnifiedSyncDeleteStatsFromJson(json);

  static const toJsonFactory = _$UnifiedSyncDeleteStatsToJson;
  Map<String, dynamic> toJson() => _$UnifiedSyncDeleteStatsToJson(this);

  @JsonKey(name: 'attachments', includeIfNull: false)
  final int? attachments;
  @JsonKey(name: 'messages', includeIfNull: false)
  final int? messages;
  @JsonKey(name: 'conversations', includeIfNull: false)
  final int? conversations;
  @JsonKey(name: 'tokens', includeIfNull: false)
  final int? tokens;
  @JsonKey(name: 'user', includeIfNull: false)
  final int? user;
  static const fromJsonFactory = _$UnifiedSyncDeleteStatsFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is UnifiedSyncDeleteStats &&
            (identical(other.attachments, attachments) ||
                const DeepCollectionEquality().equals(
                  other.attachments,
                  attachments,
                )) &&
            (identical(other.messages, messages) ||
                const DeepCollectionEquality().equals(
                  other.messages,
                  messages,
                )) &&
            (identical(other.conversations, conversations) ||
                const DeepCollectionEquality().equals(
                  other.conversations,
                  conversations,
                )) &&
            (identical(other.tokens, tokens) ||
                const DeepCollectionEquality().equals(other.tokens, tokens)) &&
            (identical(other.user, user) ||
                const DeepCollectionEquality().equals(other.user, user)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(attachments) ^
      const DeepCollectionEquality().hash(messages) ^
      const DeepCollectionEquality().hash(conversations) ^
      const DeepCollectionEquality().hash(tokens) ^
      const DeepCollectionEquality().hash(user) ^
      runtimeType.hashCode;
}

extension $UnifiedSyncDeleteStatsExtension on UnifiedSyncDeleteStats {
  UnifiedSyncDeleteStats copyWith({
    int? attachments,
    int? messages,
    int? conversations,
    int? tokens,
    int? user,
  }) {
    return UnifiedSyncDeleteStats(
      attachments: attachments ?? this.attachments,
      messages: messages ?? this.messages,
      conversations: conversations ?? this.conversations,
      tokens: tokens ?? this.tokens,
      user: user ?? this.user,
    );
  }

  UnifiedSyncDeleteStats copyWithWrapped({
    Wrapped<int?>? attachments,
    Wrapped<int?>? messages,
    Wrapped<int?>? conversations,
    Wrapped<int?>? tokens,
    Wrapped<int?>? user,
  }) {
    return UnifiedSyncDeleteStats(
      attachments: (attachments != null ? attachments.value : this.attachments),
      messages: (messages != null ? messages.value : this.messages),
      conversations: (conversations != null
          ? conversations.value
          : this.conversations),
      tokens: (tokens != null ? tokens.value : this.tokens),
      user: (user != null ? user.value : this.user),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class UnifiedSyncGetResponse {
  const UnifiedSyncGetResponse({
    this.userId,
    required this.isNew,
    this.tempId,
    this.profile,
    this.chat,
  });

  factory UnifiedSyncGetResponse.fromJson(Map<String, dynamic> json) =>
      _$UnifiedSyncGetResponseFromJson(json);

  static const toJsonFactory = _$UnifiedSyncGetResponseToJson;
  Map<String, dynamic> toJson() => _$UnifiedSyncGetResponseToJson(this);

  @JsonKey(name: 'user_id', includeIfNull: false)
  final String? userId;
  @JsonKey(name: 'is_new', includeIfNull: false)
  final bool isNew;
  @JsonKey(name: 'temp_id', includeIfNull: false)
  final String? tempId;
  @JsonKey(name: 'profile', includeIfNull: false)
  final FullProfile? profile;
  @JsonKey(name: 'chat', includeIfNull: false)
  final FullChat? chat;
  static const fromJsonFactory = _$UnifiedSyncGetResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is UnifiedSyncGetResponse &&
            (identical(other.userId, userId) ||
                const DeepCollectionEquality().equals(other.userId, userId)) &&
            (identical(other.isNew, isNew) ||
                const DeepCollectionEquality().equals(other.isNew, isNew)) &&
            (identical(other.tempId, tempId) ||
                const DeepCollectionEquality().equals(other.tempId, tempId)) &&
            (identical(other.profile, profile) ||
                const DeepCollectionEquality().equals(
                  other.profile,
                  profile,
                )) &&
            (identical(other.chat, chat) ||
                const DeepCollectionEquality().equals(other.chat, chat)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(userId) ^
      const DeepCollectionEquality().hash(isNew) ^
      const DeepCollectionEquality().hash(tempId) ^
      const DeepCollectionEquality().hash(profile) ^
      const DeepCollectionEquality().hash(chat) ^
      runtimeType.hashCode;
}

extension $UnifiedSyncGetResponseExtension on UnifiedSyncGetResponse {
  UnifiedSyncGetResponse copyWith({
    String? userId,
    bool? isNew,
    String? tempId,
    FullProfile? profile,
    FullChat? chat,
  }) {
    return UnifiedSyncGetResponse(
      userId: userId ?? this.userId,
      isNew: isNew ?? this.isNew,
      tempId: tempId ?? this.tempId,
      profile: profile ?? this.profile,
      chat: chat ?? this.chat,
    );
  }

  UnifiedSyncGetResponse copyWithWrapped({
    Wrapped<String?>? userId,
    Wrapped<bool>? isNew,
    Wrapped<String?>? tempId,
    Wrapped<FullProfile?>? profile,
    Wrapped<FullChat?>? chat,
  }) {
    return UnifiedSyncGetResponse(
      userId: (userId != null ? userId.value : this.userId),
      isNew: (isNew != null ? isNew.value : this.isNew),
      tempId: (tempId != null ? tempId.value : this.tempId),
      profile: (profile != null ? profile.value : this.profile),
      chat: (chat != null ? chat.value : this.chat),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class UnifiedSyncPatchResponse {
  const UnifiedSyncPatchResponse({required this.profile});

  factory UnifiedSyncPatchResponse.fromJson(Map<String, dynamic> json) =>
      _$UnifiedSyncPatchResponseFromJson(json);

  static const toJsonFactory = _$UnifiedSyncPatchResponseToJson;
  Map<String, dynamic> toJson() => _$UnifiedSyncPatchResponseToJson(this);

  @JsonKey(name: 'profile', includeIfNull: false)
  final Profile profile;
  static const fromJsonFactory = _$UnifiedSyncPatchResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is UnifiedSyncPatchResponse &&
            (identical(other.profile, profile) ||
                const DeepCollectionEquality().equals(other.profile, profile)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(profile) ^ runtimeType.hashCode;
}

extension $UnifiedSyncPatchResponseExtension on UnifiedSyncPatchResponse {
  UnifiedSyncPatchResponse copyWith({Profile? profile}) {
    return UnifiedSyncPatchResponse(profile: profile ?? this.profile);
  }

  UnifiedSyncPatchResponse copyWithWrapped({Wrapped<Profile>? profile}) {
    return UnifiedSyncPatchResponse(
      profile: (profile != null ? profile.value : this.profile),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class UnifiedSyncPostRequestRequest {
  const UnifiedSyncPostRequestRequest({
    this.profile,
    this.conversations,
    this.messages,
    this.messageRequests,
    this.messageResponses,
    this.messageOutputs,
    this.attachments,
  });

  factory UnifiedSyncPostRequestRequest.fromJson(Map<String, dynamic> json) =>
      _$UnifiedSyncPostRequestRequestFromJson(json);

  static const toJsonFactory = _$UnifiedSyncPostRequestRequestToJson;
  Map<String, dynamic> toJson() => _$UnifiedSyncPostRequestRequestToJson(this);

  @JsonKey(name: 'profile', includeIfNull: false)
  final FullProfileRequest? profile;
  @JsonKey(
    name: 'conversations',
    includeIfNull: false,
    defaultValue: <ConversationRequest>[],
  )
  final List<ConversationRequest>? conversations;
  @JsonKey(
    name: 'messages',
    includeIfNull: false,
    defaultValue: <MessageRequest>[],
  )
  final List<MessageRequest>? messages;
  @JsonKey(
    name: 'message_requests',
    includeIfNull: false,
    defaultValue: <MessageRequestRequest>[],
  )
  final List<MessageRequestRequest>? messageRequests;
  @JsonKey(
    name: 'message_responses',
    includeIfNull: false,
    defaultValue: <MessageResponseRequest>[],
  )
  final List<MessageResponseRequest>? messageResponses;
  @JsonKey(
    name: 'message_outputs',
    includeIfNull: false,
    defaultValue: <MessageOutputRequest>[],
  )
  final List<MessageOutputRequest>? messageOutputs;
  @JsonKey(
    name: 'attachments',
    includeIfNull: false,
    defaultValue: <AttachmentRequest>[],
  )
  final List<AttachmentRequest>? attachments;
  static const fromJsonFactory = _$UnifiedSyncPostRequestRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is UnifiedSyncPostRequestRequest &&
            (identical(other.profile, profile) ||
                const DeepCollectionEquality().equals(
                  other.profile,
                  profile,
                )) &&
            (identical(other.conversations, conversations) ||
                const DeepCollectionEquality().equals(
                  other.conversations,
                  conversations,
                )) &&
            (identical(other.messages, messages) ||
                const DeepCollectionEquality().equals(
                  other.messages,
                  messages,
                )) &&
            (identical(other.messageRequests, messageRequests) ||
                const DeepCollectionEquality().equals(
                  other.messageRequests,
                  messageRequests,
                )) &&
            (identical(other.messageResponses, messageResponses) ||
                const DeepCollectionEquality().equals(
                  other.messageResponses,
                  messageResponses,
                )) &&
            (identical(other.messageOutputs, messageOutputs) ||
                const DeepCollectionEquality().equals(
                  other.messageOutputs,
                  messageOutputs,
                )) &&
            (identical(other.attachments, attachments) ||
                const DeepCollectionEquality().equals(
                  other.attachments,
                  attachments,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(profile) ^
      const DeepCollectionEquality().hash(conversations) ^
      const DeepCollectionEquality().hash(messages) ^
      const DeepCollectionEquality().hash(messageRequests) ^
      const DeepCollectionEquality().hash(messageResponses) ^
      const DeepCollectionEquality().hash(messageOutputs) ^
      const DeepCollectionEquality().hash(attachments) ^
      runtimeType.hashCode;
}

extension $UnifiedSyncPostRequestRequestExtension
    on UnifiedSyncPostRequestRequest {
  UnifiedSyncPostRequestRequest copyWith({
    FullProfileRequest? profile,
    List<ConversationRequest>? conversations,
    List<MessageRequest>? messages,
    List<MessageRequestRequest>? messageRequests,
    List<MessageResponseRequest>? messageResponses,
    List<MessageOutputRequest>? messageOutputs,
    List<AttachmentRequest>? attachments,
  }) {
    return UnifiedSyncPostRequestRequest(
      profile: profile ?? this.profile,
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      messageRequests: messageRequests ?? this.messageRequests,
      messageResponses: messageResponses ?? this.messageResponses,
      messageOutputs: messageOutputs ?? this.messageOutputs,
      attachments: attachments ?? this.attachments,
    );
  }

  UnifiedSyncPostRequestRequest copyWithWrapped({
    Wrapped<FullProfileRequest?>? profile,
    Wrapped<List<ConversationRequest>?>? conversations,
    Wrapped<List<MessageRequest>?>? messages,
    Wrapped<List<MessageRequestRequest>?>? messageRequests,
    Wrapped<List<MessageResponseRequest>?>? messageResponses,
    Wrapped<List<MessageOutputRequest>?>? messageOutputs,
    Wrapped<List<AttachmentRequest>?>? attachments,
  }) {
    return UnifiedSyncPostRequestRequest(
      profile: (profile != null ? profile.value : this.profile),
      conversations: (conversations != null
          ? conversations.value
          : this.conversations),
      messages: (messages != null ? messages.value : this.messages),
      messageRequests: (messageRequests != null
          ? messageRequests.value
          : this.messageRequests),
      messageResponses: (messageResponses != null
          ? messageResponses.value
          : this.messageResponses),
      messageOutputs: (messageOutputs != null
          ? messageOutputs.value
          : this.messageOutputs),
      attachments: (attachments != null ? attachments.value : this.attachments),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class UnifiedSyncPostResponse {
  const UnifiedSyncPostResponse({
    required this.summary,
    this.errors,
    this.userId,
    this.tempId,
    this.profile,
    this.chat,
  });

  factory UnifiedSyncPostResponse.fromJson(Map<String, dynamic> json) =>
      _$UnifiedSyncPostResponseFromJson(json);

  static const toJsonFactory = _$UnifiedSyncPostResponseToJson;
  Map<String, dynamic> toJson() => _$UnifiedSyncPostResponseToJson(this);

  @JsonKey(name: 'summary', includeIfNull: false)
  final UnifiedSyncUpsertSummary summary;
  @JsonKey(name: 'errors', includeIfNull: false)
  final Map<String, dynamic>? errors;
  @JsonKey(name: 'user_id', includeIfNull: false)
  final String? userId;
  @JsonKey(name: 'temp_id', includeIfNull: false)
  final String? tempId;
  @JsonKey(name: 'profile', includeIfNull: false)
  final FullProfile? profile;
  @JsonKey(name: 'chat', includeIfNull: false)
  final FullChat? chat;
  static const fromJsonFactory = _$UnifiedSyncPostResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is UnifiedSyncPostResponse &&
            (identical(other.summary, summary) ||
                const DeepCollectionEquality().equals(
                  other.summary,
                  summary,
                )) &&
            (identical(other.errors, errors) ||
                const DeepCollectionEquality().equals(other.errors, errors)) &&
            (identical(other.userId, userId) ||
                const DeepCollectionEquality().equals(other.userId, userId)) &&
            (identical(other.tempId, tempId) ||
                const DeepCollectionEquality().equals(other.tempId, tempId)) &&
            (identical(other.profile, profile) ||
                const DeepCollectionEquality().equals(
                  other.profile,
                  profile,
                )) &&
            (identical(other.chat, chat) ||
                const DeepCollectionEquality().equals(other.chat, chat)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(summary) ^
      const DeepCollectionEquality().hash(errors) ^
      const DeepCollectionEquality().hash(userId) ^
      const DeepCollectionEquality().hash(tempId) ^
      const DeepCollectionEquality().hash(profile) ^
      const DeepCollectionEquality().hash(chat) ^
      runtimeType.hashCode;
}

extension $UnifiedSyncPostResponseExtension on UnifiedSyncPostResponse {
  UnifiedSyncPostResponse copyWith({
    UnifiedSyncUpsertSummary? summary,
    Map<String, dynamic>? errors,
    String? userId,
    String? tempId,
    FullProfile? profile,
    FullChat? chat,
  }) {
    return UnifiedSyncPostResponse(
      summary: summary ?? this.summary,
      errors: errors ?? this.errors,
      userId: userId ?? this.userId,
      tempId: tempId ?? this.tempId,
      profile: profile ?? this.profile,
      chat: chat ?? this.chat,
    );
  }

  UnifiedSyncPostResponse copyWithWrapped({
    Wrapped<UnifiedSyncUpsertSummary>? summary,
    Wrapped<Map<String, dynamic>?>? errors,
    Wrapped<String?>? userId,
    Wrapped<String?>? tempId,
    Wrapped<FullProfile?>? profile,
    Wrapped<FullChat?>? chat,
  }) {
    return UnifiedSyncPostResponse(
      summary: (summary != null ? summary.value : this.summary),
      errors: (errors != null ? errors.value : this.errors),
      userId: (userId != null ? userId.value : this.userId),
      tempId: (tempId != null ? tempId.value : this.tempId),
      profile: (profile != null ? profile.value : this.profile),
      chat: (chat != null ? chat.value : this.chat),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class UnifiedSyncUpsertSummary {
  const UnifiedSyncUpsertSummary({
    this.profileUpdated,
    this.conversationsCreated,
    this.conversationsUpdated,
    this.messagesCreated,
    this.messagesUpdated,
    this.requestsCreated,
    this.requestsUpdated,
    this.responsesCreated,
    this.responsesUpdated,
    this.outputsCreated,
    this.outputsUpdated,
    this.attachmentsCreated,
    this.attachmentsUpdated,
  });

  factory UnifiedSyncUpsertSummary.fromJson(Map<String, dynamic> json) =>
      _$UnifiedSyncUpsertSummaryFromJson(json);

  static const toJsonFactory = _$UnifiedSyncUpsertSummaryToJson;
  Map<String, dynamic> toJson() => _$UnifiedSyncUpsertSummaryToJson(this);

  @JsonKey(name: 'profile_updated', includeIfNull: false)
  final bool? profileUpdated;
  @JsonKey(name: 'conversations_created', includeIfNull: false)
  final int? conversationsCreated;
  @JsonKey(name: 'conversations_updated', includeIfNull: false)
  final int? conversationsUpdated;
  @JsonKey(name: 'messages_created', includeIfNull: false)
  final int? messagesCreated;
  @JsonKey(name: 'messages_updated', includeIfNull: false)
  final int? messagesUpdated;
  @JsonKey(name: 'requests_created', includeIfNull: false)
  final int? requestsCreated;
  @JsonKey(name: 'requests_updated', includeIfNull: false)
  final int? requestsUpdated;
  @JsonKey(name: 'responses_created', includeIfNull: false)
  final int? responsesCreated;
  @JsonKey(name: 'responses_updated', includeIfNull: false)
  final int? responsesUpdated;
  @JsonKey(name: 'outputs_created', includeIfNull: false)
  final int? outputsCreated;
  @JsonKey(name: 'outputs_updated', includeIfNull: false)
  final int? outputsUpdated;
  @JsonKey(name: 'attachments_created', includeIfNull: false)
  final int? attachmentsCreated;
  @JsonKey(name: 'attachments_updated', includeIfNull: false)
  final int? attachmentsUpdated;
  static const fromJsonFactory = _$UnifiedSyncUpsertSummaryFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is UnifiedSyncUpsertSummary &&
            (identical(other.profileUpdated, profileUpdated) ||
                const DeepCollectionEquality().equals(
                  other.profileUpdated,
                  profileUpdated,
                )) &&
            (identical(other.conversationsCreated, conversationsCreated) ||
                const DeepCollectionEquality().equals(
                  other.conversationsCreated,
                  conversationsCreated,
                )) &&
            (identical(other.conversationsUpdated, conversationsUpdated) ||
                const DeepCollectionEquality().equals(
                  other.conversationsUpdated,
                  conversationsUpdated,
                )) &&
            (identical(other.messagesCreated, messagesCreated) ||
                const DeepCollectionEquality().equals(
                  other.messagesCreated,
                  messagesCreated,
                )) &&
            (identical(other.messagesUpdated, messagesUpdated) ||
                const DeepCollectionEquality().equals(
                  other.messagesUpdated,
                  messagesUpdated,
                )) &&
            (identical(other.requestsCreated, requestsCreated) ||
                const DeepCollectionEquality().equals(
                  other.requestsCreated,
                  requestsCreated,
                )) &&
            (identical(other.requestsUpdated, requestsUpdated) ||
                const DeepCollectionEquality().equals(
                  other.requestsUpdated,
                  requestsUpdated,
                )) &&
            (identical(other.responsesCreated, responsesCreated) ||
                const DeepCollectionEquality().equals(
                  other.responsesCreated,
                  responsesCreated,
                )) &&
            (identical(other.responsesUpdated, responsesUpdated) ||
                const DeepCollectionEquality().equals(
                  other.responsesUpdated,
                  responsesUpdated,
                )) &&
            (identical(other.outputsCreated, outputsCreated) ||
                const DeepCollectionEquality().equals(
                  other.outputsCreated,
                  outputsCreated,
                )) &&
            (identical(other.outputsUpdated, outputsUpdated) ||
                const DeepCollectionEquality().equals(
                  other.outputsUpdated,
                  outputsUpdated,
                )) &&
            (identical(other.attachmentsCreated, attachmentsCreated) ||
                const DeepCollectionEquality().equals(
                  other.attachmentsCreated,
                  attachmentsCreated,
                )) &&
            (identical(other.attachmentsUpdated, attachmentsUpdated) ||
                const DeepCollectionEquality().equals(
                  other.attachmentsUpdated,
                  attachmentsUpdated,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(profileUpdated) ^
      const DeepCollectionEquality().hash(conversationsCreated) ^
      const DeepCollectionEquality().hash(conversationsUpdated) ^
      const DeepCollectionEquality().hash(messagesCreated) ^
      const DeepCollectionEquality().hash(messagesUpdated) ^
      const DeepCollectionEquality().hash(requestsCreated) ^
      const DeepCollectionEquality().hash(requestsUpdated) ^
      const DeepCollectionEquality().hash(responsesCreated) ^
      const DeepCollectionEquality().hash(responsesUpdated) ^
      const DeepCollectionEquality().hash(outputsCreated) ^
      const DeepCollectionEquality().hash(outputsUpdated) ^
      const DeepCollectionEquality().hash(attachmentsCreated) ^
      const DeepCollectionEquality().hash(attachmentsUpdated) ^
      runtimeType.hashCode;
}

extension $UnifiedSyncUpsertSummaryExtension on UnifiedSyncUpsertSummary {
  UnifiedSyncUpsertSummary copyWith({
    bool? profileUpdated,
    int? conversationsCreated,
    int? conversationsUpdated,
    int? messagesCreated,
    int? messagesUpdated,
    int? requestsCreated,
    int? requestsUpdated,
    int? responsesCreated,
    int? responsesUpdated,
    int? outputsCreated,
    int? outputsUpdated,
    int? attachmentsCreated,
    int? attachmentsUpdated,
  }) {
    return UnifiedSyncUpsertSummary(
      profileUpdated: profileUpdated ?? this.profileUpdated,
      conversationsCreated: conversationsCreated ?? this.conversationsCreated,
      conversationsUpdated: conversationsUpdated ?? this.conversationsUpdated,
      messagesCreated: messagesCreated ?? this.messagesCreated,
      messagesUpdated: messagesUpdated ?? this.messagesUpdated,
      requestsCreated: requestsCreated ?? this.requestsCreated,
      requestsUpdated: requestsUpdated ?? this.requestsUpdated,
      responsesCreated: responsesCreated ?? this.responsesCreated,
      responsesUpdated: responsesUpdated ?? this.responsesUpdated,
      outputsCreated: outputsCreated ?? this.outputsCreated,
      outputsUpdated: outputsUpdated ?? this.outputsUpdated,
      attachmentsCreated: attachmentsCreated ?? this.attachmentsCreated,
      attachmentsUpdated: attachmentsUpdated ?? this.attachmentsUpdated,
    );
  }

  UnifiedSyncUpsertSummary copyWithWrapped({
    Wrapped<bool?>? profileUpdated,
    Wrapped<int?>? conversationsCreated,
    Wrapped<int?>? conversationsUpdated,
    Wrapped<int?>? messagesCreated,
    Wrapped<int?>? messagesUpdated,
    Wrapped<int?>? requestsCreated,
    Wrapped<int?>? requestsUpdated,
    Wrapped<int?>? responsesCreated,
    Wrapped<int?>? responsesUpdated,
    Wrapped<int?>? outputsCreated,
    Wrapped<int?>? outputsUpdated,
    Wrapped<int?>? attachmentsCreated,
    Wrapped<int?>? attachmentsUpdated,
  }) {
    return UnifiedSyncUpsertSummary(
      profileUpdated: (profileUpdated != null
          ? profileUpdated.value
          : this.profileUpdated),
      conversationsCreated: (conversationsCreated != null
          ? conversationsCreated.value
          : this.conversationsCreated),
      conversationsUpdated: (conversationsUpdated != null
          ? conversationsUpdated.value
          : this.conversationsUpdated),
      messagesCreated: (messagesCreated != null
          ? messagesCreated.value
          : this.messagesCreated),
      messagesUpdated: (messagesUpdated != null
          ? messagesUpdated.value
          : this.messagesUpdated),
      requestsCreated: (requestsCreated != null
          ? requestsCreated.value
          : this.requestsCreated),
      requestsUpdated: (requestsUpdated != null
          ? requestsUpdated.value
          : this.requestsUpdated),
      responsesCreated: (responsesCreated != null
          ? responsesCreated.value
          : this.responsesCreated),
      responsesUpdated: (responsesUpdated != null
          ? responsesUpdated.value
          : this.responsesUpdated),
      outputsCreated: (outputsCreated != null
          ? outputsCreated.value
          : this.outputsCreated),
      outputsUpdated: (outputsUpdated != null
          ? outputsUpdated.value
          : this.outputsUpdated),
      attachmentsCreated: (attachmentsCreated != null
          ? attachmentsCreated.value
          : this.attachmentsCreated),
      attachmentsUpdated: (attachmentsUpdated != null
          ? attachmentsUpdated.value
          : this.attachmentsUpdated),
    );
  }
}

String? statusEnumNullableToJson(enums.StatusEnum? statusEnum) {
  return statusEnum?.value;
}

String? statusEnumToJson(enums.StatusEnum statusEnum) {
  return statusEnum.value;
}

enums.StatusEnum statusEnumFromJson(
  Object? statusEnum, [
  enums.StatusEnum? defaultValue,
]) {
  return enums.StatusEnum.values.firstWhereOrNull(
        (e) => e.value == statusEnum,
      ) ??
      defaultValue ??
      enums.StatusEnum.swaggerGeneratedUnknown;
}

enums.StatusEnum? statusEnumNullableFromJson(
  Object? statusEnum, [
  enums.StatusEnum? defaultValue,
]) {
  if (statusEnum == null) {
    return null;
  }
  return enums.StatusEnum.values.firstWhereOrNull(
        (e) => e.value == statusEnum,
      ) ??
      defaultValue;
}

String statusEnumExplodedListToJson(List<enums.StatusEnum>? statusEnum) {
  return statusEnum?.map((e) => e.value!).join(',') ?? '';
}

List<String> statusEnumListToJson(List<enums.StatusEnum>? statusEnum) {
  if (statusEnum == null) {
    return [];
  }

  return statusEnum.map((e) => e.value!).toList();
}

List<enums.StatusEnum> statusEnumListFromJson(
  List? statusEnum, [
  List<enums.StatusEnum>? defaultValue,
]) {
  if (statusEnum == null) {
    return defaultValue ?? [];
  }

  return statusEnum.map((e) => statusEnumFromJson(e.toString())).toList();
}

List<enums.StatusEnum>? statusEnumNullableListFromJson(
  List? statusEnum, [
  List<enums.StatusEnum>? defaultValue,
]) {
  if (statusEnum == null) {
    return defaultValue;
  }

  return statusEnum.map((e) => statusEnumFromJson(e.toString())).toList();
}

// ignore: unused_element
String? _dateToJson(DateTime? date) {
  if (date == null) {
    return null;
  }

  final year = date.year.toString();
  final month = date.month < 10 ? '0${date.month}' : date.month.toString();
  final day = date.day < 10 ? '0${date.day}' : date.day.toString();

  return '$year-$month-$day';
}

class Wrapped<T> {
  final T value;
  const Wrapped.value(this.value);
}
