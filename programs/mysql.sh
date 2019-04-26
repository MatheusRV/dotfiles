#!/bin/bash
PREVIOUS_PWD="$(jq -r '.pwd' "${HOME}"/tmp/pwd.json)"
if [ "$(jq -r '.configurations.debug' "${PREVIOUS_PWD}"/bootstrap/settings.json)" == true ] ; then
	# Disable exit on non 0
	set +e
else
	# Enable exit on non 0
	set -e
fi
if [ "$(jq -r '.configurations.purge' "${PREVIOUS_PWD}"/bootstrap/settings.json)" == true ] ; then
	sudo apt -y purge mysql-server mysql-client
fi
sudo apt -y install mysql-server mysql-client
sudo usermod -d /var/lib/mysql/ mysql
printf "Press enter when asked for mysql password"
sudo mysql_secure_installation
dpkg --get-selections | grep mysql
