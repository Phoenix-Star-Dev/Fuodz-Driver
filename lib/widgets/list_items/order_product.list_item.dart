import 'package:flutter/material.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/extensions/dynamic.dart';
import 'package:fuodz/models/order_product.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderProductListItem extends StatelessWidget {
  const OrderProductListItem({
    required this.orderProduct,
    Key? key,
  }) : super(key: key);

  final OrderProduct orderProduct;
  @override
  Widget build(BuildContext context) {
    return HStack(
      [
        //vendor image
        CustomImage(
          imageUrl: orderProduct.product?.photo ?? "",
          width: context.percentWidth * 16,
          boxFit: BoxFit.cover,
          height: context.percentHeight * 8,
        ),

        //
        VStack(
          [
            //
            "${orderProduct.product?.name}"
                .text
                .size(Sizes.fontSizeLarge)
                .medium
                .make(),
            if (orderProduct.options != null &&
                orderProduct.options!.isNotEmpty)
              "${orderProduct.options}"
                  .text
                  .size(Sizes.fontSizeSmall)
                  .gray500
                  .medium
                  .make(),

            "${AppStrings.currencySymbol}${orderProduct.price}"
                .currencyFormat()
                .text
                .size(Sizes.fontSizeLarge)
                .make(),
          ],
        ).expand(),

        //qty
        "x ${orderProduct.quantity}"
            .text
            .size(Sizes.fontSizeLarge)
            .medium
            .make()
            .px12(),
      ],
      spacing: 10,
    )
        .card
        .elevation(0.5)
        .clip(Clip.antiAlias)
        .withRounded(value: Sizes.radiusSmall)
        .make();
  }
}
