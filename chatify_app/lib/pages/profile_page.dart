import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/db_service.dart';
import '../models/contact.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../services/navigation_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: StreamBuilder<Contact>(
            stream: DBService.instance.getUserData(auth.user!.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SpinKitWanderingCubes(
                  color: Colors.blue,
                  size: 50.0,
                );
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return const Text(
                  "No user data found.",
                  style: TextStyle(color: Colors.white70),
                );
              }

              final userData = snapshot.data!;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _userImageWidget(userData.image ?? ''),
                  const SizedBox(height: 20),
                  _userNameWidget(userData.name ?? ''),
                  const SizedBox(height: 10),
                  _userEmailWidget(userData.email ?? ''),
                  const SizedBox(height: 30),
                  _logoutButton(auth, context),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _userImageWidget(String imageUrl) {
    return CircleAvatar(
      radius: 60,
      backgroundImage: imageUrl.isNotEmpty
          ? NetworkImage(imageUrl)
          : const NetworkImage(
              'https://cdn-icons-png.flaticon.com/512/847/847969.png',
            ),
    );
  }

  Widget _userNameWidget(String name) {
    return Text(
      name.isNotEmpty ? name : 'No Name',
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white, fontSize: 26),
    );
  }

  Widget _userEmailWidget(String email) {
    return Text(
      email.isNotEmpty ? email : 'No Email',
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white70, fontSize: 16),
    );
  }

  Widget _logoutButton(AuthProvider auth, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        onPressed: () {
          auth.logoutUser(context, () async {
            await NavigationService.instance.navigateToReplacement("login");
          });
        },

        child: const Text(
          "LOGOUT",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
