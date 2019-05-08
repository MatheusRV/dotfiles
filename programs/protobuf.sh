#!/bin/bash
PREVIOUS_PWD="$(jq -r '.pwd' "${HOME}"/tmp/pwd.json)"
if [ "$(jq -r '.configurations.debug' "${PREVIOUS_PWD}"/bootstrap/settings.json)" == true ]; then
	set +e
else
	set -e
fi
HEADER_TYPE="$(uname -s)"
ARCHITECTURE_TYPE="$(uname -m)"
PROTOC_VERSION="$(jq -r '.APACHE_VERSION' "${PREVIOUS_PWD}"/bootstrap/version.json)"
if ! curl https://github.com/google/protobuf/releases/download/v"${PROTOC_VERSION}"/protoc-"${PROTOC_VERSION}"-"${HEADER_TYPE}"-"${ARCHITECTURE_TYPE}".zip; then
	echo "Protobuf download failed! Exiting."
	kill $$
fi
unzip protoc-"${PROTOC_VERSION}"-"${HEADER_TYPE}"-"${ARCHITECTURE_TYPE}".zip -o -d protoc3
sudo mv protoc3/bin/* /usr/local/bin/
sudo cp -r protoc3/include/. /usr/local/include/
sudo chown "${USER}" /usr/local/bin/protoc
sudo chown -R "${USER}" /usr/local/include/google
