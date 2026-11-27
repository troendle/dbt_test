#!/usr/bin/env bash

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    printf 'Run this script with: source ./activate.sh\n' >&2
    exit 1
fi

dbt_workspace_path="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)" || return 1

if [[ ! -f "$dbt_workspace_path/.venv/bin/activate" ]]; then
    printf 'Missing .venv. Run: python3 -m venv .venv\n' >&2
    return 1
fi

if [[ ! -s "$dbt_workspace_path/.postgres-password" ]]; then
    printf 'Missing or empty PostgreSQL password file.\n' >&2
    return 1
fi

DBT_ENV_SECRET_POSTGRES_PASSWORD="$(< "$dbt_workspace_path/.postgres-password")"
export DBT_ENV_SECRET_POSTGRES_PASSWORD
export DBT_PROFILES_DIR="$dbt_workspace_path/analytics"
export DBT_SEND_ANONYMOUS_USAGE_STATS=false
source "$dbt_workspace_path/.venv/bin/activate"
unset dbt_workspace_path
