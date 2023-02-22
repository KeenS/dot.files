#!/bin/sh
# templated by http://qiita.com/blackenedgold/items/c9e60e089974392878c8
usage() {
    cat <<HELP
NAME:
   $0 -- install helix

SYNOPSIS:
  $0 [--force] [--verbose] VERSION
  $0 [-h|--help]

DESCRIPTION:
   install the helix

      --force     Skip version check and force install
  -h  --help      Print this help.
      --verbose   Enables verbose mode.
HELP
}

hx_version() {
    hx --version | grep -Eo '[0-9]+\.[0-9]+(\.[0-9]+)'
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


    echo "current version = $(hx_version) , required version = ${VERSION}"
    if "$force" || [ "$(hx_version)" != "${VERSION}" ]; then
        echo "start installing $VERSION"

        cd ~/Rust/helix/
        git fetch -a
        git checkout "${VERSION}"
        cargo install -f --locked --path helix-term
        hx --grammar fetch
        hx --grammar build
        echo "installation of helix ${VERSION} done"
    else
        echo "helix is up to date. do nothing."
    fi

}

main "$@"

