#!/bin/bash
PREVIOUS_PWD="$(jq -r '.pwd' "${HOME}"/tmp/pwd.json)"
if [ "$(jq -r '.configurations.debug' "${PREVIOUS_PWD}"/bootstrap/settings.json)" == true ]; then
	set +e
else
	set -e
fi
if [ "$(jq -r '.configurations.purge' "${PREVIOUS_PWD}"/bootstrap/settings.json)" == y ]; then
	sudo apt -y purge ruby* rvm*
fi
# TODO: Fix 'failed: IPC connect call failed gpg: keyserver receive failed: No dirmngr' on install rvm key.
sudo apt -y install dirmngr
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
if ! curl -sSL https://get.rvm.io | bash -s stable; then
	echo "Download failed! Exiting."
	kill $$
fi
