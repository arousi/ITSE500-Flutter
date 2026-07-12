import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app_itse500/core/models/conversation.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/repositories/data_repository.dart';
// import 'package:flutter_app_itse500/core/widgets/conversation_widget.dart'; // legacy widget replaced by inline ListTile
import 'package:flutter_app_itse500/features/auth/presentation/widgets/logoutButton.dart';
import 'package:flutter_app_itse500/features/profile/presentation/widgets/profile_button.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app_itse500/shared_preferences.dart';
import 'package:flutter_app_itse500/l10n/app_localizations.dart';

class CustomDrawer extends StatefulWidget {
  final ValueChanged<Conversation> onConversationTap;
  const CustomDrawer({super.key, required this.onConversationTap});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  late Future<List<Conversation>> _conversationsFuture;
  late final StreamSubscription _sub;
  bool _selectionMode = false;
  final Set<String> _selectedIds = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload when drawer context changes (e.g., newly opened)
    _reload();
  }

  void _reload() {
    setState(() {
      _conversationsFuture = fetchConversations();
    });
  }

  Future<List<Conversation>> fetchConversations() async {
    final repo = DataRepository();
    await repo.backfillConversationsFromMessages();
    return await repo.fetchConversations();
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _conversationsFuture = fetchConversations();
    // Listen for sync events and refresh automatically
    _sub = DataRepository().conversationsChanged.stream.listen((_) {
      if (mounted) _reload();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine global storage mode to adjust UI (no per-conversation toggle in local-only mode)
    return FutureBuilder<String?>(
      future: SharedPref().getString('storage_mode'),
      builder: (ctx, modeSnap) {
        final storageMode =
            (modeSnap.data == 'mixed' || modeSnap.data == 'local')
                ? modeSnap.data
                : 'local';
        return Drawer(
          child: SafeArea(
            child: Column(
              children: [
                // Action bar when in selection mode
                if (_selectionMode)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: AppLocalizations.of(context)!.selectAll,
                          icon: const Icon(Icons.select_all),
                          onPressed: () {
                            setState(() {
                              // Bulk select all current conversations (async list not yet loaded -> no-op)
                            });
                          },
                        ),
                        Text(AppLocalizations.of(context)!
                            .selectedCount(_selectedIds.length)),
                        const Spacer(),
                        IconButton(
                          tooltip: AppLocalizations.of(context)!.deleteSelected,
                          icon: const Icon(Icons.delete_forever,
                              color: Colors.red),
                          onPressed: _selectedIds.isEmpty
                              ? null
                              : () async {
                                  final l10n = AppLocalizations.of(context)!;
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text(l10n
                                          .deleteSelectedConversationsTitle),
                                      content: Text(l10n
                                          .deleteSelectedConversationsBody(
                                              _selectedIds.length)),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: Text(l10n.cancel)),
                                        FilledButton.tonal(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: Text(l10n.delete)),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true) {
                                    final repo = DataRepository();
                                    await repo.deleteConversations(
                                        _selectedIds.toList());
                                    setState(() {
                                      _selectedIds.clear();
                                      _selectionMode = false;
                                    });
                                  }
                                },
                        ),
                        IconButton(
                          tooltip:
                              AppLocalizations.of(context)!.cancelSelection,
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() {
                            _selectionMode = false;
                            _selectedIds.clear();
                          }),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      _reload();
                      await _conversationsFuture;
                    },
                    child: FutureBuilder<List<Conversation>>(
                      future: _conversationsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                              child: Text(AppLocalizations.of(context)!
                                  .noConversationsFound));
                        }
                        final conversations = snapshot.data!;
                        return ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: conversations.length,
                          itemBuilder: (context, index) {
                            final conv = conversations[index];
                            final selected =
                                _selectedIds.contains(conv.conversationId);
                            return GestureDetector(
                              onLongPress: () {
                                setState(() {
                                  _selectionMode = true;
                                  _selectedIds.add(conv.conversationId);
                                });
                              },
                              child: Container(
                                color: selected
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.15)
                                    : null,
                                child: ListTile(
                                  leading: SizedBox(
                                    width: 28,
                                    child: Center(
                                      child: _selectionMode
                                          ? Checkbox(
                                              value: selected,
                                              onChanged: (v) {
                                                setState(() {
                                                  if (v == true) {
                                                    _selectedIds.add(
                                                        conv.conversationId);
                                                  } else {
                                                    _selectedIds.remove(
                                                        conv.conversationId);
                                                  }
                                                });
                                              },
                                            )
                                          : (conv.localOnly
                                              ? Image.asset(
                                                  'assets/imgs/inPrivate-Avatar.png',
                                                  width: 22,
                                                  height: 22,
                                                  errorBuilder: (c, e, st) =>
                                                      const Icon(
                                                          Icons.lock_outline,
                                                          size: 20),
                                                  semanticLabel:
                                                      'Private Conversation',
                                                )
                                              : const Icon(
                                                  Icons.chat_bubble_outline,
                                                  size: 20)),
                                    ),
                                  ),
                                  title: Text(conv.title ?? 'Untitled',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                  subtitle: conv.localOnly
                                      ? const Text('In-Private',
                                          style: TextStyle(fontSize: 11))
                                      : null,
                                  trailing:
                                      !_selectionMode && storageMode == 'mixed'
                                          ? IconButton(
                                              tooltip: conv.localOnly
                                                  ? 'Allow future sync'
                                                  : 'Make private (local-only)',
                                              icon: Icon(
                                                  conv.localOnly
                                                      ? Icons.visibility
                                                      : Icons.lock_outline,
                                                  size: 18),
                                              onPressed: () async {
                                                final repo = DataRepository();
                                                await repo
                                                    .updateConversationLocalOnly(
                                                        conv.conversationId,
                                                        !conv.localOnly);
                                                _reload();
                                              },
                                            )
                                          : null,
                                  onTap: () {
                                    if (_selectionMode) {
                                      setState(() {
                                        if (selected) {
                                          _selectedIds
                                              .remove(conv.conversationId);
                                          if (_selectedIds.isEmpty)
                                            _selectionMode = false;
                                        } else {
                                          _selectedIds.add(conv.conversationId);
                                        }
                                      });
                                    } else {
                                      Navigator.of(context).pop();
                                      widget.onConversationTap(conv);
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 16, 12),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.auto_awesome_motion, size: 18),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Future.microtask(
                                () => GoRouter.of(context).push('/models'));
                          },
                          label:
                              Text(AppLocalizations.of(context)!.modelCatalog),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const SizedBox(
                        width: double.infinity,
                        child: ProfileButton(),
                      ),
                      const SizedBox(height: 8),
                      const SizedBox(
                        width: double.infinity,
                        child: LogoutButton(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
