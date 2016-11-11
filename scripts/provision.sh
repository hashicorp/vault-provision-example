#!/usr/bin/env bash
set -e

shopt -s nullglob

function mirror() {
  set +e
  pushd "$1" > /dev/null
  for f in $(ls "$1"/*.json); do
    p="$1/${f%.json}"
    echo "Provisioning $p"
    curl \
      --silent \
      --location \
      --fail \
      --header "X-Vault-Token: ${VAULT_TOKEN}" \
      --data @"${f}" \
      "${VAULT_ADDR}/v1/${p}"
  done
  popd > /dev/null
  set -e
}

echo "Verifying Vault is unsealed"
vault status > /dev/null

pushd data >/dev/null
mirror sys/auth
mirror sys/mounts
mirror sys/policy
mirror postgresql/config
mirror postgresql/roles
mirror auth/userpass/users
popd > /dev/null
