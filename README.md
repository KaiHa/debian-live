debian-live
===========

Configuration for a Debian live system. With this configuration it should be
possible to create a Debian live ISO-image on a Debian 8 (Jessie)
system.

Building a CD
-------------

You need the *live-build* tools. You can install them by this command:
```
$ aptitude install live-build
```

In the directory where you have this configuration, you can build the image by
this commands:
```
$ lb config
$ sudo lb build
```

Or simply by calling `make`.

The resulting ISO can be dumped on a USB thumb drive. Be careful when doing this,
if you give to `of=` the wrong device you may destroy data.
```
$ sudo dd bs=4096 if=live-image*.hybrid.iso of=/dev/sdX
```

Persistence
-----------

Persistence is enabled by default. Whenever you want to boot with persistence
disabled, you have to remove `persistence` of the commandline in the boot
menu.

For persistence to work you need an persistence partition with an
persistence.conf file. For example, if you want a persistent /home folder you
can create in the remaining space of the USB thumb drive an extra partition
with the label `persistence`. Add to this partition a file `persistence.conf`
with the following content.
```
/home union
```
There is also a small script that will create a persistence partition for you. In addition it will create one data partition that is also accessible by Windows PCs. You can use the script like this:
```
runhaskell CopyToUsbDrive.hs live-image.iso /dev/sdX
```

User and password
-----------------

Name: `user`
Password: `live`

Speeding up successive builds
-----------------------------

If you want/need to build the image more than once, you can speed things up by installing *approx*. Here is what my `/etc/approx/approx.conf` looks like:
```
debian		http://ftp.de.debian.org/debian
```
And in `/etc/live/build.conf` I have added this line:
```
LB_MIRROR_BOOTSTRAP="http://localhost:9999/debian"
```

Other resources
---------------

More and much better configurations can be found at the [git
repository](http://live-systems.org/gitweb/?p=live-images.git) of the
live-build project itself.

Ready-made images are also available at [live-system.org](http://live-systems.org/cdimage/).
Sadly there are not always images available of the sid/testing distribution.
