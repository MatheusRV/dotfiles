#!/bin/bash
{
    starttotaltime=$(date +%s)
    PREVIOUS_PWD="$1"
    printf "\n [ START ] Configuring System Run\n"
    starttime=$(date +%s)
    sudo apt -qq update
    endtime=$(date +%s)
    printf " [ DONE ] Configuring System Run ... %s seconds\n" "$((endtime - starttime))"
    printf "\n [ START ] Instaling Major Requirements\n"
    starttime=$(date +%s)
    trap '' 2
    if ! git clone https://github.com/molovo/lumberjack; then
        echo "Download failed downloading molovo/lumberjack! Exiting."
        kill $$
    fi
    if [ -d /usr/local/bin/lj ]; then
        sudo rm -f -R /usr/local/bin/lj
        sudo mv lumberjack/lj /usr/local/bin
    fi
    sudo apt -y install jq moreutils
    if [ ! -n "$(command -v jq)" ] || [ ! -n "$(command -v sponge)" ]; then
        lj critical "Command jq or sponge (moreutils) was not instaled sucessful."
        kill $$
    fi
    trap 2
    endtime=$(date +%s)
    printf " [ DONE ] Instaling Major Requirements ... %s seconds\n" "$((endtime - starttime))"
    lj " [ DONE ] Instaling Major Requirements ... %s seconds\n" "$((endtime - starttime))"
    printf "\n ( PRESS KEY '1' FOR EXPRESS INSTALL )
 ( PRESS KEY '2' FOR CUSTOM INSTALL )\n
 Option: "
    read -r instalationtype
    printf "\n Enable Debug Mode (y/N): "
    read -r debugmode
    if [ "$debugmode" == Y ] || [ "$debugmode" == y ]; then
        debugmode=true
    else
        debugmode=false
    fi
    jq '.configurations.debug = "'"${debugmode}"'"' "${PREVIOUS_PWD}"/bootstrap/settings.json | sponge "${PREVIOUS_PWD}"/bootstrap/settings.json
    unset debugmode
    if [ "$(jq -r '.configurations.debug' "${PREVIOUS_PWD}"/bootstrap/settings.json)" == true ]; then
        set +e
    else
        set -e
    fi
    printf "\n First time runing script? (Y/n): "
    read -r firstrun
    if [ -z "${firstrun}" ] || [ "${firstrun}" == Y ] || [ "${firstrun}" == y ]; then
        printf "\n [ START ] Update & Upgrade\n"
        starttime=$(date +%s)
        sudo apt -y upgrade && sudo apt -y dist-upgrade
        endtime=$(date +%s)
        printf " [ DONE ] Update & Upgrade ... %s seconds\n" "$((endtime - starttime))"
        printf "\n [ START ] Instaling Common Requirements\n"
        starttime=$(date +%s)
        apps=(
            software-properties-common
            build-essential
            apt-transport-https
            curl
            unzip
            libssl-dev
            ca-certificates
        )
        sudo apt -y install "${apps[@]}"
        unset apps
        endtime=$(date +%s)
        printf " [ DONE ] Common Requirements ... %s seconds\n" "$((endtime - starttime))"
        lj " [ DONE ] Instaling Common Requirements ... %s seconds\n" "$((endtime - starttime))"
        printf "\n [ START ] Configurating Command Alias\n"
        starttime=$(date +%s)
        "${PREVIOUS_PWD}"/configurations/alias.sh "${PREVIOUS_PWD}"
        wait
        endtime=$(date +%s)
        printf " [ DONE ] Configurating Command Alias ... %s seconds\n" "$((endtime - starttime))"
        lj " [ DONE ] Configurating Command Alias ... %s seconds\n" "$((endtime - starttime))"
    elif [ "${firstrun}" == N ] || [ "${firstrun}" == n ]; then
        printf "\n [ START ] Fix Possible Erros\n"
        starttime=$(date +%s)
        sudo apt --fix-broken install
        sudo dpkg --configure -a
        endtime=$(date +%s)
        printf " [ DONE ] Fix Possible Erros ... %s seconds\n" "$((endtime - starttime))"
        lj " [ DONE ] Fix Possible Erros ... %s seconds\n" "$((endtime - starttime))"
        printf "\n Enable Purge Mode (y/N): "
        read -r purgemode
        if [ "$purgemode" == Y ] || [ "$purgemode" == y ]; then
            purgemode=true
        else
            purgemode=false
        fi
        jq '.configurations.purge = "'"${purgemode}"'"' "${PREVIOUS_PWD}"/bootstrap/settings.json | sponge "${PREVIOUS_PWD}"/bootstrap/settings.json
        unset purgemode
    else
        kill $$
    fi
    unset firstrun
    if [ "${instalationtype}" == 1 ]; then
        printf "\n [ START ] Software Instalation List\n"
        starttime=$(date +%s)
        i=0
        printf "\n Use default program instalation (y/N): "
        read -r defaultprogram
        printf "\n"
        for row in $(jq -r '.programs[] | @base64' "${PREVIOUS_PWD}"/bootstrap/settings.json); do
            _jq() {
                echo "${row}" | base64 --decode | jq -r "${1}"
            }
            if [ "$defaultprogram" == Y ] || [ "$defaultprogram" == y ]; then
                programdefault=$(_jq '.default')
                jq '.programs['"${i}"'].installation = "'"${programdefault}"'"' "${PREVIOUS_PWD}"/bootstrap/settings.json | sponge "${PREVIOUS_PWD}"/bootstrap/settings.json
            fi
            ((i++))
        done
        for row in $(jq -r '.programs[] | @base64' "${PREVIOUS_PWD}"/bootstrap/settings.json); do
            _jq() {
                echo "${row}" | base64 --decode | jq -r "${1}"
            }
            if [ "$(_jq '.installation')" == true ]; then
                echo " $(_jq '.name'): $(_jq '.installation')"
            fi
        done
        sleep 3
        endtime=$(date +%s)
        printf " [ DONE ] Software Instalation List ... %s seconds\n" "$((endtime - starttime))"
        lj " [ DONE ] Software Instalation List ... %s seconds\n" "$((endtime - starttime))"
    elif [ "${instalationtype}" == 2 ]; then
        printf "\n Your Name (Default: Matheus Rocha Vieira): "
        read -r username
        if [ -z "${username}" ]; then
            username="Matheus Rocha Vieira"
            echo "$username"
        fi
        jq '.personal.name = "'"${username}"'"' "${PREVIOUS_PWD}"/bootstrap/settings.json | sponge "${PREVIOUS_PWD}"/bootstrap/settings.json
        unset username
        printf "\n Your E-Mail (Default: matheusrv@email.com): "
        read -r email
        if [ -z "${email}" ]; then
            email="matheusrv@email.com"
            echo "$email"
        fi
        jq '.personal.email = "'"${email}"'"' "${PREVIOUS_PWD}"/bootstrap/settings.json | sponge "${PREVIOUS_PWD}"/bootstrap/settings.json
        unset email
        printf "\n Your GitHub Username (Default: MatheusRV): "
        read -r githubuser
        if [ -z "${githubuser}" ]; then
            githubuser="MatheusRV"
            echo "$githubuser"
        fi
        jq '.personal.githubuser = "'"${githubuser}"'"' "${PREVIOUS_PWD}"/bootstrap/settings.json | sponge "${PREVIOUS_PWD}"/bootstrap/settings.json
        unset githubuser
        if [[ ! "$(uname -r)" =~ "Microsoft$" ]]; then
            defaultoption="(Default for WSL: '/mnt/c/Dev')"
        else
            defaultoption="(Default for Unix-like: '~/Dev')"
        fi
        printf "\n Default Dev Folder %s: " "$defaultoption"
        read -r defaultfolder
        if [ -z "${defaultfolder}" ]; then
            if [[ ! "$(uname -r)" =~ "Microsoft$" ]]; then
                defaultfolder=/mnt/c/Dev
            else
                defaultfolder=~/Dev
            fi
            if [ ! -d "${defaultfolder}" ]; then
                mkdir "${defaultfolder}"
            fi
            echo "${defaultfolder}"
        else
            if [ ! -d "${defaultfolder}" ]; then
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
            programslug="$(_jq '.program')"
            programdependencies="$(jq -r '.programs[] | select(.program=="'"${programslug}"'").dependencies' "${PREVIOUS_PWD}"/bootstrap/settings.json)"
            dependencieinstallation="$(jq -r '.programs[] | select(.program=="'"${programdependencies}"'").installation' "${PREVIOUS_PWD}"/bootstrap/settings.json)"
            if [ "${programdependencies}" == "null" ] || [ "${dependencieinstallation}" == true ]; then
                programdefault=$(_jq '.default')
                if [ "$programdefault" == true ]; then
                    defaultoption="(Y/n)"
                else
                    defaultoption="(y/N)"
                fi
                printf "\n Install %s %s: " "$(_jq '.name')" "$defaultoption"
                read -r programname
                if [ "$programname" == Y ] || [ "$programname" == y ]; then
                    programinstallation=true
                    echo "${programinstallation}"
                elif [ -z "$programname" ]; then
                    programinstallation="${programdefault}"
                    echo "${programdefault}"
                else
                    programinstallation=false
                    echo "${programinstallation}"
                fi
                jq '.programs['"${i}"'].installation = "'"${programinstallation}"'"' "${PREVIOUS_PWD}"/bootstrap/settings.json | sponge "${PREVIOUS_PWD}"/bootstrap/settings.json
            else
                programname="$(_jq '.name')"
                printf "\n You can't install %s without %s\n" "$programname" "$programdependencies"
            fi
            ((i++))
            unset programname
        done
        variables=(
            programname
            programdefault
            programinstallation
            defaultoption
            i
        )
        unset "${variables[@]}"
    else
        kill $$
    fi
    unset instalationtype
    for row in $(jq -r '.programs[] | @base64' "${PREVIOUS_PWD}"/bootstrap/settings.json); do
        _jq() {
            echo "${row}" | base64 --decode | jq -r "${1}"
        }
        if [ "$(_jq '.installation')" == true ]; then
            programslug="$(_jq '.program')"
            #shellcheck disable=SC2116
            programname="$(echo _jq '.name')"
            programdependencies="$(jq -r '.programs[] | select(.program=="'"${programslug}"'").dependencies' "${PREVIOUS_PWD}"/bootstrap/settings.json)"
            dependencieinstallation="$(jq -r '.programs[] | select(.program=="'"${programdependencies}"'").installation' "${PREVIOUS_PWD}"/bootstrap/settings.json)"
            if [ "${programdependencies}" == "null" ] || [ "${dependencieinstallation}" == true ]; then
                installflag=true
            else
                installflag=false
                printf "\n [ ERROR ] You are instaling %s without install it dependecies\n" "$($programname)"
            fi
            if [ "${installflag}" == true ]; then
                printf "\n [ START ] %s\n" "$($programname)"
                starttime=$(date +%s)
                "${PREVIOUS_PWD}"/programs/"${programslug}".sh "${PREVIOUS_PWD}" || installationerror=true
                wait
                if [ "${installationerror}" == true ]; then
                    installationerror=false
                    endtime=$(date +%s)
                    printf " [ ERROR ] %s returns a non-zero exit status ... %s seconds\n" "$($programname)" "$((endtime - starttime))"
                else
                    programconfiguration="$(jq -r '.programs[] | select(.program=="'"${programslug}"'").config' "${PREVIOUS_PWD}"/bootstrap/settings.json)"
                    if [ "${programconfiguration}" == true ]; then
                        printf "\n [ START ] %s configuration\n" "$($programname)"
                        "${PREVIOUS_PWD}"/programs/"${programslug}"-config.sh "${PREVIOUS_PWD}" || installationerror=true
                        wait
                        if [ "${installationerror}" == true ]; then
                            installationerror=false
                            printf " [ ERROR ] %s configuration returns a non-zero exit status\n" "$($programname)"
                        else
                            printf " [ DONE ] %s configuration\n" "$($programname)"
                        fi
                    fi
                    endtime=$(date +%s)
                    printf " [ DONE ] %s ... %s seconds\n" "$($programname)" "$((endtime - starttime))"
                fi
            fi
        fi
    done
    variables=(
        installflag
        installationerror
        programname
        dependencieinstallation
    )
    unset "${variables[@]}"
    printf "\n [ START ] Common Requirements\n"
    starttime=$(date +%s)
    apps=(
        htop
        tmux
        shellcheck
    )
    sudo apt -y install "${apps[@]}"
    endtime=$(date +%s)
    printf " [ DONE ] Common Requirements ... %s seconds\n" "$((endtime - starttime))"
    printf "\n [ START ] Cleaning\n"
    starttime=$(date +%s)
    sudo apt -y autoremove && sudo apt -y autoclean && sudo apt -y clean
    cd "${PREVIOUS_PWD}" && echo "cd ${PREVIOUS_PWD}" || return
    sudo rm -R -f "${HOME}"/tmp
    endtime=$(date +%s)
    printf " [ DONE ] Cleaning ... %s seconds\n" "$((endtime - starttime))"
    endtotaltime=$(date +%s)
    printf "\n Total Execution Time ... %s seconds\n" "$((endtotaltime - starttotaltime))"
    variables=(
        PREVIOUS_PWD
        starttotaltime
        endtotaltime
        starttime
        endtime
        apps
    )
    unset "${variables[@]}"
}
