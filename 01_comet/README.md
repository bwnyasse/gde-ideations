# Comet: An AI-Powered Folder Explorer

Comet is a command-line tool that allows you to explore your file system and get AI-powered insights to help you better understand and organize your codebase. With the integration of LLM like **Google's Gemini AI**, Comet transforms into an intelligent assistant for your development workflow.

## Features

- **Explore File System**:  Inspired by the `tree` command, Comet adds features tailored for Dart and Flutter developers. Explore your project's file structure with a tree-like visualization, filter files and folders by name, and display file sizes, last modification dates, and line counts. 

- **AI-Powered Insights:** Comet integrates with state-of-the-art AI models, such as Gemini, to provide intelligent insights about your codebase. These insights can help you improve code organization, identify potential quality issues, and analyze the overall project structure.

- **Customizable Insights:** Selectively generate insights on various aspects of your project, including code organization, code quality, project overview, and predictive file management suggestions.

- **Update README:** Comet can provide an updated version of your project's README.md file, making it more informative and welcoming for new contributor

- **Google Forms Integration**: Programmatically create and update Google Forms based on user input, streamlining data collection and automation tasks.

## Installation

Since Comet is not yet published on pub.dev, you'll need to generate the executable binary directly from the source code. To do this, follow these steps:

1. Make sure you have Dart installed on your system. You can download the latest version of Dart from the official website: https://dart.dev/get-dart

2. Clone the Comet repository from GitHub:

    git clone https://github.com/bwnyasse/gde-ideations.git

3. Navigate to the `comet` directory in your terminal.

    cd gde-ideations/01_comet

4. Generate the executable binary:

    dart compile exe -o comet bin/main.dart

5. Optionally, add the Comet executable to your system's PATH for global access.

    dart pub global activate --source path .


As the Comet project progresses, we plan to publish it on pub.dev, which will make the installation process much simpler. But for now, this manual compilation step is necessary to use the tool.

## Generating Your Gemini API Key

To interact with the Gemini AI model, you will need to obtain an API key from Google AI Studio. This key will allow you to authenticate your requests and use the AI capabilities provided by Gemini.

### Obtaining Your API Key

1. Visit [Google AI Studio](https://aistudio.google.com/app/) and log in or create a new account.

2. Follow the instructions provided in the documentation to generate a new API key.

3. Once you have your API key, keep it secure as it allows access to the Gemini AI features.

### Setting Up Your Environment

To use Comet's AI-powered features, you need to set up environment variables for API authentication. To keep your API key secure and not hard-coded in your application, you should use environment variables. Here's how to set up your `.env` file:

1. Create a `.env` file in the project root.

2. Add the following lines to your `.env` file:

    GEMINI_AI_API_KEY=<your Gemini API key>
    OAUTH_CLIENT_ID=<your OAuth client ID>
    OAUTH_CLIENT_SECRET=<your OAuth client secret>

3. Replace placeholders with your actual keys and credentials.

## Usage

To use Comet, simply run the `comet` command in your terminal. 

### Exploring the File System

To explore your file system using Comet, simply run the `comet explore` command in your terminal. You can customize the output by using various flags, such as `--directories`, `--size`, and `--date`, and the new `--count-lines` to display the line counts of each file.

For example, to list only the directories in the current directory, you can run:

    comet explore --directories


To list all files and folders that match the `*.dart` pattern, you can run:

    comet explore --pattern '*.dart'

### Generating AI-Powered Insights

To generate insights about your codebase, use the `comet insights` command. You can select the specific type of insights you want to generate, such as code organization, code quality, project overview, or an updated README.

For example, to generate insights about the code organization and structure of your project, you can run:

    comet insights --code-organization

To get an overview of your project, run:

    comet insights --project-overview

To generate an updated version of your project's README.md file, run:

    comet insights --update-readme

### Interacting with Google Forms

    comet form --prompt 'Please enter your details to register for the event.'

## Demo



https://github.com/bwnyasse/gde-ideations/assets/5323628/26b34350-da25-4d73-ae10-1a39bfda945d


    
## Roadmap

- **Expand AI Model Integration:** Provide users with the ability to select from a variety of AI models, including OpenAI, and Claude, to generate insights. This will allow users to choose the model that best suits their needs and preferences, and potentially unlock more advanced or specialized insights.


- **Interactive Mode::** Add support for an interactive mode, where users can ask questions about the file system and receive AI-generated responses. This will enable users to explore and understand their codebase more intuitively, without having to rely solely on the command-line interface.

## Contributing

If you'd like to contribute to the Comet project, please feel free to submit a pull request or open an issue on the [GitHub repository](https://github.com/bwnyasse/gde-ideations/tree/main/01_comet).

## License

Comet is licensed under the [MIT License](LICENSE).
