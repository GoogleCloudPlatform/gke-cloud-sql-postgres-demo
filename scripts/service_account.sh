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

# This script sets up both the service accounts that the demo needs
# The first one is for the Cloud SQL Proxy container and the service account
# gets roles/cloudsql.client
# The second is for the GKE nodes and it gets the minimal permissions needed
# for logging and monitoring as recommended by the GKE documentation

ROOT=$(dirname "${BASH_SOURCE[0]}")
source "${ROOT}"/constants.sh

if [ -z "$PROJECT" ]; then
  echo "No default project set. Please set one with gcloud config"
  exit 1
fi

gcloud iam service-accounts create "$SA_NAME" --display-name "$SA_NAME"

gcloud iam service-accounts create "$NODE_SA_NAME" --display-name "$NODE_SA_NAME"

# This is the policy for the container that will communicate with Cloud SQL Proxy
# The only permissions it needs is roles/cloudsql.client
# Remember, least privilege
gcloud projects add-iam-policy-binding "$PROJECT" \
--member serviceAccount:"$FULL_SA_NAME" \
--role roles/cloudsql.client > /dev/null

# We are building a low privilege service account for the GKE nodes
# The actual privileged SAs are built on a per-container basis
# These three privileges are the minimum needed for a functioning node
# per the GKE docs
# https://cloud.google.com/kubernetes-engine/docs/how-to/hardening-your-cluster#use_least_privilege_service_accounts_for_your_nodes
gcloud projects add-iam-policy-binding "$PROJECT" \
--member serviceAccount:"$FULL_NODE_SA_NAME" \
--role roles/logging.logWriter > /dev/null

gcloud projects add-iam-policy-binding "$PROJECT" \
--member serviceAccount:"$FULL_NODE_SA_NAME" \
--role roles/monitoring.metricWriter > /dev/null

gcloud projects add-iam-policy-binding "$PROJECT" \
--member serviceAccount:"$FULL_NODE_SA_NAME" \
--role roles/monitoring.viewer > /dev/null

gcloud iam service-accounts keys create credentials.json --iam-account "$FULL_SA_NAME"
