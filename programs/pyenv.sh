#!/bin/bash
PREVIOUS_PWD="$1"
if [ "$(jq -r '.configurations.debug' "${PREVIOUS_PWD}"/bootstrap/unix-settings.json)" == true ]; then
	set +e
else
	set -e
fi
if [ "$(jq -r '.configurations.purge' "${PREVIOUS_PWD}"/bootstrap/unix-settings.json)" == true ]; then
	echo "PyEnv purge not implemented yet! Skipping."
fi
git clone https://github.com/pyenv/pyenv.git "${HOME}"/.pyenv
{
	export PATH="${PATH}:${HOME}/.pyenv/bin"
	if command -v pyenv 1>/dev/null 2>&1; then
		eval "$(pyenv init -)"
	fi
} >>"${HOME}"/.bashrc
export PATH="${PATH}:${HOME}/.pyenv/bin"
pyenv install "${PYTHON_VERSION}"
