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

CFLAGS="-Wno-deprecated-non-protoype" make
