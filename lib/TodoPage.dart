import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_sample/bloc/todo_bloc.dart';
import 'package:flutter_bloc_sample/bloc/todo_cubit.dart';
import 'package:flutter_bloc_sample/bloc/todo_event.dart';
import 'package:flutter_bloc_sample/bloc/todo_state.dart';
import 'package:flutter_bloc_sample/repository/todo_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // BlocProvider 호출 사용 :  Provider 를 초기화 하는 작업
    return BlocProvider(
      // 함수를 만들어서 bloc 을 return 해줌 : BlocProvider 가 생성해준 bloc 을 child 에 있는 HomeWidget() 에 TodoBloc 이 사용가능하도록 해줌
      create: (_) => TodoCubit(repository: TodoRepository()),
      child: HomeWidget(),
    );
  }
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  String title = '';

  // initState 생성
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // ListTodosEvent 를 BlocProvider 에서 TodoCubit 으로 바꿈
    BlocProvider.of<TodoCubit>(context).listTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Bloc'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TodoCubit 으로 바꿈
          context.read<TodoCubit>().createTodo(this.title);
        },
        child: Icon(Icons.edit),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            TextField(
              onChanged: (val) {
                this.title = val;
              },
            ),
            SizedBox(height: 16.0),

            // 만들어진 bloc 을 불러들이기 위해선 BlocBuilder 를 사용해야 함
            // 2개의 generic 을 불러와야 되는데 처음에는 실제 가져올 bloc 을 다음에는 그것의 상태를 넣어주면 됨
            Expanded(
              child: BlocBuilder<TodoCubit, TodoState>(builder: (_, state) {
                // state 가 Empty 이면 그냥 Container() return
                if (state is Empty) {
                  return Container();
                  // state 가 Error  일 경우
                } else if (state is Error) {
                  return Container(
                    child: Text(state.message),
                  );
                  // state 가 Loading 중일때는 circularProgressindecator()
                } else if (state is Loading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                  // state 가 Loaded 중일때 기존의 todos 를 불러 온다음에 item 별로 화면에 나타 내기
                } else if (state is Loaded) {
                  final items = state.todos;

                  return ListView.separated(
                    itemBuilder: (_, index) {
                      final item = items[index];
                      return Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              BlocProvider.of<TodoCubit>(context).deleteTodo(
                                item,
                              );
                            },
                            child: Icon(Icons.delete),
                          )
                        ],
                      );
                    },
                    separatorBuilder: (_, index) => Divider(),
                    itemCount: items.length,
                  );
                }
                return Container();
              }),
            ),
          ],
        ),
      ),
    );
  }
}
