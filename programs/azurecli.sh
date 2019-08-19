#!/bin/bash
PREVIOUS_PWD="$1"
if [ "$(jq -r '.configurations.debug' "${PREVIOUS_PWD}"/bootstrap/unix-settings.json)" == true ]; then
	set +e
else
	set -e
fi
RELEASE_VERSION="$(lsb_release -cs)"
if [ "$(jq -r '.configurations.purge' "${PREVIOUS_PWD}"/bootstrap/unix-settings.json)" == true ]; then
	sudo apt -y purge azure-cli
fi
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ ${RELEASE_VERSION} main" |
	sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt-key adv --keyserver packages.microsoft.com --recv-keys 52E16F86FEE04B979B07E28DB02C46DF417A0893
if ! curl -L https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -; then
	echo "Azure CLI Download failed! Skipping."
	kill $$
fi
sudo apt -qq update
sudo apt -y install azure-cli
dpkg --get-selections | grep azure-cli
