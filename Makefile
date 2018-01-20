tmp_dir := ./.build.tmp
gsettings_script := config/includes.chroot/lib/live/bin/gnome-settings.sh

build: config/includes.chroot/etc/wlan.password.gpg check-root
	lb config
	lb build

# If it should go fast you can build the image in a tmpfs partition. This will
# use lots of memory. You have been warned!
fast-build: config/includes.chroot/etc/wlan.password.gpg check-root
	mkdir -p $(tmp_dir)
	mount -t tmpfs -o size=9G  tmpfs $(tmp_dir)
	cp -r * $(tmp_dir)
	cd $(tmp_dir) && lb config && lb build
	-cp $(tmp_dir)/build.log .
	cp $(tmp_dir)/live-image-*.hybrid.iso .
	umount $(tmp_dir)

config/includes.chroot/etc/wlan.password.gpg:
	cp ../wlan.password.gpg config/includes.chroot/etc/wlan.password.gpg

check-root:
	test "$$(whoami)" = "root"
.PHONY: check-root

# If the fast-build fails you have to manually unmount the tmpfs. You can use
# this target for this.
umount-tmpfs:
	-umount $(tmp_dir)/chroot/dev/pts
	-umount $(tmp_dir)/chroot/proc
	-umount $(tmp_dir)/chroot/sys
	umount $(tmp_dir)

clean:
	rm -rf .build/
	rm -rf binary/
	rm -rf build.log
	rm -rf cache/
	rm -rf chroot.files
	rm -rf chroot.packages.install
	rm -rf chroot.packages.live
	rm -rf chroot/
	rm -rf config/binary
	rm -rf config/bootstrap
	rm -rf config/build
	rm -rf config/chroot
	rm -rf config/common
	rm -rf config/hooks/
	rm -rf config/includes.bootstrap/
	rm -rf config/includes.source/
	rm -rf config/includes/
	rm -rf config/source
	rm -rf live-image-*.contents
	rm -rf live-image-*.files
	rm -rf live-image-*.hybrid.iso
	rm -rf live-image-*.hybrid.iso.zsync
	rm -rf live-image-*.packages
