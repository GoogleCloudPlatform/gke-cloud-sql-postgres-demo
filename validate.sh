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

# This script is to make sure that the create script ran correctly. It will
# make sure the Cloud SQL instance is up, as well as the GKE cluster and pod

ROOT=$(dirname "${BASH_SOURCE[0]}")

CLUSTER_NAME=$USER-poc-cluster

help() {
  echo "./validate.sh INSTANCE_NAME"
}

CLUSTER_ZONE=$(gcloud config get-value compute/zone)

export CLUSTER_ZONE
if [ -z "$CLUSTER_ZONE" ]; then
  echo "Make sure that compute/zone is set in gcloud config"
  exit 1
fi

export INSTANCE_NAME=$1
if [ -z "$INSTANCE_NAME" ] ; then
  help
  exit 1
fi

if ! gcloud sql instances describe "$INSTANCE_NAME" > /dev/null; then
  echo "FAIL: Cloud SQL instance does not exist"
else
  echo "Cloud SQL instance exists"
fi

if ! gcloud container clusters describe \
      "$CLUSTER_NAME" --zone "$CLUSTER_ZONE" > /dev/null; then
  echo "FAIL: GKE cluster does not exist"
else
  echo "GKE cluster exists"
fi

# You can look for Kubernetes objects in a variety of ways.
# This method involves giving the 'get' command the same manifest used to
# create the object. It will find an object matching
# the description in the manifest
if ! kubectl get -f "$ROOT"/manifests/pgadmin-deployment.yaml > /dev/null; then
  echo "FAIL: pgAdmin4 Deployment object does not exist"
else
  echo "pgAdmin4 Deployment object exists"
fi
