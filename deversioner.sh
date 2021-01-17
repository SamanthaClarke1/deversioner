ROOTPATH=/Volumes/RS01/Projects/AnimalLogic
MAXVERS=2
SAFE=false
GLBL=false
COUNT=true
BYTES=0

if [ "$1" == "--path" ]; then
	ROOTPATH=$2
elif [ "$1" == "--vers" ]; then
	MAXVERS=$2
fi

if [ "$3" == "--path" ]; then
	ROOTPATH=$4
elif [ "$3" == "--vers" ]; then
	MAXVERS=$4
fi

if [ "$1" == "--glbl" ] || [ "$2" == "--glbl" ] || [ "$3" == "--glbl" ] || [ "$4" == "--glbl" ] || [ "$5" == "--glbl" ] || [ "$6" == "--glbl" ] || [ "$7" == "--glbl" ] || [ "$8" == "--glbl" ]; then
	GLBL=true
fi
if [ "$1" == "--safe" ] || [ "$2" == "--safe" ] || [ "$3" == "--safe" ] || [ "$4" == "--safe" ] || [ "$5" == "--safe" ] || [ "$6" == "--safe" ] || [ "$7" == "--safe" ] || [ "$8" == "--safe" ]; then
	SAFE=true
fi
if [ "$1" == "--count" ] || [ "$2" == "--count" ] || [ "$3" == "--count" ] || [ "$4" == "--count" ] || [ "$5" == "--count" ] || [ "$6" == "--count" ] || [ "$7" == "--count" ] || [ "$8" == "--count" ]; then
	COUNT=true
	SAFE=true
fi
if [ "$1" == "--help" ] || [ "$2" == "--help" ] || [ "$3" == "--help" ] || [ "$4" == "--help" ] || [ "$5" == "--help" ] || [ "$6" == "--help" ] || [ "$7" == "--help" ] || [ "$8" == "--help" ]; then
	printf "\e[1m\e[34mThis is Sam's De-Versioner. It will delete everything but the last $MAXVERS versions of a script.\n\n"
	printf "\e[39m\e[1mSettings:\n\e[0m \e[32m\e[1m--path {path}\n\t\t\e[39m\e[0mSets the RootPath\n \e[32m\e[1m--vers {vers}\n\t\t\e[39m\e[0mSets the MaxVers\n \e[32m\e[1m--glbl\n\t\t\e[39m\e[0mDoes \e[1mall\e[0m folders, not just the whitelisted ones. \e[1m\e[33m(Please exercise caution whilst using this).\e[0m\n \e[32m\e[1m--safe\n\t\t\e[39m\e[0mDoesn't delete folders, but it does make a log file.\n\e[32m \e[1m--count \n\t\t\e[39m\e[0mTells the script to count and log the size of files, instead of deleting them.\n \e[1m\e[32m--help\n\t\t\e[0m\e[39mDisplays this message.\n\n \e[1mPS: if you specify a path or a version, please put them before anything else.\n\e[0m"
else

	echo "RootPath=$ROOTPATH MaxVers=$MAXVERS Safe=$SAFE Glbl=$GLBL COUNT=$COUNT"
	if [ $SAFE == false ]; then
		echo -e "\e[33m\e[4mThis Script will delete files, as it is not in safe mode.\e[0m"
	fi
	if [ $GLBL == true  ]; then
		echo -e "\e[33m\e[4mThis Script will look at all directories, not just the whitelisted ones, as you've specified global.\e[0m"
	fi
	echo "Are these settings right? Press Ctrl+C to cancel..."
	echo 5; sleep 1; echo 4; sleep 1; echo 3; sleep 1; echo 2; sleep 1; echo 1; sleep 1;
	echo "Starting..."

	DATEE=$(date '+%Y-%m-%d_%H:%M:%S')
	printf "!i!i!i!i!i!i!i!i!i!i!i!i!i!i!i!i!i!i!i!i!\nDeversioner run at $DATEE\n!i!i!i!i!i!i!i!i!i!i!i!i!i!i!i!i!i!i!i!i!\n\nSETTINGS: RootPath=$ROOTPATH MaxVers=$MAXVERS Safe=$SAFE Glbl=$GLBL\n\n" | cat >> "$DATEE.log"
	trap "echo -e \"\e[31m\e[1mExiting, canceled by ctrl+c.\e[0m\";printf \"\n\nExiting early, canceled via ctrl+c\n\n\" | cat >> \"$DATEE.log\";exit 1" INT

	for_each_folder() {
		for D in $1/*; do
			if [ -d "${D}" ]; then
				if [ -d "${D}/WIP/2d/comp" ]; then
					echo "entering WIP/2d/comp $D"
					printf "Entering /WIP/2d/comp/ " | cat >> "$DATEE.log"
					a=$D
					clean_folder "${D}/WIP/2d/comp"
					D=$a
				fi
				if [ -d "${D}/publish/2d/comp" ]; then
					echo "entering publish/2d/comp"
					printf "Entering /publish/2d/comp/ " | cat >> "$DATEE.log"
					a=$D
					clean_folder "${D}/publish/2d/comp"
					D=$a
				fi
				if [ -d "${D}/WIP/3d/light" ]; then
					echo "entering WIP/3d/light"
					printf "Entering /WIP/3d/light/ " | cat >> "$DATEE.log"
					a=$D
					clean_folder "${D}/WIP/3d/light"
					D=$a
				fi
				if [ ! -d "${D}/WIP/2d/comp" ] && [ ! -d "${D}/publish/2d/comp" ] && [ ! -d "${D}/WIP/3d/light" ]; then
					for_each_folder ${D}
				fi
			fi
		done
	}

	clean_folder() {
		vers=$(find $1 -maxdepth 1 -mindepth 1 -regextype posix-egrep -regex ".*v[0-9]{3}")
		i=1
		safevers=0
		printf "\e[0m\tVersions found:  $(echo ${vers} | tr ' ' '\n' | wc -l)\n"
		printf "\tVersions found:  $(echo ${vers} | tr ' ' '\n' | wc -l)\n" | cat >> "$DATEE.log"
		while [ $(($(echo ${vers} | tr ' ' '\n' | wc -l)-$safevers)) -gt $MAXVERS ]; do	
			ni=0				
			printf -v ni "%03d" $i
			tmpd=$(find $1/ -maxdepth 1 -mindepth 1 -name "*v${ni}*")
			chars=$(find $1/ -maxdepth 1 -mindepth 1 -name "*v${ni}*" | wc -c)
			if [ $COUNT == true ] && [ $chars -gt 2 ]; then
				TTMPD=(${tmpd[@]})
				TBYTES=$(stat --printf="%s" ${TTMPD[0]})
				echo "B: $TBYTES"
				BYTES=$((BYTES+TBYTES))
			fi
			if [ $SAFE == true ]; then
				if [ $chars -gt 2 ]; then
					echo -e "\e[33m (would be) removing $1/*v${ni}*\e[31m , Freeing $TBYTES of data."
					echo "(would've) removed $1/*v${ni}* , Freeing $TBYTES of data." | cat >> "$DATEE.log"
				fi
			else
				echo -e "\e[33m REMOVING $1/*v${ni}*\e[31m"
				echo "REMOVED $1/*v${ni}*" | cat >> "$DATEE.log"
			fi
			if [ $SAFE == false ]; then
				find $1/ -maxdepth 1 -mindepth 1 -name "*v${ni}*" -exec rm -r {} +
			else
				if [ $chars -gt 2 ]; then
					safevers=$(($safevers+1))
				fi
			fi
			i=$((i+1))
			vers=$(find $1/ -maxdepth 1 -mindepth 1 -regextype posix-egrep -regex ".*v[0-9]{3}")
			if [ $chars -gt 2 ] || [ $SAFE == false ]; then
				echo -e " \e[0m   i!i! "$(($(echo $vers | tr ' ' '\n' | wc -l)-$safevers))" versions left i!i!"
			fi
		done

		for D in $1/*; do
			if [ -d "${D}" ]; then
				if [ $(ls ${D}/ | wc -l) -gt 0 ]; then
					clean_folder ${D}
				fi
			fi
		done
		
		return
	}

	for_each_folder $ROOTPATH

	echo -e "\e[32mFinished.\e[0m"

	if [ $COUNT == false ]; then
		printf "\n\nFinished.\n\n" |  cat >> "$DATEE.log"
	else
		printf "\n\nFinished.\nWould've freed $BYTES B of data.\n\n" |  cat >> "$DATEE.log"
	fi

fi
