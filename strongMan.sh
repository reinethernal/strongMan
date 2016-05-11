#!/usr/bin/env bash

# File name
readonly PROGNAME=$(basename $0)
# File name, without the extension
readonly PROGBASENAME=${PROGNAME%.*}
# File directory
readonly PROGDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# Arguments
readonly ARGS="$@"
# Arguments number
readonly ARGNUM="$#"

usage() {
	echo "Run's all migrations for strongMan in one script."
	echo
	echo "Usage: $PROGNAME [install] [runserver] [migrate [-dm <y/n>]] [uninstall]"
	echo
	echo "Options:"
	echo
	echo "  -h, --help"
	echo "      This help text."
	echo
	echo "  install"
	echo "      Installs the strongMan application within it's own virtualenv."
	echo
	echo "  uninstall"
	echo "      Uninstalls the strongMan application within it's virtualenv."
	echo
	echo "  runserver"
	echo "      Run the server on localhost:8000"
	echo
	echo "  migrate"
	echo "      Installs the strongMan application within it's own virtualenv."
	echo
	echo "  -dm <y/n>, --deletemigration <y/n>"
	echo "      Make migrations"
	echo "      Flags if the current migrations and the database are going to be deleted or not."
	echo
}
while [ "$#" -gt 0 ]
do
	case "$1" in
	-h|--help)
		usage
		exit 0
		;;
	migrate)
		migrate=1
		;;
	-dm|--deletemigration)
		if [ -z $migrate ]
			then
				echo "-dm|--deletemigration needs the 'migrate' command"
				exit 1
		fi
		if [ -z $2 ]
			then
				echo "-dm|--deletemigration needs a y or n like ' -dm y'"
				exit 1
		fi
		delete_migrations="$2"
		;;
	install)
		install=1
		;;
	runserver)
		runserver=1
		;;
	uninstall)
		uninstall=1
		;;
	--)
		break
		;;
	-*)
		echo "Invalid option '$1'. Use --help to see the valid options" >&2
		exit 1
		;;
	# an option argument, continue
	*)	;;
	esac
	shift
done

if [ $migrate ]
	then
		if [ $delete_migrations ] 
			then
			#Migrate with parameter
			./migrate.sh -dm $delete_migrations
		else
			#Migrate without parameter
			./migrate.sh
		fi
		exit 1
fi

if [ $install ]
	then
		if [ -d "env" ]; then
		  echo "strongMan already installed"
		  exit 1
		fi

		echo "Install strongMan"
		echo
		read -r -p "${1:-Enter your python interpreter (python3.4 or python3.5):} " pythonInterpreter
		virtualenv -p $pythonInterpreter --no-site-packages env
		env/bin/pip install -r requirements.txt
		./migrate.sh -dm y
		echo
		echo strongMan installed!
		exit 1
		
fi

if [ $uninstall ]
	then
		if [ -d "env" ]; then
		  rm -rf env/
		  echo "strongMan virtualenv deleted."
		else
			echo "No installation found."
		  	exit 1
		fi
		exit 1
fi

if [ $runserver ]
	then
		if [ -d "env" ]; then
			echo "Run strongMan"
			echo
			./env/bin/python manage.py runserver --settings=strongMan.settings.local
		else
			echo "No installation found. Can't run server. "
			echo "Install strongMan with './strongman.sh install'"
		  	exit 1
		fi
		exit 1
fi

