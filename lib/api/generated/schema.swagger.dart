// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element_parameter

import 'package:json_annotation/json_annotation.dart';
import 'package:json_annotation/json_annotation.dart' as json;
import 'package:collection/collection.dart';
import 'dart:convert';

import 'schema.models.swagger.dart';
import 'package:chopper/chopper.dart';

import 'client_mapping.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' show MultipartFile;
import 'package:chopper/chopper.dart' as chopper;
import 'schema.enums.swagger.dart' as enums;
import 'schema.metadata.swagger.dart';
export 'schema.enums.swagger.dart';
export 'schema.models.swagger.dart';

part 'schema.swagger.chopper.dart';

// **************************************************************************
// SwaggerChopperGenerator
// **************************************************************************

@ChopperApi()
abstract class Schema extends ChopperService {
  static Schema create({
    ChopperClient? client,
    http.Client? httpClient,
    Authenticator? authenticator,
    ErrorConverter? errorConverter,
    Converter? converter,
    Uri? baseUrl,
    List<Interceptor>? interceptors,
  }) {
    if (client != null) {
      return _$Schema(client);
    }

    final newClient = ChopperClient(
      services: [_$Schema()],
      converter: converter ?? $JsonSerializableConverter(),
      interceptors: interceptors ?? [],
      client: httpClient,
      authenticator: authenticator,
      errorConverter: errorConverter,
      baseUrl: baseUrl ?? Uri.parse('http://'),
    );
    return _$Schema(newClient);
  }

  ///Health check
  Future<chopper.Response<HealthCheckResponse>> apiV1AuthApiHealthGet() {
    generatedMapping.putIfAbsent(
      HealthCheckResponse,
      () => HealthCheckResponse.fromJsonFactory,
    );

    return _apiV1AuthApiHealthGet();
  }

  ///Health check
  @GET(path: '/api/v1/auth_api/health/')
  Future<chopper.Response<HealthCheckResponse>> _apiV1AuthApiHealthGet({
    @chopper.Tag()
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
  });

  ///Login with identifier + password
  Future<chopper.Response<LoginResponse>> apiV1AuthApiLoginPost({
    required LoginRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      LoginResponse,
      () => LoginResponse.fromJsonFactory,
    );

    return _apiV1AuthApiLoginPost(body: body);
  }

  ///Login with identifier + password
  @POST(path: '/api/v1/auth_api/login/', optionalBody: true)
  Future<chopper.Response<LoginResponse>> _apiV1AuthApiLoginPost({
    @Body() required LoginRequest? body,
    @chopper.Tag()
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
  });

  ///Logout (client discards tokens)
  Future<chopper.Response<LogoutResponse>> apiV1AuthApiLogoutPost({
    required LogoutRequestRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      LogoutResponse,
      () => LogoutResponse.fromJsonFactory,
    );

    return _apiV1AuthApiLogoutPost(body: body);
  }

  ///Logout (client discards tokens)
  @POST(path: '/api/v1/auth_api/logout/', optionalBody: true)
  Future<chopper.Response<LogoutResponse>> _apiV1AuthApiLogoutPost({
    @Body() required LogoutRequestRequest? body,
    @chopper.Tag()
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
  });

  ///Fetch OAuth result by state
  ///@param state_value State value used in OAuth
  Future<chopper.Response<OAuthCallbackResponse>>
  apiV1AuthApiOauthResultStateValueGet({required String? stateValue}) {
    generatedMapping.putIfAbsent(
      OAuthCallbackResponse,
      () => OAuthCallbackResponse.fromJsonFactory,
    );

    return _apiV1AuthApiOauthResultStateValueGet(stateValue: stateValue);
  }

  ///Fetch OAuth result by state
  ///@param state_value State value used in OAuth
  @GET(path: '/api/v1/auth_api/oauth/result/{state_value}/')
  Future<chopper.Response<OAuthCallbackResponse>>
  _apiV1AuthApiOauthResultStateValueGet({
    @Path('state_value') required String? stateValue,
    @chopper.Tag()
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
  });

  ///Login with OTP (deprecated)
  Future<chopper.Response> apiV1AuthApiOtpLoginPost() {
    return _apiV1AuthApiOtpLoginPost();
  }

  ///Login with OTP (deprecated)
  @POST(path: '/api/v1/auth_api/otp-login/', optionalBody: true)
  Future<chopper.Response> _apiV1AuthApiOtpLoginPost({
    @chopper.Tag()
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
  });

  ///Register account
  Future<chopper.Response<RegisterResponse>> apiV1AuthApiRegisterPost({
    required RegisterRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      RegisterResponse,
      () => RegisterResponse.fromJsonFactory,
    );

    return _apiV1AuthApiRegisterPost(body: body);
  }

  ///Register account
  @POST(path: '/api/v1/auth_api/register/', optionalBody: true)
  Future<chopper.Response<RegisterResponse>> _apiV1AuthApiRegisterPost({
    @Body() required RegisterRequest? body,
    @chopper.Tag()
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
  });

  ///Set password after email verify
  Future<chopper.Response<SetPasswordAfterEmailVerifyResponse>>
  apiV1AuthApiSetPasswordAfterEmailVerifyPost({
    required SetPasswordAfterEmailVerifyRequestRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      SetPasswordAfterEmailVerifyResponse,
      () => SetPasswordAfterEmailVerifyResponse.fromJsonFactory,
    );

    return _apiV1AuthApiSetPasswordAfterEmailVerifyPost(body: body);
  }

  ///Set password after email verify
  @POST(
    path: '/api/v1/auth_api/set-password-after-email-verify/',
    optionalBody: true,
  )
  Future<chopper.Response<SetPasswordAfterEmailVerifyResponse>>
  _apiV1AuthApiSetPasswordAfterEmailVerifyPost({
    @Body() required SetPasswordAfterEmailVerifyRequestRequest? body,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<TokenRefresh>> apiV1AuthApiTokenRefreshPost({
    required TokenRefreshRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      TokenRefresh,
      () => TokenRefresh.fromJsonFactory,
    );

    return _apiV1AuthApiTokenRefreshPost(body: body);
  }

  ///
  @POST(path: '/api/v1/auth_api/token/refresh/', optionalBody: true)
  Future<chopper.Response<TokenRefresh>> _apiV1AuthApiTokenRefreshPost({
    @Body() required TokenRefreshRequest? body,
    @chopper.Tag()
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
  });

  ///Verify email PIN
  Future<chopper.Response<EmailPinVerifyResponse>>
  apiV1AuthApiVerifyEmailPinPost({
    required EmailPinVerifyRequestRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      EmailPinVerifyResponse,
      () => EmailPinVerifyResponse.fromJsonFactory,
    );

    return _apiV1AuthApiVerifyEmailPinPost(body: body);
  }

  ///Verify email PIN
  @POST(path: '/api/v1/auth_api/verify-email-pin/', optionalBody: true)
  Future<chopper.Response<EmailPinVerifyResponse>>
  _apiV1AuthApiVerifyEmailPinPost({
    @Body() required EmailPinVerifyRequestRequest? body,
    @chopper.Tag()
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
  });

  ///
  ///@param page A page number within the paginated result set.
  Future<chopper.Response<PaginatedConversationList>>
  apiV1ChatApiConversationsGet({int? page}) {
    generatedMapping.putIfAbsent(
      PaginatedConversationList,
      () => PaginatedConversationList.fromJsonFactory,
    );

    return _apiV1ChatApiConversationsGet(page: page);
  }

  ///
  ///@param page A page number within the paginated result set.
  @GET(path: '/api/v1/chat_api/conversations/')
  Future<chopper.Response<PaginatedConversationList>>
  _apiV1ChatApiConversationsGet({
    @Query('page') int? page,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<Conversation>> apiV1ChatApiConversationsPost({
    required ConversationRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      Conversation,
      () => Conversation.fromJsonFactory,
    );

    return _apiV1ChatApiConversationsPost(body: body);
  }

  ///
  @POST(path: '/api/v1/chat_api/conversations/', optionalBody: true)
  Future<chopper.Response<Conversation>> _apiV1ChatApiConversationsPost({
    @Body() required ConversationRequest? body,
    @chopper.Tag()
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
  });

  ///
  ///@param conversation_id
  Future<chopper.Response<Conversation>>
  apiV1ChatApiConversationsConversationIdGet({
    required String? conversationId,
  }) {
    generatedMapping.putIfAbsent(
      Conversation,
      () => Conversation.fromJsonFactory,
    );

    return _apiV1ChatApiConversationsConversationIdGet(
      conversationId: conversationId,
    );
  }

  ///
  ///@param conversation_id
  @GET(path: '/api/v1/chat_api/conversations/{conversation_id}/')
  Future<chopper.Response<Conversation>>
  _apiV1ChatApiConversationsConversationIdGet({
    @Path('conversation_id') required String? conversationId,
    @chopper.Tag()
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
  });

  ///
  ///@param conversation_id
  Future<chopper.Response<Conversation>>
  apiV1ChatApiConversationsConversationIdPut({
    required String? conversationId,
    required ConversationRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      Conversation,
      () => Conversation.fromJsonFactory,
    );

    return _apiV1ChatApiConversationsConversationIdPut(
      conversationId: conversationId,
      body: body,
    );
  }

  ///
  ///@param conversation_id
  @PUT(
    path: '/api/v1/chat_api/conversations/{conversation_id}/',
    optionalBody: true,
  )
  Future<chopper.Response<Conversation>>
  _apiV1ChatApiConversationsConversationIdPut({
    @Path('conversation_id') required String? conversationId,
    @Body() required ConversationRequest? body,
    @chopper.Tag()
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
  });

  ///
  ///@param conversation_id
  Future<chopper.Response<Conversation>>
  apiV1ChatApiConversationsConversationIdPatch({
    required String? conversationId,
    required PatchedConversationRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      Conversation,
      () => Conversation.fromJsonFactory,
    );

    return _apiV1ChatApiConversationsConversationIdPatch(
      conversationId: conversationId,
      body: body,
    );
  }

  ///
  ///@param conversation_id
  @PATCH(
    path: '/api/v1/chat_api/conversations/{conversation_id}/',
    optionalBody: true,
  )
  Future<chopper.Response<Conversation>>
  _apiV1ChatApiConversationsConversationIdPatch({
    @Path('conversation_id') required String? conversationId,
    @Body() required PatchedConversationRequest? body,
    @chopper.Tag()
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
  });

  ///
  ///@param conversation_id
  Future<chopper.Response> apiV1ChatApiConversationsConversationIdDelete({
    required String? conversationId,
  }) {
    return _apiV1ChatApiConversationsConversationIdDelete(
      conversationId: conversationId,
    );
  }

  ///
  ///@param conversation_id
  @DELETE(path: '/api/v1/chat_api/conversations/{conversation_id}/')
  Future<chopper.Response> _apiV1ChatApiConversationsConversationIdDelete({
    @Path('conversation_id') required String? conversationId,
    @chopper.Tag()
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
  });

  ///
  ///@param conversation_id
  ///@param page A page number within the paginated result set.
  Future<chopper.Response<PaginatedMessageList>>
  apiV1ChatApiConversationsConversationIdMessagesGet({
    required String? conversationId,
    int? page,
  }) {
    generatedMapping.putIfAbsent(
      PaginatedMessageList,
      () => PaginatedMessageList.fromJsonFactory,
    );

    return _apiV1ChatApiConversationsConversationIdMessagesGet(
      conversationId: conversationId,
      page: page,
    );
  }

  ///
  ///@param conversation_id
  ///@param page A page number within the paginated result set.
  @GET(path: '/api/v1/chat_api/conversations/{conversation_id}/messages/')
  Future<chopper.Response<PaginatedMessageList>>
  _apiV1ChatApiConversationsConversationIdMessagesGet({
    @Path('conversation_id') required String? conversationId,
    @Query('page') int? page,
    @chopper.Tag()
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
  });

  ///
  ///@param conversation_id
  Future<chopper.Response<MessageWrite>>
  apiV1ChatApiConversationsConversationIdMessagesPost({
    required String? conversationId,
    required MessageWriteRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      MessageWrite,
      () => MessageWrite.fromJsonFactory,
    );

    return _apiV1ChatApiConversationsConversationIdMessagesPost(
      conversationId: conversationId,
      body: body,
    );
  }

  ///
  ///@param conversation_id
  @POST(
    path: '/api/v1/chat_api/conversations/{conversation_id}/messages/',
    optionalBody: true,
  )
  Future<chopper.Response<MessageWrite>>
  _apiV1ChatApiConversationsConversationIdMessagesPost({
    @Path('conversation_id') required String? conversationId,
    @Body() required MessageWriteRequest? body,
    @chopper.Tag()
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
  });

  ///Get caller UMK
  Future<chopper.Response<UMKGetResponse>> apiV1CryptoApiUmkGet() {
    generatedMapping.putIfAbsent(
      UMKGetResponse,
      () => UMKGetResponse.fromJsonFactory,
    );

    return _apiV1CryptoApiUmkGet();
  }

  ///Get caller UMK
  @GET(path: '/api/v1/crypto_api/umk/')
  Future<chopper.Response<UMKGetResponse>> _apiV1CryptoApiUmkGet({
    @chopper.Tag()
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
  });

  ///Provision caller UMK
  Future<chopper.Response<UMKProvisionResponse>> apiV1CryptoApiUmkPost({
    required UMKProvisionRequestRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      UMKProvisionResponse,
      () => UMKProvisionResponse.fromJsonFactory,
    );

    return _apiV1CryptoApiUmkPost(body: body);
  }

  ///Provision caller UMK
  @POST(path: '/api/v1/crypto_api/umk/', optionalBody: true)
  Future<chopper.Response<UMKProvisionResponse>> _apiV1CryptoApiUmkPost({
    @Body() required UMKProvisionRequestRequest? body,
    @chopper.Tag()
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
  });

  ///Unified sync (fetch profile/chat)
  ///@param allow_public_uuid Allow unauthenticated read by UUID for GET
  ///@param chat Include chat section
  ///@param device_id Associate device with user/visitor
  ///@param profile Include profile section
  ///@param temp_id Visitor temp identifier (issues short-lived tokens)
  ///@param user_id User UUID (GET only, when allow_public_uuid=true)
  Future<chopper.Response<UnifiedSyncGetResponse>> apiV1UserMangMeGet({
    bool? allowPublicUuid,
    bool? chat,
    String? deviceId,
    bool? profile,
    String? tempId,
    String? userId,
  }) {
    generatedMapping.putIfAbsent(
      UnifiedSyncGetResponse,
      () => UnifiedSyncGetResponse.fromJsonFactory,
    );

    return _apiV1UserMangMeGet(
      allowPublicUuid: allowPublicUuid,
      chat: chat,
      deviceId: deviceId,
      profile: profile,
      tempId: tempId,
      userId: userId,
    );
  }

  ///Unified sync (fetch profile/chat)
  ///@param allow_public_uuid Allow unauthenticated read by UUID for GET
  ///@param chat Include chat section
  ///@param device_id Associate device with user/visitor
  ///@param profile Include profile section
  ///@param temp_id Visitor temp identifier (issues short-lived tokens)
  ///@param user_id User UUID (GET only, when allow_public_uuid=true)
  @GET(path: '/api/v1/user_mang/me/')
  Future<chopper.Response<UnifiedSyncGetResponse>> _apiV1UserMangMeGet({
    @Query('allow_public_uuid') bool? allowPublicUuid,
    @Query('chat') bool? chat,
    @Query('device_id') String? deviceId,
    @Query('profile') bool? profile,
    @Query('temp_id') String? tempId,
    @Query('user_id') String? userId,
    @chopper.Tag()
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
  });

  ///Unified upsert (profile/chat)
  Future<chopper.Response<UnifiedSyncPostResponse>> apiV1UserMangMePost({
    required UnifiedSyncPostRequestRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      UnifiedSyncPostResponse,
      () => UnifiedSyncPostResponse.fromJsonFactory,
    );

    return _apiV1UserMangMePost(body: body);
  }

  ///Unified upsert (profile/chat)
  @POST(path: '/api/v1/user_mang/me/', optionalBody: true)
  Future<chopper.Response<UnifiedSyncPostResponse>> _apiV1UserMangMePost({
    @Body() required UnifiedSyncPostRequestRequest? body,
    @chopper.Tag()
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
  });

  ///Partial profile update
  Future<chopper.Response<UnifiedSyncPatchResponse>> apiV1UserMangMePatch({
    required PatchedProfileRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      UnifiedSyncPatchResponse,
      () => UnifiedSyncPatchResponse.fromJsonFactory,
    );

    return _apiV1UserMangMePatch(body: body);
  }

  ///Partial profile update
  @PATCH(path: '/api/v1/user_mang/me/', optionalBody: true)
  Future<chopper.Response<UnifiedSyncPatchResponse>> _apiV1UserMangMePatch({
    @Body() required PatchedProfileRequest? body,
    @chopper.Tag()
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
  });

  ///Delete or archive user data
  ///@param action 'delete' or 'archive'
  ///@param chat
  ///@param download_now If true, returns a zip of CSV+PDF
  ///@param profile
  Future<chopper.Response<UnifiedSyncDeleteResponse>> apiV1UserMangMeDelete({
    String? action,
    bool? chat,
    bool? downloadNow,
    bool? profile,
  }) {
    generatedMapping.putIfAbsent(
      UnifiedSyncDeleteResponse,
      () => UnifiedSyncDeleteResponse.fromJsonFactory,
    );

    return _apiV1UserMangMeDelete(
      action: action,
      chat: chat,
      downloadNow: downloadNow,
      profile: profile,
    );
  }

  ///Delete or archive user data
  ///@param action 'delete' or 'archive'
  ///@param chat
  ///@param download_now If true, returns a zip of CSV+PDF
  ///@param profile
  @DELETE(path: '/api/v1/user_mang/me/')
  Future<chopper.Response<UnifiedSyncDeleteResponse>> _apiV1UserMangMeDelete({
    @Query('action') String? action,
    @Query('chat') bool? chat,
    @Query('download_now') bool? downloadNow,
    @Query('profile') bool? profile,
    @chopper.Tag()
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
  });
}

typedef $JsonFactory<T> = T Function(Map<String, dynamic> json);

class $CustomJsonDecoder {
  $CustomJsonDecoder(this.factories);

  final Map<Type, $JsonFactory> factories;

  dynamic decode<T>(dynamic entity) {
    if (entity is Iterable) {
      return _decodeList<T>(entity);
    }

    if (entity is T) {
      return entity;
    }

    if (isTypeOf<T, Map>()) {
      return entity;
    }

    if (isTypeOf<T, Iterable>()) {
      return entity;
    }

    if (entity is Map<String, dynamic>) {
      return _decodeMap<T>(entity);
    }

    return entity;
  }

  T _decodeMap<T>(Map<String, dynamic> values) {
    final jsonFactory = factories[T];
    if (jsonFactory == null || jsonFactory is! $JsonFactory<T>) {
      return throw "Could not find factory for type $T. Is '$T: $T.fromJsonFactory' included in the CustomJsonDecoder instance creation in bootstrapper.dart?";
    }

    return jsonFactory(values);
  }

  List<T> _decodeList<T>(Iterable values) =>
      values.where((v) => v != null).map<T>((v) => decode<T>(v) as T).toList();
}

class $JsonSerializableConverter extends chopper.JsonConverter {
  @override
  FutureOr<chopper.Response<ResultType>> convertResponse<ResultType, Item>(
    chopper.Response response,
  ) async {
    if (response.bodyString.isEmpty) {
      // In rare cases, when let's say 204 (no content) is returned -
      // we cannot decode the missing json with the result type specified
      return chopper.Response(response.base, null, error: response.error);
    }

    if (ResultType == String) {
      return response.copyWith();
    }

    if (ResultType == DateTime) {
      return response.copyWith(
        body:
            DateTime.parse((response.body as String).replaceAll('"', ''))
                as ResultType,
      );
    }

    final jsonRes = await super.convertResponse(response);
    return jsonRes.copyWith<ResultType>(
      body: $jsonDecoder.decode<Item>(jsonRes.body) as ResultType,
    );
  }
}

final $jsonDecoder = $CustomJsonDecoder(generatedMapping);
