# Developer Guide

## Tailing Logs of containers
Get the list of running pods with `kubectl get pods`.
```
NAME                                READY   STATUS        RESTARTS   AGE
adapter-metadata-789c7687d9-7kvbg   0/1     Terminating   3          1m
adapter-metadata-789c7687d9-7ptmz   1/1     Running       0          6s
import-json-raw-7789f66465-5xxj6    1/1     Running       1          14h
```
Then look into the logs with `kubectl logs -f adapter-metadata-789c7687d9-7ptmz`

Or tailing logs can be done with some existing adavanced tools also.
1. Bash script to tail Kubernetes logs from multiple pods at the same time - https://github.com/johanhaleby/kubetail
2. Multi pod and container log tailing for Kubernetes - https://github.com/wercker/stern

- List running pods, resource utilization: `kubectl get po --all-namespaces -o=jsonpath="{range .items[*]}{.metadata.namespace}:{.metadata.name}{'\n'}{range .spec.containers[*]}  {.name}:{.resources.requests.cpu}{'\n'}{end}{'\n'}{end}"`

- Delete Persistant volume before deleting MySQL pods
  `https://github.com/kubernetes/kubernetes/issues/69697#issuecomment-448541618`
  ```
  kubectl get pvc
  kubectl patch pvc db-pv-claim -p '{"metadata":{"finalizers":null}}'
  ```
  