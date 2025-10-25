import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _messages = [];
  StreamSubscription<List<Map<String, dynamic>>>? _subscription;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _subscribeToRealtime();
  }

  // 1️⃣ Charger les messages existants
  Future<void> _loadMessages() async {
    final initial = await supabase
        .from('messages')
        .select()
        .eq('match_id', widget.matchId)
        .order('created_at', ascending: true);
    setState(() {
      _messages = List<Map<String, dynamic>>.from(initial);
    });
    _scrollToBottom();
  }

  // 2️⃣ S'abonner aux updates Realtime
  void _subscribeToRealtime() {
    _subscription = supabase
        .from('messages')                  // juste la table
        .stream(primaryKey: ['id'])
        .eq('match_id', widget.matchId)   // filtre sur le match
        .listen((updates) {
      if (updates.isNotEmpty) {
        setState(() {
          _messages = List<Map<String, dynamic>>.from(updates);
        });
        _scrollToBottom();
      }
    });
  }

  void _sendMessage() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    final newMessage = {
      'match_id': widget.matchId,
      'sender_id': supabase.auth.currentUser!.id,
      'content': content,
      'created_at': DateTime.now().toIso8601String(),
    };

    setState(() {
      _messages.add(newMessage);
    });
    _scrollToBottom();

    await supabase.from('messages').insert(newMessage);

    _controller.clear();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.user['full_name'] ?? widget.user['username'])),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['sender_id'] == supabase.auth.currentUser!.id;
                return Container(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      msg['content'],
                      style: TextStyle(color: isMe ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Écrire un message...",
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}




