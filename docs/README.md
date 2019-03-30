# Installation
- Create a directory with `mkdir ~/wdias && cd ~/wdias`
- Clone repos `git clone --depth=1 https://github.com/wdias/wdias.git && git clone --depth=1 https://github.com/wdias/wdias-helm-charts.git`
- Deploy databases `bash ~/wdias/wdias/scripts/db_setup.sh ~/wdias`
- Follow instruction to setup the MySQL databases - [wdias-mysql-schema](https://github.com/wdias/wdias-mysql-schema#install-database)
  - Clone repos `git clone --depth=1 https://github.com/wdias/wdias-mysql-schema.git`
  - `bash ~/wdias/wdias-mysql-schema/scripts/install_database.sh adapter-metadata-mysql metadata wdias` (Enter root password and database password set in the Helm Chart)
  - `bash ~/wdias/wdias-mysql-schema/scripts/install_database.sh adapter-extension-mysql extension wdias` (Enter root password and database password set in the Helm Chart)
- Deploy microservices `bash ~/wdias/wdias/scripts/helm_install.sh ~/wdias`
  - Dev mode: `bash ~/wdias/wdias/scripts/helm_install.sh ~/wdias 1`

# Run with Minikube

Create a separate minikube instance to run the WDIAS.
```
minikube profile wdias
minikube config view
kubectl config use-context wdias
minikube config set memory 3072
minikube config set cpus 2
minikube start --profile wdias
```

Or use creating a new Profile;
```
minikube start --profile wdias --memory 3072 --cpus 2 --disk-size 20g
```

Issues:
- Error: configmaps is forbidden: User "system:serviceaccount:kube-system:default" cannot list configmaps in the namespace "kube-system"

Answer: 
> Helm runs with "default" service account. You should provide permissions to it.

> For read-only permissions:

> kubectl create rolebinding default-view --clusterrole=view --serviceaccount=kube-system:default --namespace=kube-system
For admin access: Eg: to install packages.

> kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default

```sh
minikube stop
minikube profile minikube
minikube config view
kubectl config use-context minikube
# minikube config set cpus 2
# minikube config set memory 3072
# minikube config set disk-size 20g
minikube start
```

Or use creating a new profile;
```
minikube start --memory 3072 --cpus 2  --disk-size 20g
```

# Use different vm-driver
- Select the Virtulization envirnment which need for your Operating System - `https://docs.okd.io/latest/minishift/getting-started/setting-up-virtualization-environment.html`
  - MacOS: [hyperkit](https://docs.okd.io/latest/minishift/getting-started/setting-up-virtualization-environment.html#setting-up-hyperkit-driver)
  - As state [here](https://github.com/kubernetes/minikube/blob/master/docs/drivers.md#hyperkit-driver), the Hyperkit driver will eventually replace the existing xhyve driver.
  - [On macOS](https://gist.github.com/inadarei/7c4f4340d65b0cc90d42d6382fb63130#gistcomment-2315322) `brew install docker-machine-driver-hyperkit`
  - `minikube start --vm-driver=hyperkit`
```
minikube config view
kubectl config use-context wdias
minikube start --profile wdias --memory 3072 --cpus 2 --vm-driver=hyperkit
```

# Set Minikube resources (memory & cpus)
- As state in [this discussion](https://github.com/kubernetes/minikube/issues/567), It's possible to change the resources - `minikube start -h`.
But it's necessary to delete the existing minikube, the memory won't be changed as this is done on creation of the VM. 
```
minikube stop
minikube delete
minikube --memory 3072 --cpus 2 start
minikube config set cpus 2
minikube config set memory 3072
```

After fresh initialization, it's required to install `helm` and enable `ingress`.
```
helm init
sleep 20
minikube addons enable ingress
```

# Deploy Particular Service

Go to the project directory wich contains the `Dockerfile`
`wdias build`

Then go to the helm-chart for that service
`wdias helm_delete &&  wdias helm_install`
