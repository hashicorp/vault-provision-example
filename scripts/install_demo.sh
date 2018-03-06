#!/usr/bin/env bash
set -e

function getVault() {
  wget https://releases.hashicorp.com/vault/0.9.3/vault_0.9.3_linux_amd64.zip
  unzip vault_0.9.3_linux_amd64.zip
  export PATH=$PATH:$(pwd)
}

#TODO validate that these env vars survive after scriptt completed
function initializeVault() {
  export VAULT_ADDR='http://127.0.0.0.1:8200'
  export VAULT_TOKEN='root'
  vault init -demo -token=root
}

echo 'Downloading Vault ...'
getVault

echo 'Initializing Vault ...'
initializeVault