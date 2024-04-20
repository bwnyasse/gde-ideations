import 'package:comet/utils/utils.dart';
import 'package:dotenv/dotenv.dart';

import 'dart:convert';

class FormService {
  Future<Map<String, dynamic>> generatePayload(String prompt) async {
    var env = DotEnv(includePlatformEnvironment: true)..load();

    final apiKey = env['GEMINI_AI_API_KEY']!;

    String output =
        await GeminiUtils.generateContent(apiKey, prepareRequest(prompt));
    print(output);
    return json.decode(output);
  }

  String prepareRequest(final prompt) {
    return '''
  input: We value your feedback. Please tell us about your experience with our BuildWithAi Meetup here in Montreal.,
  output: $json1,
  input: Please enter your details to register for the event.,
  output: $json2,
  input: $prompt,
  output:,
  ''';
  }

  final json1 = '''{
    "info": {
        "title": "BuildWithAi Meetup Feedback - Montreal",
        "description": "We value your feedback. Please tell us about your experience with our BuildWithAi Meetup here in Montreal."
    },
    "items": [
        {
            "title": "How would you rate your overall experience at the BuildWithAi Meetup?",
            "questionItem": {
                "question": {
                    "required": true,
                    "choiceQuestion": {
                        "type": "RADIO",
                        "options": [
                            {
                                "value": "Excellent"
                            },
                            {
                                "value": "Good"
                            },
                            {
                                "value": "Average"
                            },
                            {
                                "value": "Below Average"
                            },
                            {
                                "value": "Poor"
                            }
                        ]
                    }
                }
            }
        },
        {
            "title": "What did you enjoy the most about the meetup?",
            "questionItem": {
                "question": {
                    "required": false,
                    "textQuestion": {
                        "paragraph": true
                    }
                }
            }
        },
        {
            "title": "What could be improved for future meetups?",
            "questionItem": {
                "question": {
                    "required": false,
                    "textQuestion": {
                        "paragraph": true
                    }
                }
            }
        },
        {
            "title": "Would you recommend our BuildWithAi Meetup to others?",
            "questionItem": {
                "question": {
                    "required": true,
                    "choiceQuestion": {
                        "type": "RADIO",
                        "options": [
                            {
                                "value": "Yes"
                            },
                            {
                                "value": "No"
                            }
                        ]
                    }
                }
            }
        }
    ]
}''';

  final json2 = '''{
    "info": {
        "title": "Event Registration",
        "description": "Please enter your details to register for the event."
    },
    "items": [
        {
            "title": "Full Name",
            "questionItem": {
                "question": {
                    "required": true,
                    "textQuestion": {}
                }
            }
        },
        {
            "title": "Email Address",
            "questionItem": {
                "question": {
                    "required": true,
                    "textQuestion": {}
                }
            }
        },
        {
            "title": "Company or Organization (optional)",
            "questionItem": {
                "question": {
                    "required": false,
                    "textQuestion": {}
                }
            }
        },
        {
            "title": "Job Title (optional)",
            "questionItem": {
                "question": {
                    "required": false,
                    "textQuestion": {}
                }
            }
        },
        {
            "title": "Will you be attending in person or virtually?",
            "questionItem": {
                "question": {
                    "required": true,
                    "choiceQuestion": {
                        "type": "RADIO",
                        "options": [
                            {
                                "value": "In Person"
                            },
                            {
                                "value": "Virtually"
                            }
                        ]
                    }
                }
            }
        }
    ]
}''';

}
