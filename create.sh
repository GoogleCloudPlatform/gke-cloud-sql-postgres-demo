#!/bin/bash -e

# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This script will build all the GCP resources in this demo
# The resources include a GKE cluster, a Cloud SQL instance, and
# some accompanying service accounts

help() {
  echo "./create.sh POSTGRES_USERNAME PGADMIN_USERNAME"
  echo "Passwords will be entered via prompts"
}

ROOT=$(dirname "${BASH_SOURCE[0]}")

RANDOM_SUFFIX=$(tr -dc 'a-z0-9' </dev/urandom | fold -w 6 | head -n 1)
export INSTANCE_NAME=demo-postgres-${RANDOM_SUFFIX}
echo "$INSTANCE_NAME" > "${ROOT}"/.instance

if [ -z "$INSTANCE_NAME" ] ; then
  help
  exit 1
fi

export USER_NAME=$1
if [ -z "$USER_NAME" ] ; then
  help
  exit 1
fi

export PG_ADMIN_CONSOLE_EMAIL=$2
if [ -z "$PG_ADMIN_CONSOLE_EMAIL" ]; then
  help
  exit 1
fi

CLUSTER_ZONE=$(gcloud config get-value compute/zone)
INSTANCE_REGION=$(gcloud config get-value compute/region)

export CLUSTER_ZONE
if [ -z "$CLUSTER_ZONE" ]; then
  echo "Make sure that compute/zone is set in gcloud config"
  exit 1
fi

export INSTANCE_REGION
if [ -z "$INSTANCE_REGION" ]; then
  echo "Make sure that compute/region is set in gcloud config"
  exit 1
fi

if [ -z "$USER_PASSWORD" ]; then
  echo "Enter a password for $USER_NAME"
  read -r USER_PASSWORD
  export USER_PASSWORD=$USER_PASSWORD
fi

if [ -z "$USER_PASSWORD" ] ; then
  echo "Password can't be blank or whitespace"
  exit 1
fi

if [ -z "$PG_ADMIN_CONSOLE_PASSWORD" ]; then
  echo "Enter a password for $PG_ADMIN_CONSOLE_EMAIL"
  read -r PG_ADMIN_CONSOLE_PASSWORD
  export PG_ADMIN_CONSOLE_PASSWORD=$PG_ADMIN_CONSOLE_PASSWORD
fi

if [ -z "$PG_ADMIN_CONSOLE_PASSWORD" ] ; then
  echo "Password can't be blank or whitespace"
  exit 1
fi

ROOT=$(dirname "${BASH_SOURCE[0]}")

if "$ROOT"/scripts/prerequisites.sh; then
  "$ROOT"/scripts/enable_apis.sh
  "$ROOT"/scripts/postgres_instance.sh
  "$ROOT"/scripts/service_account.sh
  "$ROOT"/scripts/cluster.sh
  "$ROOT"/scripts/configs_and_secrets.sh
  "$ROOT"/scripts/pgadmin_deployment.sh
fi
