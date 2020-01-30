# Developer Guide

## Helm 3
After upgrading to the Helm 3 (from Helm 2), there are lots of breaking changes. In Helm 3, it need to add helm chart repositories, and it's possible to host own helm charts.
In order to use existing Helm charts that used for Helm to [need to add following](https://stackoverflow.com/a/57970816/1461060);
`helm repo add stable https://kubernetes-charts.storage.googleapis.com/`

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

## Helpers
- Helm delete all the charts match given keyword (e.g. delete all `adapter`)
`helm ls | grep 'adapter' | awk '{print $1}' | xargs -o -I {} helm delete --purge {}`
- Attach to running container/pod
`kubectl get pods | grep 'grid' | awk '{print $1}' | xargs -o -I {} kubectl exec -it {} -- /bin/bash`
- Delete `MatchNodeSelector` pods on Docker for Mac
`kubectl get pods --all-namespaces | grep 'MatchNodeSelector' | awk {'print $2'} | xargs -o -I {} kubectl delete -n docker pod {}`
- Disable requested resources and limits
```sh
bash ./scripts/helpers.sh resource_request ~/wdias/wdias-helm-charts 0
bash ./scripts/helpers.sh resource_request ~/wdias/wdias-helm-charts 0 values
bash ./scripts/helpers.sh resource_limit ~/wdias/wdias-helm-charts 0
bash ./scripts/helpers.sh resource_limit ~/wdias/wdias-helm-charts 0 values
```
- Enable requested resources and limits
```sh
bash ./scripts/helpers.sh resource_request ~/wdias/wdias-helm-charts 1
bash ./scripts/helpers.sh resource_request ~/wdias/wdias-helm-charts 1 values
bash ./scripts/helpers.sh resource_limit ~/wdias/wdias-helm-charts 1
bash ./scripts/helpers.sh resource_limit ~/wdias/wdias-helm-charts 1 values
```
- Remove all the databases
`<./groups/databases.txt | xargs  -n1  -I {} helm uninstall {}`
- Remove all the Helm Charts
`find ./groups -name '*.txt' | xargs -o -I {} cat {} | xargs  -n1 -o -I {} helm uninstall {}`
- Remove all the Helm Charts exept Databases
`cat docs/repos.txt | xargs  -n1  -I {} helm uninstall {}`
- Change the domain
`egrep -lir 'wdias.com' . | grep '.yaml' | xargs -o -I {} sed -i '' 's/wdias.com/mydomain.com/g' {}` # Ubuntu: without ''
- Enable or Disable resources limits defined
`wdias/scripts/helpers.sh resource_request ~/wdias/wdias-helm-charts 0`
- Run a command in regualr interval
`watch -n5 -x kubectl top pods`
- Delete all evicted pods manually after an incident
`kubectl get pods --all-namespaces -o json | jq '.items[] | select(.status.reason!=null) | select(.status.reason | contains("Evicted")) | "kubectl delete pods \(.metadata.name) -n \(.metadata.namespace)"' | xargs -n 1 bash -c`

## Setup Dev
```sh
bash ~/wdias/wdias/scripts/db_setup.sh ~/wdias
cd ~/wdias/wdias-mysql-schema && bash ~/wdias/wdias-mysql-schema/scripts/install_database.sh adapter-metadata-mysql metadata wdias
cd ~/wdias/wdias-mysql-schema && bash ~/wdias/wdias-mysql-schema/scripts/install_database.sh adapter-extension-mysql extension wdias
bash ~/wdias/wdias/scripts/helm_install.sh ~/wdias 1
helm install metrics-server --namespace=kube-system stable/metrics-server -f ~/wdias/wdias-helm-charts/metrics-server/values.yaml
```
Just Grid
```sh
bash ~/wdias/wdias/scripts/db_setup.sh ~/wdias adapter-metadata-mysql adapter-redis adapter-query-mongodb
cd ~/wdias/wdias-mysql-schema && bash ~/wdias/wdias-mysql-schema/scripts/install_database.sh adapter-metadata-mysql metadata wdias
bash ~/wdias/wdias/scripts/helm_install.sh ~/wdias 1
helm install metrics-server --namespace=kube-system stable/metrics-server -f ~/wdias/wdias-helm-charts/metrics-server/values.yaml
```
## Setup Prod
```sh
bash ~/wdias/wdias/scripts/db_setup.sh ~/wdias && sleep 10 && \
cd ~/wdias/wdias-mysql-schema && bash ~/wdias/wdias-mysql-schema/scripts/install_database.sh adapter-metadata-mysql metadata wdias && \
cd ~/wdias/wdias-mysql-schema && bash ~/wdias/wdias-mysql-schema/scripts/install_database.sh adapter-extension-mysql extension wdias && \
bash ~/wdias/wdias/scripts/helm_install.sh ~/wdias
wdias helm_install ~/wdias/wdias-performance-test/helm/wdias-performance-test
helm install metrics-server --namespace=kube-system stable/metrics-server -f ~/wdias/wdias-helm-charts/metrics-server/values.yaml
wdias helm_install ~/wdias/wdias-data-collector/helm/wdias-data-collector
```