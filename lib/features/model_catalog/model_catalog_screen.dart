import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'logic/model_catalog_cubit.dart';
import 'package:flutter_app_itse500/core/models/model_descriptor.dart';

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
          return Scaffold(
            // MainScreen supplies the top AppBar. Provide inline header + actions.
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text('Model Catalog',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                      ),
                      IconButton(
                        tooltip: 'Refresh all',
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
                                          : '${models.length} models',
                                      style: const TextStyle(fontSize: 11)),
                                  if (last != null)
                                    Text(_ago(last),
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

String _ago(DateTime dt) {
  final d = DateTime.now().difference(dt);
  if (d.inMinutes < 1) return 'just now';
  if (d.inMinutes < 60) return '${d.inMinutes}m ago';
  if (d.inHours < 24) return '${d.inHours}h ago';
  return '${d.inDays}d ago';
}
