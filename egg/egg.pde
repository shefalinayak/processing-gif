/*
 * Processing GIF template based on tutorial by Etienne Jacob
 * https://necessarydisorder.wordpress.com/2018/07/02/getting-started-with-making-processing-gifs-and-using-the-beesandbombs-template/
 * 
 */ 

/*---------------------------------------------------------------------
  GIF parameters
---------------------------------------------------------------------*/

boolean recording = true;
boolean printParameters = false;

int numFrames = 60;
float shutterAngle = 1.0;
int samplesPerFrame = 1;

/*---------------------------------------------------------------------
  Project Code
---------------------------------------------------------------------*/

OpenSimplexNoise noise;

void setup() {
  if (args != null) {
    if (args[0].equals("-i"))
      recording = false;
    else if (args[0].equals("-d"))
      printParameters = true;
  }

  size(500, 500);

  result = new int[width * height][3];
  noise = new OpenSimplexNoise();
}

void wobblyEgg(float t) {
  float cx = width/2 + 10*cos(TWO_PI*t);
  float cy = height/2 + 10*sin(TWO_PI*t);
  float yolkRadius = 120;
  float maxOffset = 50;
  float scale = 1.8;

  // egg white
  fill(#ffffff);
  beginShape();
  for (float theta = 0; theta <= TWO_PI; theta += TWO_PI/100) {
    float tScaled = map(sin(TWO_PI*t), -1, 1, 0, 1);
    float ns = (float)noise.eval(tScaled, scale * cos(theta), scale * sin(theta));
    float radius = yolkRadius + map(ns, -1, 1, 0, maxOffset);
    vertex(cx + radius*cos(theta), cy + radius*sin(theta));
  }
  endShape(CLOSE);

  // egg yolk
  fill(#ffcc5f);
  circle(cx, cy, yolkRadius);
}

// assume t in range [0,1], t=0 and t=1 should be identical
void draw_(float t) {
  background(230,230,230);
  noStroke();

  wobblyEgg(t);
}

/*---------------------------------------------------------------------
  UTILS
---------------------------------------------------------------------*/

void addParameters() {
  fill(255,255,255);
  rect(10, 10, 200, 80);
  textSize(16);
  fill(0,0,0);
  text("Shutter angle: " + shutterAngle, 20, 35);
  text("Samples per frame: " + samplesPerFrame, 20, 55);
  text("Frame count: " + numFrames, 20, 75);
}

/*---------------------------------------------------------------------
  TEMPLATE: do not edit
---------------------------------------------------------------------*/

int[][] result;

void renderFramesWithMotionBlur() {
  float t;

  for (int pixelIndex = 0; pixelIndex < width * height; pixelIndex++)
    for (int a = 0; a < 3; a++)
      result[pixelIndex][a] = 0;

  for (int sampleIndex = 0; sampleIndex < samplesPerFrame; sampleIndex++) {
    t = map(frameCount - 1 + sampleIndex * shutterAngle / samplesPerFrame, 0, numFrames, 0, 1);
    draw_(t);
    if (printParameters) addParameters();
    loadPixels();
    for (int pixelIndex = 0; pixelIndex < pixels.length; pixelIndex++) {
      result[pixelIndex][0] += pixels[pixelIndex] >> 16 & 0xff;
      result[pixelIndex][1] += pixels[pixelIndex] >> 8 & 0xff;
      result[pixelIndex][2] += pixels[pixelIndex] & 0xff;
    }
  }

  loadPixels();
  for (int pixelIndex = 0; pixelIndex < pixels.length; pixelIndex++)
    pixels[pixelIndex] = 0xff << 24 |
    int(result[pixelIndex][0] * 1.0 / samplesPerFrame) << 16 |
    int(result[pixelIndex][1] * 1.0 / samplesPerFrame) << 8 |
    int(result[pixelIndex][2] * 1.0 / samplesPerFrame);
  updatePixels();

  saveFrame("frames/fr###.png");
  println(frameCount, "/", numFrames);
  if (frameCount == numFrames)
    exit();
}

void draw() {
  if (!recording) {
    float t = mouseX * 1.0 / width;
    if (mousePressed) println("t: %d", t);
    draw_(t);
  } else {
    renderFramesWithMotionBlur();
  }
}
