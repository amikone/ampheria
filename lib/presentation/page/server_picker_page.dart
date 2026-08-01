import 'package:flutter/material.dart';
import 'package:ampheria/extensions/context_extension.dart';
import '../../models/supabase_config.dart';
import '../../services/discovery_service.dart';
import '../../services/supabase_manager.dart';

class ServerPickerPage extends StatefulWidget {
  const ServerPickerPage({super.key});

  @override
  State<ServerPickerPage> createState() => _ServerPickerPageState();
}

class _ServerPickerPageState extends State<ServerPickerPage> {
  final DiscoveryService _discoveryService = DiscoveryService();
  List<SupabaseConfig> _servers = [];
  bool _isLoading = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _publishableKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadServers();
  }

  Future<void> _loadServers() async {
    setState(() => _isLoading = true);
    final servers = await _discoveryService.fetchServers();
    if (mounted) {
      setState(() {
        _servers = servers;
        _isLoading = false;
      });
    }
  }

  void _showAddManualDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.localizations.addServerDialogTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: context.localizations.serverNameLabel),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _urlController,
                decoration: InputDecoration(labelText: context.localizations.serverUrlLabel),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _publishableKeyController,
                decoration: InputDecoration(labelText: context.localizations.serverKeyLabel),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.localizations.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final config = SupabaseConfig(
                name: _nameController.text,
                description: context.localizations.manualServerDesc,
                url: _urlController.text,
                publishableKey: _publishableKeyController.text,
              );
              _selectServer(config);
              Navigator.pop(context);
            },
            child: Text(context.localizations.addAndSelect),
          ),
        ],
      ),
    );
  }

  Future<void> _selectServer(SupabaseConfig config) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await SupabaseManager().changeServer(config);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.localizations.connectedToServer(config.name))),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentConfig = SupabaseManager().currentConfig;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.localizations.serverPickerTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadServers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    context.localizations.availableServersGithub,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ..._servers.map((server) {
                  final isSelected = currentConfig?.url == server.url;
                  return ListTile(
                    leading: Icon(
                      Icons.storage,
                      color: isSelected ? Colors.green : null,
                    ),
                    title: Text(server.name),
                    subtitle: Text(server.description),
                    trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : null,
                    onTap: () => _selectServer(server),
                  );
                }),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: Text(context.localizations.addServerManually),
                  subtitle: Text(context.localizations.addServerDesc),
                  onTap: _showAddManualDialog,
                ),
              ],
            ),
    );
  }
}
