import 'package:flutter/material.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';

class AllCategories extends StatefulWidget {
  const AllCategories({super.key, required this.scrollController});
  final ScrollController scrollController;
  @override
  State<AllCategories> createState() => _AllCategoriesState();
}

class _AllCategoriesState extends State<AllCategories> {
  static final AppColors _colors = AppColors.instance;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: double.maxFinite,
            child: Center(
              child: Container(
                height: 8,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade300,
                ),
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(builder: (context, c) {
              final double w = c.maxWidth;
              return ListView(
                controller: widget.scrollController,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    "All Categories",
                    style: TextStyle(
                      color: Colors.grey.shade900,
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  GridView.count(
                    crossAxisCount: w ~/ 60,
                    childAspectRatio: .78,
                    mainAxisSpacing: 10,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    children: List.generate(
                      categoryList.length,
                      (index) => LayoutBuilder(builder: (context, cc) {
                        final double ww = cc.maxWidth;
                        return Column(
                          children: [
                            Container(
                              width: ww,
                              height: ww,
                              decoration: BoxDecoration(
                                  gradient: _colors.gradient,
                                  borderRadius: BorderRadius.circular(5),
                                  image: DecorationImage(
                                      image: AssetImage(
                                          "assets/icons/${categoryList[index].toLowerCase().replaceAll(" ", "-")}.png"))),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Expanded(
                              child: Text(
                                categoryList[index],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          ],
                        );
                      }),
                    ),
                  )
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
