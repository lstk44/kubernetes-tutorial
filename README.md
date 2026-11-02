# Kubernetes and Docker Tutorial with Python and UV

A foundational learning repository demonstrating how to containerize a modern Python application managed by `uv` and deploy it to a local Kubernetes cluster using `kind` and `kubectl`.

---

## Core Concepts Explained

### What is Kubernetes?
Kubernetes (often abbreviated as **K8s**) is an open-source container orchestration platform. While Docker allows you to package and run a single application container on your machine, Kubernetes automates the deployment, scaling, networking, and management of hundreds or thousands of containers across clusters of computers.

### What are the Benefits of Kubernetes?
* **Automated Rollouts and Rollbacks:** Kubernetes incrementally changes your application's state or configuration, ensuring it doesn't kill all instances at once. If something goes wrong, it automatically rolls back the change.
* **Service Discovery and Load Balancing:** Kubernetes can expose containers using a DNS name or their own IP address. If traffic to a container is high, Kubernetes load-balances and distributes the network traffic across the cluster.
* **Self-Healing:** If a container crashes, fails a health check, or a node dies, Kubernetes automatically restarts containers, replaces them, or reschedules them onto healthy hardware.
* **Configuration and Secret Management:** You can deploy and update configuration settings (like ConfigMaps) and sensitive credentials without rebuilding your container images.

### What is Kind? How Does it Relate to OpenShift and AKS?
* **Kind (Kubernetes in Docker):** A tool for running local Kubernetes clusters using Docker container "nodes." It is designed primarily for local development, testing, and learning without needing heavy cloud infrastructure.
* **Relation to OpenShift and AKS:** 
  * **AKS (Azure Kubernetes Service):** A fully managed Kubernetes service hosted in the Microsoft Azure cloud. 
  * **OpenShift:** An enterprise Kubernetes platform built by Red Hat that adds advanced developer tools, security controls, and management layers on top of standard Kubernetes.
  * *The connection:* All three use the exact same underlying Kubernetes API and core architecture. Skills learned locally using **Kind** and `kubectl` directly translate to managing production workloads on **AKS**, **OpenShift**, or any other cloud provider.

### What is Kubectl?
`kubectl` is the official command-line tool for communicating with and controlling Kubernetes clusters. It sends commands to the cluster's control plane API server to deploy applications, inspect resource status, view logs, and manage cluster nodes.

### What is a Manifest?
A manifest is a text file (written in YAML) that defines the **desired state** of your application in Kubernetes. It tells Kubernetes what objects to create (such as a Deployment, ConfigMap, or Service), what container images to use, how many replicas to run, and how environment variables should be injected. Kubernetes continuously works to ensure the actual state of the cluster matches the configuration defined in your manifest.

---

## Architecture Overview

This project showcases a modern, lightweight workflow for local cloud-native development:
1. **Package Management (`uv`):** Uses Astral's `uv` for lightning-fast dependency resolution and isolated environment synchronization.
2. **Containerization (`Docker`):** Implements an optimized multi-stage `Dockerfile` leveraging cache layers and Python module execution.
3. **Configuration Management (`Kubernetes ConfigMaps`):** Decouples application settings (`LOG_LEVEL`, `APP_MODE`, `MAX_RETRIES`) from source code, injecting them dynamically as environment variables into pods.
4. **Local Orchestration (`Kind`):** Deploys and manages stateless workloads locally using Kubernetes in Docker.

---

## Repository Structure

```text
kubernetes-tutorial/
├── src/
│   └── kubernetes_tutorial/
│       ├── __init__.py
│       └── main.py
├── .gitignore
├── .python-version
├── Dockerfile
├── deployment.yaml
├── pyproject.toml
├── README.md
└── uv.lock
```

---

## Getting Started

**Prerequisites**
- Docker Desktop installed and running.
- Kubectl command-line tool.
- Kind (Kubernetes in Docker).
- UV package manager.

1. **Local Execution**

To run the application locally using `uv`:

```bash
uv run python -m kubernetes_tutorial.main
```

2. **Building the Docker Image**

Build the container image from the root directory:

```bash
docker build -t kubernetes-tutorial:latest .
```

3. **Loading the Image into Kind**

Load your locally built image into your local `kind` cluster (named `kubernetes-tutorial-cluster`):

```bash
kind load docker-image kubernetes-tutorial:latest --name kubernetes-tutorial-cluster
```

4. **Deploying to Kubernetes**

Apply the combined ConfigMap and Deployment manifest:

```bash
kubectl apply -f deployment.yaml
```

5. **Inspecting Results**

Verify that the deployment and pod are active:

```bash
kubectl get pods
```

View the runtime output and injected environment variables from the container logs:

```bash
kubectl logs deployment/app-deployment
```

---

## Configuration Management

The application configuration is managed externally via a Kubernetes ConfigMap defined in `deployment.yaml`:

- `LOG_LEVEL`: Controls logging verbosity (info, debug).
- `APP_MODE`: Switches operational behavior (development, production).
- `MAX_RETRIES`: Defines operational fault tolerance limits.