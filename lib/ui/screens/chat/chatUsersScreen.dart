import 'package:madwell/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatUsersScreen extends StatefulWidget {
  const ChatUsersScreen({
    super.key,
  });

  @override
  State<ChatUsersScreen> createState() => _ChatUsersScreenState();

  static Route route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => const ChatUsersScreen(),
    );
  }
}

class _ChatUsersScreenState extends State<ChatUsersScreen>
    with TickerProviderStateMixin {
  final List<String> statuses = ['all', 'confirmed', 'started', 'completed'];
  String selectedStatus = "all";
  late TabController _tabController;
  final List<String> typeStatuses = ['enquiryChats', 'bookingChats'];
  String selectedTypeStatus = "enquiryChats";
  late TabController _typetabController;

  late final ScrollController _scrollController = ScrollController()
    ..addListener(_chatUserScrollListener);

  void _chatUserScrollListener() {
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent) {
      if (context.read<ChatUsersCubit>().hasMore()) {
        context.read<ChatUsersCubit>().fetchMoreChatUsers(
            orderStatus: selectedStatus, filterType: selectedTypeStatus);
      }
    }
  }

  @override
  void initState() {
    _tabController = TabController(
      length: statuses.length,
      vsync: this,
    );
    _typetabController =
        TabController(length: typeStatuses.length, vsync: this);
    Future.delayed(Duration.zero, () {
      fetchChatUsers();
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_chatUserScrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void fetchChatUsers() {
    context.read<ChatUsersCubit>().fetchChatUsers(
        orderStatus: selectedStatus, filterType: selectedTypeStatus);
  }

  Widget _buildFilterButton(
      {required String svg,
      required String text,
      Color? bgColor,
      Color? svgColor}) {
    return CustomContainer(
      height: 40,
      borderRadius: UiUtils.borderRadiusOf6,
      gradient: bgColor != null
          ? null
          : LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [
                context.colorScheme.accentColor.withValues(alpha: .5),
                context.colorScheme.accentColor.withValues(alpha: .3),
                context.colorScheme.accentColor.withValues(alpha: .1),
                context.colorScheme.accentColor.withValues(alpha: .0),
              ],
            ),
      padding: const EdgeInsets.all(1),
      child: CustomContainer(
        color: context.colorScheme.accentColor.withValues(alpha: .01),
        borderRadius: UiUtils.borderRadiusOf6,
        child: CustomContainer(
          alignment: Alignment.center,
          borderRadius: UiUtils.borderRadiusOf6,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          gradient: bgColor != null
              ? null
              : LinearGradient(
                  begin: AlignmentDirectional.centerStart,
                  end: AlignmentDirectional.centerEnd,
                  colors: [
                    context.colorScheme.secondaryColor.withAlpha(255),
                    context.colorScheme.secondaryColor.withAlpha(100),
                    context.colorScheme.accentColor.withValues(alpha: .01),
                  ],
                ),
          child: Row(
            children: [
              CustomSvgPicture(
                svgImage: svg,
                color: svgColor,
              ),
              const CustomSizedBox(width: 10),
              CustomText(
                text,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return LayoutBuilder(
      builder: (context, boxConstraints) {
        return SizedBox(
          height: double.maxFinite,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: UiUtils.numberOfShimmerContainer,
            itemBuilder: (context, index) {
              return _buildOneChatUserShimmerLoader();
            },
          ),
        );
      },
    );
  }

  Widget _buildOneChatUserShimmerLoader() {
    return const Padding(
      padding: EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: CustomShimmerLoadingContainer(
        height: 80,
        borderRadius: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InterstitialAdWidget(
      child: Scaffold(
        appBar: AppBar(
            centerTitle: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  'chat'.translate(context: context),
                  color: context.colorScheme.blackColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
                context.watch<ChatUsersCubit>().state is ChatUsersFetchSuccess
                    ? HeadingAmountAnimation(
                        key: ValueKey((context.read<ChatUsersCubit>().state
                                as ChatUsersFetchSuccess)
                            .totalOffset),
                        text:
                            '${(context.read<ChatUsersCubit>().state as ChatUsersFetchSuccess).totalOffset.toString()} ${'chats'.translate(context: context)}',
                        textStyle: TextStyle(
                          color: context.colorScheme.lightGreyColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      )
                    : CustomSizedBox(
                        width: context.screenWidth * 0.7,
                        height: context.screenHeight * 0.02,
                      )
              ],
            ),
            elevation: 1,
            shadowColor: context.colorScheme.lightGreyColor,
            surfaceTintColor: context.colorScheme.secondaryColor,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Center(
                  child: CustomSvgPicture(
                    width: 56,
                    svgImage: Directionality.of(context)
                            .toString()
                            .contains(TextDirection.RTL.value.toLowerCase())
                        ? AppAssets.backArrowLtr
                        : AppAssets.backArrow,
                    color: context.colorScheme.accentColor,
                  ),
                ),
              ),
            ),
            backgroundColor: context.colorScheme.secondaryColor,
            bottom: selectedTypeStatus == "enquiryChats"
                ? null
                : TabBar(
                    indicatorColor: Colors.transparent,
                    labelPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    tabAlignment: TabAlignment.start,
                    indicatorPadding: const EdgeInsets.symmetric(vertical: 5),
                    indicatorSize: TabBarIndicatorSize.label,
                    overlayColor:
                        const WidgetStatePropertyAll(Colors.transparent),
                    indicator: BoxDecoration(
                        color: context.colorScheme.accentColor,
                        borderRadius: const BorderRadius.all(
                            Radius.circular(UiUtils.borderRadiusOf6))),
                    controller: _tabController,
                    labelColor: context.colorScheme.accentColor,
                    unselectedLabelColor: context.colorScheme.blackColor,
                    tabs: statuses.map((status) {
                      final bool isSelected = status == selectedStatus;
                      return Tab(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18.0, vertical: 0),
                          child: CustomText(
                            status.translate(context: context),
                            textAlign: TextAlign.center,
                            color: isSelected
                                ? context.colorScheme.secondaryColor
                                : context.colorScheme.blackColor,
                            // fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                    onTap: (index) {
                      setState(() {
                        selectedStatus = statuses[index];
                      });
                      fetchChatUsers();
                    },
                    isScrollable: true,
                  ),
            actions: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 15),
                child: CustomToolTip(
                  toolTipMessage: "customerSupport".translate(context: context),
                  child: CustomInkWellContainer(
                    onTap: () {
                      Navigator.pushNamed(context, chatMessages, arguments: {
                        "chatUser": ChatUser(
                          id: "-",
                          name: "customerSupport".translate(context: context),
                          receiverType: "0",
                          senderType: "0",
                          unReadChats: 0,
                          bookingId: "-1",
                          senderId: context
                                  .read<UserDetailsCubit>()
                                  .getUserDetails()
                                  .id ??
                              "0",
                        ),
                      });
                    },
                    child: _buildFilterButton(
                      svg: AppAssets.support,
                      text: 'support'.translate(context: context),
                    ),
                  ),
                ),
              )
            ]),
        bottomNavigationBar: const BannerAdWidget(),
        body: Stack(
          children: [
            BlocBuilder<ChatUsersCubit, ChatUsersState>(
              builder: (context, state) {
                if (state is ChatUsersFetchSuccess) {
                  return state.chatUsers.isEmpty
                      ? Center(
                          child: NoDataFoundWidget(
                            titleKey:
                                "noChatsFound".translate(context: context),
                          ),
                        )
                      : CustomRefreshIndicator(
                          displacment: 12,
                          onRefreshCallback: () {
                            fetchChatUsers();
                          },
                          child: SizedBox(
                            height: double.maxFinite,
                            width: double.maxFinite,
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                children: [
                                  ...List.generate(
                                    state.chatUsers.length,
                                    (index) {
                                      final currentChatUser =
                                          state.chatUsers[index];

                                      return ChatUserItemWidget(
                                        chatUser: currentChatUser.copyWith(
                                          receiverType: "1",
                                          unReadChats: 0,
                                          id: state.chatUsers[index].providerId,
                                          bookingId: state
                                              .chatUsers[index].bookingId
                                              .toString(),
                                          bookingStatus: state
                                              .chatUsers[index].bookingStatus
                                              .toString()
                                              .translate(context: context),
                                          name: state.chatUsers[index].name
                                              .toString(),
                                          profile:
                                              state.chatUsers[index].profile,
                                          senderId: context
                                                  .read<UserDetailsCubit>()
                                                  .getUserDetails()
                                                  .id ??
                                              "0",
                                        ),
                                      );
                                    },
                                  ),
                                  if (state.moreChatUserFetchProgress)
                                    _buildOneChatUserShimmerLoader(),
                                  if (state.moreChatUserFetchError &&
                                      !state.moreChatUserFetchProgress)
                                    CustomLoadingMoreContainer(
                                      isError: true,
                                      onErrorButtonPressed: () {
                                        context
                                            .read<ChatUsersCubit>()
                                            .fetchMoreChatUsers(
                                                orderStatus: selectedStatus,
                                                filterType: selectedTypeStatus);
                                      },
                                    ),
                                  const SizedBox(
                                    height: 80,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                }
                if (state is ChatUsersFetchFailure) {
                  return Center(
                    child: ErrorContainer(
                      errorMessage: state.errorMessage,
                      onTapRetry: () {
                        fetchChatUsers();
                      },
                    ),
                  );
                }
                return _buildShimmerLoader();
              },
            ),
            Padding(
              padding: const EdgeInsets.only(
                  // bottom: UiUtils.bottomNavigationBarHeight,
                  bottom: 10,
                  right: 30,
                  left: 30),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: CustomContainer(
                  color: context.colorScheme.secondaryColor,
                  borderRadius: UiUtils.borderRadiusOf50,
                  border: Border.all(color: context.colorScheme.primaryColor),
                  child: TabBar(
                    indicatorColor: Colors.transparent,
                    labelPadding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    indicatorPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    indicatorSize: TabBarIndicatorSize.tab,
                    overlayColor:
                        const WidgetStatePropertyAll(Colors.transparent),
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                        color: context.colorScheme.accentColor,
                        borderRadius: const BorderRadius.all(
                            Radius.circular(UiUtils.borderRadiusOf50))),
                    controller: _typetabController,
                    labelColor: context.colorScheme.accentColor,
                    unselectedLabelColor: context.colorScheme.blackColor,

                    tabs: typeStatuses.map((status) {
                      final bool isSelected = status == selectedTypeStatus;
                      return Tab(
                        child: CustomContainer(
                          child: CustomText(
                            status.translate(context: context),
                            textAlign: TextAlign.center,
                            color: isSelected
                                ? context.colorScheme.secondaryColor
                                : context.colorScheme.blackColor,
                          ),
                        ),
                      );
                    }).toList(),
                    onTap: (index) {
                      setState(() {
                        selectedTypeStatus = typeStatuses[index];
                      });
                      fetchChatUsers();
                    },
                    isScrollable: false,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
