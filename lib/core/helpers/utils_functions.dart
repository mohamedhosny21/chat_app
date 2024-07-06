abstract class FileUtils {
  static String extractFileName(String url) {
    Uri uri = Uri.parse(url);
    String fileName = uri.pathSegments.last;

    // If the filename contains a query string, remove it
    if (fileName.contains('/')) {
      fileName = fileName.split('/').last;
    }
    return fileName;
  }
}
