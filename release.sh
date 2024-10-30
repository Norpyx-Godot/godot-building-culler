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

echo "---"

bump_type=$(echo $1 | grep -oP '(major|minor|patch|bump)')
new_pre_type=$(echo $1 | grep -oP '(pre|rc)')

echo "Bump type: $bump_type"
echo "New Pre/RC Type: '$new_pre_type'"

echo "---"

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

# Version Info
echo "New version: $new_version"

echo "---"

# Update version in plugin.cfg
sed -i "s/version=\"$current_version\"/version=\"$new_version\"/" plugin.cfg

# Commit changes
git add plugin.cfg
git commit -m "Release $new_version"
git tag -a $new_version -m "Release $new_version"

echo "---"
echo "Populating build directory"

# Build and deploy
build_dir="build"
dest_dir="$build_dir/addons/building_culler"

rm -rf $build_dir
mkdir -p $dest_dir

cp_code=0
files=(assets nodes building_culler.gd LICENSE plugin.cfg README.md)
for file in "${files[@]}"; do
	if [ -d $file ]; then
		echo "Copying directory '$file'"
		cp -r $file $dest_dir
		cp_code=$?
	elif [ -f $file ]; then
		echo "Copying file '$file'"
		cp $file $dest_dir
		cp_code=$?
	fi

	if [ $cp_code -ne 0 ] || [ ! -f $file ] && [ ! -d $file ]; then
		echo "Failed to copy '$file'"
		exit 1
	fi
done

echo "---"

echo "Building release"
dist_dir="dist"
mkdir -p $dist_dir
tar_file="$dist_dir/building_culler-$new_version.tar.gz"
zip_file="$dist_dir/building_culler-$new_version.zip"
tar -czf $tar_file -C build/ .
pushd $build_dir > /dev/null 2>&1
zip -r ../$zip_file addons/
popd > /dev/null 2>&1
if [ -f $tar_file ]; then
	echo "Release built:"
	echo "    $tar_file"
	echo "    $zip_file"
else
	echo "Failed to build release"
	exit 1
fi

echo -e "---\n\n"
echo "When you are ready to release, run the following commands:"
echo "    git push origin main --tags"
echo -e "\nDon't forget to upload the release tarball to the Godot Asset Library,"
echo "and to the Github release page:"
echo "    $tar_file"
echo "    $zip_file"
echo "    $dist_dir/icon.png"
echo "    $dist_dir/screenshot.png"

