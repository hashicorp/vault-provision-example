#!/usr/bin/env bash
set -e

shopt -s nullglob

function provision() {
  set +e
  pushd "$1" > /dev/null
  for f in $(ls "$1"/*.json); do
    p="$1/${f%.json}"
    echo "Provisioning $p"
    # echo runnin curl --location --fail --header "X-Vault-Token: ${VAULT_TOKEN}" --data @"${f}" "${VAULT_ADDR}/v1/${p}"
    curl --silent --location --fail --header "X-Vault-Token: ${VAULT_TOKEN}" --data @"${f}" "${VAULT_ADDR}/v1/${p}"
  done
  popd > /dev/null
  set -e
}

echo "Verifying Vault is unsealed"
vault status > /dev/null

pushd ../data >/dev/null
provision sys/auth
provision sys/mounts
provision sys/policy
provision postgresql/config
provision postgresql/roles
provision auth/userpass/users
provision secret/app1/dev
provision secret/app1/prod
provision secret/app2/dev
provision secret/app2/prod
popd > /dev/null
