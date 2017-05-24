# PSScriptAnalyzerRules
Within Methos we use these PSScriptAnalyzer rules for testing our code and verifying consistency and quality in our PowerShell code.

## Rules
These are custom rules for the Powershell Script Analyzer.

### Commands
| Name                        | Description                                                   |
| --------------------------- | ------------------------------------------------------------- |
| UseCommandsNotAliasses      | Tests for aliasses used intead of commands                    |

### Functions
| Name                        | Description                                                   |
| --------------------------- | ------------------------------------------------------------- |
| UseApprovedVerbs            | Tests for approved verbs                                      |
| UseFunctionNamingConvention | Tests for function naming based on cmdlet naming convention   |

### Help
| Name                        | Description                                                   |
| --------------------------- | ------------------------------------------------------------- |
| UseHelp                     | Tests for help                                                |
| UseHelpSynopsis             | Tests for a synopsis section in the help                      |
| UseHelpDescription          | Tests for a description section in the help                   |
| UseHelpExamples             | Tests for an example section in the help                      |
| UseHelpFunctionality        | Tests for a functionality section in the help                 |
| UseHelpInputs               | Tests for an inputs section in the help                       |
| UseHelpOutputs              | Tests for an outputs section in the help                      |
| UseHelpParameters           | Tests for a parameter section in the help                     |
| UseHelpParameters           | Tests for a parameter section in the help                     |

### Parameters
| Name                        | Description                                                   |
| --------------------------- | ------------------------------------------------------------- |
| UseParameterHelp            | Tests for parameters without help                             |
| UseParameterUpdatedHelp     | Tests for obsolete documented parameters in help              |

### Variables
| Name                        | Description                                                   |
| --------------------------- | ------------------------------------------------------------- |
| UseVariableAfterAssigning   | Tests for variables used before assigning them                |
| UseAssignedVariables        | Tests for assigned but unused variables                       |



###### Copyright by [Methos B.V.](http://www.methos.nl "Methos")