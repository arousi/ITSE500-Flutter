// ChatCubit.sendMessage's actual provider round-trip (HTTP request/stream/
// persistence) is NOT covered here: it reaches through _secureStorage,
// ChatRepository, and ProviderAdapterFactory, all directly instantiated
// with no DI seam (see the "untestable without refactor" note in the test
// report). What IS dependency-free and safely testable is sendMessage's
// up-front validation/guard logic, which runs before any network or
// storage access and fully determines whether a send is attempted at all.
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_itse500/core/models/message_request.dart';
import 'package:flutter_app_itse500/features/chat/logic/chat_cubit.dart';
import 'package:flutter_app_itse500/features/chat/logic/chat_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChatCubit.sendMessage guard rails', () {
    blocTest<ChatCubit, ChatState>(
      'emits ChatError and does not attempt a send when no provider is '
      'enabled/connected (multiProvider routing with an empty target set)',
      build: () => ChatCubit(),
      act: (cubit) => cubit.sendMessage(
        request: MessageRequest(requestId: 'r1', requestUserContent: 'hi'),
      ),
      expect: () => [
        isA<ChatError>().having(
            (e) => e.error, 'error', 'No providers enabled / connected'),
      ],
    );

    blocTest<ChatCubit, ChatState>(
      'ensureConversation() lazily creates and reuses a stable conversation id',
      build: () => ChatCubit(),
      verify: (cubit) {
        final id1 = cubit.ensureConversation();
        final id2 = cubit.ensureConversation();
        expect(id1, id2);
        expect(cubit.activeConversationId, id1);
      },
    );

    blocTest<ChatCubit, ChatState>(
      'setActiveProviderModel updates provider/model and emits ChatConfigChanged',
      build: () => ChatCubit(),
      act: (cubit) => cubit.setActiveProviderModel('openai', 'gpt-4o'),
      expect: () => [isA<ChatConfigChanged>()],
      verify: (cubit) {
        expect(cubit.activeProvider, 'openai');
        expect(cubit.activeModel, 'gpt-4o');
      },
    );
  });
}
