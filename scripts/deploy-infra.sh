#!/usr/bin/env bash
set -e

export TF_CLI_ARGS="-no-color"

echo "Staring TF deployment"
echo "ENV = $ENV"
echo "GCLOUD_PROJECT = $GCLOUD_PROJECT"
echo "FOLDER = $FOLDER"

: "${ENV:?ENV is required}"
: "${GCLOUD_PROJECT:?GCLOUD_PROJECT is required}"
: "${FOLDER:?FOLDER is required}"

case "$FOLDER" in
  terraform)
    ;;
  terraform-*)
    SUFFIX="${FOLDER#terraform-}"
    if ! echo "$SUFFIX" | grep -qE '^[-a-z0-9]+$'; then
      echo "Error: SUFFIX must contain only lowercase letters and digits."
      exit 1
    fi
    ;;
  *)
    echo "Error: FOLDER must be 'terraform' or 'terraform-<suffix>' with lowercase letters and digits only."
    exit 1
    ;;
esac

cd "$FOLDER"

echo
echo terraform version
echo terraform init -backend-config="bucket=zw-mcom-terraform-state-bucket-$ENV"
echo terraform validate
echo terraform plan -var-file="terraform-$ENV.tfvars"
echo terraform apply -auto-approve -var-file="terraform-$ENV.tfvars"
waitingTime=$(shuf -i 1-30 -n 1)
echo "simulated waiting time: $waitingTime seconds"
sleep $waitingTime

echo "TF deployment complete"
