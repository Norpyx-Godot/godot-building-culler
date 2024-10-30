#!/usr/bin/env bash

# This script is used to release a new version of the project.

#current_version=$(grep -oP 'version="\K[0-9]+\.[0-9]+\.[0-9]+(?=")' plugin.cfg)

# Get current or pre/rc version from plugin.cfg
current_version=$(grep -oP 'version="\K[0-9]+\.[0-9]+\.[0-9]+((-pre|-rc)[0-9]+)?(?=")' plugin.cfg)

version=$(echo $current_version | grep -oP '[0-9]+\.[0-9]+\.[0-9]+')
pre_rc=$(echo $current_version | grep -oP '(-pre|-rc)[0-9]+')
pre_index=$(echo $pre_rc | grep -oP '(-pre|-rc)\K[0-9]+')
pre_type=$(echo $pre_rc | grep -oP '\-\K(pre|rc)(?=[0-9]+)')

new_version=$version

# Version Info
echo "Current version: $current_version"
echo "Version: $version"
echo "Pre/RC: $pre_rc"
echo "Pre/RC Index: $pre_index"
echo "Pre/RC Type: $pre_type"

bump_type=$(echo $1 | grep -oP '(major|minor|patch|bump)')
new_pre_type=$(echo $1 | grep -oP '(pre|rc)')

echo "Bump type: $bump_type"
echo "New Pre/RC Type: '$new_pre_type'"

# Increment version switch case
case "$bump_type" in
	"major")
		new_version=$(echo $version | awk -F. '{$1++; print $1"."0"."0}')
		;;
	"minor")
		new_version=$(echo $version | awk -F. '{$2++; print $1"."$2"."0}')
		;;
	"patch")
		new_version=$(echo $version | awk -F. '{$3++; print $1"."$2"."$3}')
		;;
	"bump")
		new_version=$version
		;;
	*)
		echo "Invalid argument. Use 'major', 'minor', or 'patch'."
		exit 1
		;;
esac

if [[ "$new_pre_type" != "" ]]; then
	if [[ "$new_version" == "$version" ]] && [[ "$new_pre_type" == "$pre_type" ]]; then
		pre_index=$(($pre_index + 1))
	else
		pre_index=1
	fi
	pre_type=$(echo $1 | grep -oP '(pre|rc)')
	pre_rc="-$pre_type$pre_index"
	new_version="$new_version$pre_rc"
fi

# Update version in plugin.cfg
echo sed -i "s/version=\"$current_version\"/version=\"$new_version\"/" plugin.cfg

# Version Info
echo "New version: $new_version"

# Commit changes
echo git add plugin.cfg
echo git commit -m "Release $new_version"
echo git tag -a $new_version -m "Release $new_version"
echo git push origin main --tags

# Build and deploy
build_dir="build/addons/building_culler"
files=(assets nodes building_culler.gd LICENSE.md plugin.cfg README.md)
mkdir -p $build_dir
for file in "${files[@]}"; do
	if [ -d $file ]; then
		echo "Copying directory '$file'"
		cp -r $file $dest
	elif [ -f $file ]; then
		echo "Copying file '$file'"
		cp $file $dest
	fi
done

echo "Building release"
dist_dir="dist"
tar -czf "$dist_dir/building_culler-$new_version.tar.gz" -C $build_dir .

