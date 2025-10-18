// lib/screens/ProfileSetup.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _cityController = TextEditingController();
  String? _selectedGender;
  bool _loading = false;

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() { _loading = true; });
    final userId = Supabase.instance.client.auth.currentUser?.id;

    final resp = await Supabase.instance.client
        .from('profiles')
        .update({
      'full_name': _fullNameController.text,
      'birth_date': _birthDateController.text,
      'gender': _selectedGender,
      'city': _cityController.text,
    })
        .eq('id', userId!);

    setState(() { _loading = false; });

    if (!mounted) return;
    Navigator.pop(context); // <-- On revient à ProfileScreen !
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complétez votre profil')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Prénom'),
                validator: (v) => (v == null || v.isEmpty) ? 'Le prénom est requis' : null,
              ),
              TextFormField(
                controller: _birthDateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date de naissance',
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(DateTime.now().year - 22),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    _birthDateController.text = picked.toIso8601String().substring(0, 10);
                  }
                },
                validator: (v) => (v == null || v.isEmpty) ? 'La date de naissance est requise' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Homme')),
                  DropdownMenuItem(value: 'female', child: Text('Femme')),
                  DropdownMenuItem(value: 'other', child: Text('Autre')),
                ],
                decoration: const InputDecoration(labelText: 'Genre'),
                onChanged: (v) => setState(() => _selectedGender = v),
                validator: (v) => (v == null) ? 'Genre requis' : null,
              ),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'Ville'),
                validator: (v) => (v == null || v.isEmpty) ? 'La ville est requise' : null,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading ? CircularProgressIndicator() : const Text('Valider'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}