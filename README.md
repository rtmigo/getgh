# [hubget](https://github.com/rtmigo/hubget) #experimental  

CLI for Linux, MacOS, Windows

* Downloads files and directories from GitHub repos
* Does not create/modify local Git repos
* Files may be public or private (to which you have access)



# Install

## Make sure you have `gh`

`hubget` will use `gh` internally. So you not need to mess with additional
authentication as long as you have `gh`.

`gh` is an official [GitHub CLI](https://cli.github.com/). Install it [from
here](https://github.com/cli/cli#installation).

## Install `hubget`

Get the latest `hubget` binary from the
[Releases](https://github.com/rtmigo/hubget/releases) page


<details><summary>Alternatively, get the release via the command line</summary>

### Linux

```bash
# download and extract to current working directory
wget -c -O - \
  https://github.com/rtmigo/hubget/releases/latest/download/hubget_linux_amd64.tgz \
  | tar -xz

# check it runs
./hubget --version

# maybe move to some directory in your $PATH
mv -v ./hubget "$HOME/.local/bin/"
```
</details>

# Use

## File to file

Download remote `file.sh` to local `localname.sh`:

```bash
hubget https://github.com/user/repo/file.sh localname.sh
```

## File to stdout

Just print the file on terminal:

```bash
hubget https://github.com/user/repo/file.sh
```

Or pipe to other process. For example, run the bash script without
creating a file:

```bash
hubget https://github.com/user/repo/file.sh | bash
```

## File into directory

Download remote `file.sh` to local `targetdir/file.sh`:

```bash
hubget https://github.com/user/repo/file.sh targetdir/
```

Or into the current working directory (note the dot at the end):

```bash
hubget https://github.com/user/repo/file.sh .
```

## Directory to directory

Download all files from remote `dir` storing them inside local `targetdir`:

```bash
hubget https://github.com/user/repo/dir/ targetdir/
```

# Disclaimer

This project not endorsed or associated with GitHub.

# License

Copyright © 2022 [Artsiom iG](https://github.com/rtmigo).
Released under the [MIT License](LICENSE).

