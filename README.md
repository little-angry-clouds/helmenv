# helmenv

**DISCLAIMER**
This project is discontinued, but there's a better version
[here](https://github.com/little-angry-clouds/kubernetes-binaries-managers/tree/master/cmd/helmenv).
You may check the reasons behind that decision
[here](https://github.com/little-angry-clouds/kubernetes-binaries-managers/tree/master/cmd/helmenv#why-migrate-from-bash-to-go).
And you can see how to migrate to the new project
[here](https://github.com/little-angry-clouds/kubernetes-binaries-managers/tree/master/cmd/helmenv#how-to-migrate-from-the-bash-version).

[Helm](https://helm.sh) version manager inspired by
[tfenv](https://github.com/tfutils/tfenv/). It also manages the plugins, charts
and others. It basically assigns the variable `HELM_HOME`, which by default
points to `$HOME/.helm/`, to the path `$HOME/.helm/$version`.

## Support
Currently helmenv supports the following OSes
- macOS (64bit)
- Linux
  - 32bit
  - 64bit
  - Arm
  - Arm64

## Installation
1. Check out helmenv into any path (`${HOME}/.helm` in the example)

```bash
git clone https://github.com/alexppg/helmenv.git ~/.helm
```

2. Add `~/.helm` to your `$PATH`

```bash
echo 'export PATH="$HOME/.helm:$PATH"' >> ~/.bashrc
# Or
echo 'export PATH="$HOME/.helm:$PATH"' >> ~/.zshrc
```

3. Source the script
```bash
echo 'source $HOME/.helm/helmenv.sh' >> ~/.bashrc
# Or
echo 'source $HOME/.helm/helmenv.sh' >> ~/.zshrc
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
List installed versions, and show an asterisk after the currently active version:
```bash
$ helmenv list
v2.10.0
v2.11.0
v2.12.3 *
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
There's a similar project for managing [kubectl versions](https://github.com/alexppg/kbenv).

## License
GPL3
