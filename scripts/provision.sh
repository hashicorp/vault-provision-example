#!/usr/bin/env bash
set -e

shopt -s nullglob

function provision() {
  set +e
  pushd "$1" > /dev/null
  for f in $(ls "$1"/*.json); do
    p="$1/${f%.json}"
    echo "Provisioning $p"
    # echo running curl --location --fail --header "X-Vault-Token: ${VAULT_TOKEN}" --data @"${f}" "${VAULT_ADDR}/v1/${p}"
    curl  --location --fail --header "X-Vault-Token: ${VAULT_TOKEN}" --data @"${f}" "${VAULT_ADDR}/v1/${p}"
  done
  popd > /dev/null
  set -e
}

echo "If not on CircleCI, apply env vars (for testing locally)"
if [ "$CIRCLECI" != "true" ]; then
    echo "Applying local env vars"
    source env.local
fi

echo "Applying env variables to config files"
sed -e "s/DATABASE_CONNECTION_STRING/$DB_USERNAME:$DB_PASSWORD@$DB_URL/g" \
  templates/connection.json > ../data/database/config/postgres/connection.json

echo "Verifying Vault is unsealed"
vault status > /dev/null

pushd ../data >/dev/null
provision sys/auth
provision sys/mounts
provision sys/policy
provision database/config
provision database/roles
provision auth/userpass/users
provision secret/app1/dev
provision secret/app1/prod
provision secret/app2/dev
provision secret/app2/prod
popd > /dev/null

echo "Restoring config files"
cat templates/connection.json > ../data/database/config/postgres/connection.json
