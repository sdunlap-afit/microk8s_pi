# microk8s_pi
Simple setup for microk8s



## Helm setup

To install and configure Helm:

```bash
sudo snap install helm --classic
kubectl config view --raw > ~/.kube/config
```


# Snap config for docker

TODO: Once we have a Gitlab instance up and running, we should use that for the container registry. We may also want to get a cert for the cluster from Ryan (we'd have to configure the servers to trust our CA though).

To allow docker to pull images from the local registry, add the following to the docker config file:

`sudo vim /var/snap/docker/current/config/daemon.json`

```json
{
  "insecure-registries" : ["192.168.237.101:32000"]
}
```



# Charmed Kubeflow

This Kubeflow Platform is from Canonical but isn't working for me. Not sure if it's my version of Ubuntu, or what. I've tried it on 22.04 and 24.04 VMs, and 24.04 server.

1. DNS is not working with the default install. Specifying a DNS server during install helps.
1. The version of juju needs to be very specific. One of the dependencies is picky.

Kubeflow is a machine learning toolkit for Kubernetes. It provides a way to deploy production-ready ML pipelines. 

Kubeflow has multiple maintained variants, two of which are for any Kubernetes cluster. I chose Canonical's Charmed Kubeflow, which is a Kubernetes operator that deploys Kubeflow on any Kubernetes cluster. The tutorial even uses microk8s.

I followed this tutorial to get it up and running:

https://charmed-kubeflow.io/docs/get-started-with-charmed-kubeflow


```bash

sudo apt update && sudo apt upgrade -y

# https://github.com/canonical/microk8s/issues/4361
# Doing two steps fixes a stupid issue
sudo snap install microk8s --classic --channel=1.28/stable
sudo snap refresh microk8s --channel=1.30/stable

# Alias kubectl
echo "alias kubectl='microk8s kubectl'" >> ~/.bashrc
echo "alias helm='microk8s helm'" >> ~/.bashrc

sudo usermod -a -G microk8s $USER
newgrp microk8s


mkdir ~/.kube
sudo chown -f -R $USER ~/.kube
microk8s config > ~/.kube/config


# Depending on the microk8s version, dns may already be enabled
microk8s disable dns
microk8s enable dns:8.8.8.8
```


```bash

microk8s enable hostpath-storage ingress metallb:192.168.50.43-192.168.50.49 rbac

sudo snap install juju --classic --channel=3.4/stable

mkdir -p ~/.local/share

microk8s config | juju add-k8s my-k8s --client

juju bootstrap my-k8s uk8sx
juju add-model kubeflow


sudo sysctl fs.inotify.max_user_instances=1280
sudo sysctl fs.inotify.max_user_watches=655360

# You may need to try this command a few times before it will work
juju deploy kubeflow --trust #--channel=1.8/stable

# Watch the status of the deployment (15-60 minutes)
juju status --watch 5s


# Lots of waiting later

microk8s kubectl -n kubeflow get svc istio-ingressgateway-workload -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

juju config dex-auth public-url=http://192.168.50.43.nip.io
juju config oidc-gatekeeper public-url=http://192.168.50.43.nip.io

juju config dex-auth static-username=admin
juju config dex-auth static-password=admin

```
