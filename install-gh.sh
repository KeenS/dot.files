#!/bin/sh
# templated by http://qiita.com/blackenedgold/items/c9e60e089974392878c8
usage() {
    cat <<HELP
NAME:
   $0 -- install gh

SYNOPSIS:
  $0 [--force] [--verbose] VERSION
  $0 [-h|--help]

DESCRIPTION:
   install the gh

      --force     Skip version check and force install
  -h  --help      Print this help.
      --verbose   Enables verbose mode.
HELP
}

gh_version() {
    gh version | grep -Eo 'v[0-9]+\.[0-9]+\.[0-9]+' | sed 's/v//'
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


    echo "current version = $(gh_version) , required version = ${VERSION}"
    if "$force" || [ "$(gh_version)" != "${VERSION}" ]; then
        echo "start installing $VERSION"

        wget https://github.com/cli/cli/releases/download/v${VERSION}/gh_${VERSION}_linux_amd64.deb
        sudo dpkg -i gh_${VERSION}_linux_amd64.deb
        rm -rf gh_${VERSION}_linux_amd64.deb
        echo "installation of gh ${VERSION} done"
    else
        echo "gh is up to date. do nothing."
    fi

}

main "$@"

