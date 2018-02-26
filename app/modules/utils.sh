#!/bin/bash
# ------
# Utils
# ------
function logPrefix() {
    local dateFormat=$(date +"%d/%M/%Y %T")
    if [ ${FUNCNAME[1]} == 'source' ]; then
        echo ${dateFormat}
    else
        echo ${dateFormat} [${FUNCNAME[1]}]
    fi
}
