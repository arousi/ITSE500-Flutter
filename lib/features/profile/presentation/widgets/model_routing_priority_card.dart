import 'package:flutter/material.dart';
import '../../../chat/logic/chat_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../screens/widgets/priority_multi_select.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app_itse500/l10n/app_localizations.dart';

class ModelRoutingPriorityCard extends StatelessWidget {
  const ModelRoutingPriorityCard({super.key});

  @override
  Widget build(BuildContext context) {
    final chatCubit = context.watch<ChatCubit>();
    final providers = chatCubit.supportedProviders;
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.route, size: 16),
                const SizedBox(width: 6),
                Text(l10n.modelRoutingPriority,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push('/models'),
                  child: Text(l10n.catalog),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...providers.map((p) {
              final enabled = chatCubit.providerEnabled[p] ?? false;
              final connected = chatCubit.providerConnected[p] ?? false;
              final rawModels = chatCubit.providerLLMs[p] ?? const <String>[];
              final seenModels = <String>{};
              final models = rawModels.where((m) => seenModels.add(m)).toList();
              if (!enabled) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Opacity(
                      opacity: 0.6,
                      child: Text(l10n.providerDisabledLabel(p),
                          style: Theme.of(context).textTheme.bodySmall)),
                );
              }
              final current =
                  chatCubit.providerModelPriority[p] ?? const <String>[];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(
                        p.toUpperCase() +
                            (p == 'huggingface'
                                ? ' ${l10n.alphaFeature}'
                                : ''),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    if (connected)
                      const Icon(Icons.cloud_done,
                          size: 14, color: Colors.green)
                    else
                      const Icon(Icons.cloud_off, size: 14, color: Colors.red),
                    if (p == 'huggingface') const SizedBox(width: 6),
                    if (p == 'huggingface')
                      Tooltip(
                          message: l10n.chatEmbeddingsDisabledTooltip,
                          child: const Icon(Icons.science,
                              size: 14, color: Colors.orange)),
                  ]),
                  if (models.isEmpty)
                    Text(l10n.fetchModelsFirst,
                        style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withOpacity(0.7))),
                  if (models.isNotEmpty)
                    PriorityMultiSelect(
                        provider: p,
                        models: models,
                        current: current,
                        onChanged: (ordered) =>
                            chatCubit.setProviderModelPriority(p, ordered)),
                  const Divider(height: 12),
                ],
              );
            }),
            Text(
              l10n.priorityFailoverExplanation,
              style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withOpacity(0.7)),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.invalidModelsClearedExplanation,
              style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }
}
