# Comet: An AI-Powered Folder Explorer

Comet is a command-line tool that allows you to explore your file system with the help of AI-powered insights. It provides an enhanced experience over the standard `tree` command, offering features like file organization recommendations, large file identification, and more.

## Features

- Explore your file system with a tree-like structure
- Filter files and folders by name (supports wildcards and regular expressions)
- List directories only
- Display file sizes and last modification dates
- Integrate with AI models (e.g., Gemini) to provide intelligent insights

## Installation

To install Comet, you'll need to have Dart installed on your system. You can then use the Dart package manager, `pub`, to install the Comet package:

    pub global activate comet


## Usage

To use Comet, simply run the `comet` command in your terminal. 

For example, to list only the directories in the current directory, you can run:

    comet explore --directories


To list all files and folders that match the `*.dart` pattern, you can run:

    comet explore --pattern '*.dart'


## Roadmap

- Integrate with additional AI models (e.g., OpenAI, Claude) to provide more advanced insights
- Add support for interactive mode, where users can ask questions about the file system and receive AI-generated responses
- Improve the output formatting and visualization
- Provide more customization options for the user interface

## Contributing

If you'd like to contribute to the Comet project, please feel free to submit a pull request or open an issue on the [GitHub repository](https://github.com/bwnyasse/gde-ideations/tree/main/01_comet).

## License

Comet is licensed under the [MIT License](LICENSE).
