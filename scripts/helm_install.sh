# !/bin/bash

# ./scripts/helm_install.sh <ROOT_DIR> <DEV_MODE=1> <CHART_TO_INSTALL...>
# E.g. ./scripts/helm_install.sh ~/wdias 1
# E.g. ./scripts/helm_install.sh ~/wdias 0 transformation/transformation-aggregate-accumulative

DIR=$(pwd)
ROOT_DIR=${1-$DIR}
shift
DEV_MODE=${1-0}
shift
CHARTS=$@

echo "Set ROOT_DIR=$ROOT_DIR"
echo "Make sure wdias and wdias-helm-charts avaiable within $ROOT_DIR"
echo "Dev mode: ${DEV_MODE}"
CMD="$ROOT_DIR/wdias/bin/macos/dev"
SLEEP_TIME=1

build_app() {
  if [ "${DEV_MODE}" != "1" ]; then
    return 0
  fi
  APP_PATH="$ROOT_DIR/$1"
  echo "Building Docker Image $(basename ${APP_PATH}) >>>"
  $CMD build ${APP_PATH}
}

deploy_app() {
  APP_PATH="$ROOT_DIR/wdias-helm-charts/$1"
  echo "Deploy Helm for $(basename ${PWD}) >>>"
  if [ "${DEV_MODE}" == "1" ]; then
    export DEV=true # Install helm with using the docker image build locally
  fi
  echo "${CMD} helm_delete ${APP_PATH}"
  ${CMD} helm_delete ${APP_PATH} || true
  echo "$CMD helm_install ${APP_PATH}"
  $CMD helm_install ${APP_PATH}
  echo "Waiting for $SLEEP_TIME ..."
  sleep $SLEEP_TIME
}

if [ "${CHARTS}" != "" ]; then
    for var in "$@"
    do
      chart_name=$(echo ${var} | awk '{split($0,a,"/"); print a[length(a)]}')
      build_app ${chart_name} && deploy_app ${var}
    done
    exit 0
fi

# Adapter Core
deploy_app wdias-init
build_app adapter-metadata && deploy_app adapter-metadata
build_app adapter-query && deploy_app adapter-query
build_app adapter-status && deploy_app adapter-status
# Adapter: Scalar, Vector, Grid
build_app adapter-scalar && deploy_app adapter-scalar
build_app adapter-vector && deploy_app adapter-vector
build_app adapter-grid && deploy_app adapter-grid
# Adapter Extension
build_app adapter-extension && deploy_app adapter-extension
build_app extension-handler && deploy_app extension-handler
build_app extension-scheduler && deploy_app extension-scheduler

# Import
build_app import-json-raw && deploy_app import-json-raw
build_app import-ascii-grid-binary && deploy_app import-ascii-grid-binary
build_app import-ascii-grid-upload && deploy_app import-ascii-grid-upload

# Export
build_app export-json-raw && deploy_app export-json-raw
build_app export-netcdf-binary && deploy_app export-netcdf-binary

# Extension-Transformation
build_app extension-transformation && deploy_app extension-transformation
build_app transformation-aggregate-accumulative && deploy_app transformation/transformation-aggregate-accumulative

# Extension-Interpolation
build_app extension-interpolation && deploy_app extension-interpolation
build_app interpolation-serial-linear && deploy_app interpolation/interpolation-serial-linear

# Extension-Validation
build_app extension-validation && deploy_app extension-validation
build_app validation-min-non-missing-values-check && deploy_app validation/validation-min-non-missing-values-check


cd $DIR
