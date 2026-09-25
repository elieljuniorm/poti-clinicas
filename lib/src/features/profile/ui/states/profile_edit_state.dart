sealed class ProfileEditState {
  const ProfileEditState();
}

class ProfileEditInitial extends ProfileEditState {
  const ProfileEditInitial();
}

class ProfileEditSaving extends ProfileEditState {
  const ProfileEditSaving();
}

class ProfileEditSuccess extends ProfileEditState {
  const ProfileEditSuccess();
}

class ProfileEditError extends ProfileEditState {
  final String message;
  const ProfileEditError(this.message);
}
