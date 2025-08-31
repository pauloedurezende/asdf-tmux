# Contributing

## Prerequisites

The following tools are required for local development:

- **Build tools**: gcc, make, pkg-config
- **Libraries**: libevent-dev, libncurses-dev (utf8proc on macOS)
- **Development tools**: asdf, bash, curl, tar, git
- **POSIX utilities**

Make sure you have all dependencies installed before testing. See the [Dependencies](README.md#dependencies) section in the README for installation instructions.

## Testing Locally

```shell
asdf plugin test tmux https://github.com/pauloedurezende/asdf-tmux.git --asdf-tool-version 3.5 "tmux -V"
```

**Note:** Since this plugin compiles tmux from source code, the installation process may take several minutes depending on your system performance and the availability of build dependencies.

Tests are automatically run in GitHub Actions on push and PR.
