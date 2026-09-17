import '../../../auth/domain/models/user.dart';

sealed class LoginState {
  const LoginState();
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  final User user;
  const LoginSuccess(this.user);
}

class LoginError extends LoginState {
  final String message;
  const LoginError(this.message);
}