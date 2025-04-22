import 'package:e_demand/app/generalImports.dart';

abstract class UserDetailsState {}

class UserDetailsInitial extends UserDetailsState {}

class UserDetails extends UserDetailsState {
  UserDetails(this.userDetailsModel);

  final UserDetailsModel userDetailsModel;
}

class UserDetailsCubit extends Cubit<UserDetailsState> {
  UserDetailsCubit() : super(UserDetailsInitial());
  AuthenticationRepository _authenticationRepository =
      AuthenticationRepository();

  void setUserDetails(final UserDetailsModel details) {
    emit(UserDetails(details));
  }

  Future<void> getUserDetailsFromServer() async {
    try {
      final UserDetailsModel userDetailsModel =
          await _authenticationRepository.getUserDetails();
      //
      emit(UserDetails(userDetailsModel));
    } catch (_) {}
  }

  void loadUserDetails() {
    final Map detailsMap =
        HiveRepository.getAllValueOf(boxName: HiveRepository.userDetailBoxKey);

    final UserDetailsModel userDetailsModel =
        UserDetailsModel.fromMap(Map.from(detailsMap));
    emit(UserDetails(userDetailsModel));
  }

  void changeUserDetails(final UserDetailsModel details) {
    if (state is UserDetails) {
      final UserDetailsModel oldDetails =
          (state as UserDetails).userDetailsModel;

      final UserDetailsModel newDetails = oldDetails.copyWith(
        email: details.email,
        username: details.username,
        image: details.image,
        phone: details.phone,
        latitude: details.latitude,
        longitude: details.longitude,
        countryCode: details.countryCode,
        countryCodeName: details.countryCodeName,
        userLoginType: details.userLoginType,
      );
      emit(UserDetails(newDetails));
    }
  }

  void clearCubit() {
    emit(UserDetails(UserDetailsModel.fromMap({})));
  }

  UserDetailsModel getUserDetails() {
    if (state is UserDetails) {
      return (state as UserDetails).userDetailsModel;
    }
    return UserDetailsModel.fromMap({});
  }
}
