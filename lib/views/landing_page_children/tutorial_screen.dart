import 'package:flutter/material.dart';
import 'package:terra/models/tutorial_data.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key, required this.data});
  final TutorialData data;
  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  @override
  Widget build(BuildContext context) {
    // final Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Positioned(
          bottom: 0,
          child: Image.asset(
            "assets/images/Wave.png",
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(30),
          child: LayoutBuilder(builder: (_, c) {
            final double h = c.maxHeight;
            final double w = c.maxWidth;
            return Column(
              children: [
                Image.asset(
                  widget.data.imagePath,
                ),
                SizedBox(
                  height: h * .15,
                ),
                Expanded(
                  child: SizedBox(
                    // color: Colors.red,
                    width: w,
                    child: Column(
                      children: [
                        Text(
                          widget.data.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          widget.data.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(.7),
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            );
          }),
        ),
      ],
    );
  }
}
