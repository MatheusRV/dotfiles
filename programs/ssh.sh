#!/bin/bash -e
printf " [ START ] SSH \n"
starttime=$(date +%s)
PREVIOUS_PWD="$(jq -r '.pwd' "${HOME}"/tmp/pwd.json)"
if [ "$(jq -r '.purge' "${PREVIOUS_PWD}"/bootstrap/settings.json)" == y ] ; then
	sudo apt -y purge openssh-server*
fi
sudo apt -y install openssh-server
sudo sed -i "/#PasswordAuthentication no/c\PasswordAuthentication yes" /etc/ssh/sshd_config
sudo service ssh --full-restart
sudo service ssh start
endtime=$(date +%s)
printf " [ DONE ] SSH ... %s seconds \n" "$((endtime-starttime))"
