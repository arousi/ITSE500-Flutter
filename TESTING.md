# Testing — flutter_app_itse500

This is the first-ever test suite for this project. It follows the shared
cross-repo conventions in `ci-test-conventions.md` (owner: github.com/arousi;
see the sibling `itse500-django` and `itse500-ok-REACT` repos for the same
shape applied to their stacks).

## Stack

- Flutter **3.44.5** / Dart **3.12.2** (pinned via `.fvmrc`, matched in CI via
  `subosito/flutter-action@v2`).
- Test framework: `flutter_test` (built in) + `bloc_test` (Cubit/BLoC state
  assertions) + `mocktail` (mocking, and its `Fake` base class for a
  throwaway `BuildContext`).
- `sqflite_common_ffi` for headless/in-memory-backed SQLite in `db_helper`
  tests (the real `sqflite` plugin needs a platform, which isn't available
  under `flutter test`).
- `yaml` for parsing the Django-published OpenAPI contract in the contract
  test.

## Running tests locally

```powershell
flutter pub get
flutter analyze          # 0 errors is the CI gate
flutter test              # full suite
flutter test --coverage   # writes coverage/lcov.info
```

Run a single file:

```powershell
flutter test test/core/utils/design_patterns/adapters/openai_adapter_test.dart
```

## Test layout

```
test/
  core/utils/
    design_patterns/
      adapters/               # buildRequest / parseResponse / streamParser per provider
        openai_adapter_test.dart
        gemini_adapter_test.dart
        openrouter_adapter_test.dart
        lmstudio_adapter_test.dart
        huggingface_adapter_test.dart
      builders/
        message_request_builder_test.dart
      model_resolver_test.dart
    db_helper_test.dart        # schema + CRUD, via sqflite_common_ffi
  features/
    auth/logic/
      auth_cubit_test.dart     # guest login / logout / state resolution
    chat/logic/
      chat_cubit_config_test.dart      # provider/model/key config surface
      chat_cubit_send_guards_test.dart # sendMessage guard rails, conversation id
    chat_inference/logic/
      inference_settings_cubit_test.dart
  contract/
    api_contract_test.dart     # validates wire shapes against Django's OpenAPI schema
```

## What's covered, and why

**Provider adapters** (`lib/core/utils/design_patterns/adapters/`) — the 5
adapters (OpenAI, Gemini, OpenRouter, LM Studio, HuggingFace) implement a
shared `ProviderAdapter` interface (`buildRequest` / `parseResponse` /
`streamParser`) with zero I/O in the methods under test — they're pure
request-shape builders and response parsers, which makes them the highest
signal-to-effort unit-test target in this codebase. Tests assert exact
request bodies/headers/URLs against the documented provider APIs, and parse
sample JSON payloads (including malformed/partial-stream edge cases) without
any real network call.

**`MessageRequestBuilder`** and **`ModelResolver`** — pure functions gating
which sampling parameters get included per provider capability, and
normalizing model ids (currently just Gemini's `models/` prefix). Fully
deterministic, fully covered.

**`DatabaseHelper`** (`lib/core/utils/db_helper.dart`) — schema-version and
table-presence checks after `onCreate`, plus CRUD round-trips for
conversations, messages, the request/response/output triplet tables, users,
and bulk-delete paths, run against an in-memory-backed `sqflite_common_ffi`
database. `DatabaseHelper` is a process-wide singleton (a static `_database`
field with no reset hook), so all tests in `db_helper_test.dart` share one
opened database and use unique ids per test rather than reopening per test;
`setUpAll` deletes any leftover db file from a previous run so repeated
`flutter test` invocations stay idempotent.

While writing the round-trip test we found **`insertMessage` was completely
broken since schema v1**: `Message.toJson()` emits columns (`user_id`,
`request_id`, `response_id`, `output_id`, `has_image`, `img_Url`,
`has_embedding`, `has_document`, `doc_url`) that don't exist in the
`messages` table (which only has `message_id, conversation_id, img,
timestamp, vote, metadata, embedding, doc` — the rest are joined in from the
request/response/output tables on read, see `fetchMessages`). Every real
call — e.g. `api_service.dart` after a chat completion — would throw a SQL
error. Fixed by filtering to the table's actual columns before insert. We
also fixed `Message.toJson()`/`fromJson()` to store/read booleans as 0/1
ints instead of native Dart `bool`, matching the `INTEGER` column type
(`sqflite_common_ffi`, used in tests, rejects native bools outright; the
real platform channel may have been silently mis-serializing them too).

**`InferenceSettingsCubit`** — no dependencies, fully covered: default
values, individual setters, the `localOnly`/`mixedStorage` mutual-exclusion
transition, and full-state replacement.

**`AuthCubit`** and **`ChatCubit`** — see "God objects" below. Both are
constructible under `flutter_test` by mocking the platform channels they
touch, which lets us cover:
- `AuthCubit`: initial-state resolution (`AuthInitial` / `AuthGuest` from a
  persisted visitor id / `AuthAuthenticated` from a stored token),
  `continueAsGuest` (loading→guest transition, visitor id
  generation/reuse, storage mode persisted, stale tokens cleared), `logout`
  (tokens + provider toggles cleared, including the caught-exception
  fallback path), and `setAuthenticated`.
- `ChatCubit`: its synchronous, side-effect-free configuration surface
  (`setApiKey`, `setProviderLLMs` canonicalization/de-dup,
  `setProviderConnected`/`setProviderEnabled`, pending-attachment no-op
  guards, `resetForLogout`), plus `sendMessage`'s up-front validation (the
  "no provider enabled/connected" `ChatError`) and `ensureConversation`'s
  lazy-create-then-reuse behavior.

**Contract test** (`test/contract/api_contract_test.dart`) — validates that
`Conversation.toJson()` / `Message.toJson()` (the shapes this app actually
produces when syncing to Django's unified-sync endpoint,
`GET/POST /api/v1/user_mang/me/`) satisfy the required fields of Django's
published `ConversationDoc` / `MessageDoc` / `AttachmentDoc` schemas in
`contract/openapi.yaml`. The path is resolved from the `OPENAPI_CONTRACT_PATH`
env var if set, otherwise falls back to this developer machine's known
absolute sibling-repo location; **if the schema file isn't found, the suite
skips itself rather than asserting anything fabricated** (mirrors the React
app's `src/__tests__/contract/api-contract.test.js`). Chat-completion
request/response bodies (`MessageRequest`/`MessageResponse`/`MessageOutput`)
are intentionally out of scope for this contract test — those go directly
from the app to the LLM providers and are never part of Django's API.

## God objects — known gaps, feeding a Phase 3 refactor

`chat_cubit.dart` (~2600 lines) and `api_service.dart` (~3100 lines) directly
instantiate their own dependencies (`DataRepository()`, `ChatRepository()`,
`FlutterSecureStorage()`, `ModelRepository.I`, `ProviderAdapterFactory()`,
`AppLinks()`, `LocalAuthentication()`, ...) with **no dependency-injection
seam**, so their network/storage/streaming code paths cannot be exercised in
a unit test without either (a) mocking platform channels one at a time
(brittle, and some — like `app_links`'s `EventChannel` combined with
`AuthCubit`'s undisposed subscription — actively hang `flutter_test`'s
widget pump when combined with `testWidgets`), or (b) a real DI refactor
(constructor-injected repositories/services, mockable via `mocktail`).

**Explicitly skipped as untestable-without-refactor** (candidates for Phase 3):
- `ChatCubit.sendMessage`'s actual provider round-trip (building the HTTP
  request via `ProviderAdapterFactory`, issuing it via `ChatRepository`/
  `DataRepository`, streaming the response, and persisting via
  `DatabaseHelper`) — only the pre-flight validation is covered.
- `AuthCubit`'s OAuth flows (`startGoogleOAuth`/`completeGoogleOAuth`,
  the OpenRouter and Microsoft equivalents, and the deep-link bridge
  finalization) — these call `launchUrl` (real OS browser launch) and
  `DataRepository` network methods with no mock seam.
- `AuthCubit`'s biometric flows (`attemptBiometricUnlock`, inactivity-timer
  relock) — `local_auth`'s actual authentication prompt can't be
  meaningfully faked beyond "unavailable", which the constructor path
  already exercises indirectly.
- `api_service.dart` in general — a 3100-line single class mixing HTTP,
  parsing, and persistence; not touched by this test suite at all beyond
  what's exercised transitively via `DatabaseHelper`.

## CI

`.github/workflows/ci.yml` runs on push to `main` and on every pull request,
with `concurrency: cancel-in-progress` keyed by ref:

- **lint** — `flutter analyze` (must be 0 errors).
- **test** — `flutter test --coverage`, uploads `coverage/lcov.info` as a
  build artifact.
- **build** — `flutter build web --release` (chosen over the full Windows
  desktop + Inno Setup installer pipeline to keep this workflow fast and
  cross-platform; the existing tag-triggered `.github/workflows/release.yml`
  already owns the full multi-platform release build and is untouched).

Coverage threshold: no hard gate enforced yet (first suite); the lcov
artifact is uploaded on every run so a threshold can be added once a
baseline stabilizes. As of this writing, the units this suite specifically
targets (adapters, builders, resolver, db_helper, models,
`InferenceSettingsCubit`) sit between 60% and 100% line coverage; the two
un-refactored god objects (`AuthCubit`, `ChatCubit`) sit far lower (~15% and
~7% respectively) because their network/OAuth/streaming branches are
explicitly out of scope until Phase 3.
