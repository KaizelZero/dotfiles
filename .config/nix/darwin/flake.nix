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

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ 
	  pkgs.neovim
	  pkgs.oh-my-posh
	  pkgs.fzf
	  pkgs.zoxide
	  pkgs.stow
        ];
     
      homebrew = {
      	enable = true;
	brews = [
	  "mas"
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
	];
	masApps = {
	  "Bitwarden" = 1352778147;
	  "Magnet" = 441258766;
	  "Xcode" = 497799835;
	};
	onActivation.cleanup = "zap";
	onActivation.autoUpdate = true;
	onActivation.upgrade = true;
      };
      
      fonts.packages = 
        [
	  pkgs.nerd-fonts.jetbrains-mono
        ];
      
      system.defaults = {
	dock.autohide = true;
	dock.largesize = 57;
	dock.magnification = true;
	dock.show-recents = false;
	dock.tilesize = 53;
	dock.persistent-apps = [
	  "/System/Applications/Messages.app"
	  "/System/Applications/System Settings.app"
	  "/Applications/Brave Browser.app"
	];
	loginwindow.GuestEnabled = false;
	finder.AppleShowAllExtensions = true;
	finder.AppleShowAllFiles = true;
	finder.ShowExternalHardDrivesOnDesktop = false;
	finder.ShowHardDrivesOnDesktop = false;
	finder.ShowMountedServersOnDesktop = false;
	finder.ShowPathbar = true;
	finder.ShowRemovableMediaOnDesktop = false;
	menuExtraClock.ShowSeconds = true;
	NSGlobalDomain.AppleInterfaceStyle = "Dark";
	NSGlobalDomain.KeyRepeat = 2;
      };

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations.macbook = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        mac-app-util.darwinModules.default
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            # Install Homebrew under the default prefix
            enable = true;

            # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
            enableRosetta = true;

            # User owning the Homebrew prefix
            user = "jimmy";

            # Automatically migrate existing Homebrew installations
            autoMigrate = true;
          };
	}
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations.macbook.pkgs;
  };
}
