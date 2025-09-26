part of 'inference_settings_cubit.dart';

class InferenceSettingsState extends Equatable {
  final bool useTemperature;
  final bool useTopK;
  final bool useMinP;
  final bool useTopP;
  final bool useRepeatPenalty;
  final bool useSystemPrompt;
  final bool useStructuredOutput;
  final double temperature;
  final double topK;
  final double minP;
  final double topP;
  final double repeatPenalty;
  final bool localOnly;
  final bool mixedStorage;
  final String systemPrompt;
  final String structuredSchema; // JSON schema or format instructions
  const InferenceSettingsState({
    this.useTemperature = false,
    this.useTopK = false,
    this.useMinP = false,
    this.useTopP = false,
    this.useRepeatPenalty = false,
    this.useSystemPrompt = false,
    this.useStructuredOutput = false,
    this.temperature = 0.84,
    this.topK = 40,
    this.minP = 0.3,
    this.topP = 0.3,
    this.repeatPenalty = 1.1,
    this.localOnly = false,
    this.mixedStorage = true,
    this.systemPrompt = '',
    this.structuredSchema = '',
  });
  InferenceSettingsState copyWith({
    bool? useTemperature,
    bool? useTopK,
    bool? useMinP,
    bool? useTopP,
    bool? useRepeatPenalty,
    bool? useSystemPrompt,
    bool? useStructuredOutput,
    double? temperature,
    double? topK,
    double? minP,
    double? topP,
    double? repeatPenalty,
    bool? localOnly,
    bool? mixedStorage,
    String? systemPrompt,
    String? structuredSchema,
  }) =>
      InferenceSettingsState(
        useTemperature: useTemperature ?? this.useTemperature,
        useTopK: useTopK ?? this.useTopK,
        useMinP: useMinP ?? this.useMinP,
        useTopP: useTopP ?? this.useTopP,
        useRepeatPenalty: useRepeatPenalty ?? this.useRepeatPenalty,
        useSystemPrompt: useSystemPrompt ?? this.useSystemPrompt,
        useStructuredOutput: useStructuredOutput ?? this.useStructuredOutput,
        temperature: temperature ?? this.temperature,
        topK: topK ?? this.topK,
        minP: minP ?? this.minP,
        topP: topP ?? this.topP,
        repeatPenalty: repeatPenalty ?? this.repeatPenalty,
        localOnly: localOnly ?? this.localOnly,
        mixedStorage: mixedStorage ?? this.mixedStorage,
        systemPrompt: systemPrompt ?? this.systemPrompt,
        structuredSchema: structuredSchema ?? this.structuredSchema,
      );
  @override
  List<Object?> get props => [
        useTemperature,
        useTopK,
        useMinP,
        useTopP,
        useRepeatPenalty,
        useSystemPrompt,
        useStructuredOutput,
        temperature,
        topK,
        minP,
        topP,
        repeatPenalty,
        localOnly,
        mixedStorage,
        systemPrompt,
        structuredSchema
      ];
}
