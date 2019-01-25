# !/bin/bash

# wup.sh <helm_chart_name>

DIR=$(pwd)
APP=$1
CMD=~/wdias/wdias/bin/macos/dev

BUILD_DIR=~/wdias/$APP
cd $BUILD_DIR
$CMD build
HELM_DIR=~/wdias/wdias-helm-charts/$APP
cd $HELM_DIR
export DEV=true # Install helm with using the docker image build locally
$CMD up
cd $DIR
