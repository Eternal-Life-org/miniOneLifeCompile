#!/bin/bash
set -e
# 编译家园编辑器 (TownPlanner)，流程与 editor.sh 一致，产物 output/TownPlanner.exe
PLATFORM=$(cat PLATFORM_OVERRIDE)
if [[ $PLATFORM != 1 ]] && [[ $PLATFORM != 5 ]]; then PLATFORM=${1-5}; fi
if [[ $PLATFORM != 1 ]] && [[ $PLATFORM != 5 ]]; then
	echo "Usage: 1 for Linux, 5 for XCompiling for Windows (Default)"
	exit 1
fi
cd "$(dirname "${0}")/.."

##### Configure and Make
cd OneLife
./configure $PLATFORM

cd gameSource
if [[ $PLATFORM == 5 ]]; then export PATH="/usr/i686-w64-mingw32/bin:${PATH}"; fi
./makeTownplanner.sh

cd ../..


##### Create Game Folder
mkdir -p output
cd output

# 家园编辑器读取 scenes/ 下的场景文件
mkdir -p scenes

FOLDERS="animations categories ground music objects sounds sprites transitions"
TARGET="."
LINK="../OneLifeData7"
../miniOneLifeCompile/util/createSymLinks.sh $PLATFORM "$FOLDERS" $TARGET $LINK

FOLDERS="graphics otherSounds languages"
TARGET="."
LINK="../OneLife/gameSource"
../miniOneLifeCompile/util/createSymLinks.sh $PLATFORM "$FOLDERS" $TARGET $LINK

cp -rn ../OneLife/gameSource/settings .
cp ../OneLife/gameSource/us_english_60.txt .

cp ../OneLife/gameSource/reverbImpulseResponse.aiff .

cp ../OneLifeData7/dataVersionNumber.txt .

#missing SDL.dll
if [[ $PLATFORM == 5 ]] && [ ! -f SDL.dll ]; then cp ../OneLife/build/win32/SDL.dll .; fi


##### Copy to Game Folder
# 产物保持原名 TownPlanner；如需用 家园编辑器.lnk 启动，把快捷方式目标改为 TownPlanner.exe（或自行改名）
if [[ $PLATFORM == 5 ]]; then cp -f ../OneLife/gameSource/TownPlanner.exe .; fi
if [[ $PLATFORM == 1 ]]; then cp -f ../OneLife/gameSource/TownPlanner .; fi
