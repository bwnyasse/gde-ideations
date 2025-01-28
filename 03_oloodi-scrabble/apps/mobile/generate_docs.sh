#!/bin/bash

# Create documentation directory
mkdir -p docs/source_code

# Generate markdown file for source code
echo "# Source Code Documentation" > docs/source_code/companion_implementation.md
echo "\n## Project Structure\n" >> docs/source_code/companion_implementation.md

# Function to add file content to markdown
add_file_content() {
    local file=$1
    local relative_path=${file#"lib/"}
    echo "\n### $relative_path\n" >> docs/source_code/companion_implementation.md
    echo "\`\`\`dart" >> docs/source_code/companion_implementation.md
    cat $file >> docs/source_code/companion_implementation.md
    echo "\`\`\`\n" >> docs/source_code/companion_implementation.md
}

# Generate documentation for each source file
for file in $(find lib -name "*.dart"); do
    add_file_content $file
done

# Add pubspec.yaml
echo "\n## pubspec.yaml\n" >> docs/source_code/companion_implementation.md
echo "\`\`\`yaml" >> docs/source_code/companion_implementation.md
cat pubspec.yaml >> docs/source_code/companion_implementation.md
echo "\`\`\`" >> docs/source_code/companion_implementation.md

echo "Documentation generated in docs/source_code/companion_implementation.md"