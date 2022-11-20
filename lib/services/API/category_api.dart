import 'dart:convert';
import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/models/category.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/utils/network.dart';
import 'package:terra/view_model/categories_vm.dart';

class CategoryApi {
  static final CategoriesVm _vm = CategoriesVm.instance;
  Future<void> fetchAll() async {
    try {
      return await http.get("${Network.domain}/api/categories".toUri, headers: {
        "accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken"
      }).then(
        (response) async {
          var data = json.decode(response.body);
          if (response.statusCode == 200 || response.statusCode == 201) {
            // _vm.populate(data)
            print("FETCHED ALL CATEGORY");
            final List<Category> ff =
                (data as List).map((e) => Category.fromJson(e)).toList();
            _vm.populate(ff);
            return;
          }
          await Fluttertoast.showToast(
              msg: "Unable to fetch categories, please contact the developer.");
          return;
        },
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "An unexpected error occurred while processing.",
      );
      return;
    }
  }
}
