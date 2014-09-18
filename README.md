debian-live
===========

Configuration for a Debian live system. With this configuration it should be
possible to create a Debian live ISO-image on a current Debian jessie/testing
system.

You need the live-build tools. You can install them by this command:
```
$ aptitude install live-build
```

In the directory where you have this configuration, you can build the image by
this commands:
```
$ lb config
$ sudo lb build
```

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

User and password
-----------------

Name: `user`
Password: `live`

Other resources
---------------

More and much better configurations can be found at the [git
repository](http://live-systems.org/gitweb/?p=live-images.git) of the
live-build project itself.

Ready-made images are also available at [live-system.org](http://live-systems.org/cdimage/).
Sadly there are not always images available of the sid/testing distribution.

