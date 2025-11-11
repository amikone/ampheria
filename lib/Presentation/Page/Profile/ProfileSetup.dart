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
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  String? _selectedGender;
  bool _loading = false;
  bool _otpSent = false;
  bool _phoneVerified = false;
  bool _canSubmit = false;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    final user = supabase.auth.currentUser;
    if (user != null && user.phone != null && user.phoneConfirmedAt != null) {
      _phoneController.text = user.phone!;
      _phoneVerified = true;
    }

    _fullNameController.addListener(_updateSubmitButtonState);
    _birthDateController.addListener(_updateSubmitButtonState);
    _cityController.addListener(_updateSubmitButtonState);
    _phoneController.addListener(_updateSubmitButtonState);

    _updateSubmitButtonState();
  }

  @override
  void dispose() {
    _fullNameController.removeListener(_updateSubmitButtonState);
    _birthDateController.removeListener(_updateSubmitButtonState);
    _cityController.removeListener(_updateSubmitButtonState);
    _phoneController.removeListener(_updateSubmitButtonState);

    _fullNameController.dispose();
    _birthDateController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _updateSubmitButtonState() {
    final allFieldsFilled = _fullNameController.text.isNotEmpty &&
        _birthDateController.text.isNotEmpty &&
        _selectedGender != null &&
        _cityController.text.isNotEmpty ;
        //&& _phoneController.text.isNotEmpty;
    setState(() {
      _canSubmit = allFieldsFilled ;//&& _phoneVerified;
    });
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Veuillez entrer un numéro.')));
      return;
    }

    try {
      await supabase.auth.signInWithOtp(phone: phone);
      setState(() => _otpSent = true);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Code envoyé par SMS.')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  Future<void> _verifyOtp() async {
    final phone = _phoneController.text.trim();
    final token = _otpController.text.trim();

    if (token.isEmpty) return;

    try {
      final response = await supabase.auth.verifyOTP(
        type: OtpType.sms,
        token: token,
        phone: phone,
      );

      if (response.session != null) {
        setState(() {
          _phoneVerified = true;
        });
        _updateSubmitButtonState();
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Numéro vérifié ✅')));
      } else {
        throw Exception('La vérification OTP a échoué.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Code incorrect ❌: $e')));
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;

    /*if (!_phoneVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez vérifier votre numéro avant de continuer.')),
      );
      return;
    }*/

    setState(() => _loading = true);

    final userId = supabase.auth.currentUser?.id;
    await supabase.from('profiles').update({
      'full_name': _fullNameController.text,
      'birth_date': _birthDateController.text,
      'gender': _selectedGender,
      'city': _cityController.text,
    }).eq('id', userId!);

    setState(() => _loading = false);

    if (!mounted) return;
    Navigator.pop(context);
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
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Le prénom est requis' : null,
              ),
              TextFormField(
                controller: _birthDateController,
                readOnly: true,
                decoration:
                const InputDecoration(labelText: 'Date de naissance'),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(DateTime.now().year - 22),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    _birthDateController.text =
                        picked.toIso8601String().substring(0, 10);
                  }
                },
                validator: (v) =>
                (v == null || v.isEmpty) ? 'La date de naissance est requise' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Homme')),
                  DropdownMenuItem(value: 'female', child: Text('Femme')),
                  DropdownMenuItem(value: 'other', child: Text('Autre')),
                ],
                decoration: const InputDecoration(labelText: 'Genre'),
                onChanged: (v) {
                  setState(() => _selectedGender = v);
                  _updateSubmitButtonState();
                },
                validator: (v) => (v == null) ? 'Genre requis' : null,
              ),
               TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'Ville'),
                validator: (v) =>
                (v == null || v.isEmpty) ? 'La ville est requise' : null,
              ),
              /*
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                    labelText: 'Numéro de téléphone (ex: +336...)'),
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Le téléphone est requis' : null,
                readOnly: _phoneVerified,
              ),
              if (!_phoneVerified)
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _otpSent ? null : _sendOtp,
                      child: const Text('Envoyer le code'),
                    ),
                    const SizedBox(width: 12),
                    if (_otpSent)
                      Expanded(
                        child: TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          decoration:
                          const InputDecoration(labelText: 'Code reçu'),
                        ),
                      ),
                    if (_otpSent)
                      IconButton(
                        onPressed: _verifyOtp,
                        icon: const Icon(Icons.check),
                      ),
                  ],
                ),*/
              const Spacer(),
              ElevatedButton(
                onPressed: (_canSubmit && !_loading) ? _submit : null,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Valider'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
