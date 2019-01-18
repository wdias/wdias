# Run with Minikube

Create a separate minikube instance to run the WDIAS.
```
minikube profile wdias
# minikube profile was successfully set to minikube
minikube config view

kubectl config use-context wdias

minikube start --profile wdias --memory 6144 --cpus 3 --vm-driver=hyperkit
```
Issues:
- Error: configmaps is forbidden: User "system:serviceaccount:kube-system:default" cannot list configmaps in the namespace "kube-system"

Answer: 
> Helm runs with "default" service account. You should provide permissions to it.

> For read-only permissions:

> kubectl create rolebinding default-view --clusterrole=view --serviceaccount=kube-system:default --namespace=kube-system
For admin access: Eg: to install packages.

> kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default

```
minikube stop

minikube profile minikube
minikube config view
kubectl config use-context minikube
minikube start --profile minikube --memory 3072 --cpus 3 --vm-driver=hyperkit
```

# Use different vm-driver
- Select the Virtulization envirnment which need for your Operating System - `https://docs.okd.io/latest/minishift/getting-started/setting-up-virtualization-environment.html`
  - MacOS: [hyperkit](https://docs.okd.io/latest/minishift/getting-started/setting-up-virtualization-environment.html#setting-up-hyperkit-driver)
  - As state [here](https://github.com/kubernetes/minikube/blob/master/docs/drivers.md#hyperkit-driver), the Hyperkit driver will eventually replace the existing xhyve driver.
  - [On macOS](https://gist.github.com/inadarei/7c4f4340d65b0cc90d42d6382fb63130#gistcomment-2315322) `brew install docker-machine-driver-hyperkit`
  - `minikube start --vm-driver=hyperkit`

# Set Minikube resources (memory & cpus)
- As state in [this discussion](https://github.com/kubernetes/minikube/issues/567), It's possible to change the resources - `minikube start -h`.
But it's necessary to delete the existing minikube, the memory won't be changed as this is done on creation of the VM. 
```
minikube stop
minikube delete
minikube --memory 8192 --cpus 4 start
```


# Deploy Particular Service

Go to the project directory wich contains the `Dockerfile`
`wdias build`

Then go to the helm-chart for that service
`wdias helm_delete &&  wdias helm_install`
