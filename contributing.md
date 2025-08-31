# Contributing

Testing Locally:

```shell
asdf plugin test <plugin-name> <plugin-url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git-ref>] [test-command*]

# TODO: adapt this
asdf plugin test tmux https://github.com/pauloedurezende/asdf-tmux.git "tmux -V"
```

Tests are automatically run in GitHub Actions on push and PR.
