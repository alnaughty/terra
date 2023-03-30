import 'package:rxdart/rxdart.dart';
import 'package:terra/models/v2/application.dart';

class ApplicationsVm {
  ApplicationsVm._pr();
  static final ApplicationsVm _instance = ApplicationsVm._pr();
  static ApplicationsVm get instance => _instance;

  BehaviorSubject<List<MyApplication>> _subject =
      BehaviorSubject<List<MyApplication>>();
  Stream<List<MyApplication>> get stream => _subject.stream;
  List<MyApplication> get current => _subject.value;
  void dispose() async {
    _subject = BehaviorSubject<List<MyApplication>>();
  }

  void populate(List<MyApplication> data) {
    _subject.add(data);
  }
}
