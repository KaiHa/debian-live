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

If you want a persistent /home folder you can create in the remaining space of
the USB thumb drive an extra partition with the label `persistence`. Add to
this partition a file `persistence.conf` with the following content.
```
/home union
```

Persistence is enabled by default. Whenever you want to boot with persistence
disabled, you have to remove `persistence` of the commandline in the boot
menu.

User and password
-----------------

Name: `user`
Password: `live`
