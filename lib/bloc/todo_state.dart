import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_sample/model/todo.dart';

// immutable TodoState extends Equatable
@immutable
abstract class TodoState extends Equatable {}

// Empty TodoState : 맨처음에 아무것도 state 가 없을때 사용
class Empty extends TodoState {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

// Loading TodoState :RestAPI 에 요청을 했을 때 사용(repository 실행 했을때)
class Loading extends TodoState {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

// Error TodoState : server 에서 error message 가 나왔을때
class Error extends TodoState {
  final String message;

  Error({
    required this.message,
  });

  @override
// TODO: implement props
  List<Object> get props => [this.message];
}

// Loaded TodoState : Loaded 가 완료 되는 시점에 todos list 에 값을 넘겨 주는 state
class Loaded extends TodoState {
  final List<Todo> todos;

  Loaded({
    required this.todos,
  });

  @override
// TODO: implement props
  List<Object> get props => [this.todos];
}
