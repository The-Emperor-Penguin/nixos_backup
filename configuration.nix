# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{config, pkgs, ... }:
let
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  nixpkgs.config = {
    packageOverrides = pkgs: {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };
  };

  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;

  # Bootloader.
  boot.loader.timeout = 3;
  boot.kernel.sysctl = {
  "vm.max_map_count" = 262144;
  };
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  fileSystems."/mnt/Games" = {
    device = "/dev/disk/by-uuid/6a4eaf03-a44d-4cd3-b341-f7d2a3db50c3";
    fsType = "auto";
  };

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = false;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  security.polkit.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.josiah = {
    isNormalUser = true;
    description = "Josiah";
    extraGroups = [ "networkmanager" "wheel" ];
  };


  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.josiah = { lib, ... }: {
    home.username = "josiah";
    home.homeDirectory = "/home/josiah";
    home.stateVersion = "22.11";
    home.packages = [ pkgs.vscode
                      pkgs.keepassxc
                      pkgs.virt-manager
                      pkgs.unstable.godot_4
                      pkgs.unstable.blender-hip ];

    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;
    
    programs.bash.enable = true;

    services.easyeffects = {
      enable = true;
      preset = "default";
    };

    dconf.settings = {
      "org/gnome/desktop/interface" = { 
        gtk-theme = "Adwaita-dark"; 
      };
    };

    home.file.".config/mako/config".text = ''
      default-timeout=1000
      max-visible=3
      layer=top
    '';

    home.file.".config/wofi/config".text = ''
      location = 2
      show = drun
    '';

    home.file.".config/waybar/style.css".text = ''
      * {
        font-size: 16px;
        font-family: monospace;
      }

      window#waybar {
        background: transparent;
        color: #1dbd65;
      }

      #custom-right-arrow-dark,
      #custom-left-arrow-dark {
        color: #1a1a1a;
      }
      #custom-right-arrow-light,
      #custom-left-arrow-light {
        color: #292b2e;
      }
      
      #network,
      #idle_inhibitor,
      #workspaces,
      #clock.1,
      #clock.2,
      #clock.3,
      #clock,
      #pulseaudio,
      #memory,
      #cpu,
      #battery,
      #disk,
      #tray {
        color: #1dbd65;
        border-radius: 25px;
        background: #064169;
        padding: 0 10px;
      }

      #workspaces button {
        padding: 0 2px;
        color: #fdf6e3;
      }
      #workspaces button.focused {
        color: #268bd2;
      }
      #workspaces button:hover {
        box-shadow: inherit;
        text-shadow: inherit;
      }
      #workspaces button:hover {
        background: #1a1a1a;
        border: #1a1a1a;
        padding: 0 3px;
      }
    '';

    home.file.".config/waybar/config".text = ''
      {
          "layer": "top", // Waybar at top layer
          // "position": "bottom", // Waybar position (top|bottom|left|right)
          "height": 25, // Waybar height (to be removed for auto height)
          // "width": 1280, // Waybar width
          "spacing": 5, // Gaps between modules (4px)
          // Choose the order of the modules
          "modules-left": ["pulseaudio", "network"],
          "modules-center": ["clock"],
          "modules-right": ["idle_inhibitor","tray", "cpu", "memory"],
          // Modules configuration
          // "sway/workspaces": {
          //     "disable-scroll": true,
          //     "all-outputs": true,
          //     "format": "{name}: {icon}",
          //     "format-icons": {
          //         "1": "",
          //         "2": "",
          //         "3": "",
          //         "4": "",
          //         "5": "",
          //         "urgent": "",
          //         "focused": "",
          //         "default": ""
          //     }
          // },
          "keyboard-state": {
              "numlock": true,
              "capslock": true,
              "format": "{name} {icon}",
              "format-icons": {
                  "locked": "",
                  "unlocked": ""
              }
          },
          "sway/mode": {
              "format": "<span style=\"italic\">{}</span>"
          },
          "sway/scratchpad": {
              "format": "{icon} {count}",
              "show-empty": false,
              "format-icons": ["", ""],
              "tooltip": true,
              "tooltip-format": "{app}: {title}"
          },
          "mpd": {
              "format": "{stateIcon} {consumeIcon}{randomIcon}{repeatIcon}{singleIcon}{artist} - {album} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S}) ⸨{songPosition}|{queueLength}⸩ {volume}% ",
              "format-disconnected": "Disconnected ",
              "format-stopped": "{consumeIcon}{randomIcon}{repeatIcon}{singleIcon}Stopped ",
              "unknown-tag": "N/A",
              "interval": 2,
              "consume-icons": {
                  "on": " "
              },
              "random-icons": {
                  "off": "<span color=\"#f53c3c\"></span> ",
                  "on": " "
              },
              "repeat-icons": {
                  "on": " "
              },
              "single-icons": {
                  "on": "1 "
              },
              "state-icons": {
                  "paused": "",
                  "playing": ""
              },
              "tooltip-format": "MPD (connected)",
              "tooltip-format-disconnected": "MPD (disconnected)"
          },
          "idle_inhibitor": {
              "format": "{icon}",
              "format-icons": {
                  "activated": "",
                  "deactivated": ""
              }
          },
          "tray": {
              //"icon-size": 20,
              "spacing": 10
          },
          "clock": {
              "timezone": "America/Chicago",
              "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
              "format-alt": "{:%Y-%m-%d}"
          },
          "cpu": {
              "format": "{usage}% ",
              "tooltip": false
          },
          "memory": {
              "format": "{}% "
          },
          "temperature": {
              // "thermal-zone": 2,
              // "hwmon-path": "/sys/class/hwmon/hwmon2/temp1_input",
              "critical-threshold": 80,
              // "format-critical": "{temperatureC}°C {icon}",
              "format": "{temperatureC}°C {icon}",
              "format-icons": ["", "", ""]
          },
          "backlight": {
              // "device": "acpi_video1",
              "format": "{percent}% {icon}",
              "format-icons": ["", "", "", "", "", "", "", "", ""]
          },
          "battery": {
              "states": {
                  // "good": 95,
                  "warning": 30,
                  "critical": 15
              },
              "format": "{capacity}% {icon}",
              "format-charging": "{capacity}% ",
              "format-plugged": "{capacity}% ",
              "format-alt": "{time} {icon}",
              // "format-good": "", // An empty format will hide the module
              // "format-full": "",
              "format-icons": ["", "", "", "", ""]
          },
          "battery#bat2": {
              "bat": "BAT2"
          },
          "network": {
              // "interface": "wlp2*", // (Optional) To force the use of this interface
              "format-wifi": "{essid} ({signalStrength}%) ",
              "format-ethernet": "{ipaddr}/{cidr} ",
              "tooltip-format": "{ifname} via {gwaddr} ",
              "format-linked": "{ifname} (No IP) ",
              "format-disconnected": "Disconnected ⚠",
              "format-alt": "{ifname}: {ipaddr}/{cidr}"
          },
          "pulseaudio": {
              // "scroll-step": 1, // %, can be a float
              "format": "{volume}% {icon} {format_source}",
              "format-bluetooth": "{volume}% {icon} {format_source}",
              "format-bluetooth-muted": " {icon} {format_source}",
              "format-muted": " {format_source}",
              "format-source": "{volume}% ",
              "format-source-muted": "",
              "format-icons": {
                  "headphone": "",
                  "hands-free": "",
                  "headset": "",
                  "phone": "",
                  "portable": "",
                  "car": "",
                  "default": ["", "", ""]
              },
              "on-click": "pavucontrol"
          },
          "custom/media": {
              "format": "{icon} {}",
              "return-type": "json",
              "max-length": 40,
              "format-icons": {
                  "spotify": "",
                  "default": "🎜"
              },
              "escape": true,
              "exec": "$HOME/.config/waybar/mediaplayer.py 2> /dev/null" // Script in resources folder
              // "exec": "$HOME/.config/waybar/mediaplayer.py --player spotify 2> /dev/null" // Filter player based on name
          }
      }
    '';
    
    home.file.".config/hypr/hyprland.conf".text = ''
      exec-once=waybar & ${pkgs.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1 & mako & swaybg --image /home/josiah/.config/background.jpg
      # This is an example Hyprland config file.
      #
      # Refer to the wiki for more information.

      #
      # Please note not all available settings / options are set here.
      # For a full list, see the wiki
      #

      # See https://wiki.hyprland.org/Configuring/Monitors/
      monitor=,preferred,auto,auto


      # See https://wiki.hyprland.org/Configuring/Keywords/ for more

      # Execute your favorite apps at launch
      # exec-once = waybar & hyprpaper & firefox

      # Source a file (multi-file configs)
      # source = ~/.config/hypr/myColors.conf

      # Some default env vars.
      env = XCURSOR_SIZE,24

      # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
      input {
          kb_layout = us
          kb_variant =
          kb_model =
          kb_options =
          kb_rules =

          follow_mouse = 1

          touchpad {
              natural_scroll = false
          }

          sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
      }

      general {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more

          gaps_in = 5
          gaps_out = 20
          border_size = 2
          col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
          col.inactive_border = rgba(595959aa)

          layout = dwindle
      }

      decoration {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more

          rounding = 10
          blur = true
          blur_size = 3
          blur_passes = 1
          blur_new_optimizations = true

          drop_shadow = true
          shadow_range = 4
          shadow_render_power = 3
          col.shadow = rgba(1a1a1aee)
      }

      animations {
          enabled = true

          # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

          bezier = myBezier, 0.05, 0.9, 0.1, 1.05

          animation = windows, 1, 7, myBezier
          animation = windowsOut, 1, 7, default, popin 80%
          animation = border, 1, 10, default
          animation = borderangle, 1, 8, default
          animation = fade, 1, 7, default
          animation = workspaces, 1, 6, default
      }

      dwindle {
          # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
          pseudotile = true # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
          preserve_split = true # you probably want this
      }

      master {
          # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
          new_is_master = true
      }

      gestures {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more
          workspace_swipe = false
      }

      # Example per-device config
      # See https://wiki.hyprland.org/Configuring/Keywords/#per-device-input-configs for more
      device:epic-mouse-v1 {
          sensitivity = -0.5
      }

      # Example windowrule v1
      # windowrule = float, ^(kitty)$
      # Example windowrule v2
      # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
      # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more


      # See https://wiki.hyprland.org/Configuring/Keywords/ for more
      $mainMod = SUPER

      # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
      bind = $mainMod, Q, exec, kitty
      bind = $mainMod, C, killactive,
      bind = $mainMod, M, exit,
      bind = $mainMod, E, exec, dolphin
      bind = $mainMod, V, togglefloating,
      bind = $mainMod, R, exec, wofi --show drun
      bind = $mainMod, P, pseudo, # dwindle
      bind = $mainMod, J, togglesplit, # dwindle
      bind = $mainMod, print, exec, grim

      # Move focus with mainMod + arrow keys
      bind = $mainMod, left, movefocus, l
      bind = $mainMod, right, movefocus, r
      bind = $mainMod, up, movefocus, u
      bind = $mainMod, down, movefocus, d

      # Switch workspaces with mainMod + [0-9]
      bind = $mainMod, 1, workspace, 1
      bind = $mainMod, 2, workspace, 2
      bind = $mainMod, 3, workspace, 3
      bind = $mainMod, 4, workspace, 4
      bind = $mainMod, 5, workspace, 5
      bind = $mainMod, 6, workspace, 6
      bind = $mainMod, 7, workspace, 7
      bind = $mainMod, 8, workspace, 8
      bind = $mainMod, 9, workspace, 9
      bind = $mainMod, 0, workspace, 10

      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      bind = $mainMod SHIFT, 1, movetoworkspace, 1
      bind = $mainMod SHIFT, 2, movetoworkspace, 2
      bind = $mainMod SHIFT, 3, movetoworkspace, 3
      bind = $mainMod SHIFT, 4, movetoworkspace, 4
      bind = $mainMod SHIFT, 5, movetoworkspace, 5
      bind = $mainMod SHIFT, 6, movetoworkspace, 6
      bind = $mainMod SHIFT, 7, movetoworkspace, 7
      bind = $mainMod SHIFT, 8, movetoworkspace, 8
      bind = $mainMod SHIFT, 9, movetoworkspace, 9
      bind = $mainMod SHIFT, 0, movetoworkspace, 10

      # Scroll through existing workspaces with mainMod + scroll
      bind = $mainMod, mouse_down, workspace, e+1
      bind = $mainMod, mouse_up, workspace, e-1

      # Move/resize windows with mainMod + LMB/RMB and dragging
      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow
    '';

    programs.firefox = {
      enable = true;
      package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
        extraPolicies = {
          DisableTelemetry = true;
          NewTabPage = false;
          DisablePocket = true;
          DisableFormHistory = true;
          DisableFirefoxAccounts = true;
          DisableFirefoxScreenshots = true;
          DisableAppUpdate = true;
          Homepage = {
            URL = "about:blank";
            Locked = true;
            StartPage = "homepage-locked";
          };
          ExtensionSettings =  {
            "uBlock0@raymondhill.net" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
              default_area = "navbar";
            };
            "CookieAutoDelete@kennydo.com" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/cookie-autodelete/latest.xpi";
              default_area = "navbar";
            };
            "jid1-MnnxcxisBPnSXQ@jetpack" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
            };
            "jid1-BoFifL9Vbdl2zQ@jetpack" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/decentraleyes/latest.xpi";
            };
            "{20fc2e06-e3e4-4b2b-812b-ab431220cada}" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/startpage-private-search/latest.xpi";
            };
            "graze_for_mastodon@jaredzimmerman.com" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/graze/latest.xpi";
            };
            "streetpass@streetpass.social" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/strretpass-for-mastodon/latest.xpi";
            };
          };
        };
      };
    };
  };
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  fonts.fonts = [
  pkgs.font-awesome
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    swaybg
    vlc
    easyeffects
    rustc
    cargo
    python311
    git
    gh
    kitty
    wayland
    glib
    wofi
    waybar
    wdisplays
    mako
    grim
    pavucontrol
    libsForQt5.polkit-kde-agent
    xfce.thunar
    xfce.thunar-volman
    xfce.thunar-archive-plugin
    xfce.thunar-media-tags-plugin
  ];
  

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  
  services.flatpak.enable = true;
  
  system.autoUpgrade = {
  enable = true;
  };

}
