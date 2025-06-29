import 'package:flutter/material.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/view_models/taxi/taxi.vm.dart';
import 'package:fuodz/widgets/buttons/custom_swipe_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class OnlineStatusSwipeButton extends StatefulWidget {
  const OnlineStatusSwipeButton(this.vm, {Key? key}) : super(key: key);
  final TaxiViewModel vm;

  @override
  State<OnlineStatusSwipeButton> createState() =>
      _OnlineStatusSwipeButtonState();
}

class _OnlineStatusSwipeButtonState extends State<OnlineStatusSwipeButton> {
  //
  ObjectKey viewKey = new ObjectKey(DateTime.now());
  //
  @override
  Widget build(BuildContext context) {
    viewKey = new ObjectKey(DateTime.now());
    final driverIsOnline = widget.vm.appService.driverIsOnline;
    return CustomSwipingButton(
          key: viewKey,
          radius: Sizes.radiusSmall,
          height: 50,
          text: (driverIsOnline ? "Go offline" : "Go online").tr(),
          backgroundColor: driverIsOnline ? Colors.red : Colors.green,
          swipeButtonColor: context.backgroundColor,
          iconColor: driverIsOnline ? Colors.red : Colors.green,
          buttonTextStyle: context.titleSmall!.copyWith(
            color: driverIsOnline ? Colors.red : Colors.green,
          ),
          onSwipeCallback: () async {
            AlertService.showLoading();
            try {
              final newDriverState = !widget.vm.appService.driverIsOnline;
              //show loading
              await widget.vm.newTaxiBookingService.toggleVisibility(
                newDriverState,
              );

              setState(() {
                viewKey = new ObjectKey(DateTime.now());
              });
            } catch (error) {
              widget.vm.toastError("$error");
            }
            AlertService.stopLoading();
          },
        ).box
        .withRounded(value: Sizes.radiusSmall * 1.2)
        .border(color: driverIsOnline ? Colors.red : Colors.green)
        .make()
        .p(10);
  }
}
