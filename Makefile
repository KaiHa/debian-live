tmp_dir := ./.build.tmp
nitrokey_app := https://www.nitrokey.com/sites/default/files/app/nitrokey-app-0.2-debian-jessie-amd64.deb

build: download
	lb config
	sudo lb build

download: config/packages.chroot/nitrokey-app_0.2_amd64.deb
	# VOID

config/packages.chroot/nitrokey-app_%.deb:
	cd config/packages.chroot &&  \
	wget $(nitrokey_app) && \
	dpkg-name *.deb

# If it should go fast you can build the image in a tmpfs partition. This will
# use lots of memory. You have been warned!
fast-build:
	mkdir -p $(tmp_dir)
	sudo mount -t tmpfs -o size=9G  tmpfs $(tmp_dir)
	sudo cp -r * $(tmp_dir)
	cd $(tmp_dir) && sudo lb config && sudo lb build
	-cp $(tmp_dir)/build.log .
	cp $(tmp_dir)/live-image-*.hybrid.iso .
	sudo umount $(tmp_dir)

# If the fast-build fails you have to manually unmount the tmpfs. You can use
# this target for this.
umount-tmpfs:
	-sudo umount $(tmp_dir)/chroot/dev/pts
	-sudo umount $(tmp_dir)/chroot/proc
	-sudo umount $(tmp_dir)/chroot/sys
	sudo umount $(tmp_dir)
