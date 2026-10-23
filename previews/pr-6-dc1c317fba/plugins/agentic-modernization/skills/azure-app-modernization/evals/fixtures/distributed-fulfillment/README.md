# Distributed fulfillment fixture

The API and worker run on AWS and share a PostgreSQL database. The business note
says each accepted fulfillment request is processed exactly once and partner
status events remain ordered. A nightly export is a contractual partner feed.

The target is Azure, but the team has not chosen whether to retain the current
service boundaries. Traffic, queue settings, retry policy, database version,
partner SLAs, and production telemetry are unavailable.

Assess statically. Do not execute the JavaScript or connect to AWS, PostgreSQL,
or partner systems.
