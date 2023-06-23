import 'package:flutter/material.dart';
import 'package:terra/helpers/size_reporting_widget.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/views/landing_page_children/check_page_children/upload_id_page.dart';

class ScrollableStep {
  const ScrollableStep({
    required this.title,
    this.subtitle,
    required this.content,
    this.isActive = false,
    this.label,
  });
  final Widget title;
  final Widget? subtitle;
  final Widget content;
  final bool isActive;
  final Widget? label;
}

// class UploadCallback {
//   final IDCardCallback id;
//   final String selfie;
//   final bool hasValidated;
//   const UploadCallback(
//       {required this.hasValidated, required this.selfie, required this.id});
// }

class CustomScrollableStepper extends StatefulWidget {
  const CustomScrollableStepper({super.key, required this.steps});
  // final ValueChanged<UploadCallback> uploadCallback;
  final List<ScrollableStep> steps;
  @override
  State<CustomScrollableStepper> createState() =>
      CustomScrollableStepperState();
}

class CustomScrollableStepperState extends State<CustomScrollableStepper>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late final List<bool> _indexValidated = List.generate(
    widget.steps.length,
    (index) => false,
  );
  validate(int index) {
    print("VALIDATE");
    setState(() {
      _indexValidated[index] = true;
      _currentStep += 1;
      // if (_currentStep < 2) {
      // }
    });
    _tabController.animateTo(_currentStep);
  }

  late final TabController _tabController;
  static final AppColors _colors = AppColors.instance;
  @override
  void initState() {
    _tabController = TabController(length: widget.steps.length, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  double barViewHeight = 0;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        return Column(
          children: [
            SizedBox(
              width: c.maxWidth,
              height: 60,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, i) {
                  return MaterialButton(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(60)),
                    onPressed: () {
                      // _tabController.animateTo(i);
                      // setState(() {
                      //   _currentStep = i;
                      // });
                    },
                    child: Row(
                      children: [
                        Container(
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _indexValidated[i] || _currentStep == i
                                ? _colors.top
                                : Colors.grey.withOpacity(.5),
                          ),
                          child: Center(
                            child: _indexValidated[i]
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : _currentStep == i
                                    ? const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 20,
                                      )
                                    : Text(
                                        "${i + 1}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        widget.steps[i].title,
                      ],
                    ),
                  );
                },
                separatorBuilder: (_, i) => const SizedBox(
                  width: 30,
                ),
                itemCount: widget.steps.length,
              ),
            ),
            Container(
              width: c.maxWidth,
              height: 1,
              color: const Color(0xFF4A4A4A).withOpacity(.5),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.maxFinite,
              height: barViewHeight,
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: widget.steps
                    .map(
                      (e) => OverflowBox(
                        minHeight: 0,
                        maxHeight: double.infinity,
                        alignment: Alignment.topCenter,
                        child: SizeReportingWidget(
                          onSizeChange: (size) =>
                              setState(() => barViewHeight = size?.height ?? 0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                e.subtitle ?? Container(),
                                e.content,
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        );
      },
    );
    // return LayoutBuilder(
    //   builder: ,
    //   child: Column(
    //     children: [
    //       ///HEADER
    //       Container(
    //         width: ,
    //       ),
    //     ],
    //   ),
    // );
  }
}
