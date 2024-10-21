{
  pkgs,
  username,
  ...
}:

let
  inherit (import ./variables.nix) gitUsername;
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
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIArnSwudN1AQKbjzdJrHWgFRLdRK7JPXRyS+duxqsHVu dberaud@dawan.fr"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEFKudMkQj7ZI5SbBxwTwOHiaxte285J/0ds/GsFqZGx tballet@dawan.fr"
      ];
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
