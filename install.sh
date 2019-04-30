#!/bin/bash
{ # this ensures the entire script is downloaded #
	clear && clear
	starttotaltime=$(date +%s)
	printf "\n Welcome to Windows Subsystem Linux Bootstrap Script\n
	Initializating script, please waiting until program configure itself.\n
	This may take a few minutes and you will be prompted for the password\n
	to elevate the user's permission.\n\n"
	sudo apt -y install jq
	PREVIOUS_PWD="${PWD}"
	if [ -d "${HOME}"/tmp ] ; then
		sudo rm -f -R "${HOME}"/tmp
	fi
	mkdir -p "${HOME}"/tmp
	cd "${HOME}"/tmp || return
	JSON_STRING=$( jq -n --arg pwd "${PREVIOUS_PWD}" '{pwd: $pwd}' )
	echo "${JSON_STRING}" >> "${HOME}"/tmp/pwd.json
	if [ "$(jq -r '.configurations.debug' "${PREVIOUS_PWD}"/bootstrap/settings.json)" == true ] ; then
		set +e
	else
		set -e
	fi
	printf "\n First time runing script? (Y/n): "
	read -r firstrun
	if [ -z "${firstrun}" ] || [ "${firstrun}" == Y ] || [ "${firstrun}" == y ] ; then
		printf "\n [ START ] Update & Upgrade\n"
		starttime=$(date +%s)
		sudo apt -qq update && sudo apt -y upgrade && sudo apt -y dist-upgrade
		endtime=$(date +%s)
		printf " [ DONE ] Update & Upgrade ... %s seconds\n" "$((endtime-starttime))"
		printf "\n [ START ] Common Requirements\n"
		starttime=$(date +%s)
		apps=(
			software-properties-common
			build-essential
			apt-transport-https
			moreutils
			curl
			unzip
			libssl-dev
			ca-certificates
		)
		sudo apt -y install "${apps[@]}"
		unset apps
		endtime=$(date +%s)
		printf " [ DONE ] Common Requirements ... %s seconds\n" "$((endtime-starttime))"
		printf "\n [ START ] Alias\n"
		starttime=$(date +%s)
		"${PREVIOUS_PWD}"/configurations/alias.sh
		wait
		endtime=$(date +%s)
		printf " [ DONE ] Alias ... %s seconds\n" "$((endtime-starttime))"
	else
		printf "\n [ START ] Fix Possible Erros\n"
		starttime=$(date +%s)
		sudo apt --fix-broken install
		sudo dpkg --configure -a
		endtime=$(date +%s)
		printf " [ DONE ] Fix Possible Erros ... %s seconds\n" "$((endtime-starttime))"
	fi
	unset firstrun
	echo " ( PRESS KEY '1' FOR EXPRESS INSTALL )"
	echo " ( PRESS KEY '2' FOR CUSTOM INSTALL )"
	printf "\n Option: "
	read -r instalationtype
	if [ "${instalationtype}" == 1 ] ; then
		printf "\n [ START ] Software Instalation List\n"
		starttime=$(date +%s)
		for row in $(jq -r '.programs[] | @base64' "${PREVIOUS_PWD}"/bootstrap/settings.json); do
			_jq() {
				echo "${row}" | base64 --decode | jq -r "${1}"
			}
			if [ "$(_jq '.installation')" == true ]; then
				echo " $(_jq '.name'): $(_jq '.installation')"
			fi
		done
		endtime=$(date +%s)
		printf " [ DONE ] Software Instalation List ... %s seconds\n" "$((endtime-starttime))"
		sleep 3
	elif [ "${instalationtype}" == 2 ] ; then
		printf "\n Your Name (Default: Matheus Rocha Vieira): "
		read -r username
		if [ -z "${username}" ] ; then
			username="Matheus Rocha Vieira"
			echo "$username"
		fi
		jq '.personal.name = "'"${username}"'"' "${PREVIOUS_PWD}"/bootstrap/settings.json | sponge "${PREVIOUS_PWD}"/bootstrap/settings.json
		unset username
		printf "\n Your E-Mail (Default: matheusrv@email.com): "
		read -r email
		if [ -z "${email}" ] ; then
			email="matheusrv@email.com"
			echo "$email"
		fi
		jq '.personal.email = "'"${email}"'"' "${PREVIOUS_PWD}"/bootstrap/settings.json | sponge "${PREVIOUS_PWD}"/bootstrap/settings.json
		unset email
		printf "\n Your GitHub Username (Default: MatheusRV): "
		read -r githubuser
		if [ -z "${githubuser}" ] ; then
			githubuser="MatheusRV"
			echo "$githubuser"
		fi
		jq '.personal.githubuser = "'"${githubuser}"'"' "${PREVIOUS_PWD}"/bootstrap/settings.json | sponge "${PREVIOUS_PWD}"/bootstrap/settings.json
		unset githubuser
		if [[ ! "$(uname -r)" =~ "Microsoft$" ]] ; then
			defaultoption="(Default for WSL: '/mnt/c/Dev')"
		else
			defaultoption="(Default for Unix-like: '~/Dev')"
		fi
		printf "\n Default Dev Folder %s: " "$defaultoption"
		read -r defaultfolder
		if [ -z "${defaultfolder}" ]; then
			if [[ ! "$(uname -r)" =~ "Microsoft$" ]] ; then
				defaultfolder=/mnt/c/Dev
			else
				defaultfolder=~/Dev
			fi
			if [ ! -d "${defaultfolder}" ] ; then
				mkdir "${defaultfolder}"
			fi
			echo "${defaultfolder}"
		else
			if [ ! -d "${defaultfolder}" ] ; then
				mkdir ${defaultfolder}
				echo "${defaultfolder}"
			fi
		fi
		jq '.personal.defaultfolder = "'"${defaultfolder}"'"' "${PREVIOUS_PWD}"/bootstrap/settings.json | sponge "${PREVIOUS_PWD}"/bootstrap/settings.json
		unset defaultfolder
		i=0
		for row in $(jq -r '.programs[] | @base64' "${PREVIOUS_PWD}"/bootstrap/settings.json); do
			_jq() {
				echo "${row}" | base64 --decode | jq -r "${1}"
			}
			programdefault=$(_jq '.default')
			if [ "$programdefault" == true ] ; then
				defaultoption="(Y/n)"
			else
				defaultoption="(y/N)"
			fi
			printf "\n Install %s %s: " "$(_jq '.name')" "$defaultoption"
			read -r programname
			if [ "$programname" == Y ] || [ "$programname" == y ] ; then
				programinstallation=true
			elif [ -z "$programname" ] ; then
				programinstallation="${programdefault}"
				echo "${programdefault}"
			else
				programinstallation=false
			fi
			jq '.programs['"${i}"'].installation = "'"${programinstallation}"'"' "${PREVIOUS_PWD}"/bootstrap/settings.json | sponge "${PREVIOUS_PWD}"/bootstrap/settings.json
			
			((i++))
		done
		unset programinstallation
		unset programdefault
		unset programname
		unset defaultoption
	else
		exit 1
	fi
	unset instalationtype
	printf "\n [ START ] Version Control\n"
	starttime=$(date +%s)
	if [ -f "${PREVIOUS_PWD}"/bootstrap/version.json ] ; then
		sudo rm -f version.json
	fi
	if ! curl https://raw.githubusercontent.com/MatheusRV/dotfiles/master/bootstrap/version.json --create-dirs -o "${PREVIOUS_PWD}"/bootstrap/version.json
	then
		echo "Download failed downloading version control! Exiting."
		exit 1
	fi
	endtime=$(date +%s)
	printf " [ DONE ] Version Control ... %s seconds\n" "$((endtime-starttime))"
	for row in $(jq -r '.programs[] | @base64' "${PREVIOUS_PWD}"/bootstrap/settings.json); do
		_jq() {
			echo "${row}" | base64 --decode | jq -r "${1}"
		}
		if [ "$(_jq '.installation')" == true ] ; then
		#TODO: To install a program depencies must be true
			programname=$(echo _jq '.name')
			printf "\n [ START ] %s\n" "$($programname)"
			starttime=$(date +%s)
			#TODO: Ensure if file exist if not download it
			#if [ -f  ] ; then
				#download file
			#fi
			"${PREVIOUS_PWD}"/programs/"$(_jq '.program')".sh || error=true
			wait
			if [ "${error}" == true ] ; then
				printf "\n ****************************\n"
				printf " [ ERROR ] %s returns a non-zero exit status\n" "$($programname)"
				printf " ****************************\n\n"
			fi
			endtime=$(date +%s)
			printf " [ DONE ] %s ... %s seconds\n" "$($programname)" "$((endtime-starttime))"
			unset error
			unset programname
		fi
	done
	printf "\n [ START ] Common Requirements\n"
	starttime=$(date +%s)
	apps=(
		htop
		tmux
		shellcheck
	)
	sudo apt -y install "${apps[@]}"
	unset apps
	endtime=$(date +%s)
	printf " [ DONE ] Common Requirements ... %s seconds\n" "$((endtime-starttime))"
	printf "\n [ START ] Cleaning\n"
	starttime=$(date +%s)
	sudo apt -y autoremove && sudo apt -y autoclean && sudo apt -y clean
	cd "${PREVIOUS_PWD}" || return
	sudo rm -R -f "${HOME}"/tmp
	endtime=$(date +%s)
	printf " [ DONE ] Cleaning ... %s seconds\n" "$((endtime-starttime))"
	endtotaltime=$(date +%s)
	printf "\n Total Time ... %s seconds\n" "$((endtotaltime-starttotaltime))"
} # this ensures the entire script is downloaded #
