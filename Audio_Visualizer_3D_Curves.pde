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

float soundAmp;

float spectrumCurveCenter = width/2;
float spectrumCurveYPos = 700;

float spectrumJumpMultiplier = -1000;

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
float gradientCurvesOnOffTransition;
float gradientCurvesDistance = 40;

float timeSlower;
float band3;

PVector[] lineShape = new PVector[120];
PVector[] circleShape = new PVector[120];

//Camera parameters
float eyeX;
float eyeY;
float eyeZ;

float centerX;
float centerY;
float centerZ;

float zoomLevel = 0;

//Manual cam rotate mouseX
float mouseXRef;
float oldYRotate;
float yRotate;

//Manual cam rotate mouseY
float mouseYRef;
float oldZRotate = radians(90);
float zRotate = radians(90);

//Manual cam move over Z
float mouseZRef;
float oldZPos;
float zPos;

//Auto cam orbit amplitude values
float xAmplitude = 1500;
float yAmplitude = 1500;
float zAmplitude = 1500;

float orbitSpeed = 0.3;

//Start colors
color backgroundColor = #181818;
color lighterBackgroundColor = #2b2b2b;
color primaryColor = #34e89e;
color secondaryColor = #0f3443;

//Start colors
// color backgroundColor = #040404;
// color lighterBackgroundColor = #2b2b2b;
// color primaryColor = #8E2DE2;
// color secondaryColor = #4A00E0;

//Background opacity fade effect
int backgroundFade = 255;

//Fill the main curve
boolean fillMainCurve = false;
//Locks the rotation of clone curves
boolean lockedTrailRot = false;
//Display front gradient curves
boolean gradientCurves = false;
//Automatically rotate camera
boolean autoCam = true;
//Are there trail curves
boolean trailCurves = true;

float shapeLerpAmount = 0;

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

  background(backgroundColor);
  noStroke();

  //Create the Input stream which is used for the frequency analyzer
  fft = new FFT(this, bands);
  // Create a Sound object and select the second sound device (device ids start at 0) for input
  in = new AudioIn(this, 0);
  //Start the Audio Input
  in.start();
  //Patch the AudioIn
  fft.input(in);

  cloneCurves = new CloneCurve[0];

  for (int i = 0; i < 120; i++){
    lineShape[i] = new PVector(-(-curveBands + i)*curveVertexDist, 0);
    circleShape[i] = new PVector(((curveBands*curveVertexDist)/2) * cos((-curveBands + i) * radians(180/curveBands) + PI/2), ((curveBands*curveVertexDist)/2) * sin((-curveBands + i) * radians(180/curveBands)+ PI/2));
  }  
}

void keyPressed() {
  if (key == 'l' && lockedTrailRot == false)lockedTrailRot = true;
  else lockedTrailRot = false;
}

void mousePressed() {
  if(mouseButton == CENTER){
    mouseXRef = mouseX;
    mouseYRef = mouseY;
  }
  if(mouseButton == RIGHT){
    mouseZRef = mouseX;
  }
}

void mouseDragged() {
  if(!autoCam){
    
    //eyeZ += map(mouseX, 0, width, -10, 10);    
  }
  if(mouseButton == CENTER){
    yRotate = oldYRotate + radians(-(mouseXRef-mouseX)/2);
    zRotate = constrain(oldZRotate + radians(map((mouseYRef-mouseY)/2, -height, height, -360, 360)), PI/6, (PI/6)*5);
  }
  if(mouseButton == RIGHT){
    //zPos += (mouseZRef-mouseX)/100f;
  }
}

void mouseReleased() {
  if(mouseButton == CENTER){
    oldYRotate = yRotate;
    oldZRotate = zRotate;
  }
  if(mouseButton == RIGHT){
    //oldZRotate = zPos;
  }
}

void mouseWheel(MouseEvent event) {
  zoomLevel = constrain(zoomLevel + event.getCount()*60, -1400, 5000); 
}

void draw() {
  beginCamera();
  frustum(-8, 8, -5, 5, 9, 50000);
  camera(eyeX, eyeY, eyeZ,
  centerX, centerY, centerZ,
   0.0, 1.0, 0.0); // upX, upY, upZ
  endCamera();

  //Background sphere
  pushMatrix();
  noStroke();
  fill(backgroundColor, backgroundFade);
  sphereDetail(20);
  sphere(7000);
  popMatrix();

  fft.analyze(spectrum);  

  //Camera and its movement
  //Rotation on axis in a circle = (sin(time)*amplitude) + pivot point
  if(autoCam){
    timeSlower += orbitSpeed;
    eyeZ = (zoomLevel + zAmplitude) * sin(zRotate + radians(timeSlower)) * cos(yRotate);
    eyeX = (zoomLevel + xAmplitude) * -sin(zRotate) * sin(yRotate + radians(timeSlower));;
    eyeY = (zoomLevel + yAmplitude) * -cos(zRotate + radians(timeSlower));
    // eyeX = (zoomLevel + 2000) * -sin(radians(timeSlower));
    // eyeY = (zoomLevel + 300) * cos(radians(timeSlower));
    // eyeZ = (zoomLevel + 1000) * -cos(radians(timeSlower));
  } else {
    // Converting spherical coordinates to rectangular
    // https://en.wikipedia.org/wiki/Spherical_coordinate_system
    // x=ρsinφcosθ 
    // y=ρsinφsinθ
    // z=ρcosφ

    eyeZ = (zoomLevel + 1500) * sin(zRotate) * cos(yRotate);
    eyeX = (zoomLevel + 1500) * -sin(zRotate) * sin(yRotate );;
    eyeY = (zoomLevel + 1500) * -cos(zRotate);
  }

  centerX = 0;
  centerY = 600;
  centerZ = 0;
  //(-cos(radians(timeSlower))*300-0)  

  if (trailCurves) {
    CloneCurveSpawn();    
  }

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

    PVector vertexPos = PVector.lerp(lineShape[curveBands + i], circleShape[curveBands + i], shapeLerpAmount);
	  curveVertex(spectrumCurveCenter + vertexPos.x, 
                smoothSpectrum[abs(i)] + spectrumCurveYPos,
                vertexPos.y);
    
    // //Old way I did circle
    // curveVertex(spectrumCurveCenter + ((curveBands*curveVertexDist)/2) * cos(i * radians(180/curveBands) + PI/2), //X pos
    //             smoothSpectrum[abs(i)] + spectrumCurveYPos, //Y pos
    //             ((curveBands*curveVertexDist)/2) * sin(i * radians(180/curveBands)+ PI/2)); //Z pos
    // //Old way I did the line
    // curveVertex(spectrumCurveCenter + i*curveVertexDist, 
    //             smoothSpectrum[abs(i)] + spectrumCurveYPos),
    //             0;
  }
  endShape((shapeLerpAmount >= 0.97f)?CLOSE:OPEN);

  //Gradient curve on off transition
  if(gradientCurves){
    println(gradientCurvesNumber);
    gradientCurvesNumber = (gradientCurvesOnOffTransition<15)?gradientCurvesOnOffTransition++:gradientCurvesOnOffTransition;
    GradientCurveDraw();
  } else if(gradientCurvesOnOffTransition > 0){
    gradientCurvesNumber = (gradientCurvesOnOffTransition>0)?gradientCurvesOnOffTransition--:gradientCurvesOnOffTransition;
    GradientCurveDraw();
  }
}
