#!/bin/bash

## management.sh
# Version: 0.3.1.RELEASE
##

function scriptUpdate {
        wget "https://raw.github.com/julian-eggers/jardh/master/management.sh" -O "management_new_version.sh" -nv

	if grep -q "Version" "management_new_version.sh";
	then
	        diff -q "management.sh" "management_new_version.sh" 1>/dev/null
	        if [ $? == "0" ]; then
	                echo "No update required"
	                rm "management_new_version.sh"
	        else
	                echo "Update required"
	                rm "management.sh"
	                mv "management_new_version.sh" "management.sh"
	                chmod +x "management.sh"
	                echo "Update succesful > restart script"
	                source $(dirname $(readlink -f $0))/management.sh
	                exit 1;
	        fi
	else
		echo "File-content not verified > update aborted"
		rm "management_new_version.sh"
	fi
}

function startApp {
        echo "Starting app... $RUNNING_JAR"

        if [ ! -f $RUNNING_JAR ]; then
                echo "$RUNNING_JAR not found"
                exit 1;
        fi

        nohup java -jar $JVM_PARAMETERS $RUNNING_JAR $APPLICATION_PARAMETERS > $CONSOLE_LOG_FILE 2>&1 &
        echo "App started"
}

function stopApp {
        echo "Stopping app..."

        if [ ! -f $RUNNING_JAR ]; then
                echo "$RUNNING_JAR is not running"
                return 1;
        fi

        PID=$(getPid)

        if [ ! -f /proc/$PID/exe ]; then
                echo "PID $PID not found"
                return 1;
        fi

        echo "Executing shutdown-command..."
        $APP_SHUTDOWN_COMMAND
        echo ""
        echo "Shutdown-command executed...Waiting $APP_SHUTDOWN_TIMEOUT seconds..."
        sleep $APP_SHUTDOWN_TIMEOUT

        if [ -f /proc/$PID/exe ]; then
                echo "Shutdown failed...Try to kill app..."
		kill -9 $PID
		rm $APP_PID_FILE 2> /dev/null
                echo "Kill-command executed"
        fi

        if [ ! -f /proc/$PID/exe ]; then
                echo "App successful stopped"
        else
                echo "FAILED TO STOP APP (PID: $PID)!"
        fi
}

function getPid {
	if [[ $APP_PID ]]; then
		echo $APP_PID
	elif [[  $APP_PID_FILE ]]; then
		if [ -f $APP_PID_FILE ]; then
			echo $(cat "$APP_PID_FILE")
		else
			echo "PIDFILE_NOT_FOUND"
		fi
	else
		echo "PID_NOT_FOUND"
	fi
}

function appStatus {
	echo "PID: $(getPid)"
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

	if [ -f $RUNNING_JAR ]; then
                rm -r ${RUNNING_JAR/.jar/*}
                echo "Current jar removed"
        fi

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


if [ "$AUTO_UPDATE_ENABLED" = "1" ]; then
        scriptUpdate
fi

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

	scriptUpdate)
		scriptUpdate
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
		echo "	*.sh scriptUpdate"
	;;
esac
