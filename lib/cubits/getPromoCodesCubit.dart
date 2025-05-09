//Cubit
import 'package:madwell/app/generalImports.dart';

class GetPromocodeCubit extends Cubit<GetPromocodeState> {
  GetPromocodeCubit({required this.cartRepository})
      : super(GetPromocodeInitial());
  final CartRepository cartRepository;

  void getPromocodes(
      {required final String providerIdOrSlug,
      ProviderDetailsParamType type = ProviderDetailsParamType.id}) {
    emit(FetchPromocodeInProgress());

    cartRepository
        .fetchPromocodes(providerIdOrSlug: providerIdOrSlug, type: type)
        .then((final value) {
      emit(FetchPromocodeSuccess(promocodeList: value));
    }).catchError((final e) {
      emit(FetchPromocodeFailure(errorMessage: e.toString()));
    });
  }
}

//State

abstract class GetPromocodeState {}

class GetPromocodeInitial extends GetPromocodeState {}

class FetchPromocodeInProgress extends GetPromocodeState {}

class FetchPromocodeSuccess extends GetPromocodeState {
  FetchPromocodeSuccess({required this.promocodeList});
  final List<Promocode> promocodeList;
}

class FetchPromocodeFailure extends GetPromocodeState {
  FetchPromocodeFailure({required this.errorMessage});
  final String errorMessage;
}
