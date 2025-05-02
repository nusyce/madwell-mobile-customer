import 'package:madwell/app/generalImports.dart';
import 'package:flutter/material.dart';

class BookingCardContainer extends StatelessWidget {
  final Booking bookingDetailsData;
  final String bookingScreenName;

  const BookingCardContainer({
    super.key,
    required this.bookingDetailsData,
    required this.bookingScreenName,
  });

  Widget _buildPriceContainer({required BuildContext context}) {
    return CustomText(
      (bookingDetailsData.finalTotal ?? "0").priceFormat(),
      color: context.colorScheme.blackColor,
      fontWeight: FontWeight.w700,
      fontSize: 20,
    );
  }

  Widget _buildButtonForReBookAndRate({
    required BuildContext context,
  }) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      if (bookingDetailsData.status == "completed") ...[
        Expanded(
            child: CustomRoundedButton(
          onTap: () {
            Navigator.pushNamed(
              context,
              bookingDetails,
              arguments: {"bookingDetails": bookingDetailsData},
            );
          },
          backgroundColor: context.colorScheme.lightGreyColor.withAlpha(40),
          buttonTitle: 'rateService'.translate(context: context),
          showBorder: false,
          widthPercentage: 0.9,
          fontWeight: FontWeight.w500,
          radius: UiUtils.borderRadiusOf5,
          titleColor: context.colorScheme.blackColor,
          shadowColor: context.colorScheme.lightGreyColor.withAlpha(20),
          textSize: 14,
        )),
        const CustomSizedBox(
          width: 10,
        )
      ],
      if (bookingDetailsData.isReorderAllowed == "1") ...[
        Expanded(
          child: ReOrderButton(
            bookingDetails: bookingDetailsData,
            isReorderFrom: "bookingDetails",
            bookingId: bookingDetailsData.id ?? "0",
            textSize: 14,
            cardFrom: 'home',
          ),
        ),
      ],
    ]);
  }

  Widget _buildProviderDetailsAndOtherOptionsWidget({
    required final BuildContext context,
  }) =>
      Row(
        children: [
          CustomInkWellContainer(
            onTap: () {
              Navigator.pushNamed(
                context,
                providerRoute,
                arguments: {"providerId": bookingDetailsData.partnerId ?? "0"},
              );
            },
            child: CustomContainer(
              border: Border.all(
                  color: context.colorScheme.lightGreyColor, width: 0.5),
              borderRadius: UiUtils.borderRadiusOf5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf5),
                child: CustomCachedNetworkImage(
                  height: 36,
                  width: 36,
                  networkImageUrl: bookingDetailsData.profileImage ?? "",
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          const CustomSizedBox(
            width: 12,
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: "${bookingDetailsData.companyName}",
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.pushNamed(
                      context,
                      providerRoute,
                      arguments: {
                        "providerId": bookingDetailsData.partnerId ?? "0"
                      },
                    );
                  },
                style: TextStyle(
                  fontSize: 14,
                  color: context.colorScheme.blackColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
          //  Spacer(),
          CustomContainer(
            height: 44,
            padding: const EdgeInsetsDirectional.all(12),
            color: bookingDetailsData.status == "completed" ||
                    bookingDetailsData.status == "cancelled"
                ? context.colorScheme.lightGreyColor.withValues(alpha: 0.1)
                : context.colorScheme.accentColor.withValues(alpha: 0.1),
            borderRadius: UiUtils.borderRadiusOf10,
            child: Row(children: [
              CustomToolTip(
                toolTipMessage: "location".translate(context: context),
                child: CustomInkWellContainer(
                  borderRadius: BorderRadius.circular(5),
                  onTap: () async {
                    if (bookingDetailsData.addressId == "0") {
                      try {
                        await launchUrl(
                          Uri.parse(
                            'https://www.google.com/maps/search/?api=1&query=${bookingDetailsData.providerLatitude},${bookingDetailsData.providerLongitude}',
                          ),
                          mode: LaunchMode.externalApplication,
                        );
                      } catch (e) {
                        UiUtils.showMessage(
                          context,
                          'somethingWentWrong'.translate(context: context),
                          ToastificationType.error,
                        );
                      }
                    }
                  },
                  child: CustomSvgPicture(
                    svgImage: AppAssets.icLocation,
                    color: bookingDetailsData.status == "completed" ||
                            bookingDetailsData.status == "cancelled"
                        ? context.colorScheme.lightGreyColor
                        : context.colorScheme.accentColor,
                  ),
                ),
              ),
              if (bookingDetailsData.isPostBookingChatAllowed == "1") ...[
                SizedBox(
                  height: 40,
                  child: VerticalDivider(
                    thickness: 0.5,
                    color: bookingDetailsData.status == "completed" ||
                            bookingDetailsData.status == "cancelled"
                        ? context.colorScheme.lightGreyColor
                        : context.colorScheme.accentColor,
                  ),
                ),
                CustomToolTip(
                  toolTipMessage: "chat".translate(context: context),
                  child: CustomInkWellContainer(
                    borderRadius: BorderRadius.circular(5),
                    onTap: () {
                      Navigator.pushNamed(context, chatMessages, arguments: {
                        "chatUser": ChatUser(
                          id: bookingDetailsData.partnerId ?? "-",
                          bookingId: bookingDetailsData.id.toString(),
                          bookingStatus: bookingDetailsData.status.toString(),
                          name: bookingDetailsData.companyName.toString(),
                          receiverType: "1",
                          // 1 = provider
                          unReadChats: 0,
                          profile: bookingDetailsData.profileImage,
                          senderId: context
                                  .read<UserDetailsCubit>()
                                  .getUserDetails()
                                  .id ??
                              "0",
                        ),
                      });
                    },
                    child: CustomSvgPicture(
                      svgImage: AppAssets.drChat,
                      color: bookingDetailsData.status == "completed" ||
                              bookingDetailsData.status == "cancelled"
                          ? context.colorScheme.lightGreyColor
                          : context.colorScheme.accentColor,
                    ),
                  ),
                )
              ],
            ]),
          ),
        ],
      );

  Widget _buildCompnyName({
    required final BuildContext context,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text.rich(
            TextSpan(
              text: "${bookingDetailsData.companyName}",
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.pushNamed(
                    context,
                    providerRoute,
                    arguments: {
                      "providerId": bookingDetailsData.partnerId ?? "0"
                    },
                  );
                },
              style: TextStyle(
                fontSize: 14,
                color: context.colorScheme.lightGreyColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
          ),
        ),
        Icon(
          Icons.chevron_right,
          color: context.colorScheme.lightGreyColor,
          size: 22,
        ),
      ],
    );
  }

  Widget _buildStatusAndInvoiceContainer({
    required final BuildContext context,
  }) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              flex: 6,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    child: CustomText(
                      "${"invoiceNumber".translate(context: context)}: ",
                      maxLines: 1,
                      color: context.colorScheme.blackColor,
                      textAlign: TextAlign.start,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Flexible(
                    child: CustomText(
                      bookingDetailsData.invoiceNo ?? "0",
                      color: context.colorScheme.accentColor,
                      maxLines: 1,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              )),
          Expanded(flex: 4, child: _buildStatusRow(context: context)),
        ],
      );

  Widget _buildStatusRow({
    required final BuildContext context,
  }) =>
      SizedBox(
        height: 20,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: CustomText(
                (bookingDetailsData.status ?? "")
                    .translate(context: context)
                    .capitalize(),
                color: UiUtils.getBookingStatusColor(
                    context: context,
                    statusVal: bookingDetailsData.status ?? ""),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: Icon(
                Icons.chevron_right,
                color: UiUtils.getBookingStatusColor(
                    context: context,
                    statusVal: bookingDetailsData.status ?? ""),
                size: 22,
              ),
            ),
          ],
        ),
      );

//
  Widget _buildServiceListContainer({
    required final BuildContext context,
  }) =>
      ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (final BuildContext context, final int index) =>
              const SizedBox(height: 8),
          itemCount: bookingDetailsData.services!.length > 3
              ? 3
              : bookingDetailsData.services!.length,
          itemBuilder: (final BuildContext context, final int index) {
            if (index > 1) {
              return CustomText(
                '+${bookingDetailsData.services!.length - 2} ${bookingDetailsData.services!.length - 2 == 1 ? "moreService".translate(context: context) : "moreServices".translate(context: context)}',
                fontSize: 14,
                color: context.colorScheme.accentColor,
                maxLines: 1,
                fontWeight: FontWeight.w400,
              );
            }
            return CustomText(
              '${bookingDetailsData.services![index].serviceTitle}',
              fontSize: 16,
              color: context.colorScheme.blackColor,
              maxLines: 1,
              fontWeight: FontWeight.w500,
            );
          });

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      width: context.screenWidth,
      color: context.colorScheme.secondaryColor,
      borderRadius: UiUtils.borderRadiusOf10,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bookingScreenName != "homeScreen"
              ? _buildStatusAndInvoiceContainer(
                  context: context,
                )
              : _buildCompnyName(context: context),
          const SizedBox(
            height: 12,
          ),
          CustomDivider(
            thickness: 0.5,
            color: Theme.of(context).colorScheme.lightGreyColor,
          ),
          const SizedBox(
            height: 12,
          ),
          _buildServiceListContainer(
            context: context,
          ),
          if (bookingScreenName != "homeScreen") ...[
            const SizedBox(
              height: 16,
            ),
            _buildPriceContainer(context: context),
          ],
          const SizedBox(
            height: 16,
          ),
          bookingScreenName != "homeScreen"
              ? _buildProviderDetailsAndOtherOptionsWidget(
                  context: context,
                )
              : _buildButtonForReBookAndRate(
                  context: context,
                )
        ],
      ),
    );
  }
}
