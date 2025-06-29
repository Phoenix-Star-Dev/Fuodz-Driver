import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/models/user.dart';
import 'package:fuodz/requests/driver_type.request.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/local_storage.service.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/views/pages/splash.page.dart';
import 'package:fuodz/widgets/buttons/custom_swipe_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class DriverTypeSwitch extends StatefulWidget {
  const DriverTypeSwitch({Key? key}) : super(key: key);

  @override
  State<DriverTypeSwitch> createState() => _DriverTypeSwitchState();
}

class _DriverTypeSwitchState extends State<DriverTypeSwitch> {
  GlobalKey swipeKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: AuthServices.getCurrentUser(force: true),
      builder: (context, snapshot) {
        if (!snapshot.hasData ||
            snapshot.connectionState != ConnectionState.done) {
          return UiSpacer.emptySpace();
        }

        //
        return VStack([
          //note indicating the button below is a swipable button
          "Swipe below to switch".tr().text.sm.make().centered().py(2),
          //
          CustomSwipingButton(
                key: swipeKey,
                height: 50,
                text:
                    (snapshot.data != null && !snapshot.data!.isTaxiDriver
                            ? "Switch To Taxi Driver"
                            : "Switch To Regular Driver")
                        .tr(),
                swipeButtonColor: AppColor.primaryColor,
                backgroundColor: Utils.textColorByColor(AppColor.primaryColor),
                iconColor: Utils.textColorByColor(AppColor.primaryColor),
                buttonTextStyle: context.titleSmall!.copyWith(
                  color: Utils.textColorByColor(AppColor.primaryColor),
                  fontSize: Sizes.fontSizeSmall,
                  fontWeight: FontWeight.w700,
                ),
                textStyle: context.titleMedium!.copyWith(
                  color: AppColor.primaryColor,
                  fontSize: Sizes.fontSizeSmall,
                  fontWeight: FontWeight.w700,
                ),
                radius: Sizes.radiusSmall / 2,
                onSwipeCallback: () async {
                  await _processDriverTypeSwitch(snapshot.data!, context);
                  if (mounted) {
                    setState(() {
                      swipeKey = GlobalObjectKey(DateTime.now());
                    });
                  }
                },
              ).box
              .clip(Clip.antiAliasWithSaveLayer)
              .withRounded(value: Sizes.radiusSmall)
              .border(color: AppColor.primaryColor)
              .color(Utils.textColorByColor(AppColor.primaryColor))
              .make(),

          UiSpacer.vSpace(),
        ]);
      },
    );
  }

  Future<bool> _processDriverTypeSwitch(User user, BuildContext context) async {
    bool result = false;
    try {
      AlertService.showLoading();

      final payload = {"driver_id": user.id, "is_taxi": !user.isTaxiDriver};
      final apiResponse = await DriverTypeRequest().switchType(payload);

      if (apiResponse.allGood) {
        //
        final vehicleJson = apiResponse.body['data']["vehicle"] ?? null;
        final driverJson = apiResponse.body['data']["driver"] ?? null;
        final newUserModel = await AuthServices.saveUser(driverJson);
        if (newUserModel.isTaxiDriver && vehicleJson != null) {
          await AuthServices.saveVehicle(vehicleJson);
        } else {
          await LocalStorageService.prefs!.remove(AppStrings.driverVehicleKey);
        }

        await AuthServices.getCurrentUser(force: true);
        AlertService.stopLoading();
        //reload app from splash screen
        context.nextAndRemoveUntilPage(SplashPage());
      } else {
        throw "${apiResponse.message}";
      }
      //
      result = true;
    } catch (error) {
      AlertService.stopLoading();
      AlertService.error(text: "$error");
    }
    return result;
  }
}
