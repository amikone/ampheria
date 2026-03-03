import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flyer_chat_image_message/flyer_chat_image_message.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:photo_view/photo_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:uuid/uuid.dart';

import '../../Widgets/ProfileDetailModal.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _conversations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final response = await supabase.functions.invoke('get-conversations');

    if (response.data != null) {
      final data = response.data is String ? jsonDecode(response.data) : response.data;

      if (data is List) {
        setState(() {
          _conversations = List<Map<String, dynamic>>.from(data);
          _loading = false;
        });
        return;
      }
    }

    setState(() {
      _conversations = [];
      _loading = false;
    });
  }

  void _openChat(Map<String, dynamic> conversation) {
    final matchId = conversation['match_id'];
    final user = conversation['user'];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConversationPage(matchId: matchId, user: user),
      ),
    );
  }

  Future<void> _deleteMatch(int matchId, int index) async {
    final removedItem = _conversations.removeAt(index);
    setState(() {});

    try {
      await supabase.from('matches').delete().eq('id', matchId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Match supprimé avec succès.")),
        );
      }
    } catch (e) {
      setState(() {
        _conversations.insert(index, removedItem);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Impossible de supprimer le match. Veuillez réessayer."),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      // --- STYLE APPBAR MODIFIÉ ---
      appBar: AppBar(
        title: const Text(
          "Mes chats",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _conversations.isEmpty
          ? const Center(
        child: Text(
          "Tu n'as aucune conversation pour le moment",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          final conv = _conversations[index];
          final user = conv['user'];
          final photo = (user['photos'] as List?)?.first ?? '';
          final matchId = conv['match_id'];

          return Dismissible(
            key: ValueKey(matchId),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              _deleteMatch(matchId, index);
            },
            background: Container(
              color: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.centerRight,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
                child: photo.isEmpty ? const Icon(Icons.person) : null,
              ),
              title: Text(user['full_name'] ?? user['username']),
              subtitle: Text(user['bio'] ?? ''),
              onTap: () => _openChat(conv),
            ),
          );
        },
      ),
    );
  }
}

class ConversationPage extends StatefulWidget {
  final int matchId;
  final Map<String, dynamic> user;

  const ConversationPage({required this.matchId, required this.user, super.key});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final supabase = Supabase.instance.client;
  final _chatController = InMemoryChatController();
  StreamSubscription<List<Map<String, dynamic>>>? _subscription;
  bool _isLoading = true;

  var _currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    _currentUserId = supabase.auth.currentUser?.id ?? '';
    _subscribeToRealtime();
  }

  final _signedUrlCache = <String, String>{};

  Future<String> _signedUrlFor(String path, {int expiresSeconds = 3600}) async {
    if (_signedUrlCache.containsKey(path)) return _signedUrlCache[path]!;
    final res = await supabase
        .storage
        .from('chat-pictures')
        .createSignedUrl(path, expiresSeconds);
    _signedUrlCache[path] = res;
    return res;
  }

  void _subscribeToRealtime() {
    _subscription = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('match_id', widget.matchId)
        .order('created_at', ascending: true)
        .listen((rows) async {
      final msgs = <Message>[];
      for (final msg in rows) {
        final createdAt = DateTime.parse(msg['created_at']).toUtc();
        final type = (msg['type'] ?? 'text');
        if (type == 'image' && msg['file_path'] != null) {
          final path = msg['file_path'] as String;
          final url = await _signedUrlFor(path);
          final w = (msg['width'] as int?)?.toDouble();
          final h = (msg['height'] as int?)?.toDouble();
          double? displayW = w, displayH = h;
          if (w != null && h != null) {
            const maxW = 260.0;
            const maxH = 300.0;
            final scale = min(maxW / w, maxH / h);
            displayW = w * scale;
            displayH = h * scale;
          }
          msgs.add(
            ImageMessage(
              id: msg['id'].toString(),
              authorId: msg['sender_id'],
              size: (msg['file_size'] as int?) ?? 0,
              createdAt: createdAt, source: url,
              metadata: {'file_path': path},
              width: displayW,
              height: displayH,
            ),
          );
        } else {
          msgs.add(
            TextMessage(
              id: msg['id'].toString(),
              authorId: msg['sender_id'],
              text: msg['content'] ?? '',
              createdAt: createdAt,
            ),
          );
        }
      }
      _chatController.setMessages(msgs);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _handleSendPressed(String text) async {
    if (text.trim().isEmpty) return;

    final newMessage = {
      'match_id': widget.matchId,
      'sender_id': _currentUserId,
      'content': text.trim(),
    };

    await supabase.from('messages').insert(newMessage).select().single();
  }

  Future<User> _resolveUser(String userId) async {
    if (userId == _currentUserId) {
      return User(id: _currentUserId, name: 'Me');
    } else {
      return User(
        id: userId,
        name: widget.user['full_name'] ?? widget.user['username'],
      );
    }
  }

  void _onMessageLongPress(
      BuildContext context,
      Message message, {
        int? index,
        LongPressStartDetails? details,
      }) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce message ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    ).then((confirm) {
      if (confirm == true) {
        _deleteMessage(message);
      }
    });
  }

  Future<void> _deleteMessage(Message message) async {
    await supabase.from('messages').delete().eq('id', message.id);

    if (message is ImageMessage) {
      final filePath = message.metadata?['file_path'];
      if (filePath != null && filePath is String && filePath.isNotEmpty) {
        try {
          await supabase.storage.from('chat-pictures').remove([filePath]);
        } catch (e) {
          // ignore
        }
      }
    }
  }

  Future<void> _deleteCurrentMatch() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce match ?'),
        content: const Text('Cette action est irréversible. Vous ne pourrez plus discuter avec cette personne.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await supabase.from('matches').delete().eq('id', widget.matchId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Match supprimé avec succès.")),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Erreur lors de la suppression du match."),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _chatController.dispose();
    super.dispose();
  }

  final _picker = ImagePicker();

  Future<void> _onAttachmentPressed() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2000,
      imageQuality: 85,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    final ext = picked.name.split('.').last.toLowerCase();
    final mimeType = lookupMimeType(picked.name) ?? 'image/$ext';
    final fileName = '${const Uuid().v4()}.$ext';
    final storagePath = '${widget.matchId}/$_currentUserId/$fileName';

    final compressedBytes = await FlutterImageCompress.compressWithFile(
      picked.path,
      quality: 80,
    );

    if (compressedBytes == null) return;

    const maxSize = 2 * 1024 * 1024; // 2 Mo
    if (compressedBytes.length > maxSize) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("L'image dépasse 2 Mo")),
      );
      return;
    }

    final codec = await ui.instantiateImageCodec(compressedBytes);
    final frame = await codec.getNextFrame();
    final imgWidth = frame.image.width;
    final imgHeight = frame.image.height;

    await supabase.storage.from('chat-pictures').uploadBinary(
      storagePath,
      compressedBytes,
      fileOptions: FileOptions(contentType: mimeType, upsert: false),
    );

    await supabase.from('messages').insert({
      'match_id': widget.matchId,
      'sender_id': _currentUserId,
      'type': 'image',
      'file_path': storagePath,
      'file_mime': mimeType,
      'file_size': bytes.length,
      'width': imgWidth,
      'height': imgHeight,
    });
  }

  Future<void> showZoomableImage(BuildContext context, String imageUrl) {
    return showDialog(
      context: context,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          color: Colors.black,
          child: PhotoView(
            imageProvider: NetworkImage(imageUrl),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- STYLE APPBAR MODIFIÉ ---
    final appBar = AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      title: GestureDetector(
        onTap: () {
          final profileId = widget.user['id'];
          if (profileId != null) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => Container(
                height: MediaQuery.of(context).size.height * 0.9,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E1E2C),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: ProfileDetailModal(profileId: profileId),
              ),
            );
          }
        },
        child: Text(
          widget.user['full_name'] ?? widget.user['username'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person_remove),
          color: Colors.redAccent,
          tooltip: 'Supprimer le match',
          onPressed: _deleteCurrentMatch,
        ),
      ],
    );

    if (_isLoading) {
      return Scaffold(
        appBar: appBar,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
        appBar: appBar,
        body: Chat(
          chatController: _chatController,
          currentUserId: _currentUserId,
          onMessageSend: _handleSendPressed,
          resolveUser: _resolveUser,
          theme: ChatTheme.dark(),
          onAttachmentTap: _onAttachmentPressed,
          builders: Builders(
            imageMessageBuilder: (context, message, index, {
              required bool isSentByMe,
              MessageGroupStatus? groupStatus,
            }) {
              return GestureDetector(
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      color: Colors.black,
                      child: PhotoView(
                        imageProvider: NetworkImage((message).source),
                        backgroundDecoration: const BoxDecoration(color: Colors.black),
                      ),
                    ),
                  ),
                ),
                child: FlyerChatImageMessage(
                  message: message,
                  index: index,
                ),
              );
            },
          ),
          onMessageLongPress: _onMessageLongPress,
        )
    );
  }
}