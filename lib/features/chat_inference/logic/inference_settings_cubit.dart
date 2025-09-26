import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'inference_settings_state.dart';

class InferenceSettingsCubit extends Cubit<InferenceSettingsState> {
  InferenceSettingsCubit() : super(const InferenceSettingsState());

  void update(InferenceSettingsState newState) => emit(newState);
  void setTemperature(double v) => emit(state.copyWith(temperature: v));
  void setTopK(double v) => emit(state.copyWith(topK: v));
  void setMinP(double v) => emit(state.copyWith(minP: v));
  void setTopP(double v) => emit(state.copyWith(topP: v));
  void setRepeatPenalty(double v) => emit(state.copyWith(repeatPenalty: v));
  void setUseTemperature(bool v) => emit(state.copyWith(useTemperature: v));
  void setUseTopK(bool v) => emit(state.copyWith(useTopK: v));
  void setUseMinP(bool v) => emit(state.copyWith(useMinP: v));
  void setUseTopP(bool v) => emit(state.copyWith(useTopP: v));
  void setUseRepeatPenalty(bool v) => emit(state.copyWith(useRepeatPenalty: v));
  void setLocalOnly(bool v) =>
      emit(state.copyWith(localOnly: v, mixedStorage: !v));
  void setMixedStorage(bool v) =>
      emit(state.copyWith(mixedStorage: v, localOnly: !v));
  void setUseSystemPrompt(bool v) => emit(state.copyWith(useSystemPrompt: v));
  void setSystemPrompt(String v) => emit(state.copyWith(systemPrompt: v));
  void setUseStructuredOutput(bool v) =>
      emit(state.copyWith(useStructuredOutput: v));
  void setStructuredSchema(String v) =>
      emit(state.copyWith(structuredSchema: v));
}
