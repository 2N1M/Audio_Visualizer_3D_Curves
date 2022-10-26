import processing.sound.*;
FFT fft;
AudioIn in;

//Menu layout
JSONArray layout;

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
float spectrumCurveMultiplier = -1500;

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

//Camera parameters
float eyeX;
float eyeY;
float eyeZ;

float centerX;
float centerY;
float centerZ;

//Start colors
color backgroundColor = #181818;
color primaryColor = #34e89e;
color secondaryColor = #0f3443;

//Fill the main curve
boolean fillMainCurve = true;
//Locks the rotation of clone curves
boolean lockedTrailRot = false;
//Display front gradient curves
boolean gradientCurves = true;
//Automatically rotate camera
boolean autoCam = true;

CloneCurve[] cloneCurves;

//Set fullscreen and set window icon
public void settings() {
  fullScreen(P3D);
  //size(1500, 1000, P3D);
  PJOGL.setIcon("data/icon.png");
}

void setup() {
  surface.setTitle("AV3D");
  //Load JSON and retrieve JSONArray 
  layout = loadJSONArray("layout.json");

  String[] args = {"Audio_Visualizer_3D_Curves"};
  MenuScreenApplet menuScreen = new MenuScreenApplet();
  PApplet.runSketch(args, menuScreen);

  noCursor();
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
  if (key == 'l' && lockedTrailRot == false)lockedTrailRot = true;
  else lockedTrailRot = false;
}

void draw() {
  //clear();
  //background(backgroundColor);
  pushMatrix();
  fill(backgroundColor, 255);
  sphere(7000);
  popMatrix();

  fft.analyze(spectrum);  

  //Camera and its movement
  //Rotation on axis in a circle = (sin(time)*amplitude) + pivot point
  if(autoCam){
    timeSlower += 0.3;
    eyeX = (-sin(radians(timeSlower))*2000)+width/2;
    eyeY = (cos(radians(timeSlower))*300)+400;
    eyeZ = (-cos(radians(timeSlower))*1000)+100.0;
  }else{

  }

  centerX = width/2;
  centerY = 650;
  centerZ = 0;
  //(-cos(radians(timeSlower))*300-0)
  
  
  camera(eyeX, eyeY, eyeZ,
    centerX, centerY, centerZ,
    0.0, 1.0, 0.0); // upX, upY, upZ

  CloneCurveSpawn();

  noFill();
  stroke(primaryColor);
  strokeWeight(1);
  pushMatrix();
  if(fillMainCurve){
    fill(primaryColor);
  }else{
    noFill();
  }
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


  if(gradientCurves){
    GradientCurveDraw();
  }
}
