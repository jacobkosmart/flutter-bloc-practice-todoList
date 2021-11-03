import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_sample/bloc/todo_state.dart';
import 'package:flutter_bloc_sample/model/todo.dart';
import 'package:flutter_bloc_sample/repository/todo_repository.dart';

// bloc 은 2개의 generic 을 넣어야 되는데 (event, state), cubit 은 상태만 넣으면 됩니다

class TodoCubit extends Cubit<TodoState> {
  // Repository 생성
  final TodoRepository repository;

  // Empty 값으로 시작
  TodoCubit({required this.repository}) : super(Empty());

  // override 할것이 cubic 은 없음 왜냐하면 cubit 을 사용하면 일반 method 를 사용해서 event 를 부를 수 있기 때문임 그래서 event 는 정의가 따로 필요 없음

  // ListTodo method
  listTodo() async {
    try {
      // emit 은 cubit 에서 yield 와 같은것
      emit(Loading());

      // repository 에서 가져온 정보 변수 선언
      final resp = await this.repository.listTodo();

      // listTodo 는 Map<String, dynamic> 을 return 해주기 때문에 따로 class 화를 해줘야 함
      final todos = resp.map<Todo>((e) => Todo.fromJson(e)).toList();

      // 값을 가져왔으니 loading 이 끝난것을 호출하고 todos 를 넘긴다
      emit(Loaded(todos: todos));
    } catch (e) {
      emit(Error(message: e.toString()));
    }
  }

  // CreateTodo method
  createTodo(String title) async {
    try {
      // 아래의 state 가 loaded state 인지 확인 (아직 load 가 안됬는데 data 를 가져 오면 안되기때문에)
      if (state is Loaded) {
        // todo 를 만들기 전에 기존 데이터를 가져와야 함
        // 모두 yield 된것들은 state 안에서 가져올수 있음 state 인데 사실 이건 Loaded state 라는것
        final parseState = (state as Loaded);

        // todo 생성
        final newTodo = Todo(
          //  ID: todos 의 길이 -1 의 index 의 id 값이 + 1 해서 추가 ID 번호 생성
          id: parseState.todos[parseState.todos.length - 1].id + 1,
          // Title : event 에서 title 을 불러옴
          title: title,
          // CreatedAt : 지금 시간 호출해서 String 으로 반환
          createdAt: DateTime.now().toString(),
        );

        // repository 전송전에 UI 화면에 변경된 내용을 표시해주는부분 todos 호출
        // prevTodos 에 기존에 있는것을 복사
        final prevTodos = [
          ...parseState.todos,
        ];

        // newTodos 에 기존거 + 생성한거 새로 생성
        final newTodos = [
          ...prevTodos,
          newTodo,
        ];

        // 요청을 하기전에 가상으로 yield 하기 (load 가 다 됬다고 임의로 선언 UI 에 표시하기 위해서)
        emit(Loaded(todos: newTodos));

        // repository 로 데이터 전송
        final resp = await this.repository.createTodo(newTodo);

        // id 값과 createdAt 의 값을 서버에 있는 쪽과 UI 쪽의 id 와 createdAt 의 값을 맞춰야 되기때문에 repository 전송후에 다시 Loaded 호출해서 업데이트 하는것
        emit(Loaded(todos: [
          ...prevTodos,
          Todo.fromJson(resp),
        ]));
      }
    } catch (e) {
      emit(Error(message: e.toString()));
    }
  }

  // deleteTodo method
  deleteTodo(Todo todo) async {
    try {
      if (state is Loaded) {
        final newTodos = (state as Loaded)
            .todos
            .where((item) => item.id != todo.id)
            .toList();

        emit(Loaded(todos: newTodos));

        await repository.deleteTodo(todo);
      }
    } catch (e) {
      emit(Error(message: e.toString()));
    }
  }
}
