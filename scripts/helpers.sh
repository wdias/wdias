#!/bin/bash
set -e


helper_resource_request() {
    # usage: $ProgName request_resource <SEARCH_DIR> <ENABLE>
    ENABLE=${2-1}
    echo "ENABLE: ${ENABLE}"
    SEARCH="#"
    REPLACE=""
    if [ "${ENABLE}" != "1" ]; then
        SEARCH=""
        REPLACE="#"
    fi
    FILE_TYPE=${3-deployment}
    files=$(egrep -lir "${SEARCH}requests:" ${1} | grep "${FILE_TYPE}.yaml")
    for file in ${files}
    do
        line_no=$(grep -Fn "${SEARCH}requests:" ${file} | cut -f1 -d:)
        sed -i '' "${line_no}s/${SEARCH}requests:/${REPLACE}requests:/g" ${file}
        sed -i '' "$(expr $line_no + 1)s/${SEARCH}memory:/${REPLACE}memory:/g" ${file}
        sed -i '' "$(expr $line_no + 2)s/${SEARCH}cpu:/${REPLACE}cpu:/g" ${file}
    done
}

helper_resource_limit() {
    # usage: $ProgName request_limit <SEARCH_DIR> <ENABLE>
    ENABLE=${2-1}
    echo "ENABLE: ${ENABLE}"
    SEARCH="#"
    REPLACE=""
    if [ "${ENABLE}" != "1" ]; then
        SEARCH=""
        REPLACE="#"
    fi
    FILE_TYPE=${3-deployment}
    files=$(egrep -lir "${SEARCH}limits:" ${1} | grep "${FILE_TYPE}.yaml")
    for file in ${files}
    do
        line_no=$(grep -Fn "${SEARCH}limits:" ${file} | cut -f1 -d:)
        sed -i '' "${line_no}s/${SEARCH}limits:/${REPLACE}limits:/g" ${file}
        sed -i '' "$(expr $line_no + 1)s/${SEARCH}memory:/${REPLACE}memory:/g" ${file}
        sed -i '' "$(expr $line_no + 2)s/${SEARCH}cpu:/${REPLACE}cpu:/g" ${file}
    done
}

helper_help() {
  echo "
$ProgName resource_request <SEARCH_DIR> <ENABLE> <FILE_NAME.yaml|deployment.yaml>
  Disable or Enable resource request defined.
  - SEARCH_DIR: Directory need to do the search
  - ENABLE: 1 | 0 comment or uncomment them
  - FILE_NAME: File name to be search on

$ProgName resource_limit <SEARCH_DIR> <ENABLE> <FILE_NAME.yaml>
  Disable or Enable resource limit defined.
  - SEARCH_DIR: Directory need to do the search
  - ENABLE: 1 | 0 comment or uncomment them
  - FILE_NAME: File name to be search on
  "
}

helper_cmd=$1
case $helper_cmd in
  "" | "-h" | "--help")
    helper_help
    ;;
  *)
    shift
    helper_${helper_cmd} $@
    if [ $? = 127 ]; then
      echo "Error: '$helper_cmd' is not a known command." >&2
      echo "Run '$ProgName --help' for a list of known commands." >&2
      exit 1
    fi
    ;;
esac