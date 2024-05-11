class ContactModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String? profilePicture;
  ContactModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.profilePicture,
  });
}
