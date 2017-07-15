#!/usr/bin/env bash

openwrt_version="15.05.1"
builder_dir="OpenWrt-ImageBuilder-$openwrt_version-ar71xx-generic.Linux-x86_64"
configs_dir="./configs"

host="$1"
[ -n "$host" ] || { echo "No host selected"; exit 1; }

host_profile_file="$configs_dir/$host/profile"
host_pkgs_file="$configs_dir/$host/pkgs"
host_files_dir="$configs_dir/$host/files"

[ -f "$host_profile_file" -a -f "$host_pkgs_file" -a -d "$host_files_dir" ] || { echo "Invalid host configurateion"; exit 2; }

make -C "$builder_dir"  image PROFILE="$(cat "$host_profile_file")" PACKAGES="$(cat "$host_pkgs_file" | tr '\n' ' ')" FILES="$(readlink -f "$host_files_dir")/"


echo
echo "--------------------"
echo

echo "Root is: $builder_dir/build_dir/target-mips_34kc_uClibc-*/root-ar71xx/"
echo "Image: $builder_dir/bin/ar71xx/openwrt-$openwrt_version-ar71xx-generic-*-squashfs-sysupgrade.bin"
