#!/usr/bin/env zsh

# ANSI colour codes
PURPLE='\033[0;35m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Colour

# This gets the location that the script is being run from and moves there.
SCRIPT_DIR=${0:a:h}
cd "$SCRIPT_DIR"

# Set variables
ROM_NAME="zelda3.sfc"
GAME_ID="zelda3"
GAME_TITLE="Link to the Past"
SHASUM_US="6d4f10a8b10e10dbe624cb23cf03b88bb8252973"
SHASUM_EU="7c073a222569b9b8e8ca5fcb5dfec3b5e31da895"
SHASUM_CAN="c1c6c7f76fff936c534ff11f87a54162fc0aa100"
SHASUM_FR="229364a1b92a05167cd38609b1aa98f7041987cc"
SHASUM_DE="2e62494967fb0afdf5da1635607f9641df7c6559"
PKGINFO_TITLE="LTTP"
ICON_URL='https://parsefiles.back4app.com/JPaQcFfEEQ1ePBxbf6wvzkPMEqKYHhPYv8boI1Rc/d7963e9007c68f6f82ce2433bf0fae23_The_Legend_of_Zelda__A_Link_to_the_Past.icns'

echo "${PURPLE}This script is for compiling a native macOS build of:\n${GREEN}Zelda 3: A Link to the Past${NC}\n"
echo "${PURPLE}You must have a legally obtained original copy of the game${NC}"
echo "${PURPLE}Place the ROM in the same folder that the script is run from and rename it to:\n${GREEN}${ROM_NAME}${NC}\n"
echo "Important: \nDo not run this script from Terminal using the 'sh' command"
echo "In Terminal use 'cd' to navigate to the correct directory and run with './build_zelda3.sh'"
echo "Alternatively, use Finder to set the default application for the script to be Terminal and double-click to open\n"

check_shasum() {
	USR_ROM_SHA=$(shasum zelda3.sfc | awk '{print $1}')
	
	if [ $? -ne 0 ]; then
		echo "${RED}There was an issue checking the shasum of the file.${NC}"	
		exit 1
	fi
	
	echo "${PURPLE}\nThe shasum of the provided file is: \n${GREEN}$USR_ROM_SHA${NC}"
	
	if [[ $USR_ROM_SHA == $SHASUM_US ]]; then
		echo "${GREEN}A valid rom has been detected${NC}\n"
	elif [[ $USR_ROM_SHA == $SHASUM_EU ]]; then
		echo "${PURPLE}The shasum matches the EU version of the game. \n${RED}This version is unsupported.${NC}"
		exit 1
	elif [[ $USR_ROM_SHA == $SHASUM_CAN ]]; then
		echo "${PURPLE}The shasum matches the Canadian version of the game. \n${RED}This version is unsupported.${NC}"
		exit 1	
	elif [[ $USR_ROM_SHA == $SHASUM_FR ]]; then
		echo "${PURPLE}The shasum matches the French version of the game. \n${RED}This version is unsupported.${NC}"
		exit 1
	elif [[ $USR_ROM_SHA == $SHASUM_DE ]]; then
		echo "${PURPLE}The shasum matches the German version of the game. \n${RED}This version is unsupported.${NC}"
		exit 1
	else 
		echo "${RED}The shasum does not match any supported version of the game.${NC}"
		exit 1
	fi
}

if [[ -a "${ROM_NAME}" ]]; then 
	echo "${PURPLE}Currently supported roms and their Shasum include:${NC}"
	echo "${GREEN}US Version${NC} sha1: ${SHASUM_US}"
	echo "${PURPLE}Checking Shasum...${NC}"
	check_shasum
else 
	echo "${RED}Couldn't find a valid rom${NC}"
	echo "${PURPLE}Place the ROM in the same folder that the script is run from and rename it to ${GREEN}${ROM_NAME}${NC}\n"
	exit 1
fi

echo "${PURPLE}${GREEN}Homebrew${PURPLE} and the ${GREEN}Xcode command-line tools${PURPLE} are required to build${NC}"
echo "${PURPLE}If they are not present you will be prompted to install them${NC}"

PS3='Would you like to continue? '
OPTIONS=(
	"Yes"
	"Quit")
select opt in $OPTIONS[@]
do
	case $opt in
		"Yes")
			break
			;;
		"Quit")
			echo -e "${RED}Quitting${NC}"
			exit 0
			;;
		*) 
			echo "\"$REPLY\" is not one of the options..."
			echo "Enter the number of the option and press enter to select"
			;;
	esac
done

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
	echo "${PURPLE}Homebrew not found. Installing Homebrew...${NC}"
	echo "${PURPLE}The Homebrew installer will ask you to enter your admin password${NC}"
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> $HOME/.zprofile
	eval "$(/opt/homebrew/bin/brew shellenv)"
	
	if [ $? -ne 0 ]; then
		echo "${RED}There was an issue installing Homebrew${NC}"
		echo "${PURPLE}Quitting script...${NC}"	
		exit 1
	fi
else
	echo -e "${PURPLE}Homebrew found. Updating Homebrew...${NC}"
	brew update
fi

## Homebrew dependencies
# Install required dependencies
echo -e "${PURPLE}Checking for Homebrew dependencies...${NC}"
brew_dependency_check() {
	if [ -d "$(brew --prefix)/opt/$1" ]; then
		echo -e "${GREEN}Found $1. Checking for updates...${NC}"
			brew upgrade $1
	else
		 echo -e "${PURPLE}Did not find $1. Installing...${NC}"
		brew install $1
	fi
}

# Required Homebrew packages
deps=( cmake python3 sdl2 )

for dep in $deps[@]
do 
	brew_dependency_check $dep
done

# Downloading repository
echo "${PURPLE}Downloading repository...${NC}"
git clone https://github.com/snesrev/$GAME_ID

# Copy the rom into the repository folder
cp $ROM_NAME ./$GAME_ID/$ROM_NAME
cd $GAME_ID

# Create a virtual environment for python 3.12 or later
echo "${PURPLE}Creating a virtual environment for python 3.12 or later...${NC}"
python3 -m venv .venv
source .venv/bin/activate

# Update pip
echo "${PURPLE}Updating python and installing python requirements...${NC}"
python3 -m pip install --upgrade pip

# Install python requirements 
python3 -m pip install -r requirements.txt

# Amount of available cores:
CORES=$(sysctl -n hw.ncpu)

# Build 
echo "${PURPLE}Building...${NC}"
CFLAGS="-Wno-deprecated-non-protoype" make -j${CORES}

# Create app bundle structure
echo "${PURPLE}Creating app bundle structure...${NC}"
rm -rf "${GAME_TITLE}.app"
mkdir -p "${GAME_TITLE}.app/Contents/Resources"
mkdir -p "${GAME_TITLE}.app/Contents/MacOS"

# create Info.plist
echo "${PURPLE}Creating properties list file...${NC}"
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
	<string>jp.co.nintendo.${GAME_ID}</string>
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
	<string>Nintendo of Japan</string>
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
echo "${PURPLE}Creating PkgInfo file...${NC}"
PKGINFO="-n APPL${PKGINFO_TITLE}"
echo "${PKGINFO}" > "${GAME_TITLE}.app/Contents/PkgInfo"

# Create launch script (Launching the executable directly doesn't work for some reason) and set executable permissions
echo "${PURPLE}Creating launcher script...${NC}"
LAUNCHER="#!/usr/bin/env zsh

SCRIPT_DIR=\${0:a:h}
cd "\$SCRIPT_DIR"

./${GAME_ID}"
echo "${LAUNCHER}" > "${GAME_TITLE}.app/Contents/MacOS/launch_${GAME_ID}.sh"
chmod +x "${GAME_TITLE}.app/Contents/MacOS/launch_${GAME_ID}.sh"

# Bundle resources
echo "${PURPLE}Copying resources to app bundle...${NC}"
cp -R $GAME_ID ${GAME_ID}_assets.dat saves ${GAME_ID}.ini ${GAME_TITLE}.app/Contents/MacOS/

cp -R ${GAME_TITLE}.app ..
cd ..

# Check for a 1024x png file to make an icon out of
echo "${PURPLE}Checking for png file to make icon from...${NC}"
echo "${PURPLE}File should be named ${GREEN}${GAME_ID}1024.png${NC}"
if [[ -a ${GAME_ID}1024.png ]]; then 
	# Create icon if there is a file called ${GAME_ID}1024.png in the build folder
	echo -e "${PURPLE}Found image file. Creating icon...${NC}"
	
	mkdir ${GAME_ID}.iconset
	sips -z 16 16     ${GAME_ID}1024.png --out ${GAME_ID}.iconset/icon_16x16.png
	sips -z 32 32     ${GAME_ID}1024.png --out ${GAME_ID}.iconset/icon_16x16@2x.png
	sips -z 32 32     ${GAME_ID}1024.png --out ${GAME_ID}.iconset/icon_32x32.png
	sips -z 64 64     ${GAME_ID}1024.png --out ${GAME_ID}.iconset/icon_32x32@2x.png
	sips -z 128 128   ${GAME_ID}1024.png --out ${GAME_ID}.iconset/icon_128x128.png
	sips -z 256 256   ${GAME_ID}1024.png --out ${GAME_ID}.iconset/icon_128x128@2x.png
	sips -z 256 256   ${GAME_ID}1024.png --out ${GAME_ID}.iconset/icon_256x256.png
	sips -z 512 512   ${GAME_ID}1024.png --out ${GAME_ID}.iconset/icon_256x256@2x.png
	sips -z 512 512   ${GAME_ID}1024.png --out ${GAME_ID}.iconset/icon_512x512.png
	cp ${GAME_ID}1024.png ${GAME_ID}.iconset/icon_512x512@2x.png
	iconutil -c icns ${GAME_ID}.iconset
	rm -R ${GAME_ID}.iconset
	cp -R ${GAME_ID}.icns "${GAME_TITLE}.app/Contents/Resources/"
	rm -rf ${GAME_ID}.icns
else 
	# Otherwise get an icon from macosicons.com
	echo "${PURPLE}No png file found. Downloading icon from ${GREEN}macosicons.com...${NC}"
	curl -o ${GAME_TITLE}.app/Contents/Resources/${GAME_ID}.icns ${ICON_URL}
fi

# Bundle libs & Codesign
echo "${PURPLE}Bundling dependencies and codesigning...${NC}"
dylibbundler -of -cd -b -x ./${GAME_TITLE}.app/Contents/MacOS/${GAME_ID} -d ./${GAME_TITLE}.app/Contents/libs/
codesign --force --deep --sign - ${GAME_TITLE}.app

# Cleanup
echo "${PURPLE}Cleaning up...${NC}"
rm -rf $GAME_ID

# Finished
echo "${PURPLE}Build completed${NC}"