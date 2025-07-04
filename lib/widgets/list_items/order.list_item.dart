import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/extensions/dynamic.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderListItem extends StatelessWidget {
  const OrderListItem({
    required this.order,
    this.onPayPressed,
    required this.orderPressed,
    Key? key,
  }) : super(key: key);

  final Order order;
  final Function? onPayPressed;
  final Function orderPressed;
  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        HStack(
          [
            //vendor image
            CustomImage(
              imageUrl: order.vendor?.featureImage ?? "",
              width: context.percentWidth * 18,
              boxFit: BoxFit.cover,
              height: context.percentHeight * 10,
            ).cornerRadius(5),

            //
            VStack(
              [
                //
                "#${order.code}".text.xl.medium.make(),
                //amount and total products
                HStack(
                  [
                    (order.isPackageDelivery
                            ? "${order.packageType?.name}"
                            : "%s Product(s)"
                                .tr()
                                .fill([order.orderProducts?.length]))
                        .text
                        .medium
                        .make()
                        .expand(),
                    "${AppStrings.currencySymbol} ${order.total}"
                        .currencyFormat()
                        .text
                        .xl
                        .semiBold
                        .make(),
                  ],
                ),
                //time & status
                HStack(
                  [
                    //time
                    order.formattedDate.text.sm.make().expand(),
                    "${order.status.tr().capitalized}"
                        .text
                        .lg
                        .color(
                          AppColor.getStausColor(order.status),
                        )
                        .medium
                        .make(),
                  ],
                ),
              ],
            ).px12().expand(),
          ],
        ),
      ],
    )
        .onInkTap(() => orderPressed())
        .card
        .elevation(0.5)
        .clip(Clip.antiAlias)
        .withRounded(value: Sizes.radiusSmall)
        .make();
  }
}
