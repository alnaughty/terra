import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rxdart/rxdart.dart';

class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.onFinished,
  });
  final TextEditingController controller;
  final ValueChanged<String> onFinished;
  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  static final BehaviorSubject<String> _subject = BehaviorSubject<String>();
  @override
  void initState() {
    _subject.stream
        .debounceTime(const Duration(milliseconds: 1500))
        .listen((event) {
      FocusScope.of(context).unfocus();
      widget.onFinished(event);
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          SvgPicture.asset(
            "assets/icons/search.svg",
            color: Colors.grey.shade800,
            width: 20,
            height: 20,
          ),
          // Icon(
          //   Icons.search,
          //   color: _colors.top,
          //   size: 20,
          // ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: TextField(
              // expands: true,
              maxLines: 1,
              decoration: const InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                alignLabelWithHint: true,
                isDense: true,
                hintText: "Search",
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              controller: widget.controller,
              selectionHeightStyle: BoxHeightStyle.includeLineSpacingMiddle,
            ),
          )
        ],
      ),
    );
  }
}
