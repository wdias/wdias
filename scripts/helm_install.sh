# !/bin/bash
DIR=$(pwd)
CMD=~/wdias/wdias/bin/macos/dev
SLEEP_TIME=5

deploy_app() {
  echo "Deploy Helm for $(basename ${PWD}) >>>"
  nohup $CMD up &
  echo "Waiting for $SLEEP_TIME ..."
  sleep $SLEEP_TIME
}

# Adapter-Extension
cd ~/wdias/adapter-extension && $CMD build && cd ~/wdias/wdias-helm-charts/adapter-extension && deploy_app
# cd ~/wdias/adapter-extension && wdias build && cd ~/wdias/wdias-helm-charts/adapter-extension && wdias up
# Adapter-Metadata
cd ~/wdias/adapter-metadata && $CMD build && cd ~/wdias/wdias-helm-charts/adapter-metadata && deploy_app
# cd ~/wdias/adapter-metadata && wdias build && cd ~/wdias/wdias-helm-charts/adapter-metadata && wdias up
# Adapter-Scalar
cd ~/wdias/adapter-scalar && $CMD build && cd ~/wdias/wdias-helm-charts/adapter-scalar && deploy_app
# cd ~/wdias/adapter-scalar && wdias build && cd ~/wdias/wdias-helm-charts/adapter-scalar && wdias up
# Extension-Handler
cd ~/wdias/extension-handler && $CMD build && cd ~/wdias/wdias-helm-charts/extension-handler && deploy_app
# cd ~/wdias/extension-handler && wdias build && cd ~/wdias/wdias-helm-charts/extension-handler && wdias up

# Import
cd ~/wdias/import-json-raw && $CMD build && cd ~/wdias/wdias-helm-charts/import-json-raw && deploy_app
# cd ~/wdias/import-json-raw && wdias build && cd ~/wdias/wdias-helm-charts/import-json-raw && wdias up

# Export
cd ~/wdias/export-json-raw && $CMD build && cd ~/wdias/wdias-helm-charts/export-json-raw && deploy_app
# cd ~/wdias/export-json-raw && wdias build && cd ~/wdias/wdias-helm-charts/export-json-raw && wdias up

# Extension-Transformation
cd ~/wdias/extension-transformation && $CMD build && cd ~/wdias/wdias-helm-charts/extension-transformation && deploy_app
# cd ~/wdias/extension-transformation && wdias build && cd ~/wdias/wdias-helm-charts/extension-transformation && wdias up
# -> Transformation-Aggregate_Accumulative
cd ~/wdias/transformation-aggregate-accumulative && $CMD build && cd ~/wdias/wdias-helm-charts/transformation/transformation-aggregate-accumulative && deploy_app
# cd ~/wdias/transformation-aggregate-accumulativwdias $CMD build && cd ~/wdias/wdias-helm-charts/transformation/transformation-aggregate-accumulative && wdias up

# Extension-Interpolation
cd ~/wdias/extension-interpolation && $CMD build && cd ~/wdias/wdias-helm-charts/extension-interpolation && deploy_app
# cd ~/wdias/extension-interpolation && wdias build && cd ~/wdias/wdias-helm-charts/extension-interpolation && wdias up

# Extension-Validation
cd ~/wdias/extension-validation && $CMD build && cd ~/wdias/wdias-helm-charts/extension-validation && deploy_app
# cd ~/wdias/extension-validation && wdias build && cd ~/wdias/wdias-helm-charts/extension-validation && wdias up


## Install Databases
cd ~/wdias/wdias-helm-charts/adapter-extension-mysql && helm install --name adapter-extension-mysql -f values.yaml stable/mysql
# kubectl port-forward svc/adapter-extension-mysql 3306
cd ~/wdias/wdias-helm-charts/adapter-metadata-mysql && helm install --name adapter-metadata-mysql -f values.yaml stable/mysql
# kubectl port-forward svc/adapter-metadata-mysql 3306
cd ~/wdias/wdias-helm-charts/adapter-scalar-influxdb && helm install --name adapter-scalar-influxdb -f values.yaml stable/influxdb
# kubectl exec -i -t --namespace default $(kubectl get pods --namespace default -l app=adapter-scalar-influxdb -o jsonpath='{.items[0].metadata.name}') /bin/sh

cd $DIR
