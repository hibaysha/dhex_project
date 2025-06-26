class Apis {
  ///Base Url
  static String baseUrl = 'https://backend-endpoint.eventhex.ai/api/v1';

  static String getUserData() {
    return '$baseUrl/mobile/profile?id=6778f7447fc6f415e56910d5';
  }

  ///image Append url
  static const String imageAppend =
      "https://event-manager.syd1.cdn.digitaloceanspaces.com/";
}
