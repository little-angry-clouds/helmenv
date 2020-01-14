#!/usr/bin/env bash

function _helmenv_test_requirements {
    if [[ ! "$(command -v curl)" ]]
    then
        echo "helmenv: You must install curl"
        return 1
    elif [[ ! "$(command -v jq)" ]]
    then
        echo "helmenv: You must install jq"
        return 1
    elif [[ ! "$(command -v file)" ]]
    then
        echo "helmenv: You must install file"
        return 1
    fi

    # macOS: verify greadlink installed
    if [[ "$HELM_OS_ARCH" == "darwin"* ]]; then
        if [[ ! "$(command -v greadlink)" ]]; then
            echo "helmenv: You must install coreutils"
            return 1
        fi
    fi
}

function _helmenv_get_os_and_arch(){
    local _uname
    local _arch

    _uname="$(uname -s)"
    _arch="$(uname -m)"

    case "${_uname}" in
        Linux)  machine=linux;;
        Darwin) machine=darwin;;
        *)      machine="UNKNOWN:${_uname}"
    esac

    case "${_arch}" in
        i386)   architecture="386";;
        arm)    architecture="arm";;
        arm64)  architecture="arm64";;
        x86_64) architecture="amd64";;
        *)      architecture="UNKNOWN:${_arch}"
    esac

    if [[ "$machine" == "darwin" ]]
    then
        echo "$machine-amd64"
        return 0
    fi

    echo "$machine-$architecture"
}

function helmenv_list_remote () {
    echo "Fetching versions..."
    # TODO Paginate over this url
    versions_url="https://api.github.com/repos/helm/helm/releases?per_page=100"
    versions="$(curl -s "$versions_url" | jq -r ".[].tag_name" | grep -v "rc\\|beta\\|alpha" | sort --version-sort)"
    echo "$versions"
    return 0
}

function helmenv_install () {
    VERSION="$1"

    if [[ -z "$VERSION" ]] && [[ -t 1 && -z ${HELMENV_IGNORE_FZF:-} && "$(type fzf &>/dev/null; echo $?)" -eq 0 ]]; then
        VERSION=$(helmenv_list_remote | fzf)
    fi

    if [[ -z "$VERSION" ]]
    then
        echo "You must specify a version!"
        return 1
    fi

    if [[ -e "$HELM_BINARY_PATH/helm-$VERSION" ]]
    then
        echo "The version $VERSION is already installed!"
        return 0
    fi

    if [[ "$HELM_OS_ARCH" = *"UNKNOWN"* ]]
    then
        echo "The architecture and/or the OS is not supported: $HELM_OS_ARCH"
        return 1
    fi

    if [[ $VERSION == v3* ]]
    then
        url="https://get.helm.sh/helm-$VERSION-$HELM_OS_ARCH.tar.gz"
    else
        url="https://storage.googleapis.com/kubernetes-helm/helm-$VERSION-$HELM_OS_ARCH.tar.gz"
    fi
    echo "Downloading binary..."
    curl -s -L -o "/tmp/helm-$VERSION.tar.gz" "$url"

    filetype="$(file -b "/tmp/helm-$VERSION.tar.gz")"
    if [[ "$filetype" != *"gzip"* ]]
    then
        echo "There was a problem downloading the file! You probably typed the version incorrectly, but it may be something else."
        return 1
    fi

    mkdir -p /tmp/helm
    tar -zxf "/tmp/helm-$VERSION.tar.gz" -C /tmp/helm
    mv /tmp/helm/${HELM_OS_ARCH}/helm "$HELM_BINARY_PATH/helm-$VERSION"
    rm -r /tmp/helm

    if [[ -L "$HELM_BINARY_PATH/helm" ]]
    then
        if [[ "$HELM_OS_ARCH" == "darwin"* ]]
        then
            actual_version="$(basename "$(greadlink -f "$HELM_BINARY_PATH/helm")")"
        else
            actual_version="$(basename "$(readlink -f "$HELM_BINARY_PATH/helm")")"
        fi
        echo "helm is pointing to the ${actual_version//helm-} version"
        echo "Do you want to overwrite it? (y/n)"
        read -r overwrite
        if [[ "$overwrite" == "y" ]]
        then
            helmenv_use "$VERSION"
        else
            echo "Nothing done, helm still points to the ${actual_version//helm-} version"
        fi
    else
        helmenv_use "$VERSION"
    fi

    if [[ $VERSION != v3* ]]
    then
       if [[ "$overwrite" == "y" ]]
       then
           "$HELM_BINARY_PATH/helm-$VERSION" init --client-only
       else
           HELM_HOME="$HOME/.helm/$VERSION" "$HELM_BINARY_PATH/helm-$VERSION" init --client-only
       fi
    fi
}

function helmenv_uninstall(){
    VERSION="$1"

    if [[ -z "$VERSION" ]] && [[ -t 1 && -z ${HELMENV_IGNORE_FZF:-} && "$(type fzf &>/dev/null; echo $?)" -eq 0 ]]; then
        VERSION=$(helmenv_list | fzf)
    fi

    if [[ -z "$VERSION" ]]
    then
        echo "You must specify a version!"
        return 1
    fi

    if [[ -e "$HELM_BINARY_PATH/helm-$VERSION" ]]
    then
        rm "$HELM_BINARY_PATH/helm-$VERSION"
        if [[ -e "$HOME/.helm/$VERSION" ]]
        then
           rm -r "$HOME/.helm/$VERSION"
        fi
        echo "The version $VERSION is uninstalled!"
    else
        echo "Nothing done, the version $VERSION is not installed!"
    fi
}

function helmenv_list(){
    installed_versions="$(find "${HELM_BINARY_PATH}"/ -name '*helm-*' -exec basename {} \; | grep -Eo 'v([0-9]\.?)+$' | sed '/^$/d' | sort --version-sort)"
    echo "$installed_versions"
}

function helmenv_use(){
    VERSION="$1"

    if [[ -z "$VERSION" ]] && [[ -t 1 && -z ${HELMENV_IGNORE_FZF:-} && "$(type fzf &>/dev/null; echo $?)" -eq 0 ]]; then
        VERSION=$(helmenv_list | fzf)
    fi

    if [[ -z "$VERSION" ]]
    then
        echo "You must specify a version!"
        return 1
    fi

    installed="$(find "$HELM_BINARY_PATH"/ -name "*$VERSION*")"

    if [[ -z "$installed" ]]
    then
        echo "The $VERSION version is not installed!"
        return 1
    fi

    if [[ "$HELM_OS_ARCH" == "darwin"* ]]
    then
        actual_link="$(greadlink -f "$HELM_BINARY_PATH/helm")"
    else
        actual_link="$(readlink -f "$HELM_BINARY_PATH/helm")"
    fi

    if [[ "$actual_link" =~ $VERSION ]]
    then
        echo "helm was already pointing to the $VERSION version!"
    else
        ln -sf "$HELM_BINARY_PATH/helm-$VERSION" "$HELM_BINARY_PATH/helm"
        echo "Done! Now helm points to the $VERSION version"
        export HELM_HOME="$HOME/.helm/${VERSION}"
    fi
}

function helmenv_help() {
    echo "Usage: helmenv <command> [<options>]"
    echo "Commands:"
    echo "    list-remote   List all installable versions"
    echo "    list          List all installed versions"
    echo "    install       Install a specific version"
    echo "    use           Switch to specific version"
    echo "    uninstall     Uninstall a specific version"
}

function helmenv_init () {
    HELM_BINARY_PATH="${HELM_BINARY_PATH:-$HOME/.helm/bin}"
    HELM_OS_ARCH="$(_helmenv_get_os_and_arch)"
    _helmenv_test_requirements
    [[ $? = 1 ]] && return 1
    if [[ "$HELM_OS_ARCH" == "darwin"* ]]; then
        ACTUAL_VERSION="$(basename "$(greadlink -e "$HELM_BINARY_PATH/helm")")"
    else
        ACTUAL_VERSION="$(basename "$(readlink -e "$HELM_BINARY_PATH/helm")")"
    fi
    HELM_HOME="${HELM_HOME:-$HOME/.helm/${ACTUAL_VERSION//helm-}}"

    export HELM_HOME
    export HELM_OS_ARCH

    if [[ ! -e "$HELM_HOME" ]]
    then
        mkdir -p "$HELM_HOME"
    fi
    if [[ ! -e "$HELM_BINARY_PATH" ]]
    then
        mkdir -p "$HELM_BINARY_PATH"
    fi

    # Only add HELM_BINARY_PATH to PATH if it's not already part of the PATH
    if [[ "$PATH" != *"$HELM_BINARY_PATH"* ]]
    then
        export PATH="$HELM_BINARY_PATH:$PATH"
    fi
}

function helmenv() {
    ACTION="$1"
    ACTION_PARAMETER="$2"

    _helmenv_test_requirements
    [[ $? = 1 ]] && return 1

    case "${ACTION}" in
        "list-remote")
            helmenv_list_remote;;
        "list")
            helmenv_list;;
        "install")
            helmenv_install "$ACTION_PARAMETER";;
        "uninstall")
            helmenv_uninstall "$ACTION_PARAMETER";;
        "use")
            helmenv_use "$ACTION_PARAMETER";;
        *)
            helmenv_help
    esac
}

helmenv_init
