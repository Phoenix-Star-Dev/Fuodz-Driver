import 'dart:io';

import 'package:fuodz/services/alert.service.dart';
import 'package:custom_faqs/custom_faqs.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/views/pages/payment_account/payment_account.page.dart';
import 'package:fuodz/views/pages/profile/account_delete.page.dart';
import 'package:fuodz/views/pages/splash.page.dart';
import 'package:fuodz/widgets/bottomsheets/earning.bottomsheet.dart';
import 'package:fuodz/constants/api.dart';
import 'package:fuodz/constants/app_routes.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/models/user.dart';
import 'package:fuodz/requests/auth.request.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:fuodz/widgets/cards/language_selector.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:fuodz/extensions/context.dart';

class ProfileViewModel extends MyBaseViewModel {
  //
  String appVersionInfo = "";
  late User currentUser;

  //
  AuthRequest _authRequest = AuthRequest();

  ProfileViewModel(BuildContext context) {
    this.viewContext = context;
    this.currentUser = AuthServices.currentUser!;
  }

  void initialise() async {
    //
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String versionName = packageInfo.version;
    String versionCode = packageInfo.buildNumber;
    appVersionInfo = "$versionName($versionCode)";
    setBusy(true);
    currentUser = await AuthServices.getCurrentUser(force: true);
    setBusy(false);
  }

  /**
   * Edit Profile
   */

  openEditProfile() async {
    final result = await Navigator.of(
      viewContext,
    ).pushNamed(AppRoutes.editProfileRoute);

    if (result != null && result is bool && result) {
      initialise();
    }
  }

  /**
   * Change Password
   */

  openChangePassword() async {
    Navigator.of(viewContext).pushNamed(AppRoutes.changePasswordRoute);
  }

  /**
   * Delivery addresses
   */
  openDeliveryAddresses() {
    Navigator.of(viewContext).pushNamed(AppRoutes.deliveryAddressesRoute);
  }

  //
  openFavourites() {
    Navigator.of(viewContext).pushNamed(AppRoutes.favouritesRoute);
  }

  //Earning
  showEarning() async {
    showModalBottomSheet(
      context: viewContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return EarningBottomSheet();
      },
    );
  }

  /**
   * Logout
   */
  logoutPressed() async {
    AlertService.confirm(
      title: "Logout".tr(),
      text: "Are you sure you want to logout?".tr(),
      onConfirm: () {
        processLogout();
      },
    );
  }

  void processLogout() async {
    //
    AlertService.loading(
      title: "Logout".tr(),
      text: "Logging out Please wait...".tr(),
      barrierDismissible: false,
    );

    //
    final apiResponse = await _authRequest.logoutRequest();

    //
    viewContext.pop();

    if (!apiResponse.allGood) {
      //
      AlertService.error(title: "Logout", text: apiResponse.message);
    } else {
      //
      await AuthServices.logout();
      Navigator.of(viewContext).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SplashPage()),
        (route) => false,
      );
    }
  }

  openWallet() async {
    Navigator.of(viewContext).pushNamed(AppRoutes.walletRoute);
  }

  openPaymentAccounts() async {
    viewContext.push((context) => PaymentAccountPage());
  }

  openNotification() async {
    Navigator.of(viewContext).pushNamed(AppRoutes.notificationsRoute);
  }

  /**
   * App Rating & Review
   */
  openReviewApp() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (Platform.isAndroid) {
      inAppReview.openStoreListing(appStoreId: AppStrings.appStoreId);
    } else if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    } else {
      inAppReview.openStoreListing(appStoreId: AppStrings.appStoreId);
    }
  }

  openFaqs() {
    viewContext.nextPage(
      CustomFaqPage(title: 'Faqs'.tr(), link: Api.baseUrl + Api.faqs),
    );
  }

  //
  openPrivacyPolicy() async {
    final url = Api.privacyPolicy;
    openWebpageLink(url);
  }

  openTerms() {
    final url = Api.terms;
    openWebpageLink(url);
  }

  //
  openContactUs() async {
    final url = Api.contactUs;
    openWebpageLink(url);
  }

  openLivesupport() async {
    final url = Api.inappSupport;
    openWebpageLink(url);
  }

  //
  changeLanguage() async {
    // showModalBottomSheet(
    //   context: viewContext,
    //   builder: (context) {
    //     return AppLanguageSelector();
    //   },
    // );
    Navigator.of(
      viewContext,
    ).push(MaterialPageRoute(builder: (ctx) => AppLanguageSelector()));
  }

  deleteAccount() {
    viewContext.nextPage(AccountDeletePage());
  }
}
