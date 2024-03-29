#!/bin/sh
# templated by http://qiita.com/blackenedgold/items/c9e60e089974392878c8
usage() {
    cat <<HELP
NAME:
   $0 -- install xremap

SYNOPSIS:
  $0 [--force] [--verbose] VERSION
  $0 [-h|--help]

DESCRIPTION:
   install the xremap

      --force     Skip version check and force install
  -h  --help      Print this help.
      --verbose   Enables verbose mode.
HELP
}

xremap_version() {
    xremap --version | grep -Eo '[0-9.]+'
}

stop_xremap() {
    WAS_ACTIVE=$(systemctl --user is-active xremap)
    if [ "$WAS_ACTIVE" = "active" ]; then
        systemctl --user stop xremap
    fi
}

restart_xremap() {
    if [ "$WAS_ACTIVE" = "active" ]; then
        systemctl --user start xremap
    fi
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

    echo "current version = $(xremap_version) , required version = ${VERSION}"
    if $force || [ "$(xremap_version)" != "${VERSION}" ]; then
        echo "start installing $VERSION"
        wget "https://github.com/k0kubun/xremap/releases/download/v${VERSION}/xremap-linux-x86_64-gnome.zip"
        unzip "xremap-linux-x86_64-gnome.zip" -d "xremap-linux-x86_64-gnome"
        stop_xremap
        cp "xremap-linux-x86_64-gnome/xremap" "$PREFIX"
        restart_xremap
        rm -rf "xremap-linux-x86_64-gnome" "xremap-linux-x86_64-gnome.zip"
        echo "installation of xremap ${VERSION} done"
    else
        echo "xremap is up to date. do nothing."
    fi

}

main "$@"

