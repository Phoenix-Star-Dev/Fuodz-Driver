import 'dart:async';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/services/appbackground.service.dart';
import 'package:fuodz/services/order_assignment.service.dart';
import 'package:fuodz/services/order_details_websocket.service.dart';
import 'package:fuodz/services/taxi_background_order.service.dart';
import 'package:fuodz/view_models/taxi/taxi.vm.dart';

class NewTaxiBookingService {
  TaxiViewModel taxiViewModel;
  NewTaxiBookingService(this.taxiViewModel);
  StreamSubscription? myLocationListener;
  bool showNewTripView = false;
  CountDownController countDownTimerController = CountDownController();
  GlobalKey newAlertViewKey = GlobalKey<FormState>();
  //
  FirebaseFirestore firebaseFireStore = FirebaseFirestore.instance;
  StreamSubscription? newOrderStreamSubscription;
  StreamSubscription? locationStreamSubscription;

  //dispose
  void dispose() {
    myLocationListener?.cancel();
    newOrderStreamSubscription?.cancel();
  }

  //
  toggleVisibility(bool value) async {
    //
    taxiViewModel.appService.driverIsOnline = value;
    final updated = await taxiViewModel.syncDriverNewState();
    //
    if (updated) {
      if (value && taxiViewModel.onGoingOrderTrip == null) {
        startNewOrderListener();
        AppbackgroundService().startBg();
      } else {
        stopListeningToNewOrder();
        AppbackgroundService().stopBg();
      }
    }
  }

  //start lisntening for new orders
  startNewOrderListener() {
    newOrderStreamSubscription?.cancel();
    TaxiBackgroundOrderService().taxiViewModel = taxiViewModel;
    if (AppStrings.useWebsocketAssignment) {
      OrderDetailsWebsocketService().disconnect();
    }
  }

  //stop listening to new orders
  stopListeningToNewOrder() {
    locationStreamSubscription?.cancel();
    newOrderStreamSubscription?.cancel();
  }

  void countDownCompleted() async {
    try {
      countDownTimerController.pause();
    } catch (e) {
      print("countDownTimerController error ==> $e");
    }
    AppService().stopNotificationSound();
    showNewTripView = false;
    taxiViewModel.taxiGoogleMapManagerService.zoomToCurrentLocation();
    taxiViewModel.notifyListeners();
    await OrderAssignmentService.releaseOrderForotherDrivers(
      taxiViewModel.newOrder!.toJson(),
      taxiViewModel.newOrder!.docRef!,
    );
    startNewOrderListener();
  }

  void processOrderAcceptance() {}
}
