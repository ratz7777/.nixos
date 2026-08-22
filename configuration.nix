# /etc/nixos/configuration.nix
{
  config,
  lib,
  pkgs,
  inputs,
  pkgs-stable,
  ...
}:

{
  imports = [
    ./modules/nixcord.nix
    ./modules/nixvim.nix

    ./modules/alacritty.nix
    ./modules/fish.nix

    ./modules/wallpaper.nix
    ./modules/openrgb.nix
    ./modules/nix-gc.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Boot configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  boot.supportedFilesystems = ["ntfs"];

  swapDevices = [
    { 
      device = "/var/lib/swapfile";
      size = 16 * 1024; # Size is specified in megabytes (10240 MB)
    }
  ];


  fileSystems."/mnt/windows" = {
  device = "/dev/disk/by-uuid/01DBEDD9EDB7E660";
  fsType = "ntfs3";
  options = [
    "rw"
    "nofail"            # Prevents boot failure if the drive is disconnected
    "windows_names"     # Optional: Prevents invalid characters for Windows compatibility
    ];
  };

  fileSystems."/mnt/dacha_nas" = {
  device = "//192.168.3.71/512gb";
  fsType = "cifs";
  options = [
    "x-systemd.automount" # Mounts automatically on access
    "noauto"              # Do not mount at boot time
    "x-systemd.idle-timeout=60" # Unmounts after 60 seconds of inactivity
    
    "guest"

    "uid=1000"
    "gid=100"
    ];
  };

  #sound

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    extraConfig.pipewire."92-low-latency" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.allowed-rates" = [
          48000
          96000
          192000
        ];
	      "default.clock.quantum" = 1024;
        "default.clock.min-quantum" = 32;
        "default.clock.max-quantum" = 2048;
      };
    };
  };

  services.printing = {
    enable = true;
    drivers = [ pkgs-stable.hplipWithPlugin ];
  };

  musnix.enable = true;

  # Network configuration
  networking = {
    hostName = "nixos-btw";
    networkmanager.enable = true;
    useDHCP = false;
  };
  
  programs.throne = {
    enable = true;
    tunMode.enable = true;
  };
  

  # Time and locale
  time = {
    timeZone = "Europe/Moscow";
  };
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "ru_RU.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];
    extraLocaleSettings = {
      LC_TIME = "ru_RU.UTF-8";
      LC_MONETARY = "ru_RU.UTF-8";
      LC_MEASUREMENT = "ru_RU.UTF-8";
      LC_ADDRESS = "ru_RU.UTF-8";
      LC_NAME = "ru_RU.UTF-8";
      LC_PAPER = "ru_RU.UTF-8";
      LC_TELEPHONE = "ru_RU.UTF-8";
    };
  };

  # Graphics and NVIDIA
  hardware = {
    graphics.enable = true;
    graphics.enable32Bit = true;
    nvidia = {
      modesetting.enable = true;
      open = false;
    };
  };

  services = {
    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
    };
    desktopManager.plasma6.enable = true;

    displayManager.defaultSession = "plasma";

    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --remember --time --cmd startplasma-wayland";
        };
      };
    };
 
  };

  services.flatpak.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  hardware.bluetooth.enable = true;

  systemd.services.greetd = {
    serviceConfig = {
      Type = "idle";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal";
      TTYReset = "true";
      TTYVHangup = "true";
      TTYVTDisallocate = "true";
    };
  };

  # /elifor teamspeak
  programs.appimage = {
    enable = true;
    binfmt = true;
    package = pkgs.appimage-run.override {
      extraPkgs = pkgs: with pkgs; [
          libepoxy
          zstd
        ];
    };
  };

  # Steam
  programs.steam = {
    enable = true;
    dedicatedServer.openFirewall = true;
  };

  # User accounts
  users.users = {
    ratz = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
        "video"
        "realtime"
	"audio"
	"seat"
	"dialout"
      ];
    };
    megalis = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
        "video"
        "audio"
        "seat"
      ];
    };
  };
  
  #droidcam

  #  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
  #  boot.kernelModules = [ "v4l2loopback" ];
  #  boot.extraModprobeConfig = ''
  #    options v4l2loopback exclusive_caps=1 card_label="DroidCam"
  #  '';

  # System-wide packages

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
      elisa
  ];


  environment.systemPackages = with pkgs; [

    #edu
    (python3.withPackages (ps: [ ps.tkinter ]))
    libreoffice

    droidcam
    android-tools

    # Editors and development
    vscode
    tmux

    nixfmt
    nil

    libgcc
    git

    #3d printing
    orca-slicer
   
    #bottles
    wine
    winetricks

    # Web browser
    firefox
    chromium

    # System utilities
    wget
    fastfetch

    # Nix utilities
    nix-output-monitor
    nix-tree

    #terminal bloat
    cmatrix
    cava
    ratty

    #misc
    unrar
    qbittorrent-enhanced
    gdu
    vicinae

    #audio
    pkgs-stable.reaper

    #video
    obs-studio
    vlc

    #llm
    ollama

    #minecraft
    jdk25

    #prism_minecraft
    (makeDesktopItem {
      name = "PrismLauncher";
      desktopName = "PrismLauncher";
      exec = "QT_SCALE_FACTOR=1.333 appimage-run /home/ratz/.prismAppimage/PrismLauncher-Linux-x86_64.AppImage";
      icon = "prism";
      comment = "minecraft launcher";
      type = "Application";
      categories = [ "Game" ];
    })

    #wt
    (makeDesktopItem {
      name = "warthunder";
      desktopName = "warthunder";
      exec = "steam-run /home/ratz/Downloads/WarThunder/launcher";
      icon = "warthunder";
      comment = "War Thunder on NixOS";
      type = "Application";
      categories = [ "Game" ];
    })

  ];

  # 2. Configure Ollama
  #services.ollama = {
  #  enable = true;
  #  package = pkgs.ollama-cuda;
  #};

  #do not run on startup
  #systemd.services.ollama.wantedBy = lib.mkForce [ ];

  #spotify network discovery, zomboid, minecraft
  networking.firewall.allowedUDPPorts = [
    4747
    5353
    16261
    16262
    25565
  ];
  networking.firewall.allowedTCPPorts = [
    4747
    57621
    16261
    16262
    25565
  ];

  # Fonts

  fonts = {
    fontconfig = {
      defaultFonts = {
        monospace = [
          "Consoleet Terminus-32 Smooth"
        ];
        sansSerif = [
          "Consoleet Terminus-32 Smooth"
        ];
        serif = [
          "Consoleet Terminus-32 Smooth"
        ];
      };
      hinting = {
        enable = true;
        autohint = true;
      };
      antialias = true;
      subpixel = {
	rgba = "none";
      };
    };

    packages = with pkgs; [
      terminus_font
      terminus_font_ttf
    ];
  };

  system.stateVersion = "25.11";

}
