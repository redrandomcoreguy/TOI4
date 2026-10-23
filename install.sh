#!/bin/sh
# Installs the "toi4" command on Linux and macOS:  chmod +x install.sh, then ./install.sh
# Remove it again with:  ./install.sh --uninstall   (or: toi4 --uninstall)
# It does the README's steps 2 to 4 for you: installs Python 3 and a C compiler with your
# distro's package manager when they are missing, runs the game's installer, and adds
# ~/.local/bin to your PATH when it isn't there yet.
# Installing also tidies this folder: it deletes .git, LICENSE and README.md, so only the game is left.
# (A .git folder with commits that aren't on GitHub yet is kept.)

if [ "$(id -u)" = 0 ]; then
    echo "install.sh: run it as yourself, without sudo: the toi4 command goes in your own ~/.local/bin." >&2
    echo "  (To make it for root anyway, run: python3 toi4.py --install)" >&2
    exit 1
fi

here=$(cd "$(dirname "$0")" && pwd) || exit 1
game="$here/toi4.py"
if [ ! -f "$game" ]; then
    echo "install.sh: can't find toi4.py next to this script (in $here)." >&2
    exit 1
fi

action=--install
if [ "$1" = "--uninstall" ]; then
    action=--uninstall
elif [ -n "$1" ]; then
    echo "install.sh: unknown option: $1  (use: ./install.sh, or ./install.sh --uninstall)" >&2
    exit 2
fi

os_name=$(uname -s 2>/dev/null) || os_name=

find_python() {
    # python3 first; older distros (RHEL 8, openSUSE Leap 15) keep a newer Python under its version number
    for py in python3 python python3.15 python3.14 python3.13 python3.12 python3.11 python3.10 python3.9 python3.8; do
        if command -v "$py" >/dev/null 2>&1 &&
            "$py" -c 'import sys, curses; sys.exit(sys.version_info < (3, 8))' >/dev/null 2>&1; then
            echo "$py"
            return 0
        fi
    done
    return 1
}

as_root() {
    if command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    elif command -v doas >/dev/null 2>&1; then
        doas "$@"
    else
        echo "install.sh: installing packages needs sudo or doas." >&2
        return 1
    fi
}

# README step 2: the packages each distro needs before toi4 can run.
install_prerequisites() {
    echo "Installing Python 3.8+ and a C compiler (README step 2)..."
    if [ "$os_name" = Darwin ]; then
        if ! xcode-select -p >/dev/null 2>&1; then
            echo "The Xcode Command Line Tools are missing; they include Python 3 and clang."
            xcode-select --install >/dev/null 2>&1 || true
            echo "Finish the installer window that just opened. Waiting for it to finish..."
            tries=0
            while ! xcode-select -p >/dev/null 2>&1; do
                tries=$((tries + 1))
                if [ "$tries" -ge 120 ]; then
                    echo "install.sh: the Command Line Tools still aren't installed; run this script again once they are." >&2
                    return 1
                fi
                sleep 5
            done
        fi
        return 0
    fi

    ids=
    if [ -r /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        ids="${ID:-} ${ID_LIKE:-}"
    fi

    case " $ids " in
    *" nixos "*)
        echo "install.sh: on NixOS, add python3 and gcc to environment.systemPackages, then run:" >&2
        echo "  sudo nixos-rebuild switch" >&2
        return 1
        ;;
    *" alpine "*)
        as_root apk add python3 build-base || return 1
        ;;
    *" void "*)
        as_root xbps-install -Sy python3 base-devel || return 1
        ;;
    *" gentoo "*)
        as_root emerge --noreplace dev-lang/python || return 1
        ;;
    *" arch "*)
        as_root pacman -S --needed --noconfirm python gcc || return 1
        ;;
    *" opensuse "*|*" suse "*)
        as_root zypper install -y python3 python3-curses gcc || return 1
        ;;
    *" debian "*|*" ubuntu "*)
        as_root apt-get update && as_root apt-get install -y python3 build-essential || return 1
        ;;
    *" rhel "*|*" centos "*|*" rocky "*|*" almalinux "*)
        as_root dnf install -y python3.12 gcc || as_root dnf install -y python3 gcc || return 1
        ;;
    *" fedora "*)
        as_root dnf install -y python3 gcc || return 1
        ;;
    *)
        echo "install.sh: don't know this distribution, so install Python 3.8+ (with curses) and a C compiler yourself." >&2
        echo "  Debian/Ubuntu: sudo apt install python3 build-essential    Fedora: sudo dnf install python3 gcc" >&2
        echo "  Arch: sudo pacman -S python gcc    Alpine: doas apk add python3 build-base" >&2
        return 1
        ;;
    esac
    return 0
}

# README step 4: ~/.local/bin has to be on PATH for the toi4 command to be found.
path_rc=
path_rc_added=
ensure_local_bin_on_path() {
    if [ -z "$HOME" ]; then
        return 1
    fi
    shell_name=$(basename "${SHELL:-sh}")
    case "$shell_name" in
    zsh) path_rc="$HOME/.zshrc" ;;
    bash) if [ "$os_name" = Darwin ]; then path_rc="$HOME/.bash_profile"; else path_rc="$HOME/.bashrc"; fi ;;
    fish) path_rc="$HOME/.config/fish/config.fish" ;;
    *) path_rc="$HOME/.profile" ;;
    esac
    if [ -f "$path_rc" ] && grep -v '^[[:space:]]*#' "$path_rc" 2>/dev/null | grep -F '.local/bin' >/dev/null 2>&1; then
        return 0
    fi
    if [ "$shell_name" = fish ]; then
        line='fish_add_path $HOME/.local/bin'
    else
        line='export PATH="$HOME/.local/bin:$PATH"'
    fi
    mkdir -p "$(dirname "$path_rc")" 2>/dev/null
    if printf '\n# Added by the TOI4 installer\n%s\n' "$line" >>"$path_rc" 2>/dev/null; then
        path_rc_added=1
        return 0
    fi
    echo "install.sh: couldn't write to $path_rc; add this line yourself:" >&2
    echo "  $line" >&2
    return 1
}

py=$(find_python) || py=

if [ "$action" = --uninstall ]; then
    if [ -z "$py" ]; then
        echo "install.sh: can't find Python 3.8+ with curses to run the uninstall." >&2
        exit 1
    fi
    exec "$py" "$game" --uninstall
fi

if [ -z "$py" ]; then
    install_prerequisites || {
        echo "install.sh: prerequisites are still missing, so the install stopped." >&2
        exit 1
    }
    py=$(find_python) || {
        echo "install.sh: toi4 needs Python 3.8 or newer with curses, and this computer doesn't have it." >&2
        echo "  Debian/Ubuntu: sudo apt install python3     Fedora: sudo dnf install python3" >&2
        echo "  Arch: sudo pacman -S python     Alpine: doas apk add python3     macOS: xcode-select --install" >&2
        exit 1
    }
fi

path_missing=
case ":$PATH:" in
*":$HOME/.local/bin:"*) ;;
*)
    if ensure_local_bin_on_path; then
        path_missing=1
    fi
    ;;
esac

"$py" "$game" --install --tidy
status=$?

if [ "$status" -eq 0 ] && [ -n "$path_missing" ]; then
    echo
    if [ -n "$path_rc_added" ]; then
        echo "install.sh: added ~/.local/bin to your PATH in $path_rc."
    else
        echo "install.sh: ~/.local/bin is already in $path_rc."
    fi
    echo "Open a new terminal window, then type:  toi4"
fi
exit "$status"
