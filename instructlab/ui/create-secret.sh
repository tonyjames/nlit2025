#!/usr/bin/env bash

FILE=$1
NAMESPACE="instructlab"

if [ -z ${FILE} ]; then
  echo "Usage: create-secret.sh [FILE]"
  exit
fi

oc create secret generic ilab-ui-env \
  --from-file=.env=${FILE} \
  -n ${NAMESPACE}
