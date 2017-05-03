#!/usr/bin/env bash
set -e

iso=${1:?iso argument missing}

mntdir=$(mktemp -d)
tmpdir=$(mktemp -d)
isodir=$tmpdir/iso
squashfsdir=$tmpdir/squashfs

echo "Mount ISO"
mount -t iso9660 -o loop $iso $mntdir
echo "Copy ISO content to $isodir..."
cp -a $mntdir $isodir
umount $mntdir
rmdir $mntdir
echo "Copy SquashFS content to $squashfsdir..."
unsquashfs -d $squashfsdir $isodir/live/filesystem.squashfs

onexit()
{
  echo "Cleaning..."
  rm -r $tmpdir
}

trap onexit EXIT

echo "Dropping you into a shell"
( cd $tmpdir
  bash
)

echo "Replacing filesystem.squashfs..."
rm $isodir/live/filesystem.squashfs
mksquashfs $squashfsdir $isodir/live/filesystem.squashfs
echo "Generating iso..."
genisoimage -l -r -J -V "DebianAltered" -b isolinux/isolinux.bin \
            -no-emul-boot -boot-load-size 4 -boot-info-table \
            -c isolinux/boot.cat -o output.iso $isodir

