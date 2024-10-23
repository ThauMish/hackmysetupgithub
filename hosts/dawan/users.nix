{
  pkgs,
  username,
  ...
}:

let
  inherit (import ./common/variables.nix) gitUsername;
in
{
  users.users = {
    "${username}" = {
      homeMode = "755";
      isNormalUser = true;
      description = "${gitUsername}";
      createHome = true;
      shell = pkgs.zsh;
      home = "/home/${username}";
      extraGroups = [
        "networkmanager"
        "wheel"
        "libvirtd"
        "scanner"
        "lp"
        "$username"
      ];
      hashedPassword = "__PASSWORD__";
      packages = with pkgs; [
        firefox
        chromium
        neovim
        vlc
        gnomeExtensions.appindicator
        gnomeExtensions.dash-to-dock
        gnomeExtensions.caffeine
        flat-remix-icon-theme
        eza
        btrfs-assistant
        zsh
        bat
        nerdfonts
        git
      ];
    };
  };
}
