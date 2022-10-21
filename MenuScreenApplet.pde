public class MenuScreenApplet extends PApplet {
  Button testButton = new Button("Test", 50, 50, 50, 20, 100, primaryColor, secondaryColor);
  boolean mousePressedBool;

  public void settings() {
    size(500, 500, P2D);
  }

  void mousePressed(){
    if (mousePressedBool){
        mousePressedBool = false;
    }else{
        mousePressedBool = true;
    }
  }

  public void draw() {
    if (focused) {
      cursor();
    } else {
      noCursor();
    }
    background(backgroundColor);

    testButton.update(mousePressedBool);
  }

  //UI elements classes
  class Button {
    int xpos, ypos;
    String buttonText;
    float buttonTextSize;
    int buttonTextPadding;
    int buttonWidth;
    float buttonHeight;

    color primaryColor;
    color secondaryColor;

    boolean buttonHover = false;
    boolean buttonPressed = false;

    color buttonFill;

    Button(String pButtonText, int pXpos, int pYpos, float pButtonTextSize, int pButtonTextPadding, int pButtonWidth, color pPrimaryColor, color pSecondaryColor) {
      buttonText = pButtonText;
      xpos= pXpos;
      ypos= pYpos;
      buttonTextSize = pButtonTextSize;
      buttonTextPadding = pButtonTextPadding;
      buttonWidth = pButtonWidth;
      buttonHeight = buttonTextSize + buttonTextPadding;
      primaryColor = pPrimaryColor;
      secondaryColor = pSecondaryColor;
      buttonFill = pSecondaryColor;
    }

    void update(boolean pMousePressed) {
        stroke(secondaryColor);
        fill(buttonFill);

        if (mouseX > xpos && mouseX < buttonWidth + xpos &&
            mouseY > ypos && mouseY < buttonHeight + ypos) {
            buttonHover = true;
            stroke(primaryColor);
        } else {
            buttonHover = false;
        }

        //Toggle button fill color and buttonPressed bool
        if (pMousePressed && (mouseButton == LEFT) && buttonHover) {
            buttonFill = primaryColor;
            buttonPressed = true;
        }else if (!pMousePressed && (mouseButton == LEFT) && buttonHover) {
            buttonFill = secondaryColor;
            buttonPressed = false;
        }

        rect(xpos, ypos, buttonWidth, buttonHeight);
        fill(backgroundColor);
        textSize(buttonTextSize);
        text(buttonText, xpos, ypos, buttonWidth, buttonHeight);
    }
  }
}
