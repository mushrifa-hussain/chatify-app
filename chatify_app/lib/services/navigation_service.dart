import 'package:flutter/material.dart';

class NavigationService {
  // Global key for the navigator
  late GlobalKey<NavigatorState> navigatorKey;

  // Singleton instance
  static NavigationService instance = NavigationService();

  // Constructor
  NavigationService() {
    navigatorKey = GlobalKey<NavigatorState>();
  }

  // Navigate and replace current route
  Future<dynamic>? navigateToReplacement(String routeName) {
    return navigatorKey.currentState?.pushReplacementNamed(routeName);
  }

  // Navigate normally (push to stack)
  Future<dynamic>? navigateTo(String routeName) {
    return navigatorKey.currentState?.pushNamed(routeName);
  }

  Future<dynamic>? navigateToRoute(MaterialPageRoute route) {
    return navigatorKey.currentState?.push(route);
  }

  // Go back to previous screen
  void goBack() {
    return navigatorKey.currentState?.pop();
  }
}
