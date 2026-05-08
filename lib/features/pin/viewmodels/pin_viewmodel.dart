import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wfs/features/pin/services/pin_service.dart';
import 'package:wfs/providers/auth_provider.dart';
import 'package:wfs/services/user_service.dart';
import 'package:wfs/core/base_provider.dart';

enum PinMode { create, verify, change }

class PinState {
  final bool hasPin;
  final bool isLocked;
  final int failedAttempts;

  const PinState({this.hasPin = false, this.isLocked = false, this.failedAttempts = 0});

  PinState copyWith({bool? hasPin, bool? isLocked, int? failedAttempts}) {
    return PinState(hasPin: hasPin ?? this.hasPin, isLocked: isLocked ?? this.isLocked, failedAttempts: failedAttempts ?? this.failedAttempts);
  }
}

class PinViewModel extends StateNotifier<PinState> {
  PinViewModel(this._pinService, this._ref) : super(const PinState()) {
    _init();
  }

  final PinService _pinService;
  final Ref _ref;

  Future<void> _init() async {
    final hasPin = await _pinService.hasPin();
    state = state.copyWith(hasPin: hasPin);
  }

  Future savePinStorage(String pin) async {
    await _pinService.savePinStorage(pin);
  }

  Future hasPinStorage() async {
    await _pinService.hasPin();
  }

  Future<bool> createPin(WidgetRef ref, String pin) async {
    try {
      // // Save locally
      // await _pinService.savePin(pin);

      // Update on server
      final userService = _ref.read(userServiceProvider);
      final success = await userService.updatePincode(ref, pin);

      if (success) {
        final authState = ref.read(authProvider);
        final user = await ref.read(userServiceProvider).getByID(authState.accessToken, authState.userID!);
        await ref.read(pinServiceProvider).saveUser(user);

        state = state.copyWith(hasPin: true, failedAttempts: 0);
        return true;
      }
      return false;
    } catch (e) {
      print('Error creating PIN: $e');
      return false;
    }
  }

  Future<bool> setPin(String pin) async {
    try {
      // Save locally
      await _pinService.savePinStorage(pin);

      // Update on server
      final userService = _ref.read(userServiceProvider);
      final success = await userService.updatePincode(_ref as WidgetRef, pin);

      if (success) {
        state = state.copyWith(hasPin: true, failedAttempts: 0);
        return true;
      }
      return false;
    } catch (e) {
      print('Error setting PIN: $e');
      return false;
    }
  }

  bool verifyPin(String pin) {
    // Note: This should ideally be async, but for simplicity we use sync wrapper
    // In production, refactor to use async/await throughout the flow
    final isValid = _pinService.verifyPin(pin);

    if (isValid) {
      state = state.copyWith(failedAttempts: 0, isLocked: false);
      return true;
    } else {
      final attempts = state.failedAttempts + 1;
      final isLocked = attempts >= 3;
      state = state.copyWith(failedAttempts: attempts, isLocked: isLocked);
      return false;
    }
  }

  Future<bool> verifyPinAsync(WidgetRef ref, String pin) async {
    const storage = FlutterSecureStorage();
    final accessToken = await storage.read(key: 'access_token');
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Authentication token is not available.');
    }

    final userID = await storage.read(key: 'user_id');
    if (userID == null || userID.isEmpty) {
      throw Exception('User ID is not available.');
    }

    final userService = _ref.read(userServiceProvider);
    final isValid = await userService.validatePincode(ref, accessToken, pin);

    if (isValid) {
      state = state.copyWith(failedAttempts: 0, isLocked: false);

      final userResponse = await userService.getByID(accessToken, userID);
      if ((userResponse.userID ?? '').isEmpty) {
        throw Exception('User Response User ID is not available.');
      }

      ref
          .read(authProvider.notifier)
          .updateAuthState(
            accessToken: accessToken,
            foundUserId: userResponse.userID!,
            userRoleID: userResponse.userRoleID,
            userRoleName: userResponse.userRoleName,
            email: userResponse.email,
            pincode: userResponse.pincode,
            territoryID: userResponse.territoryID,
            territoryName: userResponse.territoryName,
            firstName: userResponse.firstName ?? '',
            lastName: userResponse.lastName ?? '',
          );

      return true;
    } else {
      final attempts = state.failedAttempts + 1;
      final isLocked = attempts >= 3;
      state = state.copyWith(failedAttempts: attempts, isLocked: isLocked);
      return false;
    }
  }

  Future<void> removePin() async {
    await _pinService.removePin();
    state = state.copyWith(hasPin: false, failedAttempts: 0, isLocked: false);
  }

  void resetFailedAttempts() {
    state = state.copyWith(failedAttempts: 0, isLocked: false);
  }
}
