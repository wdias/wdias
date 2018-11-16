# Run with Minikube

Create a separate minikube instance to run the WDIAS.
```
minikube profile wdias
# minikube profile was successfully set to minikube
minikube config view

kubectl config use-context wdias

minikube start --profile wdias
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
minikube start --profile minikube
```

# Deploy Particular Service

Go to the project directory wich contains the `Dockerfile`
`wdias build`

Then go to the helm-chart for that service
`wdias helm_delete &&  wdias helm_install`
