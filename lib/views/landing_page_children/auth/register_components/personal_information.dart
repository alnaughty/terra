import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:terra/extension/string_extensions.dart';

class PersonalInfoPage extends StatefulWidget {
  PersonalInfoPage({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.city,
    required this.country,
    required this.street,
    required this.birthdate,
  });
  final TextEditingController firstName;
  final TextEditingController lastName;
  final TextEditingController city;
  final TextEditingController country;
  final TextEditingController street;
  final TextEditingController phoneNumber;
  final TextEditingController birthdate;
  @override
  State<PersonalInfoPage> createState() => PersonalInfoPageState();
}

class PersonalInfoPageState extends State<PersonalInfoPage> {
  final GlobalKey<FormState> _kForm = GlobalKey<FormState>();

  bool validate() => _kForm.currentState!.validate() && hasBirthday();
  bool hasBirthday() {
    if (widget.birthdate.text.isNotEmpty) {
      return true;
    }
    Fluttertoast.showToast(msg: "You must provide your birthdate");
    return false;
  }

  void getLocation() async {
    final LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final List<Placemark> address =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      // final Address address = await GeoCode().reverseGeocoding(
      //   latitude: position.latitude,
      //   longitude: position.longitude,
      // );
      if (address.isEmpty) return;
      widget.city.text = address.first.locality ?? "";
      widget.country.text = address.first.country ?? "";
      widget.street.text = address.first.street ?? "";
      print("ADDRESSED :$address");
      if (mounted) setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getLocation();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 15,
      ),
      children: [
        Text(
          "Personal Information",
          style: TextStyle(
            color: Colors.grey.shade900,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Text(
          "Terra assure's you that your personal information is safe, and won't be shared/used on other platform.",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Form(
          key: _kForm,
          child: Column(
            children: [
              namedField(
                name: "Firstname",
                child: TextFormField(
                  controller: widget.firstName,
                  validator: (text) {
                    if (text!.isEmpty) {
                      return "This Field is required";
                    } else if (text.length < 3) {
                      return "Names cannot contain less than 3 characters";
                    }
                  },
                  keyboardType: TextInputType.name,
                  decoration: const InputDecoration(
                    hintText: "My name",
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              namedField(
                name: "Lastname",
                child: TextFormField(
                  controller: widget.lastName,
                  validator: (text) {
                    if (text!.isEmpty) {
                      return "This field is required";
                    } else if (text.length < 3) {
                      return "Last names cannot contain less than 3 characters";
                    }
                  },
                  keyboardType: TextInputType.name,
                  decoration: const InputDecoration(
                    hintText: "My lastname",
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              namedField(
                name: "Birthdate",
                child: Container(
                  height: 60,
                  // width: 200,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey,
                    ),
                  ),
                  // child: TextFormField(
                  //   controller: widget.birthdate,
                  //   keyboardType: TextInputType.datetime,
                  //   enabled: true,
                  //   onChanged: (text) {
                  //     FocusScope.of(context).unfocus();
                  //     widget.birthdate.text =
                  //         text.substring(0, text.length - 1);
                  //     setState(() {});
                  //   },
                  //   onTap: () async {
                  //     print("ASDASD");
                  //     FocusScope.of(context).unfocus();
                  // await showDatePicker(
                  //   context: context,
                  //   initialDate: DateTime(
                  //     DateTime.now().year - 15,
                  //   ),
                  //   firstDate: DateTime(1970),
                  //   lastDate: DateTime(DateTime.now().year - 15, 31),
                  // ).then((value) {
                  //   if (value != null) {
                  //     setState(() {
                  //       widget.birthdate.text =
                  //           DateFormat("MMMM dd, yyyy").format(value);
                  //     });
                  //   }
                  // });
                  //   },
                  //   validator: (text) {
                  //     if (text!.isEmpty) {
                  //       return "This field is required";
                  //     }
                  //   },
                  //   decoration: const InputDecoration(
                  //     hintText: "My birthday",
                  //   ),
                  // ),
                  child: MaterialButton(
                    onPressed: () async {
                      await showDatePicker(
                        context: context,
                        initialDate: DateTime(
                          DateTime.now().year - 15,
                        ),
                        firstDate: DateTime(1970),
                        lastDate: DateTime(DateTime.now().year - 15, 31),
                      ).then((value) {
                        if (value != null) {
                          setState(() {
                            widget.birthdate.text = value.toString();
                            // DateFormat("MMMM dd, yyyy").format(value);
                          });
                        }
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.birthdate.text.isEmpty
                          ? "No selected date"
                          : DateFormat("MMMM dd, yyyy")
                              .format(DateTime.parse(widget.birthdate.text)),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              namedField(
                name: "Country",
                child: TextFormField(
                  controller: widget.country,
                  keyboardType: TextInputType.streetAddress,
                  validator: (text) {
                    if (text!.isEmpty) {
                      return "This field is required";
                    }
                  },
                  decoration: const InputDecoration(
                    hintText: "Country",
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              namedField(
                name: "City",
                child: TextFormField(
                  controller: widget.city,
                  keyboardType: TextInputType.streetAddress,
                  validator: (text) {
                    if (text!.isEmpty) {
                      return "This field is required";
                    }
                  },
                  decoration: const InputDecoration(
                    hintText: "City/State/Municipality",
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              namedField(
                name: "Street",
                child: TextFormField(
                  controller: widget.street,
                  minLines: 1,
                  maxLines: 3,
                  keyboardType: TextInputType.streetAddress,
                  validator: (text) {
                    if (text!.isEmpty) {
                      return "This field is required";
                    }
                  },
                  decoration: const InputDecoration(
                    hintText: "Street",
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              namedField(
                name: "Phone number",
                child: TextFormField(
                  controller: widget.phoneNumber,
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
                    prefixIcon: SizedBox(
                      width: 60,
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
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget namedField({required String name, required Widget child}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
                text: name,
                style: TextStyle(
                  color: Colors.grey.shade900,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                children: const [
                  TextSpan(
                      text: " *",
                      style: TextStyle(
                        color: Colors.red,
                      ))
                ]),
          ),
          // Text(
          //   name,

          // ),
          const SizedBox(
            height: 5,
          ),
          child,
        ],
      );
}
