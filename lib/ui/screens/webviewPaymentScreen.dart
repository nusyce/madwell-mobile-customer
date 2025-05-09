// ignore_for_file: void_checks

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/generalImports.dart';

class WebviewPaymentScreen extends StatefulWidget {
  const WebviewPaymentScreen({required this.paymentUrl, final Key? key})
      : super(key: key);
  final String paymentUrl;

  static Route route(final RouteSettings settings) {
    final arguments = settings.arguments as Map;
    return CupertinoPageRoute(
      builder: (final context) =>
          WebviewPaymentScreen(paymentUrl: arguments['paymentURL']),
    );
  }

  @override
  State<WebviewPaymentScreen> createState() => _WebviewPaymentScreenState();
}

class _WebviewPaymentScreenState extends State<WebviewPaymentScreen> {
  DateTime? currentBackPressTime;
  late final WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(context.colorScheme.primaryContainer)
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (final progress) {
          // Update loading bar.
        },
        onPageStarted: (final url) {},
        onPageFinished: (String url) {},
        onWebResourceError: (final WebResourceError error) {},
        onNavigationRequest: (final request) {
          if (request.url.startsWith("${baseUrl}app_payment_status") ||
              request.url.startsWith("${baseUrl}app_paystack_payment_status") ||
              request.url.startsWith("${baseUrl}flutterwave_payment_status") ||
              request.url.startsWith(
                  '${context.read<SystemSettingCubit>().getPaymentMethodSettings().flutterwaveWebsiteUrl}/payment-status') ||
              request.url.startsWith(
                  '${context.read<SystemSettingCubit>().getPaymentMethodSettings().paypalWebsiteUrl}/payment-status')) {
            final url = request.url;
            if (url.contains('payment_status=Completed') ||
                url.contains('status=successful')) {
              Navigator.pop(context, {'paymentStatus': 'Completed'});
            } else if (url.contains('payment_status=Failed') ||
                url.contains('status=cancelled')) {
              Navigator.pop(context, {'paymentStatus': 'Failed'});
            }
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    )
    ..loadRequest(Uri.parse(widget.paymentUrl));

  @override
  Widget build(final BuildContext context) => Scaffold(
        body: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) {
              return;
            } else {
              final now = DateTime.now();
              if (currentBackPressTime == null ||
                  now.difference(currentBackPressTime!) >
                      const Duration(seconds: 2)) {
                currentBackPressTime = now;
                UiUtils.showMessage(
                  context,
                  "doNotPressBackWhilePaymentAndDoubleTapBackButtonToExit"
                      .translate(context: context),
                  ToastificationType.warning,
                );
                return;
              }
              Navigator.pop(context, {"paymentStatus": "Failed"});
            }
          },
          child: Scaffold(
            appBar: AppBar(
              systemOverlayStyle:
                  UiUtils.getSystemUiOverlayStyle(context: context),
              leading: CustomInkWellContainer(
                onTap: () async {
                  final DateTime now = DateTime.now();
                  if (currentBackPressTime == null ||
                      now.difference(currentBackPressTime!) >
                          const Duration(seconds: 2)) {
                    currentBackPressTime = now;
                    UiUtils.showMessage(
                      context,
                      'doNotPressBackWhilePaymentAndDoubleTapBackButtonToExit'
                          .translate(context: context),
                      ToastificationType.warning,
                    );

                    return Future.value(false);
                  }
                  Navigator.pop(context, {'paymentStatus': 'Failed'});
                  return Future.value(true);
                },
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Center(
                    child: CustomSvgPicture(
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
              title: CustomText("payment".translate(context: context),
                  color: context.colorScheme.blackColor),
              centerTitle: true,
              elevation: 1,
              backgroundColor: context.colorScheme.secondaryColor,
              surfaceTintColor: context.colorScheme.secondaryColor,
            ),
            body: WebViewWidget(controller: controller),
          ),
        ),
      );
}
