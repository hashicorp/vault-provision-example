#!/usr/bin/env bash
set -e

shopt -s nullglob

function provision() {
  set +e
  pushd "$1" > /dev/null
  find . -maxdepth 1 -name "*.json" -type f -printf "%f\n" | while read f; do
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
provision sys/auth
provision sys/mounts
provision sys/policy
provision postgresql/config
provision postgresql/roles
provision auth/userpass/users
popd > /dev/null
