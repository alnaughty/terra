import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/services/API/user_api.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';

class UpdateUserDetailsPage extends StatefulWidget {
  const UpdateUserDetailsPage({super.key});

  @override
  State<UpdateUserDetailsPage> createState() => _UpdateUserDetailsPageState();
}

class _UpdateUserDetailsPageState extends State<UpdateUserDetailsPage> {
  final AppColors _colors = AppColors.instance;
  late final TextEditingController _fn;
  late final TextEditingController _ln;
  late final TextEditingController _birthdate;
  late final TextEditingController _phoneNumber;
  bool _isEditing = false;
  final UserApi _api = UserApi();

  @override
  void initState() {
    // TODO: implement initState
    _ln = TextEditingController()
      ..text = loggedUser!.lastName.capitalizeWords();
    _fn = TextEditingController()
      ..text = loggedUser!.firstName.capitalizeWords();
    _birthdate = TextEditingController()
      ..text = loggedUser!.birthdate.toString();
    _phoneNumber = TextEditingController()..text = loggedUser!.phoneNumber;
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _fn.dispose();
    _ln.dispose();
    _birthdate.dispose();
    _phoneNumber.dispose();
    super.dispose();
  }

  Widget field({
    required TextEditingController controller,
    Widget? leading,
    TextInputType inputType = TextInputType.name,
    bool isEditable = true,
    Function()? onTap,
  }) =>
      Container(
        decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10)),
        child: TextField(
          onTap: onTap,
          keyboardType: inputType,
          enabled: isEditable ? _isEditing : false,
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: leading,
          ),
        ),
      );
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Positioned.fill(
            child: Scaffold(
              backgroundColor: Colors.grey.shade200,
              appBar: AppBar(
                backgroundColor: Colors.white,
                centerTitle: true,
                title: const Text("User Details"),
                actions: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = !_isEditing;
                      });
                    },
                    icon: Icon(
                      Icons.edit,
                      color: _isEditing ? _colors.top : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              body: Container(
                padding: const EdgeInsets.all(20),
                child: SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    width: double.maxFinite,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Few information about you",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            "These are the information you provided to us. you can edit it as you want except the provided email address.",
                            style: TextStyle(
                              color: Colors.black.withOpacity(.5),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          field(
                            controller: _fn,
                            leading: Icon(
                              Icons.person_2,
                              color: _colors.top,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          field(
                            controller: _ln,
                            leading: Icon(
                              Icons.person_2,
                              color: _colors.top,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          field(
                            controller: TextEditingController()
                              ..text = loggedUser!.email,
                            isEditable: false,
                            leading: Icon(
                              Icons.email_rounded,
                              color: _colors.top,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          field(
                            controller: _phoneNumber,
                            inputType: TextInputType.number,
                            leading: Icon(
                              Icons.phone,
                              color: _colors.top,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          MaterialButton(
                            onPressed: _isEditing
                                ? () async {
                                    await showDatePicker(
                                      context: context,
                                      initialDate:
                                          DateTime.parse(_birthdate.text),
                                      firstDate: DateTime(1970),
                                      lastDate: DateTime.now(),
                                    ).then((value) {
                                      if (value != null) {
                                        setState(() {
                                          _birthdate.text = value.toString();
                                          // DateFormat("MMMM dd, yyyy").format(value);
                                        });
                                      }
                                    });
                                  }
                                : null,
                            height: 60,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            color: Colors.grey.shade100,
                            disabledColor: Colors.grey.shade100,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.date_range,
                                  color: _colors.top,
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  DateFormat("MMM dd, yyyy")
                                      .format(DateTime.parse(_birthdate.text)),
                                )
                              ],
                            ),
                          ),
                          // field(
                          //   controller: _birthdate,
                          //   inputType: TextInputType.none,
                          //   onTap: () async {},
                          //   leading: Icon(
                          //     Icons.date_range,
                          //     color: _colors.top,
                          //   ),
                          // ),
                          // Container(
                          //   decoration: BoxDecoration(
                          //       color: Colors.grey.shade100,
                          //       borderRadius: BorderRadius.circular(10)),
                          //   child: TextField(
                          //     enabled: _isEditing,
                          //     controller: _fn,
                          //   ),
                          // ),
                          if (_isEditing) ...{
                            const SizedBox(
                              height: 30,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _colors.bot,
                                    _colors.top,
                                  ],
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                ),
                                // color: _colors.bot,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: MaterialButton(
                                height: 60,
                                onPressed: () async {
                                  Map<String, dynamic> body = {};
                                  if (loggedUser!.firstName != _fn.text &&
                                      _fn.text.isNotEmpty) {
                                    body.addAll({"first_name": _fn.text});
                                  }
                                  if (loggedUser!.lastName != _ln.text &&
                                      _ln.text.isNotEmpty) {
                                    body.addAll({"last_name": _ln.text});
                                  }
                                  if (loggedUser!.phoneNumber !=
                                          _phoneNumber.text &&
                                      _phoneNumber.text.isNotEmpty) {
                                    body.addAll({
                                      "mobile_number": _phoneNumber.text,
                                    });
                                  }
                                  if (loggedUser!.birthdate !=
                                          DateTime.parse(_birthdate.text) &&
                                      _birthdate.text.isNotEmpty) {
                                    body.addAll({
                                      "birthdate": _birthdate.text,
                                    });
                                  }
                                  print("BODY : $body");
                                  if (body.isNotEmpty) {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    await _api
                                        .updateDetails(body)
                                        .then((value) async {
                                      if (value) {
                                        await _api.details().then((v) {
                                          loggedUser = v;
                                          if (mounted) setState(() {});
                                        });
                                      }
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    });
                                  }
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.save,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "Save",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          },
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading) ...{
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(.5),
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
