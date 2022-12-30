import 'package:flutter/material.dart';
import 'package:terra/models/job.dart';
import 'package:terra/services/API/job.dart';
import 'package:terra/utils/color.dart';

class JobDetailsViewer extends StatefulWidget {
  const JobDetailsViewer(
      {super.key, required this.job, required this.loadingCallback});
  final Job job;
  final ValueChanged<bool> loadingCallback;
  @override
  State<JobDetailsViewer> createState() => _JobDetailsViewerState();
}

class _JobDetailsViewerState extends State<JobDetailsViewer> {
  final AppColors _colors = AppColors.instance;
  final JobAPI _api = JobAPI.instance;
  late final TextEditingController _negotiate;
  void apply(double price) async {
    widget.loadingCallback(true);
    await _api
        .apply(
      id: widget.job.id,
      rate: price,
    )
        .then((value) {
      widget.job.hasApplied = value;
      widget.loadingCallback(false);
    });
  }

  void cancelApplication() async {
    widget.loadingCallback(true);
    await _api
        .cancel(
      id: widget.job.id,
    )
        .then((value) {
      if (value) {
        widget.job.hasApplied = false;
      }
      widget.loadingCallback(false);
    });
  }

  @override
  void initState() {
    _negotiate = TextEditingController();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _negotiate.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  late double negotiatedPrice = widget.job.price;
  bool isNegotiating = false;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey.shade100,
        ),
        constraints: BoxConstraints(
            maxWidth: 400, maxHeight: size.height * .8, minHeight: 100),
        width: size.width * .8,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row(
              //   children: [
              // ClipRRect(
              //   borderRadius: BorderRadius.circular(60),
              //   child: Container(
              //     width: 50,
              //     height: 50,
              //     color: Colors.white,
              //     child: Image.network(
              //       widget.job.postedBy.avatar,
              //     ),
              //   ),
              // ),
              //     const SizedBox(
              //       width: 10,
              //     ),

              //   ],
              // ),
              ListTile(
                contentPadding: const EdgeInsets.all(0),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Container(
                    width: 50,
                    height: 50,
                    color: Colors.white,
                    child: Image.network(
                      widget.job.postedBy.avatar,
                    ),
                  ),
                ),
                title: Text(
                  widget.job.postedBy.fullName,
                  maxLines: 2,
                  style: const TextStyle(
                    height: 1,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                subtitle: Text(
                  widget.job.postedBy.email,
                  style: TextStyle(
                    color: Colors.black.withOpacity(.5),
                    fontStyle: FontStyle.italic,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Text(
                widget.job.title,
                style: TextStyle(
                  color: Colors.black.withOpacity(.6),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Wrap(
                spacing: 5,
                runSpacing: 0,
                children: [
                  Chip(
                    avatar: Image.network(
                      widget.job.category.icon,
                    ),
                    label: Text(
                      widget.job.category.name,
                      style: TextStyle(
                        color: Colors.black.withOpacity(.7),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Chip(
                    backgroundColor:
                        widget.job.status.toLowerCase() == "available"
                            ? _colors.top
                            : Colors.red,
                    label: Text(
                      widget.job.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                      ),
                    ),
                  ),
                  if (widget.job.isNegotiable) ...{
                    Chip(
                      backgroundColor: _colors.mid,
                      label: Text(
                        "negotiable".toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  },
                  Chip(
                    backgroundColor: _colors.bot,
                    label: Text(
                      widget.job.urgency == 1
                          ? "NOT URGENT"
                          : widget.job.urgency == 2
                              ? "MILD URGENCY"
                              : "ASAP",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
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
                  Icon(
                    Icons.location_city,
                    color: _colors.top,
                    size: 20,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Text(
                      "${widget.job.city[0].toUpperCase()}${widget.job.city.substring(1)}",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.black.withOpacity(.7),
                        decoration: TextDecoration.underline,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Divider(
                color: Colors.black.withOpacity(.2),
              ),
              Tooltip(
                message: "Complete address",
                child: GestureDetector(
                  onTap: () {},
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: _colors.top,
                        size: 20,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          widget.job.address,
                          maxLines: 20,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.black.withOpacity(.7),
                            decoration: TextDecoration.underline,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.job.landmark != null ||
                  widget.job.landmark!.isNotEmpty) ...{
                Divider(
                  color: Colors.black.withOpacity(.2),
                ),
                Row(
                  children: [
                    Text(
                      "Nearest landmark:",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        widget.job.landmark!,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: _colors.bot,
                        ),
                      ),
                    )
                  ],
                ),
              },
              Divider(
                color: Colors.black.withOpacity(.2),
              ),
              Row(
                children: [
                  Text(
                    "Employer Price:",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text("₱${widget.job.price.toStringAsFixed(2)}",
                          style: TextStyle(
                            color: _colors.bot,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          )),
                    ),
                  )
                ],
              ),
              if (negotiatedPrice != widget.job.price) ...{
                Row(
                  children: [
                    Text(
                      "Negotiated Price:",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text("₱${negotiatedPrice.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: _colors.bot,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                    )
                  ],
                ),
              },
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: isNegotiating ? 50 : 0,
                child: Row(
                  children: [
                    Text(
                      "Your Price:",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    if (isNegotiating) ...{
                      Expanded(
                        child: TextField(
                          controller: _negotiate,
                          keyboardType: TextInputType.number,
                        ),
                      )
                    },
                  ],
                ),
                // child: isNegotiating ? : Container(),
              ),
              const SizedBox(
                height: 10,
              ),
              if (widget.job.hasApplied) ...{
                MaterialButton(
                  onPressed: () async {
                    Navigator.of(context).pop(null);
                    cancelApplication();
                  },
                  height: 50,
                  color: Colors.red,
                  child: Center(
                    child: Text(
                      "cancel application".toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              } else ...{
                Row(
                  children: [
                    if (widget.job.isNegotiable) ...{
                      Expanded(
                        child: MaterialButton(
                          onPressed: () async {
                            setState(() {
                              isNegotiating = !isNegotiating;
                            });
                            if (!isNegotiating) {
                              negotiatedPrice = double.parse(_negotiate.text);
                            } else {
                              _negotiate.text =
                                  negotiatedPrice.toStringAsFixed(2);
                            }
                            if (mounted) setState(() {});
                            // Navigator.of(context).pop(null);
                            // apply(widget.job.isNegotiable
                            //     ? negotiatedPrice
                            //     : widget.job.price);
                            // if (widget.job.isNegotiable) {
                            // } else {

                            // }
                          },
                          height: 50,
                          color: _colors.bot,
                          child: Center(
                            child: Text(
                              isNegotiating
                                  ? "Apply negotiation price"
                                  : "Negotiate Price",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                    },
                    Expanded(
                      child: MaterialButton(
                        onPressed: () async {
                          Navigator.of(context).pop(null);
                          apply(widget.job.isNegotiable
                              ? negotiatedPrice
                              : widget.job.price);
                          // if (widget.job.isNegotiable) {
                          // } else {

                          // }
                        },
                        height: 50,
                        color: _colors.top,
                        child: const Center(
                          child: Text(
                            "APPLY NOW",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              }
              // Text(
              //   widget.job.title,
              // )
            ],
          ),
        ),
      ),
    );
  }
}
