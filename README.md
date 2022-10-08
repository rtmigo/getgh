# [ghcp](https://github.com/rtmigo/ghcp_dart) #experimental 



CLI utility for downloading individual files from GitHub
repositories.

## Install

To get started, you will need a working [GitHub CLI](https://github.com/cli/cli#installation) (aka `gh`).

Then just download the latest `ghcp` binary from [releases](https://github.com/rtmigo/ghcp_dart/releases).

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

