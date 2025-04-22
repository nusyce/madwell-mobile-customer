import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/ui/widgets/categoryContainer.dart';
import 'package:flutter/material.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({required this.scrollController, final Key? key})
      : super(key: key);
  final ScrollController scrollController;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    Future.delayed(Duration.zero).then((final value) {
      fetchCategory();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void fetchCategory() {
    context.read<CategoryCubit>().getCategory();
  }

  @override
  Widget build(final BuildContext context) =>
      AnnotatedRegion<SystemUiOverlayStyle>(
        value: UiUtils.getSystemUiOverlayStyle(context: context),
        child: Scaffold(
          appBar: UiUtils.getSimpleAppBar(
            context: context,
            title: 'services'.translate(context: context),
            centerTitle: true,
            isLeadingIconEnable: false,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            elevation: 0.5,
          ),
          body: CustomContainer(
            color: context.colorScheme.primaryColor,
            child: CustomRefreshIndicator(
              displacment: 12,
              onRefreshCallback: () {
                fetchCategory();
              },
              child: BlocBuilder<CategoryCubit, CategoryState>(
                builder: (final BuildContext context,
                    final CategoryState categoryState) {
                  if (categoryState is CategoryFetchFailure) {
                    return ErrorContainer(
                      errorMessage: categoryState.errorMessage
                          .translate(context: context),
                      onTapRetry: fetchCategory,
                      showRetryButton: true,
                    );
                  } else if (categoryState is CategoryFetchSuccess) {
                    return categoryState.categoryList.isEmpty
                        ? NoDataFoundWidget(
                            titleKey:
                                'noServiceFound'.translate(context: context),
                            showRetryButton: true,
                            onTapRetry: () {
                              fetchCategory();
                            },
                          )
                        : _getCategoryList(
                            categoryList: categoryState.categoryList);
                  }

                  return _getCategoryShimmerEffect();
                },
              ),
            ),
          ),
        ),
      );

  Widget _getCategoryShimmerEffect() => GridView.builder(
        padding: const EdgeInsetsDirectional.only(start: 15, end: 15, top: 15),
        itemCount: UiUtils.numberOfShimmerContainer * 2,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (final context, final index) =>
            const CustomShimmerLoadingContainer(
          borderRadius: UiUtils.borderRadiusOf10,
        ),
      );

  Widget _getCategoryList({required final List<CategoryModel> categoryList}) =>
      GridView.builder(
        controller: widget.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding:
            EdgeInsets.fromLTRB(15, 15, 15, UiUtils.bottomNavigationBarHeight),
        itemCount: categoryList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (final BuildContext context, int index) {
          // final Color darkModeColor =
          //     categoryList[index].backgroundDarkColor == ""
          //         ? context.colorScheme.secondaryColor
          //         : categoryList[index].backgroundDarkColor!.toColor();
          // final Color lightModeColor =
          //     categoryList[index].backgroundLightColor == ""
          //         ? context.colorScheme.secondaryColor
          //         : categoryList[index].backgroundLightColor!.toColor();
          return CategoryContainer(
            imageURL: categoryList[index].categoryImage!,
            title: categoryList[index].name!,
            providers: categoryList[index].totalProviders!,
            imageContainerHeight: 65,
            imageContainerWidth: 65,
            textContainerHeight: 35,
            textContainerWidth: 65,
            cardWidth: 80,
            maxLines: 2,
            imageRadius: UiUtils.borderRadiusOf10,
            fontWeight: FontWeight.w500,
            darkModeBackgroundColor: categoryList[index].backgroundDarkColor,
            lightModeBackgroundColor: categoryList[index].backgroundLightColor,
            onTap: () {
              Navigator.pushNamed(
                context,
                subCategoryRoute,
                arguments: {
                  'categoryId': categoryList[index].id,
                  'appBarTitle': categoryList[index].name,
                  'type': CategoryType.category,
                },
              );
            },
          );
        },
      );
}
