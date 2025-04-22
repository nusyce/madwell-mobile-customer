import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class ChatMessageSendingWidget extends StatelessWidget {
  final Function() onMessageSend;
  final Function() onAttachmentTap;
  final TextEditingController textController;

  const ChatMessageSendingWidget({
    super.key,
    required this.onMessageSend,
    required this.textController,
    required this.onAttachmentTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: context.colorScheme.secondaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onAttachmentTap,
            child: CustomContainer(
              shape: BoxShape.circle,
              color: context.colorScheme.secondaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: Offset.zero,
                  spreadRadius: 0,
                ),
              ],
              padding: const EdgeInsets.all(8),
              child: CustomSvgPicture(
                svgImage: AppAssets.addAttachment,
                boxFit: BoxFit.contain,
                width: 20,
                height: 20,
                color: context.colorScheme.lightGreyColor,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: CustomContainer(
              borderRadius: UiUtils.borderRadiusOf5,
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                controller: textController,
                maxLines: 5,
                minLines: 1,
                maxLength: UiUtils.maxCharactersInATextMessage,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "chatSendHint".translate(context: context),
                  counterText: "",
                  hintStyle: TextStyle(
                    color: context.colorScheme.secondary,
                    fontSize: 14,
                  ),
                ),
                onSubmitted: (value) {
                  onMessageSend();
                },
                cursorColor: context.colorScheme.secondary,
                style: TextStyle(
                  color: context.colorScheme.secondary,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          CustomInkWellContainer(
            onTap: onMessageSend,
            child: CustomContainer(
              borderRadius: 5,
              height: 48,
              width: 48,
              padding: const EdgeInsets.all(8),
              color: context.colorScheme.accentColor,
              child: const Center(
                child: CustomSvgPicture(
                  svgImage: AppAssets.sendMessage,
                  boxFit: BoxFit.contain,
                  width: 24,
                  height: 24,
                  color: AppColors.whiteColors,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
