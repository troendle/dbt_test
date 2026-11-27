# Local dbt analytics project

Run dbt in an Ubuntu WSL Python virtual environment, with PostgreSQL in Rancher
Desktop. Rancher Desktop must be running with the Moby engine and Ubuntu WSL
integration enabled.

## Daily use

From the workspace root:

```bash
docker compose up -d --wait
source ./activate.sh
cd analytics
dbt debug
dbt build
```

Activation loads the database password from the git-ignored
`../.postgres-password` file and selects this project's `profiles.yml`.
Anonymous dbt usage reporting is disabled. Credentials are not stored in the
profile. The database is `dbt_test`, the user is `dbt`, and models are created
in the `analytics` schema at `127.0.0.1:5432`.

The dbt VS Code extension also reads the password from the private, Git-ignored
`analytics/.env` file. This is a separate copy: update it when the password
file changes. The extension also requires
`DBT_ALLOW_EXPERIMENTAL_ADAPTERS=true` in that file to enable its experimental
Postgres adapter support and the PostgreSQL client runtime on the Ubuntu host:

```bash
sudo apt-get install libpq5
```

Reload VS Code after changing the file.

The first starter model creates two rows with unique, non-null IDs. The second
references it and selects ID 1. Both models have uniqueness and non-null tests.

## Recreate the Python environment

From the workspace root, with Python venv support installed:

```bash
python3 -m venv .venv
.venv/bin/python -m pip install -r requirements.txt
```

In VS Code, select `.venv/bin/python` as the Python interpreter. Use `deactivate`
to exit the virtual environment.

## Database lifecycle

From the workspace root, `docker compose stop` stops PostgreSQL without removing
its data. `docker compose up -d --wait` starts it again. Do not use
`docker compose down -v` unless you intend to delete the database data.

## Browser editor (community dbt UI)

The workspace also runs [dbt UI](https://github.com/data-diving/dbt-ui), an
independent community application, not an official dbt product.

From the workspace root:

```bash
docker compose --profile ui up -d --wait
```

Open <http://localhost:8080>, enter a local Git identity when prompted, and open
the server folder `/home/dbtui/git-repos/dbt_test/analytics`. Click **Create
virtual environment** to install the pinned project dependencies. You can then
edit models, explore lineage, and run dbt from the browser. No GitHub account
or remote repository is required.

The UI creates a personal Git branch and worktree: browser edits are separate
from the original `analytics` folder in VS Code. The branch starts from the
repository's committed HEAD, not uncommitted changes. Commit browser changes and
merge your UI branch into your working branch to bring them back to the
original folder. Workspaces and their Python environments persist in a Docker
volume.

Only the browser port is published, bound to localhost. The backend receives
the database password from the existing Docker secret and can access the entire
workspace through its bind mount. Keep this UI local; it has no login
configured and can execute project code.

The backend build uses the Ubuntu host's additional CA certificates from
`/usr/local/share/ca-certificates` to support this environment's HTTPS proxy
without disabling TLS verification. This path must exist when rebuilding.

If recreating the workspace, restore the pinned UI source before building:

```bash
git clone https://github.com/data-diving/dbt-ui.git .tools/dbt-ui
git -C .tools/dbt-ui checkout c82d2b07ee6e6dc454b1a14d08c2c4b0dc49c86e
docker compose --profile ui up -d --build --wait
```
