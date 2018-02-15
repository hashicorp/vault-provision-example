#!/usr/bin/env bash
set -e

shopt -s nullglob

function getCli() {
  wget https://releases.hashicorp.com/vault/0.9.3/vault_0.9.3_linux_amd64.zip vault.zip
  unzip vault.zip
}

function provision() {
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

echo "Downloading Vault CLI"
getCli

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
