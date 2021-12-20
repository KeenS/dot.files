#!/bin/sh
# templated by http://qiita.com/blackenedgold/items/c9e60e089974392878c8
usage() {
    cat <<HELP
NAME:
   $0 -- install nsh

SYNOPSIS:
  $0 VERSION
  $0 [-h|--help]
  $0 [--verbose]

DESCRIPTION:
   install the nsh

  -h  --help      Print this help.
      --verbose   Enables verbose mode.
HELP
}

nsh_version() {
    nsh --version || echo 0.0.0 | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+'
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


    echo "current version = $(nsh_version) , required version = ${VERSION}"
    if [ "$(nsh_version)" != "${VERSION}" ]; then
        echo "start installing $VERSION"

        cargo install -f --version="$VERSION" nsh
        echo "installation of nsh ${VERSION} done"
    else
        echo "nsh is up to date. do nothing."
    fi

}

main "$@"
