import 'package:flutter/material.dart';
import 'package:terra/services/firebase_auth.dart';
import 'package:terra/utils/color.dart';

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key, required this.onLoading});
  final ValueChanged<bool> onLoading;
  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  late final TextEditingController _password;
  late final TextEditingController _conf;
  final AppColors _colors = AppColors.instance;
  final GlobalKey<FormState> _k = GlobalKey<FormState>();
  final FirebaseAuthenticator _auth = FirebaseAuthenticator();
  bool isObscured = true;
  @override
  void initState() {
    _conf = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _conf.dispose();
    _password.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Material(
        elevation: 0,
        color: Colors.transparent,
        child: Container(
          // height: 300,
          margin: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), color: Colors.white),
          child: Form(
            key: _k,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  ShaderMask(
                    shaderCallback: (Rect b) =>
                        LinearGradient(colors: [_colors.top, _colors.bot])
                            .createShader(b),
                    child: const Text("Change Password",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        )),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    validator: (text) {
                      if (text == null) {
                        return "Invalid type";
                      } else if (text.isEmpty) {
                        return "This field is required";
                      } else if (text != _conf.text) {
                        return "Password Mismatch";
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "******",
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                      ),
                      label: const Text(
                        "Password",
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isObscured = !isObscured;
                          });
                        },
                        icon: Icon(isObscured
                            ? Icons.visibility
                            : Icons.visibility_off),
                      ),
                    ),
                    controller: _password,
                    obscureText: isObscured,
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    validator: (text) {
                      if (text == null) {
                        return "Invalid type";
                      } else if (text.isEmpty) {
                        return "This field is required";
                      } else if (text != _password.text) {
                        return "Password Mismatch";
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "******",
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                      ),
                      label: const Text(
                        "Confirm Password",
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isObscured = !isObscured;
                          });
                        },
                        icon: Icon(isObscured
                            ? Icons.visibility
                            : Icons.visibility_off),
                      ),
                    ),
                    controller: _conf,
                    obscureText: isObscured,
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  MaterialButton(
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      if (_k.currentState!.validate()) {
                        Navigator.of(context).pop(null);
                        widget.onLoading(true);
                        await _auth.changePassword(_password.text);
                        widget.onLoading(false);
                      }
                    },
                    color: _colors.top,
                    height: 55,
                    child: const Center(
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
