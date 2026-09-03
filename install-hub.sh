#!/bin/sh
# templated by http://qiita.com/blackenedgold/items/c9e60e089974392878c8
usage() {
    cat <<HELP
NAME:
   $0 -- install hub

SYNOPSIS:
  $0 [--force] [--verbose] VERSION
  $0 [-h|--help]

DESCRIPTION:
   install the hub

      --force     Skip version check and force install
  -h  --help      Print this help.
      --verbose   Enables verbose mode.
HELP
}

hub_version() {
    hub version | grep 'hub version' | grep -Eo '[0-9.]+'
}

target_arch() {
    case "$(uname -m)" in
        x86_64) echo amd64 ;;
        aarch64|arm64) echo arm64 ;;
        *)
            echo "warning: hub does not support architecture $(uname -m); skipping installation." >&2
            return 1
            ;;
    esac
}


main() {
    SCRIPT_DIR="$(cd $(dirname "$0"); pwd)"

    force=false
    while [ $# -gt 0 ]; do
        case "$1" in
            --force) force=true; shift ;;
            --help) usage; exit 0;;
            --verbose) set -x; shift;;
            --) shift; break;;
            -*)
                OPTIND=1
                while getopts h OPT "$1"; do
                    case "$OPT" in
                        h) usage; exit 0;;
                    esac
                done
                shift
                ;;
            *) break;;
        esac
    done

    if [ $# != 1 ]; then
        usage
        exit 1
    fi
    VERSION="$1"
    if ! ARCH="$(target_arch)"; then
        return 0
    fi
    ASSET="hub-linux-${ARCH}-${VERSION}"


    echo "current version = $(hub_version) , required version = ${VERSION}"
    if "$force" || [ "$(hub_version)" != "${VERSION}" ]; then
        echo "start installing $VERSION"
        wget "https://github.com/github/hub/releases/download/v${VERSION}/${ASSET}.tgz"
        tar xzf "${ASSET}.tgz"
        (cd "${ASSET}" && sudo ./install)
        rm -rf "${ASSET}.tgz" "${ASSET}"
        echo "installation of hub ${VERSION} done"
    else
        echo "hub is up to date. do nothing."
    fi

}

main "$@"
