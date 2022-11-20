import 'package:rxdart/rxdart.dart';
import 'package:terra/models/category.dart';

class CategoriesVm {
  CategoriesVm._pr();
  static final CategoriesVm _instance = CategoriesVm._pr();
  static CategoriesVm get instance => _instance;

  final BehaviorSubject<List<Category>> _subject =
      BehaviorSubject<List<Category>>();
  Stream<List<Category>> get stream => _subject.stream;
  List<Category> get value => _subject.value;

  void populate(List<Category> data) {
    _subject.add(data);
  }
}
