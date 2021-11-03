import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_sample/model/todo.dart';

// 기본 class 생성

@immutable
abstract class TodoEvent extends Equatable {}

class ListTodosEvent extends TodoEvent {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

// todo 를 입력 받게 되어 있는데, 그렇게 하려면 todo 안에서도 todo object 를 가지고 있어야 함
class CreateTodoEvent extends TodoEvent {
  final String title;

  CreateTodoEvent({
    required this.title,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [this.title];
}

// DeleteTodo 에서도 Todo object 가 들어가 잇으니까 같이 받아 줘야 함
class DeleteTodoEvent extends TodoEvent {
  final Todo todo;

  DeleteTodoEvent({
    required this.todo,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [this.todo];
}
