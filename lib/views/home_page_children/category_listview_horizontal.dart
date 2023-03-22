import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:terra/models/category.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/view_model/categories_vm.dart';
import 'package:terra/views/home_page_children/category/show_all_categories.dart';

class CategoryListviewHorizontal extends StatelessWidget {
  const CategoryListviewHorizontal({super.key});
  static final AppColors _colors = AppColors.instance;
  static final CategoriesVm _vm = CategoriesVm.instance;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return StreamBuilder<List<Category>>(
      stream: _vm.stream,
      builder: (_, snapshot) {
        if (snapshot.hasError || !snapshot.hasData) {
          return Container();
        }
        final List<Category> _categories = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Categories",
                        style: TextStyle(
                          color: Colors.grey.shade900,
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          constraints: BoxConstraints(
                            maxHeight: size.height,
                          ),
                          isScrollControlled: true,
                          isDismissible: true,
                          useSafeArea: true,
                          builder: (_) => const ShowAllCategories(),
                        );
                      },
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.resolveWith(
                          (states) => _colors.bot,
                        ),
                      ),
                      child: const Text(
                        "Show all",
                      ),
                    ),
                  ],
                )),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.maxFinite,
              height: 200,
              child: ListView.separated(
                padding: const EdgeInsets.only(left: 20, right: 20),
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, i) {
                  final Category _cat = _categories[i];
                  return SizedBox(
                    width: 160,
                    height: 200,
                    child: MaterialButton(
                      onPressed: () async {
                        await Navigator.pushNamed(
                          context,
                          "/job_listing",
                          arguments: [_cat.id, null],
                        );
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      color: Colors.grey.shade100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CachedNetworkImage(
                            imageUrl: _cat.icon,
                            height: 120,
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
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, i) => const SizedBox(
                  width: 15,
                ),
                itemCount: _categories.take(5).length,
              ),
            )
          ],
        );
      },
    );
  }
}
