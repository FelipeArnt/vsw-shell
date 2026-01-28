#!/usr/bin/env bash

init_configs() {

  local pendrive=/dev/sdb1
  local distro=~/Downloads/EndeavourOS_Ganymede-Neo-2026.01.12.iso

  printf "\n [vsw-flash]: Procurando pendrive...\n"
  lsblk && lsblk | grep sdb1

  #sudo umount /dev/sdb*

  printf "\n[vsw-flash]: Distro linux encontrada:$distro \n"
  printf "\n[vsw-flash]: localização do pendrive $pendrive \n"
}

flash-iso() {
  printf "\n[vsw-flash]: Prosseguir com a instalação?"
  read -r VAR

  if [[ $VAR == 1 ]]; then
    command -v sudo dd bs=4M if=/$distro of=/dev/$pendrive status=progress oflag=sync
  fi

}

init_configs
flash-iso
