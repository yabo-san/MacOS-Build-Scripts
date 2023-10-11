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
brew install git python3 mingw-w64 gcc make pkg-config glfw glew sdl2 libusb wget
stop_spinner

clear

echo "
***************************************
          cloning into repo
***************************************
"

cd ~

start_spinner "cloning"
git clone --quiet https://github.com/snesrev/zelda3
stop_spinner

clear

echo "
***************************************
    installing dependencies again
***************************************
"

cd zelda3 
start_spinner "installing dependencies"
python3 -m ensurepip
python3 -m pip install -r requirements.txt
stop_spinner

clear

echo "where is the path to your rom file [must be .sfc & us]"
read path

cp "$path" ~/zelda3/zelda3.sfc

echo "
***************************************
              building
***************************************
"

start_spinner "building"
CFLAGS="-Wno-deprecated-non-protoype" make > /dev/null 2>&1
stop_spinner

clear

echo "
***************************************
               packing
***************************************
"

start spinner "packing"
mkdir -p ~/zelda3.app/Contents/MacOS

echo '#!/bin/bash
abspath ()
{
case "${1}" in
    [./]*)
    local ABSPATH="$(cd ${1%/*}; pwd)/"
    echo "${ABSPATH/\/\///}"
    ;;
    *)
    echo "${PWD}/"
    ;;
esac
}


CURRENTPATH=`abspath ${0}`

cd $CURRENTPATH
cd ../Resources
./zelda3' >> ~/zelda3.app/Contents/MacOS/zelda3

cd ~
mv ~/zelda3/zelda3 ~/zelda3.app/Contents/Resources/zelda3
mv ~/zelda3/zelda3.ini ~/zelda3.app/Contents/Resources/
mv ~/zelda3/zelda3_assets.dat ~/zelda3.app/Contents/Resources/


echo '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleDisplayName</key>
	<string>Zelda3</string>
	<key>CFBundleExecutable</key>
	<string>zelda3</string>
	<key>CFBundleIconFile</key>
	<string>zelda3.icns</string>
	<key>CFBundleIdentifier</key>
	<string>org.'$USER'.Zelda3</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>Zelda3</string>
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

wget https://github.com/Eclipse-5214/sm64-MacOS/raw/main/zelda3/zelda3.icns

mv zelda3.icns ~/zelda3.app/Contents/Resources
stop_spinner

clear

echo "
***************************************
               Cleaning
***************************************

This needs root to do
"

sudo rm -r ~/zelda3

clear

echo "
***************************************
                 Done
***************************************

Finished app should be in home directory"
