import 'package:madwell/app/generalImports.dart';
import 'package:flutter/material.dart';

class MyRequestListScreen extends StatefulWidget {
  const MyRequestListScreen({required this.scrollController, final Key? key})
      : super(key: key);
  final ScrollController scrollController;

  @override
  State<MyRequestListScreen> createState() => _MyRequestListScreenState();
}

class _MyRequestListScreenState extends State<MyRequestListScreen> {
  @override
  void initState() {
    Future.delayed(Duration.zero).then((final value) {
      fetchMyRequestList();
    });
  /*  WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchMyRequestList();
    });*/
    widget.scrollController.addListener(fetchMoreRequestDetails);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void fetchMoreRequestDetails() {
    if (mounted && !context.read<MyRequestListCubit>().hasMoreReq()) {
      return;
    }
// nextPageTrigger will have a value equivalent to 70% of the list size.
    final nextPageTrigger =
        0.7 * widget.scrollController.position.maxScrollExtent;

// _scrollController fetches the next paginated data when the current position of the user on the screen has surpassed
    if (widget.scrollController.position.pixels > nextPageTrigger) {
      if (mounted) {
        context.read<MyRequestListCubit>().fetchMoreReq();
      }
    }
  }

  void fetchMyRequestList() {
    context.read<MyRequestListCubit>().fetchRequests();
  }

  @override
  Widget build(final BuildContext context) =>
      AnnotatedRegion<SystemUiOverlayStyle>(
        value: UiUtils.getSystemUiOverlayStyle(context: context),
        child: Scaffold(
          appBar: UiUtils.getSimpleAppBar(
            context: context,
            title: 'myRequest'.translate(context: context),
            centerTitle: true,
            isLeadingIconEnable: false,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            elevation: 0.5,
          ),
          body: CustomRefreshIndicator(
            displacment: 12,
            onRefreshCallback: () {
              fetchMyRequestList();
            },
            child: BlocBuilder<MyRequestListCubit, MyRequestListState>(
                builder: (context, state) {
              if (HiveRepository.getUserToken == "") {
                return ErrorContainer(
                  errorTitle: 'youAreNotLoggedIn'.translate(context: context),
                  errorMessage: 'pleaseLoginToSeeYourRequests'
                      .translate(context: context),
                  showRetryButton: true,
                  buttonName: 'login'.translate(context: context),
                  onTapRetry: () {
                    //passing source as dialog instead of booking
                    //because there is no condition added for booking so using dialog,
                    Navigator.pushNamed(context, loginRoute,
                        arguments: {'source': 'dialog'});
                  },
                );
              }
              if (state is MyRequestListInProgress) {
                return _getLoadingShimmerEffect();
              }
              if (state is MyRequestListFailure) {
                return ErrorContainer(
                  errorMessage: state.errorMessage.translate(context: context),
                  onTapRetry: fetchMyRequestList,
                  showRetryButton: true,
                );
              }
              if (state is MyRequestListSuccess) {
                if (state.requestList.isEmpty) {
                  return Stack(
                    children: [
                      NoDataFoundWidget(
                        titleKey:
                            'noServiceRequested'.translate(context: context),
                        showRetryButton: true,
                        onTapRetry: fetchMyRequestList,
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: CustomContainer(
                          height: kBottomNavigationBarHeight,
                          width: context.screenWidth,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          margin: EdgeInsets.only(
                              bottom: Platform.isIOS ? kBottomNavigationBarHeight + 40
                               : kBottomNavigationBarHeight),
                          child: CustomRoundedButton(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                requestServiceFormScreen,
                              );
                            },
                            buttonTitle:
                                'requestService'.translate(context: context),
                            showBorder: false,
                            widthPercentage: .95,
                            backgroundColor: context.colorScheme.accentColor,
                            textSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return Stack(
                  children: [
                    _getMyRequestList(
                        myRequestList: state.requestList,
                        isLoadingMoreError: state.isLoadingMoreError),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: CustomContainer(
                        height: kBottomNavigationBarHeight,
                        width: context.screenWidth,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        margin: EdgeInsets.only(
                            bottom: Platform.isIOS ? kBottomNavigationBarHeight + 40
                               : kBottomNavigationBarHeight),
                        child: CustomRoundedButton(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              requestServiceFormScreen,
                            );
                          },
                          buttonTitle:
                              'requestService'.translate(context: context),
                          showBorder: false,
                          widthPercentage: .95,
                          backgroundColor: context.colorScheme.accentColor,
                          textSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const CustomSizedBox();
            }),
          ),
        ),
      );

  Widget _getMyRequestList({
    required final List<MyRequestListModel> myRequestList,
    required final bool isLoadingMoreError,
  }) =>
      ListView.builder(
        controller: widget.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
            15, 15, 15, UiUtils.bottomNavigationBarHeight * 2),
        itemCount: myRequestList.length,
        itemBuilder: (final BuildContext context, int index) {
          if (index >= myRequestList.length) {
            return CustomContainer(
              margin: const EdgeInsetsDirectional.only(
                  bottom: kBottomNavigationBarHeight * 2),
              child: CustomLoadingMoreContainer(
                isError: isLoadingMoreError,
                onErrorButtonPressed: () {
                  fetchMoreRequestDetails();
                },
              ),
            );
          }
          return MyRequestCardContainer(
            myRequestDetails: myRequestList[index],
          );
        },
      );

  Widget _getLoadingShimmerEffect() => ListView.builder(
        controller: widget.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
        itemCount: 10,
        itemBuilder: (final BuildContext context, int index) {
          return CustomShimmerLoadingContainer(
            borderRadius: 10,
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: context.screenWidth * 0.9,
            height: context.screenHeight * 0.24,
          );
        },
      );
}
