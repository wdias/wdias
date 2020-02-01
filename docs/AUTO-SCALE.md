# Pod Auto Scaling

The Horizontal Pod Autoscaler is implemented as a control loop, with a period controlled by the controller manager’s --horizontal-pod-autoscaler-sync-period flag (with a default value of 15 seconds)
- `https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#how-does-the-horizontal-pod-autoscaler-work`
Not able change flag `horizontal-pod-autoscaler-sync-period` this on GKE, EKS and other managed clusters.
- `https://stackoverflow.com/questions/54525009/change-the-horizontal-pod-autoscaler-sync-period-in-eks`

## How it works?
As described in [resource types](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#resource-types), 
While creating the pods for auto scaling, first it need to create with defining resource limits.
E.g: `kubectl run php-apache --image=k8s.gcr.io/hpa-example --requests=cpu=200m --limits=cpu=500m --expose --port=80`
It's possible to define these within the helm chart or deployment yaml.

Then define the auto scaling like below;
```sh
kubectl autoscale deployment import-ascii-grid-upload --cpu-percent=80 --min=1 --max=10
```
Depend on the requested cpu while the pod deployment, k8s spawn new pods or shink pods based on the [algorithm below](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#algorithm-details);
```sh
desiredReplicas = ceil[currentReplicas * ( currentMetricValue / desiredMetricValue )]
```
For example, if the current metric value is 200m, and the desired value is 100m, the number of replicas will be doubled, since 200.0 / 100.0 == 2.0 If the current value is instead 50m, we’ll halve the number of replicas, since 50.0 / 100.0 == 0.5. We’ll skip scaling if the ratio is sufficiently close to 1.0 (within a globally-configurable tolerance, from the --horizontal-pod-autoscaler-tolerance flag, which defaults to 0.1).

- Delete an existing autoscale
```sh
kubectl get hpa
kubectl delete hpa import-ascii-grid-upload
```

## Analyze Pod Scheduling
- Get list of nodes
`kubectl get nodes`
- Get pods sort by node name
`kubectl get pods -o wide --sort-by="{.spec.nodeName}"`
- Get Pods scheduled on a node
`kubectl get pods -o wide --field-selector spec.nodeName=<node_name>`
`kubectl get pods --all-namespaces --field-selector spec.nodeName=<node_name>`
- Show all of the non-terminated pods running on that node
`kubectl describe node <node_name>`
- Get pods on nodes using label filter
```
for n in $(kubectl get nodes -l module=common --no-headers | cut -d " " -f1); do 
    kubectl get pods --all-namespaces  --no-headers --field-selector spec.nodeName=${n} 
done
```
Refer to [Answers](https://stackoverflow.com/questions/39231880/kubernetes-api-gets-pods-on-specific-nodes)
