#!/bin/sh

name=$(basename $0)
hugo_server_cmd="hugo server -s /src -d /dst -w ${@}"

output ()
{
    echo -e "--> ${name}: ${@}"
}

# assuming in WORKDIR /src
if [ -d .git ]; then
    output "already a repo, checking out ${GIT_BRANCH}"
    git checkout ${GIT_BRANCH}
else
    git clone -b ${GIT_BRANCH} ${GIT_REPO} .
fi

output "starting hugo server\n   ${hugo_server_cmd}"
${hugo_server_cmd} &

while :; do
    output "sleeping for ${GIT_POLL_INTERVAL}"
    sleep ${GIT_POLL_INTERVAL}
    remote=$(git remote -v | grep ${GIT_REMOTE_NAME} | grep fetch | awk '{ print $2 }')
    if [ "${remote}" ]; then
        output "pulling from ${remote} ${GIT_REMOTE_NAME} ${GIT_BRANCH}"
        git pull ${GIT_REMOTE_NAME} ${GIT_BRANCH}
    else
        output "no remotes, moving on"
    fi
done
