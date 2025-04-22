import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class ProviderServiceDetailsScreen extends StatefulWidget {
  const ProviderServiceDetailsScreen(
      {super.key,
      required this.serviceDetails,
      required this.serviceId,
      required this.providerId,
      this.isProviderAvailableAtLocation});
  final Services serviceDetails;
  final String serviceId;
  final String providerId;
  final String? isProviderAvailableAtLocation;

  @override
  State<ProviderServiceDetailsScreen> createState() =>
      _ProviderServiceDetailsScreenState();

  static Route route(final RouteSettings routeSettings) {
    //
    final Map arguments = routeSettings.arguments as Map;
    //
    return CupertinoPageRoute(
      builder: (final _) => ProviderServiceDetailsScreen(
        serviceDetails: arguments["serviceDetails"],
        serviceId: arguments["serviceId"],
        providerId: arguments["providerId"],
        isProviderAvailableAtLocation:
            arguments["isProviderAvailableAtLocation"],
      ),
    );
  }
}

class _ProviderServiceDetailsScreenState
    extends State<ProviderServiceDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ServiceReviewCubit>().fetchServiceReview(
        serviceId: widget.serviceId, providerId: widget.providerId);
  }

  Widget _buildServiceDetailsCard(
      {required BuildContext context, required Services services}) {
    final bool viewRating =
        double.parse(services.rating!).toStringAsFixed(1) != '0.0';
    return CustomContainer(
      padding: const EdgeInsets.all(15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: CustomImageContainer(
              borderRadius: UiUtils.borderRadiusOf8,
              imageURL: services.imageOfTheService!,
              height: 150,
              width: 100,
              boxShadow: [],
              boxFit: BoxFit.fill,
            ),
          ),
          const CustomSizedBox(
            width: 10,
          ),
          Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    services.title!,
                    maxLines: 2,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: context.colorScheme.blackColor,
                  ),
                  const CustomSizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomSvgPicture(
                        svgImage: AppAssets.icGroup,
                        height: 18,
                        width: 18,
                        color: context.colorScheme.accentColor,
                      ),
                      CustomText(
                        " ${services.numberOfMembersRequired} ${"person".translate(context: context)} ",
                        fontSize: 13,
                        color: context.colorScheme.blackColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                  const CustomSizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomSvgPicture(
                        svgImage: AppAssets.icClock,
                        height: 18,
                        width: 18,
                        color: context.colorScheme.accentColor,
                      ),
                      CustomText(
                        " ${services.duration} ${"minutes".translate(context: context)}",
                        fontSize: 13,
                        color: context.colorScheme.blackColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                  const CustomSizedBox(
                    height: 10,
                  ),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        if (viewRating)
                          const CustomSvgPicture(
                            svgImage: AppAssets.icStar,
                            color: AppColors.ratingStarColor,
                            height: 20,
                            width: 20,
                          ),
                        if (viewRating)
                          CustomText(
                            ' ${double.parse(services.rating!).toStringAsFixed(1)}',
                            color: context.colorScheme.blackColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        if (viewRating)
                          VerticalDivider(
                            color: context.colorScheme.lightGreyColor,
                            thickness: 0.5,
                          ),
                        CustomText(
                          ' ${double.parse(services.rating!).toStringAsFixed(0)} ${'reviewers'.translate(context: context)}',
                          color: Theme.of(context).colorScheme.accentColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ),
                  const CustomSizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomText(
                        (services.priceWithTax != ''
                                ? services.priceWithTax!
                                : '0.0')
                            .priceFormat(),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: context.colorScheme.blackColor,
                      ),
                      if (services.discountedPrice != '0')
                        const CustomSizedBox(
                          width: 5,
                        ),
                      if (services.discountedPrice != '0')
                        Expanded(
                          child: CustomText(
                            (services.originalPriceWithTax != ''
                                    ? services.originalPriceWithTax!
                                    : '0.0')
                                .priceFormat(),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: context.colorScheme.accentColor,
                            showLineThrough: true,
                            maxLines: 1,
                          ),
                        ),
                    ],
                  ),
                ],
              ))
        ],
      ),
    );
  }

  Widget _buildCustomContainerWithTitleWidget({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    return CustomContainer(
      margin: const EdgeInsetsDirectional.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      width: double.infinity,
      color: context.colorScheme.secondaryColor,
      borderRadius: UiUtils.borderRadiusOf10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            title,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: context.colorScheme.accentColor,
          ),
          const CustomSizedBox(
            height: 10,
          ),
          child,
        ],
      ),
    );
  }

  //
  Widget _buildFileWidget({required BuildContext context}) {
    return _buildCustomContainerWithTitleWidget(
      context: context,
      title: "brochureOrFiles".translate(context: context),
      child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.serviceDetails.filesOfTheService!.length,
          separatorBuilder: (final BuildContext context, final int index) =>
              const CustomDivider(),
          itemBuilder: (final BuildContext context, final int index) {
            final fileName = widget.serviceDetails.filesOfTheService![index]
                .split("/")
                .last; // get file name
            return CustomInkWellContainer(
              onTap: () {
                launchUrl(
                  Uri.parse(widget.serviceDetails.filesOfTheService![index]),
                  mode: LaunchMode.externalApplication,
                );
              },
              child: Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    color: context.colorScheme.lightGreyColor,
                    size: 30,
                  ),
                  CustomText(
                    fileName.split(".").first,
                    color: context.colorScheme.blackColor,
                    maxLines: 1,
                  ) // remove file extension
                ],
              ),
            );
          }),
    );
  }

  Widget _buildFAQWidget({required BuildContext context}) {
    return _buildCustomContainerWithTitleWidget(
      context: context,
      title: "faqs".translate(context: context),
      child: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: List.generate(
              widget.serviceDetails.faqsOfTheService!.length,
              (final int index) {
                // bool isExpanded = false;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: EdgeInsets.zero,
                      collapsedIconColor: context.colorScheme.blackColor,
                      expandedAlignment: Alignment.topLeft,
                      title: CustomText(
                        widget.serviceDetails.faqsOfTheService![index]
                                .question ??
                            "",
                        color: context.colorScheme.blackColor,
                        fontStyle: FontStyle.normal,
                        fontSize: 14,
                        textAlign: TextAlign.left,
                      ),
                      children: <Widget>[
                        CustomText(
                          widget.serviceDetails.faqsOfTheService![index]
                                  .answer ??
                              "",
                          color: context.colorScheme.lightGreyColor,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 12,
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceDescriptionWidget({required BuildContext context}) {
    return _buildCustomContainerWithTitleWidget(
      context: context,
      title: "serviceDescription".translate(context: context),
      child: HtmlWidget(widget.serviceDetails.longDescription ?? ""),
    );
  }

  Widget _buildReviewWidget(
      {required BuildContext context, required Services serviceDetails}) {
    return BlocBuilder<ServiceReviewCubit, ServiceReviewState>(
      builder: (context, state) {
        if (state is ServiceReviewFetchSuccess) {
          if (state.reviewList.isEmpty) {
            return const CustomSizedBox();
          }
          return CustomContainer(
            padding: const EdgeInsets.all(15),
            child: ReviewsContainer(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              averageRating: serviceDetails.rating ?? "0",
              totalNumberOfRatings: serviceDetails.numberOfRatings ?? "0",
              totalNumberOfFiveStarRating: serviceDetails.fiveStar ?? "0",
              totalNumberOfFourStarRating: serviceDetails.fourStar ?? "0",
              totalNumberOfThreeStarRating: serviceDetails.threeStar ?? "0",
              totalNumberOfTwoStarRating: serviceDetails.twoStar ?? "0",
              totalNumberOfOneStarRating: serviceDetails.oneStar ?? "0",
              listOfReviews: state.reviewList,
              progressReviewWidth: context.screenWidth * 0.22,
            ),
          );
        } else if (state is ServiceReviewFetchFailure) {
          return const CustomSizedBox();
        }
        return CustomShimmerLoadingContainer(
          borderRadius: UiUtils.borderRadiusOf10,
          height: 25,
          width: context.screenWidth,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.secondaryColor,
      appBar: UiUtils.getSimpleAppBar(
          context: context,
          title: 'serviceDetails'.translate(context: context)),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildServiceDetailsCard(
                    context: context, services: widget.serviceDetails),
                _buildCustomContainerWithTitleWidget(
                  context: context,
                  title: 'aboutService'.translate(context: context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomReadMoreTextContainer(
                        text: widget.serviceDetails.description ?? "",
                        textStyle: TextStyle(
                          color: context.colorScheme.lightGreyColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.serviceDetails.longDescription!.isNotEmpty) ...[
                  _buildServiceDescriptionWidget(context: context)
                ],
                if (widget
                    .serviceDetails.otherImagesOfTheService!.isNotEmpty) ...[
                  _buildCustomContainerWithTitleWidget(
                    context: context,
                    title: "photos".translate(context: context),
                    child: GalleryImagesStyles(
                        imagesList:
                            widget.serviceDetails.otherImagesOfTheService!),
                  ),
                ],
                if (widget.serviceDetails.filesOfTheService!.isNotEmpty) ...[
                  _buildFileWidget(context: context),
                ],
                if (widget.serviceDetails.faqsOfTheService!.isNotEmpty) ...[
                  _buildFAQWidget(context: context)
                ],
                _buildReviewWidget(
                    context: context, serviceDetails: widget.serviceDetails),
                const CustomContainer(
                  height: 70,
                )
              ],
            ),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: AddToCartServicesContainer(
                  services: widget.serviceDetails,
                  isProviderAvailableAtLocation:
                      widget.isProviderAvailableAtLocation))
        ],
      ),
    );
  }
}
