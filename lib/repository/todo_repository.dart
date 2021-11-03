// todo list app 은 실제로 만들면 server 와 연동을 하게 되는데 RestAPI 연동하는것을 시뮬레이션 하기 위한 repository 생성

// 3개의 method 생성 (이벤트 처리를 위한)
// GET = listTodo
// POST = createTodo
// DELETE = deleteTodo

import 'package:flutter_bloc_sample/model/todo.dart';

class TodoRepository {
  Future<List<Map<String, dynamic>>> listTodo() async {
    await Future.delayed(Duration(seconds: 1));
    return [
      {
        'id': 1,
        'title': 'Flutter Study',
        'createdAt': DateTime.now().toString(),
      },
      {
        'id': 2,
        'title': 'Dart Study',
        'createdAt': DateTime.now().toString(),
      },
    ];
  }

  Future<Map<String, dynamic>> createTodo(Todo todo) async {
    // 원래는 이런 방식으로 작성해야 하는데 body - request - response - return 과정을 생략한것임
    await Future.delayed(Duration(seconds: 1));

    return todo.toJson();
  }

  Future<Map<String, dynamic>> deleteTodo(Todo todo) async {
    await Future.delayed(Duration(seconds: 1));

    return todo.toJson();
  }
}
