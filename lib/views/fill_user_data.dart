import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/services/API/auth.dart';
import 'package:terra/services/API/user_api.dart';
import 'package:terra/services/data_cacher.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';

class FillUserDataPage extends StatefulWidget {
  const FillUserDataPage({
    super.key,
    required this.firebaseId,
    required this.email,
    this.name,
    this.surname,
    required this.password,
  });
  final String firebaseId;
  final String email;
  final String password;
  final String? name;
  final String? surname;
  @override
  State<FillUserDataPage> createState() => _FillUserDataPageState();
}

class _FillUserDataPageState extends State<FillUserDataPage> {
  final DataCacher _cacher = DataCacher.instance;
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _phoneNumber;
  late final TextEditingController _birthdate;
  final AuthApi _api = AuthApi();
  static final UserApi _userApi = UserApi();
  final GlobalKey<FormState> _kForm = GlobalKey<FormState>();
  final List<String> _accountType = [
    "Job Seeker",
    "Employer",
  ];
  String? _accountTypeChoice;
  int get type => _accountTypeChoice == null
      ? 1
      : _accountTypeChoice! == "Job Seeker"
          ? 1
          : 2;
  final AppColors _colors = AppColors.instance;
  DateTime? _selectedDate;
  bool _isLoading = false;
  @override
  void initState() {
    _birthdate = TextEditingController()..text = "Select Date";
    _firstName = TextEditingController()..text = widget.name ?? "";
    _lastName = TextEditingController()..text = widget.surname ?? "";
    _phoneNumber = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _birthdate.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _phoneNumber.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async => !_isLoading,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Scaffold(
                backgroundColor: const Color(0xFFEEEEEE),
                body: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: Hero(
                            tag: "logo",
                            child: Column(children: [
                              Image.asset(
                                "assets/images/Logo.png",
                                height: 150,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Image.asset(
                                "assets/images/Terra-name.png",
                                height: 60,
                              )
                            ]),
                          ),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        Text(
                          "Account Setup".toUpperCase(),
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                            // border: Border.all(
                            //   color: Colors.grey,
                            // ),
                          ),
                          height: 60,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _accountTypeChoice,
                              hint: const Text("Job Seeker/Employer"),
                              isExpanded: true,
                              items: _accountType
                                  .map(
                                    (String e) => DropdownMenuItem<String>(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                setState(
                                  () {
                                    _accountTypeChoice = val;
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Form(
                          key: _kForm,
                          child: Column(
                            children: [
                              TextFormField(
                                validator: (text) {
                                  if (text == null) {
                                    return "Invalid type";
                                  } else if (text.isEmpty) {
                                    return "This field is required";
                                  }
                                },
                                decoration: const InputDecoration(
                                  hintText: "John",
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  label: Text(
                                    "Firstname",
                                  ),
                                ),
                                controller: _firstName,
                                keyboardType: TextInputType.emailAddress,
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
                                  }
                                },
                                decoration: const InputDecoration(
                                  hintText: "Doe",
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  label: Text(
                                    "Lastname",
                                  ),
                                ),
                                controller: _lastName,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                controller: _phoneNumber,
                                keyboardType: TextInputType.phone,
                                validator: (text) {
                                  if (text!.isEmpty) {
                                    return "This field is required";
                                  } else if (!("+63$text").isValidPhone()) {
                                    return "Invalid phone number";
                                  }
                                },
                                decoration: const InputDecoration(
                                  hintText: "9XXX-XXX-XXX",
                                  label: Text(
                                    "Phone number",
                                  ),
                                  fillColor: Colors.white,
                                  filled: true,
                                  // alignLabelWithHint: true,
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  prefixIcon: SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: Center(
                                      child: Text(
                                        "+63 ",
                                        style: TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              MaterialButton(
                                padding: const EdgeInsets.all(0),
                                onPressed: () async {
                                  await showDatePicker(
                                    context: context,
                                    initialDate: DateTime(
                                      DateTime.now().year - 15,
                                    ),
                                    firstDate: DateTime(1970),
                                    lastDate:
                                        DateTime(DateTime.now().year - 15, 31),
                                  ).then((value) {
                                    if (value != null) {
                                      _birthdate.text =
                                          DateFormat("MMM dd, yyyy")
                                              .format(value);
                                      _selectedDate = value;
                                    } else {
                                      _birthdate.text = "Select Date";
                                      _selectedDate = null;
                                    }
                                    if (mounted) setState(() {});
                                  });
                                },
                                child: TextFormField(
                                  validator: (text) {
                                    if (text == null) {
                                      return "Invalid type";
                                    } else if (text.isEmpty) {
                                      return "This field is required";
                                    } else if (_selectedDate == null) {
                                      return "This field is required";
                                    }
                                  },
                                  style: const TextStyle(
                                    color: Colors.black,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: "My birthday",
                                    fillColor: Colors.white,
                                    filled: true,
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                    ),
                                    label: Text(
                                      "Birthdate",
                                    ),
                                  ),
                                  enabled: false,
                                  controller: _birthdate,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        MaterialButton(
                          height: 60,
                          color: _colors.top,
                          onPressed: () async {
                            if (_accountTypeChoice == null) {
                              Fluttertoast.showToast(
                                msg: "Please choose an account type",
                              );
                              return;
                            }
                            if (_kForm.currentState!.validate()) {
                              setState(() {
                                _isLoading = true;
                              });
                              await _api
                                  .register(
                                firstName: _firstName.text,
                                lastName: _lastName.text,
                                email: widget.email,
                                password: widget.password,
                                accountType: type,
                                phoneNumber: _phoneNumber.text,
                                birthdate: _selectedDate!.toString(),
                                uid: widget.firebaseId,
                              )
                                  .then((v) async {
                                if (v != null) {
                                  await _userApi.details().then((user) {
                                    loggedUser = user;
                                  });
                                  await Future.delayed(
                                      const Duration(milliseconds: 700));
                                  await _cacher.setUserToken(v);
                                  await _cacher.signInMethod(0);
                                  accessToken = v;
                                  // if (loggedUser!.hasVerifiedEmail) {
                                  //   // ignore: use_build_context_synchronously
                                  //   await Navigator.pushReplacementNamed(
                                  //     context,
                                  //     "/check_page",
                                  //   );
                                  //   return;
                                  // }
                                  // ignore: use_build_context_synchronously
                                  await Navigator.pushReplacementNamed(
                                    context,
                                    "/check_page",
                                  );
                                } else {
                                  print("NULL VALUE");
                                }

                                _isLoading = false;
                                if (mounted) setState(() {});
                              });
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const SizedBox(
                            width: double.maxFinite,
                            child: Center(
                              child: Text(
                                "SUBMIT",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: MaterialButton(
                            height: 60,
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, "/");
                            },
                            child: const Center(
                              child: Text(
                                "Login with another account",
                                style: TextStyle(
                                  color: Color(0xFF4A4A4A),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading) ...{
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(.7),
                child: Center(
                  child: Image.asset("assets/images/loader.gif"),
                ),
              ),
            )
          }
        ],
      ),
    );
  }
}
