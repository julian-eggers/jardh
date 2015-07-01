#!/bin/bash

mkdir apps_deployable
mkdir apps_running
mkdir backups
mkdir data
mkdir logs
mkdir scripts

wget https://raw.githubusercontent.com/julian-eggers/jardh/master/management.sh
mv management.sh scripts/