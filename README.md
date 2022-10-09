# [ghcp](https://github.com/rtmigo/ghcp) #experimental

* CLI utility for Linux, MacOS, Windows
* Downloads individual files from GitHub repos
* Files may be public or private
* Uses `gh` API internally
* Does not create/modify local Git repos

## Install

To get started, you will need a
working [GitHub CLI](https://github.com/cli/cli#installation) (aka `gh`).

Then get the latest `ghcp` binary from
the [Releases](https://github.com/rtmigo/ghcp/releases) page.

## Use

Download `file.java` to current working directory:

```bash
ghcp https://github.com/user/repo/dir/file.java .
```


Download `file.java` to `target/path/file.java`:

```bash
ghcp https://github.com/user/repo/dir/file.java target/path/
```

Download `file.java` to `target/path/renamed.java`:

```bash
ghcp https://github.com/user/repo/dir/file.java target/path/renamed.java
```

## License

Copyright © 2022 [Artsiom iG](https://github.com/rtmigo).
Released under the [MIT License](LICENSE).

