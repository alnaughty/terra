import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/models/category.dart';
import 'package:terra/models/user_details.dart';
import 'package:terra/services/API/offers.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/view_model/categories_vm.dart';

class JobHiringDialog extends StatefulWidget {
  const JobHiringDialog({
    super.key,
    required this.recruitee,
  });
  final UserDetails recruitee;
  @override
  State<JobHiringDialog> createState() => _JobHiringDialogState();
}

class _JobHiringDialogState extends State<JobHiringDialog> {
  final AppColors _colors = AppColors.instance;
  final OfferApi _api = OfferApi();
  final CategoriesVm _vm = CategoriesVm.instance;
  late final TextEditingController _price;
  late final TextEditingController _message;
  late final TextEditingController _duration;
  DateTime? startDate;

  @override
  void initState() {
    _price = TextEditingController();
    _message = TextEditingController();
    _duration = TextEditingController();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _message.dispose();
    _price.dispose();
    _duration.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  bool isLoading = false;
  int? selectedCategoryId;
  final GlobalKey<FormState> _kForm = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: size.height * .6),
        child: SingleChildScrollView(
          child: isLoading
              ? Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: _colors.top,
                    size: 30,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      minVerticalPadding: 0.0,
                      contentPadding: const EdgeInsets.all(0),
                      title: Text(
                        widget.recruitee.fullName,
                        style: TextStyle(
                          color: _colors.bot,
                        ),
                      ),
                      subtitle: Text(
                        widget.recruitee.email,
                      ),
                    ),
                    Form(
                      key: _kForm,
                      child: Column(
                        children: [
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
                                      "Your price for ${widget.recruitee.firstName}",
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
                                  height: 50,
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
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text.rich(
                                      TextSpan(
                                        text: "Duration",
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
                                      "How many days for this job?",
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
                                  height: 50,
                                  child: TextFormField(
                                    cursorColor: _colors.top,
                                    controller: _duration,
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
                                      suffix: Text("Days"),
                                      counterText: "",
                                      errorStyle:
                                          TextStyle(fontSize: 9, height: 1),
                                    ),
                                    maxLength: 3,
                                    maxLengthEnforcement:
                                        MaxLengthEnforcement.enforced,
                                    keyboardType: TextInputType.number,
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
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text.rich(
                                      TextSpan(
                                        text: "Start date",
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
                                      "When will ${widget.recruitee.firstName} start?",
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
                                child: MaterialButton(
                                  height: 35,
                                  color: Colors.grey.shade200,
                                  onPressed: () async {
                                    await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now().add(
                                        const Duration(days: 5),
                                      ),
                                      firstDate: DateTime.now().subtract(
                                        const Duration(
                                          days: 365,
                                        ),
                                      ),
                                      lastDate: DateTime.now().add(
                                        const Duration(
                                          days: 365,
                                        ),
                                      ),
                                    ).then((value) {
                                      startDate = value;
                                      if (mounted) setState(() {});
                                    });
                                  },
                                  child: Center(
                                    child: Text(
                                      startDate == null
                                          ? "Choose date"
                                          : DateFormat("MMM. dd, y")
                                              .format(startDate!),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black.withOpacity(.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text.rich(
                                    TextSpan(
                                      text: "Hire as",
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
                                    "Choose the job for ${widget.recruitee.firstName}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black.withOpacity(.4),
                                    ),
                                  )
                                ],
                              ),
                              StreamBuilder<List<Category>>(
                                stream: _vm.stream,
                                builder: (_, snapshot) {
                                  if (snapshot.hasError || !snapshot.hasData) {
                                    return const Text("Unable to fetch skills");
                                  }
                                  final List<Category> _result = snapshot.data!;
                                  return Wrap(
                                    spacing: 10,
                                    children:
                                        List.generate(_result.length, (index) {
                                      final Category _cat = _result[index];
                                      return InputChip(
                                        selected: selectedCategoryId == _cat.id,
                                        showCheckmark: false,
                                        selectedColor: _colors.bot,
                                        onSelected: (t) {
                                          print(t);
                                          if (t) {
                                            selectedCategoryId = _cat.id;
                                          } else {
                                            selectedCategoryId = null;
                                          }
                                          if (mounted) setState(() {});
                                        },
                                        avatar: Image.network(_cat.icon),
                                        label: Text(
                                          _cat.name,
                                          style: TextStyle(
                                            color: selectedCategoryId == _cat.id
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      );
                                    }),
                                  );
                                },
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Message",
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "This field is optional",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black.withOpacity(.4),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextField(
                          cursorColor: _colors.top,
                          controller: _message,
                          maxLength: 80,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText:
                                "What do you wanna say to ${widget.recruitee.firstName}?",
                          ),
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          selectionHeightStyle:
                              BoxHeightStyle.includeLineSpacingMiddle,
                          keyboardType: TextInputType.multiline,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    MaterialButton(
                      onPressed: () async {
                        bool formValid = _kForm.currentState!.validate();
                        if (formValid &&
                            startDate != null &&
                            selectedCategoryId != null) {
                          // widget.onHire();
                          FocusScope.of(context).unfocus();
                          setState(() {
                            isLoading = true;
                          });
                          await _api
                              .hireJobseeker(
                                  jobseekerId: widget.recruitee.id,
                                  startdate: startDate,
                                  rate: double.parse(_price.text),
                                  duration: int.parse(_duration.text),
                                  message: _message.text.isNotEmpty
                                      ? _message.text
                                      : null,
                                  skillId: selectedCategoryId!)
                              .whenComplete(() {
                            isLoading = false;
                            Navigator.of(context).pop(null);
                          });
                        } else {
                          Fluttertoast.showToast(
                              msg: "Dont leave required fields!");
                        }
                      },
                      height: 50,
                      color: _colors.top,
                      child: const Center(
                        child: Text(
                          "HIRE",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
