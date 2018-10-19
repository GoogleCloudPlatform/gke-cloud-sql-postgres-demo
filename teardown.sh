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

# This script will remove all the GCP resources, which include
# the GKE cluster, the Cloud SQL instance, and the accompanying service
# accounts


ROOT=$(dirname "${BASH_SOURCE[0]}")

help() {
  echo "./teardown.sh INSTANCE_NAME"
}

INSTANCE_NAME=$(cat "${ROOT}"/.instance)
export INSTANCE_NAME
if [ -z "$INSTANCE_NAME" ] ; then
  help
  exit 1
fi

"$ROOT"/scripts/delete_resources.sh
"$ROOT"/scripts/delete_instance.sh