import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ampheria/presentation/widgets/gender_selector.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;
  bool _loading = false;

  final _fullNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedGender;

  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _birthDateController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<String?> _validatePhoneNumber(String phone) async {
    if (phone.isEmpty) return null;


    final bytes = utf8.encode(phone);
    final hash = sha256.convert(bytes).toString();

    try {
      final blacklistMatch = await supabase
          .from('blacklist')
          .select()
          .eq('phone_hash', hash)
          .maybeSingle();

      if (blacklistMatch != null) {
        return "Ce numéro de téléphone est banni de la plateforme.";
      }


      return null;
    } catch (e) {
      return "Erreur lors de la vérification du numéro.";
    }
  }

  bool _canGoToNextStep() {
    switch (_currentStep) {
      case 0:
        return _fullNameController.text.trim().isNotEmpty;
      case 1:
        return _birthDateController.text.isNotEmpty && _selectedGender != null;
      case 2:
        return _cityController.text.trim().isNotEmpty;
      case 3:
        return true;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (!_canGoToNextStep()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            'Veuillez remplir les champs requis pour continuer.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      return;
    }
    if (_currentStep < _totalSteps - 1) {
      FocusScope.of(context).unfocus();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _submit();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      FocusScope.of(context).unfocus();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _submit() async {
    final phone = _phoneController.text.trim();

    setState(() => _loading = true);

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      if (phone.isNotEmpty) {
        final errorMsg = await _validatePhoneNumber(phone);
        if (errorMsg != null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: Colors.redAccent, content: Text(errorMsg)),
          );
          setState(() => _loading = false);
          return;
        }
      }


      await supabase.from('profiles').update({
        'full_name': _fullNameController.text.trim(),
        'birth_date': _birthDateController.text,
        'gender': _selectedGender,
        'city': _cityController.text.trim(),
      }).eq('id', userId);

      if (phone.isNotEmpty) {
        try {
          await supabase.auth.updateUser(UserAttributes(phone: phone));
        } catch (authError) {
          if (authError.toString().contains('already exists')) {
            throw "Ce numéro est déjà rattaché à un autre compte.";
          }
          rethrow;
        }
      }

      if (!mounted) return;
      Navigator.pop(context);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }


  Widget _buildGlassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: child,
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String hintText,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(color: Colors.white),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: icon != null ? Icon(icon, color: Colors.white54) : null,
        filled: true,
        fillColor: Colors.black26,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
          const BorderSide(color: Colors.deepPurpleAccent, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
        const SizedBox(height: 32),
      ],
    );
  }


  Widget _buildStep1Name() {
    return SingleChildScrollView(
      child: _buildGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              'Faisons connaissance',
              'Comment doit-on vous appeler ?',
            ),
            _buildGlassTextField(
              controller: _fullNameController,
              hintText: 'Votre prénom',
              icon: Icons.person_outline_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2Details() {
    return SingleChildScrollView(
      child: _buildGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              'Un peu plus sur vous',
              'Il faut avoir au moins 18 ans pour s\'inscrire.',
            ),
            _buildGlassTextField(
              controller: _birthDateController,
              hintText: 'Date de naissance',
              icon: Icons.calendar_today_outlined,
              readOnly: true,
              onTap: () async {
                final DateTime today = DateTime.now();
                final DateTime eighteenYearsAgo = DateTime(
                  today.year - 18,
                  today.month,
                  today.day,
                );
                final picked = await showDatePicker(
                  context: context,
                  initialDate: eighteenYearsAgo,
                  firstDate: DateTime(1900),
                  lastDate: eighteenYearsAgo,
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.dark().copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: Colors.deepPurpleAccent,
                          onPrimary: Colors.white,
                          surface: Color(0xFF1E1E1E),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() {
                    _birthDateController.text =
                        picked.toIso8601String().substring(0, 10);
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Votre genre',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),
            GenderSelector(
              selectedGender: _selectedGender,
              onChanged: (value) {
                setState(() => _selectedGender = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3City() {
    return SingleChildScrollView(
      child: _buildGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              'Où êtes-vous ?',
              'Pour rencontrer des personnes autour de vous.',
            ),
            _buildGlassTextField(
              controller: _cityController,
              hintText: 'Votre ville',
              icon: Icons.location_on_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4Phone() {
    return SingleChildScrollView(
      child: _buildGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              'Votre numéro',
              'Optionnel — vous pourrez le renseigner plus tard.',
            ),

            _PhoneInputField(
              onChanged: (fullNumber) {
                _phoneController.text = fullNumber;
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: _previousStep,
        )
            : null,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_totalSteps, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: _currentStep == index ? 24 : 8,
              decoration: BoxDecoration(
                color: _currentStep >= index
                    ? Colors.deepPurpleAccent
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) =>
                      setState(() => _currentStep = index),
                  children: [
                    _buildStep1Name(),
                    _buildStep2Details(),
                    _buildStep3City(),
                    _buildStep4Phone(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canGoToNextStep()
                        ? Colors.deepPurpleAccent
                        : Colors.white.withOpacity(0.1),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.white.withOpacity(0.05),
                    disabledForegroundColor: Colors.white54,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    _currentStep == _totalSteps - 1
                        ? 'Terminer'
                        : 'Continuer',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _PhoneInputField extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const _PhoneInputField({required this.onChanged});

  @override
  State<_PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<_PhoneInputField> {
  final _numberController = TextEditingController();

  final List<Map<String, String>> _countries = [
    {'flag': '🇫🇷', 'name': 'France',       'code': '+33'},
    {'flag': '🇧🇪', 'name': 'Belgique',     'code': '+32'},
    {'flag': '🇨🇭', 'name': 'Suisse',       'code': '+41'},
    {'flag': '🇱🇺', 'name': 'Luxembourg',   'code': '+352'},
    {'flag': '🇨🇦', 'name': 'Canada',       'code': '+1'},
    {'flag': '🇺🇸', 'name': 'États-Unis',   'code': '+1'},
    {'flag': '🇬🇧', 'name': 'Royaume-Uni',  'code': '+44'},
    {'flag': '🇩🇪', 'name': 'Allemagne',    'code': '+49'},
    {'flag': '🇪🇸', 'name': 'Espagne',      'code': '+34'},
    {'flag': '🇮🇹', 'name': 'Italie',       'code': '+39'},
    {'flag': '🇵🇹', 'name': 'Portugal',     'code': '+351'},
    {'flag': '🇲🇦', 'name': 'Maroc',        'code': '+212'},
    {'flag': '🇩🇿', 'name': 'Algérie',      'code': '+213'},
    {'flag': '🇹🇳', 'name': 'Tunisie',      'code': '+216'},
  ];

  late Map<String, String> _selectedCountry;

  @override
  void initState() {
    super.initState();
    _selectedCountry = _countries.first;
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  String _buildFullNumber(String localNumber) {
    final code = _selectedCountry['code']!;
    String digits = localNumber.replaceAll(RegExp(r'\D'), ''); // chiffres only

    if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }

    return '$code$digits';
  }

  void _notify() {
    final full = _buildFullNumber(_numberController.text);
    widget.onChanged(full);
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return ListView.builder(
          itemCount: _countries.length,
          itemBuilder: (context, index) {
            final country = _countries[index];
            final isSelected = country['code'] == _selectedCountry['code'] &&
                country['name'] == _selectedCountry['name'];
            return ListTile(
              leading: Text(
                country['flag']!,
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(
                country['name']!,
                style: const TextStyle(color: Colors.white),
              ),
              trailing: Text(
                country['code']!,
                style: const TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                ),
              ),
              tileColor: isSelected
                  ? Colors.deepPurpleAccent.withOpacity(0.15)
                  : Colors.transparent,
              onTap: () {
                setState(() => _selectedCountry = country);
                _notify();
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: _showCountryPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedCountry['flag']!,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _selectedCountry['code']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white54,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: TextField(
                  controller: _numberController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (_) => _notify(),
                  decoration: const InputDecoration(
                    hintText: '06 52 61 90 66',
                    hintStyle: TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        if (_numberController.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              'Format enregistré : ${_buildFullNumber(_numberController.text)}',
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }
}