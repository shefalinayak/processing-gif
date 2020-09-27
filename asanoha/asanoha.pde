/*
  Processing code by Shefali Nayak

  Template from Etienne Jacob & beesandbombs (dave)
/*

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

void setup() {
  if (args != null) {
    if (args[0].equals("-i"))
      recording = false;
    else if (args[0].equals("-d"))
      printParameters = true;
  }

  size(500, 500);

  result = new int[width * height][3];
}

void hexagons(float t) {
  PVector origin = new PVector(width/2, height/2);
  PVector size = new PVector(50,50);
  Layout layout = new Layout(POINTY, size, origin);

  Hex hex0 = new Hex(0,0,0);
  PVector pt0 = layout.hexToPixel(hex0);
  circle(pt0.x, pt0.y, 30);

  for (int i = 0; i < 6; i++) {
    Hex neightbor = hex0.neighbor(i);
    PVector pt = layout.hexToPixel(neightbor);
    circle(pt.x, pt.y, 15);
  }
}

// assume t in range [0,1], t=0 and t=1 should be identical
void draw_(float t) {
  background(color(112,58,75));
  fill(color(219,112,147));
  noStroke();

  hexagons(t);
}

/*---------------------------------------------------------------------
  UTILS
---------------------------------------------------------------------*/

float HALF_SQRT_3 = .5 * sqrt(3); // regular triangle height
float ia = atan(sqrt(.5));

/* distorts parameter p [0,1] with intensity g */
float ease(float p, float g) {
  if (p < 0.5)
    return 0.5 * pow(2 * p, g);
  else
    return 1 - 0.5 * pow(2 * (1 - p), g);
}

/* simpler easing function, easier to understand */
float ease(float p) {
  return 3 * p * p - 2 * p * p * p;
}

void push() {
  pushMatrix();
  pushStyle();
}

void pop() {
  popStyle();
  popMatrix();
}

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
