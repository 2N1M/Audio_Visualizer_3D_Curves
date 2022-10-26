class MenuScreenApplet extends PApplet {
  Button[] buttons = new Button[0];
  TextBox[] textBoxes = new TextBox[0];
  int buttonAmount;
  int textBoxAmount;

  float leftMargin;
  float elementWidth;

  String titleText;
  float titleTextSize;
  float titleTextPos;

  void settings() {
    size(400, 600, P2D);
  }

  void setup() {
    surface.setTitle("Menu window");

    //Get data from .json
    JSONArray guiLayout = layout.getJSONArray(1);
    JSONArray guiValues = layout.getJSONArray(2);

    //Get layout arguments from .json
    JSONObject layoutParameter = guiLayout.getJSONObject(0);
    leftMargin = layoutParameter.getFloat("leftMargin");
    float topMargin = layoutParameter.getFloat("topMargin");
    float elementYDist = layoutParameter.getFloat("elementYDist");
    float normalTextSize = layoutParameter.getFloat("normalTextSize");
    float headingTextSize = layoutParameter.getFloat("headingTextSize");
    float verticalTextPadding = layoutParameter.getFloat("verticalTextPadding");
    elementWidth = layoutParameter.getFloat("elementWidth");

    titleText = layoutParameter.getString("titleText");
    titleTextSize = layoutParameter.getFloat("titleTextSize");
    titleTextPos = layoutParameter.getFloat("titleTextPos");

    //Get individual element data
    for (int i = 0; i < guiValues.size(); i++) {
      JSONObject item = guiValues.getJSONObject(i);

      String buttonNames;
      boolean startStates;
      boolean toggleButton;
      int buttonID;

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
        buttons = (Button[])append(buttons, new Button(buttonNames, leftMargin, (i==0)?topMargin:(topMargin + (i * elementYDist)), normalTextSize, verticalTextPadding, elementWidth, primaryColor, secondaryColor, startStates, toggleButton, buttonID));
        break;
      case "button":
        buttonNames = item.getString("buttonName");
        buttonID = item.getInt("buttonID");
        startStates = false;
        toggleButton = false;
        buttonAmount += 1;
        //Create button
        buttons = (Button[])append(buttons, new Button(buttonNames, leftMargin, (i==0)?topMargin:(topMargin + (i * elementYDist)), normalTextSize, verticalTextPadding, elementWidth, primaryColor, secondaryColor, startStates, toggleButton, buttonID));
        break;
      }
    }
  }

  void mousePressed() {
    for (int i = 0; i < buttonAmount; i++) {
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

    for (int i = 0; i < buttonAmount; i++) {
      buttons[i].update();
    }
    for (int i = 0; i < textBoxAmount; i++) {
      textBoxes[i].update();
    }

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
          
          break;
      }      
    }
  }

  //GUI elements classes
  class TextBox {
    float xpos, ypos;
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

    color primaryColor;
    color secondaryColor;

    boolean buttonHover = false;
    boolean buttonPressed;

    color buttonFill;
    color textFill;

    boolean toggleButton;

    int buttonID;

    Button(String pButtonText, float pXpos, float pYpos, float pButtonTextSize, float pButtonTextPadding, float pButtonWidth, color pPrimaryColor, color pSecondaryColor, boolean startState, boolean pToggleButton, int pButtonID) {
      buttonText = pButtonText;
      xpos= pXpos;
      ypos= pYpos;
      buttonTextSize = pButtonTextSize;
      buttonTextPadding = pButtonTextPadding;
      elementWidth = pButtonWidth;
      buttonHeight = buttonTextSize + buttonTextPadding;
      primaryColor = pPrimaryColor;
      secondaryColor = pSecondaryColor;
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
        mouseY > ypos && mouseY < buttonHeight + ypos) {
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
