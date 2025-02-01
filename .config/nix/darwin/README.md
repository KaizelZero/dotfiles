To use this follow this video [here](https://www.youtube.com/watch?v=Z8BL8mdzWHI)
[mac-app-util](https://github.com/hraban/mac-app-util) For creating aliases for installed apps using pkgs

[nix-homebrew](https://github.com/zhaofengli/nix-homebrew) For using Homebrew in nix

Useful commands:
```shell
nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake ~/.config/nix/darwin#macbook
```
```shell
darwin-rebuild switch --flake ~/.config/nix/darwin#macbook
```
