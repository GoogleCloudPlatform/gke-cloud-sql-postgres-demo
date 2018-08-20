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

PROJECT=$(gcloud config get-value core/project)
export PROJECT
CLUSTER_ZONE=$(gcloud config get-value compute/zone)
export CLUSTER_ZONE
export CLUSTER_NAME=postgres-demo-cluster

INSTANCE_REGION=$(gcloud config get-value compute/region)
export INSTANCE_REGION
export SA_NAME=postgres-demo-sa
export NODE_SA_NAME=postgres-demo-node-sa
export FULL_SA_NAME=$SA_NAME@$PROJECT.iam.gserviceaccount.com
export FULL_NODE_SA_NAME=$NODE_SA_NAME@$PROJECT.iam.gserviceaccount.com