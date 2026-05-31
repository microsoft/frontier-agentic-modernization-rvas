---
description: Assess the repository.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

The text the user typed after `/appmod-kit.assess` in the triggering message **is** the GitHub issue URI. Assume you always have it available in this conversation even if `$ARGUMENTS` appears literally below. Do not ask the user to repeat it unless they provided an invalid URI. If the user provided an empty command, then it means they do not want to track the assessment with a GitHub issue.

While you may use tools like AppCat to perform the assessment, do not use these tool names when giving the user status. Instead, use "code assessment".

 ## Before You Begin

  **CRITICAL - Tool Validation (DO THIS FIRST)**:
  - Before proceeding with any steps, verify that the MCP tools 'appmod-precheck-assessment' and
'appmod-run-assessment' are available.
  - If these tools are NOT available in your tool list, STOP immediately and inform the user: "The required MCP tools ('appmod-precheck-assessment' and 'appmod-run-assessment') are not available. You need to add the app modernization MCP server to enable these tools."
  - Do NOT explore the repository, read files, or attempt any other actions until this validation passes.
  - Only proceed to step 1 after confirming the tools exist.

## Now do this:

1. **Extract GitHub issue URI**:
   - Extract the GitHub issue URI from the arguments
   - Do this ONLY if $ARGUMENTS is present
   - Validate the URI format (you can assume that syntax validity is enough)

2. **Detect the source of github issue**
   - If the Github Issue URI is present, use the 'github-mcp-server' tool to get the issue details.
   - Use below rules to detect if the issue is created by Azure Migrate: 
    - From the issue title and body, check if it contains content "estatetool=azuremigrate"
    - If no "estatetool=***" found, check if the title contains keyword "azure migrate".

3. **Install And Run Assessment Tools**:
   - Use the mcp tool 'appmod-precheck-assessment' to check and install the AppCat CLI.
   - Use the mcp tool 'appmod-run-assessment' to run the assessment.
   - Both tools will take some time to run; wait patiently.

4. Run `.appmod-kit/scripts/powershell/assess.ps1 -Json -OutputPath .github/appmod/appcat/result -IssueSource other` from the repo root, set the issue source parameter value to azuremigrate if step2 detected the source is azure migrate.

5. When the script is done, verify that the file `.github/appmod/appcat/result/summary.md` is present.

6. **Update GitHub Issue**
   - If the GitHub issue URI is present in step1, use the 'github-mcp-server' tool or 'gh' cli to create a new comment with the raw content of `summary.md` file you verified in the previous step.
   - Do not append any additional text or formatting; the comment should contain only the raw content. 
   - If the summary.md file is too large to fit in a single GitHub comment, split the content into multiple comments, ensuring each comment is complete and coherent on its own.
