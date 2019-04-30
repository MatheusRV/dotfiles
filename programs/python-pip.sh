#!/bin/bash
PREVIOUS_PWD="$(jq -r '.pwd' "${HOME}"/tmp/pwd.json)"
if [ "$(jq -r '.configurations.debug' "${PREVIOUS_PWD}"/bootstrap/settings.json)" == true ]; then
	set +e
else
	set -e
fi
if [ "$(jq -r '.configurations.purge' "${PREVIOUS_PWD}"/bootstrap/settings.json)" == true ]; then
	sudo apt -y purge python-pip
	sudo python -m pip uninstall pip
fi
sudo apt -y install python-pip
pip install --upgrade pip
echo "export PATH=\"${HOME}/.local/bin:$PATH\"" >>"${HOME}"/.bashrc
