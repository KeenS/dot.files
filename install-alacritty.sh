#!/bin/sh
# templated by http://qiita.com/blackenedgold/items/c9e60e089974392878c8
usage() {
    cat <<HELP
NAME:
   $0 -- install alacritty

SYNOPSIS:
  $0 [--force] [--verbose] VERSION
  $0 [-h|--help]

DESCRIPTION:
   {description here}

      --force     Skip version check and force install
  -h  --help      Print this help.
      --verbose   Enables verbose mode.
HELP
}

alacritty_version() {
    alacritty --version | sed 's/(.*)//' | grep -Eo '[0-9.]+'
}

main() {
    SCRIPT_DIR="$(cd $(dirname "$0"); pwd)"
    : ${PREFIX:=~/compile}

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

    echo "current version = $(alacritty_version) , required version = ${VERSION}"
    if "$force" || [ "$(alacritty_version)" != "${VERSION}" ]; then
        echo "start installing $VERSION"
        if ! [ -d "$PREFIX/alacritty/" ]; then
            (
                mkdir -p "$PREFIX"
                cd "$PREFIX"
                git clone https://github.com/jwilm/alacritty.git
            )
        fi
        cd "$PREFIX/alacritty/"
        git fetch -a
        git checkout "v${VERSION}"
        cargo install -f cargo-deb
        cargo deb --install --manifest-path=alacritty/Cargo.toml -- --no-default-features --features=wayland
        sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
        sudo desktop-file-install extra/linux/Alacritty.desktop
        sudo update-desktop-database
        sudo mkdir -p /usr/local/share/man/man1
        sudo mkdir -p /usr/local/share/man/man5
        scdoc < extra/man/alacritty.1.scd | gzip -c | sudo tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null
        scdoc < extra/man/alacritty-msg.1.scd | gzip -c | sudo tee /usr/local/share/man/man1/alacritty-msg.1.gz > /dev/null
        scdoc < extra/man/alacritty.5.scd | gzip -c | sudo tee /usr/local/share/man/man5/alacritty.5.gz > /dev/null
        scdoc < extra/man/alacritty-bindings.5.scd | gzip -c | sudo tee /usr/local/share/man/man5/alacritty-bindings.5.gz > /dev/null
        cp extra/completions/_alacritty ${ZDOTDIR:-~}/.zfunc/_alacritty

        echo "installation of alacritty ${VERSION} done"
    else
        echo "alacritty is up to date. do nothing."
    fi
}

main "$@"

