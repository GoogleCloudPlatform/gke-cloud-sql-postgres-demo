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

# This script builds the GKE cluster that we launch our application and the
# Cloud SQL Proxy in

set -o errexit

ROOT=$(dirname "${BASH_SOURCE[0]}")
# shellcheck disable=SC1090
source "${ROOT}"/constants.sh

GKE_VERSION=$(gcloud container get-server-config --zone "$CLUSTER_ZONE" \
  --format="value(validMasterVersions[0])")

gcloud container clusters create "$CLUSTER_NAME" \
--cluster-version "$GKE_VERSION" \
--num-nodes 1 \
--enable-autorepair \
--zone "$CLUSTER_ZONE" \
--service-account="postgres-demo-node-sa@$PROJECT".iam.gserviceaccount.com \

# Setting up .kube/config. This happens normally if you don't use --async
gcloud container clusters get-credentials "$CLUSTER_NAME" --zone "$CLUSTER_ZONE"
