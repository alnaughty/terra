import 'package:rxdart/rxdart.dart';
import 'package:terra/models/v2/todo.dart';

class TaskTodoVm {
  TaskTodoVm._pr();
  static final TaskTodoVm _instance = TaskTodoVm._pr();
  static TaskTodoVm get instance => _instance;

  BehaviorSubject<List<TodoTask>> _subject = BehaviorSubject<List<TodoTask>>();
  Stream<List<TodoTask>> get stream => _subject.stream;
  void populate(List<TodoTask> data) {
    _subject.add(data);
  }

  void dispose() {
    _subject = BehaviorSubject<List<TodoTask>>();
  }
}
