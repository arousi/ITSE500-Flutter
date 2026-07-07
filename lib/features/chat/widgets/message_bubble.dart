import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import 'dart:io';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_app_itse500/core/models/message.dart';
import 'package:flutter_app_itse500/core/widgets/toaster.dart';
import 'package:flutter_app_itse500/core/utils/crypto/artifact_encryptor.dart';
import 'dart:convert';
import 'package:flutter_app_itse500/core/theme/app_theme.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  const MessageBubble({super.key, required this.message});

  @override
  MessageBubbleState createState() => MessageBubbleState();
}

class MessageBubbleState extends State<MessageBubble> {
  @override
  Widget build(BuildContext context) {
    final meta = widget.message.metadata ?? {};
    final String userContent = (meta['user_content'] ?? '').toString();
    final String llmOutput =
        (meta['output_text'] ?? meta['streaming_text'] ?? '').toString();
    final bool isStreaming = meta['streaming'] == true &&
        (meta['output_text'] == null ||
            (meta['output_text'] as String).isEmpty);
    final List<dynamic> attachments =
        (meta['attachments'] as List?) ?? const [];
    final List<dynamic> generated =
        (meta['generated_attachments'] as List?) ?? const [];
    // Parse inline annotations (Gemini image outputs) if present and not already persisted.
    List<Map<String, dynamic>> inlineImages = [];
    final ann = meta['output_annotations'];
    if (generated.isEmpty && ann is String && ann.contains('images')) {
      try {
        final decoded = jsonDecode(ann);
        if (decoded is Map && decoded['images'] is List) {
          for (final img in (decoded['images'] as List)) {
            if (img is Map && img['b64'] is String) {
              inlineImages.add({
                'b64': img['b64'],
                'mime': img['mime'] ?? 'image/png',
              });
            }
          }
        }
      } catch (_) {}
    }
    final String role = (meta['role'] ?? '').toString();
    final bool billingRequired = meta['billing_required'] == true;
    final String errorText = (meta['error_text'] ?? '').toString();

    final bubbles = <Widget>[];

    // Constrain bubble width with a cap, but let short content size naturally
    final screenWidth = MediaQuery.of(context).size.width;
    final double maxBubbleWidth = math.min(screenWidth * 0.85, 700.0);

    final isUserBubble =
        role == 'user' || (role.isEmpty && userContent.isNotEmpty);
    if (isUserBubble && (userContent.isNotEmpty || attachments.isNotEmpty)) {
      bubbles.add(
        Align(
          alignment: Alignment.centerRight,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxBubbleWidth),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).extension<AppPalette>()?.userBubble ??
                    Colors.blue[100]!,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (userContent.isNotEmpty)
                    _MarkdownOrPlain(
                      text: userContent,
                      isAssistant: false,
                      // Ensure high contrast in dark mode for user bubble
                      overrideColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : null,
                    ),
                  if (attachments.isNotEmpty) const SizedBox(height: 8),
                  if (attachments.isNotEmpty)
                    _DecryptedAttachments(attachments: attachments),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if ((llmOutput.isNotEmpty ||
            isStreaming ||
            inlineImages.isNotEmpty ||
            generated.isNotEmpty) &&
        role != 'user') {
      bubbles.add(
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxBubbleWidth),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                        .extension<AppPalette>()
                        ?.assistantBubble ??
                    Colors.grey[300]!,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (billingRequired && llmOutput.isEmpty && errorText.isEmpty)
                    _InlineNotice(
                        icon: Icons.credit_card,
                        color: Colors.orange[700]!,
                        text:
                            'Billing required for this model. Enable billing then retry.'),
                  if (errorText.isNotEmpty)
                    _InlineNotice(
                        icon: Icons.error_outline,
                        color: Colors.red[700]!,
                        text: errorText),
                  if (!isStreaming && llmOutput.isNotEmpty)
                    _CopyRow(
                        textToCopy: llmOutput, alignment: Alignment.centerLeft),
                  if (!isStreaming && llmOutput.isNotEmpty)
                    const SizedBox(height: 6),
                  // Show partial text while streaming, and keep dots as a tail indicator.
                  if (llmOutput.isNotEmpty)
                    _MarkdownOrPlain(
                      text: llmOutput,
                      isAssistant: true,
                    ),
                  if (isStreaming) const SizedBox(height: 6),
                  if (isStreaming) const _TypingDots(),
                  if (!isStreaming &&
                      (inlineImages.isNotEmpty || generated.isNotEmpty))
                    const SizedBox(height: 10),
                  if (!isStreaming &&
                      (inlineImages.isNotEmpty || generated.isNotEmpty))
                    _GeneratedImagesGallery(
                        inlineImages: inlineImages, generated: generated),
                  if (!isStreaming && llmOutput.isNotEmpty)
                    const SizedBox(height: 8),
                  if (!isStreaming && llmOutput.isNotEmpty)
                    _CopyRow(
                        textToCopy: llmOutput,
                        alignment: Alignment.centerRight),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (role == 'assistant' && attachments.isNotEmpty && llmOutput.isEmpty) {
      bubbles.add(
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxBubbleWidth),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: _DecryptedAttachments(attachments: attachments),
            ),
          ),
        ),
      );
    }

    // If neither exists, render an empty spacer to keep list stable
    if (bubbles.isEmpty) {
      return const SizedBox(height: 8);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: bubbles,
    );
  }
}

class _MarkdownOrPlain extends StatelessWidget {
  final String text;
  final bool isAssistant;
  final Color?
      overrideColor; // when provided, use this for text color for contrast
  const _MarkdownOrPlain(
      {required this.text, required this.isAssistant, this.overrideColor});

  @override
  Widget build(BuildContext context) {
    // Heuristic: markdown or URLs
    final hasMarkdown = text.contains('```') ||
        text.contains('# ') ||
        text.contains('* ') ||
        text.contains('- ') ||
        text.contains('> ');
    final hasUrl = RegExp(r'https?://').hasMatch(text);
    final baseStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 16,
          height: 1.35,
          color: overrideColor ?? Theme.of(context).textTheme.bodyMedium?.color,
        );
    final rtlReg = RegExp(r'[\u0600-\u06FF]');
    final isRtl = rtlReg.hasMatch(text);
    if (!hasMarkdown && !hasUrl) {
      return Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: SelectableText(
          text,
          style: baseStyle,
          textAlign: isRtl ? TextAlign.right : TextAlign.left,
        ),
      );
    }
    final onSurface = overrideColor ??
        Theme.of(context).textTheme.bodyMedium?.color ??
        (Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black87);
    final codeBg = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFEFEFEF);
    final codeBlockBg = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF262626)
        : const Color(0xFFF6F8FA);
    final blockquoteBg = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1B1B1B)
        : const Color(0xFFF0F0F0);
    final blockquoteBorder = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade700
        : Colors.grey;
    return MarkdownBody(
      data: text,
      selectable: true,
      softLineBreak: true,
      styleSheet: MarkdownStyleSheet(
        p: baseStyle?.copyWith(
            textBaseline: TextBaseline.alphabetic, color: onSurface),
        code: TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          backgroundColor: codeBg,
          color: onSurface,
        ),
        codeblockDecoration: BoxDecoration(
          color: codeBlockBg,
          borderRadius: BorderRadius.circular(8),
        ),
        codeblockPadding: const EdgeInsets.all(12),
        blockquote: baseStyle?.copyWith(color: onSurface.withOpacity(0.85)),
        blockquoteDecoration: BoxDecoration(
          color: blockquoteBg,
          border: Border(left: BorderSide(color: blockquoteBorder, width: 4)),
        ),
        h1: baseStyle?.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
        h2: baseStyle?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
        h3: baseStyle?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
        listBullet: baseStyle,
      ),
      onTapLink: (text, href, title) async {
        if (href == null) return;
        final uri = Uri.tryParse(href);
        if (uri != null) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
    );
  }
}

class _CopyRow extends StatelessWidget {
  final String textToCopy;
  final Alignment alignment;
  const _CopyRow({required this.textToCopy, required this.alignment});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: textToCopy));
          if (context.mounted) {
            Toaster.show(context, 'Copied to clipboard');
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.copy,
                size: 16,
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withOpacity(0.7)),
            const SizedBox(width: 4),
            Text('Copy',
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          final t = _controller.value;
          int active = (t * 3).floor() % 3;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final on = i == active;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.5),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 6,
                  height: on ? 10 : 6,
                  decoration: BoxDecoration(
                    color: on
                        ? (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black54)
                        : (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white24
                            : Colors.black26),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class _DecryptedAttachments extends StatefulWidget {
  final List<dynamic> attachments;
  const _DecryptedAttachments({required this.attachments});
  @override
  State<_DecryptedAttachments> createState() => _DecryptedAttachmentsState();
}

class _DecryptedAttachmentsState extends State<_DecryptedAttachments> {
  final Map<String, Uint8List?> _decrypted = {};
  final Map<String, bool> _loading = {};
  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    for (final raw in widget.attachments) {
      if (raw is! Map) continue;
      final path = raw['path'];
      if (path is String) {
        _loading[path] = true;
        _decryptAsync(raw);
      }
    }
  }

  Future<void> _decryptAsync(Map a) async {
    final path = a['path'];
    if (path is! String) return;
    try {
      final bytes = await File(path).readAsBytes();
      // For encrypted file: ciphertext + mac (last 16 bytes)
      if (a['is_encrypted'] == 1 || a['is_encrypted'] == true) {
        final ivB64 = a['iv_base64'] as String?;
        if (ivB64 != null) {
          const macLen = 16; // AES-GCM 128-bit
          if (bytes.length > macLen) {
            final cipher = bytes.sublist(0, bytes.length - macLen);
            final mac = bytes.sublist(bytes.length - macLen);
            final clear = await ArtifactEncryptor.instance.decryptToBytes(
              ciphertext: cipher,
              mac: mac,
              nonceB64: ivB64,
            );
            if (mounted) {
              setState(() {
                _decrypted[path] = clear;
              });
            }
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _decrypted[path] = Uint8List.fromList(bytes);
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _decrypted[path] = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading[path] = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.attachments.cast<Map?>().whereType<Map>().toList();
    final images = items.where((a) => (a['type'] == 'image')).toList();
    final others = items.where((a) => a['type'] != 'image').toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (images.isNotEmpty)
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) {
                final a = images[i];
                final path = a['path'] as String? ?? '';
                final data = _decrypted[path];
                final busy = _loading[path] == true;
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 160,
                        height: 140,
                        color: Colors.black12,
                        alignment: Alignment.center,
                        child: busy
                            ? const CircularProgressIndicator(strokeWidth: 2)
                            : (data == null
                                ? const Icon(Icons.lock_outline,
                                    size: 32, color: Colors.black38)
                                : Image.memory(data,
                                    width: 160,
                                    height: 140,
                                    fit: BoxFit.cover)),
                      ),
                    ),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: _ImageActions(
                          path: path, decrypted: data, original: a),
                    ),
                  ],
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: images.length,
            ),
          ),
        if (others.isNotEmpty) const SizedBox(height: 8),
        if (others.isNotEmpty)
          Column(
            children: others
                .map((a) => _FileAttachmentTile(
                    raw: a,
                    data: _decrypted[a['path']],
                    loading: _loading[a['path']] == true))
                .toList(),
          ),
      ],
    );
  }
}

class _ImageActions extends StatelessWidget {
  final String path;
  final Uint8List? decrypted;
  final Map original;
  const _ImageActions(
      {required this.path, required this.decrypted, required this.original});

  Future<void> _saveToGallery(BuildContext context) async {
    if (decrypted == null) return;
    try {
      final name = 'Prompeteer_${DateTime.now().millisecondsSinceEpoch}';
      final result = await ImageGallerySaverPlus.saveImage(
        decrypted!,
        quality: 100,
        name: name,
      );
      bool success = false;
      if (result is Map) {
        success = (result['isSuccess'] == true) || (result['filePath'] != null);
      }
      if (context.mounted) {
        Toaster.show(context, success ? 'Saved to gallery' : 'Save failed');
      }
    } catch (e) {
      if (context.mounted) Toaster.show(context, 'Save failed: $e');
    }
  }

  Future<void> _exportFile(BuildContext context) async {
    if (decrypted == null) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final base = path.split(RegExp(r'[\\/]')).last.replaceAll('.enc', '');
      final out = File('${dir.path}${Platform.pathSeparator}export_$base');
      await out.writeAsBytes(decrypted!, flush: true);
      if (context.mounted) {
        Toaster.show(context,
            'Exported: ${out.path.split(Platform.pathSeparator).last}');
      }
    } catch (e) {
      if (context.mounted) Toaster.show(context, 'Export failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.download, size: 18, color: Colors.white),
          constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
          padding: EdgeInsets.zero,
          onPressed: decrypted == null ? null : () => _exportFile(context),
        ),
        IconButton(
          icon: const Icon(Icons.photo, size: 18, color: Colors.white),
          constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
          padding: EdgeInsets.zero,
          onPressed: decrypted == null ? null : () => _saveToGallery(context),
        ),
      ],
    );
  }
}

class _FileAttachmentTile extends StatelessWidget {
  final Map raw;
  final Uint8List? data;
  final bool loading;
  const _FileAttachmentTile(
      {required this.raw, required this.data, required this.loading});

  static String _fmtBytes(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB'];
    double v = bytes.toDouble();
    int i = 0;
    while (v >= 1024 && i < units.length - 1) {
      v /= 1024;
      i++;
    }
    return '${v.toStringAsFixed(v >= 10 || i == 0 ? 0 : 1)} ${units[i]}';
  }

  Future<void> _saveFile(BuildContext context) async {
    if (data == null) return;
    try {
      final base = (raw['path'] as String? ?? 'file')
          .split(RegExp(r'[\\/]'))
          .last
          .replaceAll('.enc', '');
      final ext = base.contains('.') ? base.split('.').last : 'bin';
      String? targetPath;
      try {
        targetPath = await FilePicker.platform.saveFile(
          dialogTitle: 'Save file as',
          fileName: base,
          type: FileType.custom,
          allowedExtensions: [ext],
        );
      } catch (_) {}
      if (targetPath != null) {
        await File(targetPath).writeAsBytes(data!, flush: true);
        if (context.mounted) Toaster.show(context, 'Saved: $targetPath');
        return;
      }
      final savedPath = await FileSaver.instance.saveFile(
        name: base,
        bytes: data!,
        ext: ext,
      );
      if (context.mounted) {
        Toaster.show(context, 'Saved (fallback): $savedPath');
      }
    } catch (e) {
      if (context.mounted) Toaster.show(context, 'Save failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = (raw['path'] as String? ?? 'file')
        .split(RegExp(r'[\\/]'))
        .last
        .replaceAll('.enc', '');
    final size = raw['size'];
    final label = size is int ? '$name (${_fmtBytes(size)})' : name;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        dense: true,
        leading: loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.insert_drive_file, size: 24),
        title: Text(label, overflow: TextOverflow.ellipsis),
        subtitle: Text(raw['mime']?.toString() ?? ''),
        trailing: Wrap(spacing: 4, children: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: 'Open',
            onPressed: data == null || loading
                ? null
                : () async {
                    try {
                      final tmpDir = await getTemporaryDirectory();
                      final tmp =
                          File('${tmpDir.path}${Platform.pathSeparator}$name');
                      await tmp.writeAsBytes(data!, flush: true);
                      final res = await OpenFilex.open(tmp.path);
                      if (res.type == ResultType.noAppToOpen) {
                        if (context.mounted) {
                          Toaster.show(context, 'No app found to open file');
                        }
                      } else if (res.type == ResultType.error) {
                        if (context.mounted) {
                          Toaster.show(context, 'Open failed: ${res.message}');
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        Toaster.show(context, 'Open failed: $e');
                      }
                    }
                  },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share',
            onPressed: data == null || loading
                ? null
                : () async {
                    try {
                      final tmpDir = await getTemporaryDirectory();
                      final tmp =
                          File('${tmpDir.path}${Platform.pathSeparator}$name');
                      await tmp.writeAsBytes(data!, flush: true);
                      await Share.shareXFiles(
                          [XFile(tmp.path, mimeType: raw['mime']?.toString())]);
                    } catch (e) {
                      if (context.mounted) {
                        Toaster.show(context, 'Share failed: $e');
                      }
                    }
                  },
          ),
          IconButton(
            icon: const Icon(Icons.save_alt),
            tooltip: 'Save',
            onPressed:
                data == null || loading ? null : () => _saveFile(context),
          ),
        ]),
        onTap: data == null || loading
            ? null
            : () async {
                try {
                  final tmpDir = await getTemporaryDirectory();
                  final tmp =
                      File('${tmpDir.path}${Platform.pathSeparator}$name');
                  await tmp.writeAsBytes(data!, flush: true);
                  await OpenFilex.open(tmp.path);
                } catch (e) {
                  if (context.mounted) Toaster.show(context, 'Open failed: $e');
                }
              },
      ),
    );
  }
}

class _InlineNotice extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _InlineNotice(
      {required this.icon, required this.color, required this.text});
  @override
  Widget build(BuildContext context) {
    final rtl = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
    return Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.6)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                    fontSize: 13, color: color.withOpacity(0.9), height: 1.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GeneratedImagesGallery extends StatelessWidget {
  final List<Map<String, dynamic>> inlineImages; // b64 only
  final List<dynamic> generated; // persisted attachments metadata
  const _GeneratedImagesGallery(
      {required this.inlineImages, required this.generated});

  @override
  Widget build(BuildContext context) {
    // Build unified list: persisted first (have paths), then inline (ephemeral)
    final cards = <Widget>[];
    // Persisted (already stored as attachments in separate messages metadata field 'generated_attachments') - treat like thumbnails
    for (final g in generated) {
      if (g is! Map) continue;
      final path = g['path']?.toString();
      if (path == null) continue;
      cards.add(
          _GeneratedImageTile(filePath: path, mime: g['mime']?.toString()));
    }
    // Inline ephemeral
    for (final img in inlineImages) {
      final b64 = img['b64'] as String?;
      if (b64 == null) continue;
      try {
        final bytes = base64Decode(b64);
        cards.add(_InlineB64Image(bytes: bytes));
      } catch (_) {}
    }
    if (cards.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, i) => cards[i],
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: cards.length,
      ),
    );
  }
}

class _GeneratedImageTile extends StatelessWidget {
  final String filePath;
  final String? mime;
  const _GeneratedImageTile({required this.filePath, this.mime});

  void _openFull(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) =>
          _FullscreenImage(path: filePath, bytes: null, tag: filePath),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openFull(context),
      child: Hero(
        tag: filePath,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 160,
                height: 150,
                color: Colors.black12,
                child: Image.file(
                  File(filePath),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image,
                      color: Colors.black38, size: 32),
                ),
              ),
            ),
            const Positioned(
              left: 6,
              top: 6,
              child: _GenBadge(),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineB64Image extends StatelessWidget {
  final Uint8List bytes;
  const _InlineB64Image({required this.bytes});

  void _openFull(BuildContext context) {
    final tag = 'b64_${bytes.hashCode}_${bytes.length}';
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => _FullscreenImage(path: null, bytes: bytes, tag: tag),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tag = 'b64_${bytes.hashCode}_${bytes.length}';
    return GestureDetector(
      onTap: () => _openFull(context),
      child: Hero(
        tag: tag,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 160,
                height: 150,
                color: Colors.black12,
                child: Image.memory(bytes, fit: BoxFit.cover),
              ),
            ),
            const Positioned(
              left: 6,
              top: 6,
              child: _GenBadge(),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenBadge extends StatelessWidget {
  const _GenBadge();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.85),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text('GEN',
          style:
              TextStyle(color: Colors.white, fontSize: 10, letterSpacing: 0.5)),
    );
  }
}

class _FullscreenImage extends StatelessWidget {
  final String? path;
  final Uint8List? bytes;
  final String tag;
  const _FullscreenImage(
      {required this.path, required this.bytes, required this.tag});

  @override
  Widget build(BuildContext context) {
    Widget img;
    if (path != null) {
      img = Image.file(File(path!),
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.broken_image, size: 64, color: Colors.white70));
    } else if (bytes != null) {
      img = Image.memory(bytes!, fit: BoxFit.contain);
    } else {
      img = const SizedBox();
    }
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Hero(
                  tag: tag,
                  child: InteractiveViewer(
                    maxScale: 5,
                    child: img,
                  ),
                ),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
              Positioned(
                left: 12,
                bottom: 12,
                right: 12,
                child: _FullscreenImageActions(path: path, bytes: bytes),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FullscreenImageActions extends StatefulWidget {
  final String? path;
  final Uint8List? bytes;
  const _FullscreenImageActions({required this.path, required this.bytes});

  @override
  State<_FullscreenImageActions> createState() =>
      _FullscreenImageActionsState();
}

class _FullscreenImageActionsState extends State<_FullscreenImageActions> {
  bool _busy = false;

  Future<Uint8List?> _loadBytes() async {
    if (widget.bytes != null) return widget.bytes;
    if (widget.path != null) {
      try {
        return await File(widget.path!).readAsBytes();
      } catch (_) {}
    }
    return null;
  }

  Future<void> _withBusy(Future<void> Function() fn) async {
    if (_busy) return;
    setState(() {
      _busy = true;
    });
    try {
      await fn();
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _share() async {
    await _withBusy(() async {
      final data = await _loadBytes();
      if (data == null) return;
      try {
        final tmpDir = await getTemporaryDirectory();
        final name = 'image_${DateTime.now().millisecondsSinceEpoch}.png';
        final tmp = File('${tmpDir.path}${Platform.pathSeparator}$name');
        await tmp.writeAsBytes(data, flush: true);
        await Share.shareXFiles([XFile(tmp.path, mimeType: 'image/png')]);
      } catch (e) {
        if (context.mounted) Toaster.show(context, 'Share failed: $e');
      }
    });
  }

  Future<void> _saveAs() async {
    await _withBusy(() async {
      final data = await _loadBytes();
      if (data == null) return;
      try {
        String? targetPath;
        try {
          targetPath = await FilePicker.platform.saveFile(
            dialogTitle: 'Save image as',
            fileName: 'generated_${DateTime.now().millisecondsSinceEpoch}.png',
            type: FileType.custom,
            allowedExtensions: ['png'],
          );
        } catch (_) {}
        if (targetPath != null) {
          await File(targetPath).writeAsBytes(data, flush: true);
          if (context.mounted) Toaster.show(context, 'Saved: $targetPath');
          return;
        }
        final savedPath = await FileSaver.instance.saveFile(
          name: 'generated_${DateTime.now().millisecondsSinceEpoch}',
          bytes: data,
          ext: 'png',
        );
        if (context.mounted) Toaster.show(context, 'Saved: $savedPath');
      } catch (e) {
        if (context.mounted) Toaster.show(context, 'Save failed: $e');
      }
    });
  }

  Future<void> _saveToGallery() async {
    await _withBusy(() async {
      final data = await _loadBytes();
      if (data == null) return;
      try {
        final name = 'Prompeteer_${DateTime.now().millisecondsSinceEpoch}';
        final result = await ImageGallerySaverPlus.saveImage(data,
            quality: 100, name: name);
        bool success = false;
        if (result is Map) {
          success =
              (result['isSuccess'] == true) || (result['filePath'] != null);
        }
        if (context.mounted) {
          Toaster.show(
              context, success ? 'Saved to gallery' : 'Gallery save failed');
        }
      } catch (e) {
        if (context.mounted) Toaster.show(context, 'Gallery save failed: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Colors.black.withOpacity(0.55);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _busy ? 0.6 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ActionBtn(
                icon: Icons.save_alt,
                label: 'Save',
                onTap: _saveAs,
                busy: _busy),
            const SizedBox(width: 8),
            _ActionBtn(
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                onTap: _saveToGallery,
                busy: _busy),
            const SizedBox(width: 8),
            _ActionBtn(
                icon: Icons.share, label: 'Share', onTap: _share, busy: _busy),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool busy;
  const _ActionBtn(
      {required this.icon,
      required this.label,
      required this.onTap,
      required this.busy});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: busy ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
