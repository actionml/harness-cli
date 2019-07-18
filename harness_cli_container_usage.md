# Harness-cli Container Usage

Harness Server presents a REST API to the world and ALL communications with the server go through this connection. 

The control CLI is implemented using the Python Client SDK for Harness. To install the CLI (usually on a remote host) it is easiest to use the Docker image.

# Prerequisites

We will assume the host will run `harness-cli` inside its container. We also assume you are connecting to a Kubernetes managed Harness deployment, though many steps will work for any deployment. This has the following prerequisite: 

 - The [Docker container hosting tools](https://docs.docker.com/install/): this consists of the the `docker` and `docker-compose` CLI tools and the docker daemon among other things.

# Installation for Remote Harness Server / Local Harness-CLI

Once Docker is installed we will launch the harness-cli container to point to the Harness Server address.

```
docker run --name harness-cli -d \
    -e HARNESS_SERVER_ADDRESS=<harness-ip-address> \
    actionml/harness-cli:develop
docker exec -it harness-cli bash
```

At this point you are logged into the container and pointing to the Harness Server address. Any address can be substituted.

# Connecting to a Kubernetes Cluster

Prerequisites: 

 - To connect directly to a Kubernetes cluster securely you should use `kubectl`. 

To map Harness Server to the host's IP run the following:

```
export KUBECONFIG=kubeconfig.yml # sets cluster config...
kubectl get pods # get info from k8s above
# note the harness pod ID
kubectl port-forward --address 0.0.0.0 harness-pod-id 9090:9090
```

This sets up the host's `localhost:9090` to connect to the k8s Harness. 

Now launch the `harness-cli` container pointing it to the host's port. From inside the container the address `172.17.0.1` is magically mapped, by docker machine, to the host of the container. 

```
docker run --name harness-cli -d \
    -e HARNESS_SERVER_ADDRESS=172.17.0.1:9090 \
    actionml/harness-cli:develop
docker exec -it harness-cli bash
```

# Using Harness CLI

Once the container is able to connect to Harness Server.

```
harness-cli status
harness-cli status engines
harness-cli status engines <engine-id>
...
```

