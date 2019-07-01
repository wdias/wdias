The Horizontal Pod Autoscaler is implemented as a control loop, with a period controlled by the controller manager’s --horizontal-pod-autoscaler-sync-period flag (with a default value of 15 seconds)
- `https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#how-does-the-horizontal-pod-autoscaler-work`
Not able change flag `horizontal-pod-autoscaler-sync-period` this on GKE, EKS and other managed clusters.
- `https://stackoverflow.com/questions/54525009/change-the-horizontal-pod-autoscaler-sync-period-in-eks`

