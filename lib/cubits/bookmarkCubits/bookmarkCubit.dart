import 'package:e_demand/app/generalImports.dart';

//state
abstract class BookmarkState {}

class BookmarkInitial extends BookmarkState {}

class BookmarkFetchInProgress extends BookmarkState {}

class BookmarkFetchSuccess extends BookmarkState {
  BookmarkFetchSuccess({
    required this.isLoadingMoreData,
    required this.isLoadingMoreError,
    required this.loadMoreError,
    required this.bookmarkList,
    required this.totalBookmark,
  });

  final List<Providers> bookmarkList;
  final int totalBookmark;
  final bool isLoadingMoreData;
  final bool isLoadingMoreError;
  final String loadMoreError;

  BookmarkFetchSuccess copyWith({
    required final int totalBookmark,
    required final List<Providers> bookmarkList,
    required final bool isLoadingMoreData,
    required final bool isLoadingMoreError,
    required final String loadMoreError,
  }) =>
      BookmarkFetchSuccess(
        isLoadingMoreData: isLoadingMoreData,
        isLoadingMoreError: isLoadingMoreError,
        loadMoreError: loadMoreError,
        bookmarkList: bookmarkList,
        totalBookmark: totalBookmark,
      );
}

class BookmarkFetchFailure extends BookmarkState {
  BookmarkFetchFailure({required this.errorMessage});

  final String errorMessage;
}

class BookmarkCubit extends Cubit<BookmarkState> {
  BookmarkCubit(this.bookmarkRepository) : super(BookmarkInitial());
  final BookmarkRepository bookmarkRepository;

  Future fetchBookmark({required final String type}) async {
    emit(BookmarkFetchInProgress());
    //
    final Map<String, dynamic> parameter = <String, dynamic>{
      Api.type: type,
      Api.limit: UiUtils.limitOfAPIData,
      Api.offset: "0",
      Api.longitude: HiveRepository.getLongitude,
      Api.latitude: HiveRepository.getLatitude,
    };
    //
    await bookmarkRepository
        .getBookmark(isAuthTokenRequired: true, parameter: parameter)
        .then((final value) {
      emit(
        BookmarkFetchSuccess(
          isLoadingMoreError: false,
          isLoadingMoreData: false,
          loadMoreError: "",
          bookmarkList: value['bookmark'],
          totalBookmark: int.parse(value['totalBookmark']),
        ),
      );
    }).catchError((final e, st) {
      emit(BookmarkFetchFailure(errorMessage: e.toString()));
    });
  }

  bool hasMoreBookMark() {
    if (state is BookmarkFetchSuccess) {
      final bool hasMoreData =
          (state as BookmarkFetchSuccess).bookmarkList.length <
              (state as BookmarkFetchSuccess).totalBookmark;

      return hasMoreData;
    }
    return false;
  }

  Future<void> fetchMoreBookmark(
      {required final String type, final String? providerId}) async {
    //
    if (state is BookmarkFetchSuccess) {
      if ((state as BookmarkFetchSuccess).isLoadingMoreData) {
        return;
      }
    }
    //
    final Map<String, dynamic> parameter = <String, dynamic>{
      Api.type: type,
      Api.limit: UiUtils.limitOfAPIData,
      Api.offset: (state as BookmarkFetchSuccess).bookmarkList.length,
      Api.longitude: HiveRepository.getLongitude,
      Api.latitude: HiveRepository.getLatitude,
    };
    //
    final BookmarkFetchSuccess currentState = state as BookmarkFetchSuccess;
    emit(
      currentState.copyWith(
        totalBookmark: currentState.totalBookmark,
        bookmarkList: currentState.bookmarkList,
        isLoadingMoreData: true,
        isLoadingMoreError: false,
        loadMoreError: "",
      ),
    );
    //
    await bookmarkRepository
        .getBookmark(isAuthTokenRequired: true, parameter: parameter)
        .then((final value) {
      //
      final oldList = currentState.bookmarkList;

      oldList.addAll(value['bookmark']);

      emit(
        BookmarkFetchSuccess(
          isLoadingMoreData: false,
          isLoadingMoreError: false,
          loadMoreError: "",
          bookmarkList: oldList,
          totalBookmark: value['totalBookmark'],
        ),
      );
    }).catchError((final e) {
      emit(
        BookmarkFetchSuccess(
          isLoadingMoreData: false,
          isLoadingMoreError: true,
          loadMoreError: e.toString(),
          bookmarkList: currentState.bookmarkList,
          totalBookmark: currentState.totalBookmark,
        ),
      );
    });
  }

  void addBookmark(final Providers providers) {
    if (state is BookmarkFetchSuccess) {
      final bookmarkPartner = (state as BookmarkFetchSuccess).bookmarkList;
      bookmarkPartner.insert(0, providers);
      emit(
        BookmarkFetchSuccess(
          isLoadingMoreData: false,
          isLoadingMoreError: false,
          loadMoreError: "",
          bookmarkList: bookmarkPartner,
          totalBookmark: (state as BookmarkFetchSuccess).totalBookmark,
        ),
      );
    }
  }

  //pass only partner id here
  void removeBookmark(final String id) {
    if (state is BookmarkFetchSuccess) {
      final bookmarkPartner = (state as BookmarkFetchSuccess).bookmarkList;
      bookmarkPartner.removeWhere((final element) => element.providerId == id);
      emit(
        BookmarkFetchSuccess(
          isLoadingMoreData: false,
          isLoadingMoreError: false,
          loadMoreError: "",
          bookmarkList: bookmarkPartner,
          totalBookmark: (state as BookmarkFetchSuccess).totalBookmark,
        ),
      );
    }
  }

  bool isPartnerBookmark(final String providerId) {
    if (state is BookmarkFetchSuccess) {
      final bookmarkPartner = (state as BookmarkFetchSuccess).bookmarkList;
      return bookmarkPartner.indexWhere(
              (final Providers element) => element.providerId == providerId) !=
          -1;
    }
    return false;
  }

  void clearBookMarkCubit() {
    emit(
      BookmarkFetchSuccess(
        bookmarkList: [],
        isLoadingMoreData: false,
        isLoadingMoreError: false,
        loadMoreError: "",
        totalBookmark: 0,
      ),
    );
  }
}
