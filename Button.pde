class Button {
  float x, y, b_width, b_height;
  String b_text;
  PFont font;
  
  Button(String b_text) {
    this.b_text = b_text;
    font = createFont("Arial", 16, true);
  }
  
  void set_position(float x, float y, float b_width, float b_height) {
    this.x = x;
    this.y = y;
    this.b_width = b_width;
    this.b_height = b_height;
  }
  
  void draw() {
    fill(Config.button_fill_color);
    rectMode(CENTER);
    rect(x, y, b_width, b_height, Config.button_corner_rounding);
    textFont(font);
    fill(Config.button_text_color);
    textAlign(CENTER, CENTER);
    text(b_text, x, y);
    
    // other parts of the program assume rect mode is corner
    rectMode(CORNER);
  }
  
  // returns true if the mouse is currently inside the button box
  boolean mouseInButton() {
    return (mouseX >= x - b_width/2 && mouseX <= x + b_width/2 && mouseY >= y - b_height/2 && mouseY <= y + b_height/2);
  }
}