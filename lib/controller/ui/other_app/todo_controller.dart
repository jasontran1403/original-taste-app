import 'dart:math';
import 'package:get/get.dart';
import 'package:original_taste/models/todo_model.dart';

class TodoController extends GetxController {
  final List<TodoModel> _todoList = [];
  List<TodoModel> get todo => _todoList;

  int _nextId = 0;

  @override
  void onInit() {
    super.onInit();
    _initializeTodos();
  }

  Future<void> _initializeTodos() async {
    final dummyList = await TodoModel.dummyList;
    _todoList.addAll(dummyList);
    _nextId = _todoList.isNotEmpty ? _todoList.map((e) => e.id).reduce(max) + 1 : 0;
    update();
  }

  void addTodo({
    required String taskName,
    required String dueDate,
    required String name,
    required String status,
    required String priority,
    required String avatar,
  }) {
    final now = DateTime.now();

    final newTodo = TodoModel(_nextId++, status, taskName, _formatDate(now), _formatTime(now), dueDate, name, avatar, priority, false);

    _todoList.add(newTodo);
    update();
  }

  void updateTodo(TodoModel updated) {
    final index = _todoList.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      _todoList[index] = updated;
      update();
    }
  }

  void deleteTodo(TodoModel data) {
    _todoList.removeAt(data.id);
    update();
  }

  void toggleTaskComplete(TodoModel task) {
    task.checked = !task.checked;
    update();
  }

  String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _formatTime(DateTime date) => '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}
