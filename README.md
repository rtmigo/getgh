# [getgh](https://github.com/rtmigo/getgh) #experimental  

* CLI utility for Linux, MacOS, Windows
* **Downloads individual files from GitHub repos**
* Files may be public or private (to which you have access)
* Uses `gh` API internally
* Does not create/modify local Git repos

# Install

### Prerequisites

Installed and working [GitHub CLI](https://github.com/cli/cli#installation) (aka `gh`)

### Installation

 
Get the latest `getgh` binary from
   the [Releases](https://github.com/rtmigo/getgh/releases) page 



<details><summary>Alternatively, get the release from the command line</summary>

## Linux:

```bash
# download and extract to current working directory
wget -c -O - \
  https://github.com/rtmigo/getgh/releases/latest/download/getgh_linux_amd64.tgz \
  | tar -xz

# check it runs
./getgh --version

# maybe move to some directory in your $PATH
mv -v ./getgh "$HOME/.local/bin/"
```
</details>



# Use

## File to file

Download remote `file.sh` to local `localname.sh`:

```bash
getgh https://github.com/user/repo/file.sh localname.sh
```

## File to stdout

Just print the file on terminal:

```bash
getgh https://github.com/user/repo/file.sh
```

Or pipe to other process. For example, extract the tar contents
to the current working directory:

```bash
getgh https://github.com/user/repo/archive.tar.gz | tar -xz
```

## File into directory

Download remote `file.sh` to local `targetdir/file.sh`:

```bash
getgh https://github.com/user/repo/file.sh targetdir/
```

Or into the current working directory:

```bash
getgh https://github.com/user/repo/file.sh .
```

## Directory to directory

Download all files from remote `dir` storing them inside local `targetdir`:

```bash
getgh https://github.com/user/repo/dir/ targetdir/
```

# License

Copyright © 2022 [Artsiom iG](https://github.com/rtmigo).
Released under the [MIT License](LICENSE).

