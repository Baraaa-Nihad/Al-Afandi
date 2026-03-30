import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:ovoride/core/helper/date_converter.dart';
import 'package:ovoride/core/utils/app_status.dart';
import 'package:ovoride/core/utils/my_icons.dart';
import 'package:ovoride/core/utils/style.dart';
import 'package:ovoride/data/controller/rider/map/ride_map_controller.dart';
import 'package:ovoride/data/controller/rider/pusher/pusher_ride_controller.dart';
import 'package:ovoride/data/controller/rider/ride/ride_details/ride_details_controller.dart';
import 'package:ovoride/data/controller/rider/ride/ride_meassage/ride_meassage_controller.dart';
import 'package:ovoride/data/model/global/app/ride_meassage_model.dart';
import 'package:ovoride/data/repo/rider/message/message_repo.dart';
import 'package:ovoride/data/repo/rider/ride/ride_repo.dart';
import 'package:ovoride/presentation/components/annotated_region/annotated_region_widget.dart';
import 'package:ovoride/presentation/components/app-bar/custom_appbar.dart';
import 'package:ovoride/presentation/components/custom_loader/custom_loader.dart';
import 'package:ovoride/presentation/components/divider/custom_spacer.dart';
import 'package:ovoride/presentation/components/image/my_local_image_widget.dart';
import 'package:ovoride/presentation/components/image/my_network_image_widget.dart';
import 'package:ovoride/presentation/components/text/header_text.dart';
import 'package:ovoride/presentation/packages/flutter_chat_bubble/chat_bubble.dart';

import 'package:ovoride/core/route/route.dart';
import 'package:ovoride/core/utils/dimensions.dart';
import 'package:ovoride/core/utils/my_animation.dart';
import 'package:ovoride/core/utils/my_color.dart';
import 'package:ovoride/core/utils/my_strings.dart';

class RideMessageScreen extends StatefulWidget {
  String rideID;
  RideMessageScreen({super.key, required this.rideID});

  @override
  State<RideMessageScreen> createState() => _RideMessageScreenState();
}

class _RideMessageScreenState extends State<RideMessageScreen> {
  String riderName = "";
  String riderStatus = "";

  @override
  void initState() {
    widget.rideID = Get.arguments?[0] ?? -1;
    riderName = Get.arguments?[1] ?? MyStrings.inbox.tr;
    riderStatus = Get.arguments?[2] ?? "-1";
    if (!Get.isRegistered<MessageRepo>(tag: 'rider')) {
      Get.put(MessageRepo(apiClient: Get.find()), tag: 'rider');
    }
    if (!Get.isRegistered<RideRepo>(tag: 'rider')) {
      Get.put(RideRepo(apiClient: Get.find()), tag: 'rider');
    }
    if (!Get.isRegistered<RideMapController>(tag: 'rider')) {
      Get.put(RideMapController(), tag: 'rider');
    }
    if (!Get.isRegistered<RideDetailsController>(tag: 'rider')) {
      Get.put(
        RideDetailsController(
          repo: Get.find(tag: 'rider'),
          mapController: Get.find(tag: 'rider'),
        ),
        tag: 'rider',
      );
    }
    final controller = Get.isRegistered<RideMessageController>(tag: 'rider') ? Get.find<RideMessageController>(tag: 'rider') : Get.put(RideMessageController(repo: Get.find(tag: 'rider')), tag: 'rider');
    if (!Get.isRegistered<PusherRideController>(tag: 'rider')) {
      Get.put(
        PusherRideController(
          apiClient: Get.find(),
          rideMessageController: Get.find(tag: 'rider'),
          rideDetailsController: Get.find(tag: 'rider'),
          rideID: widget.rideID,
        ),
        tag: 'rider',
      );
    }
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((time) {
      controller.initialData(widget.rideID);
      controller.updateCount(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    getSenderView(
      CustomClipper clipper,
      BuildContext context,
      RideMessage item,
      imagePath,
      bool isLastMessage,
    ) =>
        AnimatedContainer(
          duration: const Duration(microseconds: 500),
          curve: Curves.easeIn,
          child: ChatBubble(
            clipper: clipper,
            alignment: Alignment.topRight,
            margin: const EdgeInsets.only(top: Dimensions.space3),
            backGroundColor: MyColor.primaryColor,
            shadowColor: MyColor.primaryColor.withValues(alpha: 0.01),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
                minWidth: MediaQuery.of(context).size.width * 0.2,
              ),
              child: IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    item.image != "null"
                        ? InkWell(
                            splashFactory: NoSplash.splashFactory,
                            onTap: () {
                              Get.toNamed(
                                RouteHelper.previewImageScreen,
                                arguments: "$imagePath/${item.image}",
                              );
                            },
                            child: MyImageWidget(
                              imageUrl: "$imagePath/${item.image}",
                            ),
                          )
                        : SizedBox.shrink(),
                    SizedBox(height: Dimensions.space2),
                    Text(
                      '${item.message}',
                      textAlign: TextAlign.start,
                      style: regularLarge.copyWith(color: Colors.white),
                    ),
                    if (isLastMessage) ...[
                      spaceDown(Dimensions.space2),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          DateConverter.getTimeAgo(item.createdAt ?? ""),
                          style: regularDefault.copyWith(
                            color: Colors.white70,
                            fontSize: Dimensions.fontOverSmall,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );

    getReceiverView(
      CustomClipper clipper,
      BuildContext context,
      RideMessage item,
      String imagePath,
      bool isLastMessage,
    ) =>
        AnimatedContainer(
          duration: const Duration(microseconds: 500),
          curve: Curves.easeIn,
          child: ChatBubble(
            clipper: clipper,
            backGroundColor: MyColor.colorGrey.withValues(alpha: 0.09),
            shadowColor: MyColor.colorGrey.withValues(alpha: 0.01),
            margin: const EdgeInsets.only(top: Dimensions.space3),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
                minWidth: MediaQuery.of(context).size.width * 0.2,
              ),
              child: IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    item.image != "null"
                        ? InkWell(
                            splashFactory: NoSplash.splashFactory,
                            onTap: () {
                              Get.toNamed(
                                RouteHelper.previewImageScreen,
                                arguments: "$imagePath/${item.image}",
                              );
                            },
                            child: MyImageWidget(
                              imageUrl: "$imagePath/${item.image}",
                            ),
                          )
                        : SizedBox.shrink(),
                    SizedBox(height: Dimensions.space2),
                    Text(
                      '${item.message}',
                      style: regularLarge.copyWith(color: MyColor.getTextColor()),
                    ),
                    if (isLastMessage) ...[
                      spaceDown(Dimensions.space2),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          DateConverter.getTimeAgo(item.createdAt ?? ""),
                          style: regularDefault.copyWith(
                            color: MyColor.getTextColor().withValues(alpha: 0.7),
                            fontSize: Dimensions.fontOverSmall,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );

    return GetBuilder<RideMessageController>(
      tag: 'rider',
      builder: (controller) {
        return AnnotatedRegionWidget(
          child: Scaffold(
            extendBody: true,
            resizeToAvoidBottomInset: true,
            backgroundColor: MyColor.screenBgColor,
            appBar: CustomAppBar(
              title: riderName,
              backBtnPress: () {
                Get.back();
              },
              actionsWidget: [
                IconButton(
                  onPressed: () {
                    controller.getRideMessage(
                      controller.rideId,
                      shouldLoading: true,
                    );
                  },
                  icon: Icon(
                    Icons.refresh_outlined,
                    color: MyColor.getPrimaryColor(),
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                controller.isLoading
                    ? Expanded(child: const CustomLoader())
                    : controller.massageList.isEmpty
                        ? Expanded(
                            child: SizedBox(
                              height: context.height,
                              child: LottieBuilder.asset(
                                MyAnimation.emptyChat,
                                repeat: false,
                              ),
                            ),
                          )
                        : Expanded(
                            child: ListView.builder(
                              controller: controller.scrollController,
                              padding: const EdgeInsetsDirectional.symmetric(
                                horizontal: Dimensions.space5,
                                vertical: Dimensions.space20,
                              ),
                              itemCount: controller.massageList.length,
                              reverse: true,
                              itemBuilder: (c, index) {
                                var previous = index > 0 ? controller.massageList[index - 1] : null;
                                var item = controller.massageList[index];

                                bool isMyMessage = item.userId == controller.userId && item.userId != "0";
                                bool previousWasMine = previous?.userId == controller.userId && previous?.userId != "0";
                                bool previousWasDriver = previous?.driverId != null && previous?.driverId != "0";

                                if (isMyMessage) {
                                  if (previousWasMine) {
                                    return Padding(
                                      padding: EdgeInsetsDirectional.only(
                                        end: Dimensions.space12,
                                      ),
                                      child: getSenderView(
                                        ChatBubbleClipper5(
                                          type: BubbleType.sendBubble,
                                          secondRadius: Dimensions.space50,
                                        ),
                                        context,
                                        item,
                                        controller.imagePath,
                                        false,
                                      ),
                                    );
                                  } else {
                                    return Padding(
                                      padding: EdgeInsetsDirectional.only(
                                        end: Dimensions.space6,
                                        bottom: Dimensions.space10,
                                      ),
                                      child: getSenderView(
                                        ChatBubbleClipper3(
                                          type: BubbleType.sendBubble,
                                        ),
                                        context,
                                        item,
                                        controller.imagePath,
                                        true,
                                      ),
                                    );
                                  }
                                } else {
                                  bool currentIsDriver = item.driverId != null && item.driverId != "0";

                                  if (currentIsDriver && previousWasDriver && previous?.driverId == item.driverId) {
                                    return Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                        start: Dimensions.space12,
                                      ),
                                      child: getReceiverView(
                                        ChatBubbleClipper5(
                                          type: BubbleType.receiverBubble,
                                          secondRadius: Dimensions.space50,
                                        ),
                                        context,
                                        item,
                                        controller.imagePath,
                                        false,
                                      ),
                                    );
                                  } else {
                                    return Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                        start: Dimensions.space6,
                                        bottom: Dimensions.space10,
                                      ),
                                      child: getReceiverView(
                                        ChatBubbleClipper3(
                                          type: BubbleType.receiverBubble,
                                        ),
                                        context,
                                        item,
                                        controller.imagePath,
                                        true,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                controller.isLoading
                    ? SizedBox.shrink()
                    : riderStatus == AppStatus.RIDE_COMPLETED
                        ? Container(
                            color: MyColor.getCardBgColor(),
                            padding: EdgeInsets.all(Dimensions.space15),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: MyColor.getTextColor(),
                                ),
                                spaceSide(Dimensions.space10),
                                HeaderText(
                                  text: MyStrings.rideCompleted,
                                  style: semiBoldOverLarge.copyWith(
                                    color: MyColor.getTextColor(),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: Dimensions.space10,
                              vertical: Dimensions.space10,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.space5,
                              vertical: Dimensions.space5,
                            ),
                            decoration: BoxDecoration(
                              color: MyColor.colorWhite,
                              borderRadius: BorderRadius.circular(
                                Dimensions.space12,
                              ),
                            ),
                            child: Row(
                              children: [
                                spaceSide(Dimensions.space10),
                                controller.imageFile == null
                                    ? GestureDetector(
                                        onTap: () => controller.pickFile(),
                                        child: Icon(
                                          Icons.image,
                                          color: MyColor.primaryColor,
                                        ),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          Dimensions.mediumRadius,
                                        ),
                                        child: Image.file(
                                          controller.imageFile!,
                                          height: 35,
                                          width: 35,
                                        ),
                                      ),
                                spaceSide(Dimensions.space10),
                                Expanded(
                                  child: TextFormField(
                                    controller: controller.massageController,
                                    cursorColor: MyColor.getPrimaryColor(),
                                    style: regularSmall.copyWith(
                                      color: MyColor.getTextColor(),
                                    ),
                                    readOnly: false,
                                    maxLines: null,
                                    textAlignVertical: TextAlignVertical.top,
                                    decoration: InputDecoration(
                                      hintText: MyStrings.writeYourMessage.tr,
                                      hintStyle: mediumDefault.copyWith(
                                        color: MyColor.bodyTextColor.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                      enabledBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                    ),
                                    onFieldSubmitted: (value) {
                                      if (controller.massageController.text.isNotEmpty && controller.isSubmitLoading == false) {
                                        controller.sendMessage();
                                      }
                                    },
                                  ),
                                ),
                                spaceSide(Dimensions.space10),
                                InkWell(
                                  onTap: () {
                                    if (controller.massageController.text.isNotEmpty && controller.isSubmitLoading == false) {
                                      controller.sendMessage();
                                    }
                                  },
                                  child: controller.isSubmitLoading
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            color: MyColor.primaryColor,
                                          ),
                                        )
                                      : const MyLocalImageWidget(
                                          imagePath: MyIcons.sendArrow,
                                          width: Dimensions.space40,
                                          height: Dimensions.space40,
                                        ),
                                ),
                                spaceSide(Dimensions.space10),
                              ],
                            ),
                          ),
              ],
            ),
          ),
        );
      },
    );
  }
}
