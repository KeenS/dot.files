#!/bin/sh
# templated by http://qiita.com/blackenedgold/items/c9e60e089974392878c8
usage() {
    cat <<HELP
NAME:
   $0 -- manage VSCode's extensions

SYNOPSIS:
  $0 [-h|--help]
  $0 [--verbose] {backup|restore}

DESCRIPTION:
   manage VSCode's extensions

  -h  --help      Print this help.
      --verbose   Enables verbose mode.

HELP
}

backup_extensions() {
    code --list-extensions > $BACKUP_FILE
}

restore_extensions() {
    cat $BACKUP_FILE | xargs -n 1 code --force --install-extension 
}
main() {
    SCRIPT_DIR="$(cd $(dirname "$0"); pwd)"
    BACKUP_FILE="$SCRIPT_DIR/vscode-extensions"

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

    if [ $# -ne 1 ]; then
        echo "error: no subcommand specified" >&2
        exit 1
    fi

    case $1 in
        backup) backup_extensions ;;
        restore) restore_extensions ;;
        *) echo "unknown subcommand given: $1" > &2 ;;
    esac
}

main "$@"

