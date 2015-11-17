#!/bin/bash

AUTO_UPDATE_ENABLED="1"

JVM_PARAMETERS="-Dprofile=production -Djava.awt.headless=true"
CONSOLE_LOG_FILE="/root/logs/web.output.log"

APP_PID="`wget -qO- --header='Accept: text/html' http://localhost:17801/env/PID`"
APP_SHUTDOWN_COMMAND="curl -X POST --connect-timeout 10 http://localhost:17801/shutdown"
APP_SHUTDOWN_TIMEOUT=10
APP_KILL_COMMAND="kill -9 $APP_PID"

JAR_BACKUP_FOLDER="/root/backups/jars/web/"
RUNNING_JAR="/root/apps_running/web.jar"
DEPLOYABLE_JAR="/root/apps_deployable/web.jar"


source $(dirname $(readlink -f $0))/management.sh