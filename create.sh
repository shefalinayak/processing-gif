#!/bin/sh

set -e

help() {
    echo "Syntax: ./create your-sketch-name new|play|frames|gif|clean"
    echo "Options:"
    echo "  new:     Create new sketch folder, --noise to include OpenSimplexNoise"
    echo "  play:    Run sketch in interactive mode"
    echo "  frames:  Run sketch to generate frames, --debug to render parameter info"
    echo "  gif:     Create gif from frames"
}

render() {
    FILEPATH="$(pwd)"
    echo "Running $FILEPATH..."
    if [ "$1" = "--debug" ]; then
        echo "rendering frames with debug info"
        processing-java --sketch="$FILEPATH" --run -d "${@:2}"
    else
        echo "rendering frames"
        processing-java --sketch="$FILEPATH" --run "${@:1}"
    fi
}

if [ "$#" -lt 2 ]
then
    help
    exit 1
elif [ "$1" = "help" ]
then
    help
    exit 0
fi

SKETCH=`echo $1|tr '-' '_'`
CMD="$2"

case $CMD in
    new)
        mkdir $SKETCH
        if [ "$3" = "--noise" ]
        then
            cp TEMPLATE/noise/noise.pde "$SKETCH/$SKETCH.pde"
            cp TEMPLATE/noise/OpenSimplexNoise.pde "$SKETCH/"
        else
            cp TEMPLATE/basic/basic.pde "$SKETCH/$SKETCH.pde"
        fi
        mkdir $SKETCH/frames
        mkdir $SKETCH/output
        echo "Created new Processing sketch $SKETCH"
        tree $SKETCH
        ;;
    play)
        cd $SKETCH
        FILEPATH="$(pwd)"
        echo "Running $FILEPATH..."
        processing-java --sketch="$FILEPATH" --run -i "${@:3}"
        ;;
    frames)
        cd $SKETCH
        render "${@:3}"
        ;;
    gif)
        if [ -z "$(ls -A '$SKETCH/frames')" ]; then
            cd $SKETCH
            render "${@:3}"
            cd ..
        fi
        ./convert.sh $SKETCH
        ;;
    clean)
        cd $SKETCH
        rm frames/fr*.png
        rm -rf build
        ;;
    *)
        help
        exit 1
        ;;
esac