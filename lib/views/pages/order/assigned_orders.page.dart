import 'package:flutter/material.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/view_models/assigned_orders.vm.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/custom_easy_refresh_view.dart';
import 'package:fuodz/widgets/list_items/order.list_item.dart';
import 'package:fuodz/widgets/states/order.empty.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'widgets/online_offline.fab.dart';

class AssignedOrdersPage extends StatefulWidget {
  const AssignedOrdersPage({Key? key}) : super(key: key);

  @override
  _AssignedOrdersPageState createState() => _AssignedOrdersPageState();
}

class _AssignedOrdersPageState extends State<AssignedOrdersPage>
    with AutomaticKeepAliveClientMixin<AssignedOrdersPage> {
  @override
  Widget build(BuildContext context) {
    //
    super.build(context);
    return SafeArea(
      child: ViewModelBuilder<AssignedOrdersViewModel>.reactive(
        viewModelBuilder: () => AssignedOrdersViewModel(),
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, vm, child) {
          return BasePage(
            body: VStack(
              [
                //online status
                OnlineOfflineFab(),
                //
                CustomEasyRefreshView(
                  onRefresh: vm.fetchOrders,
                  onLoad: () => vm.fetchOrders(initialLoading: false),
                  loading: vm.isBusy,
                  dataset: vm.orders,
                  padding: EdgeInsets.all(Sizes.paddingSizeDefault),
                  emptyView: VStack(
                    [
                      EmptyOrder(
                        title: "Assigned Orders".tr(),
                      ),
                    ],
                  ),
                  listView: vm.orders.map((order) {
                    return OrderListItem(
                      order: order,
                      orderPressed: () => vm.openOrderDetails(order),
                    );
                  }).toList(),
                ).expand(),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
