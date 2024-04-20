import 'package:dotenv/dotenv.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/forms/v1.dart' as forms;
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiUtils {
  static Future<String> generateContent(String apiKey, String prompt) async {
    final content = [Content.text(prompt)];

    final model = GenerativeModel(
      model: 'models/gemini-pro',
      //model: 'models/gemini-1.5-pro-latest',
      apiKey: apiKey,
      safetySettings: [
        SafetySetting(
          HarmCategory.sexuallyExplicit,
          HarmBlockThreshold.medium,
        ),
        SafetySetting(
          HarmCategory.hateSpeech,
          HarmBlockThreshold.medium,
        ),
        SafetySetting(
          HarmCategory.harassment,
          HarmBlockThreshold.medium,
        ),
        SafetySetting(
          HarmCategory.dangerousContent,
          HarmBlockThreshold.medium,
        ),
      ],
      generationConfig: GenerationConfig(
        // optional, 0.0 always uses the highest-probability result
        temperature: 0.7,
        // optional, how many candidate results to generate
        candidateCount: 1,
        // optional, number of most probable tokens to consider for generation
        topK: 40,
        // optional, for nucleus sampling decoding strategy
        topP: 0.95,
        // optional, maximum number of output tokens to generate
        maxOutputTokens: 1024,
        // optional, sequences at which to stop model generation
        stopSequences: [],
      ),
    );

    // Call the  API to generate text
    final GenerateContentResponse response =
        await model.generateContent(content);
    return response.text ?? '';
  }
}

class AuthUtils {
  /// Obtains an authenticated client for interacting with Google Cloud APIs.
  static Future<auth.AutoRefreshingAuthClient> getAuthenticatedClient() async {
    final env = DotEnv(includePlatformEnvironment: true)..load();

    final identifier = env['OAUTH_CLIENT_ID']!;

    final secret = env['OAUTH_CLIENT_SECRET']!;

    final clientId = auth.ClientId(identifier, secret);

    const scopes = [forms.FormsApi.formsBodyScope];

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
