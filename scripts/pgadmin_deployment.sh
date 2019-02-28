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

# This script runs the only Kubernetes manifest in the project.
# It is a single pod with two containers, pgAdmin and the
# Cloud SQL Proxy container. The pod only exists as one replica.

ROOT=$(dirname "${BASH_SOURCE[0]}")

kubectl --namespace default create -f "$ROOT"/../manifests/pgadmin-deployment.yaml

# Waiting for the pod to actually deploy correctly
kubectl --namespace default rollout status --request-timeout="5m" -f "$ROOT"/../manifests/pgadmin-deployment.yaml
