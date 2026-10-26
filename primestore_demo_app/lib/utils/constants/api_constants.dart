/* -- LIST OF Constants used in APIs -- */

// Example
const String tSecretAPIKey = "cwt_live_b2da6ds3df3e785v8ddc59198f7615ba";

class ApiConstants {
  static const String baseUrl = "http://10.0.2.2:8080";
  static const String s3PublicBaseUrl = String.fromEnvironment(
    'S3_PUBLIC_BASE_URL',
    defaultValue:
        'https://prime-store-images-363159276904-eu-north-1-an.s3.eu-north-1.amazonaws.com',
  );
}
