# mender-convert-compulab

## Prepare the source code

* Creat a work dir:
```
mkdir work-dir && cd work-dir
```

* Clone/Initialize the repository
```
git clone --recursive https://github.com/compulab-yokneam/mender-convert-compulab.git
```

## Before the start

* Make and install the mender-artifact:
```
make -j 16 -C mender-artifact
sudo cp mender-artifact/mender-artifact /usr/bin/
```

* Create a symlink to a Debian image file:
```
ln -s /full/path/to/debian-bookworm-arm64.img mender-convert/input/debian-bookworm-arm64.img
```

## Run the converter
```
sudo ./scripts/mender-convert-compulab.sh
```
