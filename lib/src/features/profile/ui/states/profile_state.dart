import '../../domain/models/profile_model.dart';

class ProfileState {
  final bool isLoading;
  final String? errorMessage;
  final ProfileModel? profile;

  const ProfileState({this.isLoading = false, this.errorMessage, this.profile});

  ProfileState copyWith({
    bool? isLoading,
    String? errorMessage,
    ProfileModel? profile,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      profile: profile ?? this.profile,
    );
  }
}
