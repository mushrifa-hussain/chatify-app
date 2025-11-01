import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/navigation_service.dart';
import '../services/media_service.dart';
import '../services/cloud_storage_service.dart';
import '../services/db_service.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  late GlobalKey<FormState> _formKey;

  File? _image;

  String _name = "";
  String _email = "";
  String _password = "";

  late AuthProvider _auth;
  _RegistrationPageState() {
    _formKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          // makes it scrollable on small screens
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: registrationPageUI(),
        ),
      ),
    );
  }

  Widget registrationPageUI() {
    _auth = context.watch<AuthProvider>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _headingWidget(),
          const SizedBox(height: 30),
          _inputForm(),
          const SizedBox(height: 30),
          _registerButton(),
          const SizedBox(height: 15),
          _backToLoginPageButton(),
        ],
      ),
    );
  }

  Widget _headingWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Let's get going!",
          style: TextStyle(fontSize: 35, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 10),
        Text(
          "Please enter your details.",
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
          _imageSelectorWidget(),
          const SizedBox(height: 20),
          _nameTextField(),
          const SizedBox(height: 20),
          _emailTextField(),
          const SizedBox(height: 20),
          _passwordTextField(),
        ],
      ),
    );
  }

  Widget _imageSelectorWidget() {
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          debugPrint('Avatar tapped');
          File? imageFile = await MediaService.instance.getImageFromLibrary();
          setState(() {
            _image = imageFile;
          });
        },
        child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(50),
            image: DecorationImage(
              image: _image != null
                  ? FileImage(_image!)
                  : const NetworkImage(
                          'https://cdn0.iconfinder.com/data/icons/occupation-002/64/programmer-programming-occupation-avatar-512.png',
                        )
                        as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _nameTextField() {
    return TextFormField(
      autocorrect: false,
      style: const TextStyle(color: Colors.white),
      validator: (input) {
        return input != null ? null : "Please enter a name";
      },
      onSaved: (input) {
        setState(() {
          _name = input!;
        });
      },
      cursorColor: Colors.white,
      decoration: const InputDecoration(
        hintText: "Name",
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
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
        hintText: "Email",
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _passwordTextField() {
    return TextFormField(
      obscureText: true,
      autocorrect: false,
      style: const TextStyle(color: Colors.white),
      validator: (input) {
        return input != null ? null : "Please enter a password";
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

  Widget _registerButton() {
    return _auth.status != AuthStatus.authenticating
        ? SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 34, 74, 111),
              ),
              onPressed: () {
                if (_formKey.currentState != null &&
                    _formKey.currentState!.validate() &&
                    _image != null) {
                  _formKey.currentState!.save();
                  _auth.registerUserWithEmailAndPassword(
                    context,
                    _email,
                    _password,
                    (uid) async {
                      var result = await CloudStorageService.instance
                          .uploadUserImage(uid, _image!);
                      var imageURL = await result.ref.getDownloadURL();
                      await DBService.instance.createUserInDB(
                        uid,
                        _name,
                        _email,
                        imageURL,
                      );
                    },
                  );
                } else {
                  debugPrint("Form is not valid!");
                }

                FocusScope.of(context).unfocus(); // to hide the keyboard
              },
              child: const Text(
                "Register",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          )
        : const Align(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          );
  }

  Widget _backToLoginPageButton() {
    return GestureDetector(
      onTap: () {
        NavigationService.instance.goBack();
      },
      child: SizedBox(
        width: double.infinity,
        child: Text(
          "BACK TO LOGIN",
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
