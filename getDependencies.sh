#!/bin/bash
set -ex
cd "$(dirname "${0}")/.."

sudo apt-get update

sudo apt-get install -y  \
	rsync \
	wget \
	unzip \
	git \
	imagemagick \
	xclip \
	libglu1-mesa-dev \
	libgl1-mesa-dev \
	libsdl1.2-dev \
	mingw-w64 \
	build-essential \


mkdir -p dependencies
cd dependencies

# Getting SDL
if [ ! -d SDL* ]; then
	pushd .
	wget https://www.libsdl.org/release/SDL-1.2.15.tar.gz -O- | tar xfz -
	cd SDL*
	./configure \
		--bindir=/usr/i686-w64-mingw32/bin \
		--libdir=/usr/i686-w64-mingw32/lib \
		--includedir=/usr/i686-w64-mingw32/include \
		--host=i686-w64-mingw32 \
		--prefix=/usr/i686-w64-mingw32 \
		CPPFLAGS="-I/usr/i686-w64-mingw32/include" \
		LDFLAGS="-L/usr/i686-w64-mingw32/lib"
	make
	sudo make install
	popd
fi

# Getting zlib
if [ ! -d zlib* ]; then
	pushd .
	wget http://zlib.net/fossils/zlib-1.2.12.tar.gz -O- | tar xfz -
	cd zlib*
	host="i686-w64-mingw32"
	prefixdir="/usr/i686-w64-mingw32"
	sudo make -f win32/Makefile.gcc \
		BINARY_PATH=$prefixdir/bin \
		INCLUDE_PATH=$prefixdir/include \
		LIBRARY_PATH=$prefixdir/lib \
		SHARED_MODE=1 \
		PREFIX=$host- \
		install
	popd
fi

# Getting libpng
if [ ! -d l*png* ]; then
	pushd .
	wget http://downloads.sourceforge.net/project/libpng/libpng16/1.6.37/libpng-1.6.37.tar.gz -O- | tar xfz -
	cd l*png*
	./configure \
		--host=i686-w64-mingw32 \
		--prefix=/usr/i686-w64-mingw32 \
		CPPFLAGS="-I/usr/i686-w64-mingw32/include" \
		LDFLAGS="-L/usr/i686-w64-mingw32/lib"
	make
	sudo make install
	popd
fi

# Getting freetype (CJK font rendering for minorGems/game/Font.cpp)
# Installed to a LOCAL prefix (not the sysroot) so no sudo is needed;
# Makefile.MinGWCross points -I/-L at /mnt/d/root/dependencies/freetype_mingw.
if [ ! -d freetype_mingw ]; then
	pushd .
	wget https://download.savannah.gnu.org/releases/freetype/freetype-2.13.2.tar.gz -O- | tar xfz -
	cd freetype-2.13.2
	./configure \
		--host=i686-w64-mingw32 \
		--prefix=/mnt/d/root/dependencies/freetype_mingw \
		--enable-static \
		--disable-shared \
		--without-harfbuzz \
		--without-bzip2 \
		--with-png=no \
		--with-zlib=no
	# CCexe=gcc: build the host tool `apinames` with the NATIVE gcc, not the
	# cross compiler. Default CCexe=$(CC) builds apinames as a Windows exe that
	# cannot run under WSL, failing with "could not open objs/ftexport.sym".
	make CCexe=gcc
	make install
	popd
fi

# Getting discord_game_sdk
if [ ! -d discord_game_sdk ]; then
	wget https://dl-game-sdk.discordapp.net/3.2.1/discord_game_sdk.zip
	unzip -d discord_game_sdk discord_game_sdk.zip
	rm discord_game_sdk.zip
fi
