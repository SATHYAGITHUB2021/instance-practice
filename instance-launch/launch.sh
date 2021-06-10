#!/bin/bash

COMPONENT=$1

if [ -z "${component}" ]; then
  echo "Component is Needed"
  exit 1
fi
aws ec2 run-instances --launch-template  LaunchTemplateId=lt-0cff640d7e3d4dbdf,Version=2 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${COMPONENT}]" | jq


