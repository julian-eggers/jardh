#!/bin/bash

if [ -z ${1+x} ]; then
        echo "append path to app-environment ( setup.sh /home/exampleuser/ )"
        exit 1;
fi

cd $1

mkdir apps_deployable
mkdir apps_running
mkdir backups
mkdir data
mkdir logs
mkdir scripts

cd scripts/
wget "https://raw.github.com/julian-eggers/jardh/master/management.sh" -O "management.sh" -nv