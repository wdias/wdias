# !/bin/bash

# ./scripts/helm_install.sh <ROOT_DIR> <DEV_MODE=1>
# E.g. ./scripts/helm_install.sh ~/wdias 1

DIR=$(pwd)
ROOT_DIR=${1-$DIR}
echo "Set ROOT_DIR=$ROOT_DIR"
echo "Make sure wdias and wdias-helm-charts avaiable within $ROOT_DIR"
DEV_MODE=${2-0}
echo "Dev mode: ${DEV_MODE}"
CMD="$ROOT_DIR/wdias/bin/macos/dev"
SLEEP_TIME=1

build_app() {
  if [ "${DEV_MODE}" != "1" ]; then
    return 0
  fi
  APP_PATH="$ROOT_DIR/$1"
  echo "Building Docker Image $(basename ${PWD}) >>>"
  $CMD build ${APP_PATH}
}

deploy_app() {
  APP_PATH="$ROOT_DIR/wdias-helm-charts/$1"
  echo "Deploy Helm for $(basename ${PWD}) >>>"
  if [ "${DEV_MODE}" == "1" ]; then
    export DEV=true # Install helm with using the docker image build locally
  fi
  ${CMD} helm_delete ${APP_PATH}
  $CMD helm_install ${APP_PATH}
  echo "Waiting for $SLEEP_TIME ..."
  sleep $SLEEP_TIME
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


cd $DIR
