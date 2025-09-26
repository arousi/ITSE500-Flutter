import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_app_itse500/features/chat/logic/chat_cubit.dart';
import 'package:flutter_app_itse500/features/chat_inference/logic/inference_settings_cubit.dart';

class ConfigureDialog extends StatefulWidget {
  const ConfigureDialog({super.key});
  @override
  State<ConfigureDialog> createState() => _ConfigureDialogState();
}

class _ConfigureDialogState extends State<ConfigureDialog> {
  bool _providersExpanded = true;
  bool _settingsExpanded = false;
  bool _samplingExpanded = false;
  bool _structuredExpanded = false;
  bool _limitResponseLength = false; // placeholder future feature

  @override
  Widget build(BuildContext context) {
    final chatCubit = context.watch<ChatCubit>();
    final inferenceCubit = context.watch<InferenceSettingsCubit>();
    final state = inferenceCubit.state;
    final providerSet = <String>{
      ...chatCubit.providerApiKeys.keys,
      ...chatCubit.providerEnabled.keys,
      ...chatCubit.providerConnected.keys,
    };
    final providers = providerSet.toList()..sort();

    String displayName(String key) {
      switch (key) {
        case 'openai':
          return 'OpenAI';
        case 'openrouter':
          return 'OpenRouter';
        case 'google':
        case 'gemini':
          return 'Gemini';
        case 'lmstudio':
          return 'LM Studio';
        case 'huggingface':
          return 'HuggingFace';
        default:
          return key;
      }
    }

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 620, minWidth: 420),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Configuration',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _section(
                        title: 'Providers',
                        icon: Icons.dns_outlined,
                        expanded: _providersExpanded,
                        onToggle: () => setState(() {
                          final next = !_providersExpanded;
                          _providersExpanded = next;
                          if (next) {
                            _settingsExpanded = false;
                            _samplingExpanded = false;
                            _structuredExpanded = false;
                          }
                        }),
                        child: providers.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text('No providers available',
                                    style: TextStyle(color: Colors.redAccent)),
                              )
                            : Column(
                                children: providers.map((provider) {
                                  final connected =
                                      chatCubit.providerConnected[provider] ??
                                          false;
                                  final enabled =
                                      chatCubit.providerEnabled[provider] ??
                                          false;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: connected
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(displayName(provider),
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600)),
                                        ),
                                        Switch.adaptive(
                                          value: enabled,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          onChanged: (val) async {
                                            if (!val) {
                                              chatCubit.setProviderEnabled(
                                                  provider, false);
                                              chatCubit.setProviderConnected(
                                                  provider, false);
                                              return;
                                            }
                                            // Ensure key loaded (after app restart cache may be empty)
                                            var key = chatCubit
                                                .providerApiKeys[provider];
                                            if (key == null || key.isEmpty) {
                                              key = await chatCubit
                                                  .getApiKey(provider);
                                              if (key != null &&
                                                  key.isNotEmpty) {
                                                chatCubit.providerApiKeys[
                                                    provider] = key;
                                              }
                                            }
                                            if (key == null || key.isEmpty) {
                                              chatCubit.setProviderEnabled(
                                                  provider, false);
                                              chatCubit.setProviderConnected(
                                                  provider, false);
                                              if (mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          'Add API key for ${displayName(provider)} in Profile screen.')),
                                                );
                                              }
                                            } else {
                                              chatCubit.setProviderEnabled(
                                                  provider, true);
                                              chatCubit.setProviderConnected(
                                                  provider, true);
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                      _section(
                        title: 'Settings',
                        icon: Icons.settings_outlined,
                        expanded: _settingsExpanded,
                        onToggle: () => setState(() {
                          final next = !_settingsExpanded;
                          _settingsExpanded = next;
                          if (next) {
                            _providersExpanded = false;
                            _samplingExpanded = false;
                            _structuredExpanded = false;
                          }
                        }),
                        child: Column(
                          children: [
                            _buildSystemPromptSection(context, state),
                            const SizedBox(height: 8),
                            _buildSliderToggle(
                              context: context,
                              label: 'Temperature',
                              use: state.useTemperature,
                              value: state.temperature,
                              min: 0.0,
                              max: 2.0,
                              divisions: 40,
                              onUseChanged: (v) => context
                                  .read<InferenceSettingsCubit>()
                                  .setUseTemperature(v),
                              onChanged: (v) => context
                                  .read<InferenceSettingsCubit>()
                                  .setTemperature(v),
                            ),
                            Row(
                              children: [
                                Switch(
                                  value: _limitResponseLength,
                                  onChanged: (v) =>
                                      setState(() => _limitResponseLength = v),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                const SizedBox(width: 4),
                                const Text('Limit Response Length',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _section(
                        title: 'Sampling',
                        icon: Icons.tune_outlined,
                        expanded: _samplingExpanded,
                        onToggle: () => setState(() {
                          final next = !_samplingExpanded;
                          _samplingExpanded = next;
                          if (next) {
                            _providersExpanded = false;
                            _settingsExpanded = false;
                            _structuredExpanded = false;
                          }
                        }),
                        child: Column(
                          children: [
                            _buildSliderToggle(
                              context: context,
                              label: 'Top K',
                              use: state.useTopK,
                              value: state.topK,
                              min: 1,
                              max: 200,
                              divisions: 199,
                              onUseChanged: (v) => context
                                  .read<InferenceSettingsCubit>()
                                  .setUseTopK(v),
                              onChanged: (v) => context
                                  .read<InferenceSettingsCubit>()
                                  .setTopK(v),
                            ),
                            _buildSliderToggle(
                              context: context,
                              label: 'Repeat Penalty',
                              use: state.useRepeatPenalty,
                              value: state.repeatPenalty,
                              min: 0.5,
                              max: 2.0,
                              divisions: 150,
                              onUseChanged: (v) => context
                                  .read<InferenceSettingsCubit>()
                                  .setUseRepeatPenalty(v),
                              onChanged: (v) => context
                                  .read<InferenceSettingsCubit>()
                                  .setRepeatPenalty(v),
                            ),
                            _buildSliderToggle(
                              context: context,
                              label: 'Min P',
                              use: state.useMinP,
                              value: state.minP,
                              min: 0.0,
                              max: 1.0,
                              divisions: 100,
                              onUseChanged: (v) => context
                                  .read<InferenceSettingsCubit>()
                                  .setUseMinP(v),
                              onChanged: (v) => context
                                  .read<InferenceSettingsCubit>()
                                  .setMinP(v),
                            ),
                            _buildSliderToggle(
                              context: context,
                              label: 'Top P',
                              use: state.useTopP,
                              value: state.topP,
                              min: 0.0,
                              max: 1.0,
                              divisions: 100,
                              onUseChanged: (v) => context
                                  .read<InferenceSettingsCubit>()
                                  .setUseTopP(v),
                              onChanged: (v) => context
                                  .read<InferenceSettingsCubit>()
                                  .setTopP(v),
                            ),
                          ],
                        ),
                      ),
                      _section(
                        title: 'Structured Output',
                        icon: Icons.data_object_outlined,
                        expanded: _structuredExpanded,
                        onToggle: () => setState(() {
                          final next = !_structuredExpanded;
                          _structuredExpanded = next;
                          if (next) {
                            _providersExpanded = false;
                            _settingsExpanded = false;
                            _samplingExpanded = false;
                          }
                        }),
                        child: _buildStructuredOutputSection(context, state),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () async {
                      const storage = FlutterSecureStorage();
                      await storage.write(
                          key: 'inference_temperature',
                          value: state.temperature.toString());
                      await storage.write(
                          key: 'inference_top_k', value: state.topK.toString());
                      await storage.write(
                          key: 'inference_min_p', value: state.minP.toString());
                      await storage.write(
                          key: 'inference_top_p', value: state.topP.toString());
                      await storage.write(
                          key: 'inference_repeat_penalty',
                          value: state.repeatPenalty.toString());
                      await storage.write(
                        key: 'inference_use_flags',
                        value: [
                          state.useTemperature,
                          state.useTopK,
                          state.useMinP,
                          state.useTopP,
                          state.useRepeatPenalty,
                          state.useSystemPrompt,
                          state.useStructuredOutput,
                        ].map((e) => e ? '1' : '0').join(','),
                      );
                      await storage.write(
                          key: 'inference_system_prompt',
                          value: state.systemPrompt);
                      await storage.write(
                          key: 'inference_structured_schema',
                          value: state.structuredSchema);
                      if (mounted) Navigator.of(context).pop();
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required bool expanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          ListTile(
            dense: true,
            leading: Icon(icon, size: 20),
            title: Text(title,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            trailing: Icon(expanded ? Icons.expand_less : Icons.expand_more),
            onTap: onToggle,
          ),
          AnimatedCrossFade(
            crossFadeState:
                expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 180),
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: child,
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemPromptSection(
      BuildContext context, InferenceSettingsState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Switch(
              value: state.useSystemPrompt,
              onChanged: (v) =>
                  context.read<InferenceSettingsCubit>().setUseSystemPrompt(v),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 4),
            const Expanded(
              child: Text('System Prompt',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        AnimatedOpacity(
          opacity: state.useSystemPrompt ? 1.0 : 0.35,
          duration: const Duration(milliseconds: 200),
          child: TextField(
            enabled: state.useSystemPrompt,
            maxLines: 3,
            minLines: 1,
            decoration: const InputDecoration(
              hintText:
                  'Enter a persistent system instruction (e.g., You are a helpful assistant...)',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            controller: TextEditingController(text: state.systemPrompt),
            onChanged: (v) =>
                context.read<InferenceSettingsCubit>().setSystemPrompt(v),
          ),
        ),
      ],
    );
  }

  Widget _buildStructuredOutputSection(
      BuildContext context, InferenceSettingsState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Switch(
              value: state.useStructuredOutput,
              onChanged: (v) => context
                  .read<InferenceSettingsCubit>()
                  .setUseStructuredOutput(v),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 4),
            const Expanded(
              child: Text('Structured Output (JSON Schema)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        AnimatedOpacity(
          opacity: state.useStructuredOutput ? 1.0 : 0.35,
          duration: const Duration(milliseconds: 200),
          child: TextField(
            enabled: state.useStructuredOutput,
            maxLines: 6,
            minLines: 2,
            decoration: const InputDecoration(
              hintText: '{ "type": "object", "properties": { ... } }',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            controller: TextEditingController(text: state.structuredSchema),
            onChanged: (v) =>
                context.read<InferenceSettingsCubit>().setStructuredSchema(v),
          ),
        ),
      ],
    );
  }

  Widget _buildSliderToggle({
    required BuildContext context,
    required String label,
    required bool use,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<bool> onUseChanged,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 95,
            child: Row(
              children: [
                Switch(
                  value: use,
                  onChanged: onUseChanged,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                Expanded(
                  child: Text(label,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          Expanded(
            child: Opacity(
              opacity: use ? 1.0 : 0.35,
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                divisions: divisions,
                label: value.toStringAsFixed(2),
                onChanged: use ? onChanged : null,
              ),
            ),
          ),
          SizedBox(
            width: 42,
            child: Text(
              value.toStringAsFixed(value < 10 ? 2 : 0),
              textAlign: TextAlign.end,
              style: TextStyle(
                  fontSize: 11, color: use ? Colors.black : Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
