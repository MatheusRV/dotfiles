#!/bin/bash
PREVIOUS_PWD="$1"
if [ "$(jq -r '.configurations.debug' "${PREVIOUS_PWD}"/bootstrap/unix-settings.json)" == true ]; then
	set +e
else
	set -e
fi
PYTHON_VERSION="$(jq -r '.PYTHON_VERSION' "${PREVIOUS_PWD}"/bootstrap/version.json)"
if [ "$(jq -r '.configurations.purge' "${PREVIOUS_PWD}"/bootstrap/unix-settings.json)" == y ]; then
	sudo apt -y purge python3 python3-*
fi
sudo apt -y install software-properties-common
sudo add-apt-repository -y ppa:jonathonf/python-"${PYTHON_VERSION}"
sudo apt -qq update
sudo apt -y install python"${PYTHON_VERSION}" python"${PYTHON_VERSION}"-dev
sudo apt -y install \
	libgfortran3 \
	python-qt4 \
	python3-tk \
	keychain
echo "alias pstart=\"python -m SimpleHTTPServer 4000\"" >>"${HOME}"/.bash_aliases
