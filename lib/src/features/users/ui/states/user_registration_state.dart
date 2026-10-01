import '../../domain/models/user_model.dart';

sealed class UserRegistrationState {
  const UserRegistrationState();
}

class UserRegistrationInitial extends UserRegistrationState {
  const UserRegistrationInitial();
}

class UserRegistrationSaving extends UserRegistrationState {
  const UserRegistrationSaving();
}

class UserRegistrationSuccess extends UserRegistrationState {
  final UserModel user;
  const UserRegistrationSuccess(this.user);
}

class UserRegistrationError extends UserRegistrationState {
  final String message;
  const UserRegistrationError(this.message);
}
