import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:terra/extension/int.dart';
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/models/category.dart';
import 'package:terra/services/API/job.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/view_model/categories_vm.dart';
import 'package:terra/views/home_page_children/home_page_main_children/map_update.dart';

class JobPostingPage extends StatefulWidget {
  const JobPostingPage(
      {super.key,
      required this.loadingCallback,
      required this.scrollController});
  final ValueChanged<bool> loadingCallback;
  final ScrollController scrollController;
  @override
  State<JobPostingPage> createState() => _JobPostingPageState();
}

class _JobPostingPageState extends State<JobPostingPage> {
  final AppColors _colors = AppColors.instance;
  final JobAPI _api = JobAPI.instance;
  final CategoriesVm _vm = CategoriesVm.instance;
  late final TextEditingController _title;
  late final TextEditingController _address;
  late final TextEditingController _landmark;
  late final TextEditingController _details;
  late final TextEditingController _price;
  bool isNegotiable = false;
  LatLng? latlng;
  int urgency = 1;
  int? selectedSkillId;
  @override
  void initState() {
    _title = TextEditingController();
    _details = TextEditingController();
    _address = TextEditingController();
    _landmark = TextEditingController();
    _price = TextEditingController()..text = "100";
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getCurrentLocation();
    });
    // TODO: implement initState
    super.initState();
  }

  bool hasCheckedGeo = false;
  getCurrentLocation() async {
    await Geolocator.checkPermission().then((value) async {
      if (value == LocationPermission.always ||
          value == LocationPermission.whileInUse) {
        if (!hasCheckedGeo) {
          setState(() {
            hasCheckedGeo = true;
          });
          await Geolocator.getCurrentPosition().then((v) async {
            latlng = LatLng(v.latitude, v.longitude);
            updateAddress(latlng!);
          }).whenComplete(() {
            hasCheckedGeo = false;
          });
        }
        if (mounted) setState(() {});
      }
    });
  }

  Future<void> updateAddress(LatLng v) async {
    final List<Placemark> address =
        await placemarkFromCoordinates(v.latitude, v.longitude);
    if (address.isNotEmpty) {
      _address.text =
          "${address.first.street ?? ""},${address.first.locality ?? ""}";
      // _city.text = address.first.locality ?? "UNKNOWN CITY";
      // _brgy.text = address.first.street ?? "UNKNOWN BRGY";
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _details.dispose();
    _price.dispose();
    _address.dispose();
    _landmark.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  final GlobalKey<FormState> _kForm = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        // backgroundColor: Colors.transparent,
        // resizeToAvoidBottomInset: true,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
          color: Colors.white,
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Container(
              width: 80,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Expanded(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: size.height * .6),
                child: SingleChildScrollView(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _kForm,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text.rich(
                              TextSpan(
                                text: "Title",
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                                children: [
                                  TextSpan(
                                      text: " *",
                                      style: TextStyle(
                                        color: Colors.red,
                                      )),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              // height: 55,
                              child: TextFormField(
                                validator: (text) {
                                  if (text == null) {
                                    return "Error initializing widget";
                                  } else if (text.isEmpty) {
                                    return "Field is required";
                                  }
                                },
                                controller: _title,
                                decoration: const InputDecoration(
                                  hintText: "Tell us about your offer",
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text.rich(
                              TextSpan(
                                text: "Complete address",
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                                children: [
                                  TextSpan(
                                      text: " *",
                                      style: TextStyle(
                                        color: Colors.red,
                                      )),
                                ],
                              ),
                            ),
                            Text(
                              "Terra fetches your current location, if location is enabled",
                              style: TextStyle(
                                  color: Colors.black.withOpacity(.3),
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              // height: 60,
                              child: TextFormField(
                                controller: _address,
                                enabled: false,
                                validator: (text) {
                                  if (text == null) {
                                    return "Error initializing widget";
                                  } else if (text.isEmpty) {
                                    return "Field is required";
                                  }
                                },
                                decoration: const InputDecoration(
                                  hintText: "Street, city",
                                ),
                              ),
                            ),
                            if (latlng != null) ...{
                              const SizedBox(
                                height: 2,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Lat: ${latlng!.latitude}, Lng: ${latlng!.longitude}",
                                      style: TextStyle(
                                        color: Colors.black.withOpacity(.2),
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxHeight: 20,
                                    ),
                                    child: TextButton(
                                      style: ButtonStyle(
                                        padding:
                                            MaterialStateProperty.resolveWith(
                                          (states) => EdgeInsets.zero,
                                        ),
                                        fixedSize:
                                            MaterialStateProperty.resolveWith(
                                          (_) => const Size.fromHeight(10),
                                        ),
                                      ),
                                      onPressed: () async {
                                        await showModalBottomSheet(
                                          enableDrag: false,
                                          constraints: BoxConstraints(
                                            maxHeight: size.height * .4,
                                          ),
                                          context: context,
                                          backgroundColor: Colors.transparent,
                                          builder: (
                                            _,
                                          ) =>
                                              MapUpdate(
                                            onPosChanged: (pos) {
                                              Navigator.of(context).pop();
                                              latlng = pos;
                                              updateAddress(latlng!);
                                              if (mounted) setState(() {});
                                            },
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        "Change",
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            }
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text.rich(
                              TextSpan(
                                text: "Landmark",
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                                children: [
                                  TextSpan(
                                      text: " *",
                                      style: TextStyle(
                                        color: Colors.red,
                                      )),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              child: TextFormField(
                                controller: _landmark,
                                maxLines: 3,
                                validator: (text) {
                                  if (text == null) {
                                    return "Error initializing widget";
                                  } else if (text.isEmpty) {
                                    return "Field is required";
                                  }
                                },
                                decoration: const InputDecoration(
                                  hintText: "Put landmark or describe location",
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            const Expanded(
                              flex: 4,
                              child: Text.rich(
                                TextSpan(
                                  text: "Urgency",
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  children: [
                                    TextSpan(
                                        text: " *",
                                        style: TextStyle(
                                          color: Colors.red,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              flex: 7,
                              child: SizedBox(
                                height: 60,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButtonFormField<int>(
                                    isExpanded: true,
                                    // isDense: true,
                                    value: urgency,

                                    // selectedItemBuilder: (_) => [Text("ASDASD")],
                                    items: [1, 2, 3]
                                        .map((e) => DropdownMenuItem<int>(
                                              value: e,
                                              child: Text(
                                                e.toUrgency(),
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (v) {
                                      if (v == null) return;
                                      urgency = v;
                                      if (mounted) setState(() {});
                                    },
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text.rich(
                                    TextSpan(
                                      text: "Price",
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      children: [
                                        TextSpan(
                                            text: " *",
                                            style: TextStyle(
                                              color: Colors.red,
                                            )),
                                      ],
                                    ),
                                  ),
                                  // const Text(
                                  //   "Price",
                                  // style: TextStyle(
                                  //   fontSize: 13.5,
                                  //   fontWeight: FontWeight.w600,
                                  // ),
                                  // ),
                                  Text(
                                    "Enter your price",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black.withOpacity(.4),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              flex: 3,
                              child: SizedBox(
                                child: TextFormField(
                                  cursorColor: _colors.top,
                                  controller: _price,
                                  validator: (text) {
                                    if (text == null) {
                                      return "Error initializing widget";
                                    } else if (text.isEmpty) {
                                      return "Field is required";
                                    } else if (!text.isValidInt()) {
                                      return "Invalid value";
                                    }
                                  },
                                  decoration: const InputDecoration(
                                    errorStyle:
                                        TextStyle(fontSize: 9, height: 1),
                                    errorMaxLines: 1,
                                    prefix: Text("₱"),
                                    counterText: "",
                                  ),
                                  maxLength: 5,
                                  maxLengthEnforcement:
                                      MaxLengthEnforcement.enforced,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: false, signed: false),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            const Expanded(
                              flex: 5,
                              child: Text.rich(
                                TextSpan(
                                  text: "Is negotiable?",
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  children: [
                                    TextSpan(
                                        text: " *",
                                        style: TextStyle(
                                          color: Colors.red,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Switch.adaptive(
                              value: isNegotiable,
                              activeColor: _colors.top,
                              onChanged: (v) => setState(
                                () {
                                  isNegotiable = v;
                                },
                              ),
                            ),
                          ],
                        ),
                        StreamBuilder<List<Category>>(
                          stream: _vm.stream,
                          builder: (_, snapshot) {
                            if (snapshot.hasError || !snapshot.hasData) {
                              return const Text("Unable to fetch skills");
                            }
                            final List<Category> _result = snapshot.data!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text.rich(
                                  TextSpan(
                                    text: "Choose skill",
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    children: [
                                      TextSpan(
                                          text: " *",
                                          style: TextStyle(
                                            color: Colors.red,
                                          )),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Wrap(
                                  spacing: 10,
                                  children:
                                      List.generate(_result.length, (index) {
                                    final Category _cat = _result[index];
                                    return InputChip(
                                      selected: selectedSkillId == _cat.id,
                                      showCheckmark: false,
                                      selectedColor: _colors.bot,
                                      onSelected: (t) {
                                        print(t);
                                        if (t) {
                                          selectedSkillId = _cat.id;
                                        } else {
                                          selectedSkillId = null;
                                        }
                                        if (mounted) setState(() {});
                                      },
                                      avatar: Image.network(_cat.icon),
                                      label: Text(
                                        _cat.name,
                                        style: TextStyle(
                                          color: selectedSkillId == _cat.id
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    );
                                  }),
                                )
                              ],
                            );
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SafeArea(
                          top: false,
                          child: MaterialButton(
                            height: 55,
                            color: _colors.top,
                            onPressed: () async {
                              if (_kForm.currentState!.validate() &&
                                  latlng != null &&
                                  selectedSkillId != null) {
                                widget.loadingCallback(true);
                                Navigator.of(context).pop(null);
                                await _api.postAJob(
                                  title: _title.text,
                                  completeAddress: _address.text,
                                  brgy: _address.text.split(',').first,
                                  city: _address.text.split(',').last,
                                  landmark: _landmark.text,
                                  urgency: urgency,
                                  rate: double.parse(_price.text),
                                  latlong:
                                      "${latlng!.latitude},${latlng!.longitude}",
                                  categoryId: selectedSkillId!,
                                );
                                widget.loadingCallback(false);
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Please fill all fields");
                              }
                            },
                            child: const Center(
                                child: Text(
                              "Post",
                              style: TextStyle(color: Colors.white),
                            )),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
