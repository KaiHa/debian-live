debian-live
===========

Configuration for a Debian live system. With this configuration it should be possible to create a Debian live iso-image on a current Debian jessie/testing system.

You need the live-build tools. You can install them by this command:
```
$ aptitude install live-build
```

In the directory where you have this configuration, you can build the image by this commands:
```
$ lb config
$ sudo lb build
```
