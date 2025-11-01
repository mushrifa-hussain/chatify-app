import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/snackbar_service.dart';
import '../services/navigation_service.dart';

enum AuthStatus {
  notAuthenticated,
  authenticating,
  authenticated,
  userNotFound,
  error,
}

class AuthProvider extends ChangeNotifier {
  User? user; // <-- make nullable instead of using null!
  AuthStatus status = AuthStatus.notAuthenticated;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static AuthProvider instance = AuthProvider();

  AuthProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkCurrentUserAuthenticated();
    });
  }

  void _autoLogin() {
    if (user != null) {
      NavigationService.instance.navigateToReplacement("home");
    }
  }

  void checkCurrentUserAuthenticated() {
    user = _auth.currentUser;
    if (user != null) {
      notifyListeners();
      _autoLogin();
    }
  }

  // ---------------------- LOGIN ----------------------
  Future<void> loginUserWithEmailAndPassword(
    BuildContext context,
    String email,
    String password,
  ) async {
    status = AuthStatus.authenticating;
    notifyListeners();

    // Allow one frame for UI to rebuild before continuing
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      user = result.user;
      status = AuthStatus.authenticated;

      if (context.mounted) {
        SnackbarService.instance.showSnackBarSuccess(
          context,
          "Welcome, ${user?.email}",
        );
        NavigationService.instance.navigateToReplacement("home");
      }
    } catch (e) {
      status = AuthStatus.error;
      user = null;
      if (context.mounted) {
        SnackbarService.instance.showSnackBarError(
          context,
          "Error Authenticating: $e",
        );
      }
    }

    notifyListeners();
  }

  // ---------------------- REGISTER ----------------------
  Future<void> registerUserWithEmailAndPassword(
    BuildContext context,
    String email,
    String password,
    Future<void> Function(String uid) onSuccess, // ✅ Correct callback type
  ) async {
    status = AuthStatus.authenticating;
    notifyListeners();

    // Allow one frame for UI to rebuild before continuing
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      user = result.user;
      status = AuthStatus.authenticated;

      await onSuccess(user!.uid); // ✅ safely call with non-null uid

      if (context.mounted) {
        SnackbarService.instance.showSnackBarSuccess(
          context,
          "Welcome, ${user?.email}",
        );
        NavigationService.instance.navigateToReplacement("home");
      }
    } catch (e) {
      status = AuthStatus.error;
      user = null;

      if (context.mounted) {
        SnackbarService.instance.showSnackBarError(
          context,
          "Error Registering User: $e",
        );
      }
    }

    notifyListeners();
  }

  Future<void> logoutUser(
    BuildContext context,
    Future<void> Function() onSuccess,
  ) async {
    // ✅ capture mounted immediately
    final isMounted = context.mounted;

    if (!isMounted) return; // exit early if widget is not mounted

    try {
      await _auth.signOut();
      user = null;
      status = AuthStatus.notAuthenticated;

      await onSuccess(); // make sure onSuccess handles navigation safely

      // ✅ Use NavigationService only if mounted
      if (!context.mounted) return;
      await NavigationService.instance.navigateToReplacement("login");

      if (!context.mounted) return;
      SnackbarService.instance.showSnackBarSuccess(
        context,
        "Logged Out Successfully!",
      );
    } catch (e) {
      if (context.mounted) {
        SnackbarService.instance.showSnackBarError(
          context,
          "Error Logging Out",
        );
      }
    }

    notifyListeners();
  }
}
