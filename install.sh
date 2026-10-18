#!/bin/sh
# Installs the "toi4" command on Linux and macOS:  chmod +x install.sh, then ./install.sh
# Remove it again with:  ./install.sh --uninstall   (or: toi4 --uninstall)
# It looks for Python 3.8 or newer with curses and lets the game do the rest (python3 toi4.py --install).

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

# python3 first; older distros (RHEL 8, openSUSE Leap 15) keep a newer Python under its version number
for py in python3 python python3.15 python3.14 python3.13 python3.12 python3.11 python3.10 python3.9 python3.8; do
    if command -v "$py" >/dev/null 2>&1 &&
        "$py" -c 'import sys, curses; sys.exit(sys.version_info < (3, 8))' >/dev/null 2>&1; then
        exec "$py" "$game" "$action"
    fi
done

echo "install.sh: toi4 needs Python 3.8 or newer with curses, and this computer doesn't have it." >&2
echo "  Debian/Ubuntu: sudo apt install python3     Fedora: sudo dnf install python3" >&2
echo "  Arch: sudo pacman -S python     Alpine: doas apk add python3     macOS: brew install python" >&2
exit 1
