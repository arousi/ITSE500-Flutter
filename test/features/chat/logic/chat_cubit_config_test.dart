// Focused tests for ChatCubit's synchronous, dependency-free configuration
// surface (API key/model/provider toggles). ChatCubit is a god object that
// directly instantiates DataRepository/FlutterSecureStorage/ChatRepository/
// ModelRepository (no DI seam) and its constructor kicks off an async
// `_hydrateFromStorage()` secure-storage read; that read throws
// MissingPluginException in the test harness but is caught internally, so
// the cubit remains constructible and these in-memory-only mutators are
// safely testable without touching network or platform channels. Send/
// receive flows that call DataRepository/ChatRepository/ProviderAdapterFactory
// are NOT covered here — see the "skipped as untestable-without-refactor"
// note in the test report; that needs a DI refactor (Phase 3).
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_itse500/features/chat/logic/chat_cubit.dart';
import 'package:flutter_app_itse500/features/chat/logic/chat_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChatCubit configuration transitions', () {
    blocTest<ChatCubit, ChatState>(
      'setApiKey stores the key in-memory and emits ChatConfigChanged',
      build: () => ChatCubit(),
      act: (cubit) => cubit.setApiKey('openai', 'sk-test-123'),
      expect: () => [isA<ChatConfigChanged>()],
      verify: (cubit) {
        expect(cubit.providerApiKeys['openai'], 'sk-test-123');
      },
    );

    blocTest<ChatCubit, ChatState>(
      'setProviderLLMs canonicalizes ids (strips "models/") and de-duplicates',
      build: () => ChatCubit(),
      act: (cubit) => cubit.setProviderLLMs('gemini', [
        'models/gemini-1.5-flash',
        'gemini-1.5-flash', // duplicate once canonicalized
        'gemini-1.5-pro',
      ]),
      expect: () => [isA<ChatConfigChanged>()],
      verify: (cubit) {
        expect(cubit.providerLLMs['gemini'],
            ['gemini-1.5-flash', 'gemini-1.5-pro']);
      },
    );

    blocTest<ChatCubit, ChatState>(
      'setProviderConnected flips the connected flag for that provider only',
      build: () => ChatCubit(),
      act: (cubit) => cubit.setProviderConnected('openai', true),
      expect: () => [isA<ChatConfigChanged>()],
      verify: (cubit) {
        expect(cubit.providerConnected['openai'], isTrue);
        expect(cubit.providerConnected['gemini'], isFalse);
      },
    );

    blocTest<ChatCubit, ChatState>(
      'setProviderEnabled flips the enabled flag for that provider only',
      build: () => ChatCubit(),
      act: (cubit) => cubit.setProviderEnabled('lmstudio', true),
      expect: () => [isA<ChatConfigChanged>()],
      verify: (cubit) {
        expect(cubit.providerEnabled['lmstudio'], isTrue);
        expect(cubit.providerEnabled['openai'], isFalse);
      },
    );

    blocTest<ChatCubit, ChatState>(
      'removePendingAttachmentAt is a no-op (no emit) when the index is out of range',
      build: () => ChatCubit(),
      act: (cubit) => cubit.removePendingAttachmentAt(0),
      expect: () => <ChatState>[],
    );

    blocTest<ChatCubit, ChatState>(
      'clearPendingAttachments is a no-op (no emit) when already empty',
      build: () => ChatCubit(),
      act: (cubit) => cubit.clearPendingAttachments(),
      expect: () => <ChatState>[],
    );

    blocTest<ChatCubit, ChatState>(
      'resetForLogout clears active conversation/provider/model and caches',
      build: () => ChatCubit(),
      act: (cubit) {
        cubit.activeConversationId = 'conv-1';
        cubit.activeProvider = 'openai';
        cubit.activeModel = 'gpt-4o';
        cubit.resetForLogout();
      },
      expect: () => [isA<ChatConfigChanged>()],
      verify: (cubit) {
        expect(cubit.activeConversationId, isNull);
        expect(cubit.activeProvider, isNull);
        expect(cubit.activeModel, isNull);
        expect(cubit.cachedMessages, isEmpty);
        expect(cubit.cachedConversations, isEmpty);
      },
    );

    blocTest<ChatCubit, ChatState>(
      'resetForLogout(clearSelections: true) also clears selected models and priorities',
      build: () => ChatCubit(),
      act: (cubit) {
        cubit.setSelectedProviderLLMs('openai', ['gpt-4o']);
        cubit.resetForLogout(clearSelections: true);
      },
      verify: (cubit) {
        expect(cubit.selectedProviderLLMs['openai'], isEmpty);
        expect(cubit.providerModelPriority['openai'], isEmpty);
      },
    );
  });
}
