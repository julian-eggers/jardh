#!/bin/bash

function startApp {
        echo "Starting app... $RUNNING_JAR"

        if [ ! -f $RUNNING_JAR ]; then
                echo "$RUNNING_JAR not found"
                exit 1;
        fi

        nohup java -jar $JVM_PARAMETERS $RUNNING_JAR > $CONSOLE_LOG_FILE &
        echo "App started"
}

function stopApp {
        echo "Stopping app..."
        $APP_SHUTDOWN_COMMAND
        sleep 10
        $APP_KILL_COMMAND
        echo "App stopped"
}

function appStatus {
        $APPLICATION_SERVER_STATUS
}

function clearBackupFolder {
        find $JAR_BACKUP_FOLDER -type f -not -name "latest.jar" -ctime +3 | xargs rm -rf
        echo "Backup-Folder cleared"
}

function deploy {
        echo "Start deployment"

        if [ ! -f $1 ]; then
                echo "$1 not found"
                echo "Deployment aborted"
                exit 1;
        fi

        stopApp

        if [ ! -d $JAR_BACKUP_FOLDER ]; then
                mkdir -p $JAR_BACKUP_FOLDER
                echo "Backup-folder created"
        fi

        if [ -f $RUNNING_JAR ]; then
                cp $RUNNING_JAR "$JAR_BACKUP_FOLDER$(date +"%Y-%m-%d-%H:%M").jar"
                cp $RUNNING_JAR "${JAR_BACKUP_FOLDER}latest.jar"
                echo "Old jar saved"
        fi

        rm -r ${RUNNING_JAR/.jar/*}
        echo "Current jar removed"

        mv $1 $RUNNING_JAR
        echo "New jar moved"

        startApp
        echo "Deployment finished"
}

function rollback {
        if [ ! -f "${JAR_BACKUP_FOLDER}latest.jar" ]; then
                echo "latest.jar not found"
                echo "Rollback aborted"
                exit 1;
        fi

        deploy "${JAR_BACKUP_FOLDER}latest.jar"
        echo "Rollback finished"
}

case "$1" in
	startApp)
		startApp
	;;

	stopApp)
		stopApp
	;;

	restartApp)
		stopApp
		startApp
	;;

	status)
		appStatus
	;;

  deploy)
		if [ ! -z $2 ]; then
			deploy $2
		else
			deploy $DEPLOYABLE_JAR
		fi

		clearBackupFolder
	;;

	rollback)
		rollback
	;;

	*)
		echo "Usage:"
		echo "	*.sh startApp"
		echo "	*.sh stopApp"
		echo "	*.sh restartApp"
		echo "	*.sh status"
		echo "	*.sh deploy"
		echo "	*.sh deploy any.jar"
		echo "	*.sh rollback"
	;;
esac
