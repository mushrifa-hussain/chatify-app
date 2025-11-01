import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import './pages/login_page.dart';
import './pages/registration_page.dart';
import './services/navigation_service.dart';
import './pages/home_page.dart';
import 'package:provider/provider.dart';
import './providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider.instance),
        // add other providers here if needed
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatify',
      navigatorKey: NavigationService.instance.navigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color.fromRGBO(28, 27, 27, 1), // ✅ fixed
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 34, 74, 111),
          brightness: Brightness.dark,
        ),
      ),
      initialRoute: "login",
      routes: {
        'login': (BuildContext context) => LoginPage(),
        'register': (BuildContext context) => RegistrationPage(),
        "home": (BuildContext context) => const HomePage(),
      },
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
