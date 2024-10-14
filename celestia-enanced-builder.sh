#!/bin/sh

packagename=$(curl -Ls https://download.opensuse.org/repositories/home:/munix9/AppImage/ | tr '">< ' '\n' | grep -i "^celestia.*[0-9].*x86_64.*appimage$")

# Create and extract the "tmp" directory
mkdir -p tmp && cd tmp || exit 1

# Download "appimagetool"
if ! test -f ./appimagetool; then
	wget -q https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage -O appimagetool
	chmod a+x appimagetool
fi

# Download and extract the original AppImage
if ! test -f ./celestia-origin; then
	wget -q "https://download.opensuse.org/repositories/home:/munix9/AppImage/$packagename" -O ./celestia-origin
	chmod a+x celestia-origin && ./celestia-origin --appimage-extract
fi

# Download the enancements
if ! test -d ./Celestia-appimage; then
	rm -R -f ./squashfs-root/usr/share/celestia/textures/medres ./squashfs-root/usr/share/celestia/textures/hires/* ./squashfs-root/usr/share/celestia/textures/lores
	git clone https://github.com/ivan-hc/Celestia-appimage.git
	rsync -av Celestia-appimage/textures/hires/* ./squashfs-root/usr/share/celestia/textures/hires/
	cd ./squashfs-root/usr/share/celestia/textures/
	ln -s hires lores
	ln -s hires medres
	cd -
fi

# Export to AppImage
ARCH=x86_64 ./appimagetool --comp zstd --mksquashfs-opt -Xcompression-level --mksquashfs-opt 20 ./squashfs-root
released_package=$(echo "$packagename" | sed 's/celestia/Celestia-Enanced/g')
mv ./*AppImage ./"$released_package"