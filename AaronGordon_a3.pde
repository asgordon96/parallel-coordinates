Line line;
Data d;
ParallelCoordinates pc;

void setup() {
  size(900, 500);
  d = new Data("data.csv");
  pc = new ParallelCoordinates(d);
}

void draw() {
  background(255, 255, 255);
  pc.draw();
}

void mouseDragged() {
  pc.mouse_dragged();
}
void mousePressed(){
  pc.mouse_pressed();
}

void mouseMoved() {
  pc.mouse_moved();
}

void mouseReleased() {
  pc.axes.mouse_released();
}

void mouseClicked() {
  if (pc.axes.mouse_clicked()) {
    pc.update_show_hide();
  }
  else {
    pc.bounding_box.make_invisible();
    pc.update_show_hide();
  }
}