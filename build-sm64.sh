#!/bin/bash

clear

echo "
***************************************
        SCRIPT BY ECLIPSE5214
***************************************
"

echo is homebrew installed [y] [n]
read hb


if [ "$hb" != "${hb#[Nn]}" ] 
then
    echo "
***************************************
         installing homebrew
***************************************
"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo
fi

echo "
***************************************
       installing dependencies
***************************************
"
brew install git python3 mingw-w64 gcc make pkg-config glfw glew sdl2 libusb

echo "
***************************************
          cloning into repo
***************************************
"

cd ~
git clone https://github.com/sm64pc/sm64ex

echo "
where is the path to your rom file [must be .z64]"
read path

echo "
what language is your rom [jp] [us] [eu] [sh]"
read lang

echo "
***************************************
           getting assets
***************************************
"

cp "$path" ~/sm64ex/baserom.$lang.z64
cd ~/sm64ex
./extract_assets.py $lang &

pid=$! ; i=0
spin='◐◓◑◒'
while ps -a | awk '{print $1}' | grep -q "${pid}"
do
  i=$(( (i+1) %4 ))
  printf "\rGetting Assets [${spin:$i:1}]"
  sleep .1
done

wait ${PID}
ret=$?

echo "
***************************************
               patching
***************************************
"

./tools/apply_patch.sh ./enhancements/60fps_ex.patch

echo "
***************************************
              building
***************************************
"

gmake OSX_BUILD=1 BETTERCAMERA=1 NODRAWINGDISTANCE=1 TEXTURE_FIX=1 EXT_OPTIONS_MENU=1 EXTERNAL_DATA=1 -j 8 &

pid=$! ; i=0
spin='◐◓◑◒'
while ps -a | awk '{print $1}' | grep -q "${pid}"
do
  i=$(( (i+1) %4 ))
  printf "\rBuilding [${spin:$i:1}]"
  sleep .1
done

wait ${PID}
ret=$?

echo "
***************************************
               packing
***************************************
"

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

echo "
***************************************
               Cleaning
***************************************

This needs root to do
"

sudo rm -r ~/sm64ex
sudo rm appicons.txt

echo "
***************************************
                 Done
***************************************

Finished app should be in home directory"
