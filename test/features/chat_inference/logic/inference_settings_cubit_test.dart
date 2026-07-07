import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_itse500/features/chat_inference/logic/inference_settings_cubit.dart';

void main() {
  group('InferenceSettingsCubit', () {
    test('initial state has documented defaults', () {
      final cubit = InferenceSettingsCubit();
      expect(cubit.state.temperature, 0.84);
      expect(cubit.state.topK, 40);
      expect(cubit.state.minP, 0.3);
      expect(cubit.state.topP, 0.3);
      expect(cubit.state.repeatPenalty, 1.1);
      expect(cubit.state.useTemperature, isFalse);
      expect(cubit.state.localOnly, isFalse);
      expect(cubit.state.mixedStorage, isTrue);
      cubit.close();
    });

    blocTest<InferenceSettingsCubit, InferenceSettingsState>(
      'setTemperature updates only the temperature field',
      build: () => InferenceSettingsCubit(),
      act: (cubit) => cubit.setTemperature(1.2),
      expect: () => [
        isA<InferenceSettingsState>().having(
            (s) => s.temperature, 'temperature', 1.2),
      ],
    );

    blocTest<InferenceSettingsCubit, InferenceSettingsState>(
      'setLocalOnly(true) also flips mixedStorage to false (mutually exclusive)',
      build: () => InferenceSettingsCubit(),
      act: (cubit) => cubit.setLocalOnly(true),
      expect: () => [
        isA<InferenceSettingsState>()
            .having((s) => s.localOnly, 'localOnly', isTrue)
            .having((s) => s.mixedStorage, 'mixedStorage', isFalse),
      ],
    );

    blocTest<InferenceSettingsCubit, InferenceSettingsState>(
      'setMixedStorage(true) also flips localOnly to false (mutually exclusive)',
      build: () => InferenceSettingsCubit(),
      seed: () => const InferenceSettingsState(localOnly: true, mixedStorage: false),
      act: (cubit) => cubit.setMixedStorage(true),
      expect: () => [
        isA<InferenceSettingsState>()
            .having((s) => s.mixedStorage, 'mixedStorage', isTrue)
            .having((s) => s.localOnly, 'localOnly', isFalse),
      ],
    );

    blocTest<InferenceSettingsCubit, InferenceSettingsState>(
      'toggling useStructuredOutput and setting a schema emits two states in order',
      build: () => InferenceSettingsCubit(),
      act: (cubit) {
        cubit.setUseStructuredOutput(true);
        cubit.setStructuredSchema('{"type":"object"}');
      },
      expect: () => [
        isA<InferenceSettingsState>()
            .having((s) => s.useStructuredOutput, 'useStructuredOutput', isTrue),
        isA<InferenceSettingsState>().having(
            (s) => s.structuredSchema, 'structuredSchema', '{"type":"object"}'),
      ],
    );

    blocTest<InferenceSettingsCubit, InferenceSettingsState>(
      'update() replaces the entire state wholesale',
      build: () => InferenceSettingsCubit(),
      act: (cubit) => cubit.update(
        const InferenceSettingsState(temperature: 2.0, useTopK: true),
      ),
      expect: () => [
        const InferenceSettingsState(temperature: 2.0, useTopK: true),
      ],
    );
  });
}
