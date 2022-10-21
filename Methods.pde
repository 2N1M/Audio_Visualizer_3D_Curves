void CloneCurveSpawn() {
  //Spawn curve clone at the main curve on a timer
  if (millis() - curveCloneTimer > curveCloneSpawnTime) {
    cloneCurves = (CloneCurve[])append(cloneCurves, new CloneCurve(smoothSpectrum));
    if (cloneCurves.length > curveMaxClones) {
      //Because the way the array is set up (new curves are "spawned" at the main curve and then translated backwards)
      //it needs to be reversed (because I am using shorten which takes the last appended element and removes it) becasue
      //else it will "despawn" the curve nearest to the main curve
      cloneCurves = (CloneCurve[])reverse(cloneCurves);
      cloneCurves = (CloneCurve[])shorten(cloneCurves);
      cloneCurves = (CloneCurve[])reverse(cloneCurves);
    }
    curveCloneTimer = millis();
  }

  //Update all clone curves, translate them backward to give trail effect
  if (cloneCurves.length != 0) {
    for (int i = 0; i < cloneCurves.length; i++) {
      cloneCurves[i].update();
    }
  }
}

//Create curves in front of the main curve that are coloured in a gradient
void GradientCurveDraw() {
  noFill();
  for (int j = 1; j <=gradientCurvesNumber; j++) {
    beginShape();

    for ( int i = curveBands; i > -curveBands; i--) {
      stroke(primaryColor, 255-j*(255/gradientCurvesNumber));
      curveVertex(spectrumCurveCenter + i*curveVertexDist, smoothSpectrum[abs(i)]/ lerp(1, 2, j) + spectrumCurveYPos, gradientCurvesDistance + j* gradientCurvesDistance);
    }
    endShape();
  }
}
