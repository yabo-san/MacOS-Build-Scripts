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
# Supported
SMW_SHASUM_US="6b47bb75d16514b6a476aa0c73a683a2a4c18765"
SMAS_SHASUM_US="c05817c5b7df2fbfe631563e0b37237156a8f6b6"
# Not supported
SMW_SHASUM_EU="56265120a74b55260ff7cacc00da1f21cbcb64f4"
SMW_SHASUM_EU_REV1="46bf36be1c3a2ce9de7581323370bd2d891ad5a1"
SMW_SHASUM_JP="06a6efc246c6fdb83efab1d402d61d2179a84494"
SMAS_SHASUM_EU="cc41f4b229df01a5adf44c63b6c60e766a73c1ad"
COMBO_SHASUM_US="d245e41a2b590f7d63666b0772cbddfb26f254a2"
COMBO_SHASUM_EU="be560f0a8de05e432b34be768198ef3defb13cb6"

echo "${PURPLE}This script is for compiling a native macOS build of:"
echo "${GREEN}Super Mario World${NC}"
echo "${GREEN}Super Mario Bros${PURPLE} (SNES Remake)${NC}"
echo "${GREEN}Super Mario Bros: The Lost Levels${NC}\n"

echo "${PURPLE}You must have a legally obtained original copy of the games${NC}"
echo "${PURPLE}A copy of ${GREEN}Super Mario World${PURPLE} is required for building any of these games${NC}"
echo "${PURPLE}A copy of ${GREEN}Super Mario All Stars${PURPLE} is required for building ${GREEN}Super Mario Bros${PURPLE} or ${GREEN}The Lost Levels${NC}\n"

echo "${PURPLE}Rename the roms to: ${GREEN}smw.sfc${PURPLE} and ${GREEN}smas.sfc${PURPLE} and place in the same folder that the script is run from${NC}\n"

echo "Important: \nDo not run this script from Terminal using the 'sh' command"
echo "In Terminal use 'cd' to navigate to the correct directory and run with './build_super_mario.sh'"
echo "Alternatively, use Finder to set the default application for the script to be Terminal and double-click to open\n"

echo "${PURPLE}Currently supported roms and their Shasum include:${NC}"
echo "${GREEN}smw.sfc${NC} US Version - sha1: ${SMW_SHASUM_US}"
echo "${GREEN}smas.sfc${NC} US Version - sha1: ${SMAS_SHASUM_US}"

echo "\n${PURPLE}${GREEN}Homebrew${PURPLE} and the ${GREEN}Xcode command-line tools${PURPLE} are required to build${NC}"
echo "${PURPLE}If they are not present you will be prompted to install them${NC}\n"

# Functions
check_smw() {
	if [[ -a "smw.sfc" ]]; then 
		USR_SMW_SHA=$(shasum smw.sfc | awk '{print $1}')
		
		if [ $? -ne 0 ]; then
			echo "${RED}There was an issue checking the shasum of smw.sfc${NC}"	
			exit 1
		fi
		
		echo "${PURPLE}\nThe shasum of the provided smw.sfc file is: \n${NC}$USR_SMW_SHA"
		
		if [[ $USR_SMW_SHA == $SMW_SHASUM_US ]]; then
			echo "${GREEN}A valid smw.sfc rom has been detected${NC}\n"
		elif [[ $USR_SMW_SHA == $SMW_SHASUM_EU ]]; then
			echo "${PURPLE}The shasum of smw.sfc matches the EU version of the game. \n${RED}This version is unsupported.${NC}"
			exit 1
		elif [[ $USR_SMW_SHA == $SMW_SHASUM_JP ]]; then
			echo "${PURPLE}The shasum of smw.sfc matches the JP version of the game. \n${RED}This version is unsupported.${NC}"
			exit 1
		elif [[ $USR_SMW_SHA == $COMBO_SHASUM_US ]]; then
			echo "${PURPLE}The shasum of smw.sfc matches the US region Super Mario All Stars & Mario World compilation version of the game. \n${RED}This version is unsupported.${NC}"
			exit 1
		elif [[ $USR_SMW_SHA == $COMBO_SHASUM_EU ]]; then
			echo "${PURPLE}The shasum of smw.sfc matches the EU region Super Mario All Stars & Mario World compilation version of the game. \n${RED}This version is unsupported.${NC}"
			exit 1
		else 
			echo "${RED}The shasum does not match any supported version of the game.${NC}"
			exit 1
		fi
	else 
		echo "${RED}Couldn't find a valid ${GREEN}smw.sfc${RED} rom${NC}"
		echo "${PURPLE}Rename the rom to: ${GREEN}smw.sfc${PURPLE} and place in the same folder that the script is run from${NC}"
		exit 1
	fi
}

check_smas() {
	if [[ -a "smas.sfc" ]]; then 
		USR_SMAS_SHA=$(shasum smas.sfc | awk '{print $1}')
		
		if [ $? -ne 0 ]; then
			echo "${RED}There was an issue checking the shasum of smas.sfc${NC}"	
			exit 1
		fi
		
		echo "${PURPLE}\nThe shasum of the provided smas.sfc file is: \n${NC}$USR_SMAS_SHA"
		
		if [[ $USR_SMAS_SHA == $SMAS_SHASUM_US ]]; then
			echo "${GREEN}A valid smas.sfc rom has been detected${NC}\n"
		elif [[ $USR_SMAS_SHA == $SMAS_SHASUM_EU ]]; then
			echo "${PURPLE}The shasum of smas.sfc matches the EU version of the game. \n${RED}This version is unsupported.${NC}"
			exit 1
		elif [[ $USR_SMAS_SHA == $COMBO_SHASUM_US ]]; then
			echo "${PURPLE}The shasum of smas.sfc matches the US region Super Mario All Stars & Mario World compilation version of the game. \n${RED}This version is unsupported.${NC}"
			exit 1
		elif [[ $USR_SMAS_SHA == $COMBO_SHASUM_EU ]]; then
			echo "${PURPLE}The shasum of smas.sfc matches the EU region Super Mario All Stars & Mario World compilation version of the game. \n${RED}This version is unsupported.${NC}"
			exit 1
		else 
			echo "${RED}The shasum does not match any supported version of the game.${NC}"
			exit 1
		fi
		
	else 
		echo "${RED}Couldn't find a valid ${GREEN}smas.sfc${NC} rom${NC}"
		echo "${PURPLE}Rename the rom to: ${GREEN}smas.sfc${PURPLE} and place in the same folder that the script is run from${NC}"
		exit 1
	fi
}

PS3='Which game would you like to build? '
OPTIONS=(
	"Super Mario World"
	"Super Mario Bros"
	"Super Mario Bros: The Lost Levels"
	"Quit")
select opt in $OPTIONS[@]
do
	case $opt in
		"Super Mario World")
			GAME_ID="smw"
			GAME_TITLE="Super Mario World"
			PKGINFO_TITLE="SMWD"
			ICON_URL='https://parsefiles.back4app.com/JPaQcFfEEQ1ePBxbf6wvzkPMEqKYHhPYv8boI1Rc/7282c563ed04e9e94efa1665059e32f1_Super_Mario_World.icns'
			check_smw
			break
			;;
		"Super Mario Bros")
			GAME_ID="smb1"
			GAME_TITLE="Super Mario Bros"
			PKGINFO_TITLE="SMBR"
			ICON_URL='https://parsefiles.back4app.com/JPaQcFfEEQ1ePBxbf6wvzkPMEqKYHhPYv8boI1Rc/f94638ee3f74a325d1c710b93840b025_Super_Mario_Bros.icns'
			check_smw
			check_smas
			break
			;;
		"Super Mario Bros: The Lost Levels")
			GAME_ID="smbll"
			GAME_TITLE="The Lost Levels"
			PKGINFO_TITLE="SMLL"
			ICON_URL='https://parsefiles.back4app.com/JPaQcFfEEQ1ePBxbf6wvzkPMEqKYHhPYv8boI1Rc/6c3af467cc519632d07da06c2156efa3_Super_Mario_Bros__The_Lost_Levels.icns'
			check_smw
			check_smas
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
	echo -e "${PURPLE}Homebrew not found. Installing Homebrew...${NC}"
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
git clone https://github.com/snesrev/smw

# Copy the roms into the repository folder
cp ./smw.sfc smw/smw.sfc
if [[ $GAME_ID = "smb1" || $GAME_ID = "smbll" ]]; then 
	cp ./smas.sfc smw/other/smas.sfc
fi
cd smw

if [[ $GAME_ID == "smb1" || $GAME_ID == "smbll" ]]; then 
	cd other
	# Create a virtual environment for python 3.12 or later
	echo "${PURPLE}Creating a virtual environment for python 3.12 or later...${NC}"
	python3 -m venv .venv
	source .venv/bin/activate
	
	# Install python dependency
	pip3 install zstandard
	
	# Extract game data
	echo "${PURPLE}Extracting game data...${NC}"
	python3 ./extract.py
	
	# Copy extracted data
	cp smb1.sfc ../smb1.sfc
	cp smbll.sfc ../smbll.sfc
	
	cd ..
fi

# Amount of available cores:
CORES=$(sysctl -n hw.ncpu)

# Build 
echo "${PURPLE}Building...${NC}"
CFLAGS="-Wno-deprecated-non-protoype" make -j${CORES}

# Create app bundle structure
echo "${PURPLE}Creating app bundle...${NC}"
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
PKGINFO="-n APPL${PKGINFO_TITLE}"
echo "${PKGINFO}" > "${GAME_TITLE}.app/Contents/PkgInfo"

# Create launch script (Launching the executable directly doesn't work for some reason) and set executable permissions

if [[ $GAME_ID == "smw" ]]; then 
	LAUNCHER="#!/usr/bin/env zsh
	
	SCRIPT_DIR=\${0:a:h}
	cd "\$SCRIPT_DIR"
	
	./smw"
else 
	LAUNCHER="#!/usr/bin/env zsh
	
	SCRIPT_DIR=\${0:a:h}
	cd "\$SCRIPT_DIR"
	
	./smw ${GAME_ID}.sfc"	
fi
echo "${LAUNCHER}" > "${GAME_TITLE}.app/Contents/MacOS/launch_${GAME_ID}.sh"
chmod +x "${GAME_TITLE}.app/Contents/MacOS/launch_${GAME_ID}.sh"

# Bundle resources. 
cp -R smw smw_assets.dat smw.ini ${GAME_TITLE}.app/Contents/MacOS/

if [[ $GAME_ID == "smb1" || $GAME_ID == "smbll" ]]; then 
	cp -R $GAME_ID.sfc "${GAME_TITLE}.app/Contents/MacOS/"
fi

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
	curl -o ${GAME_TITLE}.app/Contents/Resources/${GAME_ID}.icns $ICON_URL
fi

# Bundle libs & Codesign
echo "${PURPLE}Bundling dependencies and codesigning...${NC}"
dylibbundler -of -cd -b -x ./${GAME_TITLE}.app/Contents/MacOS/smw -d ./${GAME_TITLE}.app/Contents/libs/
codesign --force --deep --sign - ${GAME_TITLE}.app

# Cleanup
echo "${PURPLE}Cleaning up...${NC}"
rm -rf smw

# Finished
echo "${PURPLE}Build completed${NC}"