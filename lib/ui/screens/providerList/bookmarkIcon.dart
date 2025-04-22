import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class BookMarkIcon extends StatelessWidget {
  const BookMarkIcon({required this.providerData, final Key? key})
      : super(key: key);
  final Providers providerData;

  @override
  Widget build(final BuildContext context) => BlocProvider(
        create: (final BuildContext context) =>
            UpdateProviderBookmarkStatusCubit(),
        child: BlocBuilder<BookmarkCubit, BookmarkState>(
          bloc: context.read<BookmarkCubit>(),
          builder: (final BuildContext context, BookmarkState bookmarkState) {
            if (bookmarkState is BookmarkFetchSuccess) {
              //check if partner is bookmark or not
              final isBookmark = context
                  .read<BookmarkCubit>()
                  .isPartnerBookmark(providerData.providerId!);
              //
              return BlocConsumer<UpdateProviderBookmarkStatusCubit,
                  UpdateProviderBookmarkStatusState>(
                bloc: context.read<UpdateProviderBookmarkStatusCubit>(),
                listener: (final BuildContext context,
                    final UpdateProviderBookmarkStatusState state) {
                  //
                  if (state is UpdateProviderBookmarkStatusFailure) {
                    UiUtils.showMessage(
                      context,
                      state.errorMessage.translate(context: context),
                      ToastificationType.error,
                    );
                  }
                  if (state is UpdateProviderBookmarkStatusSuccess) {
                    //
                    UiUtils.getVibrationEffect();
                    if (state.wasBookmarkProviderProcess) {
                      context.read<BookmarkCubit>().addBookmark(state.provider);
                    } else {
                      context
                          .read<BookmarkCubit>()
                          .removeBookmark(providerData.providerId!);
                    }
                  }
                },
                builder: (final BuildContext context,
                    final UpdateProviderBookmarkStatusState state) {
                  if (state is UpdateProviderBookmarkStatusInProgress) {
                    return CustomContainer(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      height: 20,
                      width: 20,
                      child: CustomCircularProgressIndicator(
                        color: context.colorScheme.accentColor,
                        strokeWidth: 1,
                      ),
                    );
                  }
                  return CustomInkWellContainer(
                    onTap: () {
                      final authStatus =
                          context.read<AuthenticationCubit>().state;
                      if (authStatus is UnAuthenticatedState) {
                        UiUtils.showAnimatedDialog(
                            context: context,
                            child: const LogInAccountDialog());

                        return;
                      }
                      if (state is UpdateProviderBookmarkStatusInProgress) {
                        return;
                      }
                      if (isBookmark) {
                        context
                            .read<UpdateProviderBookmarkStatusCubit>()
                            .unBookmarkProvider(
                              context: context,
                              providerId: providerData.providerId,
                              provider: providerData,
                            );
                      } else {
                        //
                        context
                            .read<UpdateProviderBookmarkStatusCubit>()
                            .bookmarkPartner(
                              providerData: providerData,
                              context: context,
                              providerId: providerData.providerId!,
                            );
                      }
                    },
                    child: CustomToolTip(
                      toolTipMessage: "bookmark".translate(context: context),
                      child: CustomSvgPicture(
                        svgImage: isBookmark
                            ? AppAssets.bookmarked
                            : AppAssets.bookmark,
                        color: context.colorScheme.accentColor,
                      ),
                    ),
                  );
                },
              );
            }
            return CustomInkWellContainer(
              onTap: () {
                final authStatus = context.read<AuthenticationCubit>().state;
                if (authStatus is UnAuthenticatedState) {
                  UiUtils.showAnimatedDialog(
                      context: context, child: const LogInAccountDialog());

                  return;
                }
                context
                    .read<UpdateProviderBookmarkStatusCubit>()
                    .bookmarkPartner(
                      providerData: providerData,
                      context: context,
                      providerId: providerData.providerId!,
                    );
              },
              child: CustomToolTip(
                toolTipMessage: "bookmark".translate(context: context),
                child: CustomSvgPicture(
                  svgImage: AppAssets.bookmark,
                  color: context.colorScheme.accentColor,
                ),
              ),
            );
          },
        ),
      );
}
