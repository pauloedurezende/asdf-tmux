<div align="center">

# asdf-tmux [![Build](https://github.com/pauloedurezende/asdf-tmux/actions/workflows/build.yml/badge.svg)](https://github.com/pauloedurezende/asdf-tmux/actions/workflows/build.yml) [![Lint](https://github.com/pauloedurezende/asdf-tmux/actions/workflows/lint.yml/badge.svg)](https://github.com/pauloedurezende/asdf-tmux/actions/workflows/lint.yml)

[tmux](https://github.com/tmux/tmux/wiki) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

**TODO: adapt this section**

- `bash`, `curl`, `tar`, and [POSIX utilities](https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html).
- `SOME_ENV_VAR`: set this environment variable in your shell config to load the correct version of tool x.

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
