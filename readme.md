# mender-convert-compulab

## Quick Start

* Ready to run images:

|SOC|Location|
|---|---|
|imx8mm|https://drive.google.com/drive/folders/1jYLXg8eHX3neP5ioLKiKVxYTx05hvwjI|
|imx8mp|https://drive.google.com/drive/folders/1DoaVligjgcbzNjdvjZvWCl6Y8pBfUkWv|

|NOTE|imx8mm platform has to have bootefi support enabled in the U-Boot|
|---|---|

* Create a mender media:

|SOC|Command|
|---|---|
|imx8mm|```xz -dc /path/to/debian.12.iot-gate-imx8-iot-gate-imx8-mender.img.xz \| sudo dd of=/dev/sdX bs=1M status=progress```|
|imx8mp|```xz -dc /path/to/debian-bookworm-arm64-buildd.compulab-imx8mp-6.6.52-compulab-1.3-rw-gpt-sdcard-compulab-imx8mp-mender.img.xz \| sudo dd of=/dev/sdX bs=1M status=progress```|


* How to deploy to the internal media:

```
DST=/dev/mmcblk2 sudo -E cl-deploy
```

## Development Guide

### Prepare the source code

* Creat a work dir:
```
mkdir work-dir && cd work-dir
```

* Clone/Initialize the repository
```
git clone --recursive https://github.com/compulab-yokneam/mender-convert-compulab.git
```

### Before the start

* Make and install the mender-artifact:
```
make -j 16 -C mender-artifact
sudo cp mender-artifact/mender-artifact /usr/bin/
```

* Create a symlink to a Debian image file:
```
ln -s /full/path/to/debian-bookworm-arm64.img mender-convert/input/debian-bookworm-arm64.img
```

### Run the converter

* Default run:
```
sudo ./scripts/mender-convert-compulab.sh
```

* Use a different MACHINE_CONSOLE:
```
MACHINE_CONSOLE="console=ttymxc2,115200" \
sudo -E ./scripts/mender-convert-compulab.sh
```

* Use different image location:
```
IMAGE=/full/path/to/debian-bookworm-arm64.img \
sudo -E ./scripts/mender-convert-compulab.sh
```

* CompuLab imx8mm sample run:
```
MACHINE_BOOTSCRIPT="Yes" \
IMAGE=/path/to/debian.12.iot-gate-imx8.img \
MACHINE_CONSOLE="console=ttymxc2,115200 earlycon=ec_imx6q,0x30880000,115200" \
sudo -E ./scripts/mender-convert-compulab.sh
```
