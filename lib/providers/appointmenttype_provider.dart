import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/models/appointmenttype_model.dart';
import 'package:wfs/services/appointmentType_service.dart';
import 'auth_provider.dart';

final appointmentTypeProvider = Provider<AppointmentTypeService>((ref) {
  return AppointmentTypeService();
});

final appointmentTypeGetList = FutureProvider<List<AppointmentType>>((
  ref,
) async {
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('User is not authenticated.');
  }

  final appointmentTypeService = ref.watch(appointmentTypeProvider);

  return appointmentTypeService.getList(accessToken);
});
