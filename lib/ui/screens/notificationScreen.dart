import 'package:madwell/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({final Key? key}) : super(key: key);

  static Route route(final RouteSettings routeSettings) => CupertinoPageRoute(
        builder: (final _) => const NotificationScreen(),
      );

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  //
  final ScrollController _scrollController = ScrollController();

  void fetchNotifications() {
    context.read<NotificationsCubit>().fetchNotifications();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((final value) {
      fetchNotifications();
    });

    _scrollController.addListener(() {
      if (!context.read<NotificationsCubit>().hasMoreNotification()) {
        return;
      }
// nextPageTrigger will have a value equivalent to 70% of the list size.
      final nextPageTrigger = 0.7 * _scrollController.position.maxScrollExtent;

// _scrollController fetches the next paginated data when the current position of the user on the screen has surpassed
      if (_scrollController.position.pixels > nextPageTrigger) {
        if (mounted) {
          context.read<NotificationsCubit>().fetchMoreNotifications();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget notificationShimmerLoadingContainer(
          {required final int noOfShimmerContainer}) =>
      SingleChildScrollView(
        child: Column(
          children: List.generate(
            noOfShimmerContainer,
            (final int index) => Padding(
              padding: const EdgeInsets.all(8),
              child: CustomShimmerLoadingContainer(
                borderRadius: UiUtils.borderRadiusOf10,
                width: context.screenWidth,
                height: 92,
              ),
            ),
          ).toList(),
        ),
      );

  @override
  Widget build(final BuildContext context) => InterstitialAdWidget(
        child: Scaffold(
          backgroundColor: context.colorScheme.primaryColor,
          appBar: UiUtils.getSimpleAppBar(
            context: context,
            title: 'notification'.translate(context: context),
          ),
          bottomNavigationBar: const BannerAdWidget(),
          body: BlocBuilder<NotificationsCubit, NotificationsState>(
            builder:
                (final BuildContext context, final NotificationsState state) {
              //
              if (state is NotificationFetchFailure) {
                return ErrorContainer(
                  onTapRetry: () {
                    fetchNotifications();
                  },
                  errorMessage: state.errorMessage.translate(context: context),
                );
              }
              if (state is NotificationFetchSuccess) {
                return state.notificationsList.isEmpty
                    ? Center(
                        child: NoDataFoundWidget(
                          titleKey: 'noNotificationsFound'
                              .translate(context: context),
                        ),
                      )
                    : CustomRefreshIndicator(
                        displacment: 12,
                        onRefreshCallback: () {
                          fetchNotifications();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          controller: _scrollController,
                          shrinkWrap: true,
                          itemCount: state.notificationsList.length +
                              (state.isLoadingMoreData ? 1 : 0),
                          itemBuilder:
                              (final BuildContext context, final index) {
                            if (index >= state.notificationsList.length) {
                              return Center(
                                child: notificationShimmerLoadingContainer(
                                    noOfShimmerContainer: 1),
                              );
                            }
                            return BlocProvider(
                              create: (context) => DeleteNotificationCubit(),
                              child: CustomSlidableTileContainer(
                                onSlideTap: () {
                                  //TODO: add redirection from notifications
                                },
                                showBorder:
                                    state.notificationsList[index].isRead == "1"
                                        ? true
                                        : false,
                                imageURL: state.notificationsList[index].image
                                    .toString(),
                                title: state.notificationsList[index].title
                                    .toString(),
                                subTitle: state.notificationsList[index].message
                                    .toString(),
                                durationTitle: state
                                    .notificationsList[index].duration
                                    .toString(),
                                dateSent: state
                                    .notificationsList[index].dateSent
                                    .toString(),
                                tileBackgroundColor:
                                    state.notificationsList[index].isRead == "1"
                                        ? context.colorScheme.primaryColor
                                        : context.colorScheme.secondaryColor,
                                slidableChild: state
                                            .notificationsList[index].type !=
                                        'personal'
                                    ? null
                                    : BlocConsumer<DeleteNotificationCubit,
                                        DeleteNotificationsState>(
                                        listener: (final BuildContext context,
                                            final DeleteNotificationsState
                                                removeNotificationState) {
                                          if (removeNotificationState
                                              is DeleteNotificationSuccess) {
                                            UiUtils.showMessage(
                                              context,
                                              "notificationDeletedSuccessfully"
                                                  .translate(context: context),
                                              ToastificationType.success,
                                            );
                                            context
                                                .read<NotificationsCubit>()
                                                .removeNotificationFromList(
                                                  removeNotificationState
                                                      .notificationId,
                                                );
                                          } else if (removeNotificationState
                                              is DeleteNotificationFailure) {
                                            UiUtils.showMessage(
                                              context,
                                              removeNotificationState
                                                  .errorMessage
                                                  .translate(context: context),
                                              ToastificationType.error,
                                            );
                                          }
                                        },
                                        builder: (final BuildContext context,
                                            final DeleteNotificationsState
                                                removeNotificationState) {
                                          if (removeNotificationState
                                              is DeleteNotificationInProgress) {
                                            if (state.notificationsList[index]
                                                    .id ==
                                                removeNotificationState
                                                    .notificationId) {
                                              return Center(
                                                child: CustomContainer(
                                                  color: Colors.transparent,
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      CustomCircularProgressIndicator(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondaryColor,
                                                    strokeWidth: 2,
                                                  ),
                                                ),
                                              );
                                            }
                                          }

                                          return SlidableAction(
                                            backgroundColor: Colors.transparent,
                                            autoClose: false,
                                            onPressed: (final context) {
                                              context
                                                  .read<
                                                      DeleteNotificationCubit>()
                                                  .deleteNotification(
                                                    state
                                                        .notificationsList[
                                                            index]
                                                        .id
                                                        .toString(),
                                                  );
                                            },
                                            icon: Icons.delete,
                                            label: 'delete'
                                                .translate(context: context),
                                            borderRadius: BorderRadius.circular(
                                                UiUtils.borderRadiusOf10),
                                          );
                                        },
                                      ),
                              ),
                            );
                          },
                        ),
                      );
              }
              return notificationShimmerLoadingContainer(
                noOfShimmerContainer: UiUtils.numberOfShimmerContainer,
              );
            },
          ),
        ),
      );
}
