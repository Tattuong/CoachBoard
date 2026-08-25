import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AppTabs {
  static final index = ValueNotifier<int>(0);
  static final shopFeatures = ValueNotifier<bool>(false);

  static void goDash() => index.value = 0;
  static void goClients() => index.value = 1;
  static void goSessions() => index.value = 2;
  static void goPrograms() => index.value = 3;
  static void goBusiness() => index.value = 4;
  static void goShop({bool features = false}) {
    shopFeatures.value = features;
    rootNavigatorKey.currentState?.pushNamed('/shop');
  }
}

BuildContext? get rootContext => rootNavigatorKey.currentContext;

Future<T?> showAppModal<T>(Widget sheet) {
  final ctx = rootContext;
  if (ctx == null) return Future.value(null);
  return showModalBottomSheet<T>(
    context: ctx,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => sheet,
  );
}
