import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
//import '../services/snackbar_service.dart';
import '../services/navigation_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late GlobalKey<FormState> _formKey;
  late AuthProvider _auth;

  String _email = "";
  String _password = "";

  _LoginPageState() {
    _formKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    _auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          // makes it scrollable on small screens
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: _loginPageUI(),
        ),
      ),
    );
  }

  Widget _loginPageUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _headingWidget(),
        const SizedBox(height: 30),
        _inputForm(),
        const SizedBox(height: 30),
        _loginButton(),
        const SizedBox(height: 15),
        _registerButton(),
      ],
    );
  }

  Widget _headingWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Welcome to Chatify!",
          style: TextStyle(fontSize: 35, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 10),
        Text(
          "Please log in to your account",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
        ),
      ],
    );
  }

  Widget _inputForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _emailTextField(),
          const SizedBox(height: 20),
          _passwordTextField(),
        ],
      ),
    );
  }

  Widget _emailTextField() {
    return TextFormField(
      autocorrect: false,
      style: const TextStyle(color: Colors.white),
      validator: (input) {
        return input != null && input.contains('@')
            ? null
            : "Please enter a valid email";
      },
      onSaved: (input) {
        setState(() {
          _email = input!;
        });
      },
      cursorColor: Colors.white,
      decoration: const InputDecoration(
        hintText: "Email Address",
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _passwordTextField() {
    return TextFormField(
      autocorrect: false,
      obscureText: true,
      style: const TextStyle(color: Colors.white),
      validator: (input) {
        return input != null && input.length >= 6
            ? null
            : "Password must be at least 6 characters long";
      },
      onSaved: (input) {
        setState(() {
          _password = input!;
        });
      },
      cursorColor: Colors.white,
      decoration: const InputDecoration(
        hintText: "Password",
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _loginButton() {
    return _auth.status == AuthStatus.authenticating
        ? Align(alignment: Alignment.center, child: CircularProgressIndicator())
        : SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 34, 74, 111),
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // all fields are valid
                  _formKey.currentState!.save();
                  await AuthProvider.instance.loginUserWithEmailAndPassword(
                    context,
                    _email,
                    _password,
                  );
                }
              },
              child: const Text(
                "LOGIN",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          );
  }

  Widget _registerButton() {
    return GestureDetector(
      onTap: () {
        NavigationService.instance.navigateTo("register");
      },
      child: SizedBox(
        width: double.infinity,
        child: Text(
          "REGISTER",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
