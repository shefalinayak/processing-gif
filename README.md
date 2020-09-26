# Making GIFs with Processing

This is a set of Processing sketches to generate GIFs. I make a GIF with Processing maybe once every few months, so every time I come back to it I have no idea what's going on. I've created a script and some template sketches to make this somewhat easier.

The base template is modified from a [tutorial by Etienne Jacobs](https://necessarydisorder.wordpress.com/2018/07/02/getting-started-with-making-processing-gifs-and-using-the-beesandbombs-template/), which in turn is based on a [motion blur template by beesandbombs (dave)](https://beesandbombs.tumblr.com/post/65346867831/motion-blur-for-processing).

## Instructions for use

The `create` script requires the following:
- [processing-java](https://github.com/processing/processing/wiki/Command-Line) to build and run Processing sketches from the command line
- [ffmpeg](https://ffmpeg.org/) to generate GIFs

### Commands

|task|command|
|--|--|
| generate new sketch from template | `./create your_sketch_name new [--noise]` |
| run sketch in interactive mode | `./create your_sketch_name play` |
| generate frames | `./create your_sketch_name frames [--debug]` |
| generate GIF | `./create your_sketch_name gif [--debug]` |
| remove frames | `./create your_sketch_name clean` |

### Notes

- Remember to run `clean` if you reduce the number of frames.
- If you run `gif` with an empty `frames/` directory, the frames will be generated first
- If you plan to use noise, running `new --noise` will add OpenSimplexNoise to the new folder
- If you want to compare different parameters, you can run `frame --debug` and each frames will include parameter info in the top-left. You can also run `gif --debug` directly with an empty `frames/` directory.
- You should be able to pass command line arguments to your Processing sketch but I haven't tested it

## ffmpeg

The script is setup to use a custom palette for the GIF. Sometimes you may want the dithering and standard color palette, in which case you can always go for the simplest conversion:
```
ffmpeg -i egg/frames/fr%03d.png egg/output/new-egg.gif
```

| Standard | Custom palette |
|--|--|
|![egg with dithering](examples/egg-dither-light.gif)|![egg with custom palette](examples/egg-custom-light.gif)|

## Useful resources
- [High quality GIF with FFmpeg](http://blog.pkh.me/p/21-high-quality-gif-with-ffmpeg.html)
