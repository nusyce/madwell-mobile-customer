import 'package:flutter/material.dart';

import '../../../../app/generalImports.dart';

class GeneralCardContainer extends StatelessWidget {
  final String imageName;
  final String title;
  final String description;
  final bool? showEditIcon;
  final VoidCallback? onTap;
  final Widget? extraWidgetWithDescription;

  const GeneralCardContainer(
      {super.key,
      required this.imageName,
      required this.title,
      required this.description,
      this.showEditIcon,
      this.extraWidgetWithDescription,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return CustomInkWellContainer(
      onTap: () {
        onTap?.call();
      },
      child: Ink(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: context.colorScheme.secondaryColor,
          // borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
        ),
        child: Row(
          children: [
            CustomContainer(
              borderRadius: UiUtils.borderRadiusOf6,
              color: context.colorScheme.accentColor.withAlpha(20),
              padding: const EdgeInsets.all(12),
              // width: 24,
              // height: 24,
              child: CustomSvgPicture(
                svgImage: imageName,
                width: 24,
                height: 24,
                color: context.colorScheme.accentColor,
              ),
            ),
            const CustomSizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomText(
                    title.translate(context: context),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  if (description != "") ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CustomText(
                            description.translate(context: context),
                            fontSize: 14,
                            color: context.colorScheme.lightGreyColor,
                            maxLines: 2,
                          ),
                        ),
                        extraWidgetWithDescription ?? const SizedBox.shrink(),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (showEditIcon ?? false) ...[
              CustomSizedBox(
                width: 25,
                height: 25,
                child: CustomContainer(
                  width: 25,
                  height: 25,
                  borderRadius: UiUtils.borderRadiusOf5,
                  color: context.colorScheme.primaryColor,
                  child: const Icon(Icons.edit, size: 18),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
