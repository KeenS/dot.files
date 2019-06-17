#!/bin/sh
# templated by http://qiita.com/blackenedgold/items/c9e60e089974392878c8
usage() {
    cat <<HELP
NAME:
   $0 -- install hub

SYNOPSIS:
  $0 VERSION
  $0 [-h|--help]
  $0 [--verbose]

DESCRIPTION:
   install the hub

  -h  --help      Print this help.
      --verbose   Enables verbose mode.
HELP
}

hub_version() {
    hub version | grep 'hub version' | grep -Eo '[0-9.]+'
}


main() {
    SCRIPT_DIR="$(cd $(dirname "$0"); pwd)"

    while [ $# -gt 0 ]; do
        case "$1" in
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


    echo "current version = $(hub_version) , required version = ${VERSION}"
    if [ "$(hub_version)" != "${VERSION}" ]; then
        echo "start installing $VERSION"
        wget https://github.com/github/hub/releases/download/v${VERSION}/hub-linux-amd64-${VERSION}.tgz
        tar xzf hub-linux-amd64-${VERSION}.tgz
        (cd hub-linux-amd64-${VERSION} && sudo ./install)
        rm -rf hub-linux-amd64-${VERSION}.tgz
        hub-linux-amd64-${VERSION}
        echo "installing hub ${VERSION} done"
    else
        echo "hub is up to date. do nothing."
    fi

}

main "$@"

