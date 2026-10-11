{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ fish ];

    # Enable fish configuration options if desired (optional, but useful for features like man-page completions)
  programs.fish = {
    enable = true;
    shellAliases = {
    nsh = "nix-shell --run fish -p";
    };
    interactiveShellInit = ''
    set -g fish_greeting ""

    function fish_prompt
      if test -n "$IN_NIX_SHELL"
        set_color blue
        echo -n "nsh"
        set_color normal
        echo -n "@$hostname"
      else
        set_color green
        echo -n "$USER"
	set_color normal
	echo -n "@$hostname"
      end

      echo -n (prompt_pwd)
      echo -n "> "
    end
  

  '';
  };
  # Add fish to the list of globally available shells
  environment.shells = with pkgs; [ fish bash ];

  # Optional: Set the default shell for all users
  users.defaultUserShell = pkgs.fish; #
  # Or, if you have a config file in your dotfiles repository:
  # environment.etc."alacritty/alacritty.toml".source = ./dotfiles/alacritty.toml;
}
