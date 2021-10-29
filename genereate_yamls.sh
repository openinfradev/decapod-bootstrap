#!/bin/bash

set -e

DECAPOD_SITE_NAME="hanu-reference"
DECAPOD_BOOTSTRAP_GIT_REPO_URL="https://github.com/openinfradev/decapod-bootstrap.git"
DECAPOD_MANIFESTS_GIT_REPO_URL="https://github.com/openinfradev/decapod-manifests.git"

function usage {
        echo -e "\nUsage: $0 [--site SITE_NAME] [--bootstrap-git BOOTSTRAP_GIT_URL ] [--manifests-git MANIFESTS_GIT_URL]"
        exit 1
}

# We use "$@" instead of $* to preserve argument-boundary information
ARGS=$(getopt -o 's:b:m:h' --long 'site:,bootstrap-git:,manifests-git:,help' -- "$@") || usage
eval "set -- $ARGS"

while true; do
    case $1 in
      (-h|--help)
            usage; shift 2;;
      (-s|--site)
            DECAPOD_SITE_NAME=$2; shift 2;;
      (-b|--bootstrap-git)
            DECAPOD_BOOTSTRAP_GIT_REPO_URL=$2; shift 2;;
      (-m|--manifests-git)
            DECAPOD_MANIFESTS_GIT_REPO_URL=$2; shift 2;;
      (--)  shift; break;;
      (*)   exit 1;;           # error
    esac
done

export DECAPOD_SITE_NAME
export DECAPOD_BOOTSTRAP_GIT_REPO_URL
export DECAPOD_MANIFESTS_GIT_REPO_URL

echo "=== Create YAML files using the following Decapod configuration. For help, use the '-h' option"
echo " Site: "$DECAPOD_SITE_NAME
echo " Bootstrap Git: "$DECAPOD_BOOTSTRAP_GIT_REPO_URL
echo " Manifests Git: "$DECAPOD_MANIFESTS_GIT_REPO_URL

DIRS="argocd-install decapod-apps"
for dir in $DIRS
do
	if [[ -z $(ls | grep ${dir}) ]]
	then
		echo "execute $0 in decapod-bootstrap directory"
		exit 1
	fi
done

for dir in $DIRS
do
	for tpl in $(find ${dir} -name template-* -printf "%f\n")
	do
		cat $dir/${tpl} | envsubst > ${dir}/${tpl:9}
	done
done
