import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vreetory_app/features/authentication/presentation/providers/auth_provider.dart';
import 'package:vreetory_app/features/pos/domain/entities/cashier_info.dart';

/// Provider untuk mendapatkan current cashier info dari user session
final currentCashierProvider = Provider<CashierInfo?>((ref) {
  final authState = ref.watch(authProvider);
  final user = authState.user;

  if (user == null) return null;

  return CashierInfo.fromUser(user);
});

/// Provider untuk check if user is authenticated and approved
final isApprovedCashierProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  final user = authState.user;

  if (user == null) return false;

  // Check if user is approved (both admin and user role need approval)
  // User role is auto-approved during registration (isApproved: true)
  // Admin role needs manual approval (isApproved: false → true after approval)
  return user.isApproved == true;
});

/// Provider untuk cashier display name
final cashierDisplayNameProvider = Provider<String>((ref) {
  final cashier = ref.watch(currentCashierProvider);
  if (cashier == null) return 'Unknown';
  return cashier.name;
});
