#!/bin/bash

COMPONENT=$1

if [ -z "${component}" ]; then
  echo "Component is Needed"
  exit 1
fi
