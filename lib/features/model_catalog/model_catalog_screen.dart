import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'logic/model_catalog_cubit.dart';
import 'package:flutter_app_itse500/core/models/model_descriptor.dart';
import 'package:flutter_app_itse500/l10n/app_localizations.dart';

class ModelCatalogScreen extends StatelessWidget {
  const ModelCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final providers = [
      (ProviderType.openrouter, 'OpenRouter', 'https://openrouter.ai/models'),
      (
        ProviderType.openai,
        'OpenAI',
        'https://platform.openai.com/docs/pricing'
      ),
      (
        ProviderType.gemini,
        'Gemini',
        'https://ai.google.dev/gemini-api/docs/models'
      ),
      (ProviderType.lmstudio, 'LM Studio', 'https://lmstudio.ai'),
      (
        ProviderType.huggingface,
        'HuggingFace',
        'https://huggingface.co/models'
      ),
    ];
    return BlocProvider(
      create: (_) => ModelCatalogCubit(),
      child: BlocBuilder<ModelCatalogCubit, ModelCatalogState>(
        builder: (context, state) {
          final l10n = AppLocalizations.of(context)!;
          return Scaffold(
            // MainScreen supplies the top AppBar. Provide inline header + actions.
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 8, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(l10n.modelCatalog,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                      ),
                      IconButton(
                        tooltip: l10n.refreshAll,
                        onPressed: () async {
                          final cubit = context.read<ModelCatalogCubit>();
                          for (final (p, _, __) in providers) {
                            await cubit.ensureLoaded(
                                provider: p,
                                credential: null,
                                forceRefresh: true);
                          }
                        },
                        icon: const Icon(Icons.refresh),
                      )
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.separated(
                    itemCount: providers.length,
                    separatorBuilder: (_, __) => const Divider(height: 0),
                    itemBuilder: (ctx, i) {
                      final (prov, name, url) = providers[i];
                      final key =
                          prov.name; // route arg remains lowercase enum name
                      final models = state.models[prov];
                      final last = state.lastUpdated[prov];
                      final isLoading =
                          state.loading && (models == null || models.isEmpty);
                      return ListTile(
                        title: Text(name),
                        subtitle:
                            Text(url, style: const TextStyle(fontSize: 11)),
                        trailing: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                      models == null
                                          ? '—'
                                          : l10n.modelsCount(models.length),
                                      style: const TextStyle(fontSize: 11)),
                                  if (last != null)
                                    Text(_ago(last, l10n),
                                        style: const TextStyle(
                                            fontSize: 10, color: Colors.grey)),
                                ],
                              ),
                        onTap: () async {
                          await context
                              .read<ModelCatalogCubit>()
                              .ensureLoaded(provider: prov, credential: null);
                          ctx.push('/models/$key');
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

String _ago(DateTime dt, AppLocalizations l10n) {
  final d = DateTime.now().difference(dt);
  if (d.inMinutes < 1) return l10n.justNow;
  if (d.inMinutes < 60) return l10n.minutesAgo(d.inMinutes);
  if (d.inHours < 24) return l10n.hoursAgo(d.inHours);
  return l10n.daysAgo(d.inDays);
}
