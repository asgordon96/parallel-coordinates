// the LineRow class represents a single row of the data
// and knows how to draw itself and detect mouse hovers
class LineRow {
  YAxesGroup axes;
  float[] row;
  String row_label;
  Line[] lines;
  boolean hidden = false;
  int num_segments;
  boolean highlighted = false;
  
  LineRow(YAxesGroup axes, float[] row, String row_label) {
    this.axes = axes;
    this.row = row;
    this.row_label = row_label;
    
    num_segments = axes.num_axes - 1;
    lines = new Line[num_segments];
    
    // initialize the lines, but don't set the (x,y) values yet
    // the are set each time draw() is called
    for (int i=0; i < num_segments; i++) {
      lines[i] = new Line(0, 0, 0, 0, color(0, 0, 0));
    }
  }
  
  void draw() {
    float[][] coordinates = axes.get_coordinates(row);
    float[] x_coords = coordinates[0];
    float[] y_coords = coordinates[1];
    
    // color is either gray if hidden, or based on selected axis
    color c;
    int stroke_weight = Config.normal_weight;
    
    if (hidden) {
      c = color(180, 180, 180, 150);
    }
    else {
      // calculate the color for these line segments based on the selected axis
      int selected_axis = axes.coloring_axis_index;
      c = axes.get_axis(selected_axis).get_color(row[selected_axis]);
      
      if (highlighted) {
        stroke_weight = Config.highlighted_weight;
        c = color(0, 0, 0);
      }
    }

    // draw each line segment
    for (int i=0; i < num_segments; i++) {
      lines[i].set_color(c);
      lines[i].set_stroke_weight(stroke_weight);
      lines[i].set_position(x_coords[i], y_coords[i], x_coords[i+1], y_coords[i+1]);
      lines[i].draw();
    }
  }
  
  // check if the mouse is on top of any of the line segments for this data point
  boolean mouse_hover() {
    // if this line is hidden, don't respond to mouse hovering
    if (hidden) {
      return false;
    }
    
    for (int i=0; i < num_segments; i++) {
      if (lines[i].mouse_over()) {
        highlighted = true;
        return true;
      }
    }
    highlighted = false;
    return false;
  }
  
  boolean intersect_box(BoundingBox bb) {
    boolean intersects = false;
    for (int i=0; i < num_segments; i++) {
      if (lines[i].in_rect(bb.x, bb.y, bb.box_width, bb.box_height)) {
        intersects = true;
      }
    }
    return intersects;
  }
  
  // given the index (starting at 0) of the column (variable)
  // get the value of the variable
  float get_value(int col_index) {
    return row[col_index];
  }
  
  // return a list of tooltips with the values for each dimension
  Tooltip[] get_tooltips() {
    Tooltip[] tooltips = new Tooltip[row.length+1];
    for (int i=0; i < row.length; i++) {
      YAxis axis = axes.axes[i];
      String text_line1 = axis.label;
      String text_line2 = str(row[i]); 
      Tooltip tp = new Tooltip(text_line1, text_line2, axis.rect_x + axis.rect_width / 2, axis.get_y(row[i]));
      tooltips[i] = tp;
    }
    tooltips[row.length] = new Tooltip(row_label, "", mouseX, mouseY);
    return tooltips;
    
  }
  
  // "hide" this line by making it light gray and somewhat transparent
  void hide() {
    hidden = true;
  }
  
  void unhide() {
    hidden = false;
  }
}