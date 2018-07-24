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

export INSTANCE_NAME=$1
if [ -z "$INSTANCE_NAME" ] ; then
  help
  exit 1
fi

"$ROOT"/scripts/delete_resources.sh

# There is a prompt for the Cloud SQL instance because it takes a long time to
# rebuild and you might not want to delete it if you are making changes to the
# other scripts
echo "Do you want to delete the Cloud SQL instance? y/n"
read -r DELETE_INSTANCE
if [ "$DELETE_INSTANCE" == "y" ]; then
  "$ROOT"/scripts/delete_instance.sh
else
  echo "Not deleting the Cloud SQL instance"
fi
