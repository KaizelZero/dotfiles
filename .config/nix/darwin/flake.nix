{
  description = "Zenfil Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, mac-app-util, nix-homebrew }:
    let
      configuration = { pkgs, config, ... }: {
        nixpkgs.config.allowUnfree = true;

        environment.systemPackages = [
          pkgs.neovim
          pkgs.oh-my-posh
          pkgs.fzf
          pkgs.zoxide
          pkgs.stow
          pkgs.ani-cli
          pkgs.nodejs_22
          pkgs.pnpm_10
        ];

        homebrew = {
          enable = true;
          brews = [ 
            "mas"
            "pyenv"
            "readline"
            "xz"
            "pyenv-virtualenv"
          ];
          casks = [
            "hammerspoon"
            "firefox"
            "iina"
            "the-unarchiver"
            "raycast"
            "discord"
            "visual-studio-code"
            "linearmouse"
            "middleclick"
            "obsidian"
            "brave-browser"
            "firefox"
            "ghostty"
            "rectangle"
            "nordvpn"
            "qbittorrent"
          ];
          masApps = {
            "Bitwarden" = 1352778147;
            "Xcode" = 497799835;
          };
          onActivation = {
            cleanup = "zap";
            autoUpdate = true;
            upgrade = true;
          };
        };

        fonts.packages = [
          pkgs.nerd-fonts.jetbrains-mono
        ];

        system.defaults = {
          dock = {
            autohide = true;
            largesize = 57;
            magnification = true;
            show-recents = false;
            tilesize = 53;
            persistent-apps = [
              "/System/Applications/Messages.app"
              "/System/Applications/System Settings.app"
              "/Applications/Brave Browser.app"
            ];
            persistent-others = [];
          };
          loginwindow.GuestEnabled = false;
          finder = {
            AppleShowAllExtensions = true;
            AppleShowAllFiles = true;
            ShowExternalHardDrivesOnDesktop = false;
            ShowHardDrivesOnDesktop = false;
            ShowMountedServersOnDesktop = false;
            ShowPathbar = true;
            ShowRemovableMediaOnDesktop = false;
          };
          menuExtraClock.ShowSeconds = true;
          NSGlobalDomain = {
            AppleInterfaceStyle = "Dark";
            KeyRepeat = 2;
          };
        };

        services.nix-daemon.enable = true;
        nix.settings.experimental-features = "nix-command flakes";
        programs.zsh.enable = true;
        system.configurationRevision = self.rev or self.dirtyRev or null;
        system.stateVersion = 6;
        nixpkgs.hostPlatform = "aarch64-darwin";
      };
    in
    {
      darwinConfigurations.macbook = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          mac-app-util.darwinModules.default
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = "jimmy";
              autoMigrate = true;
            };
          }
        ];
      };

      darwinPackages = self.darwinConfigurations.macbook.pkgs;
    };
}
