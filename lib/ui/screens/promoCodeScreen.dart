import 'package:madwell/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PromoCodeScreen extends StatefulWidget {
  const PromoCodeScreen(
      {required this.providerID,
      super.key,
      required this.isAtStoreOptionSelected,
      required this.isFrom});

  final String providerID;
  final String isFrom;
  final String isAtStoreOptionSelected;

  static Route route(final RouteSettings routeSettings) {
    final Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (final _) => MultiBlocProvider(
        providers: [
          BlocProvider<ValidatePromocodeCubit>(
            create: (final context) =>
                ValidatePromocodeCubit(cartRepository: CartRepository()),
          ),
        ],
        child: PromoCodeScreen(
            isFrom: arguments["isFrom"],
            providerID: arguments['providerID'],
            isAtStoreOptionSelected: arguments['isAtStoreOptionSelected']),
      ),
    );
  }

  @override
  State<PromoCodeScreen> createState() => _PromoCodeScreenState();
}

class _PromoCodeScreenState extends State<PromoCodeScreen> {
  //
  Widget getMessageContainer({required final String message}) => Row(
        children: [
          const Icon(Icons.remove, size: 10),
          const CustomSizedBox(
            width: 5,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: CustomText(
                message,
                fontSize: 12,
              ),
            ),
          ),
        ],
      );

  Widget getPromoCodeContainer({required final Promocode promoCodeDetails}) =>
      CustomContainer(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
        color: context.colorScheme.secondaryColor,
        borderRadius: UiUtils.borderRadiusOf10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(UiUtils.borderRadiusOf10),
                    child: CustomCachedNetworkImage(
                      networkImageUrl: promoCodeDetails.image!,
                      height: 80,
                      width: 80,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                CustomSizedBox(
                  height: 80,
                  child: VerticalDivider(
                    color: context.colorScheme.lightGreyColor,
                    thickness: 1,
                    indent: 5,
                    endIndent: 5,
                    width: 20,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(promoCodeDetails.promoCode!),
                      Row(
                        children: [
                          CustomText(
                              '${promoCodeDetails.discount!} '
                              '${promoCodeDetails.discountType}',
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                          CustomText(' ${"off".translate(context: context)}')
                        ],
                      ),
                    ],
                  ),
                ),
                BlocConsumer<ValidatePromocodeCubit, ValidatePromoCodeState>(
                  listener: (final BuildContext context,
                      final ValidatePromoCodeState state) async {
                    if (state is ValidatePromoCodeSuccess) {
                      if (!state.error) {
                      

                        //
                        //we have created validate promocode instance for each promocode
                        //so listener will call for each instance and we have pop it only one time
                        //so in this condition it will pop only one time
                        if (state.promoCodeId == promoCodeDetails.id) {
                          UiUtils.showMessage(
                            context,
                            'promoCodeAppliedSuccessfully'
                                .translate(context: context),
                            ToastificationType.success,
                          );

                          await Future.delayed(
                                  const Duration(milliseconds: 500))
                              .then((final value) {
                            Navigator.of(context).pop({
                              "discount": state.discountAmount,
                              "appliedPromocode": promoCodeDetails,
                            });
                          });
                        }
                      } else {
                        if (state.promoCodeId == promoCodeDetails.id) {
                          UiUtils.showMessage(
                              context,
                              state.message.translate(context: context),
                              ToastificationType.error);
                        }
                      }
                    } else if (state is ValidatePromoCodeFailure) {
                      UiUtils.showMessage(
                          context,
                          state.errorMessage.translate(context: context),
                          ToastificationType.error);
                    }
                  },
                  builder: (final BuildContext context,
                      ValidatePromoCodeState state) {
                    if (state is ValidatePromoCodeInProgress) {
                      if (state.promoCodeID == promoCodeDetails.id) {
                        return CustomContainer(
                          alignment: Alignment.center,
                          height: 35,
                          color: Theme.of(context).primaryColor,
                          borderRadius: UiUtils.borderRadiusOf10,
                          width: context.screenWidth * 0.25,
                          child: Center(
                            child: CustomSizedBox(
                                height: 30,
                                width: 30,
                                child: CustomCircularProgressIndicator(
                                  color: context.colorScheme.accentColor,
                                )),
                          ),
                        );
                      }
                    }
                    if (state is ValidatePromoCodeSuccess) {
                      if (!state.error) {
                        if (state.promoCodeId == promoCodeDetails.id) {
                          return CustomRoundedButton(
                            height: 35,
                            widthPercentage: 0.25,
                            titleColor: context.colorScheme.blackColor,
                            backgroundColor: Theme.of(context).primaryColor,
                            buttonTitle: "applied".translate(context: context),
                            showBorder: false,
                            textSize: 14,
                          );
                        }
                      }
                    }
                    return CustomRoundedButton(
                      height: 35,
                      widthPercentage: 0.25,
                      titleColor: context.colorScheme.blackColor,
                      backgroundColor: Theme.of(context).primaryColor,
                      buttonTitle: 'apply'.translate(context: context),
                      showBorder: false,
                      textSize: 14,
                      onTap: () {
                        if (state is ValidatePromoCodeInProgress) {
                          return;
                        }

                        // validate selected promoCode
                        context
                            .read<ValidatePromocodeCubit>()
                            .validatePromoCodes(
                              totalAmount: context
                                  .read<CartCubit>()
                                  .getCartSubTotalAmount(
                                      isFrom: widget.isFrom,
                                      isAtStoreBooked:
                                          widget.isAtStoreOptionSelected ==
                                              "1"),
                              promoCodeID: promoCodeDetails.id!,
                            );
                      },
                    );
                  },
                )
              ],
            ),
            getMessageContainer(message: promoCodeDetails.message!),
            getMessageContainer(
              message:
                  "${'offerIsApplicableOnMinimumValueOf'.translate(context: context)} ${promoCodeDetails.minimumOrderAmount!.priceFormat()}",
            ),
            getMessageContainer(
              message:
                  "${'maximumInstantDiscountOf'.translate(context: context)} ${promoCodeDetails.maxDiscountAmount!.priceFormat()}",
            ),
            getMessageContainer(
              message:
                  "${'offerValidFrom'.translate(context: context)} ${promoCodeDetails.startDate.toString().formatDate()} ${'to'.translate(context: context)} ${promoCodeDetails.endDate.toString().formatDate()}",
            ),
            if (int.parse(promoCodeDetails.noOfRepeatUsage!) > 1)
              getMessageContainer(
                message:
                    "${"applicableMaximum".translate(context: context)} ${promoCodeDetails.noOfRepeatUsage} ${"timesDuringCampaignPeriod".translate(context: context)}",
              ),
            if (int.parse(promoCodeDetails.noOfRepeatUsage!) == 1)
              getMessageContainer(
                message: 'offerValidOncePerCustomerDuringCampaignPeriod'
                    .translate(context: context),
              ),
          ],
        ),
      );

  void fetchPromoCodes() {
    context
        .read<GetPromocodeCubit>()
        .getPromocodes(providerIdOrSlug: widget.providerID);
  }

  Widget promoCodeLoadingShimmer() => Column(
        children: List.generate(
          UiUtils.numberOfShimmerContainer,
          (final int index) => CustomContainer(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(10),
            child: Row(
              children: [
                const CustomShimmerLoadingContainer(
                  height: 80,
                  width: 80,
                ),
                const CustomSizedBox(
                  width: 15,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomShimmerLoadingContainer(
                      height: 10,
                      width: context.screenWidth * 0.4,
                    ),
                    const CustomSizedBox(
                      height: 10,
                    ),
                    CustomShimmerLoadingContainer(
                      height: 10,
                      width: context.screenWidth * 0.4,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );

  @override
  void initState() {
    fetchPromoCodes();
    super.initState();
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        backgroundColor: context.colorScheme.primaryColor,
        appBar: UiUtils.getSimpleAppBar(
          context: context,
          title: 'promoCode'.translate(context: context),
        ),
        body: SingleChildScrollView(
          child: BlocBuilder<GetPromocodeCubit, GetPromocodeState>(
            builder:
                (final BuildContext context, final GetPromocodeState state) {
              if (state is FetchPromocodeFailure) {
                return ErrorContainer(
                  errorMessage: state.errorMessage.translate(context: context),
                  onTapRetry: () {
                    fetchPromoCodes();
                  },
                );
              }
              if (state is FetchPromocodeSuccess) {
                return state.promocodeList.isEmpty
                    ? Center(
                        child: NoDataFoundWidget(
                          titleKey: 'noPromoCodeAvailable'
                              .translate(context: context),
                        ),
                      )
                    : Column(
                        children: List.generate(
                          state.promocodeList.length,
                          (final int index) => getPromoCodeContainer(
                            promoCodeDetails: state.promocodeList[index],
                          ),
                        ),
                      );
              }
              return promoCodeLoadingShimmer();
            },
          ),
        ),
      );
}
