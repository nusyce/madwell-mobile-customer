import 'package:e_demand/app/generalImports.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // ignore_for_file: prefer_typing_uninitialized_variables
import 'package:intl/intl.dart' as intl;

class ScheduleBookingScreen extends StatefulWidget {
  const ScheduleBookingScreen({
    required this.companyName,
    required this.providerAdvanceBookingDays,
    required this.providerName,
    required this.providerId,
    final Key? key,
    required this.isFrom,
    this.orderID,
    this.customJobRequestId,
    this.bidder,
    this.cartFromProvider,
  }) : super(key: key);

  //
  final String providerName;
  final String isFrom;
  final String providerId;
  final String companyName;
  final String providerAdvanceBookingDays;
  final String? orderID;
  final String? customJobRequestId;
  final Bidder? bidder;
  final bool? cartFromProvider;

  @override
  State<ScheduleBookingScreen> createState() => _ScheduleBookingScreenState();

  static Route route(final RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (final BuildContext context) => Builder(
        builder: (final context) => MultiBlocProvider(
          providers: [
            BlocProvider<PlaceOrderCubit>(
              create: (final BuildContext context) =>
                  PlaceOrderCubit(cartRepository: CartRepository()),
            ),
            BlocProvider(
              create: (context) =>
                  AddTransactionCubit(bookingRepository: BookingRepository()),
            ),
            BlocProvider<ValidateCustomTimeCubit>(
              create: (context) =>
                  ValidateCustomTimeCubit(cartRepository: CartRepository()),
            ),
            BlocProvider<CheckProviderAvailabilityCubit>(
              create: (final BuildContext context) =>
                  CheckProviderAvailabilityCubit(
                      providerRepository: ProviderRepository()),
            )
          ],
          child: ScheduleBookingScreen(
              orderID: arguments["orderID"],
              customJobRequestId: arguments["customJobRequestId"],
              companyName: arguments["companyName"],
              isFrom: arguments["isFrom"],
              providerName: arguments['providerName'],
              providerId: arguments['providerId'],
              providerAdvanceBookingDays:
                  arguments['providerAdvanceBookingDays'],
              bidder: arguments['bidder'],
              cartFromProvider: arguments['cartFromProvider'] ?? false),
        ),
      ),
    );
  }
}

class _ScheduleBookingScreenState extends State<ScheduleBookingScreen> {
  //
  PaymentGatewaysSettings? paymentGatewaySetting;
  String? placedOrderId;
  StreamSubscription? _cartSubscription;
  bool isProviderInstructionFieldEditClicable = false;
  int? selectedAddressIndex;
  GetAddressModel? selectedAddress;
  dynamic selectedDate, selectedTime;
  String? message;
  Promocode? appliedPromocode;
  double promoCodeDiscount = 0;
  late List<Map<String, dynamic>> enabledPaymentMethods = context
      .read<SystemSettingCubit>()
      .getEnabledPaymentMethods(
          isPayLaterAllowed: widget.isFrom != "customJobRequest"
              ? context
                  .read<CartCubit>()
                  .isPayLaterAllowed(isFrom: widget.isFrom)
              : context
                  .read<MyRequestCartCubit>()
                  .isPayLaterAllowed(isFrom: widget.isFrom));

  ValueNotifier<String> paymentButtonName = ValueNotifier("");

  String? selectedPaymentMethod;
  final TextEditingController _instructionController = TextEditingController();

  late final List<Map<String, String>> deliverableOptions = [
    {
      "title": 'atHome',
      "description": 'atHomeDescription',
      "image": AppAssets.building
    },
    {
      "title": 'atStore',
      "description": 'atStoreDescription',
      "image": AppAssets.home
    },
  ];
  late String selectedDeliverableOption = deliverableOptions[0]['title']!;

  //----------------------------------- Razorpay Payment Gateway Start ----------------------------
  final Razorpay _razorpay = Razorpay();

  void initializeRazorpay() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleRazorPayPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleRazorPayPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleRazorPayExternalWallet);
  }

  void _handleRazorPayPaymentSuccess(final PaymentSuccessResponse response) {
    _navigateToOrderConfirmation(isSuccess: true);
  }

  void _handleRazorPayPaymentError(final PaymentFailureResponse response) {
    _navigateToOrderConfirmation(isSuccess: false);
  }

  void _handleRazorPayExternalWallet(final ExternalWalletResponse response) {}

  Future<void> openRazorPayGateway({
    required final double orderAmount,
    required final String placedOrderId,
    required final String razorpayOrderId,
  }) async {
    final options = <String, Object?>{
      'key': paymentGatewaySetting!.razorpayKey,
      //this should be come from server
      'amount': (orderAmount * 100).toInt(),
      'name': appName,
      'description': '',
      'currency': paymentGatewaySetting!.razorpayCurrency,
      'notes': {'order_id': placedOrderId},
      'order_id': razorpayOrderId,
    };

    _razorpay.open(options);
  }

  //----------------------------------- Razorpay Payment Gateway End ----------------------------

  //----------------------------------- Stripe Payment Gateway Start ----------------------------

  Future<void> openStripePaymentGateway({
    required final double orderAmount,
    required final String placedOrderId,
  }) async {
    try {
      StripeService.secret = paymentGatewaySetting!.stripeSecretKey;
      StripeService.init(
        paymentGatewaySetting!.stripePublishableKey,
        paymentGatewaySetting!.stripeMode,
      );

      final response = await StripeService.payWithPaymentSheet(
        amount: (orderAmount * 100).ceil(),
        currency: paymentGatewaySetting!.stripeCurrency,
        isTestEnvironment: paymentGatewaySetting!.stripeMode == "test",
        awaitedOrderId: placedOrderId,
        from: 'order',
      );

      if (response.status == 'succeeded') {
        _navigateToOrderConfirmation(isSuccess: true);
      } else {
        _navigateToOrderConfirmation(isSuccess: false);
      }
    } catch (e) {
      UiUtils.showMessage(
        context,
        e.toString(),
        ToastificationType.error,
      );
    }
  }

  //----------------------------------- Stripe Payment Gateway End ----------------------------

  void _navigateToOrderConfirmation({required final bool isSuccess}) {
    if (!isSuccess) {
      paymentButtonName.value = "rePayment";
      UiUtils.showMessage(
          context,
          "bookingFailureMessage".translate(context: context),
          ToastificationType.error);
      //
      context
          .read<AddTransactionCubit>()
          .addTransaction(status: "cancelled", orderID: placedOrderId ?? "0");
      //
      context.read<BookingCubit>().fetchBookingDetails(status: "");
      return;
    }

    Navigator.pushNamed(
      context,
      orderConfirmation,
      arguments: {
        'isSuccess': isSuccess,
        "orderId": placedOrderId,
        "isReBooking": widget.isFrom == "reBooking" ? '1' : '0'
      },
    );
  }

  void getPaymentGatewaySetting() {
    paymentGatewaySetting =
        context.read<SystemSettingCubit>().getPaymentMethodSettings();

    if (widget.isFrom != "customJobRequest" &&
        context
            .read<CartCubit>()
            .isOnlinePaymentAllowed(isFrom: widget.isFrom)) {
      paymentButtonName = ValueNotifier("makePayment");
    } else if (widget.isFrom == "customJobRequest" &&
        context
            .read<MyRequestCartCubit>()
            .isOnlinePaymentAllowed(isFrom: widget.isFrom)) {
      paymentButtonName = ValueNotifier("makePayment");
    } else {
      paymentButtonName = ValueNotifier("bookService");
    }
  }

  void getMyRequests() {
    if (widget.isFrom == "customJobRequest") {
      context.read<MyRequestCartCubit>().emitSuccess(
            widget.bidder ?? Bidder(),
          );
    }
  }

  @override
  void initState() {
    super.initState();
    getMyRequests();
    context.read<GetAddressCubit>().fetchAddress();
    getPaymentGatewaySetting();
    initializeRazorpay();
    if (widget.isFrom == "customJobRequest") {
      getMyRequests();
      // Store the subscription

      selectedDeliverableOption = context
              .read<MyRequestCartCubit>()
              .checkAtDoorstepProviderAvailable(isFrom: widget.isFrom)
          ? deliverableOptions[0]['title']!
          : deliverableOptions[1]['title']!;
    } else {
      selectedDeliverableOption = context
              .read<CartCubit>()
              .checkAtDoorstepProviderAvailable(isFrom: widget.isFrom)
          ? deliverableOptions[0]['title']!
          : deliverableOptions[1]['title']!;
    }

    if (widget.isFrom != "customJobRequest" &&
        context
            .read<CartCubit>()
            .isOnlinePaymentAllowed(isFrom: widget.isFrom)) {
      selectedPaymentMethod = enabledPaymentMethods[0]['paymentType'];
    } else if (widget.isFrom == "customJobRequest" &&
        context
            .read<MyRequestCartCubit>()
            .isOnlinePaymentAllowed(isFrom: widget.isFrom)) {
      selectedPaymentMethod = enabledPaymentMethods[0]['paymentType'];
    } else {
      selectedPaymentMethod = "cod";
    }
  }

  Widget getServiceDeliverableOptions() {
    return Row(
      children: List.generate(
        deliverableOptions.length,
        (index) => Expanded(
          child: Padding(
            padding: deliverableOptions.length - 1 == index
                ? EdgeInsets.zero
                : const EdgeInsets.only(right: 8.0),
            child: CustomContainerOptionsWidget(
                onChanged: (final Object? selectedValue) {
                  selectedDeliverableOption = selectedValue.toString();
                  setState(() {});
                },
                groupValue: selectedDeliverableOption,
                value: deliverableOptions[index]["title"]!,
                image: deliverableOptions[index]["image"]!,
                title: deliverableOptions[index]["title"]!,
                subTitle: deliverableOptions[index]["description"]!),
          ),
        ),
      ),
    );
  }

  Widget getHeadingTimeSelector() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: CustomText(
          'scheduleTime'.translate(context: context),
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: context.colorScheme.blackColor,
        ),
      );

  Widget verticalSpacing() {
    return const CustomSizedBox(
      height: 10,
    );
  }

  Widget _buildViewProviderInstructionField() => CustomContainer(
      height: 52,
      color: context.colorScheme.secondaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomSvgPicture(
            svgImage: AppAssets.edit,
            color: context.colorScheme.accentColor,
            height: 24,
            width: 24,
          ),
          CustomText(
            'writeInstruction'.translate(context: context),
            color: context.colorScheme.blackColor,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
          )
        ],
      ));

  Widget buildProviderInstructionField() => TextFormField(
        controller: _instructionController,
        style: const TextStyle(fontSize: 12),
        // minLines: 4,
        // maxLines: 5,
        textInputAction: TextInputAction.newline,
        decoration: InputDecoration(
          filled: true,
          fillColor: context.colorScheme.secondaryColor,
          hintText: 'writeDescriptionForProvider'.translate(context: context),
          hintStyle: const TextStyle(fontSize: 12.6),
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: context.colorScheme.secondaryColor, width: 2),
            // borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: context.colorScheme.secondaryColor),
            // borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
          ),
        ),
      );

  Widget buildAddressSelector() {
    return BlocListener<AddAddressCubit, AddAddressState>(
      listener:
          (final BuildContext context, final AddAddressState addAddressState) {
        if (addAddressState is AddAddressFail) {
          UiUtils.showMessage(
            context,
            addAddressState.error.toString().translate(context: context),
            ToastificationType.error,
          );
        }
      },
      child: BlocConsumer<GetAddressCubit, GetAddressState>(
        listener: (final BuildContext context,
            final GetAddressState getAddressState) {
          if (getAddressState is GetAddressSuccess) {
            for (var i = 0; i < getAddressState.data.length; i++) {
              //we will make default address as selected address
              //so we will take index of selected address and address data
              if (getAddressState.data[i].isDefault == "1") {
                selectedAddressIndex = i;
                selectedAddress = getAddressState.data[i];
                setState(() {});
              }
            }
            context.read<AddressesCubit>().load(getAddressState.data);
          }
        },
        builder: (final BuildContext context,
            final GetAddressState getAddressState) {
          if (getAddressState is GetAddressSuccess) {
            return BlocConsumer<AddressesCubit, AddressesState>(
              listener: (context, state) {
                if (state is Addresses) {
                  for (var i = 0; i < state.addresses.length; i++) {
                    if (state.addresses[i].isDefault == "1") {
                      selectedAddressIndex = i;
                      selectedAddress = state.addresses[i];
                      setState(() {});
                    }
                  }
                }
              },
              builder: (final context, AddressesState addressesState) {
                if (addressesState is Addresses) {
                  if (getAddressState.data.isEmpty)
                    return GeneralCardContainer(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          googleMapRoute,
                          arguments: {
                            "defaultLatitude": HiveRepository.getLatitude,
                            "defaultLongitude": HiveRepository.getLongitude,
                            'showAddressForm': true
                          },
                        ).then((final Object? value) {
                          context.read<GetAddressCubit>().fetchAddress();
                          setState(() {});
                        });
                      },
                      imageName: AppAssets.address,
                      title: "addNewAddress",
                      description: "easilyAddNewAddress",
                    );
                  else {
                    if (selectedAddress == null) {
                      /* final GetAddressModel defaultAddress */ selectedAddress =
                          addressesState.addresses.firstWhere(
                        (e) => e.isDefault == '1',
                        orElse: () => addressesState.addresses.first,
                      );
                    }

                    return BlocListener<AddAddressCubit, AddAddressState>(
                      listener: (context, state) {
                      
                      },
                      child: GestureDetector(
                        onTap: () {
                          UiUtils.showBottomSheet(
                            enableDrag: true,
                            isScrollControlled: false,
                            useSafeArea: true,
                            child: CustomContainer(
                              child: AddressBotoomSheet(
                                addresses: addressesState.addresses,
                                defaultAddress: selectedAddress!,
                              ),
                            ),
                            context: context,
                          ).then((final value) {
                            
                            selectedAddress = value['selectedAddress'];

                            setState(() {});
                          });
                        },
                        child: CustomContainer(
                          width: context.screenWidth,
                          padding: const EdgeInsetsDirectional.all(15),
                          color: context.colorScheme.secondaryColor,
                          child: Row(
                            children: [
                              CustomContainer(
                                child: CustomContainer(
                                  padding: const EdgeInsets.all(12),
                                  color: context.colorScheme.accentColor
                                      .withAlpha(20),
                                  borderRadius: UiUtils.borderRadiusOf6,
                                  child: CustomSvgPicture(
                                    svgImage: selectedAddress!.type == 'home'
                                        ? AppAssets.homeAdd
                                        : selectedAddress!.type == 'Other'
                                            ? AppAssets.locationMark
                                            : AppAssets.officeAdd,
                                    color: context.colorScheme.accentColor,
                                  ),
                                ),
                              ),
                              const CustomSizedBox(
                                width: 10,
                              ),
                              Expanded(
                                flex: 6,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      selectedAddress!.type
                                          .toString()
                                          .toLowerCase()
                                          .translate(context: context),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: context.colorScheme.blackColor,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: CustomText(
                                            '${selectedAddress!.address.toString()}, ${selectedAddress!.area}, ${selectedAddress!.cityName}, ${selectedAddress!.state}, ${selectedAddress!.country}',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            maxLines: 1,
                                            color: context
                                                .colorScheme.lightGreyColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: context.colorScheme.blackColor,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                }

                return const CustomSizedBox();
              },
            );
          }
          if (getAddressState is GetAddressInProgress) {
            return const CustomShimmerLoadingContainer(
              height: 80,
              width: double.infinity,
            );
          }
          return const CustomSizedBox();
        },
      ),
    );
  }

  Widget buildServicesList() => BlocBuilder<CartCubit, CartState>(
        builder: (final BuildContext context, final CartState state) {
          if (state is CartFetchSuccess) {
            if (state.cartData.cartDetails == null &&
                state.reOrderCartData?.cartDetails == null) {
              return const CustomSizedBox();
            }
            return CustomContainer(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              color: context.colorScheme.secondaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        'services'.translate(context: context),
                        color: context.colorScheme.lightGreyColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      TextButton(
                        onPressed: () {
                          if (widget.cartFromProvider! == true) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pop(context);
                            Navigator.pushNamed(
                              context,
                              providerRoute,
                              arguments: {
                                "providerId": state.cartData.providerId,
                              },
                            );
                          }
                        },
                        child: CustomText(
                          'edit'.translate(context: context),
                          color: context.colorScheme.accentColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.isFrom == "cart"
                        ? state.cartData.cartDetails?.length
                        : widget.isFrom == "customJobRequest"
                            ? 0
                            : state.reOrderCartData?.cartDetails?.length,
                    itemBuilder: (final context, index) {
                      final cartDetails = widget.isFrom == "cart"
                          ? state.cartData.cartDetails![index]
                          : state.reOrderCartData?.cartDetails![index];
                      return Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomImageContainer(
                                borderRadius: UiUtils.borderRadiusOf6,
                                imageURL: cartDetails
                                        ?.serviceDetails!.imageOfTheService! ??
                                    '',
                                height: 52,
                                width: 62,
                                boxFit: BoxFit.fill,
                                boxShadow: [],
                              ),
                              const CustomSizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText(
                                      cartDetails!.serviceDetails!.title!,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      maxLines: 2,
                                      color: context.colorScheme.blackColor,
                                    ),
                                    const CustomSizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        CustomText(
                                          (cartDetails.serviceDetails!
                                                          .discountedPrice !=
                                                      '0'
                                                  ? cartDetails.serviceDetails!
                                                      .priceWithTax
                                                      .toString()
                                                  : cartDetails.serviceDetails!
                                                      .priceWithTax
                                                      .toString())
                                              .priceFormat(),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color:
                                              context.colorScheme.accentColor,
                                        ),
                                        const CustomSizedBox(
                                          width: 10,
                                        ),
                                        CustomText(
                                          '${cartDetails.qty}x',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: context.colorScheme.blackColor,
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          ));
                    },
                  ),
                ],
              ),
            );
          }
          return const CustomSizedBox();
        },
      );

  Widget buildDateSelector() => GeneralCardContainer(
        onTap: () {
          setState(() {});
          UiUtils.removeFocus();
          UiUtils.showBottomSheet(
            enableDrag: true,
            context: context,
            child: MultiBlocProvider(
              providers: [
                BlocProvider<ValidateCustomTimeCubit>(
                  create: (context) =>
                      ValidateCustomTimeCubit(cartRepository: CartRepository()),
                ),
                BlocProvider(
                  create: (final BuildContext context) =>
                      TimeSlotCubit(CartRepository()),
                ),
              ],
              child: CalenderBottomSheet(
                orderId: widget.orderID,
                customJobRequestId: widget.customJobRequestId,
                advanceBookingDays: widget.providerAdvanceBookingDays,
                providerId: widget.providerId,
                selectedDate:
                    selectedDate == null ? null : DateTime.parse(selectedDate),
                selectedTime: selectedTime,
              ),
            ),
          ).then((final value) {
            if (value != null) {
              if (value["isSaved"]) {
                selectedDate = intl.DateFormat('yyyy-MM-dd')
                    .format(DateTime.parse("${value['selectedDate']}"));
                selectedTime = value["selectedTime"];
                message = value["message"];
                setState(() {});
              }
            }
          });
        },
        imageName: AppAssets.icCalendar,
        title: selectedDate != null && selectedTime != null
            ? '${selectedDate.toString().formatDate()}, ${selectedTime.toString().formatTime()}'
            : "selectDateAndTime".translate(context: context),
        description: selectedDate != null && selectedTime != null
            ? message != null && message != ''
                ? 'orderWillBeScheduledForTheMultipleDays'
                    .translate(context: context)
                : ""
            : "scheduleOnYourPreferDateAndTime",
        showEditIcon: selectedDate != null && selectedTime != null,
      );

  BoxDecoration selectedItemBorderStyle() => BoxDecoration(
        boxShadow: [
          BoxShadow(color: context.colorScheme.lightGreyColor, blurRadius: 3)
        ],
        border: Border.all(color: context.colorScheme.blackColor),
        color: context.colorScheme.secondaryColor,
        borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
      );

  BoxDecoration normalBoxDecoration() => BoxDecoration(
        color: context.colorScheme.secondaryColor,
        borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
      );

  void placeOrder() {
    //
    context.read<PlaceOrderCubit>().placeOrder(
          status: "awaiting",
          orderId: widget.orderID ?? "",
          customJobRequestId: widget.customJobRequestId ?? "",
          bidderId: widget
              .providerId, // this is partner id which we will get from bidder
          selectedAddressID: selectedAddress?.id,
          promoCodeId: appliedPromocode?.id ?? '',
          paymentMethod: selectedPaymentMethod!,
          orderNote: _instructionController.text.trim().toString(),
          dateOfService: selectedDate!,
          startingTime: selectedTime!,
          isAtStoreOptionSelected:
              selectedDeliverableOption == "atStore" ? "1" : "0",
        );
  }

  Widget continueButtonContainer(final BuildContext context) =>
      BlocConsumer<PlaceOrderCubit, PlaceOrderState>(
        listener:
            (final BuildContext context, PlaceOrderState placeOrderState) {
          if (placeOrderState is PlaceOrderSuccess) {
            if (!placeOrderState.isError) {
              //

              placedOrderId = placeOrderState.orderId;
              //
              //we will get cart total amount form cart cubit or my request cart cubit
              //and if amount is from cart cubit and promocode is applied then we will subtract that amount for online pay
              final double cartTotalAmount = widget.isFrom == 'customJobRequest'
                  ? double.parse(context
                      .read<MyRequestCartCubit>()
                      .getCartTotalAmount(
                          isFrom: widget.isFrom,
                          isAtStoreBooked:
                              selectedDeliverableOption == "atStore"))
                  : double.parse(context.read<CartCubit>().getCartTotalAmount(
                          isFrom: widget.isFrom,
                          isAtStoreBooked:
                              selectedDeliverableOption == "atStore")) -
                      promoCodeDiscount;
              //
              if (selectedPaymentMethod == "cod") {
                _navigateToOrderConfirmation(isSuccess: true);
              } else {
                if (selectedPaymentMethod == 'stripe') {
                  //
                  openStripePaymentGateway(
                    orderAmount: cartTotalAmount,
                    placedOrderId: placeOrderState.orderId,
                  );
                  //
                } else if (selectedPaymentMethod == 'razorpay') {
                  //
                  openRazorPayGateway(
                    orderAmount: cartTotalAmount,
                    placedOrderId: placeOrderState.orderId,
                    razorpayOrderId: placeOrderState.razorpayOrderId,
                  );
                  //
                } else if (selectedPaymentMethod == 'paystack') {
                  //
                  _openWebviewPaymentGateway(
                      webviewLink: placeOrderState.paystackLink);
                } else if (selectedPaymentMethod == 'flutterwave') {
                  //
                  _openWebviewPaymentGateway(
                      webviewLink: placeOrderState.flutterwaveLink);
                } else if (selectedPaymentMethod == 'paypal') {
                  //
                  _openWebviewPaymentGateway(
                      webviewLink: placeOrderState.paypalLink);
                } else {
                  UiUtils.showMessage(
                    context,
                    "onlinePaymentNotAvailableNow".translate(context: context),
                    ToastificationType.warning,
                  );
                }
              }
            } else {
              UiUtils.showMessage(
                  context,
                  placeOrderState.message.translate(context: context),
                  ToastificationType.error);
            }
          }
          if (placeOrderState is PlaceOrderFailure) {
            UiUtils.showMessage(
                context,
                placeOrderState.errorMessage.translate(context: context),
                ToastificationType.error);
          }
        },
        builder: (context, state) {
          Widget? child;
          if (state is PlaceOrderInProgress) {
            child = const Center(
              child:
                  CustomCircularProgressIndicator(color: AppColors.whiteColors),
            );
          } else if (state is PlaceOrderFailure || state is PlaceOrderSuccess) {
            child = null;
          }
          return BlocConsumer<CheckProviderAvailabilityCubit,
              CheckProviderAvailabilityState>(
            listener: (final context,
                CheckProviderAvailabilityState checkProviderAvailabilityState) {
              if (checkProviderAvailabilityState
                  is CheckProviderAvailabilityFetchSuccess) {
                if (checkProviderAvailabilityState.error) {
                  //
                  UiUtils.showMessage(
                    context,
                    'serviceNotAvailableAtSelectedAddress'
                        .translate(context: context),
                    ToastificationType.warning,
                  );
                } else {
                  context.read<ValidateCustomTimeCubit>().validateCustomTime(
                      providerId: widget.providerId,
                      selectedDate: selectedDate,
                      selectedTime: selectedTime,
                      orderId: widget.orderID,
                      customJobRequestId: widget.customJobRequestId);
                }
              } else if (checkProviderAvailabilityState
                  is CheckProviderAvailabilityFetchFailure) {
                UiUtils.showMessage(
                  context,
                  checkProviderAvailabilityState.errorMessage
                      .translate(context: context),
                  ToastificationType.error,
                );
              }
            },
            builder: (final context,
                CheckProviderAvailabilityState checkProviderAvailabilityState) {
              if (checkProviderAvailabilityState
                  is CheckProviderAvailabilityFetchInProgress) {
                child = const CustomCircularProgressIndicator(
                  color: AppColors.whiteColors,
                );
              } else if (checkProviderAvailabilityState
                      is CheckProviderAvailabilityFetchFailure ||
                  checkProviderAvailabilityState
                      is CheckProviderAvailabilityFetchSuccess) {
                child = null;
              }
              return BlocConsumer<ValidateCustomTimeCubit,
                  ValidateCustomTimeState>(
                listener: (
                  final BuildContext context,
                  final ValidateCustomTimeState validateCustomTimeState,
                ) {
                  if (validateCustomTimeState is ValidateCustomTimeSuccess) {
                    if (!validateCustomTimeState.error) {
                      placeOrder();
                    } else {
                      UiUtils.showMessage(
                          context,
                          validateCustomTimeState.message
                              .translate(context: context),
                          ToastificationType.error);
                    }
                  } else if (validateCustomTimeState
                      is ValidateCustomTimeFailure) {
                    UiUtils.showMessage(
                      context,
                      validateCustomTimeState.errorMessage
                          .translate(context: context),
                      ToastificationType.error,
                    );
                  }
                },
                builder: (
                  final BuildContext context,
                  final ValidateCustomTimeState validateCustomTimeState,
                ) {
                  if (validateCustomTimeState is ValidateCustomTimeInProgress) {
                    child = const CustomCircularProgressIndicator(
                        color: AppColors.whiteColors);
                  } else if (validateCustomTimeState
                          is ValidateCustomTimeFailure ||
                      validateCustomTimeState is ValidateCustomTimeSuccess) {
                    child = null;
                  }
                  return CustomContainer(
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 2.0,
                          offset: const Offset(1.0, 0),
                          color: context.colorScheme.lightGreyColor),
                    ],
                    color: context.colorScheme.secondaryColor,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    child: ValueListenableBuilder(
                      valueListenable: paymentButtonName,
                      builder: (context, value, _) {
                        return CustomRoundedButton(
                          onTap: () {
                            if (validateCustomTimeState
                                    is ValidateCustomTimeInProgress ||
                                checkProviderAvailabilityState
                                    is CheckProviderAvailabilityFetchInProgress) {
                              return;
                            }
                            //
                            if (selectedTime == null || selectedDate == null) {
                              UiUtils.showMessage(
                                context,
                                'pleaseSelectDateAndTime'
                                    .translate(context: context),
                                ToastificationType.warning,
                              );
                              return;
                            }
                            //
                            if (context
                                    .read<MyRequestCartCubit>()
                                    .checkAtDoorstepProviderAvailable(
                                        isFrom: widget.isFrom) &&
                                selectedDeliverableOption ==
                                    deliverableOptions[0]["title"]) {
                              if (selectedAddress == null) {
                                UiUtils.showMessage(
                                  context,
                                  'pleaseSelectAddress'
                                      .translate(context: context),
                                  ToastificationType.warning,
                                );
                              } else {
                                context
                                    .read<CheckProviderAvailabilityCubit>()
                                    .checkProviderAvailability(
                                      customJobRequestId:
                                          widget.bidder?.customJobRequestId,
                                      bidderId: widget.bidder?.partnerId,
                                      isAuthTokenRequired: true,
                                      checkingAtCheckOut: '1',
                                      latitude:
                                          selectedAddress!.lattitude.toString(),
                                      longitude:
                                          selectedAddress!.longitude.toString(),
                                    );
                              }
                            } else if (widget.isFrom != "customJobRequest" &&
                                context
                                    .read<CartCubit>()
                                    .checkAtDoorstepProviderAvailable(
                                        isFrom: widget.isFrom) &&
                                selectedDeliverableOption ==
                                    deliverableOptions[0]["title"]) {
                              if (selectedAddress == null) {
                                UiUtils.showMessage(
                                  context,
                                  'pleaseSelectAddress'
                                      .translate(context: context),
                                  ToastificationType.warning,
                                );
                              } else {
                                context
                                    .read<CheckProviderAvailabilityCubit>()
                                    .checkProviderAvailability(
                                      orderId: widget.orderID,
                                      isAuthTokenRequired: true,
                                      checkingAtCheckOut: '1',
                                      latitude:
                                          selectedAddress!.lattitude.toString(),
                                      longitude:
                                          selectedAddress!.longitude.toString(),
                                    );
                              }
                            } else {
                              placeOrder();
                            }
                          },
                          widthPercentage: 1,
                          backgroundColor: context.colorScheme.accentColor,
                          buttonTitle: selectedPaymentMethod == "cod"
                              ? 'bookService'.translate(context: context)
                              : paymentButtonName.value
                                  .translate(context: context),
                          showBorder: false,
                          child: child,
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      );

  Widget getTitle({required String title}) {
    return CustomText(
      title.translate(context: context),
      fontSize: 16,
      color: context.colorScheme.blackColor,
      fontWeight: FontWeight.bold,
    );
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: context.colorScheme.primaryColor,
      appBar: UiUtils.getSimpleAppBar(
          context: context,
          title: 'checkoutServices'.translate(context: context)),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              clipBehavior: Clip.none,
              padding: EdgeInsets.only(
                  bottom: UiUtils.bottomNavigationBarHeight + 20, top: 10),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.isFrom == "customJobRequest" &&
                          context
                              .read<MyRequestCartCubit>()
                              .checkAtStoreProviderAvailable(
                                  isFrom: widget.isFrom) &&
                          context
                              .read<MyRequestCartCubit>()
                              .checkAtDoorstepProviderAvailable(
                                  isFrom: widget.isFrom)) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: getServiceDeliverableOptions(),
                        )
                      ],
                      if (widget.isFrom != "customJobRequest" &&
                          context
                              .read<CartCubit>()
                              .checkAtStoreProviderAvailable(
                                  isFrom: widget.isFrom) &&
                          context
                              .read<CartCubit>()
                              .checkAtDoorstepProviderAvailable(
                                  isFrom: widget.isFrom)) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: getServiceDeliverableOptions(),
                        )
                      ],
                      if (widget.isFrom != "customJobRequest")
                        verticalSpacing(),
                      if (widget.isFrom != "customJobRequest")
                        buildServicesList(),
                      verticalSpacing(),
                      buildDateSelector(),
                    ],
                  ),
                  if (widget.isFrom == "customJobRequest" &&
                      selectedDeliverableOption ==
                          deliverableOptions[0]["title"] &&
                      context
                          .read<MyRequestCartCubit>()
                          .checkAtDoorstepProviderAvailable(
                              isFrom: widget.isFrom)) ...[
                    
                    verticalSpacing(),
                    buildAddressSelector(),
                  ],
                  if (widget.isFrom != "customJobRequest" &&
                      selectedDeliverableOption ==
                          deliverableOptions[0]["title"] &&
                      context
                          .read<CartCubit>()
                          .checkAtDoorstepProviderAvailable(
                              isFrom: widget.isFrom)) ...[
                   
                    verticalSpacing(),
                    buildAddressSelector(),
                  ],
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      verticalSpacing(),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isProviderInstructionFieldEditClicable = true;
                          });
                        },
                        child: isProviderInstructionFieldEditClicable
                            ? buildProviderInstructionField()
                            : _buildViewProviderInstructionField(),
                      )
                    ],
                  ),
                  verticalSpacing(),
                  if (widget.isFrom != "customJobRequest")
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        GeneralCardContainer(
                          onTap: () {
                            if (widget.providerId == "0") {
                              UiUtils.showMessage(
                                context,
                                'somethingWentWrong'
                                    .translate(context: context),
                                ToastificationType.warning,
                              );
                              return;
                            }
                            Navigator.pushNamed(
                              context,
                              promocodeScreen,
                              arguments: {
                                "isFrom": widget.isFrom,
                                "providerID": widget.providerId,
                                "isAtStoreOptionSelected":
                                    selectedDeliverableOption == "atStore"
                                        ? "1"
                                        : "0"
                              },
                            ).then((final Object? value) {
                              if (value != null) {
                                final parameter = value as Map;
                                promoCodeDiscount =
                                    double.parse(parameter["discount"]);
                                appliedPromocode =
                                    parameter["appliedPromocode"];

                                setState(() {});
                              }
                            });
                          },
                          imageName: AppAssets.discount,
                          title: "applyCoupon",
                          description: appliedPromocode != null
                              ? "${appliedPromocode!.promoCode} ${"applied".translate(context: context)}"
                              : "applyCouponAndGetExtraDiscount"
                                  .translate(context: context),
                          extraWidgetWithDescription: appliedPromocode != null
                              ? CustomInkWellContainer(
                                  onTap: () {
                                    promoCodeDiscount = 0.0;
                                    appliedPromocode = null;
                                    setState(() {});
                                  },
                                  child: CustomText(
                                    "remove".translate(context: context),
                                    fontSize: 12,
                                    color: context.colorScheme.lightGreyColor,
                                    fontStyle: FontStyle.italic,
                                    showUnderline: true,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  verticalSpacing(),
                  if (widget.isFrom == "customJobRequest" &&
                          context
                              .read<MyRequestCartCubit>()
                              .isPayLaterAllowed(isFrom: widget.isFrom) &&
                          context
                              .read<MyRequestCartCubit>()
                              .isOnlinePaymentAllowed(isFrom: widget.isFrom) ||
                      (widget.isFrom == "customJobRequest" &&
                          context
                              .read<MyRequestCartCubit>()
                              .isOnlinePaymentAllowed(isFrom: widget.isFrom) &&
                          context
                              .read<SystemSettingCubit>()
                              .isMoreThanOnePaymentGatewayEnabled())) ...[
                    CustomContainer(
                      color: context.colorScheme.secondaryColor,
                      padding: const EdgeInsetsDirectional.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          verticalSpacing(),
                          ...[
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: enabledPaymentMethods.length,
                              itemBuilder: (context, index) {
                                final Map<String, dynamic> paymentMethod =
                                    enabledPaymentMethods[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: CustomRadioOptionsWidget(
                                    image: paymentMethod["image"]!,
                                    title: paymentMethod["title"]!,
                                
                                    value: paymentMethod["paymentType"]!,
                                    groupValue: selectedPaymentMethod!,
                                    applyAccentColor: false,
                                    onChanged: (final Object? selectedValue) {
                                      selectedPaymentMethod =
                                          selectedValue.toString();
                                      if (selectedValue.toString() == "cod") {
                                        paymentButtonName.value = "bookService";
                                      } else {
                                        paymentButtonName.value = "makePayment";
                                      }
                                      setState(() {});
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    )
                  ],
                  if (widget.isFrom != "customJobRequest" &&
                          context
                              .read<CartCubit>()
                              .isPayLaterAllowed(isFrom: widget.isFrom) &&
                          context
                              .read<CartCubit>()
                              .isOnlinePaymentAllowed(isFrom: widget.isFrom) ||
                      (widget.isFrom != "customJobRequest" &&
                          context
                              .read<CartCubit>()
                              .isOnlinePaymentAllowed(isFrom: widget.isFrom) &&
                          context
                              .read<SystemSettingCubit>()
                              .isMoreThanOnePaymentGatewayEnabled())) ...[
                    CustomContainer(
                      color: context.colorScheme.secondaryColor,
                      padding: const EdgeInsetsDirectional.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            'selectPayment'.translate(context: context),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          verticalSpacing(),
                          ...[
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: enabledPaymentMethods.length,
                              itemBuilder: (context, index) {
                                final Map<String, dynamic> paymentMethod =
                                    enabledPaymentMethods[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: CustomRadioOptionsWidget(
                                    image: paymentMethod["image"]!,
                                    title: paymentMethod["title"]!,
                                  
                                    value: paymentMethod["paymentType"]!,
                                    groupValue: selectedPaymentMethod!,
                                    applyAccentColor: false,
                                    onChanged: (final Object? selectedValue) {
                                      selectedPaymentMethod =
                                          selectedValue.toString();
                                      if (selectedValue.toString() == "cod") {
                                        paymentButtonName.value = "bookService";
                                      } else {
                                        paymentButtonName.value = "makePayment";
                                      }
                                      setState(() {});
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    )
                  ],
                  verticalSpacing(),
                  if (widget.isFrom == "customJobRequest") ...[
                    BlocBuilder<MyRequestCartCubit, MyRequestCartState>(
                      builder: (final BuildContext context,
                          final MyRequestCartState state) {
                        if (state is MyRequestCartInProgress) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: context.colorScheme.accentColor,
                            ),
                          );
                        }
                        if (state is MyRequestCartSuccess) {
                          return CustomContainer(
                            color: context.colorScheme.secondaryColor,
                            borderRadius: UiUtils.borderRadiusOf10,
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              children: [
                                ChargesTile(
                                  title1:
                                      'subTotal'.translate(context: context),
                                  title2: '',
                                  title3: (state.bidderData.finalTotal ?? "0")
                                      .priceFormat(),
                                  fontSize: 16,
                                  fontweight: FontWeight.w400,
                                ),
                                const CustomSizedBox(
                                  height: 10,
                                ),
                                if (widget.isFrom == "customJobRequest" &&
                                    state.bidderData.visitingCharges != '0' &&
                                    state.bidderData.visitingCharges != "" &&
                                    state.bidderData.visitingCharges !=
                                        'null' &&
                                    selectedDeliverableOption != "atStore")
                                  ChargesTile(
                                    title1: 'visitingCharge'
                                        .translate(context: context),
                                    title2: '',
                                    title3:
                                        '+ ${state.bidderData.visitingCharges!.priceFormat()}',
                                    fontSize: 16,
                                    fontweight: FontWeight.w400,
                                  ),
                                if (selectedDeliverableOption != "atStore")
                                  const CustomSizedBox(
                                    height: 10,
                                  ),
                                if (selectedDeliverableOption != "atStore")
                                  ChargesTile(
                                    title1: 'totalAmount'
                                        .translate(context: context),
                                    title2: '',
                                    title3: (double.parse(state
                                                        .bidderData.finalTotal
                                                        .toString() !=
                                                    "null"
                                                ? state.bidderData.finalTotal
                                                    .toString()
                                                : "0") +
                                            (selectedDeliverableOption !=
                                                    "atStore"
                                                ? double.parse(state.bidderData
                                                        .visitingCharges ??
                                                    "0")
                                                : 0))
                                        .toStringAsFixed(2)
                                        .priceFormat(),
                                    fontSize: 18,
                                    fontweight: FontWeight.w700,
                                  ),
                              ],
                            ),
                          );
                        }
                        return const CustomSizedBox();
                      },
                    ),
                  ],
                  if (widget.isFrom != "customJobRequest") ...[
                    BlocBuilder<CartCubit, CartState>(
                      builder:
                          (final BuildContext context, final CartState state) {
                        if (state is CartFetchSuccess) {
                          if (state.cartData.cartDetails == null &&
                              state.reOrderCartData?.cartDetails == null) {
                            return const CustomSizedBox();
                          }
                          return CustomContainer(
                            color: context.colorScheme.secondaryColor,
                           
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              children: [
                                
                                ChargesTile(
                                  title1:
                                      'subTotal'.translate(context: context),
                                  title2: '',
                                  title3: (widget.isFrom == "cart"
                                          ? state.cartData.subTotal ?? "0"
                                          : state.reOrderCartData?.subTotal ??
                                              "0")
                                      .priceFormat(),
                                  fontSize: 14,
                                ),
                                if (promoCodeDiscount != 0.0) ...[
                                  const CustomSizedBox(
                                    height: 5,
                                  ),
                                  ChargesTile(
                                    title1: "couponDiscount"
                                        .translate(context: context),
                                    title2: '',
                                    title3:
                                        '- ${promoCodeDiscount.toString().priceFormat()}',
                                    fontSize: 16,
                                    fontweight: FontWeight.w400,
                                  ),
                                ],
                                const CustomSizedBox(
                                  height: 10,
                                ),
                                if (widget.isFrom == "cart" &&
                                    state.cartData.visitingCharges != '0' &&
                                    state.cartData.visitingCharges != "" &&
                                    state.cartData.visitingCharges != 'null' &&
                                    selectedDeliverableOption != "atStore")
                                  ChargesTile(
                                    title1: 'visitingCharge'
                                        .translate(context: context),
                                    title2: '',
                                    title3:
                                        '+ ${state.cartData.visitingCharges!.priceFormat()}',
                                    fontSize: 16,
                                    fontweight: FontWeight.w400,
                                  ),
                                if (widget.isFrom == "reBooking" &&
                                    state.reOrderCartData?.visitingCharges !=
                                        '0' &&
                                    state.reOrderCartData?.visitingCharges !=
                                        "" &&
                                    state.reOrderCartData?.visitingCharges !=
                                        'null' &&
                                    selectedDeliverableOption != "atStore")
                                  ChargesTile(
                                    title1: 'visitingCharge'
                                        .translate(context: context),
                                    title2: '',
                                    title3:
                                        '+ ${(state.reOrderCartData?.visitingCharges ?? "0").priceFormat()}',
                                    fontSize: 16,
                                    fontweight: FontWeight.w400,
                                  ),
                                const CustomSizedBox(
                                  height: 10,
                                ),
                                ChargesTile(
                                  title1:
                                      'totalAmount'.translate(context: context),
                                  title2: '',
                                  title3: (double.parse(widget.isFrom == "cart"
                                              ? state.cartData.overallAmount !=
                                                      "null"
                                                  ? state.cartData
                                                          .overallAmount ??
                                                      "0"
                                                  : "0"
                                              : state.reOrderCartData
                                                          ?.overallAmount !=
                                                      "null"
                                                  ? state.reOrderCartData
                                                          ?.overallAmount ??
                                                      "0"
                                                  : '0') -
                                          promoCodeDiscount -
                                          (selectedDeliverableOption ==
                                                  "atStore"
                                              ? double.parse(widget
                                                          .isFrom ==
                                                      "cart"
                                                  ? state.cartData
                                                          .visitingCharges ??
                                                      "0"
                                                  : state.reOrderCartData
                                                          ?.visitingCharges ??
                                                      "0")
                                              : 0))
                                      .toStringAsFixed(2)
                                      .priceFormat(),
                                  fontSize: 18,
                                  fontweight: FontWeight.w700,
                                ),
                              ],
                            ),
                          );
                        }
                        return const CustomSizedBox();
                      },
                    ),
                  ]
                ],
              ),
            ),
              ],
        ),
      ),
      bottomSheet: continueButtonContainer(context),
    );
  }

  void _openWebviewPaymentGateway({required String webviewLink}) {
    Navigator.pushNamed(
      context,
      webviewPaymentScreen,
      arguments: {'paymentURL': webviewLink},
    ).then((final Object? value) {
      final parameter = value as Map;
      if (parameter['paymentStatus'] == 'Completed') {
        //
        _navigateToOrderConfirmation(isSuccess: true);
        //
      } else if (parameter['paymentStatus'] == 'Failed') {
        _navigateToOrderConfirmation(isSuccess: false);
      }
    });
  }

  @override
  void dispose() {
    _instructionController.dispose();
    paymentButtonName.dispose();
    _cartSubscription?.cancel();
    super.dispose();
  }
}
