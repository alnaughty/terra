import 'package:rxdart/rxdart.dart';
import 'package:terra/models/v2/task.dart';

class TasksVm {
  TasksVm._pr();
  static final TasksVm _instance = TasksVm._pr();
  static TasksVm get instance => _instance;

  BehaviorSubject<List<Task>> _subject = BehaviorSubject<List<Task>>();
  Stream<List<Task>> get stream => _subject.stream;

  void populate(List<Task> data) {
    print("TASKS LOADED");
    _subject.add(data);
  }

  void dispose() {
    _subject = BehaviorSubject<List<Task>>();
  }
}
