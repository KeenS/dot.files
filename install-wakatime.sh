#!/bin/sh
# templated by http://qiita.com/blackenedgold/items/c9e60e089974392878c8
usage() {
    cat <<HELP
NAME:
   $0 -- install wakatime

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

wakatime_version() {
    wakatime version | grep 'wakatime version' | grep -Eo '[0-9.]+'
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

    echo "current version = $(wakatime_version) , required version = ${VERSION}"
    if "$force" || [ "$(wakatime_version)" != "${VERSION}" ]; then
        echo "start installing $VERSION"
        wget "https://github.com/wakatime/wakatime-cli/releases/download/v$VERSION/wakatime-cli-linux-amd64.zip"
        mkdir "wakatime_${VERSION}_linux_amd64"
        unzip wakatime-cli-linux-amd64.zip -d "wakatime_${VERSION}_linux_amd64"
        cp "wakatime_${VERSION}_linux_amd64/wakatime-cli-linux-amd64" "$PREFIX/wakatime"
        rm -rf "wakatime_${VERSION}_linux_amd64" "wakatime_cli_linux_amd64.zip"
        echo "installation of wakatime ${VERSION} done"
    else
        echo "wakatime is up to date. do nothing."
    fi

}

main "$@"

