#!/usr/bin/env zsh

## This script is supposed to be run from inside a GTA III PC folder
## It may overwrite some files, so always backup. 

## Assumes Xcode and Homebrew are installed

# This gets the location that the script is being run from and moves there.
SCRIPT_DIR=${0:a:h}
cd "$SCRIPT_DIR"

# Required Homebrew packages
brew install openal-soft glfw mpg123 wget dylibbundler

# build a premake5 binary
git clone https://github.com/premake/premake-core
cd premake-core
make -f Bootstrap.mak osx PLATFORM=ARM
cd build/bootstrap
make config=release

cd ../../../
# The premake5 binary will be in premake-core/bin/release
mv premake-core/bin/release/premake5 ./premake5
# Don't need the premake-core source anymore
rm -r -f premake-core

# Clone the re3 repository
git clone --recursive https://github.com/halpz/re3

# Copy the premake5 binary into re3
mv premake5 re3
cd re3

# Build with premake5: 
./premake5 --with-librw gmake2
cd build
# To see build options run:
# make help

# Build for Arm 
make config=release_macosx-arm64-librw_gl3_glfw-oal 

# The binary will be in bin/macosx-arm64-librw_gl3_glfw-oal/release
cd ../bin/macosx-arm64-librw_gl3_glfw-oal/release
# It will likely be created with .app, but this needs to be removed (The .app may be invisible depending on your finder settings)
mv re3.app re3
mv re3 ../../../gamefiles
cd ../../../../
mv re3/gamefiles re3\ gamefiles
rm -r -f re3

# Copy the newly built re3 gamefiles into the appropriate folder, and overwrite if necessary
cp re3\ gamefiles/re3 re3
mv re3\ gamefiles/neo neo
rsync -r ./re3\ gamefiles/data/ data
rsync -r ./re3\ gamefiles/models/ models
rsync -r ./re3\ gamefiles/TEXT/ TEXT

# Get an updated version of the game controller database
wget https://raw.githubusercontent.com/gabomdq/SDL_GameControllerDB/master/gamecontrollerdb.txt

# Set game title
GAME_ID="re3"
GAME_TITLE="GTA III"

# Create app bundle structure
rm -rf "${GAME_TITLE}.app"
mkdir -p "${GAME_TITLE}.app/Contents/Resources"
mkdir -p "${GAME_TITLE}.app/Contents/MacOS"

# create Info.plist
PLIST="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>English</string>
	<key>CFBundleGetInfoString</key>
	<string>${GAME_TITLE}</string>
	<key>CFBundleExecutable</key>
	<string>launch_${GAME_ID}.sh</string>
	<key>CFBundleIconFile</key>
	<string>${GAME_ID}.icns</string>
	<key>CFBundleIdentifier</key>
	<string>com.rockstargames.${GAME_ID}</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>${GAME_TITLE}</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1.0</string>
	<key>LSMinimumSystemVersion</key>
	<string>11.0</string>
	<key>NSPrincipalClass</key>
	<string>NSApplication</string>
	<key>NSHumanReadableCopyright</key>
	<string>Rockstar Games</string>
	<key>NSHighResolutionCapable</key>
	<true/>
	<key>LSApplicationCategoryType</key>
	<string>public.app-category.games</string>
	<key>LSArchitecturePriority</key>
	<array>
		<string>arm64</string>
	</array>
</dict>
</plist>
"
echo "${PLIST}" > "${GAME_TITLE}.app/Contents/Info.plist"

# Create PkgInfo
PKGINFO="-n APPLGTA3"
echo "${PKGINFO}" > "${GAME_TITLE}.app/Contents/PkgInfo"

# Create launch script (Launching the executable directly doesn't work for some reason) and set executable permissions
LAUNCHER="#!/usr/bin/env zsh

SCRIPT_DIR=\${0:a:h}
cd "\$SCRIPT_DIR"

./${GAME_ID}"
echo "${LAUNCHER}" > "${GAME_TITLE}.app/Contents/MacOS/launch_${GAME_ID}.sh"
chmod +x "${GAME_TITLE}.app/Contents/MacOS/launch_${GAME_ID}.sh"

# Create re3.ini file
# Note: this is required for Retina Macs
# Without setting the width/height/depth nothing will display on launch.
INI="[VideoMode]
Width=1920
Height=1200
Depth=32
Subsystem=0
Windowed=0
[Controller]
HeadBob1stPerson=0
VerticalMouseSens=0.003000
HorizantalMouseSens=0.002500
InvertMouseVertically=1
DisableMouseSteering=1
Vibration=0
Method=0
InvertPad=0
Type=4
JoystickName=0
PadButtonsInited=0
[Audio]
SfxVolume=102
MusicVolume=102
Radio=0
SpeakerType=0
Provider=0
DynamicAcoustics=1
[Display]
Brightness=256
DrawDistance=1.200000
Subtitles=1
PedDensity=1.000000
CarDensity=1.000000
CutsceneBorders=1
FreeCam=0
[Graphics]
AspectRatio=0
VSync=1
FrameLimiter=1
Trails=1
MultiSampling=0
IslandLoading=0
PS2AlphaTest=1
ColourFilter=2
MotionBlur=0
VehiclePipeline=0
NeoRimLight=0
NeoLightMaps=0
NeoRoadGloss=0
[General]
SkinFile=$$""
Language=0
DrawVersionText=0
NoMovies=0
[CustomPipesValues]
PostFXIntensity=1.000000
NeoVehicleShininess=0.700000
NeoVehicleSpecularity=1.000000
RimlightMult=1.000000
LightmapMult=1.000000
GlossMult=1.000000
[Rendering]
NewRenderer=0
[Draw]
ProperScaling=1
FixRadar=1
FixSprites=1
[Bindings]
PED_FIREWEAPON=kbd:PADINS,2ndKbd:LCTRL,mouse:LEFT
PED_CYCLE_WEAPON_RIGHT=2ndKbd:PADENTER,mouse:WHLDOWN
PED_CYCLE_WEAPON_LEFT=kbd:PADDEL,mouse:WHLUP
GO_FORWARD=kbd:UP,2ndKbd:W
GO_BACK=kbd:DOWN,2ndKbd:S
GO_LEFT=kbd:LEFT,2ndKbd:A
GO_RIGHT=kbd:RIGHT,2ndKbd:D
PED_SNIPER_ZOOM_IN=kbd:PGUP,2ndKbd:Z
PED_SNIPER_ZOOM_OUT=kbd:PGDN,2ndKbd:X
VEHICLE_ENTER_EXIT=kbd:ENTER,2ndKbd:F
CAMERA_CHANGE_VIEW_ALL_SITUATIONS=kbd:HOME,2ndKbd:C
PED_JUMPING=kbd:RCTRL,2ndKbd:SPC
PED_SPRINT=2ndKbd:LSHIFT,kbd:RSHIFT
PED_LOOKBEHIND=kbd:PADEND,2ndKbd:CAPSLK,mouse:MIDDLE
VEHICLE_FIREWEAPON=kbd:PADINS,2ndKbd:LCTRL,mouse:LEFT
VEHICLE_ACCELERATE=kbd:UP,2ndKbd:W
VEHICLE_BRAKE=kbd:DOWN,2ndKbd:S
VEHICLE_CHANGE_RADIO_STATION=kbd:INS,2ndKbd:R,mouse:WHLUP
VEHICLE_HORN=2ndKbd:LSHIFT,kbd:RSHIFT
TOGGLE_SUBMISSIONS=kbd:PLUS,2ndKbd:CAPSLK
VEHICLE_HANDBRAKE=kbd:RCTRL,2ndKbd:SPC,mouse:RIGHT
PED_1RST_PERSON_LOOK_LEFT=kbd:PADLEFT
PED_1RST_PERSON_LOOK_RIGHT=kbd:PADRIGHT
VEHICLE_LOOKLEFT=kbd:PADEND,2ndKbd:Q
VEHICLE_LOOKRIGHT=kbd:PADDOWN,2ndKbd:E
VEHICLE_LOOKBEHIND=mouse:MIDDLE
VEHICLE_TURRETLEFT=kbd:PADLEFT
VEHICLE_TURRETRIGHT=kbd:PAD5
VEHICLE_TURRETUP=kbd:PADPGUP
VEHICLE_TURRETDOWN=kbd:PADRIGHT
PED_CYCLE_TARGET_LEFT=kbd:[
PED_CYCLE_TARGET_RIGHT=2ndKbd:]
PED_CENTER_CAMERA_BEHIND_PLAYER=kbd:#
PED_LOCK_TARGET=kbd:DEL,mouse:RIGHT
NETWORK_TALK=
PED_1RST_PERSON_LOOK_UP=kbd:PADUP
PED_1RST_PERSON_LOOK_DOWN=kbd:PAD5
_CONTROLLERACTION_36=
TOGGLE_DPAD=
SWITCH_DEBUG_CAM_ON=
TAKE_SCREEN_SHOT=
SHOW_MOUSE_POINTER_TOGGLE=
"

echo "${INI}" > "${GAME_TITLE}.app/Contents/MacOS/${GAME_ID}.ini"

# Bundle resources
# Models folder and neo.txd needs to be in both MacOS and Resources for some reason, otherwise will fail to run
cp -R models neo gamecontrollerdb.txt ${GAME_TITLE}.app/Contents/Resources/
cp -R anim audio data models movies mp3 mss skins TEXT txd ${GAME_TITLE}.app/Contents/MacOS/
mkdir ${GAME_TITLE}.app/Contents/MacOS/neo/ && cp neo/neo.txd ${GAME_TITLE}.app/Contents/MacOS/neo/
cp ${GAME_ID} ${GAME_TITLE}.app/Contents/MacOS/

# Get icon from macosicons.com
curl -o ${GAME_TITLE}.app/Contents/Resources/${GAME_ID}.icns https://parsefiles.back4app.com/JPaQcFfEEQ1ePBxbf6wvzkPMEqKYHhPYv8boI1Rc/b1902f1df00ceda963bd48696c4f477f_WEbRiWFSRf.icns

# Bundle libs & Codesign
dylibbundler -of -cd -b -x ./${GAME_TITLE}.app/Contents/MacOS/${GAME_ID} -d ./${GAME_TITLE}.app/Contents/libs/
codesign --force --deep --sign - ${GAME_TITLE}.app
