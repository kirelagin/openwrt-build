#!/usr/bin/env bash

openwrt_version="22.03.5"
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
version_target="${openwrt_version:+$openwrt_version-}${target}"
profile=$(cat "$host_target_file" | tail -n +2 | tail -n 1)

builder_dir="$TMPDIR/openwrt-imagebuilder-$version_target.Linux-x86_64"
echo "Expecting builder at $builder_dir"
if [ ! -d "$builder_dir" ]; then
  if [ -z "$openwrt_version" ]; then
    generator_url="https://downloads.openwrt.org/snapshots/targets/${target/-/\/}/openwrt-imagebuilder-$version_target.Linux-x86_64.tar.xz"
  else
    generator_url="https://downloads.openwrt.org/releases/$openwrt_version/targets/${target/-/\/}/openwrt-imagebuilder-$version_target.Linux-x86_64.tar.xz"
  fi
  echo "Image generator is missing, downloading it from $generator_url"
  curl -f -C - -o "$builder_dir".tar.xz "$generator_url" || { echo "Could not download the generator"; exit 2; }
  tar -xf "$builder_dir.tar.xz" -C "$TMPDIR" || { echo "Could not extract the generator"; exit 2; }
fi
[ -d "$builder_dir" ] || { echo "AAAAAAAAAAAAAAA"; exit 2; }

out_dir="$(readlink -f "$builder_dir/bin/$host")"
img_file="$builder_dir/bin/$host/openwrt-$version_target-$profile-squashfs-sysupgrade.bin"

rm -f "$img_file"
make -C "$builder_dir"  image BIN_DIR="$out_dir" PROFILE="$profile" PACKAGES="$(cat "$host_pkgs_file" | tr '\n' ' ')" FILES="$(readlink -f "$host_files_dir")/"


echo
echo "--------------------"
echo

echo "Image: [$img_file]"
if [ -s "$img_file" ]; then
  shasum -a 256 "$img_file"
else
  echo "FAIL: image is missing"
  echo "(if you are building this image for the first time, run this shitty script again)"
  exit 1
fi
