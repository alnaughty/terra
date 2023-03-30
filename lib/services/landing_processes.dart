import 'package:terra/models/v2/raw_task.dart';
import 'package:terra/models/v2/task.dart';
import 'package:terra/models/v2/todo.dart';
import 'package:terra/services/API/v2/task_api.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/view_model/posted_jobs.dart';
import 'package:terra/view_model/tasks_vm.dart';
import 'package:terra/view_model/todo_vm.dart';

class LandingProcesses {
  LandingProcesses._pr();
  static final LandingProcesses _instance = LandingProcesses._pr();
  static LandingProcesses get instance => _instance;
  static final TaskAPIV2 _taskApi = TaskAPIV2.instance;
  static final TasksVm _tasks = TasksVm.instance;
  static final TaskTodoVm _taskTodoVm = TaskTodoVm.instance;
  static final PostedJobsVm _postedJobsVm = PostedJobsVm.instance;

  Future<void> loadProcesses() async {
    final List _result = await Future.wait([
      _taskApi.getTasks(),
      if (loggedUser!.accountType == 1) ...{
        _taskApi.getTodos(),
      } else ...{
        _taskApi.getPostedTasks(),
      },
    ]);
    if (_result.isEmpty) return;
    print("RESULT $_result");
    final List<Task> tasks = (_result[0] as List<Task>);
    _tasks.populate(tasks);
    if (_result[1] == null) return;
    if (loggedUser!.accountType == 1) {
      _taskTodoVm.populate(_result[1] as List<TodoTask>);
    } else {
      _postedJobsVm.populate(_result[1] as List<RawTaskV2>);
    }
  }
}
