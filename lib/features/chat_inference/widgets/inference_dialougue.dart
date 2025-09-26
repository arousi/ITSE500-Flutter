import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../logic/inference_settings_cubit.dart';

class InferenceDialogue extends StatelessWidget {
  const InferenceDialogue({super.key});

  @override
  Widget build(BuildContext context) {
    const storage = FlutterSecureStorage();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<InferenceSettingsCubit, InferenceSettingsState>(
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Inference Parameters',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _ParamRow(
                  label: 'Temperature',
                  use: state.useTemperature,
                  value: state.temperature,
                  min: 0.0,
                  max: 2.0,
                  divisions: 40,
                  valueFormat: (v) => v.toStringAsFixed(2),
                  onUseChanged: (v) => context
                      .read<InferenceSettingsCubit>()
                      .setUseTemperature(v),
                  onChanged: (v) =>
                      context.read<InferenceSettingsCubit>().setTemperature(v),
                ),
                _ParamRow(
                  label: 'Top K',
                  use: state.useTopK,
                  value: state.topK,
                  min: 1,
                  max: 200,
                  divisions: 199,
                  valueFormat: (v) => v.toStringAsFixed(0),
                  onUseChanged: (v) =>
                      context.read<InferenceSettingsCubit>().setUseTopK(v),
                  onChanged: (v) =>
                      context.read<InferenceSettingsCubit>().setTopK(v),
                ),
                _ParamRow(
                  label: 'Min P',
                  use: state.useMinP,
                  value: state.minP,
                  min: 0.0,
                  max: 1.0,
                  divisions: 100,
                  valueFormat: (v) => v.toStringAsFixed(2),
                  onUseChanged: (v) =>
                      context.read<InferenceSettingsCubit>().setUseMinP(v),
                  onChanged: (v) =>
                      context.read<InferenceSettingsCubit>().setMinP(v),
                ),
                _ParamRow(
                  label: 'Top P',
                  use: state.useTopP,
                  value: state.topP,
                  min: 0.0,
                  max: 1.0,
                  divisions: 100,
                  valueFormat: (v) => v.toStringAsFixed(2),
                  onUseChanged: (v) =>
                      context.read<InferenceSettingsCubit>().setUseTopP(v),
                  onChanged: (v) =>
                      context.read<InferenceSettingsCubit>().setTopP(v),
                ),
                _ParamRow(
                  label: 'Repeat Penalty',
                  use: state.useRepeatPenalty,
                  value: state.repeatPenalty,
                  min: 0.5,
                  max: 2.0,
                  divisions: 150,
                  valueFormat: (v) => v.toStringAsFixed(2),
                  onUseChanged: (v) => context
                      .read<InferenceSettingsCubit>()
                      .setUseRepeatPenalty(v),
                  onChanged: (v) => context
                      .read<InferenceSettingsCubit>()
                      .setRepeatPenalty(v),
                ),
                const SizedBox(height: 12),
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
                        await storage.write(
                            key: 'inference_temperature',
                            value: state.temperature.toString());
                        await storage.write(
                            key: 'inference_top_k',
                            value: state.topK.toString());
                        await storage.write(
                            key: 'inference_min_p',
                            value: state.minP.toString());
                        await storage.write(
                            key: 'inference_top_p',
                            value: state.topP.toString());
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
                          ].map((e) => e ? '1' : '0').join(','),
                        );
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop();
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ParamRow extends StatelessWidget {
  final String label;
  final bool use;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<bool> onUseChanged;
  final ValueChanged<double> onChanged;
  final String Function(double) valueFormat;
  const _ParamRow({
    required this.label,
    required this.use,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onUseChanged,
    required this.onChanged,
    required this.valueFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 110,
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
                          fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          Expanded(
            child: Opacity(
              opacity: use ? 1 : 0.35,
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                divisions: divisions,
                onChanged: use ? onChanged : null,
              ),
            ),
          ),
          SizedBox(
            width: 48,
            child: Text(
              valueFormat(value),
              textAlign: TextAlign.end,
              style: TextStyle(
                  fontSize: 12, color: use ? Colors.black : Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
