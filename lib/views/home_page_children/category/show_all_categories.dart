import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:terra/models/category.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/view_model/categories_vm.dart';

class ShowAllCategories extends StatelessWidget {
  const ShowAllCategories({super.key});
  static final AppColors _colors = AppColors.instance;
  static final CategoriesVm _vm = CategoriesVm.instance;
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: .5,
      maxChildSize: 1,
      minChildSize: .45,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(50),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Container(
              width: 60,
              height: 5,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade400.withOpacity(.4),
                      blurRadius: 3,
                      offset: const Offset(2, 2),
                    )
                  ]),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: StreamBuilder<List<Category>>(
                stream: _vm.stream,
                builder: (_, snapshot) {
                  if (snapshot.hasError || !snapshot.hasData) {
                    return Container();
                  }
                  final List<Category> _categories = snapshot.data!;
                  return Scrollbar(
                    controller: scrollController,
                    child: GridView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: .7,
                      ),
                      itemBuilder: (_, i) {
                        final Category _cat = _categories[i];
                        return MaterialButton(
                          onPressed: () async {
                            Navigator.of(context).pop(null);
                            await Navigator.pushNamed(
                              context,
                              "/job_listing",
                              arguments: [_cat.id, null],
                            );
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          color: Colors.grey.shade100,
                          child: LayoutBuilder(builder: (context, c) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: _cat.icon,
                                  height: c.maxHeight * .45,
                                  fit: BoxFit.fitHeight,
                                  placeholder: (_, ff) => Image.asset(
                                    "assets/images/loader.gif",
                                    height: 100,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  _cat.name,
                                  textAlign: TextAlign.center,
                                )
                              ],
                            );
                          }),
                        );
                      },
                      itemCount: _categories.length,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        // child: ListView(
        //   controller: scrollController,
        //   padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        //   children: [],
        // ),
      ),
    );
  }
}
