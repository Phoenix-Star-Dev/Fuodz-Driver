import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/view_models/taxi/taxi.vm.dart';
import 'package:fuodz/widgets/buttons/custom_swipe_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class TaxiActionSwipeView extends StatelessWidget {
  const TaxiActionSwipeView(this.vm, {Key? key}) : super(key: key);

  final TaxiViewModel vm;

  @override
  Widget build(BuildContext context) {
    return CustomSwipingButton(
      key: ObjectKey(DateTime.now()),
      height: 50,
      radius: Sizes.radiusSmall,
      backgroundColor: AppColor.accentColor.withValues(alpha: 0.80),
      swipeButtonColor: AppColor.primaryColorDark,
      swipePercentageNeeded: 0.80,
      text: "${vm.onGoingTaxiBookingService.getNewStateStatus}".tr(),
      onSwipeCallback: () {
        vm.onGoingTaxiBookingService.processOrderStatusUpdate();
      },
    );
  }
}
