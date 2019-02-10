# helmenv
[Helm](https://helm.sh) version manager inspired by
[tfenv](https://github.com/tfutils/tfenv/). It also manages the plugins, charts
and others. It basically assigns the variable `HELM_HOME`, which by default
points to `$HOME/.helm/`, to the path `$HOME/.helm/$version`.

## Support
Currently helmenv supports the following OSes
- Mac OS X (64bit) - not really tested
- Linux
  - 32bit
  - 64bit
  - Arm
  - Arm64

## Installation
1. Check out helmenv into any path (`${HOME}/.helmenv` in the example)

```bash
git clone https://github.com/alexppg/helmenv.git ~/.helmenv
```

2. Add `~/.bin` to your `$PATH`

```bash
echo 'export PATH="$HOME/.bin:$PATH"' >> ~/.bashrc
# Or
echo 'export PATH="$HOME/.bin:$PATH"' >> ~/.zshrc
```

3. Source the script
```bash
echo 'source $HOME/.helmenv/helmenv.sh' >> ~/.bashrc
# Or
echo 'source $HOME/.helmenv/helmenv.sh' >> ~/.zshrc
```

## Usage
### helmenv help

``` bash
$ helmenv help
Usage: helmenv <command> [<options>]
Commands:
    list-remote   List all installable versions
    list          List all installed versions
    install       Install a specific version
    use           Switch to specific version
    uninstall     Uninstall a specific version
```

### helmenv list-remote
List installable versions:

```bash
$ helmenv list-remote
Fetching versions...
v1.2.1
v2.0.0
v2.0.1
v2.0.2
...
```

### helmenv list
List installed versions:
```bash
$ helmenv list
v2.10.0
v2.11.0
v2.12.3
```

### helmenv install
Install a specific version:

```bash
$ helmenv install v2.10.0
Creating $HOME/.helm/v2.10.0
Creating $HOME/.helm/v2.10.0/repository
Creating $HOME/.helm/v2.10.0/repository/cache
Creating $HOME/.helm/v2.10.0/repository/local
Creating $HOME/.helm/v2.10.0/plugins
Creating $HOME/.helm/v2.10.0/starters
Creating $HOME/.helm/v2.10.0/cache/archive
Creating $HOME/.helm/v2.10.0/repository/repositories.yaml
Adding stable repo with URL: https://kubernetes-charts.storage.googleapis.com
Adding local repo with URL: http://127.0.0.1:8879/charts
$HELM_HOME has been configured at $HOME/.helm/v2.10.0.
Not installing Tiller due to 'client-only' flag having been set
Happy Helming!
```

### helmenv use
Switch to specific version:

```bash
$ helmenv use
Done! Now helm points to the v2.11.0 version
```

### helmenv uninstall
Uninstall a specific version:
```bash
$ helmenv uninstall 0.7.0
The version v2.12.3 is uninstalled!
```

## Related Projects
There's a similar project for managing [kubectl
versions](https://github.com/alexppg/kbenv).

## License
GPL3
