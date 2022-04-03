#!/bin/sh
# templated by http://qiita.com/blackenedgold/items/c9e60e089974392878c8
usage() {
    cat <<HELP
NAME:
   $0 -- install hugo

SYNOPSIS:
  $0 [--force] [--verbose] VERSION
  $0 [-h|--help]

DESCRIPTION:
   install the hugo

      --force     Skip version check and force install
  -h  --help      Print this help.
      --verbose   Enables verbose mode.
HELP
}

hugo_version() {
    hugo version | grep -Eo 'v[0-9]+\.[0-9]+\.[0-9]+' | sed 's/v//'
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


    echo "current version = $(hugo_version) , required version = ${VERSION}"
    if "$force" [ "$(hugo_version)" != "${VERSION}" ]; then
        echo "start installing $VERSION"

        wget https://github.com/gohugoio/hugo/releases/download/v${VERSION}/hugo_${VERSION}_Linux-64bit.deb
        sudo dpkg -i hugo_${VERSION}_Linux-64bit.deb
        rm -rf hugo_${VERSION}_Linux-64bit.deb
        echo "installation of hugo ${VERSION} done"
    else
        echo "hugo is up to date. do nothing."
    fi

}

main "$@"

