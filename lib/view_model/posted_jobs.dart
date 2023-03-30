import 'package:rxdart/rxdart.dart';
import 'package:terra/models/v2/raw_task.dart';

class PostedJobsVm {
  PostedJobsVm._pr();
  static final PostedJobsVm _instance = PostedJobsVm._pr();
  static PostedJobsVm get instance => _instance;

  BehaviorSubject<List<RawTaskV2>> _subject =
      BehaviorSubject<List<RawTaskV2>>();
  Stream<List<RawTaskV2>> get stream => _subject.stream;
  List<RawTaskV2> get current => _subject.value;

  void populate(List<RawTaskV2> data) {
    _subject.add(data);
  }

  void dispose() {
    _subject = BehaviorSubject<List<RawTaskV2>>();
  }
}
