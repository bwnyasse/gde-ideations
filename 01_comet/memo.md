# Memo Demo - BuildWithAi

## 1. Prepare Cursor with : 

- gemini_agent.dart ( Right)
- utils.dart ( Split - Left)
- Open this memo.md

## 2. Demo root folder

    cd /Users/boris-wilfriednyasse/gr/github/buildwithai

## 3. Prepare Demo folder

    cd /Users/boris-wilfriednyasse/gr/github/buildwithai

    ./clone_for_demo.sh examples/basic_authentication

## 4. Prepare the terminal 

- Split - Left : 
    
    cd /Users/boris-wilfriednyasse/gr/github/bwnyasse/gde-ideations/01_comet

- Split Right 

    cd /Users/boris-wilfriednyasse/gr/github/buildwithai/demo-buildwithai

## Live Demo 

a. Acting like a developer who is trying to work on this project : 

    https://github.com/VeryGoodOpenSource/dart_frog/tree/main/examples/basic_authentication

b. Quickly show how to compile comet :

    dart pub global activate --source path .

c. Display the help

    comet --help

d. Demo project-overview

    comet insights --project-overview | tee -a overview.md

e. Demo --code-organization

    comet insights --code-organization | tee -a code-organization.md

f. Demo --File-management

    comet explore -L 5 -c 

    comet insights --file-management | tee -a file-management.md


## Bonus

    comet form --prompt "Can you design a feedback form for my recent presentation at GDG Montreal?"


