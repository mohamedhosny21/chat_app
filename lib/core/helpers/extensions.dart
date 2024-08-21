extension StringExtension on String {
  bool get imageType => this == 'jpg' || this == 'png' || this == 'jpeg';
  bool get videoType => this == 'mp4' || this == 'avi' || this == 'mov';
}
