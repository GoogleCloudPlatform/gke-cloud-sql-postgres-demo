# Connecting to Cloud SQL from an application in Kubernetes Engine

## Table of Contents

* [Introduction](#introduction)
    * [Unprivileged service accounts](#unprivileged-service-accounts)
    * [Privileged service accounts in containers](#privileged-service-accounts-in-containers)
    * [Cloud SQL Proxy](#cloud-sql-proxy)
* [Architecture](#architecture)
* [Prerequisites](#prerequisites)
  * [Tools](#tools)
* [Deployment](#deployment)
* [Validation](#validation)
* [Teardown](#teardown)
* [Troubleshooting](#troubleshooting)
  * [Issue](#issue)
  * [Resolution](#resolution)

## Introduction

This demo shows how easy it is to connect an application in Kubernetes Engine to
a Cloud SQL instance using the Cloud SQL Proxy container as a sidecar container.
You will deploy a [Kubernetes Engine](https://cloud.google.com/kubernetes-engine/) (Kubernetes Engine)
cluster and a [Cloud SQL](https://cloud.google.com/sql/docs/) Postgres instance
and use the [Cloud SQL Proxy container](https://gcr.io/cloudsql-docker/gce-proxy:1.11)
to allow communication between them.

While this demo is focused on connecting to a Cloud SQL instance with a Cloud
SQL Proxy container, the concepts are the same for any GCP managed service that
requires API access.

The key takeaways for this demo are:
* How to protect your database from unauthorized access by using an
unprivileged service account on your Kubernetes Engine nodes
* How to put privileged service account credentials into a container running on
Kubernetes Engine
* How to use the Cloud SQL Proxy to offload the work of connecting to your
Cloud SQL instance and reduce your applications knowledge of your infrastructure

#### Unprivileged service accounts

By default all Kubernetes Engine nodes are assigned the default Compute Engine
service account. This service account is fairly high privilege and has access
to many GCP services. Because of the way the Google Cloud SDK is setup, software
that you write will use the credentials assigned to the compute engine instance
on which it is running. Since we don't want all of our containers to have the
privileges that the default Compute Engine service account has, we need to make
a least-privilege service account for our Kubernetes Engine nodes and then
create more specific (but still least-privilege) service accounts for our
containers.

#### Privileged service accounts in containers

The only two ways to get service account credentials are 1.) through your host
instance, which as we discussed we don't want, or 2.) through a credentials
file. This demo will show you how to get this credentials file into your
container running in Kubernetes Engine so your application has the privileges
it needs.

#### Cloud SQL Proxy

The Cloud SQL Proxy allows you to offload the burden of creating and
maintaining a connection to your Cloud SQL instance to the Cloud SQL Proxy
process. Doing this allows your application to be unaware of the connection
details and simplifies your secret management. The Cloud SQL Proxy comes
pre-packaged by Google as a Docker container that you can run alongside your
application container in the same Kubernetes Engine pod.

## Architecture

The application and its sidecar container are deployed in a single Kubernetes
(k8s) pod running on the only node in the Kubernetes Engine cluster. The
application communicates with the Cloud SQL instance via the Cloud SQL Proxy
process listening on localhost.

The k8s manifest builds a single-replica Deployment object with two containers,
pgAdmin and Cloud SQL Proxy. There are two secrets installed into the Kubernetes
Engine cluster: the Cloud SQL instance connection information and a service
account key credentials file, both used by the Cloud SQL Proxy containers Cloud
SQL API calls.

The application doesn't have to know anything about how to connect to Cloud
SQL, nor does it have to have any exposure to its API. The Cloud SQL Proxy
process takes care of that for the application. It's important to note that the
Cloud SQL Proxy container is running as a 'sidecar' container in the pod.

![Application in Kubernetes Engine using a Cloud SQL Proxy sidecar container to communicate
with a Cloud SQL Proxy instance](docs/architecture-diagram.png)

## Prerequisites

### Supported Operating Systems

* macOS
* Linux
* Google Cloud Shell

### Tools

1. gcloud (Google Cloud SDK version >= 200.0.0)
2. kubectl >= 1.8.6
3. bash or bash compatible shell
4. A Google Cloud Platform project you have access to with the default network
still intact
5. Create a project and set core/project with `gcloud config set project <your_p
roject>`

If you don't have a Google Cloud account you can sign up for a [free account](https://cloud.google.com/).

## Deployment

Deployment is fully automated except for a few prompts for user input. In order
to deploy you need to run **create.sh** and follow the prompts. The script
takes the following parameters, in order:
* A name for your Cloud SQL instance
* A username for a new Postgres user that you will use to connect to the
instance with
* A username for the pgAdmin console

Example: `./create.sh INSTANCE_NAME POSTGRES_USERNAME PGADMIN_USERNAME`

**create.sh** will run the following scripts:
1. enable_apis.sh - enables the Kubernetes Engine API and Cloud SQL Admin API
2. postgres_instance.sh - creates the Cloud SQL instance and additional
Postgres user. Note that gcloud will timeout when waiting for the creation of a
Cloud SQL instance so the script manually polls for its completion instead.
3. service_account.sh - creates the service account for the Cloud SQL Proxy
container and creates the credentials file
4. cluster.sh - Creates the Kubernetes Engine cluster
5. configs_and_secrets.sh - creates the Kubernetes Engine secrets and configMap
containing credentials and connection string for the Cloud SQL instance
6. pgadmin_deployment.sh - creates the pgAdmin4 pod

Once **create.sh** is complete you need to run ```make expose``` to connect to
the running pgAdmin pod. ```make expose``` will port-forward to the running pod.
 You can [connect to the port-forwarded pgAdmin in your
browser](http://127.0.0.1:8080/login). Use the pgAdmin username in the "Email
Address" field and password you defined earlier to login to the console.
From there you can click "Add New Server" and use the database username and
password you created earlier to connect to 127.0.0.1:5432.

## Validation

Validation is fully automated. The validation script checks for the existence
of the Cloud SQL instance, the Kubernetes Engine cluster, and the running pod.
All of these resources should exist after the deployment script completes. In
order to validate you need to run **validate.sh**. The script takes the
following parameters, in order:
* INSTANCE_NAME - the name of the existing Cloud SQL instance

## Teardown

Teardown is fully automated. The teardown script deletes every resource created
in the deployment script. In order to teardown you need to run **teardown.sh**.
The script takes the following parameters, in order:
* INSTANCE_NAME - the name of the existing Cloud SQL instance

**teardown.sh** will run the following scripts:
1. delete_resources.sh - deletes everything but the Cloud SQL instance
2. delete_instance.sh - deletes the Cloud SQL instance

## Troubleshooting

### Issue

When creating a Cloud SQL instance you get the error:

```ERROR: (gcloud.sql.instances.create) Resource in project [...]
is the subject of a conflict: The instance or operation is not
in an appropriate state to handle the request.
```

### Resolution

You cannot reuse an instance name for up to a week after you have deleted an
instance.
https://cloud.google.com/sql/docs/mysql/delete-instance

**This is not an officially supported Google product**
