#!/usr/bin/env bash

if [[ "$DEBUG" == 1 ]]; then
  set -x
fi

IAM_TOKEN=`yc iam create-token`
KMS_HTTP_ENDPOINT=${KMS_HTTP_ENDPOINT:-"kms.yandex:443"}

curl -s --insecure \
    -H "Authorization: Bearer ${IAM_TOKEN}" \
    -H "Content-type: application/json" \
    --data "${KMS_HTTP_REQUEST}" \
    "${KMS_HTTP_ENDPOINT}/kms/v1/keys/${KEY_ID}:${OP}"
