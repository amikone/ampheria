import 'dart:async';
import 'dart:math';

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
    if (response.data != null && response.data is List) {
      setState(() {
        _conversations = List<Map<String, dynamic>>.from(response.data);
        _loading = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text("Mes chats")),
      body: ListView.builder(
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          final conv = _conversations[index];
          final user = conv['user'];
          final photo = (user['photos'] as List?)?.first ?? '';
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
              child: photo.isEmpty ? const Icon(Icons.person) : null,
            ),
            title: Text(user['full_name'] ?? user['username']),
            subtitle: Text(user['bio'] ?? ''),
            onTap: () => _openChat(conv),
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
          msgs.add(
            ImageMessage(
              id: msg['id'].toString(),
              authorId: msg['sender_id'],
              size: (msg['file_size'] as int?) ?? 0,
              createdAt: createdAt, source: url,
              metadata: {'file_path': path},
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
          // ignore ou affiche une erreur/toast si tu veux
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

    // Upload dans le bucket privé
    await supabase.storage.from('chat-pictures').uploadBinary(
      storagePath,
      compressedBytes,
      fileOptions: FileOptions(contentType: mimeType, upsert: false),
    );



    // Enregistre le message image dans la base
    await supabase.from('messages').insert({
      'match_id': widget.matchId,
      'sender_id': _currentUserId,
      'type': 'image',
      'file_path': storagePath,
      'file_mime': mimeType,
      'file_size': bytes.length,

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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.user['full_name'] ?? widget.user['username'])),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(widget.user['full_name'] ?? widget.user['username'])),
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
                // Les autres params si besoin,
              ),
            );
          },
        ),
        onMessageLongPress: _onMessageLongPress,
      )
    );
  }
}
