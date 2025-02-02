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
	  "rectangle"
	];
	masApps = {
	  "Bitwarden" = 1352778147;
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
        dock = {
	  autohide = false;
	  largesize = 57;
	  magnification = true;
	  show-recents = false;
	  tilesize = 53;
	  persistent-apps = [
	    "/System/Applications/Messages.app"
	    "/System/Applications/System Settings.app"
	    "/Applications/Brave Browser.app"
	  ];
	  persistent-others = null
	};
	loginwindow = {
	  GuestEnabled = false;
	};
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
	NSGlobalDomain.AppleInterfaceStyle = "Dark";
	NSGlobalDomain.KeyRepeat = 2;
      };

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true; # default shell on catalina

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
