import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  // TODO: implement props
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({this.statusCode, required String message})
    : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure({String message = "No internet connection"})
    : super(message);
}
