#!/usr/bin/env bash

openwrt_version="17.01.2"
builder_dir="lede-imagebuilder-$openwrt_version-ar71xx-generic.Linux-x86_64"
configs_dir="./configs"

host="$1"
[ -n "$host" ] || { echo "No host selected"; exit 1; }

host_profile_file="$configs_dir/$host/profile"
host_pkgs_file="$configs_dir/$host/pkgs"
host_files_dir="$configs_dir/$host/files"

[ -f "$host_profile_file" -a -f "$host_pkgs_file" -a -d "$host_files_dir" ] || { echo "Invalid host configurateion"; exit 2; }

out_dir="$(readlink -f "$builder_dir/bin/$host")"

make -C "$builder_dir"  image BIN_DIR="$out_dir" PROFILE="$(cat "$host_profile_file")" PACKAGES="$(cat "$host_pkgs_file" | tr '\n' ' ')" FILES="$(readlink -f "$host_files_dir")/"


echo
echo "--------------------"
echo

img="$(ls "$builder_dir/bin/$host/lede-$openwrt_version-ar71xx-generic-"*"-squashfs-sysupgrade.bin")"
echo "Image: [$img]"
