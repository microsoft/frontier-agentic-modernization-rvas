# Modernization Plan

**Branch**: `[BRANCH-NAME]` | **Date**: [DATE] | **Github Issue**: [link]

> NOTE: Generation metadata and instructional sections must be stripped before saving the final plan.

This template is filled in by the `/appmod-kit.create-plan` command.

---

## HOW-TO-GENERATE (DO NOT PERSIST)

1) **Modernization Goal**: Summarize the customer’s stated modernization objective; must be singular and unambiguous.
2) **Scope**: The section describe the modernization scope type that the generated plan will cover. DO NOT Generate plan out of scope type described in **Scope**.
3) **Application Information**： According to the input project information, describe the current architecture.
4) **Clarification**: You will read the plan project information and knowledge base to make a plan, if you still have some open issue to make a plan, add clarification in this section.
5) **Target Architecture**: According to project information and knowledge base for modernization, generate the target architecture of the project.
6) **Task Breakdown and Dependencies**: According to **Target Architecture**, **Task breakdown rules**, break the task list for modernization, the modernization task MUST be scope according to **Scope**.

## Modernization Goal

Analyze user input and the content of mentioned files to identify the modernization goal.
Describe the customer modernization goal of the application here, e.g.,Migrate the project to Azure Container Apps (from user input)
Ensure that the application's modernization goal is unambiguous; for instance, the target service must be unique.

## Scope

This section described the scope that the modernization plan can cover.

According to the provided project information, user's request and the content of mentioned files, summarize the scope for modernization and the source that scope based on, the scope should be only related with code change and the scope type will be one of belows:

1. Upgrade the application framework, e.g., JDK upgrade, Spring Framework upgrade
2. Migrate source code from using X to using Y, X is an on-premise/aws resource and Y is an Azure resource
3. Containerize the application
4. Generate deployment files

Example:
1. Java Upgrade
   - JDK (11 → 17) [based on the global constitution request]
   - Spring Boot (2.5 → 3.x) [based on the user request]
2. Migration To Azure
   - Migrate messaging from ActiveMQ to Azure Service Bus [based on the assess report]
   - Migrate secrets to Azure Key Vault [based on the assess report]

## References

If user input mentioned files that contain rules that migration tasks should reference, put the reference file path here.  Do not summarize the content of the file in the file description.
If user input mentioned github issue url for the migration, put the url here. Do not summarize the content of the issue in the description.
If there is no such kind of file or url mentioned, do not include this section.

Example:

- `../../modernization/constitution.md` - Contains the global migration requirement
- `https://github.com/abc/my-container-app/issues/35` - Migration issue to be updated

## Azure Environment
Describe the Azure environment information if user provided the information in the input, including:
1) Subscription ID
2) Resource Group
If there is no such kind of information provided, do not include this section.

## Application Information

### Current Architecture

According to the input project, describe the application architecture with diagram of mermaid, including:

1) Application framework information
2) Resource/Services dependencies
3) Connector framework to the dependencies

## Clarification

Before you make a target architecture and Task Breakdown for next sections, list all the open issues you need to clarify with user as a list with format as below:

1) Open issue 1: [Describe the issue here]  
   - Answer: [User Answer]  
   - Status: Solved

All the open issues should be related with task breakdown for code change, NOT list the issue with infra.

The open issues is possible be:

1) You don't have enough information to clarify if this issue is a really issue
2) There are multiple solutions for the same issue and the solutions are conflict, and you don't have enough information to decide solution you need to choose

This section is not mandatory, just leave if empty if no open issues

## Target Architecture

Define the target architecture for modernization with diagram of mermaid, according to the project information and scope for modernization, including:

1) Application framework information
2) Target Resource/Services dependencies
3) Connector framework to the dependencies

## Task Breakdown

> NOTE: This task list will be used by the `/appmod-kit.run-plan` command to execute the modernization. Do not hallucinate the steps or changes of these tasks which may misleading the user.

**Task breakdown rules**:
1) Make a task breakdown for this iteration of migration according to **`Goal`**, **`Scope`**. Always respect user intent, pickup solutions according to user input.
2) If there is any open issues to make the task, add your open issues to the section of clarification section, try to add a task with solution to the issue if possible.
3) Migration task MUST be breakdown to target specific azure service.
4) DO NOT describe the implementation details in the task breakdown, just give a high level description of what the task will do.
5) ONLY have one deploy task if user requested to generate deployment files or deploy the application. If deploy task is added, DO NOT add containerize task since it is included in deploy task.
6) For task migration from X to Y, you need to find a solution id from the knowledge base of modernization, each solution will complete all the code/configuration changes needed for the migration from X to Y, so you just need to find the right solution id to cover the migration from X to Y.
7) If there is no solution id to cover the migration from X to Y, you need to add warning "Migration from X to Y is not supported." in the scope section. And do not add the migration task to the task list.
8) ONLY deployment task needn't the solution id. Else task MUST have the solution id or be excluded. The solution id MUST from the knowledge base of modernization.
9) Rules to Upgrade Java - **CRITICAL: Avoid Creating Duplicate Tasks**
      - The latest version of Java is above 17, the latest of Spring Boot is above 3 and the latest Spring Framework is above 6
      - **Choose the right upgrade solution id set and avoid duplicate work in solution. If solution A contains solution B, only pick solution A.**
        - **If Spring Boot is asked to upgrade to 3.x or above without explicitly requesting Java 21 or above:**
            - **DO NOT create separate tasks** for: JDK upgrade, Spring Framework upgrade, or Jakarta EE upgrade
            - **ONLY create ONE task: "Upgrade Spring Boot to 3.x"**
            - In the task description, explicitly state that it includes: upgrading JDK to 17, Spring Framework to 6.x, and migrating from JavaEE (javax.*) to Jakarta EE (jakarta.*)
        - **If Spring Framework is asked to upgrade to 6.x or above (without Spring Boot upgrade) without explicitly requesting Java 21 or above:**
            - **DO NOT create a separate task** for: JDK upgrade
            - **ONLY create ONE task: "Upgrade Spring Framework to 6.x"**
            - In the task description, explicitly state that it includes: upgrading JDK to 17
        - **If JDK upgrade is explicitly requested with version 21 or above:**
            - Create a task: "Upgrade Java to version X"
10) If the JDK version is under 17, you should add task to upgrade the JDK to latest version unless user specified not to do it.
11) Rules to pickup solution
   1. If there is a managed identity solution to connect a resource, choose the managed identity solution. Otherwise, if Key Vault is explicitly requested, use the Key Vault to manage the credentials.
   2. If Oracle is found, PostgreSQL will be the preferred migration target.
11) The tasks MUST be one of below type and follow this sequence:
   1. Java Upgrade
   2. Migration to Azure (Migration from X to Y)
   3. Containerize (Generate Dockerfile and related file; DO NOT add this task if deploy task is added)
   4. Deploy (Generate deployment files and deploy the application)
12) For task type Migration to Azure, follow the below sequence
   1. Migration except the below solutions
   2. Azure keyvault related migration if migration task for azure key vault is required
   3. Managed Identity related solution
   4. Telemetry related migration like log and application insight if it is requried

Example:
1) Task name: Upgrade JDK to 17  
   - Task Type: Java Upgrade  
   - Description: Move build/runtime to JDK 17   
   - Solution Id: java-version-upgrade  

2) Task name: Migration from X to Y  
   - Task Type: Migration To Azure  
   - Description: [The issue to be solve by the task]  
   - Solution Id: id1  

The solution ID must be from knowledge base and NEVER fake a solution id