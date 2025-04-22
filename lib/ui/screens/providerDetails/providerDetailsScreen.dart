import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/ui/widgets/SliderPromoCode.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum ProviderDetailsParamType {
  slug,
  id;
}

class ProviderDetailsScreen extends StatefulWidget {
  const ProviderDetailsScreen(
      {required this.providerIDOrSlug, final Key? key, required this.type})
      : super(key: key);
  final String providerIDOrSlug;
  final ProviderDetailsParamType type;

  @override
  State<ProviderDetailsScreen> createState() => _ProviderDetailsScreenState();

  static Route route(final RouteSettings routeSettings) {
    final Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (final context) => BlocProvider(
        create: (context) => ProviderDetailsAndServiceCubit(
            ServiceRepository(), ProviderRepository()),
        child: ProviderDetailsScreen(
          providerIDOrSlug: arguments["providerId"],
          type: arguments['type'] ?? ProviderDetailsParamType.id,
        ),
      ),
    );
  }
}

class _ProviderDetailsScreenState extends State<ProviderDetailsScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  //
  late TabController _tabController = TabController(length: 2, vsync: this);

  List<String> tabLabels = ['services', 'about'];

  int selectedIndex = 0;

  //
  ScrollController _serviceListScrollController = ScrollController();

  //

  double? calculatedWidth;

  //
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero).then((final value) {
      fetchProviderDetailsAndServices();
   
    });



    //_serviceListScrollController.addListener(serviceListScrollController);
  }

  void serviceListScrollController() {
    if (mounted &&
        !context.read<ProviderDetailsAndServiceCubit>().hasMoreServices()) {
      return;
    }
// nextPageTrigger will have a value equivalent to 70% of the list size.
    final nextPageTrigger =
        0.7 * _serviceListScrollController.position.maxScrollExtent;

// _scrollController fetches the next paginated data when the current position of the user on the screen has surpassed
    if (_serviceListScrollController.position.pixels > nextPageTrigger) {
      if (mounted) {
        context.read<ProviderDetailsAndServiceCubit>().fetchMoreServices(
            providerId: widget.providerIDOrSlug, type: widget.type);
      }
    }
  }


  void fetchProviderDetailsAndServices() {
    context
        .read<ProviderDetailsAndServiceCubit>()
        .fetchProviderDetailsAndServices(
            providerId: widget.providerIDOrSlug,
            promocode: "1",
            type: widget.type);
    context
        .read<ReviewCubit>()
        .fetchReview(providerId: widget.providerIDOrSlug, type: widget.type);
  }

  Widget providerDetailsScreenShimmerLoading() => SingleChildScrollView(
        child: Column(
          children: [
            CustomShimmerLoadingContainer(
              height: context.screenHeight * 0.4,
              width: context.screenWidth,
            ),
            const CustomShimmerLoadingContainer(
              borderRadius: 0,
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              height: 50,
            ),
            Column(
              children: List.generate(
                UiUtils.numberOfShimmerContainer,
                (final int index) => const CustomShimmerLoadingContainer(
                  height: 150,
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                ),
              ),
            )
          ],
        ),
      );

  Widget profileView(ProviderDetailsAndServiceFetchSuccess state,
      double providerContainerHight) {
    return CustomContainer(
      padding: const EdgeInsetsDirectional.all(8),
      width: calculatedWidth,
      height: providerContainerHight,
      color: context.colorScheme.secondaryColor,
      borderRadius: UiUtils.borderRadiusOf8,
      clipBehavior: Clip.antiAlias,
      // border: Border.all(color: Colors.black),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
              flex: 1,
              child: CustomImageContainer(
                borderRadius: UiUtils.borderRadiusOf8,
                imageURL: state.providerDetails.image!,
                height: 80,
                width: 80,
                boxFit: BoxFit.fill,
                boxShadow: [],
              )),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            state.providerDetails.companyName!,
                            fontSize: 16,
                            maxLines: 1,
                            color: context.colorScheme.blackColor,
                            fontWeight: FontWeight.w600,
                          ),
                          CustomText(
                            '${state.providerDetails.totalServices!} ${state.providerDetails.totalServices!.toInt() < 1 ? 'service'.translate(context: context) : 'services'.translate(context: context)}',
                            fontSize: 14,
                            maxLines: 1,
                            color: context.colorScheme.blackColor,
                            fontWeight: FontWeight.w200,
                          ),
                        ],
                      ),
                    ),
                    BookMarkIcon(
                      providerData: state.providerDetails,
                    )
                  ],
                ),
                IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // crossAxisAlignment:
                    //     CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CustomSvgPicture(
                            svgImage: AppAssets.currentLocation,
                            height: 16,
                            width: 16,
                            color: context.colorScheme.accentColor,
                          ),
                          const SizedBox(width: 5),
                          CustomText(
                            "${double.parse(state.providerDetails.distance!).ceil()} ${UiUtils.distanceUnit}",
                            fontSize: 14,
                            color: context.colorScheme.blackColor,
                            fontWeight: FontWeight.w600,
                          ),
                          if (state.providerDetails.ratings! != '0.0')
                            VerticalDivider(
                              color: context.colorScheme.lightGreyColor,
                              thickness: 0.2,
                            ),
                          if (state.providerDetails.ratings! != '0.0')
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  reviewScreen,
                                  arguments: {
                                    'providerDetails': state.providerDetails,
                                  },
                                );
                              },
                              child: Row(
                                children: [
                                  const CustomSvgPicture(
                                    svgImage: AppAssets.icStar,
                                    height: 16,
                                    width: 16,
                                    color: AppColors.ratingStarColor,
                                  ),
                                  const SizedBox(width: 5),
                                  CustomText(
                                    double.parse(state.providerDetails.ratings!)
                                        .toString(),
                                    fontSize: 14,
                                    color: context.colorScheme.blackColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ],
                              ),
                            )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _serviceListScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    calculatedWidth =
        context.screenWidth - 2 * ((context.screenWidth * 0.15) - 45);

    super.build(context);
    return Scaffold(
      bottomNavigationBar: const BannerAdWidget(),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (final BuildContext context, final CartState state) =>
            BlocBuilder<ProviderDetailsAndServiceCubit,
                ProviderDetailsAndServiceState>(
          builder: (final context, final state) {
            if (state is ProviderDetailsAndServiceFetchFailure) {
              return Center(
                child: ErrorContainer(
                  onTapRetry: () {
                    fetchProviderDetailsAndServices();
                  },
                  errorMessage: state.errorMessage.translate(context: context),
                ),
              );
            } else if (state is ProviderDetailsAndServiceFetchSuccess) {
              final double appbarimageContainerHight =
                  context.screenHeight * 0.27;
              const double providerContainerHight = 90;
              final double promocodeHight =
                  state.providerDetails.promocode!.length == 1
                      ? 110
                      : state.providerDetails.promocode!.isNotEmpty
                          ? 130
                          : 10;
              return Stack(
                children: [
                  NestedScrollView(
                    controller: _serviceListScrollController,
                    headerSliverBuilder: (final BuildContext context,
                            final bool innerBoxIsScrolled) =>
                        <Widget>[
                      SliverLayoutBuilder(
                        builder: (context, constraints) {
                          return SliverAppBar(
                            title: constraints.scrollOffset >= 150
                                ? CustomText(
                                    state.providerDetails.companyName!,
                                    color: context.colorScheme.blackColor,
                                  )
                                : const SizedBox.shrink(),
                            leading: CustomContainer(
                              margin: const EdgeInsetsDirectional.only(
                                end: 10,
                                top: 10,
                                bottom: 10,
                                start: 10,
                              ),
                              color: context.colorScheme.secondaryColor
                                  .withValues(alpha: 0.5),
                              borderRadius: UiUtils.borderRadiusOf8,
                              child: CustomInkWellContainer(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                borderRadius: BorderRadius.circular(
                                    UiUtils.borderRadiusOf8),
                                child: Padding(
                                  padding:
                                      const EdgeInsetsDirectional.symmetric(
                                          horizontal: 5),
                                  child: CustomSvgPicture(
                                    svgImage: Directionality.of(context)
                                            .toString()
                                            .contains(TextDirection.RTL.value
                                                .toLowerCase())
                                        ? AppAssets.backArrowLtr
                                        : AppAssets.backArrow,
                                    color: context.colorScheme.accentColor,
                                  ),
                                ),
                              ),
                            ),
                            bottom: PreferredSize(
                              preferredSize: const Size(double.infinity, 50),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: context.colorScheme.secondaryColor,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(
                                        constraints.scrollOffset >= 150
                                            ? 0
                                            : UiUtils.borderRadiusOf10),
                                    topRight: Radius.circular(
                                        constraints.scrollOffset >= 150
                                            ? 0
                                            : UiUtils.borderRadiusOf10),
                                  ),
                                ),
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 8,
                                      child: TabBar(
                                        onTap: (value) {
                                          setState(() {
                                            selectedIndex = value;
                                          });
                                        },
                                        controller: _tabController,
                                        isScrollable: false,
                                        dividerColor: Colors.transparent,
                                        padding: const EdgeInsets.only(
                                          right: 5,
                                        ),
                                        labelPadding: const EdgeInsets.all(2),
                                        indicatorColor: Colors.transparent,
                                        labelStyle: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                        unselectedLabelStyle: const TextStyle(
                                            fontWeight: FontWeight.normal),
                                        tabs: tabLabels.map((e) {
                                          final int index = tabLabels.indexOf(
                                              e); // Get the index of the current tab
                                          return Tab(
                                            child: CustomContainer(
                                              height: 40,
                                              borderRadius:
                                                  UiUtils.borderRadiusOf8,
                                              color: selectedIndex == index
                                                  ? context
                                                      .colorScheme.accentColor
                                                  : context
                                                      .colorScheme.primaryColor,
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 2),
                                              child: CustomText(
                                                e.translate(context: context),
                                                color: selectedIndex == index
                                                    ? AppColors.whiteColors
                                                    : context
                                                        .colorScheme.blackColor,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    BlocBuilder<UserDetailsCubit,
                                            UserDetailsState>(
                                        builder: (context, userDetails) {
                                      final token = HiveRepository.getUserToken;
                                      return Expanded(
                                        flex: state.providerDetails
                                                        .isPreBookingChatAllowed ==
                                                    "1" &&
                                                token != ""
                                            ? 3
                                            : 2,
                                        child: Row(
                                          children: [
                                            CustomToolTip(
                                              toolTipMessage: "share"
                                                  .translate(context: context),
                                              child: CustomContainer(
                                                height: 40,
                                                width: 40,
                                                margin:
                                                    const EdgeInsetsDirectional
                                                        .only(
                                                  top: 10,
                                                  bottom: 10,
                                                ),
                                                color: context
                                                    .colorScheme.accentColor
                                                    .withAlpha(20),
                                                borderRadius:
                                                    UiUtils.borderRadiusOf5,
                                                child: CustomInkWellContainer(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          UiUtils
                                                              .borderRadiusOf5),
                                                  onTap: () =>
                                                      _handleShareButtonClick(
                                                    providerDetails:
                                                        state.providerDetails,
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsetsDirectional
                                                            .all(10),
                                                    child: CustomSvgPicture(
                                                      svgImage:
                                                          AppAssets.shareSp,
                                                      color: context.colorScheme
                                                          .accentColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const CustomSizedBox(
                                              width: 10,
                                            ),
                                            if (state.providerDetails
                                                        .isPreBookingChatAllowed ==
                                                    "1" &&
                                                token != "") ...[
                                              CustomInkWellContainer(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        UiUtils
                                                            .borderRadiusOf5),
                                                onTap: () {
                                                  Navigator.pushNamed(
                                                      context, chatMessages,
                                                      arguments: {
                                                        "chatUser": ChatUser(
                                                          id: state
                                                                  .providerDetails
                                                                  .providerId ??
                                                              "-",
                                                          name: state
                                                              .providerDetails
                                                              .companyName
                                                              .toString(),
                                                          receiverType: "1",
                                                          bookingId: "0",
                                                          providerId: state
                                                              .providerDetails
                                                              .providerId,
                                                          // 1 = provider
                                                          unReadChats: 0,
                                                          profile: state
                                                              .providerDetails
                                                              .image,
                                                          senderId: context
                                                                  .read<
                                                                      UserDetailsCubit>()
                                                                  .getUserDetails()
                                                                  .id ??
                                                              "0",
                                                        ),
                                                      });
                                                },
                                                child: CustomContainer(
                                                  height: 40,
                                                  width: 40,
                                                  margin:
                                                      const EdgeInsetsDirectional
                                                          .only(
                                                    top: 10,
                                                    bottom: 10,
                                                  ),
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 10),
                                                  color: context
                                                      .colorScheme.accentColor
                                                      .withAlpha(20),
                                                  borderRadius:
                                                      UiUtils.borderRadiusOf5,
                                                  child: CustomSvgPicture(
                                                    svgImage: AppAssets.drChat,
                                                    color: context.colorScheme
                                                        .accentColor,
                                                  ),
                                                ),
                                              ),
                                            ]
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                            systemOverlayStyle: const SystemUiOverlayStyle(
                                statusBarColor: Colors.transparent),
                            pinned: true,
                            elevation: 0,
                            surfaceTintColor:
                                context.colorScheme.secondaryColor,
                            expandedHeight: appbarimageContainerHight +
                                (providerContainerHight / 2) +
                                promocodeHight +
                                30,
                            backgroundColor: constraints.scrollOffset >= 150
                                ? context.colorScheme.secondaryColor
                                : context.colorScheme.primaryColor,
                            actions: [
                              if (constraints.scrollOffset >= 150)
                                CustomContainer(
                                  height: 40,
                                  width: 40,
                                  padding:
                                      const EdgeInsetsDirectional.symmetric(
                                          horizontal: 10, vertical: 10),
                                  color: context.colorScheme.secondaryColor,
                                  borderRadius: UiUtils.borderRadiusOf5,
                                  child: BookMarkIcon(
                                    providerData: state.providerDetails,
                                  ),
                                )
                            ],
                            flexibleSpace: FlexibleSpaceBar(
                              collapseMode: CollapseMode.pin,
                              stretchModes: const [StretchMode.zoomBackground],
                              background: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: appbarimageContainerHight +
                                        (providerContainerHight / 2),
                                    width: double.maxFinite,
                                    child: Stack(
                                      alignment: Alignment.topCenter,
                                      children: [
                                        CustomSizedBox(
                                          width: context.screenWidth,
                                          height: appbarimageContainerHight,
                                          child: CustomCachedNetworkImage(
                                            networkImageUrl: state
                                                .providerDetails.bannerImage!,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: profileView(
                                              state, providerContainerHight),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (state
                                      .providerDetails.promocode!.isNotEmpty)
                                    CustomContainer(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      width: calculatedWidth,
                                      child: SliderPromocode(
                                          height: 80,
                                          promocode:
                                              state.providerDetails.promocode!,
                                          calculatedWidth: calculatedWidth!),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    body: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: _tabController,
                      children: [
                        ProviderServicesContainer(
                          isProviderAvailableAtLocation:
                              state.providerDetails.isAvailableAtLocation!,
                          servicesList: state.serviceList,
                          providerID: state.providerDetails.providerId ?? "0",
                          isLoadingMoreData: state.isLoadingMoreServices,
                        ),
                        AboutProviderContainer(
                            providerDetails: state.providerDetails)
                      ],
                    ),
                  ),
                  if ((context.watch<CartCubit>().state is CartFetchSuccess) &&
                      (context.watch<CartCubit>().state as CartFetchSuccess)
                              .cartData
                              .providerId ==
                          widget.providerIDOrSlug)
                    const PositionedDirectional(
                        start: 0,
                        end: 0,
                        bottom: 0,
                        child: AddToCartComtainer()),
                  if (context.watch<CartCubit>().state is CartFetchSuccess &&
                      ((context.watch<CartCubit>().state as CartFetchSuccess)
                                  .cartData
                                  .cartDetails ??
                              [])
                          .isNotEmpty &&
                      ((context.watch<CartCubit>().state as CartFetchSuccess)
                              .cartData
                              .providerId !=
                          widget.providerIDOrSlug)) ...[
                    PositionedDirectional(
                      start: 0,
                      end: 0,
                      bottom: 0,
                      child: CartSubDetailsContainer(
                        providerID: state.providerDetails.providerId,
                      ),
                    ),
                  ],
                ],
              );
            }
            return providerDetailsScreenShimmerLoading();
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _handleShareButtonClick(
      {required Providers providerDetails}) async {
    final box = context.findRenderObject() as RenderBox?;

    final sharePositionOrigin = box!.localToGlobal(Offset.zero) & box.size;

    //
    final String shareURL =
        'https://$domain/provider-details/${providerDetails.slug}?share=true';

    await Share.share(
      shareURL,
      subject: "Share Provider",
      sharePositionOrigin: sharePositionOrigin,
    );
  }
}

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => max(maxHeight, minHeight);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
