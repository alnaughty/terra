import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:terra/extension/int.dart';
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/models/category.dart';
import 'package:terra/models/v2/raw_task.dart';
import 'package:terra/services/API/job.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/view_model/categories_vm.dart';
import 'package:terra/views/home_page_children/home_page_main_children/map_update.dart';

class PostedControlCenter extends StatefulWidget {
  const PostedControlCenter({
    super.key,
    required this.task,
    this.isEditing = false,
    required this.updateCallback,
  });
  final RawTaskV2 task;
  final bool isEditing;
  final ValueChanged<bool> updateCallback;
  @override
  State<PostedControlCenter> createState() => _PostedControlCenterState();
}

class _PostedControlCenterState extends State<PostedControlCenter> {
  final AppColors _colors = AppColors.instance;
  final JobAPI _api = JobAPI.instance;
  late final TextEditingController _title;
  late final TextEditingController _address;
  late final TextEditingController _landmark;
  late final TextEditingController _price;
  final CategoriesVm _vm = CategoriesVm.instance;
  late bool isNegotiable = widget.task.isNegotiable;
  late LatLng? latlng = widget.task.coordinates;
  late int urgency = widget.task.urgency ?? 1;
  late int? selectedSkillId = widget.task.category.id;
  @override
  void initState() {
    _title = TextEditingController()..text = widget.task.category.name;
    _address = TextEditingController()..text = widget.task.address;
    _landmark = TextEditingController();
    _price = TextEditingController()..text = widget.task.rate.toString();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getCurrentLocation();
    });

    super.initState();
  }

  bool _isLoading = false;
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
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _address.dispose();
    _landmark.dispose();

    super.dispose();
  }

  late bool toEdit = widget.isEditing;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Positioned.fill(
            child: Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text(
                    "${toEdit ? "Edit task" : "Task Details"} (${widget.task.status.capitalizeWords()})"),
              ),
              body: SafeArea(
                top: false,
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Complete address",
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
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
                              if (toEdit) ...{
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
                              },
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
                        const Text(
                          "Description",
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          child: TextFormField(
                            controller: _landmark
                              ..text = widget.task.message ?? "Say something",
                            maxLines: 3,
                            enabled: toEdit,
                            validator: (text) {
                              if (text == null) {
                                return "Error initializing widget";
                              } else if (text.isEmpty) {
                                return "Field is required";
                              }
                            },
                            decoration: const InputDecoration(
                              hintText: "Describe or specify the job",
                            ),
                          ),
                        )
                      ],
                    ),
                    if (loggedUser!.accountType != 1) ...{
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Expanded(
                            flex: 4,
                            child: Text(
                              "Urgency",
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 7,
                            child: SizedBox(
                              height: 65,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButtonFormField<int>(
                                  isExpanded: true,
                                  value: urgency,
                                  items: [1, 2, 3]
                                      .map((e) => DropdownMenuItem<int>(
                                            value: e,
                                            child: Text(
                                              e.toUrgency(),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: toEdit
                                      ? (v) {
                                          if (v == null) return;
                                          urgency = v;
                                          if (mounted) setState(() {});
                                        }
                                      : null,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    },
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
                              const Text(
                                "Price",
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "${toEdit ? "Enter y" : "Y"}our price",
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
                              enabled: toEdit,
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
                                errorStyle: TextStyle(fontSize: 9, height: 1),
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
                          child: Text(
                            "Is negotiable?",
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Switch.adaptive(
                          value: isNegotiable,
                          activeColor: _colors.top,
                          onChanged: toEdit
                              ? (v) => setState(
                                    () {
                                      isNegotiable = v;
                                    },
                                  )
                              : null,
                        ),
                      ],
                    ),
                    StreamBuilder<List<Category>>(
                      stream: _vm.stream,
                      builder: (_, snapshot) {
                        if (snapshot.hasError || !snapshot.hasData) {
                          return const Text("Unable to fetch skills");
                        }
                        final List<Category> _result =
                            loggedUser!.accountType == 1
                                ? loggedUser!.skills
                                : snapshot.data!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              toEdit ? "Choose Skill" : "Associated Skill",
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            _result.isEmpty
                                ? SizedBox(
                                    height: 60,
                                    width: double.maxFinite,
                                    child: Center(
                                      child: Text(
                                        "You need to add some skills to post",
                                        style: TextStyle(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                    ),
                                  )
                                : Wrap(
                                    spacing: 10,
                                    children:
                                        List.generate(_result.length, (index) {
                                      final Category _cat = _result[index];
                                      return InputChip(
                                        selected: selectedSkillId == _cat.id,
                                        showCheckmark: false,
                                        selectedColor: _colors.bot,
                                        onSelected: toEdit
                                            ? (t) {
                                                print(t);
                                                if (t) {
                                                  selectedSkillId = _cat.id;
                                                  _title.text = _cat.name;
                                                } else {
                                                  selectedSkillId = null;
                                                  _title.clear();
                                                }
                                                if (mounted) setState(() {});
                                              }
                                            : null,
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
                    if (toEdit) ...{
                      const SizedBox(
                        height: 20,
                      ),
                      MaterialButton(
                        height: 55,
                        color: _colors.top,
                        onPressed: () async {
                          final Map<String, dynamic> body = {};
                          // brgy: _address.text.split(',').first,
                          //   city: _address.text.split(',').last,
                          if (_title.text.toLowerCase() !=
                              widget.task.category.name.toLowerCase()) {
                            body.addAll({
                              "title": _title.text,
                            });
                          }
                          if (_address.text.toLowerCase() !=
                              widget.task.address.toLowerCase()) {
                            body.addAll({
                              "complete_address": _address.text,
                            });
                          }
                          if (_landmark.text != widget.task.message) {
                            body.addAll({
                              "message": _landmark.text,
                            });
                          }
                          if (_address.text.split(',').last !=
                              widget.task.address.split(",").last) {
                            body.addAll(
                                {"city": _address.text.split(',').last});
                          }
                          if (urgency != widget.task.urgency) {
                            body.addAll({"urgency": "$urgency"});
                          }
                          if (double.parse(_price.text) != widget.task.rate) {
                            body.addAll({
                              "rate": "${double.parse(_price.text)}",
                            });
                          }
                          if (latlng != widget.task.coordinates) {
                            body.addAll({
                              "latlong":
                                  "${latlng!.latitude},${latlng!.longitude}"
                            });
                          }
                          if (selectedSkillId != widget.task.category.id) {
                            body.addAll({"category_id": "$selectedSkillId"});
                          }
                          if (isNegotiable != widget.task.isNegotiable) {
                            body.addAll(
                                {"is_negotiable": "${isNegotiable ? 1 : 0}"});
                          }
                          if (body.isEmpty) {
                            Fluttertoast.showToast(
                                msg: "Please change something.");
                          } else {
                            setState(() {
                              _isLoading = true;
                            });
                            await _api
                                .updateTask(widget.task.id, body)
                                .then(
                                  (value) => widget.updateCallback(value),
                                )
                                .whenComplete(() {
                              _isLoading = false;
                              if (mounted) setState(() {});
                            });
                          }
                        },
                        child: const Center(
                            child: Text(
                          "Update",
                          style: TextStyle(color: Colors.white),
                        )),
                      ),
                    },
                    const SizedBox(
                      height: 20,
                    ),
                  ],
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
          },
        ],
      ),
    );
  }
}
