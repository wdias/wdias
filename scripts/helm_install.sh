# !/bin/bash

# ./scripts/helm_install.sh <ROOT_DIR> <DEV_MODE=1>
# E.g. ./scripts/helm_install.sh ~/wdias 1

DIR=$(pwd)
ROOT_DIR=${1-$DIR}
echo "Set ROOT_DIR=$ROOT_DIR"
echo "Make sure wdias and wdias-helm-charts avaiable within $ROOT_DIR"
DEV=${2-0}
echo "Dev mode: $DEV"
CMD="$ROOT_DIR/wdias/bin/macos/dev"
SLEEP_TIME=5

build_app() {
  if [ "$DEV" != "1" ]; then
    return 0
  fi
  APP_PATH="$ROOT_DIR/$1"
  cd $APP_PATH
  echo "Building Docker Image $(basename ${PWD}) >>>"
  $CMD build
}

deploy_app() {
  APP_PATH="$ROOT_DIR/wdias-helm-charts/$1"
  cd $APP_PATH
  echo "Deploy Helm for $(basename ${PWD}) >>>"
  nohup $CMD up &
  echo "Waiting for $SLEEP_TIME ..."
  sleep $SLEEP_TIME
}

install_db() {
  APP_PATH="$ROOT_DIR/wdias-helm-charts/$1"
  cd $APP_PATH
  echo "Install Database Helm for $(basename ${PWD}) >>>"
  helm install --name $1 -f values.yaml stable/$2
}

# Adapter-Extension
build_app adapter-extension && deploy_app adapter-extension
# cd ~/wdias/adapter-extension && wdias build && cd ~/wdias/wdias-helm-charts/adapter-extension && wdias up
# Adapter-Metadata
build_app adapter-metadata && deploy_app adapter-metadata
# cd ~/wdias/adapter-metadata && wdias build && cd ~/wdias/wdias-helm-charts/adapter-metadata && wdias up
# Adapter-Scalar
build_app adapter-scalar && deploy_app adapter-scalar
# cd ~/wdias/adapter-scalar && wdias build && cd ~/wdias/wdias-helm-charts/adapter-scalar && wdias up
# Extension-Handler
build_app extension-handler && deploy_app extension-handler
# cd ~/wdias/extension-handler && wdias build && cd ~/wdias/wdias-helm-charts/extension-handler && wdias up

# Import
build_app import-json-raw && deploy_app import-json-raw
# cd ~/wdias/import-json-raw && wdias build && cd ~/wdias/wdias-helm-charts/import-json-raw && wdias up

# Export
build_app export-json-raw && deploy_app export-json-raw
# cd ~/wdias/export-json-raw && wdias build && cd ~/wdias/wdias-helm-charts/export-json-raw && wdias up

# Extension-Transformation
build_app extension-transformation && deploy_app extension-transformation
# cd ~/wdias/extension-transformation && wdias build && cd ~/wdias/wdias-helm-charts/extension-transformation && wdias up
# -> Transformation-Aggregate_Accumulative
build_app transformation-aggregate-accumulative && deploy_app transformation/transformation-aggregate-accumulative
# cd ~/wdias/transformation-aggregate-accumulativwdias wdias build && cd ~/wdias/wdias-helm-charts/transformation/transformation-aggregate-accumulative && wdias up

# Extension-Interpolation
build_app extension-interpolation && deploy_app extension-interpolation
# cd ~/wdias/extension-interpolation && wdias build && cd ~/wdias/wdias-helm-charts/extension-interpolation && wdias up

# Extension-Validation
build_app extension-validation && deploy_app extension-validation
# cd ~/wdias/extension-validation && wdias build && cd ~/wdias/wdias-helm-charts/extension-validation && wdias up


## Install Databases
install_db adapter-extension-mysql mysql
# cd ~/wdias/wdias-helm-charts/adapter-extension-mysql && helm install --name adapter-extension-mysql -f values.yaml stable/mysql
# kubectl port-forward svc/adapter-extension-mysql 3306
install_db adapter-metadata-mysql mysql
# cd ~/wdias/wdias-helm-charts/adapter-metadata-mysql && helm install --name adapter-metadata-mysql -f values.yaml stable/mysql
# kubectl port-forward svc/adapter-metadata-mysql 3306
install_db adapter-redis redis
# cd ~/wdias/wdias-helm-charts/adapter-redis && helm install --name adapter-redis -f values.yaml stable/redis
install_db adapter-scalar-influxdb influxdb
# cd ~/wdias/wdias-helm-charts/adapter-scalar-influxdb && helm install --name adapter-scalar-influxdb -f values.yaml stable/influxdb
# kubectl exec -i -t --namespace default $(kubectl get pods --namespace default -l app=adapter-scalar-influxdb -o jsonpath='{.items[0].metadata.name}') /bin/sh

cd $DIR
