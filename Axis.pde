// includes all of the y axes for parallel coordinates
class YAxesGroup {
  Data data;
  YAxis[] axes;
  int num_axes;
  int coloring_axis_index = 0; // the index (starting at 0) of the axis currently used to color the lines
  
  YAxesGroup(Data data) {
    this.data = data;
    create_axes();
  }
  
  void create_axes() {
    num_axes = data.num_dim;
    axes = new YAxis[num_axes];
    for (int i=0; i < num_axes; i++) {
      axes[i] = new YAxis(i, num_axes, data.column_labels[i], data.get_min_value(i), data.get_max_value(i), Config.axis_color);
    }
  }
  
  // given a single row of data, return the (x, y) coordinates 
  // at the axes
  float[][] get_coordinates(float[] row) {
    float[][] coordinates = new float[2][num_axes];
    
    for (int i=0; i < num_axes; i++) {
      float x = axes[i].get_center_x();
      float y = axes[i].get_y(row[i]);
      coordinates[0][i] = x;
      coordinates[1][i] = y;
    }
    return coordinates;
  }
  
  void draw(PGraphics top_layer) {
    for (int i=0; i < num_axes; i++) {
      // highlight the axis that we are coloring the lines by
      color axis_color;
      if (i == coloring_axis_index) {
        axis_color = Config.axis_highlight;
      }
      else {
        axis_color = Config.axis_color;
      }
      axes[i].set_color(axis_color);
      axes[i].draw(top_layer);
    }
  }
  
  YAxis get_axis(int index) {
    return axes[index];
  }
  
  // return true is this line_row is in the range of the selected axes
  boolean in_range(LineRow line_row) {
    for (int i=0; i < num_axes; i++) {
      if (!axes[i].in_range(line_row.get_value(i))) {
        return false; // if it is out of range on a single axis, return false
      }
    }
    return true;
  }
  
  void clear_ranges() {
    for (int i=0; i < num_axes; i++) {
      axes[i].clear_range();
    }
  }
  
  // returns true is there is a mouse press on any of the axes
  boolean mouse_pressed() {
    // check for mouse clicks within the axes
    // and if there is one, change the coloring to that axis
    boolean press = false;
    for (int i=0; i < num_axes; i++) {
      if (axes[i].mouse_over()) {
        coloring_axis_index = i;
        press = true;
      }
      axes[i].mouse_pressed(); // for ranges on each axis
    }
    
    // now check for clicks on the flip buttons
    // and flip axes if necessary
    for (int i=0; i < num_axes; i++) {
      if (axes[i].check_flip()) {
        axes[i].flip();
      }
    }
    return press;
  }
  
  void mouse_dragged() {
    for (int i=0; i < num_axes; i++) {
      axes[i].mouse_dragged(); // for dragging axis ranges
    }
  }
  
  void mouse_released() {
    for (int i=0; i < num_axes; i++) {
      axes[i].mouse_released(); // for dragging axis ranges
    }
  }
  
  // returns true if there has been a click that deselects an axis range
  boolean mouse_clicked() {
    for (int i=0; i < num_axes; i++) {
      if (axes[i].mouse_clicked()) {
        return true;
      }
    }
    return false;
  }
  
  // get the index of the axis that is closest to the mouse
  int get_closest_axis() {
    int closest_axis_index = 0;
    float closest_distance = width;
    
    // iterate through the axes to find the one that is closest to the mouse x position
    for (int i=0; i < num_axes; i++) {
      float dist = abs(axes[i].rect_x - mouseX);
      if (dist < closest_distance) {
        closest_distance = dist;
        closest_axis_index = i;
      }
    }
    return closest_axis_index;
  }
  
  String[] get_axes_labels() {
    return d.column_labels;
  }
  
}

// axis class stores a single y axis for the parallel coordinates
// can draw itself and convert data values to y values
class YAxis {
  // order is the index of the order of this axis (start at 0 is the leftmost axis)
  int order, num_axes;
  float max_value, min_value; // NOT in y coordinate, but in data values
  String label;
  color fill_color;
  boolean reversed = false; // reversed is true if the low value is at the top, otherwise false
  float rect_x, rect_y, rect_width, rect_height; // the dimensions of the rectangle drawn for the axis
  Button flip_button;
  PFont number_font = createFont("Arial", 12, true);
  PFont label_font = createFont("Arial", 14, true);
  float press_x, press_y; // the location starting the press and before the dragging
  
  // allow user to selecte the ranges to show of the axis
  // note that these are data values, not y coordinates 
  float selected_max_value, selected_min_value; 
  boolean selecting_range = false; // true if the user is currently selecting the range
  boolean draw_selection = false; // true if the selection should be drawn right now 
  
  YAxis(int order, int num_axes, String label, float min_value, float max_value, color fill_color) {
    this.order = order;
    this.num_axes = num_axes;
    this.label = label;
    this.max_value = max_value;
    this.min_value = min_value;
    this.fill_color = fill_color;
    flip_button = new Button("Flip");
  }
  
  void draw(PGraphics top_layer) {
    // gap from this axis x value to the next axis x value
    float gap = (width - 2*Config.x_margin - Config.axis_width) / (num_axes - 1);
    
    // dimensions of the rectangle to draw for the axis
    rect_x = gap * order + Config.x_margin;
    rect_y = Config.y_margin_top;
    rect_width = Config.axis_width;
    rect_height = height - Config.y_margin_top - Config.y_margin_bottom;
    
    // draw the main axis
    fill(fill_color);
    stroke(0, 0, 0); // black borders
    rect(rect_x, rect_y, rect_width, rect_height);
    
    // draw the highlighted range
    if (draw_selection) {
      fill(Config.axis_range_color);
      float y1 = get_y(selected_max_value);
      float y2 = get_y(selected_min_value);
      rect(rect_x, min(y1, y2), Config.axis_width, abs(y2 - y1));
       
      float top_y = min(y1, y2) - 3;
      float bottom_y = max(y1, y2) + 3;
       
      top_layer.beginDraw();
      top_layer.textFont(createFont("Arial", 12, true));
      top_layer.fill(0, 0, 0);
      
      if (reversed) {
        top_layer.textAlign(CENTER, BOTTOM);
        top_layer.text(selected_min_value, rect_x + rect_width / 2, top_y);
        top_layer.textAlign(CENTER, TOP);
        top_layer.text(selected_max_value, rect_x + rect_width / 2, bottom_y);
      }
      else {
        top_layer.textAlign(CENTER, BOTTOM);
        top_layer.text(selected_max_value, rect_x + rect_width / 2, top_y);
        top_layer.textAlign(CENTER, TOP);
        top_layer.text(selected_min_value, rect_x + rect_width / 2, bottom_y);
      }
      top_layer.endDraw();
    }
    
    // draw the labels
    textAlign(CENTER, CENTER);
    fill(0);
    textFont(label_font);
    text(label, rect_x + Config.axis_width / 2, Config.col_label_y); // dimension label
    
    // draw the flip button
    flip_button.set_position(rect_x + Config.axis_width / 2, Config.y_margin_top / 2, 40, 25);
    flip_button.draw();
    
    float top_label_y = Config.y_margin_top - 15;
    float bottom_label_y = height - Config.y_margin_bottom + 15;
    // draw labels for the top and bottom values
    fill(0, 0, 0);
    textFont(number_font);
    if (reversed) {
      // draw the min value and the top and the max value at the bottom
      textFont(number_font);
      text(min_value, rect_x + rect_width / 2, top_label_y);
      text(max_value, rect_x + rect_width / 2, bottom_label_y);
    }
    else {
      // draw the max value and the top and the min value at the bottom
      text(min_value, rect_x + rect_width / 2, bottom_label_y);
      text(max_value, rect_x + rect_width / 2, top_label_y);
    }
  }
  
  // convert from data values to graphics y values
  float get_y(float value) {
    float scale_factor = (height - Config.y_margin_top - Config.y_margin_bottom) / (max_value - min_value);
    if (reversed) {
      return (value - min_value)*scale_factor + Config.y_margin_top;
    }
    else {
      return (max_value - value)*scale_factor + Config.y_margin_top;
    }
  }
  
  // convert from y coordinates to data value (inverse of get_y)
  float get_value(float y) {
    float scale_factor = (height - Config.y_margin_top - Config.y_margin_bottom) / (max_value - min_value);
    if (reversed) {
      return (y - Config.y_margin_top) / scale_factor + min_value;
    }
    else {
      return (Config.y_margin_top - y) / scale_factor + max_value;
    }
  }
  
  // get the color corresponding to the value on this axis
  color get_color(float value) {
    float fraction = (value - min_value) / (max_value - min_value); // fraction from min to max
    return lerpColor(Config.min_color, Config.max_color, fraction);
  }
  
  // return the x value at the center of the axis
  float get_center_x() {
    return rect_x + rect_width / 2;
  }
  
  void set_color(color c) {
    this.fill_color = c;
  }
  
  // return true if the value is within the selected range or if
  // the user has not selected a range
  boolean in_range(float value) {
    if (!draw_selection) { // if no selection, always in range
      return true;
    }
    else {
      return value >= selected_min_value && value <= selected_max_value;
    }
  }
  
  // clear selected range (if there is one) from this axis
  void clear_range() {
    draw_selection = false;
    selecting_range = false;
  }
  
  boolean mouse_over() {
    return (mouseX >= rect_x && mouseX <= rect_x + rect_width &&
            mouseY >= rect_y && mouseY <= rect_y + rect_height);
  }
  
  // call this when the mouse is pressed
  // for clicking and dragging of the axis range
  // returns true is the mouse button press is in the axis
  boolean mouse_pressed() {
    if (mouse_over()) {
      press_x = mouseX;
      press_y = mouseY;
      draw_selection = true;
      selecting_range = true;
      return true;
    }
    return false;
  }
  
  // check for clicks for clearing the selected range
  // returns true if there has been a range deselection, so redrawing is needed
  boolean mouse_clicked() {
    if (mouse_over()) {
      if (draw_selection) {
        float y1 = get_y(selected_max_value);
        float y2 = get_y(selected_min_value);
        float top_y = min(y1, y2);
        float bottom_y = max(y1, y2);
        if (mouseY <= top_y || mouseY >= bottom_y) {
          // click outside the range, so deselect the range
          draw_selection = false;
          return true;
        }
      }
    }
    return false;
  }
  
  void mouse_dragged() {
    if (selecting_range) {
      float value1 = get_value(press_y);
      float value2 = get_value(mouseY);
      selected_max_value = max(value1, value2);
      selected_min_value = min(value1, value2);
    }
  }
  
  void mouse_released() {
    selecting_range = false;
  }
  
  // check to see if the mouse is over the flip button (so we can check for clicks)
  boolean check_flip() {
    return flip_button.mouseInButton();
  }
  
  // reverse the orientation of the axis
  void flip() {
    reversed = !reversed;
  }
}