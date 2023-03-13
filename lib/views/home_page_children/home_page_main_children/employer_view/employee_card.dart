import 'package:flutter/material.dart';
import 'package:terra/models/category.dart';
import 'package:terra/models/user_details.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/views/home_page_children/home_page_main_children/employer_view/job_hiring_dialog.dart';

class EmployeeCard extends StatefulWidget {
  const EmployeeCard({super.key, required this.data});
  final UserDetails data;
  @override
  State<EmployeeCard> createState() => _EmployeeCardState();
}

class _EmployeeCardState extends State<EmployeeCard> {
  bool viewAll = false;
  final AppColors _colors = AppColors.instance;
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade100,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              minVerticalPadding: 0,
              contentPadding: const EdgeInsets.all(0),
              leading: SizedBox(
                width: 50,
                // height: 50,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Image.network(widget.data.avatar),
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      right: 0,
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.data.status == "active"
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              title: Text(
                widget.data.fullName,
              ),
              subtitle: Text(
                widget.data.email,
              ),
              trailing: TextButton(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.resolveWith(
                    (states) => _colors.top,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    viewAll = !viewAll;
                  });
                },
                child: Text(
                  "${!viewAll ? "ALL" : "MINIMIZE"} SKILLS",
                ),
              ),
            ),
            // ListTile(
            //   contentPadding: const EdgeInsets.all(0),
            //   leading: Icon(Icons.phone),
            //   title: Text(widget.data.phoneNumber),
            // ),
            if (widget.data.skills.isNotEmpty) ...{
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                children: [
                  Text(
                    "SKILLS : ",
                    style: TextStyle(
                      color: _colors.bot,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ...List.generate(
                      viewAll
                          ? widget.data.skills.length
                          : widget.data.skills
                              .sublist(widget.data.skills.length >= 2
                                  ? widget.data.skills.length - 2
                                  : 0)
                              .length, (index) {
                    final Category _skill = widget.data.skills[index];
                    return Chip(
                      avatar: Image.network(_skill.icon),
                      label: Text(_skill.name),
                    );
                  }),
                ],
              ),
            },
            const SizedBox(
              height: 10,
            ),
            MaterialButton(
              onPressed: () async {
                await showGeneralDialog(
                  context: context,
                  barrierDismissible: false,
                  barrierColor: Colors.black.withOpacity(.5),
                  barrierLabel: "Job hiring",
                  transitionDuration: const Duration(milliseconds: 500),
                  transitionBuilder: (_, a1, a2, x) {
                    return Transform.scale(
                      scale: a1.value,
                      child: FadeTransition(
                        opacity: a1,
                        child: AlertDialog(
                          // actions: [

                          // ],
                          title: Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  "Offer a job",
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context).pop(null);
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                              )
                            ],
                          ),
                          content: JobHiringDialog(
                            recruitee: widget.data,
                          ),
                        ),
                      ),
                    );
                  },
                  pageBuilder: (_, a1, a2) => Container(),
                );
                // setState(() {
                //   _selectedCatIds = catIds;
                // });
                // if (_k.currentState!.isEndDrawerOpen) {
                //   Navigator.of(context).pop(null);
                // }
                // await fetch();
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
    );
  }
}
