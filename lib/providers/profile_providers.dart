import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/data/profile_service.dart';


final profileCompletionProvider = FutureProvider.autoDispose<bool>((ref) async {
  final service = ref.watch(profileServiceProvider);
  return await service.isProfileComplete();
});