class MenuScreenApplet extends PApplet {
  Button[] buttons = new Button[0];
  int buttonAmount;

  float leftMargin;

  String titleText;
  float titleTextSize;
  float titleTextPos;

  void settings() {
    size(600, 500, P2D);
  }

  void setup(){
    surface.setTitle("Menu window");    

    JSONArray buttonLayout = layout.getJSONArray(0);
    JSONArray buttonValues = layout.getJSONArray(1);
    buttonAmount = buttonValues.size();

    JSONObject layoutParameter = buttonLayout.getJSONObject(0);
    leftMargin = layoutParameter.getFloat("leftMargin");
    float topMargin = layoutParameter.getFloat("topMargin");
    float elementYDist = layoutParameter.getFloat("elementYDist");
    float normalTextSize = layoutParameter.getFloat("normalTextSize");
    float verticalTextPadding = layoutParameter.getFloat("verticalTextPadding");
    float buttonWidth = layoutParameter.getFloat("buttonWidth");

    titleText = layoutParameter.getString("titleText");
    titleTextSize = layoutParameter.getFloat("titleTextSize");
    titleTextPos = layoutParameter.getFloat("titleTextPos");    

    for (int i = 0; i < buttonValues.size(); i++) {    
        JSONObject item = buttonValues.getJSONObject(i); 

        String buttonNames = item.getString("buttonName");
        boolean startStates = item.getBoolean("startState");

        //Create buttons
        buttons = (Button[])append(buttons, new Button(buttonNames, leftMargin, (i==0)?topMargin:(topMargin + (i * elementYDist)), normalTextSize, verticalTextPadding, buttonWidth, primaryColor, secondaryColor, startStates));     
    }
  }

  void mousePressed(){
    for (int i = 0; i < buttonAmount; i++){
        buttons[i].onClick();
    }
  }

  void draw() {
    if (focused) {
      cursor();
    } else {
      noCursor();
    }
    background(backgroundColor);

    pushMatrix();
    fill(secondaryColor);
    textAlign(LEFT, TOP);
    textSize(titleTextSize);
    text(titleText, leftMargin, titleTextPos);
    popMatrix();    

    for (int i = 0; i < buttonAmount; i++){
        buttons[i].update();
    }

    lockedTrailRot = buttons[0].buttonPressed;
    gradientCurves = buttons[1].buttonPressed;
  }

  //UI elements classes
  class Button {
    float xpos, ypos;
    String buttonText;
    float buttonTextSize;
    float buttonTextPadding;
    float buttonWidth;
    float buttonHeight;

    color primaryColor;
    color secondaryColor;

    boolean buttonHover = false;
    boolean buttonPressed;

    color buttonFill;
    color textFill;

    Button(String pButtonText, float pXpos, float pYpos, float pButtonTextSize, float pButtonTextPadding, float pButtonWidth, color pPrimaryColor, color pSecondaryColor, boolean startState) {
      buttonText = pButtonText;
      xpos= pXpos;
      ypos= pYpos;
      buttonTextSize = pButtonTextSize;
      buttonTextPadding = pButtonTextPadding;
      buttonWidth = pButtonWidth;
      buttonHeight = buttonTextSize + buttonTextPadding;
      primaryColor = pPrimaryColor;
      secondaryColor = pSecondaryColor;
      buttonFill = startState?primaryColor:secondaryColor;
      textFill = startState?backgroundColor:color(255);
      buttonPressed = startState;
    }

    void onClick(){
        //Toggle button fill color and buttonPressed bool if button pressed
        if (!buttonPressed && (mouseButton == LEFT) && buttonHover) {
            buttonFill = primaryColor;
            buttonPressed = true;
            textFill = backgroundColor;
        }else if ((mouseButton == LEFT) && buttonHover) {
            buttonFill = secondaryColor;
            buttonPressed = false;
            textFill = color(255);
        }
    }

    void update() {
        stroke(secondaryColor);
        fill(buttonFill);

        //Check if mouse is hovering over button and react
        if (mouseX > xpos && mouseX < buttonWidth + xpos &&
            mouseY > ypos && mouseY < buttonHeight + ypos) {
            buttonHover = true;
            stroke(primaryColor);
        } else {
            buttonHover = false;
        }

        rect(xpos, ypos, buttonWidth, buttonHeight, 5);
        fill(textFill);
        textAlign(CENTER, CENTER);
        textSize(buttonTextSize);
        text(buttonText + ": " + (buttonPressed?"On":"Off"), xpos, ypos, buttonWidth, buttonHeight);
    }
  }
}
