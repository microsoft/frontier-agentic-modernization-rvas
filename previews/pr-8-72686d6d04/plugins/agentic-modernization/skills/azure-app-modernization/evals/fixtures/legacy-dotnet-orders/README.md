# Legacy order administration fixture

This internal application runs on .NET Framework 4.7.2 under Windows IIS.
The modernization goal is to reduce Windows server maintenance while preserving
order-clerk authorization and the downstream invoice-export contract.

Operations says invoice exports are collected from a shared drive every five
minutes. Production volume, session concurrency, deployment scripts, database
version, and the supported replacement for Windows integrated authentication
are unknown.

Assess statically. Do not build or run the application.
