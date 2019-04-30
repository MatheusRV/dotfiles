#!/bin/bash
PREVIOUS_PWD="$(jq -r '.pwd' "${HOME}"/tmp/pwd.json)"
if [ "$(jq -r '.configurations.debug' "${PREVIOUS_PWD}"/bootstrap/settings.json)" == true ]; then
	set +e
else
	set -e
fi
git clone https://github.com/pyenv/pyenv.git "${HOME}"/.pyenv
{
	export PYENV_ROOT="${HOME}/.pyenv"
	export PATH="${PYENV_ROOT}/bin:${PATH}"
	if command -v pyenv 1>/dev/null 2>&1; then
		eval "$(pyenv init -)"
	fi
} >>~/.bashrc
source "${HOME}"/.bashrc
#pyenv install "${PYTHON_VERSION}"
source "${HOME}"/.bashrc
dpkg --get-selections | grep python
