// class representing a tooltip (a box with text in it)
// (x, y) is the location that the tooltip points to
class Tooltip {
  float x, y;
  String text_line1, text_line2;
  PFont font;
  Tooltip(String text_line1, String text_line2, float x, float y) {
    this.text_line1 = text_line1;
    this.text_line2 = text_line2;
    this.x = x;
    this.y = y;
    this.font = createFont("Arial", 14);
  }
  
  void draw() {
    int padding = 5;
    float text_width = max(textWidth(text_line1), textWidth(text_line2));
    float text_height;
    
    if (text_line2.equals("")) {
      text_height= textAscent() + textDescent();
    }
    else {
      text_height = 2*(textAscent() + textDescent());
    }
    
    // first draw the box with a pointer
    float rect_width = text_width + 2*padding;
    float rect_height = text_height + 2*padding;
    float point_height = 10;
    float point_width = 10;
    
    float x2, point_x, text_x;
    if (x + rect_width > width) {
      // hanging off the right edge, so draw it to the left
      x2 = x - rect_width;
      point_x = x - point_width;
      text_x = x - rect_width + padding; 
    }
    else {
      x2 = x + rect_width;
      point_x = x + point_width;
      text_x = x + padding;
    }
    
    stroke(0, 0, 0);
    fill(255, 255, 255);
    beginShape();
    vertex(x, y);
    vertex(x, y - point_height - rect_height);
    vertex(x2, y - point_height - rect_height);
    vertex(x2, y - point_height);
    vertex(point_x, y - point_height);
    endShape(CLOSE);
    
    textAlign(LEFT, TOP);
    textFont(font);

    fill(0, 0, 0);
    text(text_line1, text_x, y - point_height - rect_height + padding);
    text(text_line2, text_x, y - point_height - rect_height + 0.5*padding + rect_height / 2);
  }
}