{ pkgs, ... }:

let
  dynamicWallpaperScript = pkgs.writeShellScript "dynamic-wallpaper" ''
    # Ensure paths are absolute
    ID="${pkgs.coreutils}/bin/id"
    MAGICK="${pkgs.imagemagick}/bin/magick"
    APPLY_WP="${pkgs.kdePackages.plasma-workspace}/bin/plasma-apply-wallpaperimage"

    # Set up environment variables for the user session
    USER_ID=$($ID -u)
    export XDG_RUNTIME_DIR="/run/user/$USER_ID"
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_ID/bus"

    # Get current hour (00-23)
    CURRENT_HOUR=$(date +%H)

    # Determine color based on time (Day: 08:00 to 21:59, Night: 22:00 to 07:59)
    if [ "$CURRENT_HOUR" -ge 6 ] && [ "$CURRENT_HOUR" -lt 22 ]; then
        COLOR="white"
    else
        COLOR="black"
    fi

    # Create 1x1 solid image if it doesn't exist
    WP_PATH="/tmp/bg_$COLOR.png"
    if [ ! -f "$WP_PATH" ]; then
        $MAGICK -size 1x1 xc:"$COLOR" "$WP_PATH"
    fi

    # Apply it
    $APPLY_WP "$WP_PATH"
  '';
in
{
  environment.systemPackages = [ pkgs.imagemagick ];

  systemd.user.services.update-wallpaper = {
    description = "Dynamically update KDE wallpaper based on current time";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${dynamicWallpaperScript}";
    };
    # graphical-session.target ensures D-Bus and Plasma are fully ready
    wantedBy = [ "graphical-session.target" ];
  };

  systemd.user.timers.update-wallpaper = {
    description = "Check and update wallpaper periodially";
    timerConfig = {
      # Runs at 08:00, 22:00, and immediately upon login if missed
      OnCalendar = [ "*-*-* 06:00:00" "*-*-* 22:00:00" ];
      OnStartupSec = "10s"; 
      Persistent = true;
    };
    wantedBy = [ "timers.target" ];
  };
}
