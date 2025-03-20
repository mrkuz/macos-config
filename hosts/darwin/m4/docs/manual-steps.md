# Manual setup

This document collects manual installation/configuration steps.

# Software

## Xcode CLI tools

`xcode-select --install`

## Rosetta

`softwareupdate --install-rosetta --agree-to-license`

## Java

`mise use -g java@temurin`

# Emacs configuration

```shell
mkdir ~/etc/
cd ~/etc/
git clone https://github.com/mrkuz/emacs.d.git emacs.d.git
ln -s ~/etc/emacs.d.git ~/.emacs.d
```

# Links

## iCloud documents

`ln -s ~/Library/Mobile\ Documents/com\~apple\~CloudDocs/ ~/iCloud`

## Applications

`ln -s /Applications/IntelliJ\ IDEA\ CE.app/Contents/MacOS/idea ~/bin/`
