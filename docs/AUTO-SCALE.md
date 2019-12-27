The Horizontal Pod Autoscaler is implemented as a control loop, with a period controlled by the controller manager’s --horizontal-pod-autoscaler-sync-period flag (with a default value of 15 seconds)
- `https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#how-does-the-horizontal-pod-autoscaler-work`
Not able change flag `horizontal-pod-autoscaler-sync-period` this on GKE, EKS and other managed clusters.
- `https://stackoverflow.com/questions/54525009/change-the-horizontal-pod-autoscaler-sync-period-in-eks`

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
