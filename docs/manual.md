# Manual steps

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

# Shortcuts

## Open Kitty

- Run with: Hyper + T
- Run Shell Script: `open -n /Users/markus/Applications/Home\ Manager\ Apps/kitty.app`

## Open Emacs

- Run with: Hyper + E
- Run Shell Script: `emacsclient --socket-name /var/folders/tm/s0rmv44130v_l7p3jynpdkm00000gn/T/emacs501/default -n -c`

## Capture journal entry

- Run with: Hyper + J
- Run Shell Script: `emacsclient --socket-name /var/folders/tm/s0rmv44130v_l7p3jynpdkm00000gn/T/emacs501/default -n -c -F '((name . "org-protocol-capture"))' "org-protocol://capture?template=j"`

# Links

## iCloud documents

`ln -s ~/Library/Mobile\ Documents/com\~apple\~CloudDocs/ ~/iCloud`
