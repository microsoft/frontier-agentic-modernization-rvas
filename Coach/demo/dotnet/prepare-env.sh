#!/usr/bin/env bash
# Usage (Bash or Zsh): source "$REPO_ROOT/Coach/demo/dotnet/prepare-env.sh"
# Prerequisites: terraform, jq, az login, and both guide Terraform stacks deployed.
# Optional: LEGACY_INFRA and ACA_INFRA select existing deployment directories.
# Read-only: does not deploy resources, change Terraform state, or create files.
# Cleanup of exported values, if needed:
# unset MIGRATION_SQL_HOST ACA_RG ACA_APP APP_IDENTITY_NAME APP_CLIENT_ID BLOB_ACCOUNT DEMO_IMAGE

contoso_demo_output() {
    local value
    if ! value="$(terraform -chdir="$1" output -json "$2")" ||
        ! value="$(printf '%s' "$value" | jq -ers 'select(length == 1) | .[0] | select(type == "string") | select(test("^[^[:space:][:cntrl:]]+$"))')"; then
        printf 'Cannot read Terraform output "%s" from %s.\n' "$2" "$1" >&2
        printf 'Check that deployment directory, backend, and workspace before continuing:\n' >&2
        printf '  terraform -chdir="%s" workspace show\n' "$1" >&2
        printf '  terraform -chdir="%s" state list\n' "$1" >&2
        printf 'If already deployed, use its original state; do not redeploy from empty state.\n' >&2
        printf 'If not deployed, complete A1 (Student) and A3 (Coach) first.\n' >&2
        return 1
    fi
    printf '%s\n' "$value"
}

contoso_demo_prepare() {
    local tool legacy_infra aca_infra migration_sql_host aca_rg aca_fqdn blob_endpoint
    local aca_app app_identity_name app_client_id blob_account apps app identity demo_image
    unset MIGRATION_SQL_HOST ACA_RG ACA_APP APP_IDENTITY_NAME APP_CLIENT_ID BLOB_ACCOUNT
    for tool in terraform jq az; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            printf 'Required command not found: %s\n' "$tool" >&2
            return 1
        fi
    done
    if [ -z "${REPO_ROOT:-}" ]; then
        printf 'Set REPO_ROOT to the repository directory before sourcing this script.\n' >&2
        return 1
    fi
    legacy_infra="${LEGACY_INFRA:-$REPO_ROOT/Student/Resources/dotnet/infra}"
    aca_infra="${ACA_INFRA:-$REPO_ROOT/Coach/Solutions/dotnet/infra}"

    printf 'Checking both Terraform deployments...\n'
    migration_sql_host="$(contoso_demo_output "$legacy_infra" target_sql_server_for_wizard)" || return 1
    aca_rg="$(contoso_demo_output "$aca_infra" resource_group_name)" || return 1
    aca_fqdn="$(contoso_demo_output "$aca_infra" container_app_fqdn)" || return 1
    blob_endpoint="$(contoso_demo_output "$aca_infra" storage_account_blob_endpoint)" || return 1
    blob_account="${blob_endpoint#https://}"
    blob_account="${blob_account%%.*}"
    if ! printf '%s' "$blob_account" | jq -Rse 'test("^[a-z0-9]{3,24}$")' >/dev/null; then
        printf 'Invalid storage account endpoint in Coach Terraform outputs.\n' >&2
        return 1
    fi

    printf 'Checking the deployed Container App and its managed identity...\n'
    apps="$(az containerapp list -g "$aca_rg" -o json)" || return 1
    if [ -z "$apps" ] || ! app="$(printf '%s' "$apps" | jq -ec --arg fqdn "$aca_fqdn" \
        '[.[] | select(.properties.configuration.ingress.fqdn == $fqdn)] | select(length == 1) | .[0]')"; then
        printf 'Cannot find exactly one app matching Terraform FQDN %s in %s.\n' "$aca_fqdn" "$aca_rg" >&2
        printf 'Check az account show and the subscription used for the Coach deployment.\n' >&2
        return 1
    fi
    aca_app="$(printf '%s' "$app" | jq -er '.name | select(type == "string" and length > 0)')" || return 1
    if ! identity="$(printf '%s' "$app" | jq -ec \
        '(.identity.userAssignedIdentities // {}) | to_entries | select(length == 1) | .[0]')"; then
        printf 'Expected exactly one user-assigned identity on %s; check the Coach deployment.\n' "$aca_app" >&2
        return 1
    fi
    app_identity_name="$(printf '%s' "$identity" | jq -er '.key | split("/") | last | select(length > 0)')" || return 1
    app_client_id="$(printf '%s' "$identity" | jq -er '.value.clientId | select(type == "string" and length > 0)')" || return 1
    az storage account show -g "$aca_rg" -n "$blob_account" --query name -o tsv >/dev/null || return 1

    demo_image="${DEMO_IMAGE:-}"
    if [ -z "$demo_image" ]; then
        printf 'Container image tag to build and deploy (including registry/repository): '
        read -r demo_image || return 1
    fi
    if ! printf '%s' "$demo_image" | jq -Rse 'test("^[^[:space:][:cntrl:]]+$")' >/dev/null; then
        printf 'Provide a nonempty container image reference without whitespace.\n' >&2
        return 1
    fi

    export LEGACY_INFRA="$legacy_infra" ACA_INFRA="$aca_infra"
    export MIGRATION_SQL_HOST="$migration_sql_host" ACA_RG="$aca_rg" ACA_APP="$aca_app"
    export APP_IDENTITY_NAME="$app_identity_name" APP_CLIENT_ID="$app_client_id"
    export BLOB_ACCOUNT="$blob_account" DEMO_IMAGE="$demo_image"
    printf 'Ready: app=%s, resource group=%s, identity=%s, storage=%s\n' \
        "$ACA_APP" "$ACA_RG" "$APP_IDENTITY_NAME" "$BLOB_ACCOUNT"
}

if contoso_demo_prepare; then
    unset -f contoso_demo_prepare contoso_demo_output
else
    unset -f contoso_demo_prepare contoso_demo_output
    return 1
fi
