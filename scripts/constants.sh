PROJECT=$(gcloud config get-value core/project)

CLUSTER_ZONE=$(gcloud config get-value compute/zone)
CLUSTER_NAME=postgres-demo-cluster

INSTANCE_REGION=$(gcloud config get-value compute/region)

SA_NAME=postgres-demo-sa
NODE_SA_NAME=postgres-demo-node-sa
FULL_SA_NAME=$SA_NAME@$PROJECT.iam.gserviceaccount.com
FULL_NODE_SA_NAME=$NODE_SA_NAME@$PROJECT.iam.gserviceaccount.com