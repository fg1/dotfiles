dotfiles
========

Collection of various dotfiles I use, currently managed using [GNU Stow](https://www.gnu.org/software/stow/).

## Installation and usage

On Debian/Ubuntu:
```
# apt-get install stow
$ cd ~
$ git clone https://github.com/fg1/dotfiles.git
$ cd dotfiles
$ git submodule init
$ git submodule update

$ stow ...
```

