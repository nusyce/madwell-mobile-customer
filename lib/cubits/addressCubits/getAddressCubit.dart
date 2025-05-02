import 'package:madwell/app/generalImports.dart';

abstract class GetAddressState {}

class GetAddressInitial extends GetAddressState {}

class GetAddressInProgress extends GetAddressState {}

class GetAddressSuccess extends GetAddressState {
  GetAddressSuccess(this.data);
  List<GetAddressModel> data;
}

class GetAddressFail extends GetAddressState {
  GetAddressFail(this.error);
  final String error;
}

class GetAddressCubit extends Cubit<GetAddressState> {
  GetAddressCubit() : super(GetAddressInitial());

  final AddressRepository _address = AddressRepository();

  Future fetchAddress() async {
    try {
      emit(GetAddressInProgress());

      final List<GetAddressModel> response = await _address.fetchAddress();
      emit(GetAddressSuccess(response));
    } catch (e) {
      emit(GetAddressFail(e.toString()));
    }
  }

  void updateDefaultAddress(String defaultAddressId) {
    if (state is GetAddressSuccess) {
      List<GetAddressModel> addressList = (state as GetAddressSuccess).data;

      addressList = addressList.map((address) {
        if (address.isDefault == '1') {
          return address.copyWith(isDefault: '0');
        }
        return address;
      }).toList();

      addressList = addressList.map((address) {
        if (address.id == defaultAddressId) {
          return address.copyWith(isDefault: '1');
        }
        return address;
      }).toList();

      emit(GetAddressSuccess(addressList));
    }
  }
}
