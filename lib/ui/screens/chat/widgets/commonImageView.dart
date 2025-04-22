import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class CommonImageWidget extends StatelessWidget {
  final bool isFile;
  final bool isAsset;
  final String imagePath;
  final BoxFit boxFit;
  final Widget? customLoadingPlaceholder;
  final ProgressIndicatorBuilder? progressIndicatorBuilder;
  final ImageWidgetBuilder? imageBuilder;
  final LoadingErrorWidgetBuilder? errorWidget;
  const CommonImageWidget(
      {super.key,
      this.isFile = false,
      this.isAsset = false,
      required this.imagePath,
      this.boxFit = BoxFit.cover,
      this.customLoadingPlaceholder,
      this.progressIndicatorBuilder,
      this.imageBuilder,
      this.errorWidget});

  @override
  Widget build(BuildContext context) {
    return !isFile && !isAsset //it's network in that case
        ? imagePath.split('.').last.toLowerCase() == "svg"
            ? SvgPicture.network(
                imagePath,
                fit: boxFit,
              )
            : CachedNetworkImage(
                /*   memCacheHeight: 500,
                memCacheWidth: 500,*/
                errorWidget: errorWidget ??
                    (context, image, _) => Center(
                          child: Icon(
                            Icons.error,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                imageUrl: imagePath,
                fit: boxFit,
                placeholder: progressIndicatorBuilder != null
                    ? null
                    : (context, url) =>
                        customLoadingPlaceholder ??
                        Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                progressIndicatorBuilder: progressIndicatorBuilder,
                imageBuilder: imageBuilder,
              )
        : isAsset
            ? imagePath.split('.').last.toLowerCase() == "svg"
                ? SvgPicture.asset(
                    imagePath,
                    fit: boxFit,
                  )
                : Image.asset(
                    imagePath,
                    fit: boxFit,
                  )
            : imagePath.split('.').last.toLowerCase() == "svg"
                ? SvgPicture.file(
                    File(imagePath),
                    fit: boxFit,
                  )
                : Image.file(
                    File(imagePath),
                    fit: boxFit,
                  );
  }
}
