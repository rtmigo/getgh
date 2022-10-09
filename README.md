# [ghfd](https://github.com/rtmigo/ghfd) #experimental  

GitHub File Downloader

* CLI utility for Linux, MacOS, Windows
* Downloads individual files from GitHub repos
* Files may be public or private
* Uses `gh` API internally
* Does not create/modify local Git repos

## Install

To get started, you will need a
working [GitHub CLI](https://github.com/cli/cli#installation) (aka `gh`).

Then get the latest `ghfd` binary from
the [Releases](https://github.com/rtmigo/ghfd/releases) page.

## Use

Download `file.java` to current working directory:

```bash
ghfd https://github.com/user/repo/dir/file.java .
```


Download `file.java` to `target/path/file.java`:

```bash
ghfd https://github.com/user/repo/dir/file.java target/path/
```

Download `file.java` to `target/path/renamed.java`:

```bash
ghfd https://github.com/user/repo/dir/file.java target/path/renamed.java
```

## Disclaimer

This project not endorsed or associated with GitHub.

## License

Copyright © 2022 [Artsiom iG](https://github.com/rtmigo).
Released under the [MIT License](LICENSE).

