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
DNS_UPDATE() {
  PRIVATEIP=$(aws --region us-east-1 ec2 describe-instances --filters "Name=tag:Name,Values=${COMPONENT}" | jq .Reservations[].Instances[].PrivateIpAddress | xargs -n1)
  sed -e "s/COMPONENT/${COMPONENT}/" -e "s/IPADDRESS/${PRIVATEIP}/" record.json >/tmp/record.json
  aws route53 change-resource-record-sets --hosted-zone-id Z04373561YPMQTZH9WA2Z --change-batch file:///tmp/record.json | jq
}

INSTANCE_CREATE() {
  INSTANCE_STATE=$(aws --region us-east-1 ec2 describe-instances --filters "Name=tag:Name,Values=${COMPONENT}" | jq .Reservations[].Instances[].State.Name | xargs -n1)
  if [ "${INSTANCE_STATE}" = "running" ]; then
    echo "${COMPONENT} Instance Already Exists!!"
    DNS_UPDATE
    return 0
  fi

  if [ "${INSTANCE_STATE}" = "stopped" ]; then
    echo "${COMPONENT} Instance Already Exists!!"
    return 0
  fi
  echo -n Instance ${COMPONENT} created - IPADDRESS is
  aws --region us-east-1 ec2 run-instances --launch-template  LaunchTemplateId=${LID},Version=${LVER} --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${COMPONENT}}]" | jq | grep PrivateIpAddress |xargs -n1
  sleep 10
  DNS_UPDATE
}

if [ "${1}" == "all"]; then
  for component in frontend mongodb catalogue redis cart user mysql shipping rabbitmq payment ; do
    COMPONENT=$component
    INSTANCE_CREATE
  done
else
  COMPONENT=$1
  INSTANCE_CREATE
fi



