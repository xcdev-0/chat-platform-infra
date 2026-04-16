#!/usr/bin/env bash

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="${BASE_DIR}/generated"

TLS_CERT="${OUT_DIR}/kube.com.pem"
TLS_KEY="${OUT_DIR}/kube.com-key.pem"

if [[ ! -f "${TLS_CERT}" || ! -f "${TLS_KEY}" ]]; then
  echo "TLS certificate not found. Run generate-kube-com-cert.sh first." >&2
  exit 1
fi

kubectl -n dev create secret tls kube-com-tls \
  --cert="${TLS_CERT}" \
  --key="${TLS_KEY}" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n argocd create secret tls argocd-server-tls \
  --cert="${TLS_CERT}" \
  --key="${TLS_KEY}" \
  --dry-run=client -o yaml | kubectl apply -f -
