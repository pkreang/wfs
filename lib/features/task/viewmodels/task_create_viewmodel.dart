import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wfs/core/base_provider.dart';
import 'package:wfs/core/http/api_client.dart';
import 'package:wfs/features/appointment/models/address.dart';
import 'package:wfs/features/appointment/models/purpose.dart';
import 'package:wfs/features/client/models/client.dart';
import 'package:wfs/features/company/models/company.dart';
import 'package:wfs/features/task/models/task.dart' hide AppointmentType;
import 'package:wfs/features/task/models/task_appointment_type.dart';
import 'package:wfs/features/task/models/task_response.dart';
import 'package:wfs/features/task/models/task_type.dart';
import 'package:wfs/features/task/services/task_service.dart';
import 'package:wfs/providers/appointment_provider.dart';

DateTime get roundedTaskNow {
  final now = DateTime.now();
  final roundedMinute = ((now.minute + 4) ~/ 5) * 5;

  return DateTime(now.year, now.month, now.day, now.hour, roundedMinute >= 60 ? 55 : roundedMinute);
}

Task createEmptyTask() {
  final now = roundedTaskNow;
  return Task.empty().copyWith(scheduledStartDate: now, scheduledEndDate: now.add(const Duration(minutes: 5)));
}

@immutable
class TaskCreateState {
  final AsyncValue<Task> data;
  final List<Company> companies;
  final bool isDirty;
  final bool isLoading;
  final String? errorMessage;

  const TaskCreateState({required this.data, this.companies = const [], this.isDirty = false, this.isLoading = false, this.errorMessage});

  TaskCreateState copyWith({AsyncValue<Task>? data, List<Company>? companies, bool? isDirty, bool? isLoading, String? errorMessage, bool clearErrorMessage = false}) {
    return TaskCreateState(
      data: data ?? this.data,
      companies: companies ?? this.companies,
      isDirty: isDirty ?? this.isDirty,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class TaskCreateViewModel extends StateNotifier<TaskCreateState> {
  TaskCreateViewModel(this.ref, this.clientID, this.clientType) : super(TaskCreateState(data: (clientID ?? '').isEmpty ? AsyncValue.data(createEmptyTask()) : const AsyncValue.loading())) {
    if ((clientID ?? '').isNotEmpty) {
      fetchClientById(clientID!, clientType);
    }
  }

  final Ref ref;
  final String? clientID;
  final String clientType;

  TaskService get _taskService => ref.read(taskServiceProvider);

  Future<void> fetchClientById(String id, String clientType) async {
    final isInitialLoad = state.data.isLoading;
    if (!isInitialLoad) {
      state = state.copyWith(isLoading: true, clearErrorMessage: true);
    }

    if (clientType.toLowerCase() == "lead") {
      final result = await AsyncValue.guard(() => ref.read(leadServiceProvider).getById(ref, id));

      result.when(
        data: (lead) {
          final hasCompany = (lead.companyID ?? '').isNotEmpty;
          final companies = hasCompany ? [Company(companyID: lead.companyID, companyName: lead.companyName, addresses: lead.company?.addresses ?? const [])] : <Company>[];
          final companyAddress = companies.isNotEmpty && companies.first.addresses.isNotEmpty ? companies.first.addresses.first : null;
          final task = state.data.value ?? createEmptyTask();

          state = state.copyWith(
            data: AsyncValue.data(
              task.copyWith(
                clientID: lead.leadID,
                clientName: '${lead.firstName ?? ''} ${lead.lastName ?? ''}'.trim(),
                phone: lead.phone,
                email: lead.email,
                companyID: lead.companyID ?? '',
                companyName: lead.companyName ?? '',
                taskAddress: companyAddress == null ? null : Address.fromJson(companyAddress.toJson()),
              ),
            ),
            companies: companies,
            isDirty: !isInitialLoad,
            isLoading: false,
            clearErrorMessage: true,
          );
        },
        loading: () {},
        error: (error, stackTrace) {
          state = state.copyWith(data: isInitialLoad ? AsyncValue.error(error, stackTrace) : null, isLoading: false, errorMessage: error is ApiException ? error.message : 'Unable to load lead data');
        },
      );
    } else {
      final result = await AsyncValue.guard(() => ref.read(clientServiceProvider).getById(ref, id));

      result.when(
        data: (client) {
          final companies = (client.companies ?? [])
              .map((clientCompany) => clientCompany.company)
              .where((company) => (company?.companyID ?? '').isNotEmpty)
              .map((company) => Company(companyID: company!.companyID, companyName: company.companyName, addresses: company.addresses))
              .toList();
          final defaultCompany = companies.isNotEmpty ? companies.first : null;
          final defaultAddress = defaultCompany?.addresses.isNotEmpty == true ? defaultCompany!.addresses.first : null;
          final task = state.data.value ?? createEmptyTask();

          state = state.copyWith(
            data: AsyncValue.data(
              task.copyWith(
                clientID: client.clientID,
                clientName: client.clientName.trim(),
                phone: client.phone,
                email: client.email,
                companyID: defaultCompany?.companyID ?? '',
                companyName: defaultCompany?.companyName ?? '',
                taskAddress: defaultAddress == null
                    ? null
                    : Address(
                        address: defaultAddress.address,
                        subDistrictID: defaultAddress.subDistrictID,
                        subDistrictName: defaultAddress.subDistrictName,
                        districtID: defaultAddress.districtID,
                        districtName: defaultAddress.districtName,
                        provinceID: defaultAddress.provinceID,
                        provinceName: defaultAddress.provinceName,
                        postCode: defaultAddress.postCode,
                        countryID: defaultAddress.countryID,
                        countryName: defaultAddress.countryName,
                      ),
              ),
            ),
            companies: companies,
            isDirty: !isInitialLoad,
            isLoading: false,
            clearErrorMessage: true,
          );
        },
        loading: () {},
        error: (error, stackTrace) {
          state = state.copyWith(
            data: isInitialLoad ? AsyncValue.error(error, stackTrace) : null,
            isLoading: false,
            errorMessage: error is ApiException ? error.message : 'Unable to load client data',
          );
        },
      );
    }
  }

  void setTaskType(TaskType value) {
    _set((task) => task.copyWith(taskType: value));
  }

  void setAppointmentType(TaskAppointmentType value) {
    _set((task) => task.copyWith(appointmentTypeID: value.appointmentTypeID, appointmentTypeName: value.appointmentTypeName));
  }

  void setTitle(String value) {
    _set((task) => task.copyWith(title: value));
  }

  void setDetails(String value) {
    _set((task) => task.copyWith(details: value));
  }

  void setScheduledStartDate(DateTime value) {
    final currentDateTime = state.data.value?.scheduledStartDate;
    if (currentDateTime == null) return;

    final updated = DateTime(value.year, value.month, value.day, currentDateTime.hour, currentDateTime.minute);
    _set((task) => task.copyWith(scheduledStartDate: updated));
  }

  void setScheduleStartTime(TimeOfDay time) {
    final currentDateTime = state.data.value?.scheduledStartDate;
    if (currentDateTime == null) return;

    final updated = DateTime(currentDateTime.year, currentDateTime.month, currentDateTime.day, time.hour, time.minute);
    _set((task) => task.copyWith(scheduledStartDate: updated));
  }

  void setScheduledEndDate(DateTime value) {
    final currentDateTime = state.data.value?.scheduledEndDate;
    if (currentDateTime == null) return;

    final updated = DateTime(value.year, value.month, value.day, currentDateTime.hour, currentDateTime.minute);
    _set((task) => task.copyWith(scheduledEndDate: updated));
  }

  void setScheduleEndTime(TimeOfDay time) {
    final currentDateTime = state.data.value?.scheduledEndDate;
    if (currentDateTime == null) return;

    final updated = DateTime(currentDateTime.year, currentDateTime.month, currentDateTime.day, time.hour, time.minute);
    _set((task) => task.copyWith(scheduledEndDate: updated));
  }

  void setPurpose(Purpose status) {
    _set((task) => task.copyWith(purposeID: status.purposeTypeID, purposeName: status.purposeTypeName));
  }

  void setPurposeOther(String value) {
    _set((task) => task.copyWith(purposeOther: value));
  }

  Future<void> setClient(Client client) async {
    final id = client.clientID ?? '';
    if (id.isEmpty) return;

    await fetchClientById(id, client.clientType ?? 'client');
  }

  void setMobile(String mobile) {
    _set((task) => task.copyWith(phone: mobile));
  }

  void setEmail(String email) {
    _set((task) => task.copyWith(email: email));
  }

  void setCompany(Company company) {
    _set((task) => task.copyWith(companyID: company.companyID ?? '', companyName: company.companyName ?? ''));

    final companyAddress = company.addresses.isNotEmpty ? company.addresses.first : null;
    if (companyAddress != null) {
      setAddress(
        address: Address(
          address: companyAddress.address,
          subDistrictID: companyAddress.subDistrictID,
          subDistrictName: companyAddress.subDistrictName,
          districtID: companyAddress.districtID,
          districtName: companyAddress.districtName,
          provinceID: companyAddress.provinceID,
          provinceName: companyAddress.provinceName,
          postCode: companyAddress.postCode,
          countryID: 1,
        ),
      );
    }
  }

  void removeCompany() {
    _set((task) => task.copyWith(companyID: '', companyName: '', taskAddress: null));
  }

  void setAddress({required Address address}) {
    _set((task) => task.copyWith(taskAddress: address));
  }

  void _set(Task Function(Task) update) {
    state = state.copyWith(data: state.data.whenData(update), isDirty: true, clearErrorMessage: true);
  }

  Future<TaskResponse> createTask() async {
    final task = state.data.value;
    if (task == null) return TaskResponse.failure('Task data was not found');

    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final result = await _taskService.createTask(ref, task);
      if (result.success) {
        // ref.invalidate(taskListProvider);
        final filter = task.appointmentDateTimeFrom ?? DateTime.now();
        ref.read(selectedMonthProvider.notifier).setMonth(filter);
        ref.read(selectedDateProvider.notifier).setDate(filter);

        ref.read(appointmentMarkDateProvider(DateTime(filter.year, filter.month, 1)).notifier).refresh();
        ref.read(appointmentsByDateProvider(DateFormat("yyyy-MM-dd").format(filter)).notifier).refresh();

        final now = DateTime.now();
        final bool isSameDate = filter.year == now.year && filter.month == now.month && filter.day == now.day;

        if (isSameDate) {
          ref.invalidate(appointmentsProvider(DateTime(filter.year, filter.month, filter.day)));
          ref.invalidate(appointmentSummaryProvider(DateTime(filter.year, filter.month, filter.day)));
        }
      } else if (result.message.isNotEmpty) {
        state = state.copyWith(errorMessage: result.message);
      }

      return result;
    } catch (e) {
      state = state.copyWith(errorMessage: e is ApiException ? e.message : 'Request failed');
    } finally {
      state = state.copyWith(isLoading: false);
    }

    return TaskResponse.failure(state.errorMessage ?? 'Request failed');
  }
}
