
CLASH_CORE=meta
BIN_DIR=/usr/local/bin
DEST=$BIN_DIR/clash
VERSION=v1.14.1

usage() {
    echo "Usage: $0 [--clash-version] [--subscribe] [-h | --help]"
    echo "  --clash-version: install clash core version"
    echo "  --subscribe: subscribe url"
    echo "  -h | --help: print help info"
    exit 1
}

while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        --clash-version)
            VERSION=$VALUE
            ;;
        --subscribe)
            SUBSCRIBE_URL=$VALUE
            ;;
        --override-deamon)
            OVERRIDE_DEAMON=1
            ;;
        -h | --help)
            usage
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done
if [[ $(uname -m) == 'arm64' ]]; then
    ARCH=arm64
else
    ARCH=amd64
fi

if [[ $(uname) == 'Darwin' ]]; then
    OS=darwin
else
    OS=linux
fi

FILE_NAME=Clash.Meta-$OS-$ARCH-$VERSION
GZ_FILE_NAME=$FILE_NAME.gz
OUTPUT=/tmp/$GZ_FILE_NAME
if [ -f "/tmp/$FILE_NAME" ];then
    echo "Use cached file: /tmp/$FILE_NAME"
else
    if [ ! -f $OUTPUT ]; then
        curl -L "https://github.com/MetaCubeX/Clash.Meta/releases/download/$VERSION/$GZ_FILE_NAME" -o $OUTPUT

        if [ -f "/tmp/$FILE_NAME" ]; then
            rm "/tmp/$FILE_NAME"
        fi
    fi
    gunzip $OUTPUT
fi

chmod +x /tmp/$FILE_NAME

if [ ! -d "$BIN_DIR" ]; then
    mkdir -p "$BIN_DIR"
fi

cp /tmp/$FILE_NAME "$DEST"

if [ ! -d $HOME/.config/simple-clash ]; then
    mkdir -p $HOME/.config/simple-clash
fi

curl -L "$SUBSCRIBE_URL" -o "$HOME/.config/simple-clash/config.yaml"

cp com.imciel.simple.clash.plist $HOME/Library/LaunchAgents/
if launchctl list | grep 'simeple.clash'; then
    launchctl unload $HOME/Library/LaunchAgents/com.imciel.simple.clash.plist
fi

launchctl load $HOME/Library/LaunchAgents/com.imciel.simple.clash.plist
