// class to represent a single line segment
// defined by its end points

class Line {
  float left_x, left_y, right_x, right_y;
  float slope, intercept;
  color c;
  int stroke_weight = 1;
  float y_buffer; // for hovering
  
  Line(float x1, float y1, float x2, float y2, color c) {
    this.c = c;
    set_position(x1, y1, x2, y2);
  }
  
  void draw() {
    stroke(c);
    strokeWeight(stroke_weight);
    //line(left_x, left_y, right_x, right_y);
    beginShape();
    vertex(left_x, left_y);
    vertex(right_x, right_y);
    endShape();
    strokeWeight(1);
  }
  
  void set_color(color c) {
    this.c = c;
  }
  
  void set_stroke_weight(int w) {
    stroke_weight = w;
  }
  
  void set_position(float x1, float y1, float x2, float y2) {
    if (x1 > x2) {
      left_x = x2;
      left_y = y2;
      right_x = x1;
      right_y = y1;
    }
    else {
      left_x = x1;
      left_y = y1;
      right_x = x2;
      right_y = y2;
    }
    
    // calculate the slope and intercept based on the endpoints
    slope = (y2 - y1) / (x2 - x1);
    intercept = y1 - slope*x1;
    
    float theta = atan(slope);
    y_buffer = Config.hover_buffer / sin(PI/2 - theta);
  }
  
  boolean mouse_over() {
    if (mouseX >= left_x && mouseX <= right_x) {
      float line_y = mouseX * slope + intercept;
      if (mouseY >= line_y - y_buffer && mouseY <= line_y + y_buffer) {
        return true;
      }
    }
    return false;
  }
  
  // return true if this line intersect with a horizontal line
  // with the left point at (x, y) and of length len
  boolean intersect_horizontal(float x, float y, float len) {
    float max_y = max(left_y, right_y);
    float min_y = min(left_y, right_y);
    if (max_y < y || min_y > y) {
      return false;
    }
    float x_value = (y - intercept) / slope;
    return x_value >= x && x_value <= x + len;
  }
  
  // return true if this line intersect with a vertical line
  // with the top point at (x, y) and of length len
  boolean intersect_vertical(float x, float y, float len) {
    if (left_x > x || right_x < x) {
      // no overlap in the x direction, so they cannot intersect
      return false;
    }
    float y_value = slope*x + intercept;
    return y_value >= y && y_value <= y + len;
  }
  
  
  // check if any part of the line is within the rectangle with upper left hander corner
  // at (x, y) with width rect_width and height rect_height
  boolean in_rect(float x, float y, float rect_width, float rect_height) {
    // first check if the line is completely contained within the rectangle
    float min_y = min(left_y, right_y);
    float max_y = max(left_y, right_y);
    if (left_x >= x && right_x <= x + rect_width && min_y >= y && max_y <= y + rect_height) {
      return true;
    }
    // check intersections with all 4 sides of the box
    return intersect_horizontal(x, y, rect_width) || intersect_horizontal(x, y + rect_height, rect_width) ||
           intersect_vertical(x, y, rect_height) || intersect_vertical(x + rect_width, y, rect_height);
  }
}