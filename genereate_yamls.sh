#!/bin/bash

set -e

DECAPOD_SITE_NAME="decapod-reference"
DECAPOD_BOOTSTRAP_GIT_REPO_URL="https://github.com/openinfradev/decapod-bootstrap.git"
DECAPOD_MANIFESTS_GIT_REPO_URL="https://github.com/openinfradev/decapod-manifests.git"

DOCKER_IMAGE_REPO="docker.io"
QUAY_IMAGE_REPO="quay.io"
GITHUB_IMAGE_REPO="ghcr.io"

GIT_REVISION="main"

function usage {
        echo -e "\nUsage: $0 [--site SITE_NAME] [--bootstrap-git BOOTSTRAP_GIT_URL ] [--manifests-git MANIFESTS_GIT_URL] [--git-rev GIT_REVISION] [--registry REGISTRY_URL]"
        exit 1
}

# We use "$@" instead of $* to preserve argument-boundary information
ARGS=$(getopt -o 's:b:m:g:r:h' --long 'site:,bootstrap-git:,manifests-git:,git-rev:,registry:,help' -- "$@") || usage
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
      (-g|--git-rev)
            GIT_REVISION=$2; shift 2;;
      (-r|--registry)
            DOCKER_IMAGE_REPO=$2
	    QUAY_IMAGE_REPO=$2
            GITHUB_IMAGE_REPO=$2; shift 2;;
      (--)  shift; break;;
      (*)   exit 1;;           # error
    esac
done

export DECAPOD_SITE_NAME
export DECAPOD_BOOTSTRAP_GIT_REPO_URL
export DECAPOD_MANIFESTS_GIT_REPO_URL
export GIT_REVISION
export DOCKER_IMAGE_REPO
export QUAY_IMAGE_REPO
export GITHUB_IMAGE_REPO

echo "=== Create YAML files using the following Decapod configuration. For help, use the '-h' option"
echo " Site: "$DECAPOD_SITE_NAME
echo " Bootstrap Git: "$DECAPOD_BOOTSTRAP_GIT_REPO_URL
echo " Manifests Git: "$DECAPOD_MANIFESTS_GIT_REPO_URL
echo " Git Revision: "$GIT_REVISION

DIRS="argocd-install decapod-apps-templates"
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
	if [[ $dir == *"templates" ]]; then
		dest_dir=${dir%-templates}
        else
		dest_dir=$dir
	fi

	for tpl in $(find ${dir} -name template-* -printf "%f\n")
	do
		cat $dir/${tpl} | envsubst > ${dest_dir}/${tpl:9}
	done
done
