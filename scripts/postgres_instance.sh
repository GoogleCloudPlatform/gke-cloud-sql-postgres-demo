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

set -o errexit

# This command is using the --async flag because it generally takes too long
# to finish and causes gcloud to time out. The loop in the next section is
# used to wait for the instance to reach a good state
gcloud sql instances create "$INSTANCE_NAME" \
--database-version POSTGRES_9_6 \
--region "$INSTANCE_REGION" \
--tier db-f1-micro \
--storage-type HDD \
--async > /dev/null

echo "Cloud SQL instance creation started. This process takes a long time (5-10min)."

# Running a loop to wait for the Cloud SQL instance to become "RUNNABLE"
COUNTER=61
until [  $COUNTER -lt 2 ]; do
  echo "Waiting for instance to finish starting.."
  if gcloud sql instances describe "$INSTANCE_NAME" \
  --format="default(state)" | grep RUNNABLE; then
    break
  fi
  sleep 10
  let COUNTER=COUNTER-1
done

if [[ $COUNTER -lt 2 ]]; then
  echo "Cloud SQL instance creation timed out"
  exit 1
fi

# Making a Postgres user that is allowed to connect from any host
gcloud sql users create "$USER_NAME" \
'%' \
--instance "$INSTANCE_NAME" \
--password "$USER_PASSWORD"
