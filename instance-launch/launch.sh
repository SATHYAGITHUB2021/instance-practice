#!/bin/bash

COMPONENT=$1
##-z validates the variable empty, true if it is empty.

if [ -z "${COMPONENT}" ]; then
  echo "Component is Needed"
  exit 1
fi

LID=lt-0cff640d7e3d4dbdf
LVER=2
#Validate if Instance is already there

INSTANCE_STATE=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${COMPONENT}" | jq .Reservations[].Instances[].State.Name | xargs -n1)

if [ "${INSTANCE_STATE}" = "running" ]; then
  echo "Instance Already Exists!!"
  exit 0
fi

if [ "${INSTANCE_STATE}" = "stopped" ]; then
  echo "Instance Already Exists!!"
  exit 0
fi


aws ec2 run-instances --launch-template  LaunchTemplateId=${LID},Version=${LVER} --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${COMPONENT}}]" | jq


