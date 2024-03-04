# Manual setup

This document collects manual installation/configuration steps.

# Software

## Xcode CLI tools

`xcode-select --install`

## Rosetta

`softwareupdate --install-rosetta --agree-to-licenes`

# Emacs configuration

```shell
mkdir ~/etc/
cd ~/etc/
git clone https://github.com/mrkuz/emacs.d.git emacs.d.git
ln -s ~/etc/emacs.d.git ~/.emacs.d
```

# Hammerspoon configuration

```shell
mkdir ~/etc/
cd ~/etc/
git clone https://github.com/mrkuz/hammerspoon.git hammerspoon.git
ln -s ~/etc/hammerspoon.git ~/.hammerspoon
```

# Links

## iCloud documents

`ln -s ~/Library/Mobile\ Documents/com\~apple\~CloudDocs/ ~/iCloud`
`ln -s /Applications/IntelliJ\ IDEA\ CE.app/Contents/MacOS/idea ~/bin/`

