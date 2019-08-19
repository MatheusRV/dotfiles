#!/bin/bash
PREVIOUS_PWD="$1"
if [ "$(jq -r '.configurations.debug' "${PREVIOUS_PWD}"/bootstrap/unix-settings.json)" == true ]; then
    set +e
else
    set -e
fi
email=$(jq -r '.personal.email' "${PREVIOUS_PWD}"/bootstrap/unix-settings.json)
ssh-keygen -t rsa -b 4096 -C "$email"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
#https://help.github.com/en/enterprise/2.16/user/articles/adding-a-new-ssh-key-to-your-github-account
