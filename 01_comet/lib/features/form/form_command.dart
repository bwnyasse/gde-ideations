import 'package:args/command_runner.dart';
import 'package:comet/utils/utils.dart';
import 'package:googleapis/forms/v1.dart' as forms;
import 'package:http/http.dart' as http;

class FormCommand extends Command<void> {
  @override
  final name = 'form';
  @override
  final description = 'Interact with Google Forms.';

  FormCommand() {
    argParser.addOption('entry', help: 'User entry to generate the form.');
  }

  @override
  Future<void> run() async {
    // Obtain an authenticated client for interacting with DocumentAI.
    final client = await AuthUtils.getAuthenticatedClient();

    try {
      var entry = argResults?['entry'];
      if (entry == null) {
        print('Please provide an entry.');
        return;
      }

      var payload = generateFakePayload();
      // Create or update the form using the Google Forms API
      await createOrUpdateForm(client, "", payload);
    } finally {
      client.close();
    }
  }

  Future<void> createOrUpdateForm(
    http.Client client,
    String formId,
    Map<String, dynamic> payload,
  ) async {
    var formsApi = forms.FormsApi(client);

    try {
      if (formId.isEmpty) {
        // Step 1: Create a new form with only the title
        var form = forms.Form.fromJson({
          "info": {"title": payload['info']['title']}
        });
        var createResult = await formsApi.forms.create(form);
        formId = createResult.formId ?? "EMPTY";
        print('Form created: $formId');

        // Step 2: Use batchUpdate to add items and other properties
        var requests =
            generateBatchUpdateRequests(payload); // You need to implement this
        var request = forms.BatchUpdateFormRequest(requests: requests);
        await formsApi.forms.batchUpdate(request, formId);
        print('Form updated with items: $formId');
      } else {
        // Update an existing form
        var requests =
            generateBatchUpdateRequests(payload); // Adjust to your needs
        var request = forms.BatchUpdateFormRequest(requests: requests);
        await formsApi.forms.batchUpdate(request, formId);
        print('Form updated: $formId');
      }
    } catch (e) {
      print('Failed to create or update form: $e');
      rethrow;
    }
  }

  List<forms.Request> generateBatchUpdateRequests(
      Map<String, dynamic> payload) {
    List<forms.Request> requests = [];
    int index =
        0; // Initialize the index to specify the insertion point in the form.

    for (var item in payload['items']) {
      // Dynamically handle different question types based on your payload structure.
      if (item.containsKey('questionItem')) {
        var questionItem = item['questionItem'];
        var question = questionItem['question'];

        var formItem = forms.Item();
        formItem.title = item['title']; // Set the item title.

        if (question.containsKey('textQuestion')) {
          // Handle text and paragraph questions.
          var textQuestion = question['textQuestion'];
          formItem.questionItem = forms.QuestionItem(
            question: forms.Question(
              required: question['required'],
              textQuestion: forms.TextQuestion(
                paragraph: textQuestion['paragraph'],
              ),
            ),
          );
        } else if (question.containsKey('choiceQuestion')) {
          // Handle choice questions (radio, checkbox).
          var choiceQuestion = question['choiceQuestion'];
          formItem.questionItem = forms.QuestionItem(
            question: forms.Question(
              required: question['required'],
              choiceQuestion: forms.ChoiceQuestion(
                type: choiceQuestion['type'], // RADIO or CHECKBOX
                options: choiceQuestion['options']
                    .map<forms.Option>(
                      (option) => forms.Option(value: option['value']),
                    )
                    .toList(),
              ),
            ),
          );
        }
        // Add more question types here as needed.

        // Create a request for the item and add it to the list of requests.
        var request = forms.Request(
          createItem: forms.CreateItemRequest(
            item: formItem,
            location:
                forms.Location(index: index++), // Increment index after use.
          ),
        );
        requests.add(request);
      }
    }

    return requests;
  }

  Map<String, dynamic> generateFakePayload() {
    return {
      "info": {
        "title": "Independent Mechanic Survey",
        "description":
            "A survey to gather insights from mechanics and workshop managers."
      },
      "items": [
        {
          "title": "General Business Questions",
          "description":
              "How long have you been working as a mechanic/managing this workshop?",
          "questionItem": {
            "question": {
              "required": true,
              "choiceQuestion": {
                "type": "RADIO",
                "options": [
                  {"value": "Less than a year"},
                  {"value": "1-5 years"},
                  {"value": "6-10 years"},
                  {"value": "More than 10 years"},
                  {"value": "Other:", "isOther": true}
                ]
              }
            }
          }
        },
        {
          "title": "How many customers do you serve on average each month?",
          "questionItem": {
            "question": {
              "required": true,
              "choiceQuestion": {
                "type": "RADIO",
                "options": [
                  {"value": "Less than 10"},
                  {"value": "11-50"},
                  {"value": "51-100"},
                  {"value": "More than 100"},
                  {"value": "Other:", "isOther": true}
                ]
              }
            }
          }
        },
        {
          "title": "Current Use of Technology",
          "description":
              "Are you currently using any software or application to manage your workshop?",
          "questionItem": {
            "question": {
              "required": true,
              "choiceQuestion": {
                "type": "RADIO",
                "options": [
                  {"value": "Yes"},
                  {"value": "No"},
                  {"value": "Searching for a solution"}
                ]
              }
            }
          }
        },
        {
          "title":
              "What are the main challenges you encounter with the current tools? (Select all that apply)",
          "questionItem": {
            "question": {
              "required": false,
              "choiceQuestion": {
                "type": "CHECKBOX",
                "options": [
                  {"value": "Lack of specific features"},
                  {"value": "Difficulty of use"},
                  {"value": "High cost"},
                  {"value": "Lack of support or customer service"},
                  {"value": "No problems with current tools"},
                  {"value": "Other:", "isOther": true}
                ]
              }
            }
          }
        },
        {
          "title": "Customer Relationship Management",
          "description":
              "How do you currently manage communication with your clients? (Select all that apply)",
          "questionItem": {
            "question": {
              "required": false,
              "choiceQuestion": {
                "type": "CHECKBOX",
                "options": [
                  {"value": "Phone calls"},
                  {"value": "Emails"},
                  {"value": "SMS"},
                  {"value": "No formal system"},
                  {"value": "Other:", "isOther": true}
                ]
              }
            }
          }
        },
        {
          "title":
              "Would it be useful for you to have a tool that automates maintenance reminders?",
          "questionItem": {
            "question": {
              "required": true,
              "choiceQuestion": {
                "type": "RADIO",
                "options": [
                  {"value": "Yes"},
                  {"value": "No"},
                  {"value": "Unsure"}
                ]
              }
            }
          }
        },
        {
          "title": "Maintenance History and Document Management",
          "description":
              "How do you keep track of your clients' vehicle maintenance history?",
          "questionItem": {
            "question": {
              "required": true,
              "choiceQuestion": {
                "type": "RADIO",
                "options": [
                  {"value": "Computerized system"},
                  {"value": "Paper files"},
                  {"value": "I do not keep a maintenance history"},
                  {"value": "Other:", "isOther": true}
                ]
              }
            }
          }
        },
        {
          "title": "Are there difficulties accessing the maintenance history?",
          "questionItem": {
            "question": {
              "required": true,
              "choiceQuestion": {
                "type": "RADIO",
                "options": [
                  {"value": "Yes"},
                  {"value": "No"},
                  {"value": "Sometimes"}
                ]
              }
            }
          }
        },
        {
          "title": "Openness to New Solutions",
          "description":
              "What features would you consider essential in a management tool for your workshop? (Select all that apply)",
          "questionItem": {
            "question": {
              "required": false,
              "choiceQuestion": {
                "type": "CHECKBOX",
                "options": [
                  {"value": "Appointment scheduling and reminders"},
                  {"value": "Expense and revenue tracking"},
                  {"value": "Inventory management"},
                  {"value": "Communication with clients"},
                  {"value": "Analysis and reports"},
                  {"value": "None/I'm not sure"},
                  {"value": "Other:", "isOther": true}
                ]
              }
            }
          }
        },
        {
          "title": "Would you be open to trying a new technological solution?",
          "questionItem": {
            "question": {
              "required": true,
              "choiceQuestion": {
                "type": "RADIO",
                "options": [
                  {"value": "Yes"},
                  {"value": "No"},
                  {"value": "Unsure"}
                ]
              }
            }
          }
        },
        {
          "title": "Comments and Suggestions",
          "description":
              "Do you have any specific suggestions or ideas about what you would like to see in a workshop management tool?",
          "questionItem": {
            "question": {
              "required": false,
              "textQuestion": {"paragraph": true}
            }
          }
        }
      ]
    };
  }
}
