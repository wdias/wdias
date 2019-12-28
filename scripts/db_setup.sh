# !/bin/bash

# ./scripts/db_setup.sh <ROOT_DIR> <DB_TO_INSTALL...>
# E.g. ./scripts/db_setup.sh ~/wdias adapter-extension-mysql adapter-redis

DIR=$(pwd)
ROOT_DIR=${1-$DIR}
shift
DBS=$@
echo "Set ROOT_DIR=$ROOT_DIR"
echo "Make sure wdias and wdias-helm-charts avaiable within $ROOT_DIR"
CMD="$ROOT_DIR/wdias/bin/macos/dev"
SLEEP_TIME=1

is_helm_exists() {
    # https://stackoverflow.com/a/47794267
    helm ls | grep "$1" | awk '{print $1}'
}

install_db() {
    HELM_CHART=$(is_helm_exists $1)
    if [ "$HELM_CHART" != "$1" ]; then
        APP_PATH="$ROOT_DIR/wdias-helm-charts/$1"
        cd $APP_PATH
        echo "Install Database Helm for $(basename ${PWD}) >>>"
        echo "helm install $1 stable/$2 -f values.yaml"
        helm install $1 stable/$2 -f values.yaml
        sleep $SLEEP_TIME
    else
        echo "$1 already exists. Run 'helm delete --purge $1' to delete."
    fi
}

if [ "$DBS" != "" ]; then
    for var in "$@"
    do
        db_name=$(echo $var | awk '{split($0,a,"-"); print a[length(a)]}')
        install_db $var $db_name
    done
    exit 0
fi

## Install Databases
install_db adapter-extension-mysql mysql
# cd ~/wdias/wdias-helm-charts/adapter-extension-mysql && helm install --name adapter-extension-mysql -f values.yaml stable/mysql
# kubectl port-forward svc/adapter-extension-mysql 3306
install_db adapter-metadata-mysql mysql
# cd ~/wdias/wdias-helm-charts/adapter-metadata-mysql && helm install --name adapter-metadata-mysql -f values.yaml stable/mysql
# kubectl port-forward svc/adapter-metadata-mysql 3306
install_db adapter-redis redis
# cd ~/wdias/wdias-helm-charts/adapter-redis && helm install --name adapter-redis -f values.yaml stable/redis
install_db adapter-query-mongodb mongodb
# cd ~/wdias/wdias-helm-charts/adapter-query-mongodb && helm install --name adapter-query-mongodb -f values.yaml stable/mongodb
install_db adapter-scalar-influxdb influxdb
# cd ~/wdias/wdias-helm-charts/adapter-scalar-influxdb && helm install --name adapter-scalar-influxdb -f values.yaml stable/influxdb
# kubectl exec -i -t --namespace default $(kubectl get pods --namespace default -l app=adapter-scalar-influxdb -o jsonpath='{.items[0].metadata.name}') /bin/sh
install_db adapter-vector-influxdb influxdb
# cd ~/wdias/wdias-helm-charts/adapter-vector-influxdb && helm install --name adapter-vector-influxdb -f values.yaml stable/influxdb
# kubectl exec -i -t --namespace default $(kubectl get pods --namespace default -l app=adapter-vector-influxdb -o jsonpath='{.items[0].metadata.name}') /bin/sh

cd $DIR