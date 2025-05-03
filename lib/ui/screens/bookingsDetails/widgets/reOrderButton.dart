import 'package:madwell/app/generalImports.dart';
import 'package:flutter/material.dart';

class ReOrderButton extends StatelessWidget {
  final String bookingId;
  final String isReorderFrom;
  final Booking bookingDetails;
  final double? textSize;
  final String cardFrom;

  const ReOrderButton(
      {super.key,
      required this.bookingId,
      required this.isReorderFrom,
      required this.bookingDetails,
      this.textSize,
      this.cardFrom = 'booking'});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CartCubit, CartState>(
      listener: (final BuildContext context, CartState state) {
        if (state is CartFetchFailure) {
          //
          UiUtils.showMessage(
              context,
              state.errorMessage.translate(context: context),
              ToastificationType.error);
        } else if (state is CartFetchSuccess) {
          if (state.isReorderCart &&
              state.reOrderId == bookingId &&
              bookingDetails == state.bookingDetails &&
              isReorderFrom == state.isReorderFrom) {
            //
            context.read<GetPromocodeCubit>().getPromocodes(
                providerIdOrSlug: state.reOrderCartData?.providerId ?? "0");
            //
            Navigator.pushNamed(
              context,
              scheduleScreenRoute,
              arguments: {
                "isFrom": "reBooking",
                "providerName": state.reOrderCartData?.providerName,
                "providerId": state.reOrderCartData?.providerId,
                "companyName": state.reOrderCartData?.companyName,
                "providerAdvanceBookingDays":
                    state.reOrderCartData?.advanceBookingDays,
                "orderID": state.reOrderId
              },
            );
          }
        }
      },
      builder: (final BuildContext context, final CartState state) {
        Widget? child;
        if (state is CartFetchInProgress) {
          if (state.reOrderId == bookingId)
            child = const CustomCircularProgressIndicator(
                color: AppColors.whiteColors);
        }
        //
        return Align(
          alignment: Alignment.bottomCenter,
          child: CustomRoundedButton(
            onTap: () {
              if (state is CartFetchInProgress) {
                return;
              }
              context.read<CartCubit>().getCartDetails(
                  isReorderFrom: isReorderFrom,
                  bookingDetails: bookingDetails,
                  reOrderId: bookingId,
                  isReorderCart: true);
            },
            backgroundColor: cardFrom == 'home'
                ? context.colorScheme.accentColor
                : context.colorScheme.accentColor.withAlpha(30),
            buttonTitle: 'reBooking'.translate(context: context),
            showBorder: false,
            widthPercentage: 0.9,
            fontWeight: FontWeight.w500,
            radius: UiUtils.borderRadiusOf5,
            titleColor: cardFrom == 'home'
                ? AppColors.whiteColors
                : context.colorScheme.accentColor,
            shadowColor: context.colorScheme.accentColor.withAlpha(30),
            textSize: textSize,
            child: child,
          ),
        );
      },
    );
  }
}
