#!/bin/bash

spinner_pid=
function start_spinner {
    set +m
    echo -n "         "
    { while : ; do for X in '◐' '◓' '◑' '◒'; do echo -en "\r[$X] $1" ; sleep 0.1 ; done ; done & } 2>/dev/null
    spinner_pid=$!
}

function stop_spinner {
    { kill -9 $spinner_pid && wait; } 2>/dev/null
    set -m
    echo -en "\033[2K\r"
}

trap stop_spinner EXIT

clear

echo "
***************************************
        SCRIPT BY ECLIPSE5214
***************************************
"
sleep 1

if [[ $(command -v brew) == "" ]]; then
    echo "
***************************************
         installing homebrew
***************************************
"
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
	echo "
***************************************
          updating homebrew
***************************************
"
	start_spinner "updating"
    brew update
	stop_spinner
fi

clear

echo "
***************************************
       installing dependencies
***************************************
"

start_spinner "installing dependencies"
brew install git python3 mingw-w64 gcc make pkg-config glfw glew sdl2 libusb
stop_spinner

clear

echo "
***************************************
          cloning into repo
***************************************
"

cd ~

start_spinner "cloning"
git clone --quiet https://github.com/sm64pc/sm64ex 
stop_spinner

#Queiry for assets

clear

echo "where is the path to your rom file [must be .z64]"
read path

echo "
what language is your rom [jp] [us] [eu] [sh]"
read lang

clear

echo "
***************************************
           getting assets
***************************************
"

cp "$path" ~/sm64ex/baserom.$lang.z64
cd ~/sm64ex

start_spinner "getting assets"
python3 extract_assets.py $lang > /dev/null 2>&1
stop_spinner

clear

echo "
***************************************
               patching
***************************************
"

./tools/apply_patch.sh ./enhancements/60fps_ex.patch

clear

echo "
***************************************
              building
***************************************
"
start_spinner "building"
gmake OSX_BUILD=1 BETTERCAMERA=1 NODRAWINGDISTANCE=1 TEXTURE_FIX=1 EXT_OPTIONS_MENU=1 EXTERNAL_DATA=1 -j 8 > /dev/null 2>&1
stop_spinner

clear

echo "
***************************************
               packing
***************************************
"

start spinner "packing"
mkdir -p ~/sm64.app/Contents/MacOS
cd ~
mv ~/sm64ex/build/us_pc/sm64.us.f3dex2e ~/sm64.app/Contents/MacOS/sm64
mv ~/sm64ex/build/us_pc/ ~/sm64.app/Contents/Resources

echo '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleDisplayName</key>
	<string>Sm64</string>
	<key>CFBundleExecutable</key>
	<string>Sm64</string>
	<key>CFBundleIconFile</key>
	<string>sm64.icns</string>
	<key>CFBundleIdentifier</key>
	<string>org.'$USER'.Sm64</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>Sm64</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>LSMinimumSystemVersion</key>
	<string>10.11.0</string>
	<key>LSUIElement</key>
	<false/>
	<key>NSAppTransportSecurity</key>
	<dict>
		<key>NSAllowsArbitraryLoads</key>
		<true/>
	</dict>
	<key>NSHumanReadableCopyright</key>
	<string>© 2023 '$USER'</string>
	<key>NSMainNibFile</key>
	<string>MainMenu</string>
	<key>NSPrincipalClass</key>
	<string>NSApplication</string>
</dict>
</plist>' >> Info.plist

mv Info.plist ~/sm64.app/Contents/

curl https://raw.githubusercontent.com/Eclipse-5214/sm64-MacOS/main/appicons.txt > appicons.txt
base64 --decode -i appicons.txt -o sm64.icns

mv sm64.icns ~/sm64.app/Contents/Resources
stop_spinner

clear

echo "
***************************************
               Cleaning
***************************************

This needs root to do
"

sudo rm -r ~/sm64ex
sudo rm appicons.txt

clear

echo "
***************************************
                 Done
***************************************

Finished app should be in home directory"
