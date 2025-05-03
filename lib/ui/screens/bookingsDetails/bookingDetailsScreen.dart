// ignore_for_file: use_build_context_synchronously

import 'package:madwell/app/generalImports.dart';
import 'package:madwell/ui/screens/bookingsDetails/paymentGatewayManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

typedef PaymentGatewayDetails = ({String paymentType, String paymentImage});

// ignore: must_be_immutable
class BookingDetails extends StatefulWidget {
  //

  Booking bookingDetails;

  BookingDetails({final Key? key, required this.bookingDetails})
      : super(key: key);

  static Route route(final RouteSettings routeSettings) {
    final Map parameters = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (final BuildContext context) => Builder(builder: (context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<AddTransactionCubit>(
              create: (context) =>
                  AddTransactionCubit(bookingRepository: BookingRepository()),
            ),
            BlocProvider<ChangeBookingStatusCubit>(
              create: (context) => ChangeBookingStatusCubit(
                  bookingRepository: BookingRepository()),
            ),
          ],
          child: BookingDetails(
            bookingDetails: parameters["bookingDetails"],
          ),
        );
      }),
    );
  }

  @override
  State<BookingDetails> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  ValueNotifier<bool> isBillDetailsCollapsed = ValueNotifier(true);
  PaymentGatewayManager? _paymentManager;

  //TODO CHANGE HERE "isPayLaterAllowed"
  late List<Map<String, dynamic>> enabledPaymentMethods = context
      .read<SystemSettingCubit>()
      .getEnabledPaymentMethods(
          isPayLaterAllowed:
              widget.bookingDetails.isPayLaterAllowed == 1 ? true : false);
  late String selectedPaymentMethod = '';
  late String selectedDeliverableOption = deliverableOptions[0]['title']!;
  late final List<Map<String, String>> deliverableOptions = [
    {
      "title": 'atHome',
      "description": 'atHomeDescription',
      "image": AppAssets.home
    },
    {
      "title": 'atStore',
      "description": 'atStoreDescription',
      "image": AppAssets.store
    },
  ];
  ValueNotifier<String> paymentButtonName = ValueNotifier("");

  ({String paymentImage, String paymentType}) getPaymentGatewayDetails() {
    switch (selectedPaymentMethod) {
      case "cod":
        return (paymentType: "cod", paymentImage: AppAssets.cod);
      case "stripe":
        return (paymentType: "stripe", paymentImage: AppAssets.stripe);
      case "razorpay":
        return (paymentType: "razorpay", paymentImage: AppAssets.razorpay);
      case "paystack":
        return (paymentType: "paystack", paymentImage: AppAssets.paystack);
      case "paypal":
        return (paymentType: "paypal", paymentImage: AppAssets.paypal);
      case "flutterwave":
        return (
          paymentType: "flutterwave",
          paymentImage: AppAssets.flutterwave
        );
      default:
        return (paymentType: "cod", paymentImage: AppAssets.cod);
    }
  }

  dynamic selectedDate;

  dynamic selectedTime;

  String? message;

  void initState() {
    super.initState();
    getPaymentGatewayDetails();
  }

  void dispose() {
    _paymentManager?.dispose();
    paymentButtonName.dispose();
    super.dispose();
  }

  //

  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: UiUtils.getSimpleAppBar(
            context: context,
            titleWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  'bookingInformation'.translate(context: context),
                  color: context.colorScheme.blackColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
                CustomText(
                  "${widget.bookingDetails.services!.length.toString()} ${widget.bookingDetails.services!.length > 1 ? 'services'.translate(context: context) : 'service'.translate(context: context)}",
                  color: context.colorScheme.lightGreyColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ],
            ),
            elevation: 0.5),
        body: BlocListener<ChangeBookingStatusCubit, ChangeBookingStatusState>(
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
              context.read<BookingCubit>().updateBookingDataLocally(
                  latestBookingData: state.bookingData);

              widget.bookingDetails = state.bookingData;
            }
          },
          child: BlocBuilder<BookingCubit, BookingState>(
            builder: (final BuildContext context, final BookingState state) {
              if (state is BookingFetchSuccess) {
                return getBookingDetailsData(
                  context: context,
                );
              }

              return ErrorContainer(
                  errorMessage:
                      'somethingWentWrong'.translate(context: context));
            },
          ),
        ),
      );

  Widget _buildNotesWidget({
    required final BuildContext context,
    required final String notes,
  }) =>
      CustomContainer(
        color: context.colorScheme.secondaryColor,
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageAndTitleWidget(context,
                imageName: AppAssets.icNotes,
                title: "notesLbl".translate(context: context)),
            const SizedBox(
              height: 10,
            ),
            CustomText(
              notes,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: context.colorScheme.lightGreyColor,
            ),
          ],
        ),
      );

  Widget _buildProviderImageTitleAndChatOptionWidget({
    required final BuildContext context,
    required final String providerName,
    required final String providerImageUrl,
  }) =>
      CustomContainer(
        color: context.colorScheme.secondaryColor,
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeadingWidget(context,
                title: "provider".translate(context: context)),
            const SizedBox(
              height: 10,
            ),
            CustomInkWellContainer(
              showRippleEffect: false,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  providerRoute,
                  arguments: {
                    "providerId": widget.bookingDetails.partnerId ?? "0"
                  },
                );
              },
              child: Row(
                children: [
                  CustomContainer(
                    border: Border.all(
                        color: context.colorScheme.lightGreyColor, width: 0.5),
                    borderRadius: UiUtils.borderRadiusOf5,
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(UiUtils.borderRadiusOf5),
                      child: CustomContainer(
                        height: 44,
                        width: 44,
                        borderRadius: UiUtils.borderRadiusOf5,
                        child: CustomCachedNetworkImage(
                            height: 44,
                            width: 44,
                            networkImageUrl: providerImageUrl,
                            fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  const CustomSizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: CustomText(
                      providerName,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: context.colorScheme.blackColor,
                      maxLines: 2,
                    ),
                  ),
                  if (widget.bookingDetails.isPostBookingChatAllowed ==
                      "1") ...[
                    CustomContainer(
                      height: 44,
                      padding: const EdgeInsetsDirectional.all(12),
                      color: widget.bookingDetails.status == "completed" ||
                              widget.bookingDetails.status == "cancelled"
                          ? context.colorScheme.lightGreyColor
                              .withValues(alpha: 0.1)
                          : context.colorScheme.accentColor
                              .withValues(alpha: 0.1),
                      borderRadius: UiUtils.borderRadiusOf10,
                      child: CustomToolTip(
                        toolTipMessage: "chat".translate(context: context),
                        child: CustomInkWellContainer(
                          borderRadius: BorderRadius.circular(5),
                          onTap: () {
                            Navigator.pushNamed(context, chatMessages,
                                arguments: {
                                  "chatUser": ChatUser(
                                    id: widget.bookingDetails.partnerId ?? "-",
                                    bookingId:
                                        widget.bookingDetails.id.toString(),
                                    bookingStatus:
                                        widget.bookingDetails.status.toString(),
                                    name: widget.bookingDetails.companyName
                                        .toString(),
                                    receiverType: "1",
                                    // 1 = provider
                                    unReadChats: 0,
                                    profile: widget.bookingDetails.profileImage,
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
                            color: widget.bookingDetails.status ==
                                        "completed" ||
                                    widget.bookingDetails.status == "cancelled"
                                ? context.colorScheme.lightGreyColor
                                : context.colorScheme.accentColor,
                          ),
                        ),
                      ),
                    )
                  ],
                ],
              ),
            ),
          ],
        ),
      );

//
  Widget _buildServiceListContainer({
    required final List<BookedService> servicesList,
    required final BuildContext context,
  }) =>
      CustomContainer(
        color: context.colorScheme.secondaryColor,
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeadingWidget(context, title: "services"),
            const SizedBox(
              height: 10,
            ),
            ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder:
                    (final BuildContext context, final int index) => Column(
                          children: [
                            const SizedBox(
                              height: 12,
                            ),
                            LinearDivider(),
                            const SizedBox(
                              height: 12,
                            ),
                          ],
                        ),
                itemCount: servicesList.length,
                shrinkWrap: true,
                itemBuilder: (final BuildContext context, final int index) {
                  final BookedService service = servicesList[index];
                  //
                  bool collapsed = true;
                  return StatefulBuilder(builder: (context, innerSetState) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            CustomContainer(
                              borderRadius: UiUtils.borderRadiusOf5,
                              width: 62,
                              height: 68,
                              border: Border.all(
                                  color: context.colorScheme.lightGreyColor,
                                  width: 0.5),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    UiUtils.borderRadiusOf5),
                                child: CustomCachedNetworkImage(
                                  networkImageUrl: service.image ?? '',
                                  height: 68,
                                  width: 62,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    '${service.serviceTitle} ',
                                    fontWeight: FontWeight.w500,
                                    color: context.colorScheme.blackColor,
                                    fontSize: 16,
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Row(
                                        children: [
                                          CustomText(
                                            service.priceWithTax!
                                                .toString()
                                                .priceFormat(),
                                            color:
                                                context.colorScheme.accentColor,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                          ),
                                          const SizedBox(
                                            width: 12,
                                          ),
                                          CustomText(
                                            "x${service.quantity}"
                                                .translate(context: context),
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12,
                                            color:
                                                context.colorScheme.blackColor,
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      _buildRatingWidget(context,
                                          service: service,
                                          index: index, onTap: () {
                                        if ((service.comment ?? '').isEmpty &&
                                            (service.reviewImages ?? [])
                                                .isEmpty) {
                                          return;
                                        }
                                        innerSetState(() {
                                          collapsed = !collapsed;
                                        });
                                      }, isCollapsed: collapsed),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (service.rating != "0") ...[
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            child: CustomContainer(
                              constraints: collapsed
                                  ? const BoxConstraints(maxHeight: 0.0)
                                  : const BoxConstraints(
                                      maxHeight: double.infinity,
                                      maxWidth: double.maxFinite,
                                    ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  CustomText(
                                    service.comment ?? "",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: context.colorScheme.lightGreyColor,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  if (service.reviewImages?.isNotEmpty ?? false)
                                    SizedBox(
                                      height: 44,
                                      child: ListView.separated(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          itemCount:
                                              service.reviewImages?.length ?? 0,
                                          separatorBuilder:
                                              (final BuildContext context,
                                                      final int index) =>
                                                  const SizedBox(
                                                    width: 12,
                                                  ),
                                          itemBuilder: (context, index) =>
                                              CustomInkWellContainer(
                                                onTap: () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    imagePreview,
                                                    arguments: {
                                                      "startFrom": index,
                                                      "isReviewType": true,
                                                      "dataURL":
                                                          service.reviewImages,
                                                      "reviewDetails": Reviews(
                                                        id: service.id ?? "",
                                                        rating:
                                                            service.rating ??
                                                                "",
                                                        profileImage: HiveRepository
                                                                .getUserProfilePictureURL ??
                                                            "",
                                                        userName: HiveRepository
                                                                .getUsername ??
                                                            "",
                                                        serviceId:
                                                            service.serviceId ??
                                                                "",
                                                        comment:
                                                            service.comment ??
                                                                "",
                                                        images: service
                                                                .reviewImages ??
                                                            [],
                                                        ratedOn: "",
                                                      ),
                                                    },
                                                  );
                                                },
                                                child: CustomContainer(
                                                    height: 44,
                                                    width: 44,
                                                    borderRadius:
                                                        UiUtils.borderRadiusOf5,
                                                    border: Border.all(
                                                        color: context
                                                            .colorScheme
                                                            .lightGreyColor,
                                                        width: 0.5),
                                                    child: ClipRRect(
                                                        borderRadius: BorderRadius
                                                            .circular(UiUtils
                                                                .borderRadiusOf5),
                                                        child:
                                                            CustomCachedNetworkImage(
                                                          networkImageUrl:
                                                              service.reviewImages?[
                                                                      index] ??
                                                                  "",
                                                          height: 44,
                                                          width: 44,
                                                          fit: BoxFit.fill,
                                                        ))),
                                              )),
                                    )
                                ],
                              ),
                            ),
                          ),
                        ]
                      ],
                    );
                  });
                }),
          ],
        ),
      );

  //
  Widget _getPriceSectionTile({
    required final BuildContext context,
    required final String heading,
    required final String subHeading,
    required final Color textColor,
    final Color? subHeadingTextColor,
    required final double fontSize,
    final FontWeight? fontWeight,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Expanded(
              child: CustomText(heading,
                  color: textColor,
                  maxLines: 1,
                  fontWeight: fontWeight,
                  fontSize: fontSize),
            ),
            CustomText(subHeading,
                color: subHeadingTextColor ?? textColor,
                fontWeight: fontWeight,
                maxLines: 1,
                fontSize: fontSize),
          ],
        ),
      );

//
  Widget _buildPriceSectionWidget({
    required final BuildContext context,
    required final String subTotal,
    required final String taxAmount,
    required final String visitingCharge,
    required final String promoCodeAmount,
    required final String promoCodeName,
    required final String totalAmount,
    required final bool isAtStoreOptionSelected,
  }) {
    return CustomContainer(
      color: context.colorScheme.secondaryColor,
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          CustomInkWellContainer(
            onTap: () {
              isBillDetailsCollapsed.value = !isBillDetailsCollapsed.value;
            },
            child: Row(
              children: [
                Expanded(
                  child: CustomText(
                    "billDetails".translate(context: context),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: context.colorScheme.lightGreyColor,
                  ),
                ),
                ValueListenableBuilder(
                    valueListenable: isBillDetailsCollapsed,
                    builder: (context, bool isCollapsed, _) {
                      return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: isCollapsed
                              ? Icon(Icons.keyboard_arrow_down,
                                  color: context.colorScheme.accentColor,
                                  size: 24)
                              : Icon(Icons.keyboard_arrow_up,
                                  color: context.colorScheme.accentColor,
                                  size: 24));
                    })
              ],
            ),
          ),
          ValueListenableBuilder(
              valueListenable: isBillDetailsCollapsed,
              builder: (context, bool isCollapsed, _) {
                return AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: CustomContainer(
                    constraints: isCollapsed
                        ? const BoxConstraints(maxHeight: 0.0)
                        : const BoxConstraints(
                            maxHeight: double.infinity,
                            maxWidth: double.maxFinite,
                          ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _getPriceSectionTile(
                          context: context,
                          fontSize: 14,
                          heading: 'subTotal'.translate(context: context),
                          subHeading: subTotal.priceFormat(),
                          textColor: context.colorScheme.blackColor,
                        ),
                        if (promoCodeName != "" && promoCodeAmount != "")
                          _getPriceSectionTile(
                            context: context,
                            fontSize: 14,
                            heading:
                                "${"promoCode".translate(context: context)} ($promoCodeName)",
                            subHeading: "- ${promoCodeAmount.priceFormat()}",
                            textColor: context.colorScheme.blackColor,
                          ),
                        if (taxAmount != "" &&
                            taxAmount != "0" &&
                            taxAmount != "0.00")
                          _getPriceSectionTile(
                            context: context,
                            fontSize: 14,
                            heading: 'tax'.translate(context: context),
                            subHeading: "+ ${taxAmount.priceFormat()}",
                            textColor: context.colorScheme.blackColor,
                          ),
                        if (visitingCharge != '0' &&
                            visitingCharge != "" &&
                            visitingCharge != 'null' &&
                            !isAtStoreOptionSelected)
                          _getPriceSectionTile(
                            context: context,
                            fontSize: 14,
                            heading:
                                'visitingCharge'.translate(context: context),
                            subHeading: "+ ${visitingCharge.priceFormat()}",
                            textColor: context.colorScheme.blackColor,
                          ),
                        if (widget.bookingDetails.additionalCharges != null &&
                            widget
                                .bookingDetails.additionalCharges!.isNotEmpty &&
                            widget.bookingDetails.totalAdditionalCharge != '' &&
                            widget.bookingDetails.totalAdditionalCharge !=
                                "0") ...[
                          _getPriceSectionTile(
                            context: context,
                            fontSize: 14,
                            heading:
                                'additionalCharges'.translate(context: context),
                            subHeading:
                                "+ ${widget.bookingDetails.totalAdditionalCharge!.priceFormat()}",
                            textColor: context.colorScheme.blackColor,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
          const SizedBox(
            height: 10,
          ),
          _getPriceSectionTile(
            context: context,
            fontSize: 20,
            heading: (widget.bookingDetails.paymentMethod == "cod"
                    ? "totalAmount"
                    : 'paidAmount')
                .translate(context: context),
            subHeading: totalAmount.priceFormat(),
            textColor: context.colorScheme.blackColor,
            fontWeight: FontWeight.w700,
            subHeadingTextColor: context.colorScheme.accentColor,
          ),
          const SizedBox(
            height: 10,
          ),
          Divider(
            color: context.colorScheme.lightGreyColor,
            thickness: 0.5,
            height: 0.5,
          ),
          const SizedBox(
            height: 10,
          ),
          _buildPaymentModeWidget(context),
        ],
      ),
    );
  }

  //
  Widget _buildUploadedProofWidget({
    required final String title,
    required final List<dynamic> proofData,
  }) =>
      CustomContainer(
        color: context.colorScheme.secondaryColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
              child: _buildSectionHeadingWidget(context, title: title),
            ),
            SizedBox(
              height: 100,
              width: double.infinity,
              child: ListView.separated(
                  separatorBuilder:
                      (final BuildContext context, final int index) =>
                          const SizedBox(
                            width: 12,
                          ),
                  itemCount: proofData.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (final BuildContext context, final int index) {
                    return CustomContainer(
                      height: 100,
                      width: 100,
                      borderRadius: UiUtils.borderRadiusOf10,
                      border: Border.all(
                          color: context.colorScheme.lightGreyColor,
                          width: 0.5),
                      child: CustomInkWellContainer(
                        borderRadius:
                            BorderRadius.circular(UiUtils.borderRadiusOf10),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            imagePreview,
                            arguments: {
                              "startFrom": index,
                              "isReviewType": false,
                              "dataURL": proofData,
                            },
                          ).then((Object? value) {
                            //locked in portrait mode only
                            SystemChrome.setPreferredOrientations(
                              [
                                DeviceOrientation.portraitUp,
                                DeviceOrientation.portraitDown
                              ],
                            );
                          });
                        },
                        child: UrlTypeHelper.getType(proofData[index]) ==
                                UrlType.image
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    UiUtils.borderRadiusOf10),
                                child: CustomCachedNetworkImage(
                                  networkImageUrl: proofData[index],
                                  fit: BoxFit.cover,
                                  height: 100,
                                  width: 100,
                                ),
                              )
                            : UrlTypeHelper.getType(proofData[index]) ==
                                    UrlType.video
                                ? Center(
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: context.colorScheme.accentColor,
                                    ),
                                  )
                                : const CustomSizedBox(),
                      ),
                    );
                  }),
            ),
            const SizedBox(
              height: 15,
            ),
          ],
        ),
      );

//
  Widget getBookingDetailsData({required final BuildContext context}) {
    String scheduledTime =
        "${widget.bookingDetails.dateOfService!.formatDate()}, ${widget.bookingDetails.startingTime!.formatTime()}-${widget.bookingDetails.endingTime!.formatTime()}";
    if (widget.bookingDetails.multipleDaysBooking!.isNotEmpty) {
      String currentDate = "";
      for (int i = 0;
          i < widget.bookingDetails.multipleDaysBooking!.length;
          i++) {
        currentDate =
            "\n${widget.bookingDetails.multipleDaysBooking![i].multipleDayDateOfService.toString().formatDate()},${widget.bookingDetails.multipleDaysBooking![i].multipleDayStartingTime.toString().formatTime()}-${widget.bookingDetails.multipleDaysBooking![i].multipleEndingTime.toString().formatTime()}";
      }
      scheduledTime = scheduledTime + currentDate;
    }
    final booking = widget.bookingDetails;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: 10 +
                (widget.bookingDetails.status == "completed"
                    ? 0
                    : UiUtils.getScrollViewBottomPadding(context)),
            top: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProviderImageTitleAndChatOptionWidget(
                context: context,
                providerName: widget.bookingDetails.companyName!,
                providerImageUrl: widget.bookingDetails.profileImage!,
              ), //
              const SizedBox(
                height: 8,
              ),
              _buildStatusAndInvoiceWidget(context,
                  statusTranslatedValue:
                      widget.bookingDetails.status!.translate(context: context),
                  invoiceNumber: widget.bookingDetails.invoiceNo,
                  status: widget.bookingDetails.status),
              const SizedBox(
                height: 8,
              ),
              _buildBookingAddressDateAndOTPWidget(context),
              const SizedBox(
                height: 8,
              ),
              if (widget.bookingDetails.remarks != "") ...[
                _buildNotesWidget(
                  context: context,
                  notes: widget.bookingDetails.remarks!,
                ),
                const SizedBox(
                  height: 8,
                ),
              ],

              if (widget.bookingDetails.workStartedProof!.isNotEmpty) ...[
                _buildUploadedProofWidget(
                  title: "workStartedProof",
                  proofData: widget.bookingDetails.workStartedProof!,
                ),
                const SizedBox(
                  height: 8,
                ),
              ],
              if (widget.bookingDetails.workCompletedProof!.isNotEmpty) ...[
                _buildUploadedProofWidget(
                  title: "workCompletedProof",
                  proofData: widget.bookingDetails.workCompletedProof!,
                ),
                const SizedBox(
                  height: 8,
                ),
              ],
              if (widget.bookingDetails.isCustomJobRequest) ...[
                _buildCustomJobRequestContainer(),
                if (widget.bookingDetails.services?.first
                            .customJobServiceProviderNote !=
                        null &&
                    widget.bookingDetails.services?.first
                            .customJobServiceProviderNote !=
                        "") ...[
                  const SizedBox(
                    height: 8,
                  ),
                  _buildCustomJobProviderNoteContainer(),
                ],
              ] else ...[
                _buildServiceListContainer(
                  servicesList: widget.bookingDetails.services!,
                  context: context,
                ),
              ],
              const SizedBox(
                height: 8,
              ),
              if (widget.bookingDetails.additionalCharges != null &&
                  widget.bookingDetails.additionalCharges!.isNotEmpty &&
                  widget.bookingDetails.totalAdditionalCharge != '' &&
                  widget.bookingDetails.totalAdditionalCharge != "0") ...[
                _buildAdditionalCharges(),
                const SizedBox(
                  height: 8,
                ),
              ],
              _buildPriceSectionWidget(
                  context: context,
                  totalAmount: widget.bookingDetails.finalTotal!,
                  promoCodeAmount: widget.bookingDetails.promoDiscount!,
                  promoCodeName: widget.bookingDetails.promoCode!,
                  subTotal: (double.parse(widget.bookingDetails.total!
                              .replaceAll(",", "")) -
                          double.parse(
                            widget.bookingDetails.taxAmount!
                                .replaceAll(",", ""),
                          ))
                      .toString(),
                  taxAmount: widget.bookingDetails.taxAmount!,
                  visitingCharge: widget.bookingDetails.visitingCharges!,
                  isAtStoreOptionSelected:
                      widget.bookingDetails.addressId == "0"),
              if (widget.bookingDetails.status == "completed") ...[
                const SizedBox(
                  height: 26,
                ),
                _buildReorderAndGetInvoiceButton(context),
              ],
              if (widget.bookingDetails.status != "completed") ...[
                const SizedBox(
                  height: kBottomNavigationBarHeight,
                ),
              ],
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 15, right: 15),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.bookingDetails.isCancelable == "1" &&
                    widget.bookingDetails.status != "cancelled") ...[
                  Expanded(
                    child: CancelAndRescheduleButton(
                      bookingId: widget.bookingDetails.id ?? "0",
                      buttonName: "cancelBooking",
                      onButtonTap: () {
                        context
                            .read<ChangeBookingStatusCubit>()
                            .changeBookingStatus(
                              pressedButtonName: "cancelBooking",
                              bookingStatus: 'cancelled',
                              bookingId: widget.bookingDetails.id!,
                            );
                      },
                    ),
                  ),
                  if (widget.bookingDetails.status == "awaiting" ||
                      widget.bookingDetails.status == "confirmed")
                    const CustomSizedBox(
                      width: 10,
                    ),
                  if (booking.paymentStatusOfAdditionalCharge == '' &&
                      booking.additionalCharges != null &&
                      booking.additionalCharges!.isNotEmpty &&
                      booking.totalAdditionalCharge != '' &&
                      booking.totalAdditionalCharge != "0")
                    const CustomSizedBox(
                      width: 10,
                    ),
                ],
                if (widget.bookingDetails.status == "awaiting" ||
                    widget.bookingDetails.status == "confirmed")
                  Expanded(
                    child: CancelAndRescheduleButton(
                      bookingId: widget.bookingDetails.id ?? "0",
                      buttonName: "reschedule",
                      onButtonTap: () {
                        UiUtils.showBottomSheet(
                          enableDrag: true,
                          context: context,
                          child: MultiBlocProvider(
                            providers: [
                              BlocProvider<ValidateCustomTimeCubit>(
                                create: (context) => ValidateCustomTimeCubit(
                                    cartRepository: CartRepository()),
                              ),
                              BlocProvider(
                                create: (context) =>
                                    TimeSlotCubit(CartRepository()),
                              )
                            ],
                            child: CalenderBottomSheet(
                              advanceBookingDays: widget
                                  .bookingDetails.providerAdvanceBookingDays
                                  .toString(),
                              providerId:
                                  widget.bookingDetails.partnerId.toString(),
                              selectedDate: selectedDate,
                              selectedTime: selectedTime,
                              orderId: widget.bookingDetails.id.toString(),
                              customJobRequestId: widget.bookingDetails
                                  .services?[0].customJobRequestId,
                            ),
                          ),
                        ).then(
                          (final value) {
                            //
                            final bool isSaved = value['isSaved'];
                            selectedDate = /* DateTime.parse(
                                DateFormat("yyyy-MM-dd").format(DateTime.parse(
                                    "${value['selectedDate']}"))); */
                                intl.DateFormat('yyyy-MM-dd').format(
                                    DateTime.parse("${value['selectedDate']}"));
                            //
                            selectedTime = value['selectedTime'];
                            //
                            message = value['message'];
                            //
                            if (selectedTime != null &&
                                selectedTime != null &&
                                isSaved) {
                              context
                                  .read<ChangeBookingStatusCubit>()
                                  .changeBookingStatus(
                                      pressedButtonName: "reschedule",
                                      bookingStatus: 'rescheduled',
                                      bookingId: widget.bookingDetails.id!,
                                      selectedTime: selectedTime.toString(),
                                      selectedDate: selectedDate.toString());
                            }
                          },
                        );
                      },
                    ),
                  ),
                if (booking.paymentStatusOfAdditionalCharge == '' &&
                    booking.additionalCharges != null &&
                    booking.additionalCharges!.isNotEmpty &&
                    booking.totalAdditionalCharge != '' &&
                    booking.totalAdditionalCharge != "0")
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: CustomRoundedButton(
                          buttonTitle: 'payAdditionalCharges'
                              .translate(context: context),
                          showBorder: true,
                          widthPercentage: 1,
                          backgroundColor: context.colorScheme.accentColor,
                          onTap: () {
                            UiUtils.showAnimatedDialog(
                                context: context,
                                child: _buildAdditionalPaymentWidget(
                                  context: context,
                                  bookingDetails: widget.bookingDetails,
                                ));
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusAndInvoiceWidget(BuildContext context,
      {String? statusTranslatedValue, String? invoiceNumber, String? status}) {
    return CustomContainer(
      color: context.colorScheme.secondaryColor,
      padding: const EdgeInsets.all(15),
      border: Border.symmetric(
        horizontal: BorderSide(
          color: UiUtils.getBookingStatusColor(
              context: context,
              statusVal: statusTranslatedValue!.toLowerCase()),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CustomText(
                "${"status".translate(context: context)}: ",
                maxLines: 1,
                color: context.colorScheme.blackColor,
                textAlign: TextAlign.start,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              CustomText(
                statusTranslatedValue.capitalize(),
                color: UiUtils.getBookingStatusColor(
                    context: context, statusVal: status!.toLowerCase()),
                maxLines: 1,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CustomText(
                "${"invoiceNumber".translate(context: context)}: ",
                maxLines: 1,
                color: context.colorScheme.blackColor,
                textAlign: TextAlign.start,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              CustomText(
                invoiceNumber ?? "0",
                color: context.colorScheme.accentColor,
                maxLines: 1,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingAddressDateAndOTPWidget(
    BuildContext context,
  ) {
    String scheduledTime =
        "${widget.bookingDetails.dateOfService!.formatDate()}, ${widget.bookingDetails.startingTime!.formatTime()}-${widget.bookingDetails.endingTime!.formatTime()}";
    if (widget.bookingDetails.multipleDaysBooking!.isNotEmpty) {
      String currentDate = "";
      for (int i = 0;
          i < widget.bookingDetails.multipleDaysBooking!.length;
          i++) {
        currentDate =
            "\n${widget.bookingDetails.multipleDaysBooking![i].multipleDayDateOfService.toString().formatDate()},${widget.bookingDetails.multipleDaysBooking![i].multipleDayStartingTime.toString().formatTime()}-${widget.bookingDetails.multipleDaysBooking![i].multipleEndingTime.toString().formatTime()}";
      }
      scheduledTime = scheduledTime + currentDate;
    }
    return CustomContainer(
      color: context.colorScheme.secondaryColor,
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSectionHeadingWidget(context,
                    title: "bookedAt".translate(context: context)),
              ),
              CustomInkWellContainer(
                showRippleEffect: false,
                onTap: () => _handleAddressTap(context),
                child: CustomText(
                  (widget.bookingDetails.addressId == "0"
                          ? "storeAddress"
                          : "yourAddress")
                      .translate(context: context),
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: context.colorScheme.accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          CustomInkWellContainer(
            showRippleEffect: false,
            onTap: () => _handleAddressTap(context),
            child: _buildImageAndTitleWidget(context,
                imageName: AppAssets.icLocation,
                title: widget.bookingDetails.addressId != "0"
                    ? filterAddressString(widget.bookingDetails.address ?? "")
                    : "${widget.bookingDetails.providerAddress}"),
          ),
          const SizedBox(
            height: 10,
          ),
          CustomInkWellContainer(
            showRippleEffect: false,
            onTap: () => _handleNumberTap(
                context,
                widget.bookingDetails.addressId != "0"
                    ? widget.bookingDetails.customerNo.toString()
                    : widget.bookingDetails.providerNumber.toString()),
            child: _buildImageAndTitleWidget(context,
                imageName: AppAssets.phone,
                title: widget.bookingDetails.addressId != "0"
                    ? filterAddressString(
                        widget.bookingDetails.customerNo ?? "")
                    : "${widget.bookingDetails.providerNumber}"),
          ),
          const SizedBox(
            height: 10,
          ),
          if (widget.bookingDetails.multipleDaysBooking!.isEmpty) ...[
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: _buildImageAndTitleWidget(context,
                      imageName: AppAssets.icCalendar,
                      title: widget.bookingDetails.dateOfService
                          .toString()
                          .formatDate()),
                ),
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                  flex: 6,
                  child: _buildImageAndTitleWidget(context,
                      imageName: AppAssets.icClock,
                      title: widget.bookingDetails.startingTime
                          .toString()
                          .formatTime(),
                      secondTitle: widget.bookingDetails.endingTime
                          .toString()
                          .formatTime()),
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
          ] else ...[
            ...List.generate(widget.bookingDetails.multipleDaysBooking!.length,
                (final int index) {
              final String scheduleDate = widget.bookingDetails
                  .multipleDaysBooking![index].multipleDayDateOfService
                  .toString()
                  .formatDate();
              final String scheduleStartTime = widget.bookingDetails
                  .multipleDaysBooking![index].multipleDayStartingTime
                  .toString()
                  .formatTime();
              final String scheduleEndTime = widget
                  .bookingDetails.multipleDaysBooking![index].multipleEndingTime
                  .toString()
                  .formatTime();
              return Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: _buildImageAndTitleWidget(context,
                        imageName: AppAssets.icCalendar, title: scheduleDate),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    flex: 6,
                    child: _buildImageAndTitleWidget(context,
                        imageName: AppAssets.icClock,
                        title: scheduleStartTime,
                        secondTitle: scheduleEndTime),
                  ),
                ],
              );
            }),
          ],
          if (context.read<SystemSettingCubit>().isOTPSystemEnabled() &&
              widget.bookingDetails.status?.toLowerCase() != "cancelled" &&
              widget.bookingDetails.status?.toLowerCase() != "completed") ...[
            const SizedBox(
              height: 10,
            ),
            _buildOTPWidget(context, otp: widget.bookingDetails.otp!),
          ]
        ],
      ),
    );
  }

  Widget _buildImageAndTitleWidget(BuildContext context,
      {required String imageName,
      required String title,
      String secondTitle = ''}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomSvgPicture(
          svgImage: imageName,
          height: 20,
          width: 20,
          color: context.colorScheme.accentColor,
        ),
        const CustomSizedBox(
          width: 5,
        ),
        secondTitle != ''
            ? Row(
                children: [
                  Row(
                    children: [
                      CustomText(
                        title,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: context.colorScheme.blackColor,
                        maxLines: 2,
                      ),
                      CustomText(
                        ' ${'to'.translate(context: context)} $secondTitle',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: context.colorScheme.blackColor,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ],
              )
            : Expanded(
                child: CustomText(
                  title,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: context.colorScheme.blackColor,
                  maxLines: 2,
                ),
              ),
      ],
    );
  }

  Widget _buildOTPWidget(BuildContext context, {required String otp}) {
    return Row(
      children: [
        CustomSvgPicture(
          svgImage: AppAssets.icOtp,
          height: 20,
          width: 20,
          color: context.colorScheme.accentColor,
        ),
        const CustomSizedBox(
          width: 10,
        ),
        CustomText(
          "otp".translate(context: context),
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: context.colorScheme.blackColor,
          maxLines: 1,
        ),
        const CustomSizedBox(
          width: 10,
        ),
        CustomInkWellContainer(
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: otp.toString()));
          },
          borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf5),
          child: CustomContainer(
            height: 30,
            width: 110,
            color: context.colorScheme.accentColor.withAlpha(15),
            borderRadius: UiUtils.borderRadiusOf5,
            child: Stack(children: [
              CustomSizedBox(
                height: 30,
                width: 110,
                child: DashedRect(
                  color: context.colorScheme.accentColor,
                  strokeWidth: 1,
                  gap: 5,
                ),
              ),
              Center(
                child: CustomText(
                  otp,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: context.colorScheme.accentColor,
                  maxLines: 1,
                  letterSpacing: 5,
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeadingWidget(BuildContext context,
      {required String title}) {
    return CustomText(
      title.translate(context: context),
      maxLines: 1,
      fontWeight: FontWeight.w400,
      fontSize: 14,
      color: context.colorScheme.lightGreyColor,
    );
  }

  Widget _buildRatingWidget(BuildContext context,
      {required BookedService service,
      required int index,
      required VoidCallback onTap,
      required bool isCollapsed}) {
    final int serviceRating = int.parse(
      (service.rating ?? 0).toString().isEmpty ? '0' : service.rating ?? '0',
    );
    return (widget.bookingDetails.status == "completed" && serviceRating == 0)
        ? _buildRatingButtonWidget(context,
            service: service,
            index: index,
            title: "rate",
            serviceRating: serviceRating)
        : (widget.bookingDetails.status == "completed" && serviceRating != 0)
            ? CustomInkWellContainer(
                showRippleEffect: false,
                onTap: onTap,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomSvgPicture(
                      svgImage: AppAssets.icStar,
                      height: 16,
                      width: 16,
                      color: context.colorScheme.accentColor,
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    CustomText(
                      serviceRating.toString(),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.colorScheme.accentColor,
                    ),
                    if ((service.comment ?? '').isNotEmpty ||
                        (service.reviewImages ?? []).isNotEmpty)
                      AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: isCollapsed
                              ? Icon(Icons.arrow_drop_down_sharp,
                                  color: context.colorScheme.accentColor,
                                  size: 12)
                              : Icon(Icons.arrow_drop_up_sharp,
                                  color: context.colorScheme.accentColor,
                                  size: 12)),
                    const SizedBox(width: 6),
                    SizedBox(
                      height: 12,
                      child: VerticalDivider(
                        color: context.colorScheme.lightGreyColor,
                        thickness: 0.5,
                        width: 0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _buildRatingButtonWidget(context,
                        service: service,
                        index: index,
                        title: "edit",
                        serviceRating: serviceRating),
                  ],
                ),
              )
            : const SizedBox.shrink();
  }

  Widget _buildRatingButtonWidget(BuildContext context,
      {required BookedService service,
      required int index,
      required String title,
      required int serviceRating}) {
    return CustomInkWellContainer(
      onTap: () {
        UiUtils.showBottomSheet(
          enableDrag: true,
          context: context,
          child: BlocProvider<SubmitReviewCubit>(
            create: (final BuildContext context) =>
                SubmitReviewCubit(bookingRepository: BookingRepository()),
            child: RatingBottomSheet(
              reviewComment: service.comment ?? "",
              ratingStar: serviceRating,
              serviceID: service.serviceId ?? '',
              serviceName: service.serviceTitle ?? "",
              customJobRequestId: service.customJobRequestId,
            ),
          ),
        ).then(
          (value) {
            if (value != null) {
              widget.bookingDetails.services?[index] = service.copyWith(
                comment: value["comment"],
                rating: value["rating"],
                reviewImages: (value["images"]?.isNotEmpty ?? false)
                    ? (value["images"] as List).cast<String>()
                    : [],
              );
              context.read<BookingCubit>().updateBookingDataLocally(
                  latestBookingData: widget.bookingDetails);
            }
          },
        );
      },
      child: CustomText(
        title.translate(context: context),
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: context.colorScheme.accentColor,
      ),
    );
  }

  Widget _buildReorderAndGetInvoiceButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          if (widget.bookingDetails.isReorderAllowed == "1") ...[
            Expanded(
              child: ReOrderButton(
                bookingDetails: widget.bookingDetails,
                isReorderFrom: "bookingDetails",
                bookingId: widget.bookingDetails.id ?? "0",
              ),
            ),
            const CustomSizedBox(
              width: 10,
            )
          ],
          Expanded(
            child: DownloadInvoiceButton(
              bookingId: widget.bookingDetails.id!,
              buttonScreenName: "bookingDetails",
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAddressTap(BuildContext context) async {
    //bookingDetails.addressId =="0" means booking booked as At store option
    if (widget.bookingDetails.addressId == "0") {
      try {
        await launchUrl(
          Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${widget.bookingDetails.providerLatitude},${widget.bookingDetails.providerLongitude}',
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
  }

  Future<void> _handleNumberTap(
      BuildContext context, String phoneNumber) async {
    //bookingDetails.addressId =="0" means booking booked as At store option
    final Uri url = Uri.parse("tel:$phoneNumber");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw "Could not launch $url";
    }
  }

  Widget _buildPaymentModeWidget(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            CustomContainer(
              height: 44,
              width: 44,
              borderRadius: UiUtils.borderRadiusOf5,
              child: CustomSvgPicture(
                svgImage: _getPaymentGatewayDetails(
                        paymentMethod:
                            widget.bookingDetails.paymentMethod ?? '')
                    .paymentImage,
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomText(
                    "paymentMode".translate(context: context),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: context.colorScheme.blackColor,
                  ),
                  const CustomSizedBox(
                    height: 4,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: CustomText(
                          _getPaymentGatewayDetails(
                                  paymentMethod:
                                      widget.bookingDetails.paymentMethod ?? '')
                              .paymentType
                              .translate(context: context),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: context.colorScheme.accentColor,
                        ),
                      ),
                      CustomText(
                        (widget.bookingDetails.paymentStatus!
                                        .toLowerCase()
                                        .isEmpty
                                    ? "pending"
                                    : widget.bookingDetails.paymentStatus
                                        ?.toLowerCase())
                                ?.translate(context: context) ??
                            "",
                        color: UiUtils.getPaymentStatusColor(
                            paymentStatus:
                                widget.bookingDetails.paymentStatus ?? ""),
                        fontWeight: FontWeight.w700,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (widget.bookingDetails.paymentStatusOfAdditionalCharge != '') ...[
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              CustomContainer(
                height: 44,
                width: 44,
                borderRadius: UiUtils.borderRadiusOf5,
                child: CustomSvgPicture(
                  svgImage: _getPaymentGatewayDetails(
                          paymentMethod: widget.bookingDetails
                                  .paymentMethodOfAdditionalCharge ??
                              '')
                      .paymentImage,
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomText(
                      "additionalChargesPaymentMode"
                          .translate(context: context),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: context.colorScheme.blackColor,
                    ),
                    const CustomSizedBox(
                      height: 4,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: CustomText(
                            _getPaymentGatewayDetails(
                                    paymentMethod: widget.bookingDetails
                                            .paymentMethodOfAdditionalCharge ??
                                        '')
                                .paymentType
                                .translate(context: context),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: context.colorScheme.accentColor,
                          ),
                        ),
                        CustomText(
                          (widget.bookingDetails
                                          .paymentStatusOfAdditionalCharge ==
                                      '0'
                                  ? "pending"
                                  : widget.bookingDetails
                                              .paymentStatusOfAdditionalCharge ==
                                          '1'
                                      ? "success"
                                      : widget.bookingDetails
                                                  .paymentStatusOfAdditionalCharge ==
                                              '2'
                                          ? "failed"
                                          : '')
                              .translate(context: context),
                          color: UiUtils.getPaymentStatusColor(
                              paymentStatus: widget.bookingDetails
                                      .paymentStatusOfAdditionalCharge ??
                                  ""),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  PaymentGatewayDetails _getPaymentGatewayDetails(
      {required String paymentMethod}) {
    switch (paymentMethod) {
      case "cod":
        return (paymentType: "cod", paymentImage: AppAssets.cod);
      case "stripe":
        return (paymentType: "stripe", paymentImage: AppAssets.stripe);
      case "razorpay":
        return (paymentType: "razorpay", paymentImage: AppAssets.razorpay);
      case "paystack":
        return (paymentType: "paystack", paymentImage: AppAssets.paystack);
      case "paypal":
        return (paymentType: "paypal", paymentImage: AppAssets.paypal);
      case "flutterwave":
        return (
          paymentType: "flutterwave",
          paymentImage: AppAssets.flutterwave
        );
      default:
        return (paymentType: "cod", paymentImage: AppAssets.cod);
    }
  }

  // !Additional Payment START
  Widget _buildAdditionalPaymentWidget({
    required final BuildContext context,
    required final Booking bookingDetails,
  }) {
    return CustomContainer(
      borderRadius: UiUtils.borderRadiusOf10,
      color: context.colorScheme.primaryColor,
      padding: const EdgeInsetsDirectional.all(16),
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    'payAdditionalCharges'.translate(context: context),
                    fontSize: 16,
                    color: context.colorScheme.blackColor,
                    fontWeight: FontWeight.bold,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: CustomContainer(
                      alignment: Alignment.center,
                      color: context.colorScheme.primaryColor,
                      borderRadius: UiUtils.borderRadiusOf50,
                      border: Border.all(
                        color: context.colorScheme.accentColor
                            .withValues(alpha: 0.8),
                      ),
                      padding: const EdgeInsets.all(2.5),
                      child: Icon(
                        Icons.close,
                        color: context.colorScheme.blackColor,
                        size: 20,
                      ),
                    ),
                  )
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: enabledPaymentMethods.length,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  final Map<String, dynamic> paymentMethod =
                      enabledPaymentMethods[index];
                  return CustomRadioOptionsWidget(
                    image: paymentMethod["image"]!,
                    title: paymentMethod["title"]!,
                  
                    value: paymentMethod["paymentType"]!,
                    groupValue: selectedPaymentMethod,
                    applyAccentColor: false,
                    onChanged: (final Object? selectedValue) {
                      setState(() {
                        selectedPaymentMethod = selectedValue.toString();
                        if (selectedValue.toString() == "cod") {
                          paymentButtonName.value =
                              "payWithCash".translate(context: context);
                        } else {
                          paymentButtonName.value =
                              "makePayment".translate(context: context);
                        }
                      });
                    },
                  );
                },
              ),
              const SizedBox(
                height: 10,
              ),
              if (paymentButtonName.value != "")
                BlocConsumer<AddTransactionCubit, AddTransactionState>(
                  listener: (context, state) {
                    if (state is AddTransactionSuccess) {
                      final totalAdditionalCharge =
                          widget.bookingDetails.totalAdditionalCharge;

                      _processPayment(
                        state: state,
                        totalAdditionalCharge: totalAdditionalCharge,
                      );
                    }
                  },
                  builder: (context, state) {
                    return ValueListenableBuilder(
                      valueListenable: paymentButtonName,
                      builder: (context, String value, _) {
                        return CustomRoundedButton(
                          buttonTitle: value,
                          showBorder: true,
                          widthPercentage: 0.8,
                          backgroundColor: context.colorScheme.accentColor,
                          onTap: () async {
                            _paymentManager?.dispose();
                            _paymentManager = PaymentGatewayManager(
                              placedOrderId: widget.bookingDetails.id ?? "",
                              context: context,
                              paymentGatewaySetting: context
                                  .read<SystemSettingCubit>()
                                  .getPaymentMethodSettings(),
                            );

                            if (selectedPaymentMethod == 'razorpay' ||
                                selectedPaymentMethod == 'stripe') {
                              _processDirectPayment(
                                widget.bookingDetails.totalAdditionalCharge,
                              );
                            } else if (selectedPaymentMethod == 'cod') {
                              _processDirectPayment(
                                widget.bookingDetails.totalAdditionalCharge,
                              );
                            } else {
                              await context
                                  .read<AddTransactionCubit>()
                                  .addTransaction(
                                    status: "pending",
                                    orderID: widget.bookingDetails.id ?? "",
                                    isAdditionalCharge: '1',
                                    paymentGatewayName: selectedPaymentMethod,
                                  );
                            }
                          },
                        );
                      },
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  void _processPayment({
    required AddTransactionSuccess state,
    required String? totalAdditionalCharge,
  }) {
    String? paymentUrl;

    switch (selectedPaymentMethod) {
      case 'paystack':
        paymentUrl = state.paystackUrl;
        break;
      case 'flutterwave':
        paymentUrl = state.flutterwaveUrl;
        break;
      case 'paypal':
        paymentUrl = state.paypalUrl;
        break;
    }

    if (paymentUrl != null && paymentUrl.isNotEmpty) {
      _paymentManager?.processPayment(
        paymentMethod: selectedPaymentMethod,
        amount: double.parse(
          totalAdditionalCharge == '' ? '0' : totalAdditionalCharge ?? '0',
        ),
        orderId: widget.bookingDetails.id ?? '',
        paymentUrl: paymentUrl,
      );
    }
  }

  void _processDirectPayment(String? totalAdditionalCharge) {
    _paymentManager?.processPayment(
      paymentMethod: selectedPaymentMethod,
      amount: double.parse(
          totalAdditionalCharge == '' ? '0' : totalAdditionalCharge ?? '0'),
      orderId: widget.bookingDetails.id ?? '',
    );
  }

  Widget _buildCustomJobRequestContainer() {
    final BookedService service = widget.bookingDetails.services![0];
    //
    bool collapsed = true;
    return CustomContainer(
      width: context.screenWidth,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      color: context.colorScheme.secondaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeadingWidget(context, title: "requestedService"),
          const CustomSizedBox(
            height: 10,
          ),
          StatefulBuilder(builder: (context, innerSetState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomContainer(
                      borderRadius: UiUtils.borderRadiusOf5,
                      width: 62,
                      height: 68,
                      border: Border.all(
                          color: context.colorScheme.lightGreyColor,
                          width: 0.5),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(UiUtils.borderRadiusOf5),
                        child: CustomCachedNetworkImage(
                          networkImageUrl: service.image ?? '',
                          height: 68,
                          width: 62,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            '${service.serviceTitle} ',
                            fontWeight: FontWeight.w500,
                            color: context.colorScheme.blackColor,
                            fontSize: 16,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Row(
                                children: [
                                  CustomText(
                                    service.priceWithTax!
                                        .toString()
                                        .priceFormat(),
                                    color: context.colorScheme.accentColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  CustomText(
                                    "x${service.quantity}"
                                        .translate(context: context),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: context.colorScheme.blackColor,
                                  ),
                                ],
                              ),
                              const Spacer(),
                              _buildRatingWidget(context,
                                  service: service, index: 0, onTap: () {
                                if ((service.comment ?? '').isEmpty &&
                                    (service.reviewImages ?? []).isEmpty) {
                                  return;
                                }
                                innerSetState(() {
                                  collapsed = !collapsed;
                                });
                              }, isCollapsed: collapsed),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (service.rating != "0") ...[
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    child: CustomContainer(
                      constraints: collapsed
                          ? const BoxConstraints(maxHeight: 0.0)
                          : const BoxConstraints(
                              maxHeight: double.infinity,
                              maxWidth: double.maxFinite,
                            ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          CustomText(
                            service.comment ?? "",
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: context.colorScheme.lightGreyColor,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          if (service.reviewImages?.isNotEmpty ?? false)
                            SizedBox(
                              height: 44,
                              child: ListView.separated(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: service.reviewImages?.length ?? 0,
                                  separatorBuilder: (final BuildContext context,
                                          final int index) =>
                                      const SizedBox(
                                        width: 12,
                                      ),
                                  itemBuilder: (context, index) =>
                                      CustomInkWellContainer(
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            imagePreview,
                                            arguments: {
                                              "startFrom": index,
                                              "isReviewType": true,
                                              "dataURL": service.reviewImages,
                                              "reviewDetails": Reviews(
                                                id: service.id ?? "",
                                                rating: service.rating ?? "",
                                                profileImage: HiveRepository
                                                        .getUserProfilePictureURL ??
                                                    "",
                                                userName: HiveRepository
                                                        .getUsername ??
                                                    "",
                                                serviceId:
                                                    service.serviceId ?? "",
                                                comment: service.comment ?? "",
                                                images:
                                                    service.reviewImages ?? [],
                                                ratedOn: "",
                                              ),
                                            },
                                          );
                                        },
                                        child: CustomContainer(
                                            height: 44,
                                            width: 44,
                                            borderRadius:
                                                UiUtils.borderRadiusOf5,
                                            border: Border.all(
                                                color: context
                                                    .colorScheme.lightGreyColor,
                                                width: 0.5),
                                            child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        UiUtils
                                                            .borderRadiusOf5),
                                                child: CustomCachedNetworkImage(
                                                  networkImageUrl:
                                                      service.reviewImages?[
                                                              index] ??
                                                          "",
                                                  height: 44,
                                                  width: 44,
                                                  fit: BoxFit.fill,
                                                ))),
                                      )),
                            )
                        ],
                      ),
                    ),
                  ),
                ],
                if (widget.bookingDetails.services?[0].customJobServiceNote !=
                        null &&
                    widget.bookingDetails.services?[0].customJobServiceNote !=
                        "") ...[
                  const CustomSizedBox(
                    height: 10,
                  ),
                  CustomReadMoreTextContainer(
                      text: widget.bookingDetails.services?[0]
                              .customJobServiceNote ??
                          ""),
                ],
              ],
            );
          })
        ],
      ),
    );
  }

  Widget _buildCustomJobProviderNoteContainer() {
    return CustomContainer(
      width: context.screenWidth,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      color: context.colorScheme.secondaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeadingWidget(context,
              title: "providerNote".translate(context: context)),
          const CustomSizedBox(
            height: 10,
          ),
          CustomReadMoreTextContainer(
              text: widget.bookingDetails.services?[0]
                      .customJobServiceProviderNote ??
                  ""),
        ],
      ),
    );
  }

  Widget _buildAdditionalCharges() {
    return CustomContainer(
      width: context.screenWidth,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      color: context.colorScheme.secondaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeadingWidget(context, title: "additionalCharges"),
          const SizedBox(
            height: 10,
          ),
          for (var i = 0;
              i < widget.bookingDetails.additionalCharges!.length;
              i++) ...[
            _getPriceSectionTile(
              context: context,
              fontSize: 14,
              heading: widget.bookingDetails.additionalCharges![i].name!,
              subHeading: widget.bookingDetails.additionalCharges![i].charge!
                  .priceFormat(),
              textColor: context.colorScheme.blackColor,
            ),
            const SizedBox(
              height: 4,
            ),
          ],
        ],
      ),
    );
  }

// !Additional Payment END
}
