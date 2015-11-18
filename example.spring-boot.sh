#!/bin/bash

AUTO_UPDATE_ENABLED="1"

JVM_PARAMETERS="-Djava.awt.headless=true"
CONSOLE_LOG_FILE="/root/logs/app.output.log"

APP_PID="`wget -qO- --header='Accept: text/html' http://localhost:17801/env/PID`"
APP_SHUTDOWN_COMMAND="curl -X POST --connect-timeout 10 http://localhost:17801/shutdown"
APP_SHUTDOWN_TIMEOUT=10

JAR_BACKUP_FOLDER="/root/backups/jars/app/"
RUNNING_JAR="/root/apps_running/app.jar"
DEPLOYABLE_JAR="/root/apps_deployable/app.jar"


source $(dirname $(readlink -f $0))/management.sh
