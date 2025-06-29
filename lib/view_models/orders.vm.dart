import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_routes.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/requests/order.request.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:fuodz/views/pages/order/taxi_order_details.page.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:fuodz/extensions/context.dart';
//

class OrdersViewModel extends MyBaseViewModel {
  //
  OrdersViewModel(BuildContext context) {
    this.viewContext = context;
  }

  //
  OrderRequest orderRequest = OrderRequest();
  List<Order> orders = [];
  int queryPage = 1;

  void initialise() async {
    await fetchMyOrders();
  }

  //
  Future<bool> fetchMyOrders({bool initialLoading = true}) async {
    if (initialLoading) {
      setBusy(true);
      queryPage = 1;
    } else {
      queryPage++;
    }

    List<Order> mOrders = [];
    try {
      mOrders = await orderRequest.getOrders(
        page: queryPage,
        type: "history",
      );
      if (!initialLoading) {
        orders.addAll(mOrders);
      } else {
        orders = mOrders;
      }
      clearErrors();
    } catch (error) {
      print("Order Error ==> $error");
      setError(error);
    }

    setBusy(false);
    return true;
  }

  //
  openPaymentPage(Order order) async {
    launchUrlString(order.paymentLink);
  }

  openOrderDetails(Order order) async {
    //
    if (order.taxiOrder != null) {
      await viewContext.push(
        (context) => TaxiOrderDetailPage(order: order),
      );
      return;
    }

    final result = await Navigator.of(viewContext).pushNamed(
      AppRoutes.orderDetailsRoute,
      arguments: order,
    );

    //
    if (result != null && (result is Order || result is bool)) {
      fetchMyOrders();
    }
  }

  void openLogin() async {
    await Navigator.of(viewContext).pushNamed(AppRoutes.loginRoute);
    notifyListeners();
    fetchMyOrders();
  }
}
