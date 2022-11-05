class MenuScreenApplet extends PApplet {
  Button[] buttons = new Button[0];
  Slider[] sliders = new Slider[0];
  TextBox[] textBoxes = new TextBox[0];
  int buttonAmount;
  int sliderAmount;
  int textBoxAmount;

  boolean mousePresent;

  float leftMargin;
  float topMargin;
  float elementYDist;

  //Scroll bar vars
  float verticalScrollSize;
  float scrollbarHandleYpos;
  float oldScrollbarHandleYpos = 0;
  float scrollbarHandleYSize = 80;
  boolean scrolling = false;
  boolean scrollingCenter = false;
  float yScrollTranslate = 0;
  float mouseYWithScroll;

  String titleText;
  float titleTextSize;
  float titleTextPos;

  void settings() {
    size(420, 600, P2D);
  }

  void setup() {
    surface.setTitle("Menu window");
    surface.setAlwaysOnTop(true);

    //Get data from .json
    JSONArray guiLayout = layout.getJSONArray(1);
    JSONArray guiValues = layout.getJSONArray(2);

    //Get layout arguments from .json
    JSONObject layoutParameter = guiLayout.getJSONObject(0);
    leftMargin = layoutParameter.getFloat("leftMargin");
    topMargin = layoutParameter.getFloat("topMargin");
    elementYDist = layoutParameter.getFloat("elementYDist");
    float normalTextSize = layoutParameter.getFloat("normalTextSize");
    float headingTextSize = layoutParameter.getFloat("headingTextSize");
    float verticalTextPadding = layoutParameter.getFloat("verticalTextPadding");
    float elementWidth = layoutParameter.getFloat("elementWidth");

    titleText = layoutParameter.getString("titleText");
    titleTextSize = layoutParameter.getFloat("titleTextSize");
    titleTextPos = layoutParameter.getFloat("titleTextPos");

    verticalScrollSize = (topMargin + (guiValues.size() * elementYDist)) / 2;

    //Get individual element data
    for (int i = 0; i < guiValues.size(); i++) {
      JSONObject item = guiValues.getJSONObject(i);

      //Button vars
      String buttonNames;
      boolean startStates;
      boolean toggleButton;
      int buttonID;

      //Slider vars
      String sliderNames;
      float defaultSliderValues;
      float minSliderValues;
      float maxSliderValues;
      int nfLeft;
      int nfRight;
      int sliderID;

      switch(item.getString("elementType")) {
      case "heading":
        String textBoxText = item.getString("text");
        textBoxAmount += 1;
        //Create textBox
        textBoxes = (TextBox[])append(textBoxes, new TextBox(textBoxText, leftMargin, (i==0)?topMargin:(topMargin + (i * elementYDist)), headingTextSize));
        break;
      case "toggleButton":
        buttonNames = item.getString("buttonName");
        startStates = item.getBoolean("startState");
        buttonID = item.getInt("buttonID");
        toggleButton = true;
        buttonAmount += 1;
        //Create button
        buttons = (Button[])append(buttons, new Button(buttonNames, leftMargin, (i==0)?topMargin:(topMargin + (i * elementYDist)), normalTextSize, verticalTextPadding, elementWidth, startStates, toggleButton, buttonID));
        break;
      case "button":
        buttonNames = item.getString("buttonName");
        buttonID = item.getInt("buttonID");
        startStates = false;
        toggleButton = false;
        buttonAmount += 1;
        //Create button
        buttons = (Button[])append(buttons, new Button(buttonNames, leftMargin, (i==0)?topMargin:(topMargin + (i * elementYDist)), normalTextSize, verticalTextPadding, elementWidth, startStates, toggleButton, buttonID));
        break;
      case "slider":
        sliderNames = item.getString("sliderName");
        defaultSliderValues = item.getFloat("defaultValue");
        minSliderValues = item.getFloat("minValue");
        maxSliderValues = item.getFloat("maxValue");
        nfLeft = item.getInt("nfLeft");
        nfRight = item.getInt("nfRight");
        sliderID = item.getInt("sliderID");
        sliderAmount += 1;
        //Create slider
        sliders = (Slider[])append(sliders, new Slider(sliderNames, leftMargin, (i==0)?topMargin:(topMargin + (i * elementYDist)), normalTextSize, verticalTextPadding, elementWidth, minSliderValues, maxSliderValues, defaultSliderValues, nfLeft, nfRight, sliderID));
        break;
      }
    }
  }

  void mousePressed() {
    for (int i = 0; i < buttonAmount; i++) {
      buttons[i].onClick();
    }
    if (mouseX > 400) {
      scrolling = true;
      if (!scrollingCenter){
        oldScrollbarHandleYpos = mouseY - scrollbarHandleYpos;
      }      
    }
  }

  void mouseReleased() {
    scrolling = false;
    scrollingCenter = false;
  }
  
  void mouseWheel(MouseEvent event) {
    scrollbarHandleYpos = constrain(scrollbarHandleYpos + event.getCount()*40, 0, height-scrollbarHandleYSize);
  }
    
  void mouseExited() {
    mousePresent = false;
    noCursor();
  }
    
  void mouseEntered() {
    mousePresent = true;
    cursor();
  }

  void draw() {
    //Background  color of window
    background(backgroundColor);

    //Scrollbar    
    pushMatrix();
    fill(lighterBackgroundColor);
    noStroke();
    rect(400, 0, 20, height);
    fill(220);
    //Scrollbar handle
    rect(400, scrollbarHandleYpos, 20, scrollbarHandleYSize);
    popMatrix();

    yScrollTranslate = map(scrollbarHandleYpos, 0, height - scrollbarHandleYSize, 0, verticalScrollSize);
    mouseYWithScroll = mouseY + yScrollTranslate;
    translate(0, -yScrollTranslate);

    if (scrolling) {
      if ((mouseY > scrollbarHandleYpos + scrollbarHandleYSize || mouseY < scrollbarHandleYpos) || scrollingCenter) {
        scrollbarHandleYpos = constrain(mouseY - 20, 0, height-scrollbarHandleYSize);
        scrollingCenter = true;
      } else {
        scrollbarHandleYpos = constrain(mouseY - oldScrollbarHandleYpos, 0, height-scrollbarHandleYSize);
      }          
    }

    pushMatrix();
    fill(secondaryColor);
    textAlign(LEFT, TOP);
    textSize(titleTextSize);
    text(titleText, leftMargin, titleTextPos);
    popMatrix();

    for (int i = 0; i < buttonAmount; i++) {
      buttons[i].update();
    }
    for (int i = 0; i < sliderAmount; i++) {
      sliders[i].update();
    }
    for (int i = 0; i < textBoxAmount; i++) {
      textBoxes[i].update();
    }

    //Switch for updating all the button element bools and values
    for (int i = 0; i < buttonAmount; i++) {
      switch (buttons[i].buttonID) {
        case 0:
          fillMainCurve = buttons[i].buttonPressed;
          break;
        case 1:
          lockedTrailRot = buttons[i].buttonPressed;
          break;
        case 2:
          gradientCurves = buttons[i].buttonPressed;
          break;
        case 3:
          autoCam = buttons[i].buttonPressed;
          break;
        case 4:
          if(buttons[i].buttonPressed){
            timeSlower = 0;
            zRotate = radians(90);
            oldZRotate = radians(90);
            yRotate = 0;
            oldYRotate = 0;
            zPos = 0;
            oldZPos = 0;
            zoomLevel = 0;            
          }
          break;
        case 5:
          trailCurves = buttons[i].buttonPressed;
          break;
        
      }      
    }

    //Switch for updating all the slider element floats
    for (int i = 0; i < sliderAmount; i++) {
      switch (sliders[i].sliderID) {
        case 0:
          backgroundFade = int(sliders[i].sliderValue);
          break;
        case 1:
          spectrumCurveMultiplier = -sliders[i].sliderValue;
          break;
        case 2:
          xAmplitude = sliders[i].sliderValue;
          break;
        case 3:
          yAmplitude = sliders[i].sliderValue;
          break;
        case 4:
          zAmplitude = sliders[i].sliderValue;
          break;
        case 5:
          orbitSpeed = sliders[i].sliderValue;
          break;
        case 6:
          curveMaxClones = sliders[i].sliderValue;
          break;
        case 7:
          shapeLerpAmount = sliders[i].sliderValue;
          break;
        case 8:
          spectrumJumpMultiplier = -sliders[i].sliderValue;
          break;
        case 9:
          curveCloneSpawnTime = sliders[i].sliderValue;
          break;
      }      
    }
  }

  //GUI elements classes
  class Slider {
    float xpos, ypos;
    String sliderText;
    float sliderTextSize;
    float sliderTextPadding;
    float elementWidth;
    float sliderHeight;
    float sliderBoxWidth;
    float sliderInputBoxGap = 4;
    float userInputBoxWidth = 40;
    float userInputBoxXPos;

    float sliderValue;
    float sliderHandlePos;
    float sliderHandleWidth = 10;

    boolean sliderHover = false;
    boolean sliderHandleHover = false;
    boolean sliderPressed;

    float sliderMin;
    float sliderMax;

    color sliderFill;
    color textFill;

    int nfLeft;
    int nfRight;

    int sliderID;

    Slider(String pSliderText, float pXpos, float pYpos, float pSliderTextSize, float pSliderTextPadding, float pElementWidth, float pSliderMin, float pSliderMax, float defaultSliderValue, int pNfLeft, int pNfRight, int pSliderID) {
      sliderText = pSliderText;
      xpos= pXpos;
      ypos= pYpos;
      sliderValue = defaultSliderValue;
      sliderTextSize = pSliderTextSize;
      elementWidth = pElementWidth;
      sliderBoxWidth = elementWidth - (sliderInputBoxGap + userInputBoxWidth);
      sliderHeight = sliderTextSize + pSliderTextPadding;
      sliderFill = secondaryColor;
      textFill = color(255);
      sliderID = pSliderID;      
      userInputBoxXPos = xpos + sliderBoxWidth + sliderInputBoxGap;
      sliderMin = pSliderMin;
      sliderMax = pSliderMax;
      sliderHandlePos = map(sliderValue, sliderMin, sliderMax, xpos, sliderBoxWidth + leftMargin - sliderHandleWidth);
      nfLeft = pNfLeft;
      nfRight = pNfRight;
    }

    void update() {
      //Background boxes
      pushMatrix();
        noStroke();
        fill(lighterBackgroundColor);
        //main slider box
        rect(xpos, ypos, sliderBoxWidth, sliderHeight, 5);
        //User input box
        rect(userInputBoxXPos, ypos, userInputBoxWidth, sliderHeight, 5);      
      popMatrix();      

      stroke(secondaryColor);

      if (mousePressed && (mouseButton == LEFT) && sliderHover && !scrolling) {        
        sliderFill = primaryColor;
        sliderPressed = true;
        textFill = backgroundColor;
        sliderHandlePos = constrain(mouseX - (sliderHandleWidth/2), xpos, sliderBoxWidth + leftMargin - sliderHandleWidth);
      } else {        
        sliderFill = secondaryColor;
        sliderPressed = false;
        textFill = color(255);
      }  

      fill(sliderFill);

      //Check if mouse is hovering over slider element and react
      if (mouseX > xpos && mouseX < elementWidth + xpos &&
        mouseYWithScroll > ypos && mouseYWithScroll < sliderHeight + ypos) {
        sliderHover = true;
        stroke(primaryColor);
      } else {
        sliderHover = false;
      }

      //Check if mouse is hovering over slider handle element and react
      if (mouseX > sliderHandlePos && mouseX <  sliderHandlePos + sliderHandleWidth &&
        mouseYWithScroll > ypos && mouseYWithScroll < sliderHeight + ypos) {
        sliderHandleHover = true;
      } else {
        sliderHandleHover = false;
      }
      
      //Slider fill rect
      rect(xpos, ypos, sliderHandlePos - leftMargin + sliderHandleWidth, sliderHeight, 5);
      
      fill(textFill);
      //Slider handle
      rect(sliderHandlePos, ypos, sliderHandleWidth, sliderHeight, 5);
      //Slider text
      textAlign(LEFT, CENTER);
      textSize(sliderTextSize);
      text(sliderText, xpos + 5, ypos, sliderBoxWidth, sliderHeight);
      //Slider value text
      fill(255);
      textAlign(RIGHT, CENTER);
      textSize(sliderTextSize);
      text(((nfRight == 0)? nf(int(sliderValue), nfLeft):nf(sliderValue, nfLeft, nfRight)), userInputBoxXPos, ypos, userInputBoxWidth - 5, sliderHeight);      

      sliderValue = map(sliderHandlePos, xpos, sliderBoxWidth + leftMargin - sliderHandleWidth, sliderMin, sliderMax);
    }

  }

  class TextBox {
    float xpos, ypos;
    float elementWidth = 300;
    String textBoxText;
    float textBoxTextSize;
    float textBoxHeight;

    TextBox(String pTextBoxText, float pXpos, float pYpos, float pTextBoxTextSize){
      textBoxText = pTextBoxText;
      xpos= pXpos;
      ypos= pYpos;
      textBoxTextSize = pTextBoxTextSize;
      textBoxHeight = pTextBoxTextSize + 20;
    }

    void update(){
      fill(secondaryColor);
      textAlign(LEFT, CENTER);
      textSize(textBoxTextSize);
      text(textBoxText, xpos, ypos, elementWidth, textBoxHeight);
    }
  }

  class Button {
    float xpos, ypos;
    String buttonText;
    float buttonTextSize;
    float buttonTextPadding;
    float elementWidth;
    float buttonHeight;

    boolean buttonHover = false;
    boolean buttonPressed;

    color buttonFill;
    color textFill;

    boolean toggleButton;

    int buttonID;

    Button(String pButtonText, float pXpos, float pYpos, float pButtonTextSize, float pButtonTextPadding, float pButtonWidth, boolean startState, boolean pToggleButton, int pButtonID) {
      buttonText = pButtonText;
      xpos= pXpos;
      ypos= pYpos;
      buttonTextSize = pButtonTextSize;
      buttonTextPadding = pButtonTextPadding;
      elementWidth = pButtonWidth;
      buttonHeight = buttonTextSize + buttonTextPadding;
      buttonFill = startState?primaryColor:secondaryColor;
      textFill = startState?backgroundColor:color(255);
      buttonPressed = startState;
      toggleButton = pToggleButton;
      buttonID = pButtonID;
    }

    void onClick() {
      if (toggleButton) {
        //Toggle button fill color and buttonPressed bool if button pressed
        if (!buttonPressed && (mouseButton == LEFT) && buttonHover) {
          buttonFill = primaryColor;
          buttonPressed = true;
          textFill = backgroundColor;
        } else if ((mouseButton == LEFT) && buttonHover) {
          buttonFill = secondaryColor;
          buttonPressed = false;
          textFill = color(255);
        }
      }
    }

    void update() {
      stroke(secondaryColor);

      if(!toggleButton){
        if (mousePressed && (mouseButton == LEFT) && buttonHover) {
          buttonFill = primaryColor;
          buttonPressed = true;
          textFill = backgroundColor;
        } else {
          buttonFill = secondaryColor;
          buttonPressed = false;
          textFill = color(255);
        }
      }      

      fill(buttonFill);
      //Check if mouse is hovering over button and react
      if (mouseX > xpos && mouseX < elementWidth + xpos &&
        mouseYWithScroll > ypos && mouseYWithScroll < buttonHeight + ypos) {
        buttonHover = true;
        stroke(primaryColor);
      } else {
        buttonHover = false;
      }

      rect(xpos, ypos, elementWidth, buttonHeight, 5);
      fill(textFill);
      textAlign(CENTER, CENTER);
      textSize(buttonTextSize);
      if (toggleButton) {
        text(buttonText + ": " + (buttonPressed?"On":"Off"), xpos, ypos, elementWidth, buttonHeight);
      } else {
        text(buttonText, xpos, ypos, elementWidth, buttonHeight);
      }
    }
  }
}
