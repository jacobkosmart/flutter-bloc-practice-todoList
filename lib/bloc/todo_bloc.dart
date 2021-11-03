import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_sample/bloc/todo_event.dart';
import 'package:flutter_bloc_sample/bloc/todo_state.dart';
import 'package:flutter_bloc_sample/model/todo.dart';
import 'package:flutter_bloc_sample/repository/todo_repository.dart';

// Bloc logic 생성
// <> generic 으로 첫번째는 event 를 받고, 그 다음에는 state를 받습니다

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  // dependancy injection 하기 위한 변수 선언
  final TodoRepository repository;

  // constructor 생성 : super 에는 가장 기본이 되는 state 인 Empty() 를 넣어 줌(처음 실행할때 아무것도 없는 상태이기 때문임) / TodoBloc 안에서 repository 의 로직도 안에서 실행하기 위해서 dependency injection 을 해줌
  TodoBloc({
    required this.repository,
  }) : super(Empty());

  // 모든 event 들이 이 함수를 통해서 실행이 됨
  // Stream 은 async* 해줘야함 Future 는 그냥 async
  @override
  Stream<TodoState> mapEventToState(TodoEvent event) async* {
    // 먼저 어떠한 event 인지 check 하는 것 (ListTodosEvent, CreateTodoEvent, DeleteTodoEvent)
    if (event is ListTodosEvent) {
      yield* _mapListTodoEvent(event);
    } else if (event is CreateTodoEvent) {
      yield* _mapCreateTodoEvent(event);
    } else if (event is DeleteTodoEvent) {
      yield* _mapDeleteTodoEvent(event);
    }
  }

  // 아래의 로직이 가장 처음으로 UI 와 연결되는 부분이기 때문에 Stream builder 형태로 Stream 으로 들어가게 되는데 UI 에서 error 가 나는것을 최소화 시켜 줘야 함. 그래서 모든 error 를 이 단계에서 설정을 함(try , catch 로)
  // _mapListTodoEvent Stream logic 생성
  Stream<TodoState> _mapListTodoEvent(ListTodosEvent event) async* {
    try {
      // circular indicator 를 보여주기 위해 Loading을 호출
      yield Loading();

      // repository 에서 가져온 정보 변수 선언
      final resp = await this.repository.listTodo();

      // listTodo 는 Map<String, dynamic> 을 return 해주기 때문에 따로 class 화를 해줘야 함
      final todos = resp.map<Todo>((e) => Todo.fromJson(e)).toList();

      // 값을 가져왔으니 loading 이 끝난것을 호출하고 todos 를 넘긴다
      yield Loaded(todos: todos);
    } catch (e) {
      yield Error(message: e.toString());
    }
  }

  // _mapCreateTodoEvent Stream logic 생성
  Stream<TodoState> _mapCreateTodoEvent(CreateTodoEvent event) async* {
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
          title: event.title,
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
        yield Loaded(todos: newTodos);

        // repository 로 데이터 전송
        final resp = await this.repository.createTodo(newTodo);

        // id 값과 createdAt 의 값을 서버에 있는 쪽과 UI 쪽의 id 와 createdAt 의 값을 맞춰야 되기때문에 repository 전송후에 다시 Loaded 호출해서 업데이트 하는것
        yield Loaded(todos: [
          ...prevTodos,
          Todo.fromJson(resp),
        ]);
      }
    } catch (e) {
      yield Error(message: e.toString());
    }
  }

  // _mapDeleteTodoEvent Stream logic 생성
  Stream<TodoState> _mapDeleteTodoEvent(DeleteTodoEvent event) async* {
    try {
      if (state is Loaded) {
        final newTodos = (state as Loaded)
            .todos
            .where((todo) => todo.id != event.todo.id)
            .toList();

        yield Loaded(todos: newTodos);

        await repository.deleteTodo(event.todo);
      }
    } catch (e) {
      yield Error(message: e.toString());
    }
  }
}
