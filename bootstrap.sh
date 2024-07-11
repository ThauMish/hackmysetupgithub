#!/bin/bash

## nix-shell -p btrfs-progs bat lsof gum --run "bash <(curl -L https://upload.dawan.fr/os/nixos/bootstrap.sh)

## TODO
### function to manage lvm onto the nix configuration files 

set -e

# Variables
DISK="nvme0n1"
EFI_PART_SIZE="1024MiB"
BOOT_PART_SIZE="4GiB"
LUKS_PART="CDISK1"
LUKS_NAME="luks_lvm"
NIX_CONFIG_URL="https://upload.dawan.fr/os/nixos/nix/"
NIX_CONFIG_PATH="/mnt/etc/nixos/"
GIT_FLAKES_REPO_URL="https://gitlab.dawan.fr/publicentry/hackmysetup.git"
GIT_FLAKES_REPO_NAME="hackmysetup"

###############
## ATTENTION ##
# Only the size can be changed.
# Don't change the names(root,home,var,swap) => TODO
###############
declare -a lv_info=("root:100G"
                    "home:500G"
                    "var:100G"
                    "swap:66G")
###############


reset && gum style \
	--foreground 150 --border-foreground 150 --border double \
	--align center --width 50 --margin "1 2" --padding "2 4" \
	'Hack my setup!' 'Devops toolbox by NIXOS'

gum spin --spinner dot --title "Cleaning windows..." -- sleep 4 && reset
gum log -t layout -s -l warn "Enter the passphrase(used by cryptsetup)"
PASSPHRASE=$(gum input --password --placeholder "default passphrase" --value "roottoor")
gum log -t layout -s -l warn "Enter the username"
USER=$(gum input --placeholder "Le boss" --value "damien")
gum log -t layout -s -l warn "Enter the password for $USER"
RAWPASSWORD=$(gum input --password --placeholder "default password" --value "roottoor")
PASSWORD=$(mkpasswd -m sha-512 $RAWPASSWORD)
gum log -t layout -s -l warn "Enter the GIT username"
GITUSER=$(gum input --placeholder "Le boss" --value "$USER")
gum log -t layout -s -l warn "Enter the GIT email"
GITEMAIL=$(gum input --placeholder "Le boss" --value "$USER@dawan.fr")
gum log -t layout -s -l warn "Enter the hostname"
HOST=$(gum input --placeholder "DreamTeam" --value "pc-damien")
gum spin --spinner dot --title "Cleaning windows..." -- sleep 2 && reset

FLAKES_CONFIG_PATH="/mnt/etc/nixos/$GIT_FLAKES_REPO_NAME/host/$HOST"

setup_flask(){
  cd $NIX_CONFIG_PATH
  git clone $GIT_FLAKES_REPO_URL --depth=1 $GIT_FLAKES_REPO_NAME
  cp -r $GIT_FLAKES_REPO_NAME/hosts/dawan $FLAKES_CONFIG_PATH || gum log -t layout -s -l warn "No default flakes repo($GIT_FLAKES_REPO_NAME/hosts/dawan)"
  reset && echo '# Process to apply after reboot:
  ```sh
  nixos-generate-config --show-hardware-config > hosts/$HOST/hardware.nix.new
  diff \
    <(cat /etc/nixos/hackmysetup/$HOST/hardware.nix.new) \
    <(cat /etc/nixos/hackmysetup/$HOST/hardware.nix) |\
    bat
  ```
  > Please take care of the `mountpoint / disk / modules / kernel`
  > Contrôl the personnal values: `/etc/nixos/hackmysetup/host/*/variables.nix`

  # To launch the final setup
  ```sh
  sudo nixos-rebuild switch --flake .#$HOST
  ```
  '| gum format -t markdown

  gum confirm "Continue?" || ( echo "End of script" && exit 1 )

}


# Préparation du disque et configuration LUKS/LVM
setup_disk() {

  gum log -t layout -s -l warn "Starting process"
  gum confirm "The process will destroy all the data(disk=$DISK). Are you ok?" || ( echo "End of script" && exit 1 )

  cryptsetup erase /dev/disk/by-partlabel/${LUKS_PART} || gum log -t layout -s -l info "No LUKS's artefact to erase"

  gum log -t layout -s -l debug "Remove old artefact(LUKS/LVM)."
  umount /dev/${DISK}* || gum log -t layout -s -l info "No partition found"
  for part in $(ls /dev/${DISK}*); do
    umount $part || gum log -t layout -s -l info "No partition to umount"
  done
  wipefs -af /dev/disk/by-partlabel/${LUKS_PART} || gum log -t layout -s -l info "No artefact to wipe"
  gum log -t layout -s -l debug "Configuration du disque et LUKS/LVM..."
  wipefs -af "/dev/$DISK"
  sgdisk --zap-all "/dev/$DISK"
  partprobe "/dev/$DISK"
  sgdisk --clear \
    --new=1:0:+${EFI_PART_SIZE} --typecode=1:ef00 --change-name=1:EFI \
    --new=2:0:+${BOOT_PART_SIZE} --typecode=2:8300 --change-name=2:BOOT \
    --new=3:0:0 --typecode=3:8309 --change-name=3:${LUKS_PART} "/dev/$DISK" && gum log -t layout -s -l info "[PARTITION: completed]"
  partprobe "/dev/$DISK"
  gum spin --spinner dot --title "Waiting..." -- sleep 5

  mkfs.vfat -F32 -n EFI /dev/disk/by-partlabel/EFI && gum log -t layout -s -l info "[FORMATAGE: FAT(EFI)]"
  mkfs.ext4 -L BOOT /dev/${DISK}p2

  echo -n "${PASSPHRASE}" | cryptsetup luksFormat \
      --verbose \
      --type luks2 \
      --align-payload 8192 \
      --pbkdf argon2id \
      --iter-time 5000 \
      --key-size 256 \
      --cipher aes-xts-plain64 \
      /dev/disk/by-partlabel/${LUKS_PART} -

  cryptsetup luksDump /dev/disk/by-partlabel/${LUKS_PART}
  echo -n "${PASSPHRASE}" | cryptsetup open /dev/disk/by-partlabel/${LUKS_PART} ${LUKS_NAME} \
      && gum log -t layout -s -l info "[ENCRYPT]: ${LUKS_PART}(${LUKS_NAME})"

  gum confirm "Everything is correct?" || ( echo "End of script" && exit 1 )

  pvcreate --dataalignment 4M /dev/mapper/${LUKS_NAME} && gum log -t layout -s -l info "[LVM]: add PV"
  vgcreate nixos /dev/mapper/${LUKS_NAME}  && gum log -t layout -s -l info "[LVM]: create VG"

  set -x
  for lv in "${lv_info[@]}"
  do
      lvcreate --name "${lv%%:*}" --size "${lv#*:}" nixos && gum log -t layout -s -l info "[LVM]: create LV(${lv%%:*})"
  done
  set +x

  gum confirm "Everything is correct?" || ( echo "End of script" && exit 1 ) 

  pvs && vgs && lvs

  gum confirm "Everything is correct?" || ( echo "End of script" && exit 1 ) 

  gum spin --spinner line --title "Cleaning in 5s.." -- sleep 5 && reset

  mkswap --label SWAP /dev/mapper/nixos-swap
  mkfs.ext4 -L ROOT /dev/nixos/root
  mkfs.ext4 -L VAR /dev/nixos/var

  OPTS=defaults,x-mount.mkdir,noatime,nodiratime,ssd,compress=zstd
  mkfs.btrfs -q --nodiscard --label HOME /dev/nixos/home
  mount -o $OPTS /dev/mapper/nixos-home /mnt
  btrfs subvolume create /mnt/@home
  # timeshift / snapper
  umount /mnt
  gum log -t layout -s -l info "Mounting partitions"
  set -x
  mount --mkdir -o $OPTS,subvol=@home    /dev/mapper/nixos-home       /mnt/home
  mount --mkdir /dev/nixos/root /mnt/
  mount --mkdir /dev/nixos/var /mnt/var
  mount --mkdir /dev/${DISK}p2 /mnt/boot
  mount --mkdir /dev/${DISK}p1 /mnt/boot/efi
  swapon /dev/nixos/swap
  lsblk
  set +x && gum confirm "Everything is correct?" || ( echo "End of script" && exit 1 )
  gum spin --spinner dot --title "Cleaning windows..." -- sleep 2 && reset

}

# Configuration du fichier de clé LUKS
configure_luks_keyfile() {
  gum log -t layout -s -l info "Init the key used by LUKS..."
  dd if=/dev/urandom of=/mnt/crypto_keyfile.bin bs=512 count=4
  echo -n "${PASSPHRASE}" | cryptsetup luksAddKey /dev/disk/by-partlabel/${LUKS_PART} /mnt/crypto_keyfile.bin
  mv /mnt/crypto_keyfile.bin /mnt/boot/crypto_keyfile.bin
  chmod 600 /mnt/boot/crypto_keyfile.bin
}

# Génération de la configuration NixOS
generate_nixos_config() {
  gum log -t layout -s -l info "Generate configuration files of NixOS..."
  nixos-generate-config --root /mnt
  setup_flask
  curl -o ${NIX_CONFIG_PATH}configuration.nix "${NIX_CONFIG_URL}configuration.nix.tpl" \
    && curl -o  ${NIX_CONFIG_PATH}hardware-configuration.nix "${NIX_CONFIG_URL}hardware-configuration.nix.tpl" \
    && curl -o ${NIX_CONFIG_PATH}variables "${FLAKES_CONFIG_PATH}variables.tpl" \
    && gum spin --spinner points --title "Downloading NIX's files" -- sleep 2 && reset

  sed -i "s|__DISK__|$DISK|g" ${NIX_CONFIG_PATH}configuration.nix \
    && sed -i "s|__EMAIL__|$GITEMAIL|g" ${FLAKES_CONFIG_PATH}/variables.nix \
    && sed -i "s|__USERNAME__|$GITUSER|g" ${FLAKES_CONFIG_PATH}/variables.nix \
    && sed -i "s|__USER__|$USER|g" ${NIX_CONFIG_PATH}configuration.nix \
    && sed -i "s|__PASSWORD__|${PASSWORD}|g" ${NIX_CONFIG_PATH}configuration.nix \
    && sed -i "s|__HOST__|$HOST|g" ${NIX_CONFIG_PATH}configuration.nix \
    && sed -i "s|__DISK__|$DISK|g" ${NIX_CONFIG_PATH}hardware-configuration.nix \
    && gum spin --spinner points --title "Generate NIX configuration file" -- sleep 2 && reset

  diff \
    <(curl -s ${NIX_CONFIG_URL}configuration.nix.tpl) \
    <(cat ${NIX_CONFIG_PATH}configuration.nix) |\
    bat

  diff \
    <(curl -s ${NIX_CONFIG_PATH}hardware-configuration.nix.tpl) \
    <(cat ${NIX_CONFIG_PATH}hardware-configuration.nix) |\
    bat
  
  #nixos-generate-config --show-hardware-config

  gum confirm "Everything is correct?" || ( echo "End of script" && exit 1 )
}

# Installation de NixOS
install_nixos() {
  gum log -t layout -s -l info "Setup NixOS..."
  gum log -t layout -s -l warn "This process can take a long time(10 minutes)"
  gum spin --spinner dot --title "Cleaning windows..." -- sleep 4 && reset
  time nixos-install --no-root-password --cores 0 --max-jobs auto --root /mnt
}

# Exécution des fonctions
# setup_disk
# configure_luks_keyfile
generate_nixos_config
install_nixos


gum log -t layout -s -l info "Setup done successfuly."

gum confirm "Are you ok to reboot?" && reboot || ( echo "End of script" && exit 1 ) 
