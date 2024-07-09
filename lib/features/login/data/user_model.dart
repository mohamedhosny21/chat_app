class UserModel {
  final String phoneNumber;
  final String? photo, about;

  UserModel({required this.phoneNumber, this.photo, this.about});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'phone_number': phoneNumber,
      'photo': photo,
      'about': about,
    };
  }
}
