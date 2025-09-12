import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/models/sales_territory.dart';
import 'package:wfs/models/territory_model.dart';
import 'package:wfs/services/saleterritorie_service.dart';
import 'auth_provider.dart';

final saleterritorieProvider = Provider<SaleterritorieService>((ref) {
  return SaleterritorieService();
});

final saleTerritorieGetList = FutureProvider<List<Territory>>((ref) async {
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('User is not authenticated.');
  }

  final saleterritorService = ref.watch(saleterritorieProvider);

  return saleterritorService.getList(accessToken);
});
final territoryGetListProvider = FutureProvider.autoDispose<List<Territory>>((
  ref,
) async {
  final authState = ref.watch(authProvider);
  return await ref
      .read(saleterritorieProvider)
      .getList(authState.accessToken.toString());
});

final SalesTerritoryEditProvider = StateNotifierProvider.autoDispose
    .family<SalesTerritoryEditViewModel, SalesTerritoryEditState, String>((
      ref,
      id,
    ) {
      return SalesTerritoryEditViewModel(ref, id);
    });

final territoryProvider = FutureProvider.autoDispose<List<Territory>>((
  ref,
) async {
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken;
  return await ref.read(saleterritorieProvider).getList(accessToken.toString());
});

@immutable
class SalesTerritoryEditState {
  final AsyncValue<SalesTerritory> data;
  final bool isDirty;
  final bool isLoading;

  const SalesTerritoryEditState({
    required this.data,
    this.isDirty = false,
    this.isLoading = false,
  });

  SalesTerritoryEditState copyWith({
    AsyncValue<SalesTerritory>? data,
    bool? isDirty,
    bool? isLoading,
  }) => SalesTerritoryEditState(
    data: data ?? this.data,
    isDirty: isDirty ?? this.isDirty,
    isLoading: isLoading ?? this.isLoading,
  );
}

class SalesTerritoryEditViewModel
    extends StateNotifier<SalesTerritoryEditState> {
  SalesTerritoryEditViewModel(this.ref, this.id)
    : super(const SalesTerritoryEditState(data: AsyncValue.loading())) {
    // fetch();
  }

  final Ref ref;
  final String id;

  // SaleterritorieService get _SalesTerritoryService =>
  //     ref.read(saleterritorieProvider);

  // Future<void> fetch() async {
  //   final res = await AsyncValue.guard(() => _SalesTerritoryService.getList());
  //   state = state.copyWith(data: res, isDirty: false);
  // }

  // void setSalesTerritoryType(SalesTerritoryType status) {
  //   state = state.copyWith(
  //     data: state.data.whenData(
  //       (v) => v.copyWith(
  //         SalesTerritoryTypeId: status.SalesTerritoryTypeID,
  //         SalesTerritoryTypeName: status.SalesTerritoryTypeName,
  //       ),
  //     ),
  //     isDirty: true,
  //   );
  // }

  // void setSalesTerritoryStatus(SalesTerritoryStatus status) {
  //   state = state.copyWith(
  //     data: state.data.whenData(
  //       (v) => v.copyWith(
  //         SalesTerritoryStatusId: status.SalesTerritoryStatusID,
  //         SalesTerritoryStatusName: status.SalesTerritoryStatusName,
  //       ),
  //     ),
  //     isDirty: true,
  //   );
  // }

  // void setPurpose(Purpose status) {
  //   state = state.copyWith(
  //     data: state.data.whenData(
  //       (v) => v.copyWith(
  //         purposeTypeId: status.purposeTypeID,
  //         purposeTypeName: status.purposeTypeName,
  //       ),
  //     ),
  //     isDirty: true,
  //   );
  // }

  // void setSalesTerritory(SalesTerritory status) {
  //   final newSalesSalesTerritory = SalesSalesTerritory(
  //     salesSalesTerritoryID: status.salesSalesTerritoryID,
  //     salesSalesTerritoryName: status.salesSalesTerritoryName,
  //   );

  //   state = state.copyWith(
  //     data: state.data.whenData(
  //       (v) => v.copyWith(
  //         client: v.client.copyWith(
  //           salesSalesTerritory: newSalesSalesTerritory,
  //         ),
  //       ),
  //     ),
  //     isDirty: true,
  //   );
  // }

  // void addSalesTerritory(SalesTerritory SalesTerritory) {
  //   state = state.copyWith(
  //     data: state.data.whenData(
  //       (v) =>
  //           v.copyWith(SalesTerritorys: [...v.SalesTerritorys, SalesTerritory]),
  //     ),
  //     isDirty: true,
  //   );
  // }

  // void updateSalesTerritory(SalesTerritory SalesTerritory) {
  //   state = state.copyWith(
  //     data: state.data.whenData(
  //       (v) => v.copyWith(
  //         SalesTerritorys: v.SalesTerritorys.map(
  //           (p) => p.SalesTerritoryId == SalesTerritory.SalesTerritoryId
  //               ? SalesTerritory
  //               : p,
  //         ).toList(),
  //       ),
  //     ),
  //     isDirty: true,
  //   );
  // }

  // void removeSalesTerritory(String SalesTerritoryId) {
  //   state = state.copyWith(
  //     data: state.data.whenData(
  //       (v) => v.copyWith(
  //         SalesTerritorys: v.SalesTerritorys.where(
  //           (p) => p.SalesTerritoryId != SalesTerritoryId,
  //         ).toList(),
  //       ),
  //     ),
  //     isDirty: true,
  //   );
  // }

  // Future<bool> updateSalesTerritory({String? noted}) async {
  //   final detail = state.data.valueOrNull;
  //   if (!state.isDirty || detail == null) return false;

  //   state = state.copyWith(isLoading: true);

  //   try {
  //     return await _SalesTerritoryService.updateSalesTerritory(detail);
  //   } catch (e, st) {
  //     state = state.copyWith(data: AsyncError(e, st));
  //   } finally {
  //     state = state.copyWith(isLoading: false);
  //   }

  //   return false;
  // }

  // Future<bool> deleteSalesTerritory() async {
  //   state = state.copyWith(isLoading: true);

  //   try {
  //     return await _SalesTerritoryService.deleteSalesTerritory(id);
  //   } catch (e, st) {
  //     state = state.copyWith(data: AsyncError(e, st));
  //   } finally {
  //     state = state.copyWith(isLoading: false);
  //   }

  //   return false;
  // }
  void setTerritory(Territory status) {
    // final newSalesTerritory = SalesTerritory(
    //   salesTerritoryID: status.salesTerritoryID,
    //   salesTerritoryName: status.salesTerritoryName,
    // );
    state = state.copyWith(
      data: state.data.whenData(
        (v) => v.copyWith(
          salesTerritoryID: status.salesTerritoryID,
          salesTerritoryName: status.salesTerritoryName,
        ),
      ),
      isDirty: true,
    );
  }
}