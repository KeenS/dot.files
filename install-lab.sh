#!/bin/sh
# templated by http://qiita.com/blackenedgold/items/c9e60e089974392878c8
usage() {
    cat <<HELP
NAME:
   $0 -- install lab

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

lab_version() {
    lab version | grep 'lab version' | grep -Eo '[0-9.]+'
}

target_arch() {
    case "$(uname -m)" in
        x86_64) echo amd64 ;;
        aarch64|arm64) echo arm64 ;;
        *)
            echo "warning: lab does not support architecture $(uname -m); skipping installation." >&2
            return 1
            ;;
    esac
}


main() {
    SCRIPT_DIR="$(cd $(dirname "$0"); pwd)"
    : ${PREFIX=~/bin}

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
    ASSET="lab_${VERSION}_linux_${ARCH}"

    echo "current version = $(lab_version) , required version = ${VERSION}"
    if "$force" || [ "$(lab_version)" != "${VERSION}" ]; then
        echo "start installing $VERSION"
        wget "https://github.com/zaquestion/lab/releases/download/v${VERSION}/${ASSET}.tar.gz"
        mkdir "${ASSET}"
        tar xzf "${ASSET}.tar.gz" -C "${ASSET}"
        cp "${ASSET}/lab" "$PREFIX"
        rm -rf "${ASSET}" "${ASSET}.tar.gz"
        echo "installation of lab ${VERSION} done"
    else
        echo "lab is up to date. do nothing."
    fi

}

main "$@"
