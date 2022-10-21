import processing.sound.*;
FFT fft;
AudioIn in;

//Create frequency spectrum array
int bands = 512;
float[] spectrum = new float[bands];
//Create frequency spectrum array to store smoothed spectrum values
float[] smoothSpectrum = new float[bands];
float[] test = new float[bands];

float soundAmp;
float backgroundFade = 28;

float spectrumCurveCenter;
float spectrumCurveYPos = 700;
float spectrumJumpMultiplier = -300;

//Negative to make curve face upward
float spectrumCurveMultiplier = -1000;

//Curve movement easing lower is smoother
float curveEasingVal = 0.2;

//Curve spawning arguments
float curveCloneTimer;
float curveCloneSpawnTime = 300;
float curveMaxClones = 50;

//Curve details
int curveBands = 60;
float curveVertexDist = 20;

float gradientCurvesNumber = 15;
float gradientCurvesDistance = 40;

float timeSlower;
float band3;

//Colors
//Og black #040404
color backgroundColor = #181818;

//Pink purple
//color primaryColor = #8E2DE2;
//color secondaryColor = #4A00E0;
//
color primaryColor = #34e89e;
color secondaryColor = #0f3443;

//Locks the rotation of clone curves
boolean lockedRot = true;

CloneCurve[] cloneCurves;

void setup() {
  String[] args = {"Audio_Visualizer_3D_Curves"};
  MenuScreenApplet menuScreen = new MenuScreenApplet();
  PApplet.runSketch(args, menuScreen);

  //size(1500, 1000, P3D);
  fullScreen(P3D);
  noCursor();
  //background(#040404);
  background(backgroundColor);
  noStroke();

  spectrumCurveCenter = width/2;

  //Create the Input stream which is used for the frequency analyzer
  fft = new FFT(this, bands);
  // Create a Sound object and select the second sound device (device ids start at 0) for input
  in = new AudioIn(this, 0);
  //Start the Audio Input
  in.start();
  //Patch the AudioIn
  fft.input(in);

  cloneCurves = new CloneCurve[0];
}

void keyPressed() {
  if (key == 'l' && lockedRot == false)lockedRot = true;
  else lockedRot = false;
}

void draw() {
  clear();
  background(backgroundColor);
  fft.analyze(spectrum);

  timeSlower = millis()/100f;

  //Camera and its movement
  camera((-sin(radians(timeSlower))*2000)+width/2, (cos(radians(timeSlower))*300)+400, (-cos(radians(timeSlower))*1000)+100.0, // eyeX, eyeY, eyeZ
    width/2, 650, (-cos(radians(timeSlower))*300-0), // centerX, centerY, centerZ
    0.0, 1.0, 0.0); // upX, upY, upZ

  CloneCurveSpawn();

  noFill();
  stroke(primaryColor);
  strokeWeight(1);
  pushMatrix();
  fill(primaryColor);
  //textSize(30f-smoothSpectrum[3]/50f);
  //text("//EenM", 0, spectrumCurveYPos+40);
  popMatrix();
  beginShape();
  for ( int i = -curveBands; i < curveBands; i++) {
    float targetCurveY = spectrum[abs(i)] * spectrumCurveMultiplier + spectrum[3] * spectrumJumpMultiplier;
    float dCurveEasing = targetCurveY - smoothSpectrum[abs(i)];
    smoothSpectrum[abs(i)] += dCurveEasing * curveEasingVal;

    //stroke( lerpColor( #ff0000, #ffffff, (smoothSpectrum[constrain(abs(i)+((i>0)?-1:+1), 0, curveBands)]/-30)));
    curveVertex(spectrumCurveCenter + i*curveVertexDist, smoothSpectrum[abs(i)] + spectrumCurveYPos);
  }
  endShape();

  GradientCurveDraw();
}
