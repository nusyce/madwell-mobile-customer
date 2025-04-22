import 'package:e_demand/app/generalImports.dart';

//State
abstract class DownloadInvoiceState {}

class DownloadInvoiceInitial extends DownloadInvoiceState {}

class DownloadInvoiceInProgress extends DownloadInvoiceState {
  final String bookingId;
  final String buttonScreenName;

  DownloadInvoiceInProgress(
      {required this.bookingId, required this.buttonScreenName});
}

class DownloadInvoiceSuccess extends DownloadInvoiceState {
  DownloadInvoiceSuccess(
      {required this.bookingId,
      required this.invoiceData,
      required this.buttonScreenName});

  final String buttonScreenName;
  final List<int> invoiceData;
  final String bookingId;
}

class DownloadInvoiceFailure extends DownloadInvoiceState {
  DownloadInvoiceFailure(
      {required this.bookingId,
      required this.errorMessage,
      required this.buttonScreenName});

  final String errorMessage;
  final String bookingId;
  final String buttonScreenName;
}

class DownloadInvoiceCubit extends Cubit<DownloadInvoiceState> {
  DownloadInvoiceCubit(this.bookingRepository)
      : super(DownloadInvoiceInitial());
  BookingRepository bookingRepository;

  void downloadInvoice(
      {required final String bookingId,
      required final String buttonScreenName}) {
    emit(DownloadInvoiceInProgress(
        bookingId: bookingId, buttonScreenName: buttonScreenName));

    bookingRepository.downloadInvoice(bookingId: bookingId).then((final value) {
      emit(DownloadInvoiceSuccess(
          invoiceData: value,
          bookingId: bookingId,
          buttonScreenName: buttonScreenName));
    }).catchError((final e, final st) {
      emit(DownloadInvoiceFailure(
          errorMessage: e.toString(),
          bookingId: bookingId,
          buttonScreenName: buttonScreenName));
    });
  }
}
