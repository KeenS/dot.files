#!/bin/sh
# templated by http://qiita.com/blackenedgold/items/c9e60e089974392878c8
usage() {
    cat <<HELP
NAME:
   $0 -- backup home

SYNOPSIS:
  $0 [-h|--help]
  $0 [--verbose]

DESCRIPTION:
   Backup home from the latest snapshot. It logs to $LOG_FILE

  -h  --help      Print this help.
      --verbose   Enables verbose mode.
HELP
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

    latest_snapshot="$(ls --color=never -t .zfs/snapshot | head -n1)"
    echo "Taking backup of $latest_snapshot"
    ls -l .zfs/snapshot | grep "$latest_snapshot"
    rm -f Dropbox/backup/home.old.tar.xz Dropbox/backup/home.old.tar.xz.sha1
    mv -f Dropbox/backup/home.tar.xz Dropbox/backup/home.old.tar.xz || true
    mv -f Dropbox/backup/home.tar.xz.sha1 Dropbox/backup/home.old.tar.xz.sha1 || true
    nice tar cJvf Dropbox/backup/home.tar.xz \
        --sparse --ignore-failed-read \
        -p --xattrs \
        --exclude=./Dropbox \
        --exclude=./.cache \
        --exclude=./.steam \
        -C ".zfs/snapshot/$latest_snapshot/" \
        .
    sha1sum Dropbox/backup/home.tar.xz > Dropbox/backup/home.tar.xz.sha1
}
set -e
cd $HOME
export PATH=/usr/bin:/usr/sbin
start_time="$(date +%s)"
main "$@"
end_time="$(date +%s)"
echo "$(($end_time - $start_time)) seconds"
date
