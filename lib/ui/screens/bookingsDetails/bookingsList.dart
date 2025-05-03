import 'package:madwell/app/generalImports.dart';
import 'package:flutter/material.dart';

class BookingsList extends StatefulWidget {
  final String selectedStatus;
  final ScrollController scrollController;

  const BookingsList(
      {super.key,
      required this.selectedStatus,
      required this.scrollController});

  @override
  State<BookingsList> createState() => _BookingsListState();
}

class _BookingsListState extends State<BookingsList> {
  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(fetchMoreBookingDetails);
  }

  void fetchMoreBookingDetails() {
    if (mounted && !context.read<BookingCubit>().hasMoreBookings()) {
      return;
    }

    final nextPageTrigger =
        0.7 * widget.scrollController.position.maxScrollExtent;

    if (widget.scrollController.position.pixels > nextPageTrigger) {
      if (mounted) {
        context.read<BookingCubit>().fetchMoreBookingDetails(
              status: widget.selectedStatus,
              customRequestOrders: _getCustomRequestOrders(),
            );
      }
    }
  }

  String _getCustomRequestOrders() {
    final bookingsScreen =
        context.findAncestorStateOfType<BookingsScreenState>();
    return bookingsScreen?.isCustomBooking ?? false ? "1" : "";
  }

  void fetchBookingDetails() {
    Future.delayed(Duration.zero).then((final value) {
      context.read<BookingCubit>().fetchBookingDetails(
            status: widget.selectedStatus,
            customRequestOrders: _getCustomRequestOrders(),
          );
    });
  }

//
  Widget _getBookingShimmerLoading(
          {required final int numberOfShimmerContainer}) =>
      SingleChildScrollView(
        padding: EdgeInsets.only(
            bottom: UiUtils.getScrollViewBottomPadding(context)),
        child: Column(
          children: List.generate(
            numberOfShimmerContainer,
            (final int index) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: CustomShimmerLoadingContainer(
                height: 220,
              ),
            ),
          ),
        ),
      );
//
  Widget getBookingDetailsData({
    required final List<Booking> bookingDetailsList,
    required final bool isLoadingMoreData,
    required final bool isLoadingMoreError,
  }) {
    return bookingDetailsList.isEmpty
        ? Center(
            child: NoDataFoundWidget(
              titleKey: 'noBookingFound'.translate(context: context),
            ),
          )
        : ListView.separated(
            controller: widget.scrollController,
            padding: EdgeInsets.only(
                top: 16,
                bottom: UiUtils.getScrollViewBottomPadding(context),
                right: 5,
                left: 5),
            physics: const AlwaysScrollableScrollPhysics(),
            separatorBuilder: (final BuildContext context, final int index) =>
                const SizedBox(
              height: 16,
            ),
            itemCount: bookingDetailsList.length +
                (isLoadingMoreData || isLoadingMoreError ? 1 : 0),
            itemBuilder: (final BuildContext context, final int index) {
              if (index >= bookingDetailsList.length) {
                return CustomLoadingMoreContainer(
                  isError: isLoadingMoreError,
                  onErrorButtonPressed: () {
                    fetchMoreBookingDetails();
                  },
                );
              }
              return CustomInkWellContainer(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    bookingDetails,
                    arguments: {"bookingDetails": bookingDetailsList[index]},
                  );
                },
                //if user cancel the booking from booking details
                //then again state will build and remove cancelled booking
                //from other status's booking details
                //and  "" is used to check for all status bookings
                child: widget.selectedStatus == "" ||
                        bookingDetailsList[index].status ==
                            widget.selectedStatus
                    ? BookingCardContainer(
                        bookingDetailsData: bookingDetailsList[index],
                        bookingScreenName: "bookingsList",
                      )
                    : const CustomSizedBox(),
              );
            },
          );
  }

//
  @override
  Widget build(final BuildContext context) =>
      BlocListener<ChangeBookingStatusCubit, ChangeBookingStatusState>(
        listener: (context, state) {
          if (state is ChangeBookingStatusFailure) {
            UiUtils.showMessage(
                context,
                state.errorMessage.toString().translate(context: context),
                ToastificationType.error);
          } else if (state is ChangeBookingStatusSuccess) {
            UiUtils.showMessage(
                context, state.message, ToastificationType.success);
            //
            context
                .read<BookingCubit>()
                .updateBookingDataLocally(latestBookingData: state.bookingData);
          }
        },
        child: BlocBuilder<BookingCubit, BookingState>(
          builder: (final BuildContext context, final BookingState state) {
            if (state is BookingFetchFailure) {
              return ErrorContainer(
                errorMessage: state.errorMessage.translate(context: context),
                onTapRetry: () {
                  fetchBookingDetails();
                },
              );
            }
            if (state is BookingFetchSuccess) {
              return state.bookingData.isEmpty
                  ? NoDataFoundWidget(
                      titleKey: 'noBookingFound'.translate(context: context),
                    )
                  : CustomRefreshIndicator(
                      onRefreshCallback: () {
                        fetchBookingDetails();
                      },
                      displacment: 12,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 10, bottom: 15, right: 10),
                        child: getBookingDetailsData(
                          isLoadingMoreError: state.isLoadMoreError,
                          bookingDetailsList: state.bookingData,
                          isLoadingMoreData: state.isLoadingMoreData,
                        ),
                      ),
                    );
            }
            return _getBookingShimmerLoading(
              numberOfShimmerContainer: UiUtils.numberOfShimmerContainer,
            );
          },
        ),
      );
}
