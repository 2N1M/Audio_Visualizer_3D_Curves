class CloneCurve {
  //Create clone freq spectrum array for trail effect
  float[] cloneSpectrum = new float[bands];
  float zPos;
  float zRot;
  float rotSpeed = 0;
  float rotSpeed2 = 0.001;
  float speed = 8;
  float alpha = 255;
  float dimSpeed = 0.7;
  CloneCurve(float[] curveVertsArray) {
    arrayCopy(curveVertsArray, cloneSpectrum);
  }
  void update() {
    zPos -= speed;
    zRot -= rotSpeed;
    rotSpeed += lockedTrailRot?0:map(mouseX, 0, width, -0.005f, 0.005f);
    alpha -= dimSpeed;
    pushMatrix();
    noFill();
    stroke(lerpColor(primaryColor, secondaryColor, alpha/255), alpha);
    translate(0, 0, zPos);
    beginShape();
    rotateZ(radians(zRot));
    for ( int i = -curveBands; i < curveBands; i++) {
      //stroke( lerpColor( #ff0000, #ffffff, (cloneSpectrum[constrain(abs(i)+10,0,curveBands)]-650)/-60) );
      curveVertex(spectrumCurveCenter + i*curveVertexDist, cloneSpectrum[abs(i)] + spectrumCurveYPos);
    }
    endShape();
    popMatrix();
  }
}
