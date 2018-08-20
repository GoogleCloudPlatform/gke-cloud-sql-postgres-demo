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

# Here we are installing secrets into the Kubernetes cluster
# Installing them into the cluster makes it very easy to access them from
# the appliations in the cluster
kubectl --namespace default create secret generic cloudsql-sa-creds \
--from-file=credentials.json=credentials.json

kubectl --namespace default create secret generic pgadmin-console \
--from-literal=user="$PG_ADMIN_CONSOLE_EMAIL" \
--from-literal=password="$PG_ADMIN_CONSOLE_PASSWORD"

CONNECTION_NAME=$(gcloud sql instances describe "$INSTANCE_NAME" \
--format="value(connectionName)")

# You can also store non-sensitive information in the cluster
# similar to a secret. In this case we are using a configMap, which
# is also very easy to access from applications in the cluster
kubectl --namespace default create configmap connectionname \
--from-literal=connectionname="$CONNECTION_NAME"
