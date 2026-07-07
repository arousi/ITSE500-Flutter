// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'schema.swagger.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$Schema extends Schema {
  _$Schema([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = Schema;

  @override
  Future<Response<HealthCheckResponse>> _apiV1AuthApiHealthGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description:
          'Report server liveness with a simple JSON payload and 200 status.',
      summary: 'Health check',
      operationId: 'v1_auth_api_health_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth", "BearerAuth"],
      tags: ["ops"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth_api/health/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<HealthCheckResponse, HealthCheckResponse>($request);
  }

  @override
  Future<Response<LoginResponse>> _apiV1AuthApiLoginPost({
    required LoginRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description:
          '''Authenticate a user and return JWT tokens plus initial sync payload.
Accepts identifier (email/username) and user_password/password. Returns 200
with access/refresh tokens, conversations, and attachments on success.
Returns 401 for invalid credentials, 403 if user is inactive/locked, or 400/500 otherwise.''',
      summary: 'Login with identifier + password',
      operationId: 'v1_auth_api_login_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth", "BearerAuth"],
      tags: ["auth"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth_api/login/');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<LoginResponse, LoginResponse>($request);
  }

  @override
  Future<Response<LogoutResponse>> _apiV1AuthApiLogoutPost({
    required LogoutRequestRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description:
          '''Invalidate the current session and blacklist the refresh token if supplied.
Returns a 200 response with a brief message. Requires a valid JWT and authenticated user.''',
      summary: 'Logout (client discards tokens)',
      operationId: 'v1_auth_api_logout_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth", "BearerAuth"],
      tags: ["auth"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth_api/logout/');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<LogoutResponse, LogoutResponse>($request);
  }

  @override
  Future<Response<OAuthCallbackResponse>>
  _apiV1AuthApiOauthResultStateValueGet({
    required String? stateValue,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description:
          '''Fetch the stored OAuth result payload for the given state (one-time).
Returns 202 if the result isn\'t ready yet, 410 if already retrieved, 404 if
the state is unknown, and 200 with the payload on success.''',
      summary: 'Fetch OAuth result by state',
      operationId: 'v1_auth_api_oauth_result_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth", "BearerAuth"],
      tags: ["oauth"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth_api/oauth/result/${stateValue}/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<OAuthCallbackResponse, OAuthCallbackResponse>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1AuthApiOtpLoginPost({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description:
          'Deprecated: OTP-based login is disabled in this release. Always returns 410 Gone.',
      summary: 'Login with OTP (deprecated)',
      operationId: 'v1_auth_api_otp_login_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth", "BearerAuth"],
      tags: ["auth"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth_api/otp-login/');
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<RegisterResponse>> _apiV1AuthApiRegisterPost({
    required RegisterRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description:
          'Create a new account or reconcile existing identity; returns JWTs and initial sync.',
      summary: 'Register account',
      operationId: 'v1_auth_api_register_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth", "BearerAuth"],
      tags: ["auth"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth_api/register/');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<RegisterResponse, RegisterResponse>($request);
  }

  @override
  Future<Response<SetPasswordAfterEmailVerifyResponse>>
  _apiV1AuthApiSetPasswordAfterEmailVerifyPost({
    required SetPasswordAfterEmailVerifyRequestRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Set/reset the account password after email verification.

Expects JSON body with:
- email: string; must match the authenticated user\'s email
- password: string; client-side sha256(raw)

On success, stores a salted backend hash and returns 200 with a message.
May return 400 if data is invalid or email not verified; 404 if user not found;
401 if JWT is missing/invalid.''',
      summary: 'Set password after email verify',
      operationId: 'v1_auth_api_set_password_after_email_verify_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth", "BearerAuth"],
      tags: ["auth"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/auth_api/set-password-after-email-verify/',
    );
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<
      SetPasswordAfterEmailVerifyResponse,
      SetPasswordAfterEmailVerifyResponse
    >($request);
  }

  @override
  Future<Response<TokenRefresh>> _apiV1AuthApiTokenRefreshPost({
    required TokenRefreshRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description:
          '''Takes a refresh type JSON web token and returns an access type JSON web
token if the refresh token is valid.''',
      summary: '',
      operationId: 'v1_auth_api_token_refresh_create',
      consumes: [],
      produces: [],
      security: ["BearerAuth"],
      tags: ["v1"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth_api/token/refresh/');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<TokenRefresh, TokenRefresh>($request);
  }

  @override
  Future<Response<EmailPinVerifyResponse>> _apiV1AuthApiVerifyEmailPinPost({
    required EmailPinVerifyRequestRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Verify the 5-digit email PIN for the authenticated user.

Expects JSON body with:
- email: string; must match the authenticated user\'s email
- pin: string; 5-digit code

Returns 200 with a success message on valid PIN; 400 for invalid/expired PIN;
404 if the user is not found; 401 if JWT is missing/invalid.''',
      summary: 'Verify email PIN',
      operationId: 'v1_auth_api_verify_email_pin_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth", "BearerAuth"],
      tags: ["auth"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth_api/verify-email-pin/');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<EmailPinVerifyResponse, EmailPinVerifyResponse>(
      $request,
    );
  }

  @override
  Future<Response<PaginatedConversationList>> _apiV1ChatApiConversationsGet({
    int? page,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description:
          'List the caller\'s own conversations, or create a new one owned by the caller.',
      summary: '',
      operationId: 'v1_chat_api_conversations_list',
      consumes: [],
      produces: [],
      security: ["jwtAuth", "BearerAuth"],
      tags: ["v1"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/chat_api/conversations/');
    final Map<String, dynamic> $params = <String, dynamic>{'page': page};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<PaginatedConversationList, PaginatedConversationList>(
      $request,
    );
  }

  @override
  Future<Response<Conversation>> _apiV1ChatApiConversationsPost({
    required ConversationRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description:
          'List the caller\'s own conversations, or create a new one owned by the caller.',
      summary: '',
      operationId: 'v1_chat_api_conversations_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth", "BearerAuth"],
      tags: ["v1"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/chat_api/conversations/');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<Conversation, Conversation>($request);
  }

  @override
  Future<Response<Conversation>> _apiV1ChatApiConversationsConversationIdGet({
    required String? conversationId,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Retrieve/update/delete a conversation owned by the caller.

Uses a user-scoped queryset so another user\'s conversation resolves to 404
(never 403) -- this avoids leaking whether the resource exists at all.''',
      summary: '',
      operationId: 'v1_chat_api_conversations_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth", "BearerAuth"],
      tags: ["v1"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/chat_api/conversations/${conversationId}/',
    );
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<Conversation, Conversation>($request);
  }

  @override
  Future<Response<Conversation>> _apiV1ChatApiConversationsConversationIdPut({
    required String? conversationId,
    required ConversationRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Retrieve/update/delete a conversation owned by the caller.

Uses a user-scoped queryset so another user\'s conversation resolves to 404
(never 403) -- this avoids leaking whether the resource exists at all.''',
      summary: '',
      operationId: 'v1_chat_api_conversations_update',
      consumes: [],
      produces: [],
      security: ["jwtAuth", "BearerAuth"],
      tags: ["v1"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/chat_api/conversations/${conversationId}/',
    );
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<Conversation, Conversation>($request);
  }

  @override
  Future<Response<Conversation>> _apiV1ChatApiConversationsConversationIdPatch({
    required String? conversationId,
    required PatchedConversationRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Retrieve/update/delete a conversation owned by the caller.

Uses a user-scoped queryset so another user\'s conversation resolves to 404
(never 403) -- this avoids leaking whether the resource exists at all.''',
      summary: '',
      operationId: 'v1_chat_api_conversations_partial_update',
      consumes: [],
      produces: [],
      security: ["jwtAuth", "BearerAuth"],
      tags: ["v1"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/chat_api/conversations/${conversationId}/',
    );
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<Conversation, Conversation>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1ChatApiConversationsConversationIdDelete({
    required String? conversationId,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Retrieve/update/delete a conversation owned by the caller.

Uses a user-scoped queryset so another user\'s conversation resolves to 404
(never 403) -- this avoids leaking whether the resource exists at all.''',
      summary: '',
      operationId: 'v1_chat_api_conversations_destroy',
      consumes: [],
      produces: [],
      security: ["jwtAuth", "BearerAuth"],
      tags: ["v1"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/chat_api/conversations/${conversationId}/',
    );
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<PaginatedMessageList>>
  _apiV1ChatApiConversationsConversationIdMessagesGet({
    required String? conversationId,
    int? page,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description:
          '''List or create messages within a conversation owned by the caller.

The parent conversation is resolved with a user-scoped lookup, so a missing
OR non-owned conversation both yield 404 (covers the cross-user case without
revealing existence of another user\'s conversation).''',
      summary: '',
      operationId: 'v1_chat_api_conversations_messages_list',
      consumes: [],
      produces: [],
      security: ["jwtAuth", "BearerAuth"],
      tags: ["v1"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/chat_api/conversations/${conversationId}/messages/',
    );
    final Map<String, dynamic> $params = <String, dynamic>{'page': page};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<PaginatedMessageList, PaginatedMessageList>($request);
  }

  @override
  Future<Response<MessageWrite>>
  _apiV1ChatApiConversationsConversationIdMessagesPost({
    required String? conversationId,
    required MessageWriteRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description:
          '''List or create messages within a conversation owned by the caller.

The parent conversation is resolved with a user-scoped lookup, so a missing
OR non-owned conversation both yield 404 (covers the cross-user case without
revealing existence of another user\'s conversation).''',
      summary: '',
      operationId: 'v1_chat_api_conversations_messages_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth", "BearerAuth"],
      tags: ["v1"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/chat_api/conversations/${conversationId}/messages/',
    );
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<MessageWrite, MessageWrite>($request);
  }

  @override
  Future<Response<UMKGetResponse>> _apiV1CryptoApiUmkGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description:
          'Return the caller\'s User Master Key metadata + base64 value, or {exists: false} if not yet provisioned.',
      summary: 'Get caller UMK',
      operationId: 'v1_crypto_api_umk_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth", "BearerAuth"],
      tags: ["crypto"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/crypto_api/umk/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<UMKGetResponse, UMKGetResponse>($request);
  }

  @override
  Future<Response<UMKProvisionResponse>> _apiV1CryptoApiUmkPost({
    required UMKProvisionRequestRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description:
          'Provision the UMK once. Reject with 409 if already provisioned (rotation not yet supported).',
      summary: 'Provision caller UMK',
      operationId: 'v1_crypto_api_umk_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth", "BearerAuth"],
      tags: ["crypto"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/crypto_api/umk/');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<UMKProvisionResponse, UMKProvisionResponse>($request);
  }

  @override
  Future<Response<UnifiedSyncGetResponse>> _apiV1UserMangMeGet({
    bool? allowPublicUuid,
    bool? chat,
    String? deviceId,
    bool? profile,
    String? tempId,
    String? userId,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''GET

Returns a nested payload containing `profile` and/or `chat` depending on flags.

Response shape (high level):
    {
        "user_id": <uuid>,
        "is_new": <bool>,
        "temp_id": <str|null>,
        "profile": { ... } ,          # present when profile=true or by default
        "chat": {                     # present when chat=true or by default
            "conversations": [...],
            "messages": [...],
            "message_request": [...],
            "message_response": [...],
            "message_output": [...],
            "attachments": [...]
        }
    }

Notes / implementation details:
- Serializers: when available the view uses `FullProfileSerializer` and `FullChatSerializer` to produce the
  canonical output. If serializers fail the view falls back to minimal manual assembly.
- Attachments returned in `chat.attachments` always include a `user_id` field (derived from the related
  message) to make ownership explicit for clients.

Example Request:
    GET /api/v1/unified-sync/?user_id=123e4567-e89b-12d3-a456-426614174000&profile=true&chat=true

Example Response (simplified):
    {
        "user_id": "123e4567-e89b-12d3-a456-426614174000",
        "is_new": false,
        "temp_id": null,
        "profile": {
            "user_id": "123e4567-e89b-12d3-a456-426614174000",
            "username": "john_doe",
            "email": "john@example.com",
            "is_visitor": false,
            "is_active": true,
            "is_archived": false
        },
        "chat": {
            "conversations": [
                {
                    "conversation_id": "c1",
                    "title": "My Conversation",
                    "messages": [ {"message_id": "m1", "content": "Hello!"} ]
                }
            ],
            "messages": [ {"message_id": "m1", "content": "Hello!"} ],
            "attachments": [
                {
                    "id": 1,
                    "type": "image",
                    "file_path": "/media/attachments/1.png",
                    "user_id": "123e4567-e89b-12d3-a456-426614174000"
                }
            ]
        }
    }''',
      summary: 'Unified sync (fetch profile/chat)',
      operationId: 'v1_user_mang_me_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth", "BearerAuth"],
      tags: ["sync"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/user_mang/me/');
    final Map<String, dynamic> $params = <String, dynamic>{
      'allow_public_uuid': allowPublicUuid,
      'chat': chat,
      'device_id': deviceId,
      'profile': profile,
      'temp_id': tempId,
      'user_id': userId,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<UnifiedSyncGetResponse, UnifiedSyncGetResponse>(
      $request,
    );
  }

  @override
  Future<Response<UnifiedSyncPostResponse>> _apiV1UserMangMePost({
    required UnifiedSyncPostRequestRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description:
          'Upsert profile and chat model lists atomically; returns summary/errors and canonical payload.',
      summary: 'Unified upsert (profile/chat)',
      operationId: 'v1_user_mang_me_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth", "BearerAuth"],
      tags: ["sync"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/user_mang/me/');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<UnifiedSyncPostResponse, UnifiedSyncPostResponse>(
      $request,
    );
  }

  @override
  Future<Response<UnifiedSyncPatchResponse>> _apiV1UserMangMePatch({
    required PatchedProfileRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description:
          'Authenticated partial update for profile fields (me endpoint style).',
      summary: 'Partial profile update',
      operationId: 'v1_user_mang_me_partial_update',
      consumes: [],
      produces: [],
      security: ["jwtAuth", "BearerAuth"],
      tags: ["sync"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/user_mang/me/');
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<UnifiedSyncPatchResponse, UnifiedSyncPatchResponse>(
      $request,
    );
  }

  @override
  Future<Response<UnifiedSyncDeleteResponse>> _apiV1UserMangMeDelete({
    String? action,
    bool? chat,
    bool? downloadNow,
    bool? profile,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''DELETE

Delete or archive a user\'s profile and/or chat data.

Important behavior changes:
    - The ``action`` parameter is now restricted to "delete" or "archive". Other values are rejected.
    - On any successful delete or archive operation this endpoint will always generate BOTH a CSV and a
      PDF export of the user\'s data.
    - Exports are saved under MEDIA_ROOT/exports/<user_id> and emailed to the user\'s verified address when
      available.
    - If the caller provides ``download_now`` (truthy: 1/true/yes) the view will zip the CSV+PDF and
      immediately return the zip file as a FileResponse. If ``download_now`` is falsy the files are kept on
      disk and the response will include URLs the client can use to download them.

Parameters (body or query):
    - action: "delete" | "archive"  (required)
    - profile: true/false
    - chat: true/false
    - download_now: true/false or 1/0 — when true return a zip (csv+pdf) immediately; when false save and
      return URLs instead
    - reason: optional string for audit logs

Returns (examples):

Example Request (delete + return URLs):
    DELETE /api/v1/unified-sync/
    {
        "user_id": "123e4567-e89b-12d3-a456-426614174000",
        "action": "delete",
        "profile": true,
        "chat": true,
        "download_now": false
    }

Example Response (delete, saved exports):
    HTTP 200
    {
        "message": "User and all related data deleted successfully",
        "deleted": { "attachments": 2, "messages": 5, "conversations": 1, "tokens": 1, "user": 1 },
        "export_urls": {
            "csv": "https://example.com/media/exports/<user_id>/user_export_20250829123000.csv",
            "pdf": "https://example.com/media/exports/<user_id>/user_export_20250829123000.pdf"
        },
        "profile": { /* FullProfileSerializer output or minimal fallback */ },
        "chat": { /* FullChatSerializer output or minimal fallback */ }
    }

Example Request (archive + immediate download):
    DELETE /api/v1/unified-sync/
    {
        "user_id": "123e4567-e89b-12d3-a456-426614174000",
        "action": "archive",
        "profile": true,
        "download_now": true
    }

Example Response (archive, immediate zip):
    HTTP 200
    (A FileResponse serving an attachment named "user_export_<user_id>.zip" containing both CSV and PDF)

Notes:
    - Exporting and emailing are best-effort. Failures while creating or sending exports are logged and do
      not prevent the delete/archive from completing.
    - The response will include ``export_urls`` when files are saved and not directly returned.''',
      summary: 'Delete or archive user data',
      operationId: 'v1_user_mang_me_destroy',
      consumes: [],
      produces: [],
      security: ["jwtAuth", "BearerAuth"],
      tags: ["sync"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/user_mang/me/');
    final Map<String, dynamic> $params = <String, dynamic>{
      'action': action,
      'chat': chat,
      'download_now': downloadNow,
      'profile': profile,
    };
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<UnifiedSyncDeleteResponse, UnifiedSyncDeleteResponse>(
      $request,
    );
  }
}
