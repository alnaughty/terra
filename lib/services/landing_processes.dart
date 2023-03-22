import 'package:terra/models/v2/task.dart';
import 'package:terra/services/API/v2/task_api.dart';
import 'package:terra/view_model/tasks_vm.dart';

class LandingProcesses {
  LandingProcesses._pr();
  static final LandingProcesses _instance = LandingProcesses._pr();
  static LandingProcesses get instance => _instance;
  static final TaskAPIV2 _taskApi = TaskAPIV2.instance;
  static final TasksVm _tasks = TasksVm.instance;

  Future<void> loadProcesses() async {
    final List _result = await Future.wait([
      _taskApi.getTasks(),
    ]);
    if (_result.isEmpty) return;
    print("RESULT $_result");
    final List<Task> tasks = (_result[0] as List<Task>);
    _tasks.populate(tasks);
  }
}
