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

    NAME=shun
    mv -f /home/${NAME}/Dropbox/backup/home.tar.xz /home/${NAME}/Dropbox/backup/home.old.tar.xz
    mv -f /home/${NAME}/Dropbox/backup/home.tar.xz.sha1 /home/${NAME}/Dropbox/backup/home.old.tar.xz.sha1
    chown -f ${NAME}:${NAME} /home/${NAME}/Dropbox/backup/home.old.tar.xz /home/${NAME}/Dropbox/backup/home.old.tar.xz.sha1
    latest_snapshot="$(zfs list -S creation -o name -tsnapshot | grep -m1 "rpool/USERDATA/${NAME}_.*@autozsys_.*" | grep -o 'autozsys.*')"
    nice tar cvf /home/${NAME}/Dropbox/backup/home.tar.xz \
        --sparse \
        --use-compress-prog=pixz  \
        -p --xattrs \
        --exclude=./Dropbox \
        --exclude=./.cache \
        -C "/home/${NAME}/.zfs/snapshot/$latest_snapshot/" \
        .
    sha1sum /home/${NAME}/Dropbox/backup/home.tar.xz > /home/${NAME}/Dropbox/backup/home.tar.xz.sha1
    chown ${NAME}:${NAME} /home/${NAME}/Dropbox/backup/home.tar.xz /home/${NAME}/Dropbox/backup/home.tar.xz.sha1
}
set -e
export PATH=/usr/bin:/usr/sbin
LOG_FILE=/var/log/backup-home.log
start_time="$(date +%s)"
main "$@" > $LOG_FILE 2>&1
end_time="$(date +%s)"
echo "$(($end_time - $start_time)) seconds" >> $LOG_FILE
date >> $LOG_FILE
