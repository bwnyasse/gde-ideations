import 'package:comet/features/insights/insights_service.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:dotenv/dotenv.dart';

class GeminiAgent extends InsightsService {

  @override
  Future<String> getCodeQualityInsightsPrompt() async {
    final content = await folderService.readProjectContents(
      readLib: true,
    );

    String output = '''
As an experienced Dart developer, please review the provided code and provide specific recommendations to improve the code quality. Focus on the following files:

$content

In your response, please address the following areas:

1. Variable and method naming conventions: Are the names used throughout the codebase clear and descriptive, or could they be improved?
2. Code organization and structure: Is the code organized in a way that promotes maintainability and extensibility, or are there opportunities for better separation of concerns?
3. Potential code smells or anti-patterns: Are there any code constructs or patterns that could be refactored to improve the overall code quality?
4. Adherence to Dart/Flutter best practices: Does the code follow established best practices for Dart and Flutter development, or are there areas that could be improved?
5. Opportunities for performance optimization: Are there any areas in the code that could be optimized to improve performance, such as inefficient algorithms or resource-intensive operations?

Please provide specific, actionable recommendations for each of these areas, referencing the relevant parts of the code where applicable. Your response should be detailed and constructive, as if you were providing feedback during a code review.
''';
    return output;
  }

  @override
  Future<String> getCodeOrganizationInsightsPrompt() async {
    final folderTree = await folderService.exploreFileSystem();
    String folderTreeAsString = folderTree.toString();

    return '''
  "input: Provide the top 2 recommendations for improving the code organization and structure based on the following project layout:\n\n├── 01_comet\n│   ├── test\n│   ├── bin\n│   │   └── main.dart \n│   ├── lib\n│   │   ├── models\n│   │   │   └── folder_model.dart \n│   │   │   └── file_model.dart \n│   │   │   └── insight_model.dart \n│   │   ├── commands\n│   │   │   └── insights_command.dart \n│   │   │   └── explore_command.dart \n│   │   ├── services\n│   │   │   └── folder_service.dart \n│   │   │   └── ai_service.dart \n│   │   └── .DS_Store \n│   ├── .dart_tool\n│   │   └── package_config.json \n│   └── .DS_Store \n│   └── CHANGELOG.md \n│   └── pubspec.lock \n│   └── .keep \n│   └── README.md \n│   └── pubspec.yaml \n│   └── analysis_options.yaml \n\nSome interesting resources that could provide inspiration for improving the code organization and structure:\n\n- https://dart.dev/tools/pub/package-layout\n- https://dart.dev/effective-dart/style\n- https://codewithandrea.com/articles/flutter-project-structure/\n- https://medium.com/flutter-community/scalable-folder-structure-for-flutter-applications-183746bdc320",
  "output: Top 2 recommendations for improving the code organization and structure:\n\n1. Organize Files by Functionality:\n   - The current structure groups files by their type (models, commands, services), which is a good starting point.\n   - However, consider organizing the files further by their functionality or domain, rather than just by their type.\n   - For example, you could have separate folders for \"user-related\" files, \"file-related\" files, and \"insights-related\" files.\n   - This will make the codebase more intuitive and easier to navigate.\n\n2. Exclude Hidden System Files:\n   - The presence of `.DS_Store` files indicates that there might be some hidden or system-generated files in the project.\n   - It's generally recommended to exclude these types of files from version control and project distribution.\n   - Consider adding `.DS_Store` to your `.gitignore` file to prevent these files from being tracked.\n\nSuggested Project Structure:\n\n└── 01_comet\n    ├── CHANGELOG.md\n    ├── README.md\n    ├── analysis_options.yaml\n    ├── bin\n    │   └── main.dart\n    ├── lib\n    │   ├── commands\n    │   │   ├── file_command.dart\n    │   │   ├── insight_command.dart\n    │   │   └── user_command.dart\n    │   ├── models\n    │   │   ├── file_model.dart\n    │   │   ├── insight_model.dart\n    │   │   └── user_model.dart\n    │   ├── repositories\n    │   │   ├── file_repository.dart\n    │   │   ├── insight_repository.dart\n    │   │   └── user_repository.dart\n    │   ├── services\n    │   │   ├── file_service.dart\n    │   │   ├── insight_service.dart\n    │   │   └── user_service.dart\n    │   └── utils\n    │       ├── file_utils.dart\n    │       └── insight_utils.dart\n    ├── pubspec.lock\n    ├── pubspec.yaml\n    └── test",
  "input: Provide the top 2 recommendations for improving the code organization and structure based on the following project layout:\n\n├── my_app\n│   ├── lib\n│   │   ├── screens\n│   │   │   ├── home_screen.dart\n│   │   │   ├── settings_screen.dart\n│   │   │   └── profile_screen.dart\n│   │   ├── widgets\n│   │   │   ├── app_drawer.dart\n│   │   │   ├── header_widget.dart\n│   │   │   └── footer_widget.dart\n│   │   ├── services\n│   │   │   ├── auth_service.dart\n│   │   │   ├── api_service.dart\n│   │   │   └── storage_service.dart\n│   │   └── models\n│   │       ├── user_model.dart\n│   │       ├── post_model.dart\n│   │       └── settings_model.dart\n│   ├── test\n│   ├── assets\n│   ├── pubspec.yaml\n│   └── README.md\n\nSome interesting resources that could provide inspiration for improving the code organization and structure:\n- https://dart.dev/tools/pub/package-layout\n- https://dart.dev/effective-dart/style\n- https://codewithandrea.com/articles/flutter-project-structure/\n- https://medium.com/flutter-community/scalable-folder-structure-for-flutter-applications-183746bdc320",
  "output: Top 2 recommendations for improving the code organization and structure:\n\n1. Separate Concerns by Domain:\n   - The current structure groups files by their type (screens, widgets, services, models), which is a common approach.\n   - However, consider organizing the files further by their domain or functionality, rather than just by their type.\n   - For example, you could have separate folders for \"authentication-related\" files, \"post-related\" files, and \"settings-related\" files.\n   - This will make the codebase more intuitive and easier to navigate, as the files will be grouped by their purpose rather than just their type.\n\n2. Utilize Consistent Naming Conventions:\n   - Ensure that you are using consistent naming conventions for your files, classes, and variables throughout the project.\n   - Follow the Dart style guide and use descriptive, meaningful names that reflect the purpose of the code elements.\n   - This will improve the readability and maintainability of the codebase, making it easier for other developers to understand and work with the code.\n\nSuggested Project Structure:\n\n└── my_app\n    ├── assets\n    ├── lib\n    │   ├── authentication\n    │   │   ├── models\n    │   │   │   └── user_model.dart\n    │   │   ├── screens\n    │   │   │   ├── login_screen.dart\n    │   │   │   └── register_screen.dart\n    │   │   └── services\n    │   │       └── auth_service.dart\n    │   ├── posts\n    │   │   ├── models\n    │   │   │   └── post_model.dart\n    │   │   ├── screens\n    │   │   │   ├── home_screen.dart\n    │   │   │   └── post_detail_screen.dart\n    │   │   └── services\n    │   │       └── api_service.dart\n    │   ├── settings\n    │   │   ├── models\n    │   │   │   └── settings_model.dart\n    │   │   └── screens\n    │   │       └── settings_screen.dart\n    │   ├── shared\n    │   │   ├── services\n    │   │   │   └── storage_service.dart\n    │   │   └── widgets\n    │   │       ├── app_drawer.dart\n    │   │       ├── footer_widget.dart\n    │   │       └── header_widget.dart\n    │   └── main.dart\n    ├── test\n    ├── README.md\n    └── pubspec.yaml",
  "input: Provide the top 2 recommendations for improving the code organization and structure based on the following project layout:\n\n$folderTreeAsString\n\nSome interesting resources that could provide inspiration for improving the code organization and structure:\n- https://dart.dev/tools/pub/package-layout\n- https://dart.dev/effective-dart/style\n- https://codewithandrea.com/articles/flutter-project-structure/\n- https://medium.com/flutter-community/scalable-folder-structure-for-flutter-applications-183746bdc320",
  "output: ",
''';
  }

  @override
  Future<String> getProjectOverviewInsightsPrompt() async {
    final content = await folderService.readProjectContents(
      readLib: true,
      readBin: true,
      readPubspec: true,
      readReadme: true,
    );

    return '''
As a new developer joining this project, I would like to get a high-level overview of the project to help me understand its purpose, features, and implementation. Please provide the following information:

Project Description:
Provide a brief description of the project, including its purpose and the problem it aims to solve.

Key Features:
List the main features and functionalities provided by the project.

Project Structure:
Describe the overall structure of the project, including the major components, their responsibilities, and how they interact with each other. This can include:
- Modules or packages
- Core services or repositories
- User interface components (e.g., screens, widgets)
- Data models
- Any other significant architectural elements

Implementation Details:
Provide a general overview of the implementation details, such as:
- Programming languages and frameworks used
- Architectural patterns or design principles applied
- Notable libraries or third-party dependencies
- Approach to handling data, networking, or other cross-cutting concerns

Getting Started:
Suggest any steps or resources that would be helpful for a new developer to get started with the project, such as setting up the development environment, running the project, or accessing relevant documentation.

Please provide this information in a clear and concise manner, as if you were onboarding a new developer to the project. Feel free to use your own knowledge and understanding of the provided code files to fill in the details.

To help me better understand the project, please also provide the full content of the implementation, including the following files:

$content

''';
  }

  @override
  Future<String> generateInsight(String prompt) async {
    var env = DotEnv(includePlatformEnvironment: true)..load();

    final apiKey = env['GENERATIVE_AI_API_KEY']!;

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
