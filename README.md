<div align="center">

# asdf-tmux [![Build](https://github.com/pauloedurezende/asdf-tmux/actions/workflows/build.yml/badge.svg)](https://github.com/pauloedurezende/asdf-tmux/actions/workflows/build.yml) [![Lint](https://github.com/pauloedurezende/asdf-tmux/actions/workflows/lint.yml/badge.svg)](https://github.com/pauloedurezende/asdf-tmux/actions/workflows/lint.yml)

[tmux](https://github.com/tmux/tmux/wiki) plugin for the [asdf version manager](https://asdf-vm.com).

A terminal multiplexer that allows you to create, access and control multiple terminals from a single screen.

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- **Build tools**: gcc, make, pkg-config - Required for compiling tmux from source code
- **Libraries**: libevent-dev, libncurses-dev - Development headers for tmux dependencies
- **macOS additional**: utf8proc - Required for UTF-8 support on macOS
- **Basic tools**: bash, curl, tar, git and [POSIX utilities](https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html)

**Note:** This plugin compiles tmux from source code, which may take a few minutes depending on your system. The plugin will automatically check and guide you through installing missing dependencies.

## Installing Dependencies

**On Debian/Ubuntu:**
```shell
sudo apt-get update
sudo apt-get install build-essential libevent-dev libncurses5-dev pkg-config
```

**On macOS with Homebrew:**
```shell
brew install libevent ncurses pkg-config utf8proc
```

**On CentOS/RHEL/Fedora:**
```shell
sudo dnf install gcc make libevent-devel ncurses-devel pkgconfig
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

# Show installed versions
asdf list tmux

# Set a version globally (in your home ~/.tool-versions file)
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
