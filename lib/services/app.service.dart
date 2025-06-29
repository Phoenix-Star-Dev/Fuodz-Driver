import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fuodz/models/order.dart';
import 'package:random_string/random_string.dart';
import 'package:rxdart/rxdart.dart';
import 'package:just_audio/just_audio.dart';
import 'package:singleton/singleton.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class AppService {
  //

  /// Factory method that reuse same instance automatically
  factory AppService() => Singleton.lazy(() => AppService._());

  /// Private constructor
  AppService._() {}

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  BehaviorSubject<int> homePageIndex = BehaviorSubject<int>();
  BehaviorSubject<bool> refreshAssignedOrders = BehaviorSubject<bool>();
  BehaviorSubject<Order> addToAssignedOrders = BehaviorSubject<Order>();
  bool driverIsOnline = false;
  StreamSubscription? actionStream;
  List<int> ignoredOrders = [];
  final audioPlayer = AudioPlayer();

  changeHomePageIndex({int index = 2}) async {
    print("Changed Home Page");
    homePageIndex.add(index);
  }

  //
  void playNotificationSound() async {
    try {
      await audioPlayer.stop();
    } catch (error) {
      print("Error stopping audio player");
    }

    //
    await audioPlayer.setAsset("assets/audio/alert.mp3", preload: true);
    await audioPlayer.setLoopMode(LoopMode.one);
    await audioPlayer.play();
  }

  void stopNotificationSound() async {
    try {
      await audioPlayer.stop();
    } catch (error) {
      print("Error stopping audio player");
    }
  }

  Future<File?> compressFile(File file, {int quality = 50}) async {
    final dir = await path_provider.getTemporaryDirectory();
    final targetPath =
        dir.absolute.path + "/temp_" + randomAlphaNumeric(10) + ".jpg";

    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: quality,
    );

    if (kDebugMode) {
      print("unCompress file size ==> ${file.lengthSync()}");
      if (result != null) {
        print("Compress file size ==> ${result.length}");
        print("Compress successful");
      } else {
        print("compress failed");
      }
    }

    return result != null ? File(result.path) : null;
  }
}
