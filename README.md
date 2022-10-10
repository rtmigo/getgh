# [getgh](https://github.com/rtmigo/getgh) #experimental  

GH File Downloader

* CLI utility for Linux, MacOS, Windows
* **Downloads individual files from GitHub repos**
* Files may be public or private (to which you have access)
* Uses `gh` API internally
* Does not create/modify local Git repos

## Install

To get started, you will need a
working [GitHub CLI](https://github.com/cli/cli#installation) (aka `gh`).

Then get the latest `getgh` binary from
the [Releases](https://github.com/rtmigo/getgh/releases) page.

<details><summary>Or get the latest release from command-line</summary>

### Linux:

```bash
# download and extract to current working directory
wget -c -O - \
  https://github.com/rtmigo/getgh/releases/latest/download/ghfd_linux_amd64.tgz \
  | tar -xz

# check it runs
./getgh --version

# maybe move to some directory in your $PATH
mv -v ./getgh "$HOME/.local/bin/"
```
</details>

## Use

Download `file.java` to current working directory:

```bash
getgh https://github.com/user/repo/dir/file.java .
```


Download `file.java` to `target/path/file.java`:

```bash
getgh https://github.com/user/repo/dir/file.java target/path/
```

Download `file.java` to `target/path/renamed.java`:

```bash
getgh https://github.com/user/repo/dir/file.java target/path/renamed.java
```

## Disclaimer

This project not endorsed or associated with GitHub.

## License

Copyright © 2022 [Artsiom iG](https://github.com/rtmigo).
Released under the [MIT License](LICENSE).

