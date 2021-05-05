#!/bin/sh
# templated by http://qiita.com/blackenedgold/items/c9e60e089974392878c8
usage() {
    cat <<HELP
NAME:
   $0 -- install zellij

SYNOPSIS:
  $0 VERSION
  $0 [-h|--help]
  $0 [--verbose]

DESCRIPTION:
   install the zellij

  -h  --help      Print this help.
      --verbose   Enables verbose mode.
HELP
}

zellij_version() {
    zellij --version | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+'
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


    echo "current version = $(zellij_version) , required version = ${VERSION}"
    if [ "$(zellij_version)" != "${VERSION}" ]; then
        echo "start installing $VERSION"

        wget https://github.com/zellij-org/zellij/releases/download/v${VERSION}/zellij-x86_64-unknown-linux-musl.tar.gz
        tar xzf zellij-x86_64-unknown-linux-musl.tar.gz
        mv zellij ~/bin/
        rm -rf zellij-x86_64-unknown-linux-musl.tar.gz
        echo "installation of zellij ${VERSION} done"
    else
        echo "zellij is up to date. do nothing."
    fi

}

main "$@"

