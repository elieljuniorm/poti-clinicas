import '../../domain/models/user_details_model.dart';

class UserDetailsState {
  final bool isLoading;
  final String? errorMessage;
  final UserDetailsModel? details;

  const UserDetailsState({
    this.isLoading = false,
    this.errorMessage,
    this.details,
  });

  UserDetailsState copyWith({
    bool? isLoading,
    String? errorMessage,
    UserDetailsModel? details,
  }) {
    return UserDetailsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      details: details ?? this.details,
    );
  }
}
