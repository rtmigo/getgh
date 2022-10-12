# [hubget](https://github.com/rtmigo/hubget)  

CLI for Linux, MacOS, Windows

* Downloads files and directories from GitHub repos
* Does not create/modify local Git repos
* Files may be public or private (to which you have access)



# Install

## Make sure you have `gh`

`hubget` will use `gh` internally. So you won't have to bother with 
authentication when you have `gh` configured.

`gh` is an official [GitHub CLI](https://cli.github.com/). Install it [from
here](https://github.com/cli/cli#installation).

## Install `hubget`

Download and extract a binary executable [release](https://github.com/rtmigo/hubget/releases):

* [for macOS](https://github.com/rtmigo/hubget/releases/latest/download/hubget_darwin_amd64.tgz)
* [for Linux](https://github.com/rtmigo/hubget/releases/latest/download/hubget_linux_amd64.tgz)
* [for Windows](https://github.com/rtmigo/hubget/releases/latest/download/hubget_windows_amd64.zip)

<details><summary>Alternatively, get the executable via the command line</summary>

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

Download remote `file.txt` to local file `localname.txt`:

```bash
hubget https://github.com/owner/repo/blob/branch/file.txt localname.txt
```

## File to stdout

Just print the file to terminal:

```bash
hubget https://github.com/owner/repo/blob/branch/file.txt
```

Or pipe to other process. For example, extract the file contents without
saving the archive a file:

```bash
hubget https://github.com/owner/repo/blob/branch/file.tgz | tar -xz
```

## File into directory

Download remote `file.txt` to local `targetdir/file.txt`:

```bash
hubget https://github.com/owner/repo/blob/branch/file.txt targetdir/
```

Or into the current working directory (note the dot at the end):

```bash
hubget https://github.com/owner/repo/blob/branch/file.txt .
```

## Directory to directory

Download all files from remote `dir` storing them inside local `targetdir`:

```bash
hubget https://github.com/owner/repo/tree/branch/dir targetdir/
```

# Disclaimer

This project not endorsed or associated with GitHub.

# License

Copyright © 2022 [Artsiom iG](https://github.com/rtmigo).
Released under the [MIT License](LICENSE).

