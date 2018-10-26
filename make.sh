#!/usr/bin/env bash

openwrt_version="18.06.1"
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

builder_dir="$TMPDIR/openwrt-imagebuilder-$openwrt_version-$target.Linux-x86_64"
if [ ! -d "$builder_dir" ]; then
  generator_url="https://downloads.openwrt.org/releases/$openwrt_version/targets/${target/-/\/}/openwrt-imagebuilder-$openwrt_version-$target.Linux-x86_64.tar.xz"
  echo "Image generator is missing, downloading it from $generator_url"
  #curl -f -C - -o "$builder_dir".tar.xz "$generator_url" || { echo "Could not download the generator"; exit 2; }
  tar -xf "$builder_dir.tar.xz" -C "$TMPDIR" || { echo "Could not extract the generator"; exit 2; }
fi
[ -d "$builder_dir" ] || { echo "AAAAAAAAAAAAAAA"; exit 2; }

out_dir="$(readlink -f "$builder_dir/bin/$host")"
img_file="$builder_dir/bin/$host/openwrt-$openwrt_version-$target-$profile-squashfs-sysupgrade.bin"

rm -f "$img_file"
make -C "$builder_dir"  image BIN_DIR="$out_dir" PROFILE="$profile" PACKAGES="$(cat "$host_pkgs_file" | tr '\n' ' ')" FILES="$(readlink -f "$host_files_dir")/"


echo
echo "--------------------"
echo

if [ -s "$img_file" ]; then
  echo "Image: [$img_file]"
  shasum -a 256 "$img_file"
else
  echo "FAIL"
  exit 1
fi
