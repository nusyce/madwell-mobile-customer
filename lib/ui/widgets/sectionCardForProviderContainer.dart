import 'package:madwell/app/generalImports.dart';
import 'package:flutter/material.dart';

class SectionCardForProviderContainer extends StatelessWidget {
  const SectionCardForProviderContainer({
    required this.discount,
    required this.onTap,
    required this.imageHeight,
    required this.imageWidth,
    required this.cardHeight,
    required this.title,
    required this.image,
    required this.cardWidth,
    required this.bannerImage,
    required this.numberOfRating,
    required this.distance,
    required this.averageRating,
    required this.services,
    final Key? key,
  }) : super(key: key);
  final String title,
      image,
      discount,
      bannerImage,
      numberOfRating,
      distance,
      averageRating,
      services;
  final double imageHeight, imageWidth, cardHeight, cardWidth;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) {
    return CustomInkWellContainer(
      onTap: onTap,
      child: Stack(
        children: [
          // The first container
          CustomContainer(
            margin: const EdgeInsetsDirectional.symmetric(
                vertical: 20, horizontal: 10),
            height: cardHeight,
            width: cardWidth,
            border:
                Border.all(color: context.colorScheme.blackColor, width: 0.2),
            borderRadius: UiUtils.borderRadiusOf8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(UiUtils.borderRadiusOf8),
                    topRight: Radius.circular(UiUtils.borderRadiusOf8),
                  ),
                  child: CustomCachedNetworkImage(
                    networkImageUrl: bannerImage,
                    height: cardHeight / 2,
                    width: cardWidth,
                    fit: BoxFit.fill,
                  ),
                ),
                IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (averageRating != '0' && averageRating != '') ...[
                          Row(
                            children: [
                              const CustomSvgPicture(
                                svgImage: AppAssets.icStar,
                                height: 16,
                                width: 16,
                                color: AppColors.ratingStarColor,
                              ),
                              const SizedBox(width: 5),
                              CustomText(
                                averageRating,
                                fontSize: 14,
                                color: AppColors.startedOrderColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                          const SizedBox(width: 5),
                          const VerticalDivider(
                            color: Colors.black,
                            thickness: 0.2,
                          ),
                        ],
                        const SizedBox(width: 5),
                        CustomSvgPicture(
                          svgImage: AppAssets.icLocation,
                          height: 16,
                          width: 16,
                          color: context.colorScheme.accentColor,
                        ),
                        const SizedBox(width: 5),
                        CustomText(
                          "${double.parse(distance).ceil()} ${UiUtils.distanceUnit}",
                          fontSize: 14,
                          color: AppColors.startedOrderColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Centered container
          Positioned.directional(
            top: (cardHeight - (cardHeight / 3)) / 1.3,
            end: (cardWidth - (cardWidth / 1.1)) / 1.1,
            textDirection: Directionality.of(context),
            child: CustomContainer(
              padding: const EdgeInsetsDirectional.all(8),
              height: cardHeight / 3,
              width: cardWidth / 1.1,
              borderRadius: UiUtils.borderRadiusOf8,
              color: context.colorScheme.secondaryColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(
                          title,
                          fontSize: 16,
                          maxLines: 1,
                          color: context.colorScheme.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                        CustomText(
                          '$services ${services.toInt() > 1 ? 'services'.translate(context: context) : 'service'.translate(context: context)}',
                          fontSize: 12,
                          maxLines: 1,
                          color: context.colorScheme.lightGreyColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(UiUtils.borderRadiusOf8),
                      ),
                      child: CustomCachedNetworkImage(
                        networkImageUrl: image,
                        width: 45,
                        height: 45,
                        fit: BoxFit.fill,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
