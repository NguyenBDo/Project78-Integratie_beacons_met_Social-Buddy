import 'package:buddy_bot/components/custom_switch.dart';
import 'package:buddy_bot/generated/assets.dart';
import 'package:buddy_bot/views/change_voice_page.dart';
import 'package:buddy_bot/views/view_exporter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slider_drawer/src/slider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../controller/flic/flic_connect.dart';
import '../views/ble_debug.dart';
import '../views/ble_distance_view.dart';

import '../config/config_exporter.dart';
import '../utils/utils_exporter.dart';

class DrawerScreen extends StatefulWidget {
  final GlobalKey<SliderDrawerState> scaffoldKey;

  const DrawerScreen({super.key, required this.scaffoldKey});

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> with WidgetsBindingObserver {
  final BoxDecoration selectedDecoration = BoxDecoration(
    color: Colors.grey.withOpacity(0.2),
    borderRadius: const BorderRadius.only(
      topRight: Radius.circular(15.0),
      topLeft: Radius.circular(5.0),
      bottomRight: Radius.circular(15.0),
      bottomLeft: Radius.circular(15.0),
    ),
  );

  double imageHeight = 25;
  RxBool isFromFaceSwitch = false.obs;
  RxBool isFromHandSwitch = false.obs;
  RxString version = "".obs;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getPackageInfo().then((value) => version.value = "${value.version} (${value.buildNumber})");
    });

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && authController.detectPermission.isTrue && (isFromHandSwitch.isTrue || isFromFaceSwitch.isTrue)) {
      authController.detectPermission.value = false;
      isFromHandSwitch.value = false;
      checkPermissions(performAction: () {
        if (isFromHandSwitch.isTrue) {
          changeHandSwitchValue();
          isFromHandSwitch.value = false;
        }
        if (isFromFaceSwitch.isTrue) {
          changeFaceSwitchValue();
          isFromFaceSwitch.value = false;
        }
        homeController.initPoseDetection();
      });
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: getWidth(context) * .35,
      height: getHeight(context),
      color: AppColors.lightBgColor,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Obx(() => Column(
                mainAxisSize: MainAxisSize.min,
                children: drawerTile(
                    title: AppStrings.appName,
                    subTitle: authController.botName.trim().length > 1 ? authController.botName.value : "BotName",
                    callback: () {},
                    isDivider: true,
                    trailingIcon: InkWell(
                      onTap: () {
                        commonAlertDialog(
                            message: AppStrings.logOutConfirmMessage,
                            okCall: () {
                              authController.signOut();
                            });
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.logout, color: Colors.red, size: 25),
                      ),
                    ),
                    imageSize: 40,
                    image: Container(
                      color: Colors.white,
                      height: imageHeight,
                      width: imageHeight,
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset(Assets.imagesLogo),
                    )))),
            SizedBox(height: 1.5.h),
            ...drawerTile(
                title: AppStrings.scanQR.tr,
                callback: () {
                  Get.to(() => const QrCodeScreen(
                        isFromInsideApp: true,
                      ));
                },
                image: Icon(
                  CupertinoIcons.qrcode,
                  size: 4.2.h,
                  color: CupertinoColors.systemGrey,
                ),
                // color: CupertinoColors.systemGrey,
                isBorder: false),
            ...drawerTile(
                title: AppStrings.changeBot.tr,
                callback: () {
                  if (authController.isConnected.isFalse) {
                    noInternetConnectedDialog();
                    return;
                  }
                  Get.to(() => const VoucherCodeScreen(isFromChangeCode: true));
                },
                image: Icon(
                  Icons.cameraswitch,
                  size: 3.8.h,
                  color: CupertinoColors.systemGrey,
                ),
                // color: CupertinoColors.systemGrey,
                isBorder: false),
            ...drawerTile(
                title: AppStrings.changeVoice.tr,
                callback: () {
                  if (authController.isConnected.isFalse) {
                    noInternetConnectedDialog();
                    return;
                  }
                  Get.to(() => const ChangeVoicePage());
                },
                image: Icon(
                  Icons.voice_chat_sharp,
                  size: 3.8.h,
                  color: CupertinoColors.systemGrey,
                ),
                // color: CupertinoColors.systemGrey,
                isBorder: false),
            ...drawerTile(
              title: "Flic",
              image: Icon(
                  Icons.radio_button_checked,
                  size: 3.8.h,
                  color: CupertinoColors.systemGrey),
              callback: () {
                if (authController.isConnected.isFalse) {
                  noInternetConnectedDialog();
                  return;
                }
                Get.to(() => const FlicConnect());
              },
            ),

            ...drawerTile(
                title: "distance BLE debug",
                image: Icon(
                  Icons.media_bluetooth_on_outlined,
                  size: 3.8.h,
                  color: CupertinoColors.activeBlue,
                ),

                callback: () {
                  if (authController.isConnected.isFalse) {
                    noInternetConnectedDialog();
                    return;
                  }
                  Get.to(() => const BleDeviceList());
                }
            ),

            ...drawerTile(
                title: "Distance Sensor",
                image: Icon (
                  Icons.radio,
                  size: 3.8.h,
                  color: CupertinoColors.activeGreen
                ),

                callback: () {
                  Get.to(() => const BleTag());
                }

            ),

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(AppStrings.enableHandGesture.tr, style: Styles.primaryText(fontWeight: FontWeight.w500, color: AppColors.mainFontColor))
                      .paddingOnly(left: 15),
                ),
                StreamBuilder<bool>(
                    stream: authController.isEnableGesture.stream,
                    builder: (context, snapshot) {
                      return CustomSwitch(
                          enableColor: AppColors.primaryColor,
                          disableColor: CupertinoColors.systemGrey2,
                          value: authController.isEnableGesture.value,
                          onChanged: (value) async {
                            if (authController.isEnableGesture.isTrue) {
                              changeHandSwitchValue();
                            } else {
                              if (authController.isCameraPermissionGranted.value != PermissionStatus.granted) {
                                isFromHandSwitch.value = true;
                                await askPermission(performAction: () {
                                  changeHandSwitchValue();
                                  homeController.initPoseDetection();
                                });
                              } else {
                                changeHandSwitchValue();
                              }
                            }
                          });
                    }),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text(AppStrings.showMessageOnlyWhenFaceDetect.tr,
                            style: Styles.primaryText(fontWeight: FontWeight.w500, color: AppColors.mainFontColor))
                        .paddingOnly(left: 15)),
                StreamBuilder<bool>(
                    stream: authController.isOnlyFaceEvent.stream,
                    builder: (context, snapshot) {
                      return CustomSwitch(
                          enableColor: AppColors.primaryColor,
                          disableColor: CupertinoColors.systemGrey2,
                          value: authController.isOnlyFaceEvent.value,
                          onChanged: (value) async {
                            if (authController.isOnlyFaceEvent.isTrue) {
                              changeFaceSwitchValue();
                            } else {
                              if (authController.isCameraPermissionGranted.value != PermissionStatus.granted) {
                                isFromFaceSwitch.value = true;
                                await askPermission(performAction: () {
                                  changeFaceSwitchValue();
                                  homeController.initPoseDetection();
                                });
                              } else {
                                changeFaceSwitchValue();
                              }
                            }
                          });
                    }),
              ],
            ),
            const SizedBox(height: 15),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(
                  child: Text(AppStrings.debugMode.tr, style: Styles.primaryText(fontWeight: FontWeight.w500, color: AppColors.mainFontColor))
                      .paddingOnly(left: 15)),
              StreamBuilder(
                  stream: authController.isDebugMode.stream,
                  builder: (context, snapshot) {
                    return CustomSwitch(
                        enableColor: AppColors.primaryColor,
                        disableColor: CupertinoColors.systemGrey2,
                        value: authController.isDebugMode.value,
                        onChanged: (value) async {
                          authController.isDebugMode.toggle();
                        });
                  }),
            ]),
            const SizedBox(height: 10),
            Center(
              child: StreamBuilder(
                  stream: version.stream,
                  builder: (context, snapshot) {
                    return Text(
                      "${AppStrings.version.tr}: ${version.value}",
                      style: Styles.secondaryText(fontWeight: FontWeight.w400, color: Colors.black),
                    );
                  }),
            ),
            const SizedBox(height: 10),
          ],
        ).paddingOnly(right: 8.0),
      ),
    );
  }

  List<Widget> drawerTile(
      {required String title,
      String? subTitle,
      required Widget image,
      Widget? trailingIcon,
      double? imageSize,
      required Function callback,
      bool isDivider = false,
      bool isBorder = true,
      Color? color}) {
    return [
      InkWell(
        onTap: () {
          callback();
          widget.scaffoldKey.currentState?.closeSlider();
        },
        child: Row(
          children: [
            getHomeScreenImage(context, image: image, isBorder: isBorder, imageSize: imageSize).paddingOnly(right: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: Styles.primaryText(fontWeight: FontWeight.w500, color: color),
                  ),
                  SizedBox(height: subTitle != null ? 2 : 0),
                  subTitle != null
                      ? Text(
                          subTitle,
                          style: Styles.secondaryText(fontWeight: FontWeight.w500, color: color),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
            if (trailingIcon != null) trailingIcon
          ],
        ),
      ),
      // ListTile(
      //   onTap: () {
      //     callback();
      //     widget.scaffoldKey.currentState?.closeSlider();
      //   },
      //   leading: getHomeScreenImage(context, image: image, isBorder: isBorder, imageSize: imageSize),
      //   trailing: trailingIcon,
      //   title: Text(
      //     title,
      //     style: Styles.primaryText(fontWeight: FontWeight.w500, color: color),
      //   ),
      //   contentPadding: const EdgeInsets.only(left: 5.0, right: 0.0),
      //   subtitle: subTitle != null
      //       ? Text(
      //           subTitle,
      //           style: Styles.secondaryText(fontWeight: FontWeight.w500, color: color),
      //         )
      //       : null,
      // ),
      const SizedBox(height: 12),
      if (isDivider)
        Divider(
          color: AppColors.dividerColor,
          height: 1.h,
        ),
      if (isDivider) const SizedBox(height: 2),
    ];
  }

  void changeHandSwitchValue() {
    authController.isEnableGesture.toggle();
    if (authController.isEnableGesture.isTrue) {
      homeController.initPoseDetection();
    }
    stopIfNoSwitchEnabled();
    authController.getPref.write(PrefString.enableGesturePref, authController.isEnableGesture.value);
    eventController.currentEvent.refresh();
  }

  void changeFaceSwitchValue() {
    authController.isOnlyFaceEvent.toggle();

    stopIfNoSwitchEnabled();

    authController.getPref.write(PrefString.enableFacePref, authController.isOnlyFaceEvent.value);
    eventController.currentEvent.refresh();

    if (authController.isOnlyFaceEvent.isTrue) {
      homeController.initPoseDetection();
    }

    // print("object ${authController.isOnlyFaceEvent.value}");
  }

  void stopIfNoSwitchEnabled() {
    if (authController.isOnlyFaceEvent.isFalse && authController.isEnableGesture.isFalse) {
      homeController.disablePoseDetection();
    }
  }
}
