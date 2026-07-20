import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

class ProfileService {
  Future<bool> isProfileComplete() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;

    final res = await Supabase.instance.client
        .from('profiles')
        .select('birth_date, full_name, city, gender')
        .eq('id', user.id)
        .maybeSingle();

    if (res == null) {
      await Supabase.instance.client.from('profiles').insert({
        'id': user.id,
        'username': user.email,
        'created_at': DateTime.now().toIso8601String(),
      });
      return false;
    }

    final isNameValid = res['full_name'] != null && (res['full_name'] as String).trim().isNotEmpty;
    final isGenderValid = res['gender'] != null && (res['gender'] as String).trim().isNotEmpty;
    final isDateValid = res['birth_date'] != null;
    final isCityValid = res['city'] != null && (res['city'] as String).trim().isNotEmpty;

    return isNameValid && isGenderValid && isDateValid && isCityValid;
  }
}

