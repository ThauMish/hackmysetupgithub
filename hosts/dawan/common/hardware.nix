{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
    initrd.kernelModules = [ "dm-snapshot" ];
    kernelModules = [ "kvm-intel" ];
    initrd.luks.devices = {
      root = {                                             
        device = "/dev/nvme0n1p3";                                                 
        preLVM = true;                                                             
        allowDiscards = true;                                                      
      };                                                                           
    };                                                
  };                                                                                                       
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  networking.useDHCP = lib.mkDefault true;


  fileSystems."/" = {
    device = "/dev/mapper/nixos-root";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/__DISK__p2";
    fsType = "ext4";
  };

  fileSystems."/boot/efi" = {
    device = "/dev/__DISK__p1";
    fsType = "vfat";
  };

  fileSystems."/home" = {
    device = "/dev/mapper/nixos-home";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress=zstd" "noatime" "nodiratime" "ssd" ];
    #options = [ "subvol=@home" "compress=zstd" "defaults" "x-mount.mkdir" "noatime" "nodiratime" "ssd" ];
    #neededForBoot = true;
  };

  fileSystems."/var" = {
    device = "/dev/mapper/nixos-var";
    fsType = "ext4";
  };

  swapDevices = [
    {
      device = "/dev/mapper/nixos-swap";
    }
  ];

}
