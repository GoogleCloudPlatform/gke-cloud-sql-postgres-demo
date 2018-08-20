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

# This script deletes everything but the Cloud SQL instance. Building a
# Cloud SQL instance takes a long time so deleting it is a separate step
# that includes a prompt in another script

ROOT=$(dirname "${BASH_SOURCE[0]}")
source "${ROOT}"/constants.sh

gcloud container clusters delete \
postgres-demo-cluster --zone "$CLUSTER_ZONE" --quiet

gcloud projects remove-iam-policy-binding "$PROJECT" \
--member serviceAccount:"$FULL_SA_NAME" \
--role roles/cloudsql.client > /dev/null

gcloud projects remove-iam-policy-binding "$PROJECT" \
--member serviceAccount:"$FULL_NODE_SA_NAME" \
--role roles/logging.logWriter > /dev/null

gcloud projects remove-iam-policy-binding "$PROJECT" \
--member serviceAccount:"$FULL_NODE_SA_NAME" \
--role roles/monitoring.metricWriter > /dev/null

gcloud projects remove-iam-policy-binding "$PROJECT" \
--member serviceAccount:"$FULL_NODE_SA_NAME" \
--role roles/monitoring.viewer > /dev/null

gcloud iam service-accounts delete "$FULL_SA_NAME" \
--quiet && rm credentials.json

gcloud iam service-accounts delete "$FULL_NODE_SA_NAME" --quiet
