---
title: Kong Ingress on Azure Kubernetes Service (AKS)
---

## Requirements

1. A fully functional AKS cluster.
   Please follow Azure's Guide to
   [set up an AKS cluster](https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough).
1. Basic understanding of Kubernetes
1. A working `kubectl` linked to the AKS Kubernetes
   cluster you'll work on. The above AKS setup guide will help
   you set this up.

## Deploy the {{site.kic_product_name}} {#deploy-kic}

Deploy the {{site.kic_product_name}} using `kubectl`:

```bash
$ kubectl create -f https://bit.ly/k4k8s
namespace/kong created
customresourcedefinition.apiextensions.k8s.io/kongplugins.configuration.konghq.com created
customresourcedefinition.apiextensions.k8s.io/kongconsumers.configuration.konghq.com created
customresourcedefinition.apiextensions.k8s.io/kongcredentials.configuration.konghq.com created
customresourcedefinition.apiextensions.k8s.io/kongingresses.configuration.konghq.com created
serviceaccount/kong-serviceaccount created
clusterrole.rbac.authorization.k8s.io/kong-ingress-clusterrole created
clusterrolebinding.rbac.authorization.k8s.io/kong-ingress-clusterrole-nisa-binding created
configmap/kong-server-blocks created
service/kong-proxy created
service/kong-validation-webhook created
deployment.extensions/kong created
```

It will take a few minutes for all containers to start and report
healthy status.

Alternatively, you can use our helm chart as well.
Please ensure that you have Tiller working and then execute:

```bash
$ helm repo add kong https://charts.konghq.com
$ helm repo update

# Helm 3
$ helm install kong/kong --generate-name --set ingressController.installCRDs=false
```

*Note:* this process could take up to five minutes the first time.

## Set up environment variables

Next, set up an environment variable with the IP address at which
Kong is accessible. This will be used to actually send requests into the
Kubernetes cluster.

Execute the following command to get the IP address at which Kong is accessible:

```bash
$ kubectl get services -n kong
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                      AGE
kong-proxy   LoadBalancer   10.63.250.199   203.0.113.42   80:31929/TCP,443:31408/TCP   57d
```

Let's set up an environment variable to hold the IP address:

```bash
$ export PROXY_IP=$(kubectl get -o jsonpath="{.status.loadBalancer.ingress[0].ip}" service -n kong kong-proxy)
```

> Note: It may take a while for Microsoft Azure to actually associate the
IP address to the `kong-proxy` Service.

Once you've installed the {{site.kic_product_name}}, please follow our
[getting started](/kubernetes-ingress-controller/{{page.kong_version}}/guides/getting-started) tutorial to learn
about how to use the Ingress Controller.
