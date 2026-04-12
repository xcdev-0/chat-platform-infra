#!/usr/bin/env bash

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="${BASE_DIR}/generated"

CA_KEY="${OUT_DIR}/kube.com-rootCA-key.pem"
CA_CERT="${OUT_DIR}/kube.com-rootCA.pem"
CA_SERIAL="${OUT_DIR}/kube.com-rootCA.srl"
TLS_KEY="${OUT_DIR}/kube.com-key.pem"
TLS_CSR="${OUT_DIR}/kube.com.csr"
TLS_CERT="${OUT_DIR}/kube.com.pem"
TLS_EXT="${OUT_DIR}/kube.com.ext"

mkdir -p "${OUT_DIR}"
chmod 700 "${OUT_DIR}"

if [[ ! -f "${CA_KEY}" || ! -f "${CA_CERT}" ]]; then
  openssl genrsa -out "${CA_KEY}" 4096
  openssl req -x509 -new -nodes -key "${CA_KEY}" -sha256 -days 3650 \
    -out "${CA_CERT}" \
    -subj "/C=KR/ST=Seoul/L=Seoul/O=Capstone HomeLab/OU=Dev/CN=Capstone Local Root CA"
fi

openssl genrsa -out "${TLS_KEY}" 2048
openssl req -new -key "${TLS_KEY}" -out "${TLS_CSR}" \
  -subj "/C=KR/ST=Seoul/L=Seoul/O=Capstone HomeLab/OU=Dev/CN=*.kube.com"

cat > "${TLS_EXT}" <<'EOF'
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage=digitalSignature,keyEncipherment
extendedKeyUsage=serverAuth
subjectAltName=@alt_names

[alt_names]
DNS.1=*.kube.com
DNS.2=frontend.kube.com
DNS.3=backend.kube.com
DNS.4=argocd.kube.com
DNS.5=jenkins.kube.com
EOF

openssl x509 -req -in "${TLS_CSR}" \
  -CA "${CA_CERT}" \
  -CAkey "${CA_KEY}" \
  -CAcreateserial \
  -CAserial "${CA_SERIAL}" \
  -out "${TLS_CERT}" \
  -days 825 \
  -sha256 \
  -extfile "${TLS_EXT}"

echo "Generated files:"
echo "  Root CA cert : ${CA_CERT}"
echo "  Root CA key  : ${CA_KEY}"
echo "  TLS cert     : ${TLS_CERT}"
echo "  TLS key      : ${TLS_KEY}"
