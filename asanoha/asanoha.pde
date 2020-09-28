/*
  Processing code by Shefali Nayak

  Template from Etienne Jacob & beesandbombs (dave)
*/

import java.util.ArrayList;
import java.util.Arrays;

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

PVector origin = new PVector(0,0);

void setup() {
  if (args != null) {
    if (args[0].equals("-i"))
      recording = false;
    else if (args[0].equals("-d"))
      printParameters = true;
  }

  size(500, 500);
  smooth(2);

  result = new int[width * height][3];
}

ArrayList<PVector> hexMidpoints(Layout layout, Hex hex) {
  ArrayList<PVector> corners = layout.polygonCorners(hex);
  ArrayList<PVector> midpoints = new ArrayList<PVector>();

  for (int i = 0; i < 6; i++) {
    PVector v1 = corners.get(i);
    PVector v2 = corners.get((i+1)%6);
    midpoints.add(PVector.lerp(v1, v2, 0.5));
  }

  return midpoints;
}

void hexagons(float t) {
  PVector origin = new PVector(width/2, height/2);
  PVector size = new PVector(60,60);
  Layout layout = new Layout(POINTY, size, origin);

  int gridMin = -4;
  int gridMax = 4;

  for (int q = gridMin; q < gridMax; q++) {
    for (int r = gridMin; r < gridMax; r++) {
      for (int s = gridMin; s < gridMax; s++) {
        if (q + r + s != 0) continue;

        Hex hex = new Hex(q, r, s);
        PVector center = layout.hexToPixel(hex);
        ArrayList<PVector> corners = layout.polygonCorners(hex);
        ArrayList<PVector> midpoints = hexMidpoints(layout, hex);

        for (int i = 0; i < 6; i++) {
          PVector corner = corners.get(i);
          PVector midpoint = midpoints.get(i);

          float step = map(t, 0, 0.5, 0, 1);
          PVector pt = PVector.lerp(midpoint, center, step);
          line(midpoint.x, midpoint.y, pt.x, pt.y);

          if (t > 0.5) {
            step = map(t, 0.5, 1, 0, 1);
            pt = PVector.lerp(center, corner, step);
            line(center.x, center.y, pt.x, pt.y);
          }
        }
      }
    }
  }
}

// assume t in range [0,1], t=0 and t=1 should be identical
void draw_(float t) {
  background(#b0e0e6);
  stroke(#f0ffff);
  strokeWeight(2);

  float step = map(cos(TWO_PI * t), -1, 1, 1, 0);
  hexagons(step);
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
