import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/forms/v1.dart' as forms;

class AuthUtils {
  static const identifier = '';
  static const secret = '';
  static final clientId = auth.ClientId(identifier, secret);

  static const scopes = [forms.FormsApi.formsBodyScope];

  /// Obtains an authenticated client for interacting with Google Cloud APIs.
  static Future<auth.AutoRefreshingAuthClient> getAuthenticatedClient() async {
    // Prompt the user to authorize the application.
    var client = await auth.clientViaUserConsent(clientId, scopes, prompt);

    return client;
  }

  /// Launches a browser window for the user to authorize the application.
  static void prompt(String url) async {
    print("Please go to the following URL and grant access:");
    print("  $url");
  }
}
