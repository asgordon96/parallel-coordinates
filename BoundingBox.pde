// box that is drawn when the user clicks and drags
class BoundingBox {
  float start_x, start_y; // starting corner
  float offset_x, offset_y; // x and y offsets for where the user clicked inside the box to move it
  float x, y; // current top left corner of the box
  float box_width, box_height;
  boolean visible;
  color bounding_box_fill = color(180, 180, 180, 100);
  int DRAW_MODE = 0; // user drawing the bounding box
  int MOVE_MODE = 1; // user moving the bounding box
  int INVISIBLE_MODE = 2; // dont' draw the box
  int mode = DRAW_MODE;
  
  BoundingBox() {
    visible = false;
  }
  
  void mouse_pressed() {
    if (visible && mouse_inside()) {
      // click inside of a visible box => move mode;
      offset_x = mouseX - x;
      offset_y = mouseY - y;
      mode = MOVE_MODE;
    }
    else {
      // click outside or no box visible => draw mode
      start_x = mouseX;
      start_y = mouseY;
      visible = false;
      mode = DRAW_MODE;
    }
  }
  
  void mouse_dragged() {
    visible = true;
    if (mode == DRAW_MODE) {
      // update the width, height, and top left (x, y) in response to mouse drag
      if (mouseX > start_x) {
        x = start_x;
        box_width = mouseX - start_x;
      }
      else {
        x = mouseX;
        box_width = start_x - mouseX;
      }
      if (mouseY > start_y) {
        y = start_y;
        box_height = mouseY - start_y;
      }
      else {
        y = mouseY;
        box_height = start_y - mouseY;
      }
    }
    else {
      // dragging to move an existing box
      x = mouseX - offset_x;
      y = mouseY - offset_y;
    }
  }
  
  boolean mouse_inside() {
    return mouseX >= x && mouseX <= x + box_width && mouseY >= y && mouseY <= y + box_height;
  }
  
  void draw() {
    if (visible && mode != INVISIBLE_MODE) {
      rectMode(CORNER);
      fill(bounding_box_fill);
      strokeWeight(1);
      stroke(color(0, 0, 0));
      rect(x, y, box_width, box_height);
    }
  }
  
  void make_invisible() {
    mode = INVISIBLE_MODE;
  }
  
  void clear() {
    box_width = 0;
    box_height = 0;
  }
}