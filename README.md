# TOI4

![Home Screen](home-screen.png)

A offline-vibecoded terminal Hearts Of Iron IV copy


## 𝗣𝗿𝗲𝗿𝗲𝗾𝘂𝗶𝘀𝗶𝘁𝗲𝘀
* For compatibility its recommended to use **Linux** but it will work for any operating system **with a working Python 3 install**. (Including **Windows**) .

* It is recommended to use a [Mono Font](https://github.com/JetBrains/JetBrainsMono) but it is optimized to work with nearly every font.

* For your terminal its very recommended to use one with 256 colors like [Kitty](https://github.com/kovidgoyal/kitty) etc.

* It has not been tested to work with older Python versions so use the **Latest Python package**.


![Demo gif](TOI4-demo.gif)

---

## Installation for the Unix family (Macos included)

### 1. Clone the repo
```bash
git clone https://github.com/redrandomcoreguy/TOI4.git
cd TOI4
```

### 2. Run the install script

```bash
sh install.sh
```
#### If it does not work run 
```bash
chmod +x install.sh
./install.sh
```

That is everything. The script finishes the setup for you:

* It checks for **Python 3.8 or newer** and installs Python and a C compiler with your distribution's package manager if they are missing. This can ask for your password (`sudo`, or `doas` on Alpine).
* It creates the `toi4` command in `~/.local/bin`.
* It adds `~/.local/bin` to your `PATH` in your shell's startup file (`.zshrc`, `.bashrc` or `.bash_profile` on macOS, fish's `config.fish`, or `~/.profile`).

Then **open a new terminal window** and run `toi4`.

#### What the script installs

| System | Command |
| :--- | :--- |
| macOS | `xcode-select --install` |
| Debian/Ubuntu based | `sudo apt update && sudo apt install python3 build-essential` |
| Fedora based | `sudo dnf install python3 gcc` |
| RHEL/Rocky | `sudo dnf install python3.12 gcc` |
| Arch based | `sudo pacman -S --needed python gcc` |
| OpenSUSE Tumbleweed | `sudo zypper install python3 python3-curses gcc` |
| Alpine | `doas apk add python3 build-base` |
| Void | `sudo xbps-install -S python3 base-devel` |
| Gentoo | `sudo emerge --ask --noreplace dev-lang/python` |

**NixOS** is the exception: its packages come from `configuration.nix`, so the script can't install them. Add `python3` and `gcc` to `environment.systemPackages`, run:
```bash
sudo nixos-rebuild switch
```
then run `sh install.sh` again.

#### Doing it by hand instead

If you would rather install the packages yourself, run the command for your system from the table above before running `sh install.sh`; the script sees Python is already there and skips that step. It still adds `~/.local/bin` to your `PATH`, but you can do that yourself too by adding this line to your shell's startup file (`.zshrc`, `.bashrc`, `~/.bash_profile` on macOS, or `~/.profile`):
```bash
export PATH="$HOME/.local/bin:$PATH"
```
---

## Installation for Windows 

### 1. Install Python 

Download **3.14** from [Here](https://www.python.org/downloads/windows/) and click **"Add python.exe to PATH"** in the installer.

### 2. Download the files

On the GitHub click **Code > Download ZIP** and **extract** it.

### 3. Run the install script

Open the folder and run **`install.bat`**.

---

**Once you are done installing run `toi4` to play it!**

![Gameplay](gameplay.png)

---

### Command flags
| Flag | Usage  |
| :--- | :--- |
| `toi4 --help` | Prints a help menu |
| `toi4 --icons plain` |  Uses normal symbols for the map/game icons and uses the choice |
| `toi4 ---icons nerd` |  Uses Mono Nerd font icons (on windows it defaults to normal) |
| `toi4 --install` | Runs/makes the toi4 command |
| `toi4 --uninstall` | Removes the toi4 command |
| `toi4 --update` | Updates the game files |
| `toi4 --updates off` | Turns off update reminders and stops checking Github |

