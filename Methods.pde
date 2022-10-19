void CloneCurveSpawn(){
   //Updating curve clone
  if (millis() - curveCloneTimer > curveCloneSpawnTime) {
    cloneCurves = (CloneCurve[])append(cloneCurves, new CloneCurve(smoothSpectrum));
    if (cloneCurves.length > curveMaxClones) {
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

void GradientCurveDraw(){
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
