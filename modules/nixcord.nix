# nixcord.nix
{ config, pkgs, ... }:

{
  programs.nixcord = {
    # 1. ENABLE NIXCORD SYSTEM-WIDE
    enable = true;

    # 2. SPECIFY YOUR USERNAME (CRITICAL FOR SYSTEM CONFIG)
    user = "ratz"; # Replace with your actual username

    # 3. CHOOSE YOUR CLIENT MODIFICATION
    discord.vencord.enable = true; # Standard Vencord
    # discord.equicord.enable = true; # Alternative: Equicord (has more plugins)

    # 4. CONFIGURE PLUGINS AND THEMES
    config = {
      # Enable QuickCSS inside Vencord/Equicord
      useQuickCss = true;

      plugins = {
        fakeNitro.enable = true;
      };
    };

    # 5. CUSTOM FONT OVERRIDE VIA QUICKCSS
    quickCss = ''
      :root {
        --font-primary: "Consoleet Terminus\-32 Smooth", sans-serif;
        --font-headline: "Consoleet Terminus\-32 Smooth", sans-serif;
        --font-code: "Consoleet Terminus\-32 Smooth", monospace;
      }
    '';
  };
}
