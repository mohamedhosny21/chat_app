import 'package:flutter/material.dart';

class AppNavigatorObserver extends NavigatorObserver {
  static String? currentRoute = '';
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    // Called when a new route has been pushed onto the navigator.
    debugPrint('didPush: ${route.settings.name}');
    currentRoute = route.settings.name;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    // Called when the current route has been popped off the navigator.
    debugPrint('didPop: ${route.settings.name}');
    currentRoute = previousRoute?.settings.name;
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    // Called when a route has been removed from the navigator.
    debugPrint('didRemove: ${route.settings.name}');
    currentRoute = route.settings.name;
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    // Called when a route has been replaced in the navigator.
    debugPrint('didReplace: ${newRoute!.settings.name}');
    currentRoute = newRoute.settings.name;
  }

  // Add more methods as needed to track specific navigation events.
}
