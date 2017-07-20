#!/usr/bin/env bash

openwrt_version="17.01.2"
configs_dir="./configs"

host="$1"
[ -n "$host" ] || { echo "No host selected"; exit 1; }

host_target_file="$configs_dir/$host/target"
host_pkgs_file="$configs_dir/$host/pkgs"
host_files_dir="$configs_dir/$host/files"


[ -s "$host_target_file" ] || { echo "Host target file ($host_target_file) is missing or empty"; exit 2; }
[ -f "$host_pkgs_file" ]   || { echo "Host packages file ($host_pkgs_file) is missing"; exit 2; }
[ -d "$host_files_dir" ]   || { echo "Host files directory ($host_files_dir) is missing"; exit 2; }

target=$(cat "$host_target_file" | head -n 1)
profile=$(cat "$host_target_file" | tail -n +2 | tail -n 1)
builder_dir="lede-imagebuilder-$openwrt_version-$target.Linux-x86_64"
out_dir="$(readlink -f "$builder_dir/bin/$host")"
img_file="$builder_dir/bin/$host/lede-$openwrt_version-$target-$profile-squashfs-sysupgrade.bin"

rm -f "$img_file"
make -C "$builder_dir"  image BIN_DIR="$out_dir" PROFILE="$profile" PACKAGES="$(cat "$host_pkgs_file" | tr '\n' ' ')" FILES="$(readlink -f "$host_files_dir")/"


echo
echo "--------------------"
echo

if [ -s "$img_file" ]; then
  echo "Image: [$img_file]"
else
  echo "FAIL"
  exit 1
fi
