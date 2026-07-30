import 'package:flutter/material.dart';
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
  final TextEditingController _anonKeyController = TextEditingController();

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
        title: const Text('Ajouter un serveur'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(labelText: 'URL (https://...)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _anonKeyController,
                decoration: const InputDecoration(labelText: 'Anon Key'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final config = SupabaseConfig(
                name: _nameController.text,
                description: "Serveur ajouté manuellement",
                url: _urlController.text,
                anonKey: _anonKeyController.text,
              );
              _selectServer(config);
              Navigator.pop(context);
            },
            child: const Text('Ajouter et Sélectionner'),
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
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connecté à ${config.name}')),
      );
      Navigator.pop(context, true); // Return to previous page with success
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentConfig = SupabaseManager().currentConfig;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisir un serveur'),
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
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Serveurs Disponibles (GitHub)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  title: const Text('Ajouter manuellement'),
                  subtitle: const Text('Saisir URL et Anon Key'),
                  onTap: _showAddManualDialog,
                ),
              ],
            ),
    );
  }
}
