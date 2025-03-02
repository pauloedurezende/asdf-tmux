<div align="center">

# asdf-tmux [![Build](https://github.com/pauloedurezende/asdf-tmux/actions/workflows/build.yml/badge.svg)](https://github.com/pauloedurezende/asdf-tmux/actions/workflows/build.yml) [![Lint](https://github.com/pauloedurezende/asdf-tmux/actions/workflows/lint.yml/badge.svg)](https://github.com/pauloedurezende/asdf-tmux/actions/workflows/lint.yml)

[tmux](https://github.com/tmux/tmux) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

This plugin automatically attempts to install required dependencies during the installation process. However, if you encounter issues, you may need to install them manually.

## Required dependencies

- libevent (development files)
- ncurses (development files)
- build tools (gcc, make, etc.)
- autoconf
- automake
- pkg-config

## Platform-specific installation commands

If automatic installation fails, you can install the dependencies manually using the following commands:

### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install -y libevent-dev libncurses-dev build-essential bison pkg-config autoconf automake
```

### macOS (with Homebrew)
```bash
brew install libevent ncurses automake pkg-config utf8proc
```

### Fedora/CentOS/RHEL
```
sudo dnf install libevent-devel ncurses-devel automake bison pkg-config gcc make
```

### FreeBSD
```bash
pkg install libevent ncurses autoconf automake pkgconf
```

# Install

Plugin:

```shell
asdf plugin add tmux
# or
asdf plugin add tmux https://github.com/pauloedurezende/asdf-tmux.git
```

tmux:

```shell
# Show all installable versions
asdf list-all tmux

# Install specific version
asdf install tmux latest

# Set a version globally (on your ~/.tool-versions file)
asdf global tmux latest

# Now tmux commands are available
tmux -V
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/pauloedurezende/asdf-tmux/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Paulo Eduardo Rezende](https://github.com/pauloedurezende/)
