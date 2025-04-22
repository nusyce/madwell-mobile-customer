import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class CancelAndRescheduleButton extends StatelessWidget {
  final String buttonName;
  final String bookingId;
  final VoidCallback? onButtonTap;

  const CancelAndRescheduleButton(
      {super.key,
      required this.buttonName,
      this.onButtonTap,
      required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChangeBookingStatusCubit, ChangeBookingStatusState>(
      builder: (final context, final ChangeBookingStatusState state) {
        Widget? child;
        if (state is ChangeBookingStatusInProgress) {
          if (state.pressedButtonName == buttonName &&
              state.bookingId == bookingId) {
            child = const CustomCircularProgressIndicator(
              color: AppColors.whiteColors,
            );
          } else if (state.pressedButtonName == buttonName &&
              state.bookingId == bookingId) {
            child = const CustomCircularProgressIndicator(
              color: AppColors.whiteColors,
            );
          }
        }
        //
        return Align(
          alignment: Alignment.bottomCenter,
          child: CustomContainer(
            borderRadius: UiUtils.borderRadiusOf10,
            color: context.colorScheme.secondaryColor,
            child: CustomRoundedButton(
              onTap: onButtonTap,
              backgroundColor: context.colorScheme.accentColor.withAlpha(50),
              buttonTitle: buttonName.translate(context: context),
              titleColor: context.colorScheme.accentColor,
              showBorder: false,
              widthPercentage: 1,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
